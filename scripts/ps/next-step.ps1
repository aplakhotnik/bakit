# BA-Kit: suggest the next workflow step for the active (or named) task.
#
# Usage:
#   next-step.ps1 [-Workflow <manifest>] [<project>] [<task>]
#
# Reads the ordered chain from a workflow manifest (default bakit/workflow.md; pass
# -Workflow <relative-manifest> to read an alternate manifest such as
# workflow-discovery.md, resolved relative to BAKIT_HOME) and the current workspace
# state, then prints the next runnable skill and any unmet approval gate. It never
# modifies anything. A missing manifest or task is reported, not fatal-crashed.
#
# Exit codes:
#   0  a suggestion (next step, gate, or "complete") was printed
#   1  could not resolve a project/task or the workflow manifest

. (Join-Path $PSScriptRoot 'common.ps1')

$Check = (Join-Path $PSScriptRoot 'check-artifact.ps1')

# Parse options. -Workflow / --workflow selects an alternate manifest (relative to
# BAKIT_HOME); remaining positional args are [<project>] [<task>], preserving behavior.
$WorkflowRel = 'workflow.md'
$positional = @()
$i = 0
while ($i -lt $args.Count) {
    $a = [string]$args[$i]
    if ($a -eq '-Workflow' -or $a -eq '--workflow') {
        if ($i + 1 -ge $args.Count) { Bakit-Die '-Workflow requires a manifest path' }
        $WorkflowRel = [string]$args[$i + 1]; $i += 2; continue
    }
    elseif ($a -like '--workflow=*') { $WorkflowRel = $a.Substring('--workflow='.Length); $i += 1; continue }
    else { $positional += $a; $i += 1 }
}

$Workflow = (Join-Path $script:BakitHome $WorkflowRel)

# Capture a check-artifact.ps1 exit code.
function Check-Ec {
    param([string[]]$CheckArgs)
    & $Check @CheckArgs 2>$null 1>$null
    return $LASTEXITCODE
}

if (-not (Test-Path -LiteralPath $Workflow)) { Bakit-Warn "workflow manifest not found: $Workflow"; exit 1 }

$ProjectArg = ''
$TaskArg = ''
if ($positional.Count -ge 1) { $ProjectArg = [string]$positional[0] }
if ($positional.Count -ge 2) { $TaskArg = [string]$positional[1] }

$Project = Bakit-ResolveProject $ProjectArg
if ([string]::IsNullOrEmpty($Project)) { Bakit-Warn 'no project found; run ba.start-project first'; exit 1 }
$Task = Bakit-ResolveTask $Project $TaskArg
if ([string]::IsNullOrEmpty($Task)) { Bakit-Warn "no task found in project '$Project'; run ba.start-task first"; exit 1 }
$TaskDir = (Join-Path (Join-Path (Bakit-ProjectDir $Project) 'tasks') $Task)

if (-not (Test-Path -LiteralPath $TaskDir)) { Bakit-Warn "task directory not found: $TaskDir"; exit 1 }

# Extract the machine-readable rows from between the workflow markers.
$rows = @()
$inBlock = $false
foreach ($line in (Get-Content -LiteralPath $Workflow)) {
    if ($line -match '<!-- BAKIT-WORKFLOW-START -->') { $inBlock = $true; continue }
    if ($line -match '<!-- BAKIT-WORKFLOW-END -->') { $inBlock = $false }
    if ($inBlock -and $line -match '^[0-9]+\|') { $rows += $line }
}

if ($rows.Count -eq 0) { Bakit-Warn "no workflow steps found in $Workflow"; exit 1 }

# Find the skill that produces a given artifact path (for nicer gate messages).
function Producer-Of {
    param([string]$Want)
    foreach ($r in $rows) {
        $f = $r.Split('|')
        if ($f.Count -ge 3 -and $f[2] -eq $Want) { return $f[1] }
    }
    return ''
}

# Is a step's output already present?
function Is-Produced {
    param([string]$Produces)
    $path = (Join-Path $TaskDir $Produces)
    if ($Produces -eq 'deliverables') {
        if (Test-Path -LiteralPath $path) {
            $md = Get-ChildItem -LiteralPath $path -Filter '*.md' -File -ErrorAction SilentlyContinue
            if ($md) { return $true }
        }
        return $false
    }
    return (Test-Path -LiteralPath $path)
}

Bakit-Log "Project: $Project"
Bakit-Log "Task:    $Task"
Bakit-Log ''

# Determine the furthest-progressed step (highest order whose output exists).
$lastDone = 0
$maxOrder = 0
foreach ($r in $rows) {
    $f = $r.Split('|')
    if ($f.Count -lt 5) { continue }
    $order = [int]$f[0]
    if ($order -gt $maxOrder) { $maxOrder = $order }
    if (Is-Produced $f[2]) {
        if ($order -gt $lastDone) { $lastDone = $order }
    }
}

if ($lastDone -ge $maxOrder) {
    Bakit-Log 'All workflow steps have produced output.'
    Bakit-Log '  Review/approve artifacts and render deliverables as needed.'
    exit 0
}

$nextOrder = $lastDone + 1

# Read the next step's row and evaluate its approval gate.
$nextRow = ''
foreach ($r in $rows) {
    $f = $r.Split('|')
    if ([int]$f[0] -eq $nextOrder) { $nextRow = $r; break }
}
if ([string]::IsNullOrEmpty($nextRow)) { Bakit-Log 'No further workflow steps defined.'; exit 0 }

$fields = $nextRow.Split('|')
$skill = $fields[1]
$produces = $fields[2]
$requires = $fields[3]
$gate = $fields[4]

if ($requires -ne 'none' -and -not [string]::IsNullOrEmpty($requires)) {
    $reqPath = (Join-Path $TaskDir $requires)
    if (-not (Test-Path -LiteralPath $reqPath)) {
        $prod = Producer-Of $requires
        if ([string]::IsNullOrEmpty($prod)) { $prod = 'the producing skill' }
        Bakit-Log "Blocked: $skill needs '$requires' first."
        Bakit-Log "  > Run $prod to create it, then approve it."
        exit 0
    }
    $ec = Check-Ec @('--require-approved', $reqPath)
    if ($ec -ne 0) {
        Bakit-Log "Gate not met: $skill requires '$requires' to be approved."
        Bakit-Log "  Review and set 'status: approved' in $requires, then run $skill."
        exit 0
    }
}

Bakit-Log "Next: $skill"
Bakit-Log "  > Produces $produces"
exit 0
