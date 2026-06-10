# Tests for install.ps1: maps skills for Copilot and Claude targets.
#
# Scope mirrors test-install.sh (minus the Unix exec-bit checks, which do not
# apply on the PowerShell/Windows side). Claude assertions verify skill
# placement, naming, and idempotency; in-Claude invocation is verified manually
# per quickstart Scenario 1.

$ErrorActionPreference = 'Stop'
$SCRIPT_DIR = $PSScriptRoot
$BAKIT_HOME = (Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR))
$INSTALL = (Join-Path $BAKIT_HOME 'install.ps1')

$TMP = (Join-Path ([System.IO.Path]::GetTempPath()) ("bakit-" + [guid]::NewGuid().ToString('N')))
New-Item -ItemType Directory -Force -Path $TMP | Out-Null

$pass = 0; $fail = 0
function Ok { param($m) $script:pass++; Write-Output "ok   - $m" }
function No { param($m) $script:fail++; Write-Output "FAIL - $m" }

# Run install.ps1 from within a working directory.
function Run-Install {
    param([string]$WorkDir, [hashtable]$InstallArgs = @{})
    Push-Location $WorkDir
    try {
        & $INSTALL @InstallArgs 2>$null 1>$null
        return $LASTEXITCODE
    }
    finally { Pop-Location }
}

# Run install.ps1 as a child pwsh process with a redirected stdin. Required for
# no-argument (menu / auto-detect) runs: [Console]::ReadLine reads the real
# console, not a PowerShell pipeline, so the menu code path can only be driven
# (or forced non-interactive) through a child process whose stdin is a pipe.
function Run-InstallChild {
    param([string]$WorkDir, [object[]]$ArgsList = @(), [string]$StdinText = '', [switch]$AssumeMenu)
    Push-Location $WorkDir
    $old = $env:BAKIT_ASSUME_MENU
    if ($AssumeMenu) { $env:BAKIT_ASSUME_MENU = '1' } else { Remove-Item Env:BAKIT_ASSUME_MENU -ErrorAction SilentlyContinue }
    try {
        $StdinText | & pwsh -NoProfile -File $INSTALL @ArgsList 2>$null 1>$null
        return $LASTEXITCODE
    }
    finally {
        if ($null -ne $old) { $env:BAKIT_ASSUME_MENU = $old } else { Remove-Item Env:BAKIT_ASSUME_MENU -ErrorAction SilentlyContinue }
        Pop-Location
    }
}

$skills = @(
    'ba.specify', 'ba.analyze-docs', 'ba.write-stories', 'ba.render-confluence',
    'ba.start-project', 'ba.start-task', 'ba.next'
)

try {
    # --- Copilot target ----------------------------------------------------
    $WORKDIR = (Join-Path $TMP 'work')
    New-Item -ItemType Directory -Force -Path $WORKDIR | Out-Null
    $DEST = (Join-Path $WORKDIR '.github/prompts')
    if ((Run-Install $WORKDIR @{ Dest = $DEST }) -eq 0) { Ok 'installer runs cleanly with -Dest' } else { No 'installer runs cleanly with -Dest' }

    $mapped = $true
    foreach ($s in $skills) { if (-not (Test-Path (Join-Path $DEST "$s.prompt.md"))) { $mapped = $false } }
    if ($mapped) { Ok 'all skills mapped with .prompt.md extension' } else { No 'all skills mapped with .prompt.md extension' }

    if (-not (Test-Path (Join-Path $DEST '_skill-template.prompt.md'))) { Ok 'internal templates not mapped' } else { No 'internal templates not mapped' }

    $SETTINGS = (Join-Path $WORKDIR '.vscode/settings.json')
    if (Test-Path $SETTINGS) { Ok '.vscode/settings.json created' } else { No '.vscode/settings.json created' }
    if (Select-String -LiteralPath $SETTINGS -Pattern '"chat.promptFiles"' -Quiet) { Ok 'chat.promptFiles enabled in settings' } else { No 'chat.promptFiles enabled in settings' }

    # Re-run is idempotent and preserves an existing settings.json.
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($SETTINGS, "{`n  `"editor.tabSize`": 2,`n  `"chat.promptFiles`": true`n}`n", $enc)
    Run-Install $WORKDIR @{ Dest = $DEST } | Out-Null
    if (Select-String -LiteralPath $SETTINGS -Pattern '"editor.tabSize"' -Quiet) { Ok 'existing settings.json preserved on re-run' } else { No 'existing settings.json preserved on re-run' }

    # --- Claude target -----------------------------------------------------
    $CWORK = (Join-Path $TMP 'claude-explicit')
    New-Item -ItemType Directory -Force -Path $CWORK | Out-Null
    if ((Run-Install $CWORK @{ Agent = 'claude' }) -eq 0) { Ok 'claude installer runs cleanly' } else { No 'claude installer runs cleanly' }
    $CDEST = (Join-Path $CWORK '.claude/commands')
    if (Test-Path $CDEST) { Ok 'claude: .claude/commands/ created when absent' } else { No 'claude: .claude/commands/ created when absent' }

    $cmapped = $true
    foreach ($s in $skills) { if (-not (Test-Path (Join-Path $CDEST "$s.md"))) { $cmapped = $false } }
    if ($cmapped) { Ok 'claude: all skills mapped with plain .md extension' } else { No 'claude: all skills mapped with plain .md extension' }
    if (-not (Test-Path (Join-Path $CDEST 'ba.next.prompt.md'))) { Ok 'claude: no .prompt.md naming' } else { No 'claude: no .prompt.md naming' }
    if (-not (Test-Path (Join-Path $CDEST '_skill-template.md'))) { Ok 'claude: internal templates not mapped' } else { No 'claude: internal templates not mapped' }
    if (-not (Test-Path (Join-Path $CWORK '.vscode/settings.json'))) { Ok 'claude: no .vscode/settings.json' } else { No 'claude: no .vscode/settings.json' }
    Run-Install $CWORK @{ Agent = 'claude' } | Out-Null
    if (Test-Path (Join-Path $CDEST 'ba.next.md')) { Ok 'claude: re-run idempotent' } else { No 'claude: re-run idempotent' }

    # Auto-detect (non-interactive fallback): a single detected target is
    # selected and the menu never blocks (stdin is a redirected pipe).
    $CAUTO = (Join-Path $TMP 'claude-auto')
    New-Item -ItemType Directory -Force -Path (Join-Path $CAUTO '.claude') | Out-Null
    Run-InstallChild $CAUTO @() '' | Out-Null
    if (Test-Path (Join-Path $CAUTO '.claude/commands/ba.next.md')) { Ok 'auto-detect: lone .claude/ -> claude' } else { No 'auto-detect: lone .claude/ -> claude' }

    # Mixed-agent precedence: both .github/ and .claude/ -> Copilot wins.
    $CMIX = (Join-Path $TMP 'claude-mixed')
    New-Item -ItemType Directory -Force -Path (Join-Path $CMIX '.github') | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $CMIX '.claude') | Out-Null
    Run-InstallChild $CMIX @() '' | Out-Null
    if (Test-Path (Join-Path $CMIX '.github/prompts/ba.next.prompt.md')) { Ok 'mixed-agent: precedence selects copilot' } else { No 'mixed-agent: precedence selects copilot' }
    if (-not (Test-Path (Join-Path $CMIX '.claude/commands/ba.next.md'))) { Ok 'mixed-agent: .claude left untouched' } else { No 'mixed-agent: .claude left untouched' }

    # No marker + non-interactive: fall back to manual instructions, never block.
    $CNONE = (Join-Path $TMP 'none-noninteractive')
    New-Item -ItemType Directory -Force -Path $CNONE | Out-Null
    $rc = Run-InstallChild $CNONE @() ''
    if (($rc -eq 0) -and (-not (Test-Path (Join-Path $CNONE '.github'))) -and (-not (Test-Path (Join-Path $CNONE '.claude')))) { Ok 'no marker + non-interactive: no block, nothing installed' } else { No 'no marker + non-interactive: no block, nothing installed' }

    # --- Interactive multi-select menu (US1) -------------------------------
    # Driven via a child process with piped stdin + BAKIT_ASSUME_MENU=1.

    # Single selection: option 1 (copilot) + confirm.
    $MSINGLE = (Join-Path $TMP 'menu-single')
    New-Item -ItemType Directory -Force -Path $MSINGLE | Out-Null
    Run-InstallChild $MSINGLE @() "1`ny" -AssumeMenu | Out-Null
    if (Test-Path (Join-Path $MSINGLE '.github/prompts/ba.next.prompt.md')) { Ok 'menu: single selection installs copilot' } else { No 'menu: single selection installs copilot' }

    # Multi-selection: options 1 (copilot) + 2 (claude) at once.
    $MMULTI = (Join-Path $TMP 'menu-multi')
    New-Item -ItemType Directory -Force -Path $MMULTI | Out-Null
    Run-InstallChild $MMULTI @() "1 2`ny" -AssumeMenu | Out-Null
    if ((Test-Path (Join-Path $MMULTI '.github/prompts/ba.next.prompt.md')) -and (Test-Path (Join-Path $MMULTI '.claude/commands/ba.next.md'))) { Ok 'menu: multi-selection installs copilot + claude' } else { No 'menu: multi-selection installs copilot + claude' }

    # Decline confirmation: nothing installed.
    $MCANCEL = (Join-Path $TMP 'menu-cancel')
    New-Item -ItemType Directory -Force -Path $MCANCEL | Out-Null
    Run-InstallChild $MCANCEL @() "1`nn" -AssumeMenu | Out-Null
    if (-not (Test-Path (Join-Path $MCANCEL '.github'))) { Ok 'menu: declining confirmation installs nothing' } else { No 'menu: declining confirmation installs nothing' }

    # Empty selection accepts the pre-selected (auto-detected) defaults.
    $MDEFAULT = (Join-Path $TMP 'menu-default')
    New-Item -ItemType Directory -Force -Path (Join-Path $MDEFAULT '.cursor') | Out-Null
    Run-InstallChild $MDEFAULT @() "`ny" -AssumeMenu | Out-Null
    if (Test-Path (Join-Path $MDEFAULT '.cursor/commands/ba.next.md')) { Ok 'menu: empty input accepts pre-selected default' } else { No 'menu: empty input accepts pre-selected default' }
}
finally {
    Remove-Item -LiteralPath $TMP -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output ''
Write-Output "$pass passed, $fail failed"
if ($fail -ne 0) { exit 1 }
exit 0
