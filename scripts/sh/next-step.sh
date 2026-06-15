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

# Is a step's approval gate satisfied (no prerequisite, or prerequisite present + approved)?
gate_satisfied() {
  _req="$1"
  if [ "$_req" = "none" ] || [ -z "$_req" ]; then return 0; fi
  _rp="$TASK_DIR/$_req"
  [ -f "$_rp" ] || return 1
  [ "$(check_ec --require-approved "$_rp")" = "0" ]
}

bakit_log "Project: $PROJECT"
bakit_log "Task:    $TASK"
bakit_log ""

# Determine the furthest-progressed step (highest order whose output exists).
# Steps earlier in the chain may be intentionally skipped (e.g. analyze-docs),
# so the next action is the step *after* the furthest one already produced.
# Rows carry a 6th `optional` field (008); legacy 5-field rows default to false.
LAST_DONE=0
MAX_ORDER=0
while IFS='|' read -r order skill produces requires gate optional; do
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

# Ordered-row scan over the remaining rows (order > LAST_DONE), ascending.
# An optional step (optional=true) that is runnable now is surfaced as a
# *suggested-but-not-gating* hint; the first required step (optional=false) is the
# runnable "Next" step. Because the manifest uses consecutive integers but an
# optional step may be skipped, we scan the ordered rows rather than doing a single
# `LAST_DONE + 1` exact-order lookup.
REQ_ROW=""
OPTIONAL_SUGGEST=""
while IFS='|' read -r order skill produces requires gate optional; do
  [ -n "$order" ] || continue
  [ "$order" -gt "$LAST_DONE" ] || continue
  case "$optional" in true|TRUE|True) optional=true ;; *) optional=false ;; esac
  if [ "$optional" = "true" ]; then
    # Suggested-but-not-gating: surface only when its own gate is already satisfied,
    # so it is never offered prematurely (before its prerequisite is approved).
    if gate_satisfied "$requires"; then
      OPTIONAL_SUGGEST="${OPTIONAL_SUGGEST}Optional: $skill — produces $produces (suggested; never required, you may skip it)
"
    fi
    continue
  fi
  # First required remaining row: this is the runnable next step.
  REQ_ROW="$order|$skill|$produces|$requires|$gate"
  break
done <<EOF
$ROWS
EOF

# Surface any optional suggestions first (clearly labelled, never a blocker).
if [ -n "$OPTIONAL_SUGGEST" ]; then
  printf '%s' "$OPTIONAL_SUGGEST" | while IFS= read -r _line; do
    [ -n "$_line" ] && bakit_log "$_line"
  done
fi

if [ -z "$REQ_ROW" ]; then
  bakit_log "No further required workflow steps defined."
  exit 0
fi

skill=$(printf '%s' "$REQ_ROW" | cut -d'|' -f2)
produces=$(printf '%s' "$REQ_ROW" | cut -d'|' -f3)
requires=$(printf '%s' "$REQ_ROW" | cut -d'|' -f4)
gate=$(printf '%s' "$REQ_ROW" | cut -d'|' -f5)

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
  # Advisory only (007): if the approved prerequisite still carries blocking open
  # questions, surface a warning but DO NOT block — the analyst decides whether to
  # proceed or first resolve the gaps. This never changes the exit code.
  blocking=$(bakit_frontmatter_field "$req_path" "blocking_questions" 2>/dev/null || true)
  case "$blocking" in
    ''|*[!0-9]*) blocking=0 ;;
  esac
  if [ "$blocking" -gt 0 ]; then
    bakit_warn "$requires has $blocking blocking open question(s) still unresolved."
    bakit_log  "  ⚠ Advisory: you may proceed to $skill, but resolving the blocking"
    bakit_log  "    question(s) first is recommended. See its '## Open Questions' table."
  fi
fi

bakit_log "Next: $skill"
bakit_log "  ▶ Produces $produces"
