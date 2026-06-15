# Tests for check-artifact.ps1: front-matter validation and approval gate.

$SCRIPT_DIR = $PSScriptRoot
$BAKIT_HOME = (Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR))
$CHECK = (Join-Path (Join-Path (Join-Path $BAKIT_HOME 'scripts') 'ps') 'check-artifact.ps1')

$TMP = (Join-Path ([System.IO.Path]::GetTempPath()) ("bakit-" + [guid]::NewGuid().ToString('N')))
New-Item -ItemType Directory -Force -Path $TMP | Out-Null

$pass = 0; $fail = 0
function Ok { param($m) $script:pass++; Write-Output "ok   - $m" }
function No { param($m) $script:fail++; Write-Output "FAIL - $m" }

# Run check, return exit code.
function Run-Check {
    param([string[]]$CheckArgs)
    & $CHECK @CheckArgs 2>$null 1>$null
    return $LASTEXITCODE
}

# Run check, return captured stdout (lines).
function Run-CheckOut {
    param([string[]]$CheckArgs)
    return (& $CHECK @CheckArgs 2>$null)
}

# Write text as UTF-8 no BOM, LF.
function Write-Art {
    param([string]$Path, [string]$Text)
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($Text -replace "`r`n", "`n"), $enc)
}

try {
    # 1. Valid approved requirements artifact.
    $req = (Join-Path $TMP 'req.md')
    Write-Art $req "---`nid: REQ-001`ntype: requirements`ntitle: Sample`nstatus: approved`ncreated: 2026-06-06`nupdated: 2026-06-06`n---`n# Body`n"
    if ((Run-Check @($req)) -eq 0) { Ok 'valid requirements passes' } else { No 'valid requirements passes' }
    if ((Run-Check @('--require-approved', $req)) -eq 0) { Ok 'approved passes gate' } else { No 'approved passes gate' }

    # 2. Draft fails the approval gate (exit 2) but passes plain validation.
    $draft = (Join-Path $TMP 'draft.md')
    Write-Art $draft "---`nid: REQ-002`ntype: requirements`ntitle: Draft`nstatus: draft`ncreated: 2026-06-06`nupdated: 2026-06-06`n---`n"
    if ((Run-Check @($draft)) -eq 0) { Ok 'draft passes plain validation' } else { No 'draft passes plain validation' }
    if ((Run-Check @('--require-approved', $draft)) -eq 2) { Ok 'draft fails approval gate (exit 2)' } else { No 'draft fails approval gate (exit 2)' }

    # 3. Missing front-matter fails.
    $nofm = (Join-Path $TMP 'nofm.md')
    Write-Art $nofm "# no front-matter`n"
    if ((Run-Check @($nofm)) -eq 1) { Ok 'missing front-matter fails' } else { No 'missing front-matter fails' }

    # 4. Missing required field (status) fails.
    $missing = (Join-Path $TMP 'missing.md')
    Write-Art $missing "---`nid: X-1`ntype: requirements`ntitle: Missing status`ncreated: 2026-06-06`nupdated: 2026-06-06`n---`n"
    if ((Run-Check @($missing)) -eq 1) { Ok 'missing required field fails' } else { No 'missing required field fails' }

    # 5. Invalid status value fails.
    $bad = (Join-Path $TMP 'badstatus.md')
    Write-Art $bad "---`nid: X-2`ntype: requirements`ntitle: Bad status`nstatus: published`ncreated: 2026-06-06`nupdated: 2026-06-06`n---`n"
    if ((Run-Check @($bad)) -eq 1) { Ok 'invalid status fails' } else { No 'invalid status fails' }

    # 6. docs-analysis without sources fails (type-conditional requirement).
    $docs = (Join-Path $TMP 'docs.md')
    Write-Art $docs "---`nid: DA-1`ntype: docs-analysis`ntitle: No sources`nstatus: draft`ncreated: 2026-06-06`nupdated: 2026-06-06`nsources: []`n---`n"
    if ((Run-Check @($docs)) -eq 1) { Ok 'docs-analysis without sources fails' } else { No 'docs-analysis without sources fails' }

    # 7. Valid elicitation-plan artifact passes (universal fields only).
    $elic = (Join-Path $TMP 'elic.md')
    Write-Art $elic "---`nid: ELIC-1`ntype: elicitation-plan`ntitle: Sample elicitation plan`nstatus: draft`ncreated: 2026-06-06`nupdated: 2026-06-06`nround: 1`n---`n# Body`n"
    if ((Run-Check @($elic)) -eq 0) { Ok 'valid elicitation-plan passes' } else { No 'valid elicitation-plan passes' }

    # 8. elicitation-plan missing a universal field (title) fails.
    $elicBad = (Join-Path $TMP 'elic-bad.md')
    Write-Art $elicBad "---`nid: ELIC-2`ntype: elicitation-plan`nstatus: draft`ncreated: 2026-06-06`nupdated: 2026-06-06`n---`n"
    if ((Run-Check @($elicBad)) -eq 1) { Ok 'elicitation-plan missing universal field fails' } else { No 'elicitation-plan missing universal field fails' }

    # --- Discovery workflow artifact types (additive) ---

    # 9. discovery-document is valid with universal fields only (no derived_from required).
    $disc = (Join-Path $TMP 'disc.md')
    Write-Art $disc "---`nid: DISC-1`ntype: discovery-document`ntitle: Living Discovery Document`nstatus: draft`ncreated: 2026-06-07`nupdated: 2026-06-07`n---`n# Body`n"
    if ((Run-Check @($disc)) -eq 0) { Ok 'discovery-document passes (universal only)' } else { No 'discovery-document passes (universal only)' }

    # 10. project-charter is valid with universal fields only.
    $charter = (Join-Path $TMP 'charter.md')
    Write-Art $charter "---`nid: CHTR-1`ntype: project-charter`ntitle: Charter`nstatus: draft`ncreated: 2026-06-07`nupdated: 2026-06-07`n---`n# Body`n"
    if ((Run-Check @($charter)) -eq 0) { Ok 'project-charter passes (universal only)' } else { No 'project-charter passes (universal only)' }

    # 11. gap-analysis without derived_from fails; with it, passes.
    $gapBad = (Join-Path $TMP 'gap-bad.md')
    Write-Art $gapBad "---`nid: GAP-1`ntype: gap-analysis`ntitle: No derived_from`nstatus: draft`ncreated: 2026-06-07`nupdated: 2026-06-07`nderived_from: []`n---`n"
    if ((Run-Check @($gapBad)) -eq 1) { Ok 'gap-analysis without derived_from fails' } else { No 'gap-analysis without derived_from fails' }
    $gapOk = (Join-Path $TMP 'gap-ok.md')
    Write-Art $gapOk "---`nid: GAP-2`ntype: gap-analysis`ntitle: Has derived_from`nstatus: draft`ncreated: 2026-06-07`nupdated: 2026-06-07`nderived_from: [CHTR-1]`n---`n"
    if ((Run-Check @($gapOk)) -eq 0) { Ok 'gap-analysis with derived_from passes' } else { No 'gap-analysis with derived_from passes' }

    # 12. product-backlog requires derived_from.
    $pbBad = (Join-Path $TMP 'pb-bad.md')
    Write-Art $pbBad "---`nid: PB-1`ntype: product-backlog`ntitle: No derived_from`nstatus: draft`ncreated: 2026-06-07`nupdated: 2026-06-07`nderived_from: []`n---`n"
    if ((Run-Check @($pbBad)) -eq 1) { Ok 'product-backlog without derived_from fails' } else { No 'product-backlog without derived_from fails' }

    # 13. estimated-backlog requires derived_from; with it, passes; gate on draft is exit 2.
    $eb = (Join-Path $TMP 'eb.md')
    Write-Art $eb "---`nid: EB-1`ntype: estimated-backlog`ntitle: Estimated`nstatus: draft`ncreated: 2026-06-07`nupdated: 2026-06-07`nderived_from: [PB-1]`n---`n"
    if ((Run-Check @($eb)) -eq 0) { Ok 'estimated-backlog with derived_from passes' } else { No 'estimated-backlog with derived_from passes' }
    if ((Run-Check @('--require-approved', $eb)) -eq 2) { Ok 'draft discovery artifact fails approval gate (exit 2)' } else { No 'draft discovery artifact fails approval gate (exit 2)' }

    # 14. approved discovery artifact passes the approval gate (exit 0).
    $ebOk = (Join-Path $TMP 'eb-ok.md')
    Write-Art $ebOk "---`nid: EB-2`ntype: estimated-backlog`ntitle: Estimated approved`nstatus: approved`ncreated: 2026-06-07`nupdated: 2026-06-07`nderived_from: [PB-1]`n---`n"
    if ((Run-Check @('--require-approved', $ebOk)) -eq 0) { Ok 'approved discovery artifact passes gate' } else { No 'approved discovery artifact passes gate' }

    # --- 007: open/blocking rollup reporting + strict mode (--require-no-blocking) ---

    # 15. Counts are reported on success.
    $oq = (Join-Path $TMP 'oq.md')
    Write-Art $oq "---`nid: REQ-OQ`ntype: requirements`ntitle: With open questions`nstatus: approved`ncreated: 2026-06-10`nupdated: 2026-06-10`nopen_questions: 2`nblocking_questions: 1`n---`n# Body`n"
    $out = (Run-CheckOut @($oq)) -join "`n"
    if ($out -match '(?m)^open_questions: 2$') { Ok 'reports open_questions count' } else { No 'reports open_questions count' }
    if ($out -match '(?m)^blocking_questions: 1$') { Ok 'reports blocking_questions count' } else { No 'reports blocking_questions count' }
    if ((Run-Check @($oq)) -eq 0) { Ok 'open/blocking advisory by default (exit 0)' } else { No 'open/blocking advisory by default (exit 0)' }

    # 16. --require-no-blocking exits 3 when blocking questions remain.
    if ((Run-Check @('--require-no-blocking', $oq)) -eq 3) { Ok 'strict mode exits 3 when blocking remain' } else { No 'strict mode exits 3 when blocking remain' }

    # 17. --require-no-blocking exits 0 when no blocking questions.
    $oq0 = (Join-Path $TMP 'oq0.md')
    Write-Art $oq0 "---`nid: REQ-OQ0`ntype: requirements`ntitle: No blocking`nstatus: approved`ncreated: 2026-06-10`nupdated: 2026-06-10`nopen_questions: 2`nblocking_questions: 0`n---`n# Body`n"
    if ((Run-Check @('--require-no-blocking', $oq0)) -eq 0) { Ok 'strict mode exits 0 when no blocking' } else { No 'strict mode exits 0 when no blocking' }

    # 18. Legacy artifact (no rollup fields) reports 0/0 and exits 0 (backward compatible).
    $out = (Run-CheckOut @($req)) -join "`n"
    if ($out -match '(?m)^open_questions: 0$') { Ok 'legacy artifact reports open_questions: 0' } else { No 'legacy artifact reports open_questions: 0' }
    if ($out -match '(?m)^blocking_questions: 0$') { Ok 'legacy artifact reports blocking_questions: 0' } else { No 'legacy artifact reports blocking_questions: 0' }
    if ((Run-Check @('--require-no-blocking', $req)) -eq 0) { Ok 'legacy artifact passes strict mode (exit 0)' } else { No 'legacy artifact passes strict mode (exit 0)' }

    # 19. Approval gate takes precedence over blocking gate: draft + blocking => exit 2.
    $oqDraft = (Join-Path $TMP 'oq-draft.md')
    Write-Art $oqDraft "---`nid: REQ-OQD`ntype: requirements`ntitle: Draft with blocking`nstatus: draft`ncreated: 2026-06-10`nupdated: 2026-06-10`nopen_questions: 1`nblocking_questions: 1`n---`n# Body`n"
    if ((Run-Check @('--require-approved', '--require-no-blocking', $oqDraft)) -eq 2) { Ok 'approval gate precedes blocking gate (exit 2)' } else { No 'approval gate precedes blocking gate (exit 2)' }

    # 20. Invalid artifact still exits 1 even with strict flag.
    if ((Run-Check @('--require-no-blocking', $nofm)) -eq 1) { Ok 'invalid artifact exits 1 under strict mode' } else { No 'invalid artifact exits 1 under strict mode' }

    # --- 008: story-map type + single Selected-variant invariant ---

    # 21. Valid story-map with exactly one Selected variant passes.
    $smOk = (Join-Path $TMP 'sm-ok.md')
    Write-Art $smOk "---`nid: SM-1`ntype: story-map`ntitle: Valid story map`nstatus: draft`ncreated: 2026-06-15`nupdated: 2026-06-15`nderived_from: [REQ-001]`n---`n# Story Map`n`n### Variant V1: walking skeleton — **Selected variant**`n| Slice | Pattern | Covers |`n|-------|---------|--------|`n| V1-S1 | Workflow/Path | FR-001 |`n"
    if ((Run-Check @($smOk)) -eq 0) { Ok 'story-map with one Selected variant passes' } else { No 'story-map with one Selected variant passes' }

    # 22. Zero Selected variants fails (exit 1).
    $smNone = (Join-Path $TMP 'sm-none.md')
    Write-Art $smNone "---`nid: SM-2`ntype: story-map`ntitle: No selection`nstatus: draft`ncreated: 2026-06-15`nupdated: 2026-06-15`nderived_from: [REQ-001]`n---`n# Story Map`n`n### Variant V1: walking skeleton`n| Slice | Pattern | Covers |`n|-------|---------|--------|`n| V1-S1 | Workflow/Path | FR-001 |`n"
    if ((Run-Check @($smNone)) -eq 1) { Ok 'story-map with zero Selected variants fails' } else { No 'story-map with zero Selected variants fails' }

    # 23. Two Selected variants fails (exit 1).
    $smTwo = (Join-Path $TMP 'sm-two.md')
    Write-Art $smTwo "---`nid: SM-3`ntype: story-map`ntitle: Double selection`nstatus: draft`ncreated: 2026-06-15`nupdated: 2026-06-15`nderived_from: [REQ-001]`n---`n# Story Map`n`n### Variant V1: a — **Selected variant**`n### Variant V2: b — **Selected variant**`n"
    if ((Run-Check @($smTwo)) -eq 1) { Ok 'story-map with two Selected variants fails' } else { No 'story-map with two Selected variants fails' }

    # 24. Missing/empty derived_from fails.
    $smNoDerive = (Join-Path $TMP 'sm-noderive.md')
    Write-Art $smNoDerive "---`nid: SM-4`ntype: story-map`ntitle: No derived_from`nstatus: draft`ncreated: 2026-06-15`nupdated: 2026-06-15`nderived_from: []`n---`n# Story Map`n`n### Variant V1: a — **Selected variant**`n"
    if ((Run-Check @($smNoDerive)) -eq 1) { Ok 'story-map without derived_from fails' } else { No 'story-map without derived_from fails' }

    # 25. Absent open/blocking rollups are treated as 0 (exit 0) and reported.
    $smOut = (Run-CheckOut @($smOk)) -join "`n"
    if ($smOut -match '(?m)^open_questions: 0$') { Ok 'story-map absent rollups report 0' } else { No 'story-map absent rollups report 0' }
    if ((Run-Check @($smOk)) -eq 0) { Ok 'story-map absent rollups exit 0' } else { No 'story-map absent rollups exit 0' }

    # 26. Back-compat: existing requirements type still validates (Selected check does not apply).
    if ((Run-Check @($req)) -eq 0) { Ok 'non-story-map unaffected by Selected-variant check' } else { No 'non-story-map unaffected by Selected-variant check' }
}
finally {
    Remove-Item -LiteralPath $TMP -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output ''
Write-Output "$pass passed, $fail failed"
if ($fail -ne 0) { exit 1 }
exit 0
