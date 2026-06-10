# Tests for install.ps1 Antigravity target (skill-folder layout).
# Mirrors test-install-antigravity.sh and asserts the same contract
# (specs/006-installation-experience/contracts/antigravity-skill.md).

$ErrorActionPreference = 'Stop'
$SCRIPT_DIR = $PSScriptRoot
$BAKIT_HOME = (Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR))

$TMP = (Join-Path ([System.IO.Path]::GetTempPath()) ("bakit-ag-" + [guid]::NewGuid().ToString('N')))
New-Item -ItemType Directory -Force -Path $TMP | Out-Null

$pass = 0; $fail = 0
function Ok { param($m) $script:pass++; Write-Output "ok   - $m" }
function No { param($m) $script:fail++; Write-Output "FAIL - $m" }

# Body of a markdown skill = everything after its YAML front-matter.
function Get-Body {
    param([string]$Path)
    $lines = Get-Content -LiteralPath $Path
    $c = 0
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($l in $lines) {
        if ($c -ge 2) { $out.Add($l) }
        if ($l -match '^---\s*$') { $c++ }
    }
    return ($out -join "`n")
}

# Run install.ps1 from a working directory with optional HOME override.
function Run-Install {
    param([string]$WorkDir, [hashtable]$InstallArgs = @{}, [string]$HomeOverride = $null)
    Push-Location $WorkDir
    $oldHome = $env:HOME; $oldUserProfile = $env:USERPROFILE
    if ($HomeOverride) { $env:HOME = $HomeOverride; $env:USERPROFILE = $HomeOverride }
    try {
        & (Join-Path $BAKIT_HOME 'install.ps1') @InstallArgs 2>$null 1>$null
        return $LASTEXITCODE
    }
    finally {
        $env:HOME = $oldHome; $env:USERPROFILE = $oldUserProfile
        Pop-Location
    }
}

try {
    $CLONE_SKILLS = (Join-Path $BAKIT_HOME 'skills')

    # --- workspace scope (default) -----------------------------------------
    $WS = (Join-Path $TMP 'ws')
    New-Item -ItemType Directory -Force -Path $WS | Out-Null
    if ((Run-Install $WS @{ Agent = 'antigravity' }) -eq 0) { Ok 'antigravity installer runs cleanly (workspace)' } else { No 'antigravity installer runs cleanly (workspace)' }

    $SKILLS = (Join-Path $WS '.agents/skills')
    if (Test-Path $SKILLS) { Ok 'workspace: .agents/skills/ created' } else { No 'workspace: .agents/skills/ created' }

    $allfolders = $true
    Get-ChildItem -LiteralPath $CLONE_SKILLS -Filter 'ba.*.md' -File | ForEach-Object {
        if (-not (Test-Path (Join-Path $SKILLS (Join-Path $_.BaseName 'SKILL.md')))) { $allfolders = $false }
    }
    if ($allfolders) { Ok 'workspace: every skill -> ba.<name>/SKILL.md' } else { No 'workspace: every skill -> ba.<name>/SKILL.md' }

    $SKM = (Join-Path $SKILLS 'ba.next/SKILL.md')
    if (Select-String -LiteralPath $SKM -Pattern '^name: ba\.next$' -Quiet) { Ok 'SKILL.md name matches folder' } else { No 'SKILL.md name matches folder' }
    $descLine = Get-Content -LiteralPath $SKM | Where-Object { $_ -match '^description:' } | Select-Object -First 1
    $desc = ($descLine -replace '^description:\s*', '').Trim().Trim('"')
    if (-not [string]::IsNullOrEmpty($desc)) { Ok 'SKILL.md description is non-empty' } else { No 'SKILL.md description is non-empty' }

    $srcBody = Get-Body (Join-Path $CLONE_SKILLS 'ba.next.md')
    $outBody = Get-Body $SKM
    if ($srcBody -ceq $outBody) { Ok 'SKILL.md body byte-identical to source' } else { No 'SKILL.md body byte-identical to source' }

    # Minimal bundling: ba.next references only an sh script.
    if (Test-Path (Join-Path $SKILLS 'ba.next/scripts/sh/next-step.sh')) { Ok 'ba.next: bundles scripts/sh/next-step.sh' } else { No 'ba.next: bundles scripts/sh/next-step.sh' }
    if (Test-Path (Join-Path $SKILLS 'ba.next/scripts/sh/common.sh')) { Ok 'ba.next: bundles scripts/sh/common.sh' } else { No 'ba.next: bundles scripts/sh/common.sh' }
    if (-not (Test-Path (Join-Path $SKILLS 'ba.next/scripts/ps'))) { Ok 'ba.next: no scripts/ps (none referenced)' } else { No 'ba.next: no scripts/ps (none referenced)' }
    if (-not (Test-Path (Join-Path $SKILLS 'ba.next/resources'))) { Ok 'ba.next: no resources (no templates referenced)' } else { No 'ba.next: no resources (no templates referenced)' }

    # Bundled scripts are verbatim copies.
    function Same-File { param($a, $b) ((Get-Content -Raw -LiteralPath $a) -ceq (Get-Content -Raw -LiteralPath $b)) }
    if (Same-File (Join-Path $BAKIT_HOME 'scripts/sh/next-step.sh') (Join-Path $SKILLS 'ba.next/scripts/sh/next-step.sh')) { Ok 'bundled next-step.sh is verbatim' } else { No 'bundled next-step.sh is verbatim' }
    if (Same-File (Join-Path $BAKIT_HOME 'scripts/sh/common.sh') (Join-Path $SKILLS 'ba.next/scripts/sh/common.sh')) { Ok 'bundled common.sh is verbatim' } else { No 'bundled common.sh is verbatim' }

    # Template bundling.
    $TPL = (Join-Path $SKILLS 'ba.start-project/resources/templates/project/project.md')
    if (Test-Path $TPL) { Ok 'ba.start-project: bundles template under resources/' } else { No 'ba.start-project: bundles template under resources/' }
    if (Same-File (Join-Path $BAKIT_HOME 'templates/project/project.md') $TPL) { Ok 'bundled template is verbatim' } else { No 'bundled template is verbatim' }

    # No flat-file regression.
    if (-not (Test-Path (Join-Path $WS '.github'))) { Ok 'no flat-file regression (.github not created)' } else { No 'no flat-file regression (.github not created)' }

    # Idempotency: stale bundled file removed on re-run.
    New-Item -ItemType Directory -Force -Path (Join-Path $SKILLS 'ba.next/scripts/ps') | Out-Null
    Set-Content -LiteralPath (Join-Path $SKILLS 'ba.next/scripts/ps/zombie.ps1') -Value 'stale'
    Run-Install $WS @{ Agent = 'antigravity' } | Out-Null
    if (-not (Test-Path (Join-Path $SKILLS 'ba.next/scripts/ps/zombie.ps1'))) { Ok 'idempotent: stale bundled file removed on re-run' } else { No 'idempotent: stale bundled file removed on re-run' }
    if (Test-Path $SKM) { Ok 'idempotent: SKILL.md still present after re-run' } else { No 'idempotent: SKILL.md still present after re-run' }

    # --- global scope ------------------------------------------------------
    $GH = (Join-Path $TMP 'home')
    New-Item -ItemType Directory -Force -Path $GH | Out-Null
    $GWORK = (Join-Path $TMP 'gwork')
    New-Item -ItemType Directory -Force -Path $GWORK | Out-Null
    if ((Run-Install $GWORK @{ Agent = 'antigravity'; Scope = 'global' } $GH) -eq 0) { Ok 'antigravity installer runs cleanly (global)' } else { No 'antigravity installer runs cleanly (global)' }
    if (Test-Path (Join-Path $GH '.gemini/config/skills/ba.next/SKILL.md')) { Ok 'global: installs under ~/.gemini/config/skills' } else { No 'global: installs under ~/.gemini/config/skills' }
    if (-not (Test-Path (Join-Path $GWORK '.agents'))) { Ok 'global: does not create workspace .agents/' } else { No 'global: does not create workspace .agents/' }

    # --- auto-detection precedence (Antigravity is lowest) -----------------
    # No-argument runs go through the menu/auto-detect path; drive them as a
    # child process with a redirected stdin so they fall back non-interactively.
    $INSTALL = (Join-Path $BAKIT_HOME 'install.ps1')
    function Run-Child { param([string]$WorkDir) Push-Location $WorkDir; try { '' | & pwsh -NoProfile -File $INSTALL 2>$null 1>$null } finally { Pop-Location } }

    $LONE = (Join-Path $TMP 'lone-agents')
    New-Item -ItemType Directory -Force -Path (Join-Path $LONE '.agents') | Out-Null
    Run-Child $LONE
    if (Test-Path (Join-Path $LONE '.agents/skills/ba.next/SKILL.md')) { Ok 'auto-detect: lone .agents/ -> antigravity' } else { No 'auto-detect: lone .agents/ -> antigravity' }

    $MIX = (Join-Path $TMP 'mix')
    New-Item -ItemType Directory -Force -Path (Join-Path $MIX '.github') | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $MIX '.agents') | Out-Null
    Run-Child $MIX
    if (Test-Path (Join-Path $MIX '.github/prompts/ba.next.prompt.md')) { Ok 'precedence: copilot wins over antigravity' } else { No 'precedence: copilot wins over antigravity' }
    if (-not (Test-Path (Join-Path $MIX '.agents/skills'))) { Ok 'precedence: antigravity not installed when copilot present' } else { No 'precedence: antigravity not installed when copilot present' }
}
finally {
    Remove-Item -LiteralPath $TMP -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output ''
Write-Output "$pass passed, $fail failed"
if ($fail -ne 0) { exit 1 }
exit 0
