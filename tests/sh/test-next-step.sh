#!/bin/sh
# Tests for next-step.sh: resolves the correct next workflow skill and gate.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPTS="$SCRIPT_DIR/../../scripts/sh"

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t bakit)
trap 'rm -rf "$TMP"' EXIT
export BAKIT_WORKSPACE="$TMP/workspace"

pass=0; fail=0
ok() { pass=$((pass+1)); printf 'ok   - %s\n' "$1"; }
no() { fail=$((fail+1)); printf 'FAIL - %s\n' "$1"; }

# Run next-step.sh and capture stdout.
nextout() { sh "$SCRIPTS/next-step.sh" "$@" 2>/dev/null; }

# Write a minimal valid artifact of a given type/status.
mkart() {
  _path="$1"; _type="$2"; _status="$3"; _extra="${4:-}"
  mkdir -p "$(dirname "$_path")"
  {
    printf '%s\n' "---"
    printf 'id: %s\n' "test-$_type"
    printf 'type: %s\n' "$_type"
    printf 'title: "Test %s"\n' "$_type"
    printf 'status: %s\n' "$_status"
    printf 'created: 2025-01-01\n'
    printf 'updated: 2025-01-01\n'
    [ -n "$_extra" ] && printf '%s\n' "$_extra"
    printf '%s\n' "---"
    printf '\n# Test %s\n' "$_type"
  } > "$_path"
}

# Setup: project + task.
sh "$SCRIPTS/init-project.sh" "Demo" >/dev/null 2>&1
sh "$SCRIPTS/init-task.sh" "Demo" "Build" >/dev/null 2>&1
TASK="$BAKIT_WORKSPACE/demo/tasks/001-build"

# 1. Fresh task -> first step is ba.analyze-docs.
nextout | grep -q 'ba.analyze-docs' && ok "fresh task -> analyze-docs" || no "fresh task -> analyze-docs"

# 2. With docs-analysis present -> next is specify-requirements.
mkart "$TASK/artifacts/docs-analysis.md" docs-analysis draft "sources: [inputs/a.txt]"
nextout | grep -q 'ba.specify-requirements' && ok "docs-analysis done -> specify-requirements" || no "docs-analysis done -> specify-requirements"

# 3. With requirements present but draft -> write-stories gate not met.
mkart "$TASK/artifacts/requirements.md" requirements draft
out=$(nextout)
printf '%s' "$out" | grep -qi 'gate not met' && ok "draft requirements -> gate not met" || no "draft requirements -> gate not met"
printf '%s' "$out" | grep -q 'ba.write-stories' && ok "gate message names write-stories" || no "gate message names write-stories"

# 4. Approve requirements -> next is write-stories.
mkart "$TASK/artifacts/requirements.md" requirements approved
nextout | grep -q 'Next: ba.write-stories' && ok "approved requirements -> write-stories" || no "approved requirements -> write-stories"

# 5. Add user-stories -> next is render-confluence.
mkart "$TASK/artifacts/user-stories.md" user-stories draft "derived_from: [test-requirements]"
nextout | grep -q 'ba.render-confluence' && ok "user-stories done -> render-confluence" || no "user-stories done -> render-confluence"

# 6. Add a deliverable -> workflow complete.
mkart "$TASK/deliverables/out-confluence.md" confluence-page draft "derived_from: [test-requirements]"
nextout | grep -qi 'produced output' && ok "all steps done -> complete" || no "all steps done -> complete"

# 7. Skip path: a second task with requirements but NO docs-analysis.
sh "$SCRIPTS/init-task.sh" "Demo" "Skip Analyze" >/dev/null 2>&1
TASK2="$BAKIT_WORKSPACE/demo/tasks/002-skip-analyze"
mkart "$TASK2/artifacts/requirements.md" requirements draft
out2=$(nextout "Demo" "002-skip-analyze")
printf '%s' "$out2" | grep -qi 'gate not met' \
  && ok "skip analyze: draft requirements -> gate not met" || no "skip analyze: draft requirements -> gate not met"
printf '%s' "$out2" | grep -q 'ba.analyze-docs' \
  && no "skip analyze: should NOT fall back to analyze-docs" || ok "skip analyze: advances past skipped analyze-docs"

# 8. Approve those requirements -> next is write-stories.
mkart "$TASK2/artifacts/requirements.md" requirements approved
nextout "Demo" "002-skip-analyze" | grep -q 'Next: ba.write-stories' \
  && ok "skip analyze: approved -> write-stories" || no "skip analyze: approved -> write-stories"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
