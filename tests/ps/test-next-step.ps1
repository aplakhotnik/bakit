# Tests for next-step.ps1: resolves the correct next workflow skill and gate.

$SCRIPT_DIR = $PSScriptRoot
$BAKIT_HOME = (Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR))
$SCRIPTS = (Join-Path (Join-Path $BAKIT_HOME 'scripts') 'ps')
$INIT_PROJECT = (Join-Path $SCRIPTS 'init-project.ps1')
$INIT_TASK = (Join-Path $SCRIPTS 'init-task.ps1')
$NEXT = (Join-Path $SCRIPTS 'next-step.ps1')

$TMP = (Join-Path ([System.IO.Path]::GetTempPath()) ("bakit-" + [guid]::NewGuid().ToString('N')))
New-Item -ItemType Directory -Force -Path $TMP | Out-Null
$env:BAKIT_WORKSPACE = (Join-Path $TMP 'workspace')

$pass = 0; $fail = 0
function Ok { param($m) $script:pass++; Write-Output "ok   - $m" }
function No { param($m) $script:fail++; Write-Output "FAIL - $m" }

function Next-Out {
    param([string[]]$NextArgs = @())
    return (& $NEXT @NextArgs 2>$null | Out-String)
}

# Write a minimal valid artifact of a given type/status.
function Mk-Art {
    param([string]$Path, [string]$Type, [string]$Status, [string]$Extra = '')
    $dir = (Split-Path -Parent $Path)
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $body = "---`nid: test-$Type`ntype: $Type`ntitle: `"Test $Type`"`nstatus: $Status`ncreated: 2025-01-01`nupdated: 2025-01-01`n"
    if (-not [string]::IsNullOrEmpty($Extra)) { $body += "$Extra`n" }
    $body += "---`n`n# Test $Type`n"
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($body -replace "`r`n", "`n"), $enc)
}

try {
    $WS = $env:BAKIT_WORKSPACE

    # Setup: project + task.
    & $INIT_PROJECT 'Demo' 2>$null 1>$null
    & $INIT_TASK 'Demo' 'Build' 2>$null 1>$null
    $TASK = (Join-Path $WS 'demo/tasks/001-build')

    # 1. Fresh task -> first step is ba.analyze-docs.
    if ((Next-Out) -match 'ba\.analyze-docs') { Ok 'fresh task -> analyze-docs' } else { No 'fresh task -> analyze-docs' }

    # 2. With docs-analysis present -> next is specify.
    Mk-Art (Join-Path $TASK 'artifacts/docs-analysis.md') 'docs-analysis' 'draft' 'sources: [inputs/a.txt]'
    if ((Next-Out) -match 'ba\.specify') { Ok 'docs-analysis done -> specify' } else { No 'docs-analysis done -> specify' }

    # 3. With requirements present but draft -> write-stories gate not met.
    Mk-Art (Join-Path $TASK 'artifacts/requirements.md') 'requirements' 'draft'
    $out = Next-Out
    if ($out -match 'gate not met') { Ok 'draft requirements -> gate not met' } else { No 'draft requirements -> gate not met' }
    if ($out -match 'ba\.write-stories') { Ok 'gate message names write-stories' } else { No 'gate message names write-stories' }

    # 4. Approve requirements -> next is write-stories.
    Mk-Art (Join-Path $TASK 'artifacts/requirements.md') 'requirements' 'approved'
    if ((Next-Out) -match 'Next: ba\.write-stories') { Ok 'approved requirements -> write-stories' } else { No 'approved requirements -> write-stories' }

    # 5. Add user-stories -> next is render-confluence.
    Mk-Art (Join-Path $TASK 'artifacts/user-stories.md') 'user-stories' 'draft' 'derived_from: [test-requirements]'
    if ((Next-Out) -match 'ba\.render-confluence') { Ok 'user-stories done -> render-confluence' } else { No 'user-stories done -> render-confluence' }

    # 6. Add a deliverable -> workflow complete.
    Mk-Art (Join-Path $TASK 'deliverables/out-confluence.md') 'confluence-page' 'draft' 'derived_from: [test-requirements]'
    if ((Next-Out) -match 'produced output') { Ok 'all steps done -> complete' } else { No 'all steps done -> complete' }

    # 7. Skip path: a second task with requirements but NO docs-analysis.
    & $INIT_TASK 'Demo' 'Skip Analyze' 2>$null 1>$null
    $TASK2 = (Join-Path $WS 'demo/tasks/002-skip-analyze')
    Mk-Art (Join-Path $TASK2 'artifacts/requirements.md') 'requirements' 'draft'
    $out2 = Next-Out @('Demo', '002-skip-analyze')
    if ($out2 -match 'gate not met') { Ok 'skip analyze: draft requirements -> gate not met' } else { No 'skip analyze: draft requirements -> gate not met' }
    if ($out2 -match 'ba\.analyze-docs') { No 'skip analyze: should NOT fall back to analyze-docs' } else { Ok 'skip analyze: advances past skipped analyze-docs' }

    # 8. Approve those requirements -> next is write-stories.
    Mk-Art (Join-Path $TASK2 'artifacts/requirements.md') 'requirements' 'approved'
    if ((Next-Out @('Demo', '002-skip-analyze')) -match 'Next: ba\.write-stories') { Ok 'skip analyze: approved -> write-stories' } else { No 'skip analyze: approved -> write-stories' }

    # --- Discovery workflow via -Workflow workflow-discovery.md (additive) ---

    & $INIT_TASK 'Demo' 'Discovery Run' 2>$null 1>$null
    $TASK3 = (Join-Path $WS 'demo/tasks/003-discovery-run')
    function D-Next {
        param([string[]]$DArgs = @())
        $all = @('-Workflow', 'workflow-discovery.md') + $DArgs
        return (& $NEXT @all 2>$null | Out-String)
    }

    # D1. Fresh task on the discovery manifest -> first state is ba.discover.initiate.
    if ((D-Next @('Demo', '003-discovery-run')) -match 'ba\.discover\.initiate') { Ok 'discovery: fresh task -> initiate' } else { No 'discovery: fresh task -> initiate' }

    # D2. Default manifest is unaffected for the same fresh task (still analyze-docs).
    if ((Next-Out @('Demo', '003-discovery-run')) -match 'ba\.analyze-docs') { Ok 'discovery: default manifest still analyze-docs (no regression)' } else { No 'discovery: default manifest still analyze-docs (no regression)' }

    # D3. Draft charter present -> gap-analysis gate not met.
    Mk-Art (Join-Path $TASK3 'artifacts/project-charter.md') 'project-charter' 'draft'
    $out3 = D-Next @('Demo', '003-discovery-run')
    if ($out3 -match 'gate not met') { Ok 'discovery: draft charter -> gate not met' } else { No 'discovery: draft charter -> gate not met' }
    if ($out3 -match 'ba\.discover\.gap-analysis') { Ok 'discovery: gate names gap-analysis' } else { No 'discovery: gate names gap-analysis' }

    # D4. Approve charter -> next is gap-analysis.
    Mk-Art (Join-Path $TASK3 'artifacts/project-charter.md') 'project-charter' 'approved'
    if ((D-Next @('Demo', '003-discovery-run')) -match 'Next: ba\.discover\.gap-analysis') { Ok 'discovery: approved charter -> gap-analysis' } else { No 'discovery: approved charter -> gap-analysis' }

    # D5. Add approved gap-analysis -> next is backlog.
    Mk-Art (Join-Path $TASK3 'artifacts/gap-analysis.md') 'gap-analysis' 'approved' 'derived_from: [test-project-charter]'
    if ((D-Next @('Demo', '003-discovery-run')) -match 'Next: ba\.discover\.backlog') { Ok 'discovery: approved gap-analysis -> backlog' } else { No 'discovery: approved gap-analysis -> backlog' }

    # D6. Add approved backlog -> next is estimate.
    Mk-Art (Join-Path $TASK3 'artifacts/product-backlog.md') 'product-backlog' 'approved' 'derived_from: [test-gap-analysis]'
    if ((D-Next @('Demo', '003-discovery-run')) -match 'Next: ba\.discover\.estimate') { Ok 'discovery: approved backlog -> estimate' } else { No 'discovery: approved backlog -> estimate' }

    # D7. Add estimated-backlog -> all discovery states produced output.
    Mk-Art (Join-Path $TASK3 'artifacts/estimated-backlog.md') 'estimated-backlog' 'draft' 'derived_from: [test-product-backlog]'
    if ((D-Next @('Demo', '003-discovery-run')) -match 'produced output') { Ok 'discovery: all states done -> complete' } else { No 'discovery: all states done -> complete' }

    # --- 007: advisory blocking-gap warning before a dependent step ---

    # B1. Approved requirements with a blocking open question -> warn AND still suggest write-stories.
    & $INIT_TASK 'Demo' 'Gap Aware' 2>$null 1>$null
    $TASK4 = (Join-Path $WS 'demo/tasks/004-gap-aware')
    Mk-Art (Join-Path $TASK4 'artifacts/requirements.md') 'requirements' 'approved' "open_questions: 1`nblocking_questions: 1"
    $out4 = Next-Out @('Demo', '004-gap-aware')
    if ($out4 -match 'Next: ba\.write-stories') { Ok 'blocking-gap: still suggests write-stories' } else { No 'blocking-gap: still suggests write-stories' }
    if ($out4 -match 'blocking') { Ok 'blocking-gap: advisory warning shown' } else { No 'blocking-gap: advisory warning shown' }
    & $NEXT 'Demo' '004-gap-aware' 2>$null 1>$null
    if ($LASTEXITCODE -eq 0) { Ok 'blocking-gap: exit 0 (advisory)' } else { No 'blocking-gap: exit 0 (advisory)' }

    # B2. Approved requirements with NO blocking questions -> no warning (unchanged behavior).
    Mk-Art (Join-Path $TASK4 'artifacts/requirements.md') 'requirements' 'approved' "open_questions: 1`nblocking_questions: 0"
    $out5 = Next-Out @('Demo', '004-gap-aware')
    if ($out5 -match 'Next: ba\.write-stories') { Ok 'no-blocking: suggests write-stories' } else { No 'no-blocking: suggests write-stories' }
    if ($out5 -match 'blocking') { No 'no-blocking: should NOT warn about blocking' } else { Ok 'no-blocking: no blocking warning' }

    # B3. Draft requirements with a blocking question -> existing approval gate still shown first.
    Mk-Art (Join-Path $TASK4 'artifacts/requirements.md') 'requirements' 'draft' "open_questions: 1`nblocking_questions: 1"
    $out6 = Next-Out @('Demo', '004-gap-aware')
    if ($out6 -match 'gate not met') { Ok 'draft+blocking: approval gate shown (unchanged)' } else { No 'draft+blocking: approval gate shown (unchanged)' }
}
finally {
    Remove-Item -LiteralPath $TMP -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output ''
Write-Output "$pass passed, $fail failed"
if ($fail -ne 0) { exit 1 }
exit 0
