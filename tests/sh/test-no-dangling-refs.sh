#!/bin/sh
# Guard: shipped content must NOT reference internal-only paths that don't exist
# in the public repo (specs/00*, .specify/). Locks in the self-contained
# constitution; CHANGELOG is excluded because it documents the historical fix.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
cd "$ROOT"

pass=0; fail=0
ok() { pass=$((pass+1)); printf 'ok   - %s\n' "$1"; }
no() { fail=$((fail+1)); printf 'FAIL - %s\n' "$1"; }

# Directories/files that ship to users (everything except CHANGELOG and tests).
SCAN='skills memory templates docs examples README.md CONTRIBUTING.md'

hits=$(grep -rnE 'specs/0[0-9]|\.specify/' $SCAN 2>/dev/null || true)

if [ -z "$hits" ]; then
  ok "no dangling specs/ or .specify/ references in shipped content"
else
  printf '%s\n' "$hits"
  no "found dangling internal references in shipped content"
fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
