#!/bin/sh
# BA-Kit: validate an artifact's YAML front-matter and approval status.
#
# Usage:
#   check-artifact.sh <artifact.md>
#   check-artifact.sh --require-approved <artifact.md>
#
# Exit codes:
#   0  valid (and, with --require-approved, status is 'approved')
#   1  invalid front-matter / missing required fields
#   2  valid but status is not 'approved' (only with --require-approved)
#
# Prints the resolved status on success so callers/skills can gate on it.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/common.sh"

REQUIRE_APPROVED=0
FILE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --require-approved) REQUIRE_APPROVED=1; shift ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) bakit_die "unknown option: $1" ;;
    *) FILE="$1"; shift ;;
  esac
done

[ -n "$FILE" ] || bakit_die "no artifact path given (try --help)"
[ -f "$FILE" ] || bakit_die "artifact not found: $FILE"

# 1. Front-matter must parse.
bakit_has_frontmatter "$FILE" || bakit_die "missing or unparseable YAML front-matter: $FILE"

# 2. Universally required fields.
for field in id type title status created updated; do
  val=$(bakit_frontmatter_field "$FILE" "$field" || true)
  [ -n "$val" ] || bakit_die "front-matter field '$field' is missing or empty: $FILE"
done

TYPE=$(bakit_frontmatter_field "$FILE" type)
STATUS=$(bakit_frontmatter_field "$FILE" status)

# 3. status must be a known value (project uses a different lifecycle).
case "$TYPE" in
  project)
    case "$STATUS" in
      active|archived) : ;;
      *) bakit_die "project status must be 'active' or 'archived' (got '$STATUS'): $FILE" ;;
    esac ;;
  *)
    case "$STATUS" in
      draft|approved) : ;;
      *) bakit_die "status must be 'draft' or 'approved' (got '$STATUS'): $FILE" ;;
    esac ;;
esac

# 4. type-conditional required fields (traceability).
require_field() {
  v=$(bakit_frontmatter_field "$FILE" "$1" || true)
  [ -n "$v" ] && [ "$v" != "[]" ] || bakit_die "front-matter field '$1' is required for type '$TYPE': $FILE"
}
case "$TYPE" in
  docs-analysis)             require_field sources ;;
  user-stories|confluence-page) require_field derived_from ;;
  requirements|project)      : ;;
  *) bakit_warn "unknown artifact type '$TYPE' (continuing): $FILE" ;;
esac

# 5. Approval gate.
if [ "$REQUIRE_APPROVED" -eq 1 ] && [ "$STATUS" != "approved" ]; then
  printf 'status: %s\n' "$STATUS"
  bakit_warn "artifact is not approved: $FILE"
  exit 2
fi

printf 'status: %s\n' "$STATUS"
exit 0
