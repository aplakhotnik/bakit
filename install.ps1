# BA-Kit installer / bootstrap (PowerShell)
#
# Maps the agent-agnostic BA skills into a target AI agent's prompt directory so
# they can be invoked as commands. Mirrors install.sh (minus the Unix exec bit).
#
# Usage:
#   ./install.ps1 [-Agent <copilot|claude|cursor|generic>] [-Dest <dir>]
#
# Behavior:
#   - With no arguments, auto-detects a known agent prompt directory under the
#     current working directory; falls back to printing manual instructions.
#   - -Dest overrides the destination directory for skill files.
#
# This script never performs network calls and is safe to re-run (idempotent).

[CmdletBinding()]
param(
    [string]$Agent = '',
    [string]$Dest = '',
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

$BakitHome = $PSScriptRoot
$SkillsDir = (Join-Path $BakitHome 'skills')

function Write-Log  { param([string]$Message = '') Write-Output $Message }
function Write-Warn  { param([string]$Message = '') [Console]::Error.WriteLine("warning: $Message") }
function Write-Die   { param([string]$Message = '') [Console]::Error.WriteLine("error: $Message"); exit 1 }

# Write text as UTF-8 (no BOM) with LF line endings.
function Write-TextFile {
    param([string]$Path, [string]$Text)
    $normalized = $Text -replace "`r`n", "`n"
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $normalized, $enc)
}

if ($Help) {
    Get-Content -LiteralPath $PSCommandPath | Select-Object -Skip 1 -First 13 |
        ForEach-Object { $_ -replace '^# ?', '' }
    exit 0
}

# 1. (No Unix exec-bit step on Windows — scripts are invoked via `pwsh`.)

# 2. Resolve the destination directory for skill prompt files.
function Resolve-Dest {
    $cwd = (Get-Location).Path
    if (-not [string]::IsNullOrEmpty($Dest)) { return $Dest }
    switch ($Agent) {
        'copilot' { return (Join-Path $cwd '.github/prompts') }
        'claude'  { return (Join-Path $cwd '.claude/commands') }
        'cursor'  { return (Join-Path $cwd '.cursor/commands') }
        'generic' { return (Join-Path $cwd '.bakit/skills') }
        ''        { }
        default   { Write-Die "unknown agent: $Agent" }
    }
    # Auto-detect from existing directories (precedence: copilot -> claude -> cursor).
    if ((Test-Path -LiteralPath (Join-Path $cwd '.github/prompts')) -or (Test-Path -LiteralPath (Join-Path $cwd '.github'))) {
        return (Join-Path $cwd '.github/prompts')
    }
    if (Test-Path -LiteralPath (Join-Path $cwd '.claude')) { return (Join-Path $cwd '.claude/commands') }
    if (Test-Path -LiteralPath (Join-Path $cwd '.cursor')) { return (Join-Path $cwd '.cursor/commands') }
    return $null
}

# True if a destination path is a VS Code Copilot prompts directory.
function Is-CopilotDest {
    param([string]$Path)
    $norm = $Path -replace '\\', '/'
    $norm = $norm.TrimEnd('/')
    return $norm.EndsWith('.github/prompts')
}

$dest = Resolve-Dest

if ($dest) {
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Write-Log "Installing BA skills into: $dest"
    # VS Code Copilot registers '*.prompt.md' in .github/prompts as slash commands.
    # Other agents use plain '*.md' in their command dirs.
    if (Is-CopilotDest $dest) { $ext = '.prompt.md' } else { $ext = '.md' }

    Get-ChildItem -LiteralPath $SkillsDir -Filter 'ba.*.md' -File -ErrorAction SilentlyContinue | ForEach-Object {
        $base = $_.BaseName
        $target = (Join-Path $dest "$base$ext")
        Copy-Item -LiteralPath $_.FullName -Destination $target -Force
        Write-Log "  + $base$ext"
    }

    # Enable prompt files for the workspace on a Copilot install (safe-merge:
    # never clobber an existing settings.json; if the key exists, leave it).
    if (Is-CopilotDest $dest) {
        $norm = ($dest -replace '\\', '/').TrimEnd('/')
        $wsRoot = $norm.Substring(0, $norm.Length - '.github/prompts'.Length).TrimEnd('/')
        if ([string]::IsNullOrEmpty($wsRoot)) { $wsRoot = '.' }
        $settings = (Join-Path (Join-Path $wsRoot '.vscode') 'settings.json')
        if (-not (Test-Path -LiteralPath $settings)) {
            New-Item -ItemType Directory -Force -Path (Join-Path $wsRoot '.vscode') | Out-Null
            Write-TextFile $settings "{`n  `"chat.promptFiles`": true`n}`n"
            Write-Log ''
            Write-Log "Enabled prompt files for this workspace: $settings"
        } elseif (Select-String -LiteralPath $settings -Pattern '"chat.promptFiles"' -Quiet) {
            Write-Log ''
            Write-Log "Prompt files already configured in $settings"
        } else {
            Write-Log ''
            Write-Warn "Add '`"chat.promptFiles`": true' to $settings so the skills appear as /commands."
        }
    }

    Write-Log ''
    Write-Log 'BA-Kit installed. Reload VS Code (Developer: Reload Window), trust the folder'
    Write-Log "if prompted, then type '/' in Copilot Chat and pick a skill, e.g. /ba.start-project."
} else {
    Write-Warn 'Could not auto-detect an agent prompt directory.'
    Write-Log ''
    Write-Log "BA skills live in: $SkillsDir"
    Write-Log 'Re-run targeting your agent so they install to the right place:'
    Write-Log '  ./install.ps1 -Agent copilot   # VS Code  -> .github/prompts/*.prompt.md'
    Write-Log '  ./install.ps1 -Agent claude    # Claude   -> .claude/commands/*.md'
    Write-Log '  ./install.ps1 -Agent cursor    # Cursor   -> .cursor/commands/*.md'
    Write-Log '  ./install.ps1 -Dest <your-agent-prompt-dir>'
}

Write-Log ''
Write-Log 'Get started (agent-driven — just invoke these skills in your agent):'
Write-Log '  ba.start-project   # scaffolds a project workspace + shared kb/'
Write-Log '  ba.start-task      # scaffolds a task (inputs/artifacts/deliverables/kb)'
Write-Log '  ba.next            # asks the workflow what to run next'
exit 0
