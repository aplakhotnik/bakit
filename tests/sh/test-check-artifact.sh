#!/bin/sh
# Tests for check-artifact.sh: front-matter validation and approval gate.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CHECK="$SCRIPT_DIR/../../scripts/sh/check-artifact.sh"

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t bakit)
trap 'rm -rf "$TMP"' EXIT

pass=0; fail=0
ok()   { pass=$((pass+1)); printf 'ok   - %s\n' "$1"; }
no()   { fail=$((fail+1)); printf 'FAIL - %s\n' "$1"; }

# Helper: run check, capture exit code without aborting (set -e safe).
run_check() { _ec=0; sh "$CHECK" "$@" >/dev/null 2>&1 || _ec=$?; printf '%s' "$_ec"; }

# Helper: run check, capture stdout (set -e safe); exit code discarded.
run_check_out() { sh "$CHECK" "$@" 2>/dev/null || true; }

# 1. Valid approved requirements artifact.
cat > "$TMP/req.md" <<'EOF'
---
id: REQ-001
type: requirements
title: Sample
status: approved
created: 2026-06-06
updated: 2026-06-06
---
# Body
EOF
[ "$(run_check "$TMP/req.md")" = "0" ] && ok "valid requirements passes" || no "valid requirements passes"
[ "$(run_check --require-approved "$TMP/req.md")" = "0" ] && ok "approved passes gate" || no "approved passes gate"

# 2. Draft fails the approval gate (exit 2) but passes plain validation.
cat > "$TMP/draft.md" <<'EOF'
---
id: REQ-002
type: requirements
title: Draft
status: draft
created: 2026-06-06
updated: 2026-06-06
---
EOF
[ "$(run_check "$TMP/draft.md")" = "0" ] && ok "draft passes plain validation" || no "draft passes plain validation"
[ "$(run_check --require-approved "$TMP/draft.md")" = "2" ] && ok "draft fails approval gate (exit 2)" || no "draft fails approval gate (exit 2)"

# 3. Missing front-matter fails.
printf '# no front-matter\n' > "$TMP/nofm.md"
[ "$(run_check "$TMP/nofm.md")" = "1" ] && ok "missing front-matter fails" || no "missing front-matter fails"

# 4. Missing required field (status) fails.
cat > "$TMP/missing.md" <<'EOF'
---
id: X-1
type: requirements
title: Missing status
created: 2026-06-06
updated: 2026-06-06
---
EOF
[ "$(run_check "$TMP/missing.md")" = "1" ] && ok "missing required field fails" || no "missing required field fails"

# 5. Invalid status value fails.
cat > "$TMP/badstatus.md" <<'EOF'
---
id: X-2
type: requirements
title: Bad status
status: published
created: 2026-06-06
updated: 2026-06-06
---
EOF
[ "$(run_check "$TMP/badstatus.md")" = "1" ] && ok "invalid status fails" || no "invalid status fails"

# 6. docs-analysis without sources fails (type-conditional requirement).
cat > "$TMP/docs.md" <<'EOF'
---
id: DA-1
type: docs-analysis
title: No sources
status: draft
created: 2026-06-06
updated: 2026-06-06
sources: []
---
EOF
[ "$(run_check "$TMP/docs.md")" = "1" ] && ok "docs-analysis without sources fails" || no "docs-analysis without sources fails"

# 7. Valid elicitation-plan artifact passes (universal fields only, no extra required fields).
cat > "$TMP/elic.md" <<'EOF'
---
id: ELIC-1
type: elicitation-plan
title: Sample elicitation plan
status: draft
created: 2026-06-06
updated: 2026-06-06
round: 1
---
# Body
EOF
[ "$(run_check "$TMP/elic.md")" = "0" ] && ok "valid elicitation-plan passes" || no "valid elicitation-plan passes"

# 8. elicitation-plan missing a universal field (title) fails.
cat > "$TMP/elic-bad.md" <<'EOF'
---
id: ELIC-2
type: elicitation-plan
status: draft
created: 2026-06-06
updated: 2026-06-06
---
EOF
[ "$(run_check "$TMP/elic-bad.md")" = "1" ] && ok "elicitation-plan missing universal field fails" || no "elicitation-plan missing universal field fails"

# --- Discovery workflow artifact types (additive) ---

# 9. discovery-document is valid with universal fields only (no derived_from required).
cat > "$TMP/disc.md" <<'EOF'
---
id: DISC-1
type: discovery-document
title: Living Discovery Document
status: draft
created: 2026-06-07
updated: 2026-06-07
---
# Body
EOF
[ "$(run_check "$TMP/disc.md")" = "0" ] && ok "discovery-document passes (universal only)" || no "discovery-document passes (universal only)"

# 10. project-charter is valid with universal fields only.
cat > "$TMP/charter.md" <<'EOF'
---
id: CHTR-1
type: project-charter
title: Charter
status: draft
created: 2026-06-07
updated: 2026-06-07
---
# Body
EOF
[ "$(run_check "$TMP/charter.md")" = "0" ] && ok "project-charter passes (universal only)" || no "project-charter passes (universal only)"

# 11. gap-analysis without derived_from fails; with it, passes.
cat > "$TMP/gap-bad.md" <<'EOF'
---
id: GAP-1
type: gap-analysis
title: No derived_from
status: draft
created: 2026-06-07
updated: 2026-06-07
derived_from: []
---
EOF
[ "$(run_check "$TMP/gap-bad.md")" = "1" ] && ok "gap-analysis without derived_from fails" || no "gap-analysis without derived_from fails"
cat > "$TMP/gap-ok.md" <<'EOF'
---
id: GAP-2
type: gap-analysis
title: Has derived_from
status: draft
created: 2026-06-07
updated: 2026-06-07
derived_from: [CHTR-1]
---
EOF
[ "$(run_check "$TMP/gap-ok.md")" = "0" ] && ok "gap-analysis with derived_from passes" || no "gap-analysis with derived_from passes"

# 12. product-backlog requires derived_from.
cat > "$TMP/pb-bad.md" <<'EOF'
---
id: PB-1
type: product-backlog
title: No derived_from
status: draft
created: 2026-06-07
updated: 2026-06-07
derived_from: []
---
EOF
[ "$(run_check "$TMP/pb-bad.md")" = "1" ] && ok "product-backlog without derived_from fails" || no "product-backlog without derived_from fails"

# 13. estimated-backlog requires derived_from; with it, passes; gate on draft is exit 2.
cat > "$TMP/eb.md" <<'EOF'
---
id: EB-1
type: estimated-backlog
title: Estimated
status: draft
created: 2026-06-07
updated: 2026-06-07
derived_from: [PB-1]
---
EOF
[ "$(run_check "$TMP/eb.md")" = "0" ] && ok "estimated-backlog with derived_from passes" || no "estimated-backlog with derived_from passes"
[ "$(run_check --require-approved "$TMP/eb.md")" = "2" ] && ok "draft discovery artifact fails approval gate (exit 2)" || no "draft discovery artifact fails approval gate (exit 2)"

# 14. approved discovery artifact passes the approval gate (exit 0).
cat > "$TMP/eb-ok.md" <<'EOF'
---
id: EB-2
type: estimated-backlog
title: Estimated approved
status: approved
created: 2026-06-07
updated: 2026-06-07
derived_from: [PB-1]
---
EOF
[ "$(run_check --require-approved "$TMP/eb-ok.md")" = "0" ] && ok "approved discovery artifact passes gate" || no "approved discovery artifact passes gate"

# --- 007: open/blocking rollup reporting + strict mode (--require-no-blocking) ---

# 15. Counts are reported on success (open_questions / blocking_questions in stdout).
cat > "$TMP/oq.md" <<'EOF'
---
id: REQ-OQ
type: requirements
title: With open questions
status: approved
created: 2026-06-10
updated: 2026-06-10
open_questions: 2
blocking_questions: 1
---
# Body
EOF
out=$(run_check_out "$TMP/oq.md")
printf '%s' "$out" | grep -q '^open_questions: 2$' && ok "reports open_questions count" || no "reports open_questions count"
printf '%s' "$out" | grep -q '^blocking_questions: 1$' && ok "reports blocking_questions count" || no "reports blocking_questions count"
[ "$(run_check "$TMP/oq.md")" = "0" ] && ok "open/blocking advisory by default (exit 0)" || no "open/blocking advisory by default (exit 0)"

# 16. --require-no-blocking exits 3 when blocking questions remain.
[ "$(run_check --require-no-blocking "$TMP/oq.md")" = "3" ] && ok "strict mode exits 3 when blocking remain" || no "strict mode exits 3 when blocking remain"

# 17. --require-no-blocking exits 0 when no blocking questions.
cat > "$TMP/oq0.md" <<'EOF'
---
id: REQ-OQ0
type: requirements
title: No blocking
status: approved
created: 2026-06-10
updated: 2026-06-10
open_questions: 2
blocking_questions: 0
---
# Body
EOF
[ "$(run_check --require-no-blocking "$TMP/oq0.md")" = "0" ] && ok "strict mode exits 0 when no blocking" || no "strict mode exits 0 when no blocking"

# 18. Legacy artifact (no rollup fields) reports 0/0 and exits 0 (backward compatible).
out=$(run_check_out "$TMP/req.md")
printf '%s' "$out" | grep -q '^open_questions: 0$' && ok "legacy artifact reports open_questions: 0" || no "legacy artifact reports open_questions: 0"
printf '%s' "$out" | grep -q '^blocking_questions: 0$' && ok "legacy artifact reports blocking_questions: 0" || no "legacy artifact reports blocking_questions: 0"
[ "$(run_check --require-no-blocking "$TMP/req.md")" = "0" ] && ok "legacy artifact passes strict mode (exit 0)" || no "legacy artifact passes strict mode (exit 0)"

# 19. Approval gate takes precedence over blocking gate: draft + blocking => exit 2.
cat > "$TMP/oq-draft.md" <<'EOF'
---
id: REQ-OQD
type: requirements
title: Draft with blocking
status: draft
created: 2026-06-10
updated: 2026-06-10
open_questions: 1
blocking_questions: 1
---
# Body
EOF
[ "$(run_check --require-approved --require-no-blocking "$TMP/oq-draft.md")" = "2" ] && ok "approval gate precedes blocking gate (exit 2)" || no "approval gate precedes blocking gate (exit 2)"

# 20. Invalid artifact still exits 1 even with strict flag (counts not required).
[ "$(run_check --require-no-blocking "$TMP/nofm.md")" = "1" ] && ok "invalid artifact exits 1 under strict mode" || no "invalid artifact exits 1 under strict mode"

# --- 008: story-map type + single Selected-variant invariant ---

# 21. Valid story-map with exactly one Selected variant passes.
cat > "$TMP/sm-ok.md" <<'EOF'
---
id: SM-1
type: story-map
title: Valid story map
status: draft
created: 2026-06-15
updated: 2026-06-15
derived_from: [REQ-001]
---
# Story Map

### Variant V1: walking skeleton — **Selected variant**
| Slice | Pattern | Covers |
|-------|---------|--------|
| V1-S1 | Workflow/Path | FR-001 |
EOF
[ "$(run_check "$TMP/sm-ok.md")" = "0" ] && ok "story-map with one Selected variant passes" || no "story-map with one Selected variant passes"

# 22. Zero Selected variants fails (exit 1).
cat > "$TMP/sm-none.md" <<'EOF'
---
id: SM-2
type: story-map
title: No selection
status: draft
created: 2026-06-15
updated: 2026-06-15
derived_from: [REQ-001]
---
# Story Map

### Variant V1: walking skeleton
| Slice | Pattern | Covers |
|-------|---------|--------|
| V1-S1 | Workflow/Path | FR-001 |
EOF
[ "$(run_check "$TMP/sm-none.md")" = "1" ] && ok "story-map with zero Selected variants fails" || no "story-map with zero Selected variants fails"

# 23. Two Selected variants fails (exit 1).
cat > "$TMP/sm-two.md" <<'EOF'
---
id: SM-3
type: story-map
title: Double selection
status: draft
created: 2026-06-15
updated: 2026-06-15
derived_from: [REQ-001]
---
# Story Map

### Variant V1: a — **Selected variant**
### Variant V2: b — **Selected variant**
EOF
[ "$(run_check "$TMP/sm-two.md")" = "1" ] && ok "story-map with two Selected variants fails" || no "story-map with two Selected variants fails"

# 24. Missing/empty derived_from fails.
cat > "$TMP/sm-noderive.md" <<'EOF'
---
id: SM-4
type: story-map
title: No derived_from
status: draft
created: 2026-06-15
updated: 2026-06-15
derived_from: []
---
# Story Map

### Variant V1: a — **Selected variant**
EOF
[ "$(run_check "$TMP/sm-noderive.md")" = "1" ] && ok "story-map without derived_from fails" || no "story-map without derived_from fails"

# 25. Absent open/blocking rollups are treated as 0 (exit 0) and reported.
out=$(run_check_out "$TMP/sm-ok.md")
printf '%s' "$out" | grep -q '^open_questions: 0$' && ok "story-map absent rollups report 0" || no "story-map absent rollups report 0"
[ "$(run_check "$TMP/sm-ok.md")" = "0" ] && ok "story-map absent rollups exit 0" || no "story-map absent rollups exit 0"

# 26. Back-compat: existing requirements type still validates (Selected check does not apply).
[ "$(run_check "$TMP/req.md")" = "0" ] && ok "non-story-map unaffected by Selected-variant check" || no "non-story-map unaffected by Selected-variant check"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
