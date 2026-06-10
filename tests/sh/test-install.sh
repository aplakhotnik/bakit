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
[ -x "$CLONE/scripts/sh/next-step.sh" ] && ok "next-step.sh made executable" || no "next-step.sh made executable"

# All skills mapped into the destination (existing + new agent-driven ones).
# A .github/prompts destination uses the VS Code '.prompt.md' extension.
mapped=1
for s in ba.specify ba.analyze-docs ba.write-stories ba.render-confluence \
         ba.start-project ba.start-task ba.next; do
  [ -f "$DEST/$s.prompt.md" ] || mapped=0
done
[ "$mapped" -eq 1 ] && ok "all skills mapped with .prompt.md extension" || no "all skills mapped with .prompt.md extension"

# Helper templates/internal files are NOT mapped (only ba.* skills).
[ ! -f "$DEST/_skill-template.prompt.md" ] && ok "internal templates not mapped" || no "internal templates not mapped"

# A .github/prompts install enables prompt files via workspace settings (fresh run).
SETTINGS="$WORKDIR/.vscode/settings.json"
[ -f "$SETTINGS" ] && ok ".vscode/settings.json created" || no ".vscode/settings.json created"
grep -q '"chat.promptFiles"' "$SETTINGS" 2>/dev/null \
  && ok "chat.promptFiles enabled in settings" || no "chat.promptFiles enabled in settings"

# Re-running is idempotent and does not clobber an existing settings.json.
printf '%s\n' '{' '  "editor.tabSize": 2,' '  "chat.promptFiles": true' '}' > "$SETTINGS"
( cd "$WORKDIR" && sh "$CLONE/install.sh" --dest "$DEST" >/dev/null 2>&1 )
grep -q '"editor.tabSize"' "$SETTINGS" 2>/dev/null \
  && ok "existing settings.json preserved on re-run" || no "existing settings.json preserved on re-run"

# --- Claude target (US1) ---------------------------------------------------
# Scope: this verifies skill placement, naming, and idempotency for the Claude
# target. Actual in-Claude invocation is verified manually per quickstart S1.

# `--agent claude` maps all ba.* skills into .claude/commands as plain *.md.
CWORK="$TMP/claude-explicit"
mkdir -p "$CWORK"
( cd "$CWORK" && sh "$CLONE/install.sh" --agent claude >/dev/null 2>&1 ) \
  && ok "claude installer runs cleanly" || no "claude installer runs cleanly"
CDEST="$CWORK/.claude/commands"
[ -d "$CDEST" ] && ok "claude: .claude/commands/ created when absent" || no "claude: .claude/commands/ created when absent"
cmapped=1
for s in ba.specify ba.analyze-docs ba.write-stories ba.render-confluence \
         ba.start-project ba.start-task ba.next; do
  [ -f "$CDEST/$s.md" ] || cmapped=0
done
[ "$cmapped" -eq 1 ] && ok "claude: all skills mapped with plain .md extension" || no "claude: all skills mapped with plain .md extension"
# Claude must NOT receive the VS Code '.prompt.md' naming.
[ ! -f "$CDEST/ba.next.prompt.md" ] && ok "claude: no .prompt.md naming" || no "claude: no .prompt.md naming"
# Internal templates are not mapped for Claude either.
[ ! -f "$CDEST/_skill-template.md" ] && ok "claude: internal templates not mapped" || no "claude: internal templates not mapped"
# Claude install does NOT create VS Code workspace settings.
[ ! -f "$CWORK/.vscode/settings.json" ] && ok "claude: no .vscode/settings.json" || no "claude: no .vscode/settings.json"
# Re-running the Claude install is idempotent (still succeeds, skills present).
( cd "$CWORK" && sh "$CLONE/install.sh" --agent claude >/dev/null 2>&1 ) \
  && [ -f "$CDEST/ba.next.md" ] && ok "claude: re-run idempotent" || no "claude: re-run idempotent"

# Auto-detect (non-interactive fallback): with no controlling terminal and no
# --agent, a single detected target is selected and the menu never blocks.
CAUTO="$TMP/claude-auto"
mkdir -p "$CAUTO/.claude"
( cd "$CAUTO" && sh "$CLONE/install.sh" </dev/null >/dev/null 2>&1 )
[ -f "$CAUTO/.claude/commands/ba.next.md" ] && ok "auto-detect: lone .claude/ -> claude" || no "auto-detect: lone .claude/ -> claude"

# Mixed-agent precedence: both .github/ and .claude/ present, no --agent,
# resolves to Copilot (.github/prompts) and leaves .claude/ untouched.
CMIX="$TMP/claude-mixed"
mkdir -p "$CMIX/.github" "$CMIX/.claude"
( cd "$CMIX" && sh "$CLONE/install.sh" </dev/null >/dev/null 2>&1 )
[ -f "$CMIX/.github/prompts/ba.next.prompt.md" ] && ok "mixed-agent: precedence selects copilot" || no "mixed-agent: precedence selects copilot"
[ ! -f "$CMIX/.claude/commands/ba.next.md" ] && ok "mixed-agent: .claude left untouched" || no "mixed-agent: .claude left untouched"

# No marker + non-interactive: installer falls back to manual instructions and
# never blocks (exit 0, nothing installed).
CNONE="$TMP/none-noninteractive"
mkdir -p "$CNONE"
( cd "$CNONE" && sh "$CLONE/install.sh" </dev/null >/dev/null 2>&1 ) \
  && [ ! -d "$CNONE/.github" ] && [ ! -d "$CNONE/.claude" ] \
  && ok "no marker + non-interactive: no block, nothing installed" || no "no marker + non-interactive: no block, nothing installed"

# --- Interactive multi-select menu (US1) -----------------------------------
# The menu is driven deterministically via piped stdin with BAKIT_ASSUME_MENU=1
# (test hook) so the same code path real users see is exercised in CI.

# Single selection: choose option 1 (copilot) and confirm.
MSINGLE="$TMP/menu-single"
mkdir -p "$MSINGLE"
printf '1\ny\n' | ( cd "$MSINGLE" && BAKIT_ASSUME_MENU=1 sh "$CLONE/install.sh" >/dev/null 2>&1 )
[ -f "$MSINGLE/.github/prompts/ba.next.prompt.md" ] && ok "menu: single selection installs copilot" || no "menu: single selection installs copilot"

# Multi-selection: choose options 1 (copilot) and 2 (claude) at once.
MMULTI="$TMP/menu-multi"
mkdir -p "$MMULTI"
printf '1 2\ny\n' | ( cd "$MMULTI" && BAKIT_ASSUME_MENU=1 sh "$CLONE/install.sh" >/dev/null 2>&1 )
[ -f "$MMULTI/.github/prompts/ba.next.prompt.md" ] && [ -f "$MMULTI/.claude/commands/ba.next.md" ] \
  && ok "menu: multi-selection installs copilot + claude" || no "menu: multi-selection installs copilot + claude"

# Decline confirmation: nothing is installed.
MCANCEL="$TMP/menu-cancel"
mkdir -p "$MCANCEL"
printf '1\nn\n' | ( cd "$MCANCEL" && BAKIT_ASSUME_MENU=1 sh "$CLONE/install.sh" >/dev/null 2>&1 )
[ ! -d "$MCANCEL/.github" ] && ok "menu: declining confirmation installs nothing" || no "menu: declining confirmation installs nothing"

# Empty selection accepts the pre-selected (auto-detected) defaults.
MDEFAULT="$TMP/menu-default"
mkdir -p "$MDEFAULT/.cursor"
printf '\ny\n' | ( cd "$MDEFAULT" && BAKIT_ASSUME_MENU=1 sh "$CLONE/install.sh" >/dev/null 2>&1 )
[ -f "$MDEFAULT/.cursor/commands/ba.next.md" ] && ok "menu: empty input accepts pre-selected default" || no "menu: empty input accepts pre-selected default"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
