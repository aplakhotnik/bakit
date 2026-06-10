#!/bin/sh
# Tests for install.sh Antigravity target (skill-folder layout).
# Asserts the contract in specs/006-installation-experience/contracts/antigravity-skill.md.
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

# Body of a markdown skill = everything after its YAML front-matter.
skill_body() { awk 'c>=2{print} /^---[[:space:]]*$/{c++}' "$1"; }

# --- workspace scope (default) ---------------------------------------------
WS="$TMP/ws"
mkdir -p "$WS"
( cd "$WS" && sh "$INSTALL" --agent antigravity >/dev/null 2>&1 ) \
  && ok "antigravity installer runs cleanly (workspace)" || no "antigravity installer runs cleanly (workspace)"

SKILLS="$WS/.agents/skills"
[ -d "$SKILLS" ] && ok "workspace: .agents/skills/ created" || no "workspace: .agents/skills/ created"

# Every source skill has a folder with a SKILL.md.
allfolders=1
for src in "$CLONE"/skills/ba.*.md; do
  name=$(basename "$src" .md)
  [ -f "$SKILLS/$name/SKILL.md" ] || allfolders=0
done
[ "$allfolders" -eq 1 ] && ok "workspace: every skill -> ba.<name>/SKILL.md" || no "workspace: every skill -> ba.<name>/SKILL.md"

# SKILL.md front-matter: name matches folder, description present and non-empty.
SKM="$SKILLS/ba.next/SKILL.md"
grep -q '^name: ba.next$' "$SKM" && ok "SKILL.md name matches folder" || no "SKILL.md name matches folder"
desc=$(sed -n 's/^description:[[:space:]]*//p' "$SKM" | head -1 | sed 's/^"//; s/"$//')
[ -n "$desc" ] && ok "SKILL.md description is non-empty" || no "SKILL.md description is non-empty"

# Body is byte-identical to the source skill body.
skill_body "$CLONE/skills/ba.next.md" > "$TMP/body-src"
skill_body "$SKM" > "$TMP/body-out"
diff "$TMP/body-src" "$TMP/body-out" >/dev/null 2>&1 \
  && ok "SKILL.md body byte-identical to source" || no "SKILL.md body byte-identical to source"

# Minimal bundling: ba.next references only an sh script -> scripts/sh + common,
# but NO scripts/ps and NO resources/.
[ -f "$SKILLS/ba.next/scripts/sh/next-step.sh" ] && ok "ba.next: bundles scripts/sh/next-step.sh" || no "ba.next: bundles scripts/sh/next-step.sh"
[ -f "$SKILLS/ba.next/scripts/sh/common.sh" ]    && ok "ba.next: bundles scripts/sh/common.sh"  || no "ba.next: bundles scripts/sh/common.sh"
[ ! -d "$SKILLS/ba.next/scripts/ps" ]  && ok "ba.next: no scripts/ps (none referenced)" || no "ba.next: no scripts/ps (none referenced)"
[ ! -d "$SKILLS/ba.next/resources" ]   && ok "ba.next: no resources (no templates referenced)" || no "ba.next: no resources (no templates referenced)"

# Bundled scripts are verbatim copies of the repository sources.
diff "$CLONE/scripts/sh/next-step.sh" "$SKILLS/ba.next/scripts/sh/next-step.sh" >/dev/null 2>&1 \
  && ok "bundled next-step.sh is verbatim" || no "bundled next-step.sh is verbatim"
diff "$CLONE/scripts/sh/common.sh" "$SKILLS/ba.next/scripts/sh/common.sh" >/dev/null 2>&1 \
  && ok "bundled common.sh is verbatim" || no "bundled common.sh is verbatim"

# Template bundling: a template-using skill places the template verbatim under
# resources/, preserving its sub-path.
TPL="$SKILLS/ba.start-project/resources/templates/project/project.md"
[ -f "$TPL" ] && ok "ba.start-project: bundles template under resources/" || no "ba.start-project: bundles template under resources/"
diff "$CLONE/templates/project/project.md" "$TPL" >/dev/null 2>&1 \
  && ok "bundled template is verbatim" || no "bundled template is verbatim"

# No flat-file regression: an Antigravity install must NOT create copilot output.
[ ! -d "$WS/.github" ] && ok "no flat-file regression (.github not created)" || no "no flat-file regression (.github not created)"

# Idempotency: a stale bundled file is removed on re-run; folder reflects source.
mkdir -p "$SKILLS/ba.next/scripts/ps"
printf 'stale\n' > "$SKILLS/ba.next/scripts/ps/zombie.ps1"
( cd "$WS" && sh "$INSTALL" --agent antigravity >/dev/null 2>&1 )
[ ! -f "$SKILLS/ba.next/scripts/ps/zombie.ps1" ] && ok "idempotent: stale bundled file removed on re-run" || no "idempotent: stale bundled file removed on re-run"
[ -f "$SKILLS/ba.next/SKILL.md" ] && ok "idempotent: SKILL.md still present after re-run" || no "idempotent: SKILL.md still present after re-run"

# --- global scope ----------------------------------------------------------
GH="$TMP/home"
mkdir -p "$GH"
GWORK="$TMP/gwork"
mkdir -p "$GWORK"
( cd "$GWORK" && HOME="$GH" sh "$INSTALL" --agent antigravity --scope global >/dev/null 2>&1 ) \
  && ok "antigravity installer runs cleanly (global)" || no "antigravity installer runs cleanly (global)"
[ -f "$GH/.gemini/config/skills/ba.next/SKILL.md" ] && ok "global: installs under ~/.gemini/config/skills" || no "global: installs under ~/.gemini/config/skills"
[ ! -d "$GWORK/.agents" ] && ok "global: does not create workspace .agents/" || no "global: does not create workspace .agents/"

# --- auto-detection precedence (Antigravity is lowest) ---------------------
# Lone .agents/ marker, non-interactive -> antigravity.
LONE="$TMP/lone-agents"
mkdir -p "$LONE/.agents"
( cd "$LONE" && sh "$INSTALL" </dev/null >/dev/null 2>&1 )
[ -f "$LONE/.agents/skills/ba.next/SKILL.md" ] && ok "auto-detect: lone .agents/ -> antigravity" || no "auto-detect: lone .agents/ -> antigravity"

# .github/ + .agents/ -> copilot wins; no Antigravity output produced.
MIX="$TMP/mix"
mkdir -p "$MIX/.github" "$MIX/.agents"
( cd "$MIX" && sh "$INSTALL" </dev/null >/dev/null 2>&1 )
[ -f "$MIX/.github/prompts/ba.next.prompt.md" ] && ok "precedence: copilot wins over antigravity" || no "precedence: copilot wins over antigravity"
[ ! -d "$MIX/.agents/skills" ] && ok "precedence: antigravity not installed when copilot present" || no "precedence: antigravity not installed when copilot present"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
