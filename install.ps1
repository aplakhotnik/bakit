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
    [switch]$Check,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

$BakitHome = $PSScriptRoot
$SkillsDir = (Join-Path $BakitHome 'skills')

# Upgrade/backup state (feature 009).
$script:Modified    = @()   # install-relative paths that differ (preview)
$script:Report      = @()   # change-report rows: class/label/name
$script:BackupDir   = ''    # lazily-created per-run backup folder (absolute)
$script:BackupRoot  = ''    # root under which .bakit-backup/ lives
$script:BackupCount = 0     # number of files backed up this run
$script:Label       = ''    # human label of the target currently being scanned

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
  -Check         Dry-run: print the pre-upgrade preview only and make no
                 changes (no files written, no backups, no .gitignore edits).
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
# Upgrade/backup helpers (feature 009).
# ---------------------------------------------------------------------------

# Content comparison, CRLF-normalized. Returns $true when EQUAL, $false when
# they differ (or the installed file is absent). Pass -SourceText to compare
# against would-write content instead of a file.
function Test-SameContent {
    param([string]$Installed, [string]$Source = '', $SourceText)
    if (-not (Test-Path -LiteralPath $Installed -PathType Leaf)) { return $false }
    $a = (Get-Content -Raw -LiteralPath $Installed) -replace "`r", ''
    if ($PSBoundParameters.ContainsKey('SourceText')) {
        $b = [string]$SourceText -replace "`r", ''
    } else {
        $b = (Get-Content -Raw -LiteralPath $Source) -replace "`r", ''
    }
    return ($a -eq $b)
}

# Install-relative path of <Path> under <Root> (mirrors layout in backups).
function Get-RelPath {
    param([string]$Root, [string]$Path)
    $p = ($Path -replace '\\', '/')
    foreach ($base in @($Root, $env:PWD, (Get-Location).Path)) {
        if ([string]::IsNullOrEmpty($base)) { continue }
        $b = ($base -replace '\\', '/').TrimEnd('/')
        if ($p.StartsWith("$b/")) { return $p.Substring($b.Length + 1) }
    }
    return $p.TrimStart('/')
}

# Idempotently ensure .bakit-backup/ is git-ignored in the workspace root.
function Set-GitIgnore {
    param([string]$Root)
    $gi = Join-Path $Root '.gitignore'
    if (Test-Path -LiteralPath $gi) {
        if ((Get-Content -LiteralPath $gi) -contains '.bakit-backup/') { return }
        try { Add-Content -LiteralPath $gi -Value '.bakit-backup/' } catch { }
    } else {
        try { Set-Content -LiteralPath $gi -Value '.bakit-backup/' } catch { }
    }
}

# Lazily create the single per-run backup folder under <Root>/.bakit-backup/.
# Colon-free UTC timestamp; appends -2/-3 on collision. Fail-safe: aborts
# (without overwriting) if the folder cannot be created.
function New-BackupDir {
    param([string]$Root)
    if ($script:BackupDir) { return }
    $ts = if ($env:BAKIT_BACKUP_TS) { $env:BAKIT_BACKUP_TS } else { [DateTime]::UtcNow.ToString("yyyyMMdd'T'HHmmss'Z'") }
    $cand = Join-Path $Root (Join-Path '.bakit-backup' $ts)
    $n = 2
    while (Test-Path -LiteralPath $cand) { $cand = Join-Path $Root (Join-Path '.bakit-backup' "$ts-$n"); $n++ }
    try { New-Item -ItemType Directory -Force -Path $cand -ErrorAction Stop | Out-Null }
    catch { Write-Die "cannot create backup directory under $Root/.bakit-backup (aborting without overwriting tuned files)" }
    $script:BackupDir = $cand
    $script:BackupRoot = $Root
    Set-GitIgnore $Root
}

# Back up an existing installed file (verbatim) before overwrite/removal.
function Backup-File {
    param([string]$Root, [string]$Path)
    New-BackupDir $Root
    $rel = Get-RelPath $Root $Path
    $dst = Join-Path $script:BackupDir $rel
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dst) | Out-Null
    Copy-Item -LiteralPath $Path -Destination $dst -Force
    $script:BackupCount++
}

function Add-Report   { param([string]$Class, [string]$Label, [string]$Name) $script:Report += [pscustomobject]@{ class = $Class; label = $Label; name = $Name } }
function Add-Modified { param([string]$Path) $script:Modified += $Path }

# ---------------------------------------------------------------------------
# Flat-file install (copilot / claude / cursor / generic).
#   Mode = preview (compare only, no writes) | install (back up + write)
# ---------------------------------------------------------------------------
function Install-Flat {
    param([string]$Mode, [string]$DestDir, [string]$Ext)
    $root = (Get-Location).Path
    if ($Mode -ne 'preview') {
        New-Item -ItemType Directory -Force -Path $DestDir | Out-Null
        Write-Log "Installing BA skills into: $DestDir"
    }
    Get-ChildItem -LiteralPath $SkillsDir -Filter 'ba.*.md' -File -ErrorAction SilentlyContinue | ForEach-Object {
        $base = $_.BaseName
        $target = Join-Path $DestDir "$base$Ext"
        if (-not (Test-Path -LiteralPath $target)) { $cls = 'added' }
        elseif (Test-SameContent $target $_.FullName) { $cls = 'unchanged' }
        else { $cls = 'backed-up' }
        if ($Mode -eq 'preview') {
            if ($cls -eq 'backed-up') { Add-Modified (Get-RelPath $root $target) }
            return
        }
        if ($cls -eq 'backed-up') { Backup-File $root $target }
        Copy-Item -LiteralPath $_.FullName -Destination $target -Force
        Add-Report $cls $script:Label $base
        Write-Log "  + $base$Ext"
    }
    if ($Mode -eq 'preview') { return }
    # Stale detection: installed ba.* commands matching no current package skill.
    if (Test-Path -LiteralPath $DestDir) {
        Get-ChildItem -LiteralPath $DestDir -Filter 'ba.*' -File -ErrorAction SilentlyContinue | ForEach-Object {
            $ibase = $_.Name
            if ($ibase.EndsWith($Ext)) { $sk = $ibase.Substring(0, $ibase.Length - $Ext.Length) } else { $sk = $ibase }
            if (-not (Test-Path -LiteralPath (Join-Path $SkillsDir "$sk.md"))) { Add-Report 'stale' $script:Label $sk }
        }
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
#   Mode = preview (compare only, no writes) | install (back up + rebuild)
# ---------------------------------------------------------------------------
function Install-Antigravity {
    param([string]$Mode, [string]$ScopeVal)
    $base = Get-AntigravitySkillsDir $ScopeVal
    if ($ScopeVal -eq 'global') { $root = Join-Path (Get-UserHome) '.gemini/config' } else { $root = (Get-Location).Path }
    if ($Mode -ne 'preview') {
        New-Item -ItemType Directory -Force -Path $base | Out-Null
        Write-Log "Installing BA skills (Antigravity, $ScopeVal) into: $base"
    }
    Get-ChildItem -LiteralPath $SkillsDir -Filter 'ba.*.md' -File -ErrorAction SilentlyContinue | ForEach-Object {
        $name = $_.BaseName
        $folder = Join-Path $base $name

        $desc = Get-SkillSummary $_.FullName
        if ([string]::IsNullOrEmpty($desc)) { $desc = Get-FirstSentence (Get-SkillBody $_.FullName) }
        $escDesc = $desc -replace '"', '\"'
        $body = Get-SkillBody $_.FullName
        # Would-write SKILL.md (captured so preview, compare, and write all use
        # byte-identical content).
        $skillMd = "---`nname: $name`ndescription: `"$escDesc`"`n---`n$body`n"

        $content = Get-Content -Raw -LiteralPath $_.FullName
        $shRefs  = [regex]::Matches($content, 'scripts/sh/[A-Za-z0-9._-]+\.sh')   | ForEach-Object { $_.Value } | Sort-Object -Unique
        $psRefs  = [regex]::Matches($content, 'scripts/ps/[A-Za-z0-9._-]+\.ps1')  | ForEach-Object { $_.Value } | Sort-Object -Unique
        $tplRefs = [regex]::Matches($content, 'templates/[A-Za-z0-9._/-]+\.md')   | ForEach-Object { $_.Value } | Sort-Object -Unique

        $existed = Test-Path -LiteralPath $folder
        $tuned = $false

        # Compare + back up the existing SKILL.md and any bundled files BEFORE the
        # folder is rebuilt, so tuned content is never silently lost.
        $smd = Join-Path $folder 'SKILL.md'
        if (Test-Path -LiteralPath $smd) {
            if (-not (Test-SameContent $smd -SourceText $skillMd)) {
                $tuned = $true
                if ($Mode -eq 'preview') { Add-Modified (Get-RelPath $root $smd) } else { Backup-File $root $smd }
            }
        }
        foreach ($r in $shRefs) {
            $bf = Join-Path $folder (Join-Path 'scripts/sh' (Split-Path -Leaf $r))
            $src = Join-Path $BakitHome $r
            if ((Test-Path -LiteralPath $bf) -and (Test-Path -LiteralPath $src) -and (-not (Test-SameContent $bf $src))) {
                $tuned = $true
                if ($Mode -eq 'preview') { Add-Modified (Get-RelPath $root $bf) } else { Backup-File $root $bf }
            }
        }
        if ($shRefs) {
            $bf = Join-Path $folder 'scripts/sh/common.sh'; $src = Join-Path $BakitHome 'scripts/sh/common.sh'
            if ((Test-Path -LiteralPath $bf) -and (Test-Path -LiteralPath $src) -and (-not (Test-SameContent $bf $src))) {
                $tuned = $true
                if ($Mode -eq 'preview') { Add-Modified (Get-RelPath $root $bf) } else { Backup-File $root $bf }
            }
        }
        foreach ($r in $psRefs) {
            $bf = Join-Path $folder (Join-Path 'scripts/ps' (Split-Path -Leaf $r))
            $src = Join-Path $BakitHome $r
            if ((Test-Path -LiteralPath $bf) -and (Test-Path -LiteralPath $src) -and (-not (Test-SameContent $bf $src))) {
                $tuned = $true
                if ($Mode -eq 'preview') { Add-Modified (Get-RelPath $root $bf) } else { Backup-File $root $bf }
            }
        }
        if ($psRefs) {
            $bf = Join-Path $folder 'scripts/ps/common.ps1'; $src = Join-Path $BakitHome 'scripts/ps/common.ps1'
            if ((Test-Path -LiteralPath $bf) -and (Test-Path -LiteralPath $src) -and (-not (Test-SameContent $bf $src))) {
                $tuned = $true
                if ($Mode -eq 'preview') { Add-Modified (Get-RelPath $root $bf) } else { Backup-File $root $bf }
            }
        }
        foreach ($r in $tplRefs) {
            $bf = Join-Path $folder (Join-Path 'resources' $r)
            $src = Join-Path $BakitHome $r
            if ((Test-Path -LiteralPath $bf) -and (Test-Path -LiteralPath $src) -and (-not (Test-SameContent $bf $src))) {
                $tuned = $true
                if ($Mode -eq 'preview') { Add-Modified (Get-RelPath $root $bf) } else { Backup-File $root $bf }
            }
        }

        if ($Mode -eq 'preview') { return }

        # Idempotent reconciliation: rebuild the folder so no stale files remain.
        if (Test-Path -LiteralPath $folder) { Remove-Item -Recurse -Force -LiteralPath $folder }
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
        Write-TextFile $smd $skillMd

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
        if (-not $existed) { $cls = 'added' } elseif ($tuned) { $cls = 'backed-up' } else { $cls = 'unchanged' }
        Add-Report $cls $script:Label $name
        Write-Log ("  + {0}/ ({1})" -f $name, ($tags -join ', '))
    }
}

# ---------------------------------------------------------------------------
# Per-target dispatch + summary line.
# ---------------------------------------------------------------------------
$script:Summary = @()
$script:Resolved = @()

function Add-Summary  { param([string]$Line) $script:Summary += $Line }

# Collect a resolved target for the two-pass (preview then install) run.
function Add-Resolved {
    param([string]$Key, [string]$ScopeVal, [string]$DestDir)
    $script:Resolved += [pscustomobject]@{ key = $Key; scope = $ScopeVal; dest = $DestDir }
}

# Scan a single resolved target in the given mode (preview|install).
function Invoke-ScanOne {
    param([string]$Mode, [string]$Key, [string]$ScopeVal = 'workspace', [string]$DestDir = '')
    if ($Key) {
        $script:Label = Get-AgentLabel $Key
        if ((Get-AgentLayout $Key) -eq 'skill-folder') {
            Install-Antigravity $Mode $ScopeVal
            if ($Mode -eq 'install') {
                $loc = Get-AntigravitySkillsDir $ScopeVal
                Add-Summary "Installed for $($script:Label) ($ScopeVal): $loc/  -> open the workspace in Antigravity and invoke a skill, e.g. ba.start-project"
            }
        } else {
            if (-not [string]::IsNullOrEmpty($DestDir)) { $dst = $DestDir } else { $dst = (Join-Path (Get-Location).Path (Get-AgentDest $Key)) }
            if (Test-CopilotDest $dst) { $ext = '.prompt.md' } else { $ext = (Get-AgentExt $Key) }
            Install-Flat $Mode $dst $ext
            if ($Mode -eq 'install') {
                if ($Key -eq 'copilot') {
                    Add-Summary "Installed for $($script:Label): $dst/  -> reload VS Code, then type / in Copilot Chat, e.g. /ba.start-project"
                } else {
                    Add-Summary "Installed for $($script:Label): $dst/  -> open the workspace in your agent and invoke a skill, e.g. /ba.start-project"
                }
            }
        }
    } else {
        # Bare -Dest (no agent): flat-file install to the given directory.
        $script:Label = 'BA skills'
        if (Test-CopilotDest $DestDir) { $ext = '.prompt.md' } else { $ext = '.md' }
        Install-Flat $Mode $DestDir $ext
        if ($Mode -eq 'install') { Add-Summary "Installed BA skills into: $DestDir/" }
    }
}

# Iterate all resolved targets in one mode.
function Invoke-Pass {
    param([string]$Mode)
    foreach ($t in $script:Resolved) { Invoke-ScanOne $Mode $t.key $t.scope $t.dest }
}

# Print the pre-upgrade preview (safe vs. list of files that will be backed up).
function Write-Preview {
    Write-Log 'Pre-upgrade preview:'
    if (-not $script:Modified -or $script:Modified.Count -eq 0) {
        Write-Log '  Safe to upgrade — no local modifications detected. Nothing will be backed up.'
    } else {
        Write-Log '  Local modifications detected — these files differ from the package version'
        Write-Log '  and will be backed up before upgrade:'
        foreach ($f in $script:Modified) { if ($f) { Write-Log "    - $f" } }
        Write-Log '  Backups will be written under: .bakit-backup/<timestamp>/'
    }
    Write-Log ''
}

# Print the end-of-run change report (every command in exactly one category).
function Write-Report {
    if (-not $script:Report -or $script:Report.Count -eq 0) { return }
    Write-Log ''
    Write-Log 'Change report:'
    foreach ($row in $script:Report) { Write-Log ("  {0}: {1} ({2})" -f $row.class, $row.name, $row.label) }
    if ($script:BackupCount -gt 0) {
        Write-Log ''
        Write-Log "Backed up $($script:BackupCount) file(s) to: $($script:BackupDir)"
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
    Add-Resolved $Agent $scopeVal ''
} elseif ($Dest) {
    Add-Resolved '' $scopeVal $Dest
} else {
    $menuActive = $false
    if (-not [Console]::IsInputRedirected) { $menuActive = $true }
    elseif (-not [string]::IsNullOrEmpty($env:BAKIT_ASSUME_MENU)) { $menuActive = $true }

    if ($menuActive) {
        $selected = Invoke-Menu
        $scopeVal = if ($script:Scope) { $script:Scope } else { 'workspace' }
        foreach ($k in $selected) { if (Test-ValidAgent $k) { Add-Resolved $k $scopeVal '' } }
    } else {
        $first = @(Get-DetectedAgents) | Select-Object -First 1
        if ($first) {
            Add-Resolved $first $scopeVal ''
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
# Pre-upgrade preview (always), then dry-run exit or real install.
# ---------------------------------------------------------------------------
Invoke-Pass 'preview'
Write-Preview
if ($Check) {
    Write-Log 'Dry-run (-Check): no changes were made.'
    exit 0
}
Invoke-Pass 'install'

# ---------------------------------------------------------------------------
# Summary.
# ---------------------------------------------------------------------------
Write-Log ''
Write-Log 'BA-Kit installed.'
foreach ($line in $script:Summary) { if ($line) { Write-Log "  $line" } }
Write-Report
Write-Log ''
Write-Log 'Get started — invoke these skills in your agent:'
Write-Log '  ba.start-project   # scaffolds a project workspace + shared kb/'
Write-Log '  ba.start-task      # scaffolds a task (inputs/artifacts/deliverables/kb)'
Write-Log '  ba.next            # asks the workflow what to run next'
exit 0
