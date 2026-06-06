#!/bin/sh
# Tests for install.sh: clean run makes scripts executable and maps skills.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BAKIT_HOME=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t bakit)
trap 'rm -rf "$TMP"' EXIT

pass=0; fail=0
ok() { pass=$((pass+1)); printf 'ok   - %s\n' "$1"; }
no() { fail=$((fail+1)); printf 'FAIL - %s\n' "$1"; }

# Simulate a fresh checkout by copying the framework into a temp dir.
CLONE="$TMP/bakit"
mkdir -p "$CLONE"
cp -R "$BAKIT_HOME/." "$CLONE/"
# Strip executable bits to verify install restores them.
chmod -R -x+X "$CLONE/scripts/sh" 2>/dev/null || true
find "$CLONE/scripts/sh" -name '*.sh' -exec chmod 644 {} + 2>/dev/null || true

# Run installer with an explicit destination, from a working dir.
WORKDIR="$TMP/work"
mkdir -p "$WORKDIR"
DEST="$WORKDIR/.github/prompts"
( cd "$WORKDIR" && sh "$CLONE/install.sh" --dest "$DEST" >/dev/null 2>&1 ) \
  && ok "installer runs cleanly on a fresh checkout" || no "installer runs cleanly on a fresh checkout"

# Scripts are now executable.
[ -x "$CLONE/scripts/sh/init-project.sh" ] && ok "scripts made executable" || no "scripts made executable"

# All four skills mapped into the destination.
mapped=1
for s in ba.specify-requirements ba.analyze-docs ba.write-stories ba.render-confluence; do
  [ -f "$DEST/$s.md" ] || mapped=0
done
[ "$mapped" -eq 1 ] && ok "all skills mapped to destination" || no "all skills mapped to destination"

# Helper templates/internal files are NOT mapped (only ba.* skills).
[ ! -f "$DEST/_skill-template.md" ] && ok "internal templates not mapped" || no "internal templates not mapped"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
