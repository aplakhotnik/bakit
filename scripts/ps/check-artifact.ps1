# BA-Kit: validate an artifact's YAML front-matter and approval status.
#
# Usage:
#   check-artifact.ps1 <artifact.md>
#   check-artifact.ps1 --require-approved <artifact.md>
#
# Exit codes:
#   0  valid (and, with --require-approved, status is 'approved')
#   1  invalid front-matter / missing required fields
#   2  valid but status is not 'approved' (only with --require-approved)
#
# Prints the resolved status on success so callers/skills can gate on it.

. (Join-Path $PSScriptRoot 'common.ps1')

$RequireApproved = $false
$File = ''

foreach ($a in $args) {
    $s = [string]$a
    if ($s -eq '--require-approved') { $RequireApproved = $true }
    elseif ($s -eq '-h' -or $s -eq '--help') {
        Bakit-Log 'Usage: check-artifact.ps1 [--require-approved] <artifact.md>'
        exit 0
    }
    elseif ($s.StartsWith('-')) { Bakit-Die "unknown option: $s" }
    else { $File = $s }
}

if ([string]::IsNullOrEmpty($File)) { Bakit-Die 'no artifact path given (try --help)' }
if (-not (Test-Path -LiteralPath $File)) { Bakit-Die "artifact not found: $File" }

# 1. Front-matter must parse.
if (-not (Bakit-HasFrontmatter $File)) { Bakit-Die "missing or unparseable YAML front-matter: $File" }

# 2. Universally required fields.
foreach ($field in 'id', 'type', 'title', 'status', 'created', 'updated') {
    $val = Bakit-FrontmatterField $File $field
    if ([string]::IsNullOrEmpty($val)) { Bakit-Die "front-matter field '$field' is missing or empty: $File" }
}

$Type = Bakit-FrontmatterField $File 'type'
$Status = Bakit-FrontmatterField $File 'status'

# 3. status must be a known value (project uses a different lifecycle).
if ($Type -eq 'project') {
    if ($Status -ne 'active' -and $Status -ne 'archived') {
        Bakit-Die "project status must be 'active' or 'archived' (got '$Status'): $File"
    }
} else {
    if ($Status -ne 'draft' -and $Status -ne 'approved') {
        Bakit-Die "status must be 'draft' or 'approved' (got '$Status'): $File"
    }
}

# 4. type-conditional required fields (traceability).
function Require-Field {
    param([string]$Name)
    $v = Bakit-FrontmatterField $File $Name
    if ([string]::IsNullOrEmpty($v) -or $v -eq '[]') {
        Bakit-Die "front-matter field '$Name' is required for type '$Type': $File"
    }
}

switch ($Type) {
    'docs-analysis'   { Require-Field 'sources' }
    'user-stories'    { Require-Field 'derived_from' }
    'confluence-page' { Require-Field 'derived_from' }
    'requirements'    { }
    'elicitation-plan' { }
    'project'         { }
    'discovery-document' { }
    'project-charter' { }
    'gap-analysis'    { Require-Field 'derived_from' }
    'product-backlog' { Require-Field 'derived_from' }
    'estimated-backlog' { Require-Field 'derived_from' }
    default           { Bakit-Warn "unknown artifact type '$Type' (continuing): $File" }
}

# 5. Approval gate.
if ($RequireApproved -and $Status -ne 'approved') {
    Bakit-Log "status: $Status"
    Bakit-Warn "artifact is not approved: $File"
    exit 2
}

Bakit-Log "status: $Status"
exit 0
