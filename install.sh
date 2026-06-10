#!/bin/sh
# BA-Kit installer / bootstrap (POSIX sh)
#
# Maps the agent-agnostic BA skills into a target AI agent / IDE so they can be
# invoked as commands, and makes the helper scripts executable.
#
# Run it with no arguments for a simple guided menu (in a terminal), or pass
# flags for non-interactive / CI use. See --help for the full option list.
#
# This script never performs network calls and is safe to re-run (idempotent).

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BAKIT_HOME="$SCRIPT_DIR"
SKILLS_DIR="$BAKIT_HOME/skills"

AGENT=""
DEST=""
SCOPE=""

log()  { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
BA-Kit installer (POSIX sh)

Usage:
  ./install.sh [--agent <key>] [--scope <workspace|global>] [--dest <dir>]

Options:
  --agent <key>   Target agent/IDE. One of:
                    copilot      VS Code (GitHub Copilot) -> .github/prompts/*.prompt.md
                    claude       Claude                   -> .claude/commands/*.md
                    cursor       Cursor                   -> .cursor/commands/*.md
                    generic      Generic                  -> .bakit/skills/*.md
                    antigravity  Antigravity IDE          -> <scope>/.../<skill>/SKILL.md
  --scope <s>     Antigravity only: 'workspace' (default; ./.agents/skills/) or
                  'global' (~/.gemini/config/skills/). Ignored for other agents.
  --dest <dir>    Override the destination directory (flat-file agents).
  -h, --help      Show this help and exit.

With no --agent and a terminal, a guided multi-select menu is shown. With no
terminal (CI / piped input) and no --agent, the installer auto-detects a target
from existing directories and never blocks.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --agent) AGENT="${2:-}"; shift 2 ;;
    --scope) SCOPE="${2:-}"; shift 2 ;;
    --dest)  DEST="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done

# ---------------------------------------------------------------------------
# Agent target table (single source of truth for menu, flags, auto-detect).
# Fields: key|label|dest|layout|ext   (detect + scope handled by helpers)
# ---------------------------------------------------------------------------
AGENT_TABLE='copilot|VS Code (GitHub Copilot)|.github/prompts|flat-file|.prompt.md
claude|Claude|.claude/commands|flat-file|.md
cursor|Cursor|.cursor/commands|flat-file|.md
generic|Generic|.bakit/skills|flat-file|.md
antigravity|Antigravity IDE|.agents/skills|skill-folder|.md'

# Ordered list of keys (also the auto-detect precedence order).
AGENT_KEYS='copilot claude cursor generic antigravity'

agent_row()   { printf '%s\n' "$AGENT_TABLE" | awk -F'|' -v k="$1" '$1==k{print; exit}'; }
agent_label() { agent_row "$1" | awk -F'|' '{print $2}'; }
agent_dest()  { agent_row "$1" | awk -F'|' '{print $3}'; }
agent_layout(){ agent_row "$1" | awk -F'|' '{print $4}'; }
agent_ext()   { agent_row "$1" | awk -F'|' '{print $5}'; }

valid_agent() {
  case " $AGENT_KEYS " in *" $1 "*) return 0 ;; *) return 1 ;; esac
}

# Auto-detected agents (workspace markers), in precedence order. The global
# Antigravity marker (~/.gemini) is intentionally NOT used here so it cannot
# influence the non-interactive single-pick fallback (FR-008a).
detect_agents() {
  d=""
  if [ -d "$PWD/.github/prompts" ] || [ -d "$PWD/.github" ]; then d="$d copilot"; fi
  [ -d "$PWD/.claude" ] && d="$d claude"
  [ -d "$PWD/.cursor" ] && d="$d cursor"
  [ -d "$PWD/.agents" ] && d="$d antigravity"
  printf '%s' "${d# }"
}

# Menu pre-selection adds the Antigravity global marker as a convenience.
preselected_agents() {
  d=$(detect_agents)
  if [ -d "$HOME/.gemini/config/skills" ]; then
    case " $d " in *" antigravity "*) : ;; *) d="${d:+$d }antigravity" ;; esac
  fi
  printf '%s' "$d"
}

# ---------------------------------------------------------------------------
# 1. Make helper + test scripts executable.
# ---------------------------------------------------------------------------
log "Making BA-Kit scripts executable..."
chmod +x "$BAKIT_HOME"/scripts/sh/*.sh 2>/dev/null || true
chmod +x "$BAKIT_HOME"/tests/sh/*.sh 2>/dev/null || true

# ---------------------------------------------------------------------------
# Skill front-matter helpers (for Antigravity SKILL.md generation).
# ---------------------------------------------------------------------------
skill_summary() { # file -> value of the front-matter 'summary:' field
  sed -n 's/^summary:[[:space:]]*//p' "$1" | head -1 | sed 's/^"//; s/"$//'
}
skill_body() { # file -> everything after the closing front-matter '---'
  awk 'c>=2{print} /^---[[:space:]]*$/{c++}' "$1"
}
first_sentence() { # text on stdin -> first sentence (fallback description)
  tr '\n' ' ' | sed 's/^[[:space:]]*//' | sed 's/\([.!?]\).*/\1/' | cut -c1-200
}

# ---------------------------------------------------------------------------
# Flat-file install (copilot / claude / cursor / generic).
# ---------------------------------------------------------------------------
install_flat() { # dest ext
  _dest="$1"; _ext="$2"
  mkdir -p "$_dest"
  log "Installing BA skills into: $_dest"
  for skill in "$SKILLS_DIR"/ba.*.md; do
    [ -e "$skill" ] || continue
    base=$(basename "$skill" .md)
    cp "$skill" "$_dest/$base$_ext"
    log "  + $base$_ext"
  done
  case "$_dest" in
    */.github/prompts)
      ws_root="${_dest%/.github/prompts}"
      settings="$ws_root/.vscode/settings.json"
      if [ ! -f "$settings" ]; then
        mkdir -p "$ws_root/.vscode"
        printf '%s\n' '{' '  "chat.promptFiles": true' '}' > "$settings"
        log "Enabled prompt files for this workspace: $settings"
      elif grep -q '"chat.promptFiles"' "$settings" 2>/dev/null; then
        log "Prompt files already configured in $settings"
      else
        warn "Add '\"chat.promptFiles\": true' to $settings so the skills appear as /commands."
      fi ;;
  esac
}

# ---------------------------------------------------------------------------
# Antigravity skill-folder install (self-contained per skill).
# ---------------------------------------------------------------------------
antigravity_skills_dir() { # scope -> base skills directory
  case "$1" in
    global) printf '%s' "$HOME/.gemini/config/skills" ;;
    *)      printf '%s' "$PWD/.agents/skills" ;;
  esac
}

install_antigravity() { # scope
  _scope="$1"
  _base=$(antigravity_skills_dir "$_scope")
  mkdir -p "$_base"
  log "Installing BA skills (Antigravity, $_scope) into: $_base"
  for skill in "$SKILLS_DIR"/ba.*.md; do
    [ -e "$skill" ] || continue
    name=$(basename "$skill" .md)
    folder="$_base/$name"
    # Idempotent reconciliation: rebuild the folder so no stale files remain.
    rm -rf "$folder"
    mkdir -p "$folder"

    desc=$(skill_summary "$skill")
    if [ -z "$desc" ]; then desc=$(skill_body "$skill" | first_sentence); fi
    # Escape any double quotes for safe YAML embedding.
    esc_desc=$(printf '%s' "$desc" | sed 's/"/\\"/g')
    {
      printf '%s\n' '---'
      printf 'name: %s\n' "$name"
      printf 'description: "%s"\n' "$esc_desc"
      printf '%s\n' '---'
      skill_body "$skill"
    } > "$folder/SKILL.md"

    # Bundle referenced helper scripts + templates (verbatim) so the folder is
    # self-contained even when installed globally.
    sh_refs=$(grep -oE 'scripts/sh/[A-Za-z0-9._-]+\.sh' "$skill" 2>/dev/null | sort -u || true)
    ps_refs=$(grep -oE 'scripts/ps/[A-Za-z0-9._-]+\.ps1' "$skill" 2>/dev/null | sort -u || true)
    tpl_refs=$(grep -oE 'templates/[A-Za-z0-9._/-]+\.md' "$skill" 2>/dev/null | sort -u || true)

    if [ -n "$sh_refs" ]; then
      mkdir -p "$folder/scripts/sh"
      for r in $sh_refs; do
        [ -f "$BAKIT_HOME/$r" ] && cp "$BAKIT_HOME/$r" "$folder/scripts/sh/"
      done
      [ -f "$BAKIT_HOME/scripts/sh/common.sh" ] && cp "$BAKIT_HOME/scripts/sh/common.sh" "$folder/scripts/sh/"
    fi
    if [ -n "$ps_refs" ]; then
      mkdir -p "$folder/scripts/ps"
      for r in $ps_refs; do
        [ -f "$BAKIT_HOME/$r" ] && cp "$BAKIT_HOME/$r" "$folder/scripts/ps/"
      done
      [ -f "$BAKIT_HOME/scripts/ps/common.ps1" ] && cp "$BAKIT_HOME/scripts/ps/common.ps1" "$folder/scripts/ps/"
    fi
    if [ -n "$tpl_refs" ]; then
      for r in $tpl_refs; do
        if [ -f "$BAKIT_HOME/$r" ]; then
          mkdir -p "$folder/resources/$(dirname "$r")"
          cp "$BAKIT_HOME/$r" "$folder/resources/$r"
        fi
      done
    fi
    log "  + $name/ (SKILL.md${sh_refs:+, scripts/sh}${ps_refs:+, scripts/ps}${tpl_refs:+, resources})"
  done
}

# ---------------------------------------------------------------------------
# Per-target dispatch + summary line.
# ---------------------------------------------------------------------------
SUMMARY=""
add_summary() { SUMMARY="${SUMMARY}$1
"; }

install_target() { # key [scope]
  key="$1"; scope="${2:-workspace}"
  layout=$(agent_layout "$key")
  if [ "$layout" = "skill-folder" ]; then
    install_antigravity "$scope"
    loc=$(antigravity_skills_dir "$scope")
    add_summary "Installed for $(agent_label "$key") ($scope): $loc/  -> open the workspace in Antigravity and invoke a skill, e.g. ba.start-project"
  else
    # Destination: explicit --dest overrides; else table dest under PWD.
    if [ -n "$DEST" ]; then dst="$DEST"; else dst="$PWD/$(agent_dest "$key")"; fi
    case "$dst" in */.github/prompts) ext=".prompt.md" ;; *) ext=$(agent_ext "$key") ;; esac
    install_flat "$dst" "$ext"
    if [ "$key" = "copilot" ]; then
      add_summary "Installed for $(agent_label "$key"): $dst/  -> reload VS Code, then type / in Copilot Chat, e.g. /ba.start-project"
    else
      add_summary "Installed for $(agent_label "$key"): $dst/  -> open the workspace in your agent and invoke a skill, e.g. /ba.start-project"
    fi
  fi
}

# ---------------------------------------------------------------------------
# Interactive multi-select menu.
# ---------------------------------------------------------------------------
run_menu() { # reads from $MENU_IN; sets SELECTED (space-separated keys) + SCOPE
  pre=" $(preselected_agents) "
  log ""
  log "Select the agent(s) / IDE(s) to install BA-Kit for."
  log "Enter the numbers separated by spaces (e.g. '1 3'), then press Enter."
  log ""
  i=0
  for k in $AGENT_KEYS; do
    i=$((i+1))
    mark="[ ]"
    case "$pre" in *" $k "*) mark="[x]" ;; esac
    printf '  %d) %s %s\n' "$i" "$mark" "$(agent_label "$k")"
  done
  log ""
  printf 'Your selection (default = pre-selected [x]): '
  IFS= read -r reply < "$MENU_IN" || reply=""

  SELECTED=""
  if [ -z "$(printf '%s' "$reply" | tr -d ' ,')" ]; then
    # Empty -> accept pre-selected defaults.
    SELECTED=$(preselected_agents)
  else
    for tok in $(printf '%s' "$reply" | tr ',' ' '); do
      case "$tok" in
        ''|*[!0-9]*) warn "ignoring invalid selection: $tok"; continue ;;
      esac
      n=0
      for k in $AGENT_KEYS; do
        n=$((n+1))
        if [ "$n" -eq "$tok" ]; then SELECTED="${SELECTED:+$SELECTED }$k"; fi
      done
    done
  fi

  if [ -z "$SELECTED" ]; then
    warn "No valid agent selected."
    printf 'Try again? [y/N]: '
    IFS= read -r again < "$MENU_IN" || again=""
    case "$again" in y|Y|yes|YES) run_menu; return ;; *) log "Nothing installed."; exit 0 ;; esac
  fi

  # Antigravity scope sub-prompt.
  case " $SELECTED " in
    *" antigravity "*)
      if [ -z "$SCOPE" ]; then
        printf 'Antigravity scope - 1) workspace (default)  2) global: '
        IFS= read -r sreply < "$MENU_IN" || sreply=""
        case "$sreply" in 2|global) SCOPE="global" ;; *) SCOPE="workspace" ;; esac
      fi ;;
  esac

  log ""
  log "Selected: $SELECTED${SCOPE:+   (Antigravity scope: $SCOPE)}"
  printf 'Proceed? [y/N]: '
  IFS= read -r confirm < "$MENU_IN" || confirm=""
  case "$confirm" in
    y|Y|yes|YES) : ;;
    *) log "Cancelled. Nothing installed."; exit 0 ;;
  esac
}

# ---------------------------------------------------------------------------
# Mode resolution.
# ---------------------------------------------------------------------------
[ -n "$SCOPE" ] && case "$SCOPE" in workspace|global) : ;; *) die "unknown scope: $SCOPE (use workspace|global)" ;; esac

if [ -n "$AGENT" ]; then
  valid_agent "$AGENT" || die "unknown agent: $AGENT (try --help)"
  install_target "$AGENT" "${SCOPE:-workspace}"
elif [ -n "$DEST" ]; then
  # Bare --dest (no agent): flat-file install to the given directory.
  case "$DEST" in */.github/prompts) ext=".prompt.md" ;; *) ext=".md" ;; esac
  install_flat "$DEST" "$ext"
  add_summary "Installed BA skills into: $DEST/"
else
  # No agent flag: interactive menu (TTY or forced) else auto-detect fallback.
  MENU_IN=""
  if [ -t 0 ]; then MENU_IN="/dev/tty"
  elif [ -n "${BAKIT_ASSUME_MENU:-}" ]; then MENU_IN="/dev/stdin"
  fi
  if [ -n "$MENU_IN" ]; then
    run_menu
    for k in $SELECTED; do install_target "$k" "${SCOPE:-workspace}"; done
  else
    # Non-interactive fallback: single-pick auto-detect (workspace markers).
    first=$(detect_agents | awk '{print $1}')
    if [ -n "$first" ]; then
      install_target "$first" "${SCOPE:-workspace}"
    else
      warn "Could not auto-detect an agent directory."
      log ""
      log "BA skills live in: $SKILLS_DIR"
      log "Re-run targeting your agent, e.g.:"
      log "  ./install.sh --agent copilot      # VS Code  -> .github/prompts/*.prompt.md"
      log "  ./install.sh --agent claude       # Claude   -> .claude/commands/*.md"
      log "  ./install.sh --agent antigravity  # Antigravity -> .agents/skills/<skill>/SKILL.md"
      log "  ./install.sh --dest <dir>"
      exit 0
    fi
  fi
fi

# ---------------------------------------------------------------------------
# Summary.
# ---------------------------------------------------------------------------
log ""
log "BA-Kit installed."
printf '%s' "$SUMMARY" | while IFS= read -r line; do [ -n "$line" ] && log "  $line"; done
log ""
log "Get started — invoke these skills in your agent:"
log "  ba.start-project   # scaffolds a project workspace + shared kb/"
log "  ba.start-task      # scaffolds a task (inputs/artifacts/deliverables/kb)"
log "  ba.next            # asks the workflow what to run next"
