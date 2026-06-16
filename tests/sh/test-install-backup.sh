#!/bin/sh
# Tests for install.sh upgrade/backup/preview behavior (feature 009).
# Covers the flat-file scenarios of contracts/parity-and-tests.md
# (T-1..T-4, T-6..T-15). The Antigravity bundle case (T-5) lives in
# test-install-antigravity.sh. Mirrored by tests/ps/test-install-backup.ps1.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BAKIT_HOME=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t bakit)
trap 'rm -rf "$TMP"' EXIT

pass=0; fail=0
ok() { pass=$((pass+1)); printf 'ok   - %s\n' "$1"; }
no() { fail=$((fail+1)); printf 'FAIL - %s\n' "$1"; }

# Work against a copy of the framework so the repo is never mutated.
CLONE="$TMP/bakit"
mkdir -p "$CLONE"
cp -R "$BAKIT_HOME/." "$CLONE/"
INSTALL="$CLONE/install.sh"

# Run the installer in <workdir> against its .github/prompts, capturing combined
# output and exit code without tripping `set -e`. Honors $TS for BAKIT_BACKUP_TS.
OUT=""; RC=0; TS=""
run() { # workdir [extra args...]
  _w="$1"; shift
  set +e
  OUT=$( cd "$_w" && BAKIT_BACKUP_TS="$TS" sh "$INSTALL" --dest "$_w/.github/prompts" "$@" 2>&1 ); RC=$?
  set -e
}

# --- T-4: fresh install -> all added, no backup folder ---------------------
W="$TMP/t4"; mkdir -p "$W"
TS=""; run "$W"
if [ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -q 'added: ba.next' && [ ! -d "$W/.bakit-backup" ]; then
  ok "T-4: fresh install reports added, no backup folder"
else no "T-4: fresh install reports added, no backup folder"; fi

# --- T-1: tuned flat-file backed up (old content) before overwrite ---------
W="$TMP/t1"; mkdir -p "$W/.github/prompts"
cp "$CLONE/skills/ba.next.md" "$W/.github/prompts/ba.next.prompt.md"
printf 'LOCAL-TUNING\n' >> "$W/.github/prompts/ba.next.prompt.md"
TS="20200101T000000Z"; run "$W"
BK="$W/.bakit-backup/20200101T000000Z/.github/prompts/ba.next.prompt.md"
if [ -f "$BK" ] && grep -q 'LOCAL-TUNING' "$BK" \
   && ! grep -q 'LOCAL-TUNING' "$W/.github/prompts/ba.next.prompt.md"; then
  ok "T-1: tuned file backed up before overwrite; new content live"
else no "T-1: tuned file backed up before overwrite; new content live"; fi

# --- T-2: identical file is unchanged, no backup ---------------------------
W="$TMP/t2"; mkdir -p "$W/.github/prompts"
cp "$CLONE/skills/ba.next.md" "$W/.github/prompts/ba.next.prompt.md"
TS=""; run "$W"
if printf '%s' "$OUT" | grep -q 'unchanged: ba.next' && [ ! -d "$W/.bakit-backup" ]; then
  ok "T-2: identical file classified unchanged, no backup"
else no "T-2: identical file classified unchanged, no backup"; fi

# --- T-3 / T-6: idempotent re-run -> unchanged, no backup folder -----------
W="$TMP/t3"; mkdir -p "$W"
TS=""; run "$W"            # first: all added
TS=""; run "$W"            # second: all unchanged
if [ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -q 'unchanged: ba.next' \
   && ! printf '%s' "$OUT" | grep -q 'backed-up:' && [ ! -d "$W/.bakit-backup" ]; then
  ok "T-3/T-6: clean re-run is all unchanged, no backup folder"
else no "T-3/T-6: clean re-run is all unchanged, no backup folder"; fi

# --- T-7: stale flat-file surfaced, not deleted ----------------------------
W="$TMP/t7"; mkdir -p "$W/.github/prompts"
printf 'orphan\n' > "$W/.github/prompts/ba.ghost.prompt.md"
TS=""; run "$W"
if printf '%s' "$OUT" | grep -q 'stale: ba.ghost' \
   && [ -f "$W/.github/prompts/ba.ghost.prompt.md" ]; then
  ok "T-7: stale command reported and left on disk"
else no "T-7: stale command reported and left on disk"; fi

# --- T-8: preview reports 'safe' when nothing is tuned ---------------------
W="$TMP/t8"; mkdir -p "$W"
TS=""; run "$W"                       # install cleanly
TS=""; run "$W" --check              # preview only
if printf '%s' "$OUT" | grep -q 'Safe to upgrade'; then
  ok "T-8: preview reports safe to upgrade"
else no "T-8: preview reports safe to upgrade"; fi

# --- T-9: preview lists exactly the modified file(s) -----------------------
W="$TMP/t9"; mkdir -p "$W/.github/prompts"
cp "$CLONE/skills/ba.next.md" "$W/.github/prompts/ba.next.prompt.md"
printf 'LOCAL\n' >> "$W/.github/prompts/ba.next.prompt.md"
TS=""; run "$W" --check
if printf '%s' "$OUT" | grep -q 'Local modifications detected' \
   && printf '%s' "$OUT" | grep -q '\- .github/prompts/ba.next.prompt.md'; then
  ok "T-9: preview lists the modified file"
else no "T-9: preview lists the modified file"; fi

# --- T-10: --check makes no changes ----------------------------------------
W="$TMP/t10"; mkdir -p "$W/.github/prompts"
cp "$CLONE/skills/ba.next.md" "$W/.github/prompts/ba.next.prompt.md"
printf 'LOCAL\n' >> "$W/.github/prompts/ba.next.prompt.md"
TS=""; run "$W" --check
if grep -q 'LOCAL' "$W/.github/prompts/ba.next.prompt.md" \
   && [ ! -d "$W/.bakit-backup" ] && [ ! -f "$W/.gitignore" ] \
   && [ ! -f "$W/.github/prompts/ba.specify.prompt.md" ]; then
  ok "T-10: --check writes nothing (no overwrite, backup, gitignore, or new files)"
else no "T-10: --check writes nothing (no overwrite, backup, gitignore, or new files)"; fi

# --- T-11: .gitignore enforced once, idempotent on repeat ------------------
W="$TMP/t11"; mkdir -p "$W/.github/prompts"
printf 'node_modules/\n' > "$W/.gitignore"
cp "$CLONE/skills/ba.next.md" "$W/.github/prompts/ba.next.prompt.md"
printf 'LOCAL1\n' >> "$W/.github/prompts/ba.next.prompt.md"
TS="20200102T000000Z"; run "$W"                       # backs up -> appends ignore
# Re-tune so the next run backs up again (would re-touch .gitignore).
printf 'LOCAL2\n' >> "$W/.github/prompts/ba.next.prompt.md"
TS="20200103T000000Z"; run "$W"
gi_count=$(grep -c '^\.bakit-backup/$' "$W/.gitignore" 2>/dev/null || printf 0)
if [ "$gi_count" -eq 1 ] && grep -q '^node_modules/$' "$W/.gitignore"; then
  ok "T-11: .gitignore contains .bakit-backup/ exactly once (idempotent)"
else no "T-11: .gitignore contains .bakit-backup/ exactly once (idempotent)"; fi

# --- T-12: user work under workspace/ is untouched -------------------------
W="$TMP/t12"; mkdir -p "$W/workspace/demo/tasks/001/artifacts"
ART="$W/workspace/demo/tasks/001/artifacts/requirements.md"
printf 'my analysis\nline2\n' > "$ART"
cp "$ART" "$TMP/t12-ref"
TS=""; run "$W"
if cmp -s "$ART" "$TMP/t12-ref"; then
  ok "T-12: user workspace content left byte-identical"
else no "T-12: user workspace content left byte-identical"; fi

# --- T-13: fail-safe when the backup location is unwritable -----------------
W="$TMP/t13"; mkdir -p "$W/.github/prompts"
cp "$CLONE/skills/ba.next.md" "$W/.github/prompts/ba.next.prompt.md"
printf 'KEEPME\n' >> "$W/.github/prompts/ba.next.prompt.md"
# A regular file where the backup root must be a directory blocks mkdir.
printf 'block\n' > "$W/.bakit-backup"
TS=""; run "$W"
if [ "$RC" -ne 0 ] && grep -q 'KEEPME' "$W/.github/prompts/ba.next.prompt.md"; then
  ok "T-13: aborts without overwriting the tuned file"
else no "T-13: aborts without overwriting the tuned file"; fi

# --- T-14: collision suffix -> second run gets -2, neither overwritten ------
W="$TMP/t14"; mkdir -p "$W/.github/prompts"
cp "$CLONE/skills/ba.next.md" "$W/.github/prompts/ba.next.prompt.md"
printf 'RUN1\n' >> "$W/.github/prompts/ba.next.prompt.md"
TS="20200104T000000Z"; run "$W"
printf 'RUN2\n' >> "$W/.github/prompts/ba.next.prompt.md"
TS="20200104T000000Z"; run "$W"
B1="$W/.bakit-backup/20200104T000000Z/.github/prompts/ba.next.prompt.md"
B2="$W/.bakit-backup/20200104T000000Z-2/.github/prompts/ba.next.prompt.md"
if [ -f "$B1" ] && [ -f "$B2" ] && grep -q 'RUN1' "$B1" && grep -q 'RUN2' "$B2"; then
  ok "T-14: same-timestamp re-run uses -2 suffix, neither overwritten"
else no "T-14: same-timestamp re-run uses -2 suffix, neither overwritten"; fi

# --- T-15: change report completeness --------------------------------------
W="$TMP/t15"; mkdir -p "$W/.github/prompts"
cp "$CLONE/skills/ba.next.md"    "$W/.github/prompts/ba.next.prompt.md"      # unchanged
cp "$CLONE/skills/ba.specify.md" "$W/.github/prompts/ba.specify.prompt.md"
printf 'TUNED\n' >> "$W/.github/prompts/ba.specify.prompt.md"               # backed-up
printf 'orphan\n' > "$W/.github/prompts/ba.ghost.prompt.md"                 # stale
TS="20200105T000000Z"; run "$W"
if printf '%s' "$OUT" | grep -q 'unchanged: ba.next' \
   && printf '%s' "$OUT" | grep -q 'backed-up: ba.specify' \
   && printf '%s' "$OUT" | grep -q 'stale: ba.ghost' \
   && printf '%s' "$OUT" | grep -q 'added: ba.analyze-docs' \
   && printf '%s' "$OUT" | grep -q 'Backed up 1 file'; then
  ok "T-15: report covers added/unchanged/backed-up/stale + backup location"
else no "T-15: report covers added/unchanged/backed-up/stale + backup location"; fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
