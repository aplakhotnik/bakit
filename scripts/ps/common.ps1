# BA-Kit shared PowerShell helpers
#
# Dot-sourced by the other PowerShell scripts. Mirrors scripts/sh/common.sh:
# path resolution, logging, slugify, active project/task resolution, YAML
# front-matter parsing, and two-level knowledge-base resolution.
#
# Environment:
#   BAKIT_WORKSPACE  Root directory for analyst workspaces (default: <cwd>/workspace)

# --- Resolution -------------------------------------------------------------

# Directory containing this script (.../bakit/scripts/ps).
$script:BakitPsDir = $PSScriptRoot
# Framework root (.../bakit).
$script:BakitHome = (Resolve-Path (Join-Path $PSScriptRoot '..' | Join-Path -ChildPath '..')).Path
# Workspace root where projects/tasks live (honor env var, else <cwd>/workspace).
if ($env:BAKIT_WORKSPACE) {
    $script:BakitWorkspace = $env:BAKIT_WORKSPACE
} else {
    $script:BakitWorkspace = (Join-Path (Get-Location).Path 'workspace')
}
# Active pointer file (convenience only; never a source of record).
$script:BakitActiveFile = (Join-Path $script:BakitWorkspace '.bakit-active')

# --- Logging ----------------------------------------------------------------

function Bakit-Log  { param([string]$Message = '') Write-Output $Message }
function Bakit-Warn { param([string]$Message = '') [Console]::Error.WriteLine("warning: $Message") }
function Bakit-Die  { param([string]$Message = '') [Console]::Error.WriteLine("error: $Message"); exit 1 }

# --- File writing (UTF-8 no BOM, LF line endings) ---------------------------

function Bakit-WriteText {
    param([string]$Path, [string]$Text)
    $normalized = $Text -replace "`r`n", "`n"
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $normalized, $enc)
}

# --- Helpers ----------------------------------------------------------------

# Convert an arbitrary name into a filesystem-safe slug.
function Bakit-Slugify {
    param([string]$Name)
    $s = $Name.ToLowerInvariant()
    $s = $s -replace '[^a-z0-9]+', '-'
    $s = $s -replace '^-+', ''
    $s = $s -replace '-+$', ''
    return $s
}

# Validate that a name produces a non-empty, safe slug. Exits on failure.
function Bakit-RequireSafeName {
    param([string]$Name, [string]$What = 'name')
    if ($Name -match '\.\.' -or $Name.Contains('/') -or $Name.Contains('\')) {
        Bakit-Die "$What contains illegal path characters: '$Name'"
    }
    $slug = Bakit-Slugify $Name
    if ([string]::IsNullOrEmpty($slug)) {
        Bakit-Die "$What '$Name' is empty after sanitising; choose another"
    }
    return $slug
}

# Today's date (ISO).
function Bakit-Today { (Get-Date).ToString('yyyy-MM-dd') }

# Path to a project directory.
function Bakit-ProjectDir { param([string]$Name) return (Join-Path $script:BakitWorkspace $Name) }

# Write the active project/task pointer.
function Bakit-SetActive {
    param([string]$Project, [string]$Task = '')
    New-Item -ItemType Directory -Force -Path $script:BakitWorkspace | Out-Null
    Bakit-WriteText $script:BakitActiveFile ("project=$Project`ntask=$Task`n")
}

# Read a value (project/task) from the active pointer file, or '' if absent.
function Bakit-ActiveValue {
    param([string]$Key)
    if (Test-Path -LiteralPath $script:BakitActiveFile) {
        foreach ($line in (Get-Content -LiteralPath $script:BakitActiveFile)) {
            if ($line -match ('^' + [regex]::Escape($Key) + '=(.*)$')) { return $Matches[1] }
        }
    }
    return ''
}

# Resolve the active project: explicit arg -> pointer -> most-recent dir.
function Bakit-ResolveProject {
    param([string]$Arg = '')
    if (-not [string]::IsNullOrEmpty($Arg)) { return $Arg }
    $p = Bakit-ActiveValue 'project'
    if (-not [string]::IsNullOrEmpty($p) -and (Test-Path -LiteralPath (Bakit-ProjectDir $p))) { return $p }
    if (-not (Test-Path -LiteralPath $script:BakitWorkspace)) { return $null }
    $d = Get-ChildItem -LiteralPath $script:BakitWorkspace -Directory -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($d) { return $d.Name }
    return $null
}

# Resolve the active task within a project: explicit arg -> pointer -> most-recent.
function Bakit-ResolveTask {
    param([string]$Project, [string]$Arg = '')
    $tasksDir = (Join-Path (Bakit-ProjectDir $Project) 'tasks')
    if (-not [string]::IsNullOrEmpty($Arg)) { return $Arg }
    $t = Bakit-ActiveValue 'task'
    if (-not [string]::IsNullOrEmpty($t) -and (Test-Path -LiteralPath (Join-Path $tasksDir $t))) { return $t }
    if (-not (Test-Path -LiteralPath $tasksDir)) { return $null }
    $d = Get-ChildItem -LiteralPath $tasksDir -Directory -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($d) { return $d.Name }
    return $null
}

# Next zero-padded task sequence number for a project (001, 002, ...).
function Bakit-NextTaskSeq {
    param([string]$Project)
    $tasksDir = (Join-Path (Bakit-ProjectDir $Project) 'tasks')
    $max = 0
    if (Test-Path -LiteralPath $tasksDir) {
        Get-ChildItem -LiteralPath $tasksDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.Name -match '^(\d+)-') {
                $n = [int]$Matches[1]
                if ($n -gt $max) { $max = $n }
            }
        }
    }
    return ('{0:D3}' -f ($max + 1))
}

# --- YAML front-matter parsing ---------------------------------------------

# Print the value of a top-level front-matter scalar field, or $null if absent.
function Bakit-FrontmatterField {
    param([string]$File, [string]$Field)
    if (-not (Test-Path -LiteralPath $File)) { return $null }
    $lines = Get-Content -LiteralPath $File
    if ($lines.Count -eq 0 -or $lines[0] -ne '---') { return $null }
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -eq '---') { return $null }
        $idx = $lines[$i].IndexOf(':')
        if ($idx -gt 0) {
            $key = $lines[$i].Substring(0, $idx).Trim()
            if ($key -eq $Field) {
                $val = $lines[$i].Substring($idx + 1).Trim()
                $val = $val -replace '^"', ''
                $val = $val -replace '"$', ''
                return $val
            }
        }
    }
    return $null
}

# Return $true if the file has a parseable front-matter block (--- ... ---).
function Bakit-HasFrontmatter {
    param([string]$File)
    if (-not (Test-Path -LiteralPath $File)) { return $false }
    $lines = Get-Content -LiteralPath $File
    if ($lines.Count -eq 0 -or $lines[0] -ne '---') { return $false }
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -eq '---') { return $true }
    }
    return $false
}

# --- Knowledge base resolution ---------------------------------------------
#
# Two-level knowledge base: a shared project-level kb/ and a per-task kb/.
# Missing or empty knowledge bases MUST NOT be treated as errors — these
# helpers return $null so callers can degrade gracefully.

function Bakit-ProjectKbDir { param([string]$Project) return (Join-Path (Bakit-ProjectDir $Project) 'kb') }

function Bakit-TaskKbDir {
    param([string]$Project, [string]$Task)
    return (Join-Path (Join-Path (Join-Path (Bakit-ProjectDir $Project) 'tasks') $Task) 'kb')
}

# Return the path to a kb/index.md if it exists, else $null.
function Bakit-KbIndex {
    param([string]$KbDir)
    if (-not (Test-Path -LiteralPath $KbDir)) { return $null }
    $idx = (Join-Path $KbDir 'index.md')
    if (-not (Test-Path -LiteralPath $idx)) { return $null }
    return $idx
}

# Return resolved kb index paths for a project/task, project first then task.
# Only existing indexes are returned. Returns $null if none exist.
function Bakit-KbIndexes {
    param([string]$Project, [string]$Task = '')
    $out = @()
    $pIdx = Bakit-KbIndex (Bakit-ProjectKbDir $Project)
    if ($pIdx) { $out += $pIdx }
    if (-not [string]::IsNullOrEmpty($Task)) {
        $tIdx = Bakit-KbIndex (Bakit-TaskKbDir $Project $Task)
        if ($tIdx) { $out += $tIdx }
    }
    if ($out.Count -eq 0) { return $null }
    return $out
}
