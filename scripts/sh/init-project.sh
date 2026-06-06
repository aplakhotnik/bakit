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

[ $# -ge 1 ] && [ -n "${1:-}" ] || bakit_die "usage: init-project.sh \"<project name>\""

RAW_NAME="$1"
SLUG=$(bakit_require_safe_name "$RAW_NAME" "project name")
PROJECT_DIR=$(bakit_project_dir "$SLUG")

if [ -e "$PROJECT_DIR" ]; then
  bakit_die "project '$SLUG' already exists at $PROJECT_DIR; choose a different name or run init-task.sh to add a task"
fi

TEMPLATE="$BAKIT_HOME/templates/project/project.md"
[ -f "$TEMPLATE" ] || bakit_die "project template not found: $TEMPLATE"

TODAY=$(bakit_today)

mkdir -p "$PROJECT_DIR/tasks"

# Populate template: front-matter fields + title placeholder.
sed \
  -e "s/^id: \"\"/id: $SLUG/" \
  -e "s/^title: \"\"/title: \"$RAW_NAME\"/" \
  -e "s/^created: \"\"/created: $TODAY/" \
  -e "s/^updated: \"\"/updated: $TODAY/" \
  -e "s/{{TITLE}}/$RAW_NAME/g" \
  "$TEMPLATE" > "$PROJECT_DIR/project.md"

bakit_set_active "$SLUG" ""

bakit_log "Created project '$SLUG' at $PROJECT_DIR"
bakit_log "  - project.md"
bakit_log "  - tasks/"
bakit_log ""
bakit_log "Next: ./scripts/sh/init-task.sh \"$SLUG\" \"<task name>\""
