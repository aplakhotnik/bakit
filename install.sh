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
  for skill in "$SKILLS_DIR"/ba.*.md; do
    [ -e "$skill" ] || continue
    cp "$skill" "$dest/"
    log "  + $(basename "$skill")"
  done
  log ""
  log "BA-Kit installed. Restart your agent if needed, then invoke a skill, e.g. 'ba.specify-requirements'."
else
  warn "Could not auto-detect an agent prompt directory."
  log ""
  log "BA skills live in: $SKILLS_DIR"
  log "Copy the ba.*.md files into your agent's prompt/command directory, or re-run with:"
  log "  ./install.sh --agent <copilot|claude|cursor|generic>"
  log "  ./install.sh --dest <your-agent-prompt-dir>"
fi

log ""
log "Scaffold your first workspace:"
log "  ./scripts/sh/init-project.sh \"my-project\""
log "  ./scripts/sh/init-task.sh \"my-project\" \"my-first-task\""
