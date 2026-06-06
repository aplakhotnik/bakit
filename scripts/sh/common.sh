#!/bin/sh
# BA-Kit shared shell helpers (POSIX sh)
#
# Sourced by the other scripts. Provides: path resolution, logging, slugify,
# active project/task resolution, and YAML front-matter field parsing.
#
# Environment:
#   BAKIT_WORKSPACE  Root directory for analyst workspaces (default: $PWD/workspace)

# --- Resolution -------------------------------------------------------------

# Directory containing this script (.../bakit/scripts/sh).
BAKIT_SH_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd 2>/dev/null) || BAKIT_SH_DIR="$PWD"
# Framework root (.../bakit).
BAKIT_HOME=$(CDPATH= cd -- "$BAKIT_SH_DIR/../.." && pwd)
# Workspace root where projects/tasks live.
BAKIT_WORKSPACE="${BAKIT_WORKSPACE:-$PWD/workspace}"
# Active pointer file (convenience only; never a source of record).
BAKIT_ACTIVE_FILE="$BAKIT_WORKSPACE/.bakit-active"

# --- Logging ----------------------------------------------------------------

bakit_log()  { printf '%s\n' "$*"; }
bakit_warn() { printf 'warning: %s\n' "$*" >&2; }
bakit_die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

# --- Helpers ----------------------------------------------------------------

# Convert an arbitrary name into a filesystem-safe slug.
bakit_slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/[^a-z0-9]\{1,\}/-/g' -e 's/^-//' -e 's/-$//'
}

# Validate that a name produces a non-empty, safe slug. Exits on failure.
bakit_require_safe_name() {
  _name="$1"; _what="${2:-name}"
  case "$_name" in
    *..*|*/*|*\\*) bakit_die "$_what contains illegal path characters: '$_name'" ;;
  esac
  _slug=$(bakit_slugify "$_name")
  [ -n "$_slug" ] || bakit_die "$_what '$_name' is empty after sanitising; choose another"
  printf '%s' "$_slug"
}

# Today's date (ISO).
bakit_today() { date +%Y-%m-%d; }

# Path to a project directory.
bakit_project_dir() { printf '%s/%s' "$BAKIT_WORKSPACE" "$1"; }

# Write the active project/task pointer.
bakit_set_active() {
  mkdir -p "$BAKIT_WORKSPACE"
  printf 'project=%s\ntask=%s\n' "$1" "${2:-}" > "$BAKIT_ACTIVE_FILE"
}

# Resolve the active project: explicit arg -> pointer -> most-recent dir.
bakit_resolve_project() {
  if [ -n "${1:-}" ]; then printf '%s' "$1"; return 0; fi
  if [ -f "$BAKIT_ACTIVE_FILE" ]; then
    _p=$(sed -n 's/^project=//p' "$BAKIT_ACTIVE_FILE")
    [ -n "$_p" ] && [ -d "$(bakit_project_dir "$_p")" ] && { printf '%s' "$_p"; return 0; }
  fi
  [ -d "$BAKIT_WORKSPACE" ] || return 1
  _p=$(ls -1t "$BAKIT_WORKSPACE" 2>/dev/null | while read -r d; do
         [ -d "$BAKIT_WORKSPACE/$d" ] && { printf '%s' "$d"; break; }
       done)
  [ -n "$_p" ] && { printf '%s' "$_p"; return 0; }
  return 1
}

# Resolve the active task within a project: explicit arg -> pointer -> most-recent.
bakit_resolve_task() {
  _proj="$1"; _tasks_dir="$(bakit_project_dir "$_proj")/tasks"
  if [ -n "${2:-}" ]; then printf '%s' "$2"; return 0; fi
  if [ -f "$BAKIT_ACTIVE_FILE" ]; then
    _t=$(sed -n 's/^task=//p' "$BAKIT_ACTIVE_FILE")
    [ -n "$_t" ] && [ -d "$_tasks_dir/$_t" ] && { printf '%s' "$_t"; return 0; }
  fi
  [ -d "$_tasks_dir" ] || return 1
  _t=$(ls -1t "$_tasks_dir" 2>/dev/null | while read -r d; do
         [ -d "$_tasks_dir/$d" ] && { printf '%s' "$d"; break; }
       done)
  [ -n "$_t" ] && { printf '%s' "$_t"; return 0; }
  return 1
}

# Next zero-padded task sequence number for a project (001, 002, ...).
bakit_next_task_seq() {
  _tasks_dir="$(bakit_project_dir "$1")/tasks"
  _max=0
  if [ -d "$_tasks_dir" ]; then
    for d in "$_tasks_dir"/*; do
      [ -d "$d" ] || continue
      _n=$(basename "$d" | sed -n 's/^\([0-9][0-9]*\)-.*$/\1/p')
      [ -n "$_n" ] || continue
      _n=$(printf '%d' "$_n" 2>/dev/null) || continue
      [ "$_n" -gt "$_max" ] && _max="$_n"
    done
  fi
  printf '%03d' $((_max + 1))
}

# --- YAML front-matter parsing ---------------------------------------------

# Print the value of a top-level front-matter scalar field, or empty if absent.
# Usage: bakit_frontmatter_field <file> <field>
bakit_frontmatter_field() {
  _file="$1"; _field="$2"
  [ -f "$_file" ] || return 1
  awk -v field="$_field" '
    NR==1 && $0 != "---" { exit 1 }
    NR==1 { infm=1; next }
    infm && $0=="---" { exit 1 }
    infm {
      line=$0
      idx=index(line, ":")
      if (idx>0) {
        key=substr(line,1,idx-1)
        gsub(/^[ \t]+|[ \t]+$/, "", key)
        if (key==field) {
          val=substr(line, idx+1)
          gsub(/^[ \t]+|[ \t]+$/, "", val)
          gsub(/^"|"$/, "", val)
          print val
          exit 0
        }
      }
    }
  ' "$_file"
}

# Return 0 if the file has a parseable front-matter block (starts with --- and closes).
bakit_has_frontmatter() {
  _file="$1"
  [ -f "$_file" ] || return 1
  awk '
    NR==1 && $0 != "---" { exit 1 }
    NR>1 && $0=="---" { found=1; exit 0 }
    END { if (!found) exit 1 }
  ' "$_file"
}
