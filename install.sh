#!/bin/sh
# BA-Kit installer / bootstrap (POSIX sh)
#
# Makes the helper scripts executable and maps the agent-agnostic BA skills into
# a target AI agent's prompt directory so they can be invoked as commands.
#
# Usage:
#   ./install.sh [--agent <copilot|claude|cursor|generic>] [--dest <dir>]
#
# Behavior:
#   - With no arguments, auto-detects a known agent prompt directory under the
#     current working directory; falls back to printing manual instructions.
#   - --dest overrides the destination directory for skill files.
#
# This script never performs network calls and is safe to re-run (idempotent).

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BAKIT_HOME="$SCRIPT_DIR"
SKILLS_DIR="$BAKIT_HOME/skills"

AGENT=""
DEST=""

log()  { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --agent) AGENT="${2:-}"; shift 2 ;;
    --dest)  DEST="${2:-}"; shift 2 ;;
    -h|--help)
      sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

# 1. Make helper + test scripts executable.
log "Making BA-Kit scripts executable..."
chmod +x "$BAKIT_HOME"/scripts/sh/*.sh 2>/dev/null || true
chmod +x "$BAKIT_HOME"/tests/sh/*.sh 2>/dev/null || true

# 2. Resolve the destination directory for skill prompt files.
detect_dest() {
  # Honor explicit destination first.
  if [ -n "$DEST" ]; then printf '%s' "$DEST"; return 0; fi
  # Map known agents to their conventional prompt directories.
  case "$AGENT" in
    copilot) printf '%s' "$PWD/.github/prompts"; return 0 ;;
    claude)  printf '%s' "$PWD/.claude/commands"; return 0 ;;
    cursor)  printf '%s' "$PWD/.cursor/commands"; return 0 ;;
    generic) printf '%s' "$PWD/.bakit/skills"; return 0 ;;
    "") : ;;  # fall through to auto-detect
    *) die "unknown agent: $AGENT" ;;
  esac
  # Auto-detect from existing directories.
  if [ -d "$PWD/.github/prompts" ] || [ -d "$PWD/.github" ]; then
    printf '%s' "$PWD/.github/prompts"; return 0
  fi
  if [ -d "$PWD/.claude" ]; then printf '%s' "$PWD/.claude/commands"; return 0; fi
  if [ -d "$PWD/.cursor" ]; then printf '%s' "$PWD/.cursor/commands"; return 0; fi
  return 1
}

if dest=$(detect_dest); then
  mkdir -p "$dest"
  log "Installing BA skills into: $dest"
  # VS Code Copilot only registers files named '*.prompt.md' (in .github/prompts)
  # as slash commands. Other agents use plain '*.md' in their command dirs.
  case "$dest" in
    */.github/prompts) ext=".prompt.md" ;;
    *)                 ext=".md" ;;
  esac
  for skill in "$SKILLS_DIR"/ba.*.md; do
    [ -e "$skill" ] || continue
    base=$(basename "$skill" .md)
    cp "$skill" "$dest/$base$ext"
    log "  + $base$ext"
  done

  # VS Code only exposes .github/prompts/*.prompt.md as '/' slash commands when
  # the 'chat.promptFiles' setting is enabled. Turn it on for the workspace so a
  # fresh open works without manual setup. Safe-merge: never clobber an existing
  # settings.json; if the key is already managed, leave it untouched.
  case "$dest" in
    */.github/prompts)
      ws_root="${dest%/.github/prompts}"
      settings="$ws_root/.vscode/settings.json"
      if [ ! -f "$settings" ]; then
        mkdir -p "$ws_root/.vscode"
        printf '%s\n' '{' '  "chat.promptFiles": true' '}' > "$settings"
        log ""
        log "Enabled prompt files for this workspace: $settings"
      elif grep -q '"chat.promptFiles"' "$settings" 2>/dev/null; then
        log ""
        log "Prompt files already configured in $settings"
      else
        log ""
        warn "Add '\"chat.promptFiles\": true' to $settings so the skills appear as /commands."
      fi ;;
  esac

  log ""
  log "BA-Kit installed. Reload VS Code (Developer: Reload Window), trust the folder"
  log "if prompted, then type '/' in Copilot Chat and pick a skill, e.g. /ba.start-project."
else
  warn "Could not auto-detect an agent prompt directory."
  log ""
  log "BA skills live in: $SKILLS_DIR"
  log "Re-run targeting your agent so they install to the right place:"
  log "  ./install.sh --agent copilot   # VS Code  -> .github/prompts/*.prompt.md"
  log "  ./install.sh --agent claude     # Claude   -> .claude/commands/*.md"
  log "  ./install.sh --agent cursor     # Cursor   -> .cursor/commands/*.md"
  log "  ./install.sh --dest <your-agent-prompt-dir>"
fi

log ""
log "Get started (agent-driven — just invoke these skills in your agent):"
log "  ba.start-project   # scaffolds a project workspace + shared kb/"
log "  ba.start-task      # scaffolds a task (inputs/artifacts/deliverables/kb)"
log "  ba.next            # asks the workflow what to run next"
