#!/bin/sh
# BA-Kit: initialize a new Task within a project.
#
# Usage: init-task.sh "<project name>" "<task name>"
#
# Creates: $BAKIT_WORKSPACE/<project>/tasks/NNN-<task-slug>/{inputs,artifacts,deliverables}
# Sequential numbering; collision-safe; updates the .bakit-active pointer.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

[ $# -ge 2 ] && [ -n "${1:-}" ] && [ -n "${2:-}" ] || bakit_die "usage: init-task.sh \"<project name>\" \"<task name>\""

PROJECT_SLUG=$(bakit_require_safe_name "$1" "project name")
TASK_RAW="$2"
TASK_SLUG=$(bakit_require_safe_name "$TASK_RAW" "task name")
PROJECT_DIR=$(bakit_project_dir "$PROJECT_SLUG")

[ -d "$PROJECT_DIR" ] || bakit_die "project '$PROJECT_SLUG' does not exist at $PROJECT_DIR; create it first with init-project.sh"

SEQ=$(bakit_next_task_seq "$PROJECT_SLUG")
TASK_NAME="$SEQ-$TASK_SLUG"
TASK_DIR="$PROJECT_DIR/tasks/$TASK_NAME"

if [ -e "$TASK_DIR" ]; then
  bakit_die "task '$TASK_NAME' already exists at $TASK_DIR; choose a different name"
fi

mkdir -p "$TASK_DIR/inputs" "$TASK_DIR/artifacts" "$TASK_DIR/deliverables" "$TASK_DIR/kb"

# Add a small README in inputs/ to guide the analyst.
cat > "$TASK_DIR/inputs/README.md" <<EOF
# Inputs for task $TASK_NAME

Place raw source material here (notes, documents, transcripts) as text-based files.
Skills such as \`ba.specify-requirements\` and \`ba.analyze-docs\` read from this folder.
EOF

# Seed the task-level knowledge base index from the template.
KB_TEMPLATE="$BAKIT_HOME/templates/task/kb-index.md"
TODAY=$(bakit_today)
if [ -f "$KB_TEMPLATE" ]; then
  sed \
    -e "s/^id: \"\"/id: $TASK_NAME-kb/" \
    -e "s/^title: \"\"/title: \"$TASK_RAW\"/" \
    -e "s/^created: \"\"/created: $TODAY/" \
    -e "s/^updated: \"\"/updated: $TODAY/" \
    -e "s/{{TITLE}}/$TASK_RAW/g" \
    "$KB_TEMPLATE" > "$TASK_DIR/kb/index.md"
else
  bakit_warn "task kb-index template not found: $KB_TEMPLATE (kb/ left without an index)"
fi

bakit_set_active "$PROJECT_SLUG" "$TASK_NAME"

bakit_log "Created task '$TASK_NAME' in project '$PROJECT_SLUG'"
bakit_log "  $TASK_DIR/"
bakit_log "    - inputs/        (put source material here)"
bakit_log "    - artifacts/     (skill outputs land here)"
bakit_log "    - deliverables/  (rendered outputs, e.g. Confluence pages)"
bakit_log "    - kb/index.md    (task-scoped knowledge base)"
bakit_log ""
bakit_log "Active task set to: $PROJECT_SLUG / $TASK_NAME"
