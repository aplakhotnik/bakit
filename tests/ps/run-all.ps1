# Run all BA-Kit PowerShell tests. Exits non-zero if any suite fails.

$ErrorActionPreference = 'Stop'
$SCRIPT_DIR = $PSScriptRoot

$totalFail = 0
Get-ChildItem -LiteralPath $SCRIPT_DIR -Filter 'test-*.ps1' -File | Sort-Object Name | ForEach-Object {
    Write-Output ''
    Write-Output "=== $($_.Name) ==="
    & $_.FullName
    if ($LASTEXITCODE -ne 0) { $script:totalFail++ }
}

Write-Output ''
if ($totalFail -eq 0) {
    Write-Output 'ALL SUITES PASSED'
} else {
    Write-Output "$totalFail SUITE(S) FAILED"
}
if ($totalFail -ne 0) { exit 1 }
exit 0
