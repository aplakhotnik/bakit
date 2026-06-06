#!/bin/sh
# Run all BA-Kit shell tests. Exits non-zero if any suite fails.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

total_fail=0
for t in "$SCRIPT_DIR"/test-*.sh; do
  [ -e "$t" ] || continue
  printf '\n=== %s ===\n' "$(basename "$t")"
  if sh "$t"; then :; else total_fail=$((total_fail+1)); fi
done

printf '\n'
if [ "$total_fail" -eq 0 ]; then
  printf 'ALL SUITES PASSED\n'
else
  printf '%d SUITE(S) FAILED\n' "$total_fail"
fi
[ "$total_fail" -eq 0 ]
