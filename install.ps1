# BA-Kit installer / bootstrap (PowerShell)
#
# Maps the agent-agnostic BA skills into a target AI agent / IDE so they can be
# invoked as commands. Mirrors install.sh (minus the Unix exec bit).
#
# Run it with no arguments for a simple guided menu (in a terminal), or pass
# flags for non-interactive / CI use. See -Help for the full option list.
#
# This script never performs network calls and is safe to re-run (idempotent).

[CmdletBinding()]
param(
    [string]$Agent = '',
    [string]$Scope = '',
    [string]$Dest = '',
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

$BakitHome = $PSScriptRoot
$SkillsDir = (Join-Path $BakitHome 'skills')

function Write-Log  { param([string]$Message = '') Write-Output $Message }
function Write-Warn { param([string]$Message = '') [Console]::Error.WriteLine("warning: $Message") }
function Write-Die  { param([string]$Message = '') [Console]::Error.WriteLine("error: $Message"); exit 1 }

# Write text as UTF-8 (no BOM) with LF line endings.
function Write-TextFile {
    param([string]$Path, [string]$Text)
    $normalized = $Text -replace "`r`n", "`n"
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $normalized, $enc)
}

function Show-Usage {
    $text = @'
BA-Kit installer (PowerShell)

Usage:
  ./install.ps1 [-Agent <key>] [-Scope <workspace|global>] [-Dest <dir>]

Options:
  -Agent <key>   Target agent/IDE. One of:
                   copilot      VS Code (GitHub Copilot) -> .github/prompts/*.prompt.md
                   claude       Claude                   -> .claude/commands/*.md
                   cursor       Cursor                   -> .cursor/commands/*.md
                   generic      Generic                  -> .bakit/skills/*.md
                   antigravity  Antigravity IDE          -> <scope>/.../<skill>/SKILL.md
  -Scope <s>     Antigravity only: 'workspace' (default; ./.agents/skills/) or
                 'global' (~/.gemini/config/skills/). Ignored for other agents.
  -Dest <dir>    Override the destination directory (flat-file agents).
  -Help          Show this help and exit.

With no -Agent and a terminal, a guided multi-select menu is shown. With no
terminal (CI / piped input) and no -Agent, the installer auto-detects a target
from existing directories and never blocks.
'@
    Write-Output $text
}

if ($Help) { Show-Usage; exit 0 }

# ---------------------------------------------------------------------------
# Agent target table (single source of truth for menu, flags, auto-detect).
# ---------------------------------------------------------------------------
$AgentTable = @(
    [pscustomobject]@{ key = 'copilot';     label = 'VS Code (GitHub Copilot)'; dest = '.github/prompts'; layout = 'flat-file';   ext = '.prompt.md' }
    [pscustomobject]@{ key = 'claude';      label = 'Claude';                   dest = '.claude/commands'; layout = 'flat-file';   ext = '.md' }
    [pscustomobject]@{ key = 'cursor';      label = 'Cursor';                   dest = '.cursor/commands'; layout = 'flat-file';   ext = '.md' }
    [pscustomobject]@{ key = 'generic';     label = 'Generic';                  dest = '.bakit/skills';    layout = 'flat-file';   ext = '.md' }
    [pscustomobject]@{ key = 'antigravity'; label = 'Antigravity IDE';          dest = '.agents/skills';   layout = 'skill-folder'; ext = '.md' }
)
# Ordered list of keys (also the auto-detect precedence order).
$AgentKeys = @($AgentTable | ForEach-Object { $_.key })

function Get-AgentRow    { param($k) $AgentTable | Where-Object { $_.key -eq $k } | Select-Object -First 1 }
function Get-AgentLabel  { param($k) (Get-AgentRow $k).label }
function Get-AgentDest   { param($k) (Get-AgentRow $k).dest }
function Get-AgentLayout { param($k) (Get-AgentRow $k).layout }
function Get-AgentExt    { param($k) (Get-AgentRow $k).ext }
function Test-ValidAgent { param($k) return ($AgentKeys -contains $k) }

# Resolve the user's home directory. Honors $env:HOME / $env:USERPROFILE (sh
# parity + testability) before falling back to the $HOME automatic variable.
function Get-UserHome {
    if (-not [string]::IsNullOrEmpty($env:HOME)) { return $env:HOME }
    if (-not [string]::IsNullOrEmpty($env:USERPROFILE)) { return $env:USERPROFILE }
    return $HOME
}

# True if a destination path is a VS Code Copilot prompts directory.
function Test-CopilotDest {
    param([string]$Path)
    $norm = ($Path -replace '\\', '/').TrimEnd('/')
    return $norm.EndsWith('.github/prompts')
}

# Auto-detected agents (workspace markers), in precedence order. The global
# Antigravity marker (~/.gemini) is intentionally NOT used here so it cannot
# influence the non-interactive single-pick fallback (FR-008a).
function Get-DetectedAgents {
    $cwd = (Get-Location).Path
    $d = @()
    if ((Test-Path -LiteralPath (Join-Path $cwd '.github/prompts')) -or (Test-Path -LiteralPath (Join-Path $cwd '.github'))) { $d += 'copilot' }
    if (Test-Path -LiteralPath (Join-Path $cwd '.claude')) { $d += 'claude' }
    if (Test-Path -LiteralPath (Join-Path $cwd '.cursor')) { $d += 'cursor' }
    if (Test-Path -LiteralPath (Join-Path $cwd '.agents')) { $d += 'antigravity' }
    return $d
}

# Menu pre-selection adds the Antigravity global marker as a convenience.
function Get-PreselectedAgents {
    $d = @(Get-DetectedAgents)
    $gem = Join-Path (Get-UserHome) '.gemini/config/skills'
    if ((Test-Path -LiteralPath $gem) -and ($d -notcontains 'antigravity')) { $d += 'antigravity' }
    return $d
}

function Get-AntigravitySkillsDir {
    param([string]$ScopeVal)
    if ($ScopeVal -eq 'global') { return (Join-Path (Get-UserHome) '.gemini/config/skills') }
    return (Join-Path (Get-Location).Path '.agents/skills')
}

# ---------------------------------------------------------------------------
# Skill front-matter helpers (for Antigravity SKILL.md generation).
# ---------------------------------------------------------------------------
function Get-SkillSummary {
    param([string]$Path)
    $line = Get-Content -LiteralPath $Path | Where-Object { $_ -match '^summary:' } | Select-Object -First 1
    if (-not $line) { return '' }
    return ($line -replace '^summary:\s*', '').Trim().Trim('"')
}

function Get-SkillBody {
    param([string]$Path)
    $lines = Get-Content -LiteralPath $Path
    $c = 0
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($l in $lines) {
        if ($c -ge 2) { $out.Add($l) }
        if ($l -match '^---\s*$') { $c++ }
    }
    return ($out -join "`n")
}

function Get-FirstSentence {
    param([string]$Text)
    $flat = ($Text -replace "`n", ' ').Trim()
    if ($flat -match '^(.*?[.!?])(\s|$)') { $flat = $Matches[1] }
    if ($flat.Length -gt 200) { $flat = $flat.Substring(0, 200) }
    return $flat
}

# ---------------------------------------------------------------------------
# Flat-file install (copilot / claude / cursor / generic).
# ---------------------------------------------------------------------------
function Install-Flat {
    param([string]$DestDir, [string]$Ext)
    New-Item -ItemType Directory -Force -Path $DestDir | Out-Null
    Write-Log "Installing BA skills into: $DestDir"
    Get-ChildItem -LiteralPath $SkillsDir -Filter 'ba.*.md' -File -ErrorAction SilentlyContinue | ForEach-Object {
        $base = $_.BaseName
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $DestDir "$base$Ext") -Force
        Write-Log "  + $base$Ext"
    }
    if (Test-CopilotDest $DestDir) {
        $norm = ($DestDir -replace '\\', '/').TrimEnd('/')
        $wsRoot = $norm.Substring(0, $norm.Length - '.github/prompts'.Length).TrimEnd('/')
        if ([string]::IsNullOrEmpty($wsRoot)) { $wsRoot = '.' }
        $settings = (Join-Path (Join-Path $wsRoot '.vscode') 'settings.json')
        if (-not (Test-Path -LiteralPath $settings)) {
            New-Item -ItemType Directory -Force -Path (Join-Path $wsRoot '.vscode') | Out-Null
            Write-TextFile $settings "{`n  `"chat.promptFiles`": true`n}`n"
            Write-Log "Enabled prompt files for this workspace: $settings"
        } elseif (Select-String -LiteralPath $settings -Pattern '"chat.promptFiles"' -Quiet) {
            Write-Log "Prompt files already configured in $settings"
        } else {
            Write-Warn "Add '`"chat.promptFiles`": true' to $settings so the skills appear as /commands."
        }
    }
}

# ---------------------------------------------------------------------------
# Antigravity skill-folder install (self-contained per skill).
# ---------------------------------------------------------------------------
function Install-Antigravity {
    param([string]$ScopeVal)
    $base = Get-AntigravitySkillsDir $ScopeVal
    New-Item -ItemType Directory -Force -Path $base | Out-Null
    Write-Log "Installing BA skills (Antigravity, $ScopeVal) into: $base"
    Get-ChildItem -LiteralPath $SkillsDir -Filter 'ba.*.md' -File -ErrorAction SilentlyContinue | ForEach-Object {
        $name = $_.BaseName
        $folder = Join-Path $base $name
        # Idempotent reconciliation: rebuild the folder so no stale files remain.
        if (Test-Path -LiteralPath $folder) { Remove-Item -Recurse -Force -LiteralPath $folder }
        New-Item -ItemType Directory -Force -Path $folder | Out-Null

        $desc = Get-SkillSummary $_.FullName
        if ([string]::IsNullOrEmpty($desc)) { $desc = Get-FirstSentence (Get-SkillBody $_.FullName) }
        $escDesc = $desc -replace '"', '\"'
        $body = Get-SkillBody $_.FullName
        $skillMd = "---`nname: $name`ndescription: `"$escDesc`"`n---`n$body`n"
        Write-TextFile (Join-Path $folder 'SKILL.md') $skillMd

        $content = Get-Content -Raw -LiteralPath $_.FullName
        $shRefs  = [regex]::Matches($content, 'scripts/sh/[A-Za-z0-9._-]+\.sh')   | ForEach-Object { $_.Value } | Sort-Object -Unique
        $psRefs  = [regex]::Matches($content, 'scripts/ps/[A-Za-z0-9._-]+\.ps1')  | ForEach-Object { $_.Value } | Sort-Object -Unique
        $tplRefs = [regex]::Matches($content, 'templates/[A-Za-z0-9._/-]+\.md')   | ForEach-Object { $_.Value } | Sort-Object -Unique

        $tags = @('SKILL.md')
        if ($shRefs) {
            New-Item -ItemType Directory -Force -Path (Join-Path $folder 'scripts/sh') | Out-Null
            foreach ($r in $shRefs) {
                $src = Join-Path $BakitHome $r
                if (Test-Path -LiteralPath $src) { Copy-Item -LiteralPath $src -Destination (Join-Path $folder 'scripts/sh') -Force }
            }
            $common = Join-Path $BakitHome 'scripts/sh/common.sh'
            if (Test-Path -LiteralPath $common) { Copy-Item -LiteralPath $common -Destination (Join-Path $folder 'scripts/sh') -Force }
            $tags += 'scripts/sh'
        }
        if ($psRefs) {
            New-Item -ItemType Directory -Force -Path (Join-Path $folder 'scripts/ps') | Out-Null
            foreach ($r in $psRefs) {
                $src = Join-Path $BakitHome $r
                if (Test-Path -LiteralPath $src) { Copy-Item -LiteralPath $src -Destination (Join-Path $folder 'scripts/ps') -Force }
            }
            $common = Join-Path $BakitHome 'scripts/ps/common.ps1'
            if (Test-Path -LiteralPath $common) { Copy-Item -LiteralPath $common -Destination (Join-Path $folder 'scripts/ps') -Force }
            $tags += 'scripts/ps'
        }
        if ($tplRefs) {
            foreach ($r in $tplRefs) {
                $src = Join-Path $BakitHome $r
                if (Test-Path -LiteralPath $src) {
                    $target = Join-Path $folder (Join-Path 'resources' $r)
                    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
                    Copy-Item -LiteralPath $src -Destination $target -Force
                }
            }
            $tags += 'resources'
        }
        Write-Log ("  + {0}/ ({1})" -f $name, ($tags -join ', '))
    }
}

# ---------------------------------------------------------------------------
# Per-target dispatch + summary line.
# ---------------------------------------------------------------------------
$script:Summary = @()

function Install-Target {
    param([string]$Key, [string]$ScopeVal = 'workspace')
    $layout = Get-AgentLayout $Key
    if ($layout -eq 'skill-folder') {
        Install-Antigravity $ScopeVal
        $loc = Get-AntigravitySkillsDir $ScopeVal
        $script:Summary += "Installed for $(Get-AgentLabel $Key) ($ScopeVal): $loc/  -> open the workspace in Antigravity and invoke a skill, e.g. ba.start-project"
    } else {
        if (-not [string]::IsNullOrEmpty($Dest)) { $dst = $Dest } else { $dst = (Join-Path (Get-Location).Path (Get-AgentDest $Key)) }
        if (Test-CopilotDest $dst) { $ext = '.prompt.md' } else { $ext = (Get-AgentExt $Key) }
        Install-Flat $dst $ext
        if ($Key -eq 'copilot') {
            $script:Summary += "Installed for $(Get-AgentLabel $Key): $dst/  -> reload VS Code, then type / in Copilot Chat, e.g. /ba.start-project"
        } else {
            $script:Summary += "Installed for $(Get-AgentLabel $Key): $dst/  -> open the workspace in your agent and invoke a skill, e.g. /ba.start-project"
        }
    }
}

# ---------------------------------------------------------------------------
# Interactive multi-select menu.
# ---------------------------------------------------------------------------
function Read-MenuLine {
    $line = [Console]::ReadLine()
    if ($null -eq $line) { return '' }
    return $line
}

function Invoke-Menu {
    $pre = " $((Get-PreselectedAgents) -join ' ') "
    Write-Log ''
    Write-Log 'Select the agent(s) / IDE(s) to install BA-Kit for.'
    Write-Log "Enter the numbers separated by spaces (e.g. '1 3'), then press Enter."
    Write-Log ''
    $i = 0
    foreach ($k in $AgentKeys) {
        $i++
        $mark = if ($pre -like "* $k *") { '[x]' } else { '[ ]' }
        Write-Log ("  {0}) {1} {2}" -f $i, $mark, (Get-AgentLabel $k))
    }
    Write-Log ''
    [Console]::Out.Write('Your selection (default = pre-selected [x]): ')
    $reply = Read-MenuLine

    $selected = @()
    if (($reply -replace '[ ,]', '').Length -eq 0) {
        $selected = @(Get-PreselectedAgents)
    } else {
        foreach ($tok in ($reply -split '[ ,]+' | Where-Object { $_ -ne '' })) {
            if ($tok -notmatch '^[0-9]+$') { Write-Warn "ignoring invalid selection: $tok"; continue }
            $idx = [int]$tok
            if ($idx -ge 1 -and $idx -le $AgentKeys.Count) { $selected += $AgentKeys[$idx - 1] }
        }
    }
    $selected = @($selected | Select-Object -Unique)

    if (-not $selected -or $selected.Count -eq 0) {
        Write-Warn 'No valid agent selected.'
        [Console]::Out.Write('Try again? [y/N]: ')
        $again = Read-MenuLine
        if ($again -match '^(y|yes)$') { return (Invoke-Menu) }
        Write-Log 'Nothing installed.'; exit 0
    }

    if (($selected -contains 'antigravity') -and [string]::IsNullOrEmpty($script:Scope)) {
        [Console]::Out.Write('Antigravity scope - 1) workspace (default)  2) global: ')
        $sreply = Read-MenuLine
        if ($sreply -match '^(2|global)$') { $script:Scope = 'global' } else { $script:Scope = 'workspace' }
    }

    Write-Log ''
    $scopeNote = if ($script:Scope) { "   (Antigravity scope: $($script:Scope))" } else { '' }
    Write-Log ("Selected: {0}{1}" -f ($selected -join ' '), $scopeNote)
    [Console]::Out.Write('Proceed? [y/N]: ')
    $confirm = Read-MenuLine
    if ($confirm -notmatch '^(y|yes)$') { Write-Log 'Cancelled. Nothing installed.'; exit 0 }
    return $selected
}

# ---------------------------------------------------------------------------
# Mode resolution.
# ---------------------------------------------------------------------------
if ($Scope -and ($Scope -notin @('workspace', 'global'))) { Write-Die "unknown scope: $Scope (use workspace|global)" }
$scopeVal = if ($Scope) { $Scope } else { 'workspace' }

if ($Agent) {
    if (-not (Test-ValidAgent $Agent)) { Write-Die "unknown agent: $Agent (try -Help)" }
    Install-Target $Agent $scopeVal
} elseif ($Dest) {
    if (Test-CopilotDest $Dest) { $ext = '.prompt.md' } else { $ext = '.md' }
    Install-Flat $Dest $ext
    $script:Summary += "Installed BA skills into: $Dest/"
} else {
    $menuActive = $false
    if (-not [Console]::IsInputRedirected) { $menuActive = $true }
    elseif (-not [string]::IsNullOrEmpty($env:BAKIT_ASSUME_MENU)) { $menuActive = $true }

    if ($menuActive) {
        $selected = Invoke-Menu
        $scopeVal = if ($script:Scope) { $script:Scope } else { 'workspace' }
        foreach ($k in $selected) { Install-Target $k $scopeVal }
    } else {
        $first = @(Get-DetectedAgents) | Select-Object -First 1
        if ($first) {
            Install-Target $first $scopeVal
        } else {
            Write-Warn 'Could not auto-detect an agent directory.'
            Write-Log ''
            Write-Log "BA skills live in: $SkillsDir"
            Write-Log 'Re-run targeting your agent, e.g.:'
            Write-Log '  ./install.ps1 -Agent copilot      # VS Code  -> .github/prompts/*.prompt.md'
            Write-Log '  ./install.ps1 -Agent claude       # Claude   -> .claude/commands/*.md'
            Write-Log '  ./install.ps1 -Agent antigravity  # Antigravity -> .agents/skills/<skill>/SKILL.md'
            Write-Log '  ./install.ps1 -Dest <dir>'
            exit 0
        }
    }
}

# ---------------------------------------------------------------------------
# Summary.
# ---------------------------------------------------------------------------
Write-Log ''
Write-Log 'BA-Kit installed.'
foreach ($line in $script:Summary) { if ($line) { Write-Log "  $line" } }
Write-Log ''
Write-Log 'Get started — invoke these skills in your agent:'
Write-Log '  ba.start-project   # scaffolds a project workspace + shared kb/'
Write-Log '  ba.start-task      # scaffolds a task (inputs/artifacts/deliverables/kb)'
Write-Log '  ba.next            # asks the workflow what to run next'
exit 0
