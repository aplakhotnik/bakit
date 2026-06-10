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

# 2. With docs-analysis present -> next is specify.
mkart "$TASK/artifacts/docs-analysis.md" docs-analysis draft "sources: [inputs/a.txt]"
nextout | grep -q 'ba.specify' && ok "docs-analysis done -> specify" || no "docs-analysis done -> specify"

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

# --- Discovery workflow via --workflow workflow-discovery.md (additive) ---

# Drive a fresh task through the separate Discovery manifest.
sh "$SCRIPTS/init-task.sh" "Demo" "Discovery Run" >/dev/null 2>&1
TASK3="$BAKIT_WORKSPACE/demo/tasks/003-discovery-run"
dnext() { sh "$SCRIPTS/next-step.sh" --workflow workflow-discovery.md "$@" 2>/dev/null; }

# D1. Fresh task on the discovery manifest -> first state is ba.discover.initiate.
dnext "Demo" "003-discovery-run" | grep -q 'ba.discover.initiate' \
  && ok "discovery: fresh task -> initiate" || no "discovery: fresh task -> initiate"

# D2. Default manifest is unaffected for the same fresh task (still analyze-docs).
nextout "Demo" "003-discovery-run" | grep -q 'ba.analyze-docs' \
  && ok "discovery: default manifest still analyze-docs (no regression)" || no "discovery: default manifest still analyze-docs (no regression)"

# D3. Draft charter present -> gap-analysis gate not met.
mkart "$TASK3/artifacts/project-charter.md" project-charter draft
out3=$(dnext "Demo" "003-discovery-run")
printf '%s' "$out3" | grep -qi 'gate not met' && ok "discovery: draft charter -> gate not met" || no "discovery: draft charter -> gate not met"
printf '%s' "$out3" | grep -q 'ba.discover.gap-analysis' && ok "discovery: gate names gap-analysis" || no "discovery: gate names gap-analysis"

# D4. Approve charter -> next is gap-analysis.
mkart "$TASK3/artifacts/project-charter.md" project-charter approved
dnext "Demo" "003-discovery-run" | grep -q 'Next: ba.discover.gap-analysis' \
  && ok "discovery: approved charter -> gap-analysis" || no "discovery: approved charter -> gap-analysis"

# D5. Add approved gap-analysis -> next is backlog.
mkart "$TASK3/artifacts/gap-analysis.md" gap-analysis approved "derived_from: [test-project-charter]"
dnext "Demo" "003-discovery-run" | grep -q 'Next: ba.discover.backlog' \
  && ok "discovery: approved gap-analysis -> backlog" || no "discovery: approved gap-analysis -> backlog"

# D6. Add approved backlog -> next is estimate.
mkart "$TASK3/artifacts/product-backlog.md" product-backlog approved "derived_from: [test-gap-analysis]"
dnext "Demo" "003-discovery-run" | grep -q 'Next: ba.discover.estimate' \
  && ok "discovery: approved backlog -> estimate" || no "discovery: approved backlog -> estimate"

# D7. Add estimated-backlog -> all discovery states produced output.
mkart "$TASK3/artifacts/estimated-backlog.md" estimated-backlog draft "derived_from: [test-product-backlog]"
dnext "Demo" "003-discovery-run" | grep -qi 'produced output' \
  && ok "discovery: all states done -> complete" || no "discovery: all states done -> complete"

# --- 007: advisory blocking-gap warning before a dependent step ---

# B1. Approved requirements with a blocking open question -> warn AND still suggest write-stories.
sh "$SCRIPTS/init-task.sh" "Demo" "Gap Aware" >/dev/null 2>&1
TASK4="$BAKIT_WORKSPACE/demo/tasks/004-gap-aware"
mkart "$TASK4/artifacts/requirements.md" requirements approved "open_questions: 1
blocking_questions: 1"
out4=$(nextout "Demo" "004-gap-aware")
printf '%s' "$out4" | grep -q 'Next: ba.write-stories' \
  && ok "blocking-gap: still suggests write-stories" || no "blocking-gap: still suggests write-stories"
printf '%s' "$out4" | grep -qi 'blocking' \
  && ok "blocking-gap: advisory warning shown" || no "blocking-gap: advisory warning shown"
# Exit code stays 0 (advisory, never a hard block).
_ec=0; sh "$SCRIPTS/next-step.sh" "Demo" "004-gap-aware" >/dev/null 2>&1 || _ec=$?
[ "$_ec" = "0" ] && ok "blocking-gap: exit 0 (advisory)" || no "blocking-gap: exit 0 (advisory)"

# B2. Approved requirements with NO blocking questions -> no warning (unchanged behavior).
mkart "$TASK4/artifacts/requirements.md" requirements approved "open_questions: 1
blocking_questions: 0"
out5=$(nextout "Demo" "004-gap-aware")
printf '%s' "$out5" | grep -q 'Next: ba.write-stories' \
  && ok "no-blocking: suggests write-stories" || no "no-blocking: suggests write-stories"
printf '%s' "$out5" | grep -qi 'blocking' \
  && no "no-blocking: should NOT warn about blocking" || ok "no-blocking: no blocking warning"

# B3. Draft requirements with a blocking question -> existing approval gate still shown first.
mkart "$TASK4/artifacts/requirements.md" requirements draft "open_questions: 1
blocking_questions: 1"
out6=$(nextout "Demo" "004-gap-aware")
printf '%s' "$out6" | grep -qi 'gate not met' \
  && ok "draft+blocking: approval gate shown (unchanged)" || no "draft+blocking: approval gate shown (unchanged)"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
