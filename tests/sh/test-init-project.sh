#!/bin/sh
# Tests for init-project.sh: creation, structure, collision safety.
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

# 1. Create a project.
[ "$(run "$SCRIPTS/init-project.sh" "Payments Revamp")" = "0" ] && ok "creates project" || no "creates project"

# 2. project.md + tasks/ exist, with valid front-matter.
[ -f "$BAKIT_WORKSPACE/payments-revamp/project.md" ] && ok "project.md exists" || no "project.md exists"
[ -d "$BAKIT_WORKSPACE/payments-revamp/tasks" ] && ok "tasks/ exists" || no "tasks/ exists"
[ "$(run "$SCRIPTS/check-artifact.sh" "$BAKIT_WORKSPACE/payments-revamp/project.md")" = "0" ] \
  && ok "project.md has valid front-matter" || no "project.md has valid front-matter"

# 3. Slugification (name normalized to payments-revamp).
[ -d "$BAKIT_WORKSPACE/payments-revamp" ] && ok "name slugified" || no "name slugified"

# 3b. Shared project-level knowledge base seeded with a valid index.
[ -d "$BAKIT_WORKSPACE/payments-revamp/kb" ] && ok "project kb/ exists" || no "project kb/ exists"
[ -f "$BAKIT_WORKSPACE/payments-revamp/kb/index.md" ] && ok "project kb/index.md exists" || no "project kb/index.md exists"
grep -q '^## Summary' "$BAKIT_WORKSPACE/payments-revamp/kb/index.md" \
  && ok "project kb index has Summary" || no "project kb index has Summary"
grep -q '^## Entries' "$BAKIT_WORKSPACE/payments-revamp/kb/index.md" \
  && ok "project kb index has Entries" || no "project kb index has Entries"

# 4. Collision: second create with same name fails and does not overwrite.
cp "$BAKIT_WORKSPACE/payments-revamp/project.md" "$TMP/before.md"
[ "$(run "$SCRIPTS/init-project.sh" "Payments Revamp")" != "0" ] && ok "collision refused" || no "collision refused"
cmp -s "$TMP/before.md" "$BAKIT_WORKSPACE/payments-revamp/project.md" \
  && ok "existing project untouched" || no "existing project untouched"

# 5. Empty/invalid name fails.
[ "$(run "$SCRIPTS/init-project.sh" "")" != "0" ] && ok "empty name rejected" || no "empty name rejected"

# 6. Default mode is independent (kb_mode recorded; no brain registers).
grep -q '^kb_mode: independent' "$BAKIT_WORKSPACE/payments-revamp/project.md" \
  && ok "default mode is independent" || no "default mode is independent"
[ ! -f "$BAKIT_WORKSPACE/payments-revamp/kb/changelog.md" ] \
  && ok "independent has no brain registers" || no "independent has no brain registers"

# 7. Brain mode scaffolds registers + records kb_mode: brain.
[ "$(run "$SCRIPTS/init-project.sh" "RFP Pursuit" --mode brain)" = "0" ] && ok "creates brain project" || no "creates brain project"
grep -q '^kb_mode: brain' "$BAKIT_WORKSPACE/rfp-pursuit/project.md" \
  && ok "brain mode recorded" || no "brain mode recorded"
_bm_ok=1
for f in changelog requirements-register open-questions decisions glossary; do
  [ -f "$BAKIT_WORKSPACE/rfp-pursuit/kb/$f.md" ] || _bm_ok=0
done
[ "$_bm_ok" = "1" ] && ok "brain registers scaffolded" || no "brain registers scaffolded"

# 8. Invalid mode is rejected.
[ "$(run "$SCRIPTS/init-project.sh" "Bad Mode" --mode nonsense)" != "0" ] && ok "invalid mode rejected" || no "invalid mode rejected"

# 9. Upgrade an independent project to brain (idempotent, non-destructive).
cp "$BAKIT_WORKSPACE/payments-revamp/kb/index.md" "$TMP/index-before.md"
[ "$(run "$SCRIPTS/init-project.sh" "Payments Revamp" --upgrade-to-brain)" = "0" ] && ok "upgrade succeeds" || no "upgrade succeeds"
grep -q '^kb_mode: brain' "$BAKIT_WORKSPACE/payments-revamp/project.md" \
  && ok "upgrade sets kb_mode brain" || no "upgrade sets kb_mode brain"
[ -f "$BAKIT_WORKSPACE/payments-revamp/kb/changelog.md" ] \
  && ok "upgrade scaffolds registers" || no "upgrade scaffolds registers"
cmp -s "$TMP/index-before.md" "$BAKIT_WORKSPACE/payments-revamp/kb/index.md" \
  && ok "upgrade preserves existing kb/index.md" || no "upgrade preserves existing kb/index.md"
[ "$(run "$SCRIPTS/init-project.sh" "Payments Revamp" --upgrade-to-brain)" = "0" ] \
  && ok "upgrade is idempotent" || no "upgrade is idempotent"

# 10. Upgrade a non-existent project fails.
[ "$(run "$SCRIPTS/init-project.sh" "Ghost Project" --upgrade-to-brain)" != "0" ] \
  && ok "upgrade of missing project fails" || no "upgrade of missing project fails"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
