#!/bin/sh
# BA-Kit: initialize a new Project workspace.
#
# Usage: init-project.sh "<project name>"
#
# Creates: $BAKIT_WORKSPACE/<slug>/project.md (from template) and a tasks/ dir.
# Collision-safe: refuses to overwrite an existing project.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

# --- args: "<name>" [--mode independent|brain] [--upgrade-to-brain] ---
MODE=independent
UPGRADE=0
RAW_NAME=""
while [ $# -gt 0 ]; do
  case "$1" in
    --mode) MODE="${2:-}"; shift 2 ;;
    --mode=*) MODE="${1#*=}"; shift ;;
    --upgrade-to-brain) UPGRADE=1; shift ;;
    -h|--help)
      cat <<EOF
usage: init-project.sh "<project name>" [--mode independent|brain]
       init-project.sh "<project name>" --upgrade-to-brain

Modes:
  independent  (default) light shared kb/index.md; §11 promotion is best-effort.
  brain        kb/ is the single source of truth; scaffolds changelog + registers,
               and §11 promotion is expected on every task.
EOF
      exit 0 ;;
    -*) bakit_die "unknown option: $1 (try --help)" ;;
    *) if [ -z "$RAW_NAME" ]; then RAW_NAME="$1"; else bakit_die "unexpected argument: $1"; fi; shift ;;
  esac
done

[ -n "$RAW_NAME" ] || bakit_die "usage: init-project.sh \"<project name>\" [--mode independent|brain]"
case "$MODE" in independent|brain) : ;; *) bakit_die "invalid --mode '$MODE' (expected: independent|brain)" ;; esac
[ "$UPGRADE" -eq 1 ] && MODE=brain

SLUG=$(bakit_require_safe_name "$RAW_NAME" "project name")
PROJECT_DIR=$(bakit_project_dir "$SLUG")
TODAY=$(bakit_today)
BRAIN_DIR="$BAKIT_HOME/templates/project/brain"

# Fill a template's universal placeholders into a destination. fill_tpl <tpl> <dest> <id>
fill_tpl() {
  sed \
    -e "s/^id: \"\"/id: $3/" \
    -e "s/^title: \"\"/title: \"$RAW_NAME\"/" \
    -e "s/^created: \"\"/created: $TODAY/" \
    -e "s/^updated: \"\"/updated: $TODAY/" \
    -e "s/{{TITLE}}/$RAW_NAME/g" \
    "$1" > "$2"
}

# Set (or insert) the kb_mode front-matter field in a project.md. POSIX-portable (no sed -i).
set_kb_mode() { # file mode
  if grep -q '^kb_mode:' "$1"; then
    sed "s/^kb_mode:.*/kb_mode: $2/" "$1" > "$1.tmp" && mv "$1.tmp" "$1"
  else
    awk -v m="$2" '{print} /^status:/ && !d {print "kb_mode: " m; d=1}' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
  fi
}

# Scaffold the five brain registers (skip any that already exist — non-destructive).
scaffold_brain_registers() {
  for name in changelog requirements-register open-questions decisions glossary; do
    _tpl="$BRAIN_DIR/$name.md"
    _dst="$PROJECT_DIR/kb/$name.md"
    [ -f "$_tpl" ] || bakit_die "brain template missing: $_tpl"
    if [ -f "$_dst" ]; then
      bakit_log "  = kb/$name.md (kept)"
    else
      fill_tpl "$_tpl" "$_dst" "$SLUG-$name"
      bakit_log "  + kb/$name.md"
    fi
  done
}

if [ "$UPGRADE" -eq 1 ]; then
  # --- migration: upgrade an existing project to brain mode (idempotent, non-destructive) ---
  [ -d "$PROJECT_DIR" ] || bakit_die "project '$SLUG' not found at $PROJECT_DIR (nothing to upgrade)"
  mkdir -p "$PROJECT_DIR/kb"
  [ -f "$PROJECT_DIR/project.md" ] && set_kb_mode "$PROJECT_DIR/project.md" brain
  bakit_log "Upgraded project '$SLUG' to brain mode (existing files kept):"
  scaffold_brain_registers
  bakit_log ""
  bakit_log "The project kb/ is now the brain. Tasks promote digests here (constitution §11)."
  exit 0
fi

# --- fresh project ---
[ -e "$PROJECT_DIR" ] && bakit_die "project '$SLUG' already exists at $PROJECT_DIR; choose a different name or run init-task.sh to add a task"

TEMPLATE="$BAKIT_HOME/templates/project/project.md"
[ -f "$TEMPLATE" ] || bakit_die "project template not found: $TEMPLATE"

if [ "$MODE" = brain ]; then
  KB_TEMPLATE="$BRAIN_DIR/kb-index.md"
else
  KB_TEMPLATE="$BAKIT_HOME/templates/project/kb-index.md"
fi
[ -f "$KB_TEMPLATE" ] || bakit_die "project kb-index template not found: $KB_TEMPLATE"

mkdir -p "$PROJECT_DIR/tasks" "$PROJECT_DIR/kb"

fill_tpl "$TEMPLATE" "$PROJECT_DIR/project.md" "$SLUG"
set_kb_mode "$PROJECT_DIR/project.md" "$MODE"
fill_tpl "$KB_TEMPLATE" "$PROJECT_DIR/kb/index.md" "$SLUG-kb"

bakit_set_active "$SLUG" ""

bakit_log "Created project '$SLUG' ($MODE mode) at $PROJECT_DIR"
bakit_log "  - project.md"
bakit_log "  - tasks/"
bakit_log "  - kb/index.md   (shared project knowledge base)"
if [ "$MODE" = brain ]; then
  scaffold_brain_registers
  bakit_log ""
  bakit_log "Brain mode: the project kb/ is the single source of truth. Tasks ground on it and"
  bakit_log "promote digests back (constitution §11), non-destructively (§12)."
fi
bakit_log ""
bakit_log "Next: ./scripts/sh/init-task.sh \"$SLUG\" \"<task name>\""
