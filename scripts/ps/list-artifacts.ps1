# BA-Kit: list artifacts and their approval status across a project (or task).
#
# Usage:
#   list-artifacts.ps1 ["<project>"] ["<task>"]
#
# With no arguments, resolves the active project/task. Lists each artifact's
# type and status using the front-matter parser.

. (Join-Path $PSScriptRoot 'common.ps1')

$ProjectArg = ''
$TaskArg = ''
if ($args.Count -ge 1) { $ProjectArg = [string]$args[0] }
if ($args.Count -ge 2) { $TaskArg = [string]$args[1] }

$Project = Bakit-ResolveProject $ProjectArg
if ([string]::IsNullOrEmpty($Project)) { Bakit-Die 'no project found; create one with init-project.ps1' }
$ProjectDir = Bakit-ProjectDir $Project
if (-not (Test-Path -LiteralPath $ProjectDir)) { Bakit-Die "project '$Project' not found at $ProjectDir" }

function List-OneTask {
    param([string]$Task)
    $tdir = (Join-Path (Join-Path $ProjectDir 'tasks') $Task)
    Bakit-Log "Task: $Task"
    $found = $false
    foreach ($dir in 'artifacts', 'deliverables') {
        $ddir = (Join-Path $tdir $dir)
        if (-not (Test-Path -LiteralPath $ddir)) { continue }
        Get-ChildItem -LiteralPath $ddir -Filter '*.md' -File -ErrorAction SilentlyContinue | ForEach-Object {
            $found = $true
            $type = Bakit-FrontmatterField $_.FullName 'type'
            $status = Bakit-FrontmatterField $_.FullName 'status'
            if ([string]::IsNullOrEmpty($type)) { $type = '?' }
            if ([string]::IsNullOrEmpty($status)) { $status = '(no front-matter)' }
            Bakit-Log ('  [{0}] {1,-16} {2}/{3}' -f $status, $type, $dir, $_.Name)
        }
    }
    if (-not $found) { Bakit-Log '  (no artifacts yet)' }
}

Bakit-Log "Project: $Project"
Bakit-Log ''

if (-not [string]::IsNullOrEmpty($TaskArg)) {
    List-OneTask $TaskArg
} else {
    $tasksDir = (Join-Path $ProjectDir 'tasks')
    if (Test-Path -LiteralPath $tasksDir) {
        $any = $false
        Get-ChildItem -LiteralPath $tasksDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $any = $true
            List-OneTask $_.Name
            Bakit-Log ''
        }
        if (-not $any) { Bakit-Log '(no tasks yet — create one with init-task.ps1)' }
    } else {
        Bakit-Log '(no tasks yet — create one with init-task.ps1)'
    }
}

exit 0
