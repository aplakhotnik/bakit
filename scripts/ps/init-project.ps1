# BA-Kit: initialize a new Project workspace.
#
# Usage: init-project.ps1 "<project name>"
#
# Creates: $BAKIT_WORKSPACE/<slug>/project.md (from template), kb/, and a tasks/ dir.
# Collision-safe: refuses to overwrite an existing project.

. (Join-Path $PSScriptRoot 'common.ps1')

# Replace a whole front-matter line via a literal (non-regex) replacement value.
function Expand-Field {
    param([string]$Text, [string]$Pattern, [string]$Value)
    $cb = [System.Text.RegularExpressions.MatchEvaluator] { param($m) $Value }.GetNewClosure()
    return [regex]::Replace($Text, $Pattern, $cb)
}

# --- args: "<name>" [--mode independent|brain] [--upgrade-to-brain] ---
$Mode = 'independent'
$Upgrade = $false
$RawName = $null
for ($i = 0; $i -lt $args.Count; $i++) {
    $a = [string]$args[$i]
    if ($a -eq '--mode') { $i++; $Mode = [string]$args[$i] }
    elseif ($a -like '--mode=*') { $Mode = $a.Substring(7) }
    elseif ($a -eq '--upgrade-to-brain') { $Upgrade = $true }
    elseif ($a -eq '-h' -or $a -eq '--help') {
        Write-Output 'usage: init-project.ps1 "<project name>" [--mode independent|brain]'
        Write-Output '       init-project.ps1 "<project name>" --upgrade-to-brain'
        exit 0
    }
    elseif ($a.StartsWith('-')) { Bakit-Die "unknown option: $a (try --help)" }
    elseif ($null -eq $RawName) { $RawName = $a }
    else { Bakit-Die "unexpected argument: $a" }
}

if ([string]::IsNullOrEmpty([string]$RawName)) {
    Bakit-Die 'usage: init-project.ps1 "<project name>" [--mode independent|brain]'
}
if ($Mode -ne 'independent' -and $Mode -ne 'brain') {
    Bakit-Die "invalid --mode '$Mode' (expected: independent|brain)"
}
if ($Upgrade) { $Mode = 'brain' }

$RawName = [string]$RawName
$Slug = Bakit-RequireSafeName $RawName 'project name'
$ProjectDir = Bakit-ProjectDir $Slug
$Today = Bakit-Today
$BrainDir = (Join-Path $script:BakitHome 'templates/project/brain')

# Fill a template's universal placeholders into a destination file.
function Fill-Tpl($tpl, $dest, $id) {
    $t = [System.IO.File]::ReadAllText($tpl)
    $t = Expand-Field $t '(?m)^id: ""' "id: $id"
    $t = Expand-Field $t '(?m)^title: ""' ('title: "{0}"' -f $RawName)
    $t = Expand-Field $t '(?m)^created: ""' "created: $Today"
    $t = Expand-Field $t '(?m)^updated: ""' "updated: $Today"
    $t = $t.Replace('{{TITLE}}', $RawName)
    Bakit-WriteText $dest $t
}

# Set (or insert) the kb_mode front-matter field in a project.md.
function Set-KbMode($file, $mode) {
    $t = [System.IO.File]::ReadAllText($file)
    if ($t -match '(?m)^kb_mode:') {
        $t = [regex]::Replace($t, '(?m)^kb_mode:.*$', "kb_mode: $mode")
    } else {
        $t = [regex]::Replace($t, '(?m)^(status:.*)$', ('$1' + "`nkb_mode: $mode"))
    }
    Bakit-WriteText $file $t
}

# Scaffold the five brain registers (skip any that already exist — non-destructive).
function Scaffold-BrainRegisters($projectDir, $slug) {
    foreach ($name in @('changelog', 'requirements-register', 'open-questions', 'decisions', 'glossary')) {
        $tpl = (Join-Path $BrainDir "$name.md")
        $dst = (Join-Path (Join-Path $projectDir 'kb') "$name.md")
        if (-not (Test-Path -LiteralPath $tpl)) { Bakit-Die "brain template missing: $tpl" }
        if (Test-Path -LiteralPath $dst) {
            Bakit-Log "  = kb/$name.md (kept)"
        } else {
            Fill-Tpl $tpl $dst "$slug-$name"
            Bakit-Log "  + kb/$name.md"
        }
    }
}

if ($Upgrade) {
    # --- migration: upgrade an existing project to brain mode (idempotent, non-destructive) ---
    if (-not (Test-Path -LiteralPath $ProjectDir -PathType Container)) {
        Bakit-Die "project '$Slug' not found at $ProjectDir (nothing to upgrade)"
    }
    New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir 'kb') | Out-Null
    $pm = (Join-Path $ProjectDir 'project.md')
    if (Test-Path -LiteralPath $pm) { Set-KbMode $pm 'brain' }
    Bakit-Log "Upgraded project '$Slug' to brain mode (existing files kept):"
    Scaffold-BrainRegisters $ProjectDir $Slug
    Bakit-Log ''
    Bakit-Log 'The project kb/ is now the brain. Tasks promote digests here (constitution §11).'
    exit 0
}

# --- fresh project ---
if (Test-Path -LiteralPath $ProjectDir) {
    Bakit-Die "project '$Slug' already exists at $ProjectDir; choose a different name or run init-task.ps1 to add a task"
}

$Template = (Join-Path $script:BakitHome 'templates/project/project.md')
if (-not (Test-Path -LiteralPath $Template)) { Bakit-Die "project template not found: $Template" }

if ($Mode -eq 'brain') {
    $KbTemplate = (Join-Path $BrainDir 'kb-index.md')
} else {
    $KbTemplate = (Join-Path $script:BakitHome 'templates/project/kb-index.md')
}
if (-not (Test-Path -LiteralPath $KbTemplate)) { Bakit-Die "project kb-index template not found: $KbTemplate" }

New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir 'tasks') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir 'kb') | Out-Null

Fill-Tpl $Template (Join-Path $ProjectDir 'project.md') $Slug
Set-KbMode (Join-Path $ProjectDir 'project.md') $Mode
Fill-Tpl $KbTemplate (Join-Path (Join-Path $ProjectDir 'kb') 'index.md') "$Slug-kb"

Bakit-SetActive $Slug ''

Bakit-Log "Created project '$Slug' ($Mode mode) at $ProjectDir"
Bakit-Log '  - project.md'
Bakit-Log '  - tasks/'
Bakit-Log '  - kb/index.md   (shared project knowledge base)'
if ($Mode -eq 'brain') {
    Scaffold-BrainRegisters $ProjectDir $Slug
    Bakit-Log ''
    Bakit-Log 'Brain mode: the project kb/ is the single source of truth. Tasks ground on it and'
    Bakit-Log 'promote digests back (constitution §11), non-destructively (§12).'
}
Bakit-Log ''
Bakit-Log "Next: ./scripts/ps/init-task.ps1 `"$Slug`" `"<task name>`""
exit 0
