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

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
