#!/bin/sh
# BA-Kit: list artifacts and their approval status across a project (or task).
#
# Usage:
#   list-artifacts.sh ["<project>"] ["<task>"]
#
# With no arguments, resolves the active project/task. Lists each artifact's
# type and status using check-artifact.sh.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"
CHECK="$SCRIPT_DIR/check-artifact.sh"

PROJECT=$(bakit_resolve_project "${1:-}") || bakit_die "no project found; create one with init-project.sh"
PROJECT_DIR=$(bakit_project_dir "$PROJECT")
[ -d "$PROJECT_DIR" ] || bakit_die "project '$PROJECT' not found at $PROJECT_DIR"

list_one_task() {
  _task="$1"; _tdir="$PROJECT_DIR/tasks/$_task"
  bakit_log "Task: $_task"
  _found=0
  for dir in artifacts deliverables; do
    [ -d "$_tdir/$dir" ] || continue
    for f in "$_tdir/$dir"/*.md; do
      [ -e "$f" ] || continue
      _found=1
      _type=$(bakit_frontmatter_field "$f" type 2>/dev/null || true)
      _status=$(bakit_frontmatter_field "$f" status 2>/dev/null || true)
      [ -n "$_type" ] || _type="?"
      [ -n "$_status" ] || _status="(no front-matter)"
      printf '  [%s] %-16s %s/%s\n' "$_status" "$_type" "$dir" "$(basename "$f")"
    done
  done
  [ "$_found" -eq 1 ] || bakit_log "  (no artifacts yet)"
}

bakit_log "Project: $PROJECT"
bakit_log ""

if [ -n "${2:-}" ]; then
  list_one_task "$2"
else
  TASKS_DIR="$PROJECT_DIR/tasks"
  if [ -d "$TASKS_DIR" ]; then
    _any=0
    for t in "$TASKS_DIR"/*; do
      [ -d "$t" ] || continue
      _any=1
      list_one_task "$(basename "$t")"
      bakit_log ""
    done
    [ "$_any" -eq 1 ] || bakit_log "(no tasks yet — create one with init-task.sh)"
  else
    bakit_log "(no tasks yet — create one with init-task.sh)"
  fi
fi
