# Verify every relative Markdown link in the repo points to an existing target.
# Guards against the "docs page linked but never created" class of bug.

$SCRIPT_DIR = $PSScriptRoot
$ROOT = (Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR))

$pass = 0; $fail = 0
function Ok { param($m) $script:pass++; Write-Output "ok   - $m" }
function No { param($m) $script:fail++; Write-Output "FAIL - $m" }

$checked = 0
$broken = New-Object System.Collections.Generic.List[string]

$mdFiles = Get-ChildItem -LiteralPath $ROOT -Recurse -Filter '*.md' -File |
    Where-Object {
        $_.FullName -notmatch '[\\/]tests[\\/]' -and
        $_.FullName -notmatch '[\\/]\.git[\\/]'
    }

foreach ($f in $mdFiles) {
    $dir = $f.DirectoryName
    $text = Get-Content -LiteralPath $f.FullName -Raw
    foreach ($m in [regex]::Matches($text, '\]\(([^)]+)\)')) {
        $raw = $m.Groups[1].Value
        $link = ($raw -split '#', 2)[0]            # strip any #anchor
        if ([string]::IsNullOrEmpty($link)) { continue }  # pure-anchor link
        if ($link -match '^(https?://|mailto:)') { continue }
        $checked++
        $target = (Join-Path $dir $link)
        if (-not (Test-Path -LiteralPath $target)) {
            $rel = $f.FullName.Substring($ROOT.Length).TrimStart('\','/')
            $broken.Add("  $rel -> $raw")
        }
    }
}

if ($broken.Count -eq 0) {
    Ok "all $checked relative markdown links resolve"
} else {
    Write-Output ("broken links:`n" + ($broken -join "`n"))
    No 'broken markdown links found'
}

Write-Output ''
Write-Output "$pass passed, $fail failed"
if ($fail -ne 0) { exit 1 }
exit 0
