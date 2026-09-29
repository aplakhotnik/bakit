# Tests for init-project.ps1: creation, structure, collision safety.

$SCRIPT_DIR = $PSScriptRoot
$BAKIT_HOME = (Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR))
$SCRIPTS = (Join-Path (Join-Path $BAKIT_HOME 'scripts') 'ps')
$INIT = (Join-Path $SCRIPTS 'init-project.ps1')
$CHECK = (Join-Path $SCRIPTS 'check-artifact.ps1')

$TMP = (Join-Path ([System.IO.Path]::GetTempPath()) ("bakit-" + [guid]::NewGuid().ToString('N')))
New-Item -ItemType Directory -Force -Path $TMP | Out-Null
$env:BAKIT_WORKSPACE = (Join-Path $TMP 'workspace')

$pass = 0; $fail = 0
function Ok { param($m) $script:pass++; Write-Output "ok   - $m" }
function No { param($m) $script:fail++; Write-Output "FAIL - $m" }
function Run-Script {
    param([string]$Script, [string[]]$ScriptArgs = @())
    & $Script @ScriptArgs 2>$null 1>$null
    return $LASTEXITCODE
}

try {
    $WS = $env:BAKIT_WORKSPACE

    # 1. Create a project.
    if ((Run-Script $INIT @('Payments Revamp')) -eq 0) { Ok 'creates project' } else { No 'creates project' }

    # 2. project.md + tasks/ exist, with valid front-matter.
    if (Test-Path (Join-Path $WS 'payments-revamp/project.md')) { Ok 'project.md exists' } else { No 'project.md exists' }
    if (Test-Path (Join-Path $WS 'payments-revamp/tasks')) { Ok 'tasks/ exists' } else { No 'tasks/ exists' }
    if ((Run-Script $CHECK @((Join-Path $WS 'payments-revamp/project.md'))) -eq 0) { Ok 'project.md has valid front-matter' } else { No 'project.md has valid front-matter' }

    # 3. Slugification.
    if (Test-Path (Join-Path $WS 'payments-revamp')) { Ok 'name slugified' } else { No 'name slugified' }

    # 3b. Shared project-level knowledge base seeded with a valid index.
    if (Test-Path (Join-Path $WS 'payments-revamp/kb')) { Ok 'project kb/ exists' } else { No 'project kb/ exists' }
    $kbIndex = (Join-Path $WS 'payments-revamp/kb/index.md')
    if (Test-Path $kbIndex) { Ok 'project kb/index.md exists' } else { No 'project kb/index.md exists' }
    if (Select-String -LiteralPath $kbIndex -Pattern '^## Summary' -Quiet) { Ok 'project kb index has Summary' } else { No 'project kb index has Summary' }
    if (Select-String -LiteralPath $kbIndex -Pattern '^## Entries' -Quiet) { Ok 'project kb index has Entries' } else { No 'project kb index has Entries' }

    # 4. Collision: second create with same name fails and does not overwrite.
    $projMd = (Join-Path $WS 'payments-revamp/project.md')
    $before = (Join-Path $TMP 'before.md')
    Copy-Item -LiteralPath $projMd -Destination $before -Force
    if ((Run-Script $INIT @('Payments Revamp')) -ne 0) { Ok 'collision refused' } else { No 'collision refused' }
    if ((Get-FileHash $before).Hash -eq (Get-FileHash $projMd).Hash) { Ok 'existing project untouched' } else { No 'existing project untouched' }

    # 5. Empty/invalid name fails.
    if ((Run-Script $INIT @('')) -ne 0) { Ok 'empty name rejected' } else { No 'empty name rejected' }

    # 6. Default mode is independent (kb_mode recorded; no brain registers).
    if (Select-String -LiteralPath $projMd -Pattern '^kb_mode: independent' -Quiet) { Ok 'default mode is independent' } else { No 'default mode is independent' }
    if (-not (Test-Path (Join-Path $WS 'payments-revamp/kb/changelog.md'))) { Ok 'independent has no brain registers' } else { No 'independent has no brain registers' }

    # 7. Brain mode scaffolds registers + records kb_mode: brain.
    if ((Run-Script $INIT @('RFP Pursuit', '--mode', 'brain')) -eq 0) { Ok 'creates brain project' } else { No 'creates brain project' }
    if (Select-String -LiteralPath (Join-Path $WS 'rfp-pursuit/project.md') -Pattern '^kb_mode: brain' -Quiet) { Ok 'brain mode recorded' } else { No 'brain mode recorded' }
    $bmOk = $true
    foreach ($f in @('changelog', 'requirements-register', 'open-questions', 'decisions', 'glossary')) {
        if (-not (Test-Path (Join-Path $WS "rfp-pursuit/kb/$f.md"))) { $bmOk = $false }
    }
    if ($bmOk) { Ok 'brain registers scaffolded' } else { No 'brain registers scaffolded' }

    # 8. Invalid mode is rejected.
    if ((Run-Script $INIT @('Bad Mode', '--mode', 'nonsense')) -ne 0) { Ok 'invalid mode rejected' } else { No 'invalid mode rejected' }

    # 9. Upgrade an independent project to brain (idempotent, non-destructive).
    $idxBefore = (Join-Path $TMP 'index-before.md')
    Copy-Item -LiteralPath $kbIndex -Destination $idxBefore -Force
    if ((Run-Script $INIT @('Payments Revamp', '--upgrade-to-brain')) -eq 0) { Ok 'upgrade succeeds' } else { No 'upgrade succeeds' }
    if (Select-String -LiteralPath $projMd -Pattern '^kb_mode: brain' -Quiet) { Ok 'upgrade sets kb_mode brain' } else { No 'upgrade sets kb_mode brain' }
    if (Test-Path (Join-Path $WS 'payments-revamp/kb/changelog.md')) { Ok 'upgrade scaffolds registers' } else { No 'upgrade scaffolds registers' }
    if ((Get-FileHash $idxBefore).Hash -eq (Get-FileHash $kbIndex).Hash) { Ok 'upgrade preserves existing kb/index.md' } else { No 'upgrade preserves existing kb/index.md' }
    if ((Run-Script $INIT @('Payments Revamp', '--upgrade-to-brain')) -eq 0) { Ok 'upgrade is idempotent' } else { No 'upgrade is idempotent' }

    # 10. Upgrade a non-existent project fails.
    if ((Run-Script $INIT @('Ghost Project', '--upgrade-to-brain')) -ne 0) { Ok 'upgrade of missing project fails' } else { No 'upgrade of missing project fails' }
}
finally {
    Remove-Item -LiteralPath $TMP -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output ''
Write-Output "$pass passed, $fail failed"
if ($fail -ne 0) { exit 1 }
exit 0
