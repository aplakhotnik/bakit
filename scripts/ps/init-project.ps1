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

if ($args.Count -lt 1 -or [string]::IsNullOrEmpty([string]$args[0])) {
    Bakit-Die 'usage: init-project.ps1 "<project name>"'
}

$RawName = [string]$args[0]
$Slug = Bakit-RequireSafeName $RawName 'project name'
$ProjectDir = Bakit-ProjectDir $Slug

if (Test-Path -LiteralPath $ProjectDir) {
    Bakit-Die "project '$Slug' already exists at $ProjectDir; choose a different name or run init-task.ps1 to add a task"
}

$Template = (Join-Path $script:BakitHome 'templates/project/project.md')
if (-not (Test-Path -LiteralPath $Template)) { Bakit-Die "project template not found: $Template" }

$KbTemplate = (Join-Path $script:BakitHome 'templates/project/kb-index.md')
if (-not (Test-Path -LiteralPath $KbTemplate)) { Bakit-Die "project kb-index template not found: $KbTemplate" }

$Today = Bakit-Today

New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir 'tasks') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectDir 'kb') | Out-Null

# Populate project.md: front-matter fields + title placeholder.
$content = [System.IO.File]::ReadAllText($Template)
$content = Expand-Field $content '(?m)^id: ""' "id: $Slug"
$content = Expand-Field $content '(?m)^title: ""' ('title: "{0}"' -f $RawName)
$content = Expand-Field $content '(?m)^created: ""' "created: $Today"
$content = Expand-Field $content '(?m)^updated: ""' "updated: $Today"
$content = $content.Replace('{{TITLE}}', $RawName)
Bakit-WriteText (Join-Path $ProjectDir 'project.md') $content

# Seed the shared project-level knowledge base index.
$kb = [System.IO.File]::ReadAllText($KbTemplate)
$kb = Expand-Field $kb '(?m)^id: ""' "id: $Slug-kb"
$kb = Expand-Field $kb '(?m)^title: ""' ('title: "{0}"' -f $RawName)
$kb = Expand-Field $kb '(?m)^created: ""' "created: $Today"
$kb = Expand-Field $kb '(?m)^updated: ""' "updated: $Today"
$kb = $kb.Replace('{{TITLE}}', $RawName)
Bakit-WriteText (Join-Path (Join-Path $ProjectDir 'kb') 'index.md') $kb

Bakit-SetActive $Slug ''

Bakit-Log "Created project '$Slug' at $ProjectDir"
Bakit-Log '  - project.md'
Bakit-Log '  - tasks/'
Bakit-Log '  - kb/index.md   (shared project knowledge base)'
Bakit-Log ''
Bakit-Log "Next: ./scripts/ps/init-task.ps1 `"$Slug`" `"<task name>`""
exit 0
