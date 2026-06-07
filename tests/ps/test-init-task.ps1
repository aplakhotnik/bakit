# Tests for init-task.ps1: structure, sequential numbering, collision safety.

$SCRIPT_DIR = $PSScriptRoot
$BAKIT_HOME = (Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR))
$SCRIPTS = (Join-Path (Join-Path $BAKIT_HOME 'scripts') 'ps')
$INIT_PROJECT = (Join-Path $SCRIPTS 'init-project.ps1')
$INIT_TASK = (Join-Path $SCRIPTS 'init-task.ps1')

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
    $PROJ = (Join-Path $WS 'demo')

    # Setup project.
    Run-Script $INIT_PROJECT @('Demo') | Out-Null

    # 1. Task creation fails without an existing project.
    if ((Run-Script $INIT_TASK @('nope', 'x')) -ne 0) { Ok 'task in missing project fails' } else { No 'task in missing project fails' }

    # 2. First task -> 001-<slug> with the subfolders.
    if ((Run-Script $INIT_TASK @('Demo', 'Elicit Requirements')) -eq 0) { Ok 'creates first task' } else { No 'creates first task' }
    if (Test-Path (Join-Path $PROJ 'tasks/001-elicit-requirements/inputs')) { Ok 'inputs/ created' } else { No 'inputs/ created' }
    if (Test-Path (Join-Path $PROJ 'tasks/001-elicit-requirements/artifacts')) { Ok 'artifacts/ created' } else { No 'artifacts/ created' }
    if (Test-Path (Join-Path $PROJ 'tasks/001-elicit-requirements/deliverables')) { Ok 'deliverables/ created' } else { No 'deliverables/ created' }

    # 2b. Task-level knowledge base seeded with a valid index.
    if (Test-Path (Join-Path $PROJ 'tasks/001-elicit-requirements/kb')) { Ok 'task kb/ created' } else { No 'task kb/ created' }
    $kbIndex = (Join-Path $PROJ 'tasks/001-elicit-requirements/kb/index.md')
    if (Test-Path $kbIndex) { Ok 'task kb/index.md created' } else { No 'task kb/index.md created' }
    if (Select-String -LiteralPath $kbIndex -Pattern '^## Summary' -Quiet) { Ok 'task kb index has Summary' } else { No 'task kb index has Summary' }
    if (Select-String -LiteralPath $kbIndex -Pattern '^## Entries' -Quiet) { Ok 'task kb index has Entries' } else { No 'task kb index has Entries' }

    # 3. Second task -> sequential 002.
    Run-Script $INIT_TASK @('Demo', 'Write Stories') | Out-Null
    if (Test-Path (Join-Path $PROJ 'tasks/002-write-stories')) { Ok 'second task numbered 002' } else { No 'second task numbered 002' }

    # 4. Active pointer updated to most recent task.
    if (Select-String -LiteralPath (Join-Path $WS '.bakit-active') -Pattern '^task=002-write-stories$' -Quiet) { Ok 'active pointer updated' } else { No 'active pointer updated' }

    # 5. Duplicate task name yields a new sequence (no overwrite, no error).
    if ((Run-Script $INIT_TASK @('Demo', 'Elicit Requirements')) -eq 0) { Ok 'duplicate name -> new seq' } else { No 'duplicate name -> new seq' }
    if (Test-Path (Join-Path $PROJ 'tasks/003-elicit-requirements')) { Ok 'duplicate gets 003' } else { No 'duplicate gets 003' }
}
finally {
    Remove-Item -LiteralPath $TMP -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output ''
Write-Output "$pass passed, $fail failed"
if ($fail -ne 0) { exit 1 }
exit 0
