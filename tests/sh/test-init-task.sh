#!/bin/sh
# Tests for init-task.sh: structure, sequential numbering, collision safety.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPTS="$SCRIPT_DIR/../../scripts/sh"

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t bakit)
trap 'rm -rf "$TMP"' EXIT
export BAKIT_WORKSPACE="$TMP/workspace"

pass=0; fail=0
ok() { pass=$((pass+1)); printf 'ok   - %s\n' "$1"; }
no() { fail=$((fail+1)); printf 'FAIL - %s\n' "$1"; }
run() { _ec=0; sh "$@" >/dev/null 2>&1 || _ec=$?; printf '%s' "$_ec"; }

PROJ="$BAKIT_WORKSPACE/demo"

# Setup project.
sh "$SCRIPTS/init-project.sh" "Demo" >/dev/null 2>&1

# 1. Task creation fails without an existing project.
[ "$(run "$SCRIPTS/init-task.sh" "nope" "x")" != "0" ] && ok "task in missing project fails" || no "task in missing project fails"

# 2. First task -> 001-<slug> with the three subfolders.
[ "$(run "$SCRIPTS/init-task.sh" "Demo" "Elicit Requirements")" = "0" ] && ok "creates first task" || no "creates first task"
[ -d "$PROJ/tasks/001-elicit-requirements/inputs" ] && ok "inputs/ created" || no "inputs/ created"
[ -d "$PROJ/tasks/001-elicit-requirements/artifacts" ] && ok "artifacts/ created" || no "artifacts/ created"
[ -d "$PROJ/tasks/001-elicit-requirements/deliverables" ] && ok "deliverables/ created" || no "deliverables/ created"

# 3. Second task -> sequential 002.
sh "$SCRIPTS/init-task.sh" "Demo" "Write Stories" >/dev/null 2>&1
[ -d "$PROJ/tasks/002-write-stories" ] && ok "second task numbered 002" || no "second task numbered 002"

# 4. Active pointer updated to most recent task.
grep -q '^task=002-write-stories$' "$BAKIT_WORKSPACE/.bakit-active" \
  && ok "active pointer updated" || no "active pointer updated"

# 5. Duplicate task name yields a new sequence (no overwrite, no error).
[ "$(run "$SCRIPTS/init-task.sh" "Demo" "Elicit Requirements")" = "0" ] && ok "duplicate name -> new seq" || no "duplicate name -> new seq"
[ -d "$PROJ/tasks/003-elicit-requirements" ] && ok "duplicate gets 003" || no "duplicate gets 003"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
