# Guard: shipped content must NOT reference internal-only paths that don't exist
# in the public repo (specs/00*, .specify/). Locks in the self-contained
# constitution; CHANGELOG is excluded because it documents the historical fix.

$SCRIPT_DIR = $PSScriptRoot
$ROOT = (Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR))

$pass = 0; $fail = 0
function Ok { param($m) $script:pass++; Write-Output "ok   - $m" }
function No { param($m) $script:fail++; Write-Output "FAIL - $m" }

# Paths that ship to users (everything except CHANGELOG and tests).
$scan = @('skills', 'memory', 'templates', 'docs', 'examples', 'README.md', 'CONTRIBUTING.md')

$targets = foreach ($s in $scan) {
    $p = (Join-Path $ROOT $s)
    if (Test-Path -LiteralPath $p) {
        Get-ChildItem -LiteralPath $p -Recurse -File -ErrorAction SilentlyContinue
    }
}

$hits = New-Object System.Collections.Generic.List[string]
foreach ($f in $targets) {
    $n = 0
    foreach ($line in (Get-Content -LiteralPath $f.FullName)) {
        $n++
        if ($line -match 'specs/0[0-9]|\.specify/') {
            $rel = $f.FullName.Substring($ROOT.Length).TrimStart('\','/')
            $hits.Add("${rel}:${n}: $line")
        }
    }
}

if ($hits.Count -eq 0) {
    Ok 'no dangling specs/ or .specify/ references in shipped content'
} else {
    Write-Output ($hits -join "`n")
    No 'found dangling internal references in shipped content'
}

Write-Output ''
Write-Output "$pass passed, $fail failed"
if ($fail -ne 0) { exit 1 }
exit 0
