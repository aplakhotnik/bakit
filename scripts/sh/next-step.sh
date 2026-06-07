#!/bin/sh
# BA-Kit: suggest the next workflow step for the active (or named) task.
#
# Usage:
#   next-step.sh [--workflow <manifest>] [<project>] [<task>]
#
# Reads the ordered chain from a workflow manifest (default bakit/workflow.md; pass
# --workflow <relative-manifest> to read an alternate manifest such as
# workflow-discovery.md, resolved relative to BAKIT_HOME) and the current workspace
# state, then prints the next runnable skill and any unmet approval gate. It never
# modifies anything. A missing manifest or task is reported, not fatal-crashed.
#
# Exit codes:
#   0  a suggestion (next step, gate, or "complete") was printed
#   1  could not resolve a project/task or the workflow manifest

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

CHECK="$SCRIPT_DIR/check-artifact.sh"

# Parse options. --workflow selects an alternate manifest (relative to BAKIT_HOME);
# remaining positional args are [<project>] [<task>], preserving existing behavior.
WORKFLOW_REL="workflow.md"
while [ $# -gt 0 ]; do
  case "$1" in
    --workflow) [ $# -ge 2 ] || bakit_die "--workflow requires a manifest path"; WORKFLOW_REL="$2"; shift 2 ;;
    --workflow=*) WORKFLOW_REL="${1#--workflow=}"; shift ;;
    -h|--help) sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --) shift; break ;;
    -*) bakit_die "unknown option: $1" ;;
    *) break ;;
  esac
done

WORKFLOW="$BAKIT_HOME/$WORKFLOW_REL"

# Capture a check-artifact.sh exit code without tripping `set -e`.
check_ec() { _ec=0; sh "$CHECK" "$@" >/dev/null 2>&1 || _ec=$?; printf '%s' "$_ec"; }

[ -f "$WORKFLOW" ] || { bakit_warn "workflow manifest not found: $WORKFLOW"; exit 1; }

# Resolve the active project/task.
PROJECT=$(bakit_resolve_project "${1:-}") || { bakit_warn "no project found; run ba.start-project first"; exit 1; }
TASK=$(bakit_resolve_task "$PROJECT" "${2:-}") || { bakit_warn "no task found in project '$PROJECT'; run ba.start-task first"; exit 1; }
TASK_DIR="$(bakit_project_dir "$PROJECT")/tasks/$TASK"

[ -d "$TASK_DIR" ] || { bakit_warn "task directory not found: $TASK_DIR"; exit 1; }

# Extract the machine-readable rows from between the workflow markers.
ROWS=$(awk '
  /<!-- BAKIT-WORKFLOW-START -->/ { inblock=1; next }
  /<!-- BAKIT-WORKFLOW-END -->/   { inblock=0 }
  inblock && /^[0-9]+\|/          { print }
' "$WORKFLOW")

[ -n "$ROWS" ] || { bakit_warn "no workflow steps found in $WORKFLOW"; exit 1; }

# Find the skill that produces a given artifact path (for nicer gate messages).
producer_of() {
  printf '%s\n' "$ROWS" | awk -F'|' -v want="$1" '$3==want { print $2; exit }'
}

# Is a step's output already present?
is_produced() {
  _produces="$1"; _path="$TASK_DIR/$_produces"
  if [ "$_produces" = "deliverables" ]; then
    # Terminal step: produced if any deliverable file exists.
    for f in "$_path"/*.md; do [ -e "$f" ] && return 0; done
    return 1
  fi
  [ -f "$_path" ]
}

bakit_log "Project: $PROJECT"
bakit_log "Task:    $TASK"
bakit_log ""

# Determine the furthest-progressed step (highest order whose output exists).
# Steps earlier in the chain may be intentionally skipped (e.g. analyze-docs),
# so the next action is the step *after* the furthest one already produced.
LAST_DONE=0
MAX_ORDER=0
while IFS='|' read -r order skill produces requires gate; do
  [ -n "$order" ] || continue
  [ "$order" -gt "$MAX_ORDER" ] && MAX_ORDER="$order"
  if is_produced "$produces"; then
    [ "$order" -gt "$LAST_DONE" ] && LAST_DONE="$order"
  fi
done <<EOF
$ROWS
EOF

if [ "$LAST_DONE" -ge "$MAX_ORDER" ]; then
  bakit_log "All workflow steps have produced output."
  bakit_log "  Review/approve artifacts and render deliverables as needed."
  exit 0
fi

NEXT_ORDER=$((LAST_DONE + 1))

# Read the next step's row and evaluate its approval gate.
NEXT_ROW=$(printf '%s\n' "$ROWS" | awk -F'|' -v o="$NEXT_ORDER" '$1==o { print; exit }')
[ -n "$NEXT_ROW" ] || { bakit_log "No further workflow steps defined."; exit 0; }

skill=$(printf '%s' "$NEXT_ROW" | cut -d'|' -f2)
produces=$(printf '%s' "$NEXT_ROW" | cut -d'|' -f3)
requires=$(printf '%s' "$NEXT_ROW" | cut -d'|' -f4)
gate=$(printf '%s' "$NEXT_ROW" | cut -d'|' -f5)

if [ "$requires" != "none" ] && [ -n "$requires" ]; then
  req_path="$TASK_DIR/$requires"
  if [ ! -f "$req_path" ]; then
    prod=$(producer_of "$requires")
    bakit_log "Blocked: $skill needs '$requires' first."
    bakit_log "  ▶ Run ${prod:-the producing skill} to create it, then approve it."
    exit 0
  fi
  ec=$(check_ec --require-approved "$req_path")
  if [ "$ec" != "0" ]; then
    bakit_log "Gate not met: $skill requires '$requires' to be approved."
    bakit_log "  ✎ Review and set 'status: approved' in $requires, then run $skill."
    exit 0
  fi
fi

bakit_log "Next: $skill"
bakit_log "  ▶ Produces $produces"
