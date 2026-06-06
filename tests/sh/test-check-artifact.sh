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

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
