#!/bin/sh
# Verify every relative Markdown link in the repo points to an existing target.
# Guards against the "docs page linked but never created" class of bug.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
cd "$ROOT"

pass=0; fail=0
ok() { pass=$((pass+1)); printf 'ok   - %s\n' "$1"; }
no() { fail=$((fail+1)); printf 'FAIL - %s\n' "$1"; }

checked=0
broken=''

# Scan all markdown except the tests dir (this checker) and the git metadata.
for f in $(find . -name '*.md' -not -path './tests/*' -not -path './.git/*'); do
  dir=$(dirname "$f")
  for raw in $(grep -oE '\]\([^)]+\)' "$f" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//'); do
    link=${raw%%#*}                       # strip any #anchor
    [ -z "$link" ] && continue            # pure-anchor link
    case "$link" in
      http://*|https://*|mailto:*) continue ;;
    esac
    checked=$((checked+1))
    if [ ! -e "$dir/$link" ]; then
      broken="$broken
  $f -> $raw"
    fi
  done
done

if [ -z "$broken" ]; then
  ok "all $checked relative markdown links resolve"
else
  printf 'broken links:%s\n' "$broken"
  no "broken markdown links found"
fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
