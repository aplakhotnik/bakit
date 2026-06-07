# BA-Kit: initialize a new Task within a project.
#
# Usage: init-task.ps1 "<project name>" "<task name>"
#
# Creates: $BAKIT_WORKSPACE/<project>/tasks/NNN-<task-slug>/{inputs,artifacts,deliverables,kb}
# Sequential numbering; collision-safe; updates the .bakit-active pointer.

. (Join-Path $PSScriptRoot 'common.ps1')

function Expand-Field {
    param([string]$Text, [string]$Pattern, [string]$Value)
    $cb = [System.Text.RegularExpressions.MatchEvaluator] { param($m) $Value }.GetNewClosure()
    return [regex]::Replace($Text, $Pattern, $cb)
}

if ($args.Count -lt 2 -or [string]::IsNullOrEmpty([string]$args[0]) -or [string]::IsNullOrEmpty([string]$args[1])) {
    Bakit-Die 'usage: init-task.ps1 "<project name>" "<task name>"'
}

$ProjectSlug = Bakit-RequireSafeName ([string]$args[0]) 'project name'
$TaskRaw = [string]$args[1]
$TaskSlug = Bakit-RequireSafeName $TaskRaw 'task name'
$ProjectDir = Bakit-ProjectDir $ProjectSlug

if (-not (Test-Path -LiteralPath $ProjectDir)) {
    Bakit-Die "project '$ProjectSlug' does not exist at $ProjectDir; create it first with init-project.ps1"
}

$Seq = Bakit-NextTaskSeq $ProjectSlug
$TaskName = "$Seq-$TaskSlug"
$TaskDir = (Join-Path (Join-Path $ProjectDir 'tasks') $TaskName)

if (Test-Path -LiteralPath $TaskDir) {
    Bakit-Die "task '$TaskName' already exists at $TaskDir; choose a different name"
}

foreach ($sub in 'inputs', 'artifacts', 'deliverables', 'kb') {
    New-Item -ItemType Directory -Force -Path (Join-Path $TaskDir $sub) | Out-Null
}

# Add a small README in inputs/ to guide the analyst.
$readmeTemplate = @'
# Inputs for task {0}

Place raw source material here (notes, documents, transcripts) as text-based files.
Skills such as `ba.specify-requirements` and `ba.analyze-docs` read from this folder.
'@
$readme = ($readmeTemplate -f $TaskName) + "`n"
Bakit-WriteText (Join-Path (Join-Path $TaskDir 'inputs') 'README.md') $readme

# Seed the task-level knowledge base index from the template.
$KbTemplate = (Join-Path $script:BakitHome 'templates/task/kb-index.md')
$Today = Bakit-Today
if (Test-Path -LiteralPath $KbTemplate) {
    $kb = [System.IO.File]::ReadAllText($KbTemplate)
    $kb = Expand-Field $kb '(?m)^id: ""' "id: $TaskName-kb"
    $kb = Expand-Field $kb '(?m)^title: ""' ('title: "{0}"' -f $TaskRaw)
    $kb = Expand-Field $kb '(?m)^created: ""' "created: $Today"
    $kb = Expand-Field $kb '(?m)^updated: ""' "updated: $Today"
    $kb = $kb.Replace('{{TITLE}}', $TaskRaw)
    Bakit-WriteText (Join-Path (Join-Path $TaskDir 'kb') 'index.md') $kb
} else {
    Bakit-Warn "task kb-index template not found: $KbTemplate (kb/ left without an index)"
}

Bakit-SetActive $ProjectSlug $TaskName

Bakit-Log "Created task '$TaskName' in project '$ProjectSlug'"
Bakit-Log "  $TaskDir/"
Bakit-Log '    - inputs/        (put source material here)'
Bakit-Log '    - artifacts/     (skill outputs land here)'
Bakit-Log '    - deliverables/  (rendered outputs, e.g. Confluence pages)'
Bakit-Log '    - kb/index.md    (task-scoped knowledge base)'
Bakit-Log ''
Bakit-Log "Active task set to: $ProjectSlug / $TaskName"
exit 0
