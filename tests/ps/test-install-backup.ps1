# Tests for install.ps1 upgrade/backup/preview behavior (feature 009).
#
# Mirrors tests/sh/test-install-backup.sh: covers the flat-file scenarios of
# contracts/parity-and-tests.md (T-1..T-4, T-6..T-15). The Antigravity bundle
# case (T-5) lives in test-install-antigravity.ps1.

$ErrorActionPreference = 'Stop'
$SCRIPT_DIR = $PSScriptRoot
$BAKIT_HOME = (Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR))
$INSTALL = (Join-Path $BAKIT_HOME 'install.ps1')

$TMP = (Join-Path ([System.IO.Path]::GetTempPath()) ("bakit-" + [guid]::NewGuid().ToString('N')))
New-Item -ItemType Directory -Force -Path $TMP | Out-Null

$pass = 0; $fail = 0
function Ok { param($m) $script:pass++; Write-Output "ok   - $m" }
function No { param($m) $script:fail++; Write-Output "FAIL - $m" }

# Run install.ps1 as a child process (isolates exit/abort) capturing combined
# output. Honors $BackupTs for BAKIT_BACKUP_TS deterministic timestamps.
function Invoke-InstallCapture {
    param([string]$WorkDir, [object[]]$ArgsList = @(), [string]$BackupTs = '')
    Push-Location $WorkDir
    $old = $env:BAKIT_BACKUP_TS
    $oldPwd = $env:PWD
    # A real shell exports PWD to child processes; mirror that so the installer's
    # workspace-relative backup paths resolve consistently across symlinks.
    $env:PWD = $WorkDir
    if ($BackupTs) { $env:BAKIT_BACKUP_TS = $BackupTs } else { Remove-Item Env:BAKIT_BACKUP_TS -ErrorAction SilentlyContinue }
    try {
        $out = & pwsh -NoProfile -File $INSTALL @ArgsList 2>&1 | Out-String
        return [pscustomobject]@{ Output = $out; ExitCode = $LASTEXITCODE }
    }
    finally {
        if ($null -ne $old) { $env:BAKIT_BACKUP_TS = $old } else { Remove-Item Env:BAKIT_BACKUP_TS -ErrorAction SilentlyContinue }
        if ($null -ne $oldPwd) { $env:PWD = $oldPwd } else { Remove-Item Env:PWD -ErrorAction SilentlyContinue }
        Pop-Location
    }
}

# Copy the package's ba.next / ba.specify source skill into a destination.
function Copy-Skill { param($Name, $To) Copy-Item -LiteralPath (Join-Path $BAKIT_HOME "skills/$Name.md") -Destination $To -Force }

try {
    # --- T-4: fresh install -> all added, no backup folder -----------------
    $W = (Join-Path $TMP 't4'); New-Item -ItemType Directory -Force -Path $W | Out-Null
    $r = Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts'))
    if (($r.ExitCode -eq 0) -and ($r.Output -match 'added: ba\.next') -and (-not (Test-Path (Join-Path $W '.bakit-backup')))) {
        Ok 'T-4: fresh install reports added, no backup folder'
    } else { No 'T-4: fresh install reports added, no backup folder' }

    # --- T-1: tuned flat-file backed up (old content) before overwrite -----
    $W = (Join-Path $TMP 't1'); New-Item -ItemType Directory -Force -Path (Join-Path $W '.github/prompts') | Out-Null
    Copy-Skill 'ba.next' (Join-Path $W '.github/prompts/ba.next.prompt.md')
    Add-Content -LiteralPath (Join-Path $W '.github/prompts/ba.next.prompt.md') -Value 'LOCAL-TUNING'
    $r = Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts')) '20200101T000000Z'
    $bk = (Join-Path $W '.bakit-backup/20200101T000000Z/.github/prompts/ba.next.prompt.md')
    $live = (Join-Path $W '.github/prompts/ba.next.prompt.md')
    if ((Test-Path $bk) -and ((Get-Content -Raw $bk) -match 'LOCAL-TUNING') -and (-not ((Get-Content -Raw $live) -match 'LOCAL-TUNING'))) {
        Ok 'T-1: tuned file backed up before overwrite; new content live'
    } else { No 'T-1: tuned file backed up before overwrite; new content live' }

    # --- T-2: identical file is unchanged, no backup -----------------------
    $W = (Join-Path $TMP 't2'); New-Item -ItemType Directory -Force -Path (Join-Path $W '.github/prompts') | Out-Null
    Copy-Skill 'ba.next' (Join-Path $W '.github/prompts/ba.next.prompt.md')
    $r = Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts'))
    if (($r.Output -match 'unchanged: ba\.next') -and (-not (Test-Path (Join-Path $W '.bakit-backup')))) {
        Ok 'T-2: identical file classified unchanged, no backup'
    } else { No 'T-2: identical file classified unchanged, no backup' }

    # --- T-3 / T-6: idempotent re-run -> unchanged, no backup folder -------
    $W = (Join-Path $TMP 't3'); New-Item -ItemType Directory -Force -Path $W | Out-Null
    Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts')) | Out-Null
    $r = Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts'))
    if (($r.ExitCode -eq 0) -and ($r.Output -match 'unchanged: ba\.next') -and (-not ($r.Output -match 'backed-up:')) -and (-not (Test-Path (Join-Path $W '.bakit-backup')))) {
        Ok 'T-3/T-6: clean re-run is all unchanged, no backup folder'
    } else { No 'T-3/T-6: clean re-run is all unchanged, no backup folder' }

    # --- T-7: stale flat-file surfaced, not deleted ------------------------
    $W = (Join-Path $TMP 't7'); New-Item -ItemType Directory -Force -Path (Join-Path $W '.github/prompts') | Out-Null
    Set-Content -LiteralPath (Join-Path $W '.github/prompts/ba.ghost.prompt.md') -Value 'orphan'
    $r = Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts'))
    if (($r.Output -match 'stale: ba\.ghost') -and (Test-Path (Join-Path $W '.github/prompts/ba.ghost.prompt.md'))) {
        Ok 'T-7: stale command reported and left on disk'
    } else { No 'T-7: stale command reported and left on disk' }

    # --- T-8: preview reports 'safe' when nothing is tuned -----------------
    $W = (Join-Path $TMP 't8'); New-Item -ItemType Directory -Force -Path $W | Out-Null
    Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts')) | Out-Null
    $r = Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts'), '-Check')
    if ($r.Output -match 'Safe to upgrade') {
        Ok 'T-8: preview reports safe to upgrade'
    } else { No 'T-8: preview reports safe to upgrade' }

    # --- T-9: preview lists exactly the modified file(s) -------------------
    $W = (Join-Path $TMP 't9'); New-Item -ItemType Directory -Force -Path (Join-Path $W '.github/prompts') | Out-Null
    Copy-Skill 'ba.next' (Join-Path $W '.github/prompts/ba.next.prompt.md')
    Add-Content -LiteralPath (Join-Path $W '.github/prompts/ba.next.prompt.md') -Value 'LOCAL'
    $r = Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts'), '-Check')
    if (($r.Output -match 'Local modifications detected') -and ($r.Output -match '- \.github/prompts/ba\.next\.prompt\.md')) {
        Ok 'T-9: preview lists the modified file'
    } else { No 'T-9: preview lists the modified file' }

    # --- T-10: -Check makes no changes -------------------------------------
    $W = (Join-Path $TMP 't10'); New-Item -ItemType Directory -Force -Path (Join-Path $W '.github/prompts') | Out-Null
    Copy-Skill 'ba.next' (Join-Path $W '.github/prompts/ba.next.prompt.md')
    Add-Content -LiteralPath (Join-Path $W '.github/prompts/ba.next.prompt.md') -Value 'LOCAL'
    Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts'), '-Check') | Out-Null
    if (((Get-Content -Raw (Join-Path $W '.github/prompts/ba.next.prompt.md')) -match 'LOCAL') `
        -and (-not (Test-Path (Join-Path $W '.bakit-backup'))) `
        -and (-not (Test-Path (Join-Path $W '.gitignore'))) `
        -and (-not (Test-Path (Join-Path $W '.github/prompts/ba.specify.prompt.md')))) {
        Ok 'T-10: -Check writes nothing (no overwrite, backup, gitignore, or new files)'
    } else { No 'T-10: -Check writes nothing (no overwrite, backup, gitignore, or new files)' }

    # --- T-11: .gitignore enforced once, idempotent on repeat --------------
    $W = (Join-Path $TMP 't11'); New-Item -ItemType Directory -Force -Path (Join-Path $W '.github/prompts') | Out-Null
    Set-Content -LiteralPath (Join-Path $W '.gitignore') -Value 'node_modules/'
    $live = (Join-Path $W '.github/prompts/ba.next.prompt.md')
    Copy-Skill 'ba.next' $live
    Add-Content -LiteralPath $live -Value 'LOCAL1'
    Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts')) '20200102T000000Z' | Out-Null
    Add-Content -LiteralPath $live -Value 'LOCAL2'
    Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts')) '20200103T000000Z' | Out-Null
    $giLines = @(Get-Content -LiteralPath (Join-Path $W '.gitignore') | Where-Object { $_ -eq '.bakit-backup/' })
    if (($giLines.Count -eq 1) -and ((Get-Content -LiteralPath (Join-Path $W '.gitignore')) -contains 'node_modules/')) {
        Ok 'T-11: .gitignore contains .bakit-backup/ exactly once (idempotent)'
    } else { No 'T-11: .gitignore contains .bakit-backup/ exactly once (idempotent)' }

    # --- T-12: user work under workspace/ is untouched ---------------------
    $W = (Join-Path $TMP 't12'); New-Item -ItemType Directory -Force -Path (Join-Path $W 'workspace/demo/tasks/001/artifacts') | Out-Null
    $art = (Join-Path $W 'workspace/demo/tasks/001/artifacts/requirements.md')
    Set-Content -LiteralPath $art -Value "my analysis`nline2"
    $ref = (Get-FileHash -LiteralPath $art).Hash
    Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts')) | Out-Null
    if ((Get-FileHash -LiteralPath $art).Hash -eq $ref) {
        Ok 'T-12: user workspace content left byte-identical'
    } else { No 'T-12: user workspace content left byte-identical' }

    # --- T-13: fail-safe when the backup location is unwritable ------------
    $W = (Join-Path $TMP 't13'); New-Item -ItemType Directory -Force -Path (Join-Path $W '.github/prompts') | Out-Null
    $live = (Join-Path $W '.github/prompts/ba.next.prompt.md')
    Copy-Skill 'ba.next' $live
    Add-Content -LiteralPath $live -Value 'KEEPME'
    # A regular file where the backup root must be a directory blocks creation.
    Set-Content -LiteralPath (Join-Path $W '.bakit-backup') -Value 'block'
    $r = Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts'))
    if (($r.ExitCode -ne 0) -and ((Get-Content -Raw $live) -match 'KEEPME')) {
        Ok 'T-13: aborts without overwriting the tuned file'
    } else { No 'T-13: aborts without overwriting the tuned file' }

    # --- T-14: collision suffix -> second run gets -2, neither overwritten -
    $W = (Join-Path $TMP 't14'); New-Item -ItemType Directory -Force -Path (Join-Path $W '.github/prompts') | Out-Null
    $live = (Join-Path $W '.github/prompts/ba.next.prompt.md')
    Copy-Skill 'ba.next' $live
    Add-Content -LiteralPath $live -Value 'RUN1'
    Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts')) '20200104T000000Z' | Out-Null
    Add-Content -LiteralPath $live -Value 'RUN2'
    Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts')) '20200104T000000Z' | Out-Null
    $b1 = (Join-Path $W '.bakit-backup/20200104T000000Z/.github/prompts/ba.next.prompt.md')
    $b2 = (Join-Path $W '.bakit-backup/20200104T000000Z-2/.github/prompts/ba.next.prompt.md')
    if ((Test-Path $b1) -and (Test-Path $b2) -and ((Get-Content -Raw $b1) -match 'RUN1') -and ((Get-Content -Raw $b2) -match 'RUN2')) {
        Ok 'T-14: same-timestamp re-run uses -2 suffix, neither overwritten'
    } else { No 'T-14: same-timestamp re-run uses -2 suffix, neither overwritten' }

    # --- T-15: change report completeness ----------------------------------
    $W = (Join-Path $TMP 't15'); New-Item -ItemType Directory -Force -Path (Join-Path $W '.github/prompts') | Out-Null
    Copy-Skill 'ba.next' (Join-Path $W '.github/prompts/ba.next.prompt.md')                 # unchanged
    Copy-Skill 'ba.specify' (Join-Path $W '.github/prompts/ba.specify.prompt.md')
    Add-Content -LiteralPath (Join-Path $W '.github/prompts/ba.specify.prompt.md') -Value 'TUNED'  # backed-up
    Set-Content -LiteralPath (Join-Path $W '.github/prompts/ba.ghost.prompt.md') -Value 'orphan'   # stale
    $r = Invoke-InstallCapture $W @('-Dest', (Join-Path $W '.github/prompts')) '20200105T000000Z'
    if (($r.Output -match 'unchanged: ba\.next') -and ($r.Output -match 'backed-up: ba\.specify') `
        -and ($r.Output -match 'stale: ba\.ghost') -and ($r.Output -match 'added: ba\.analyze-docs') `
        -and ($r.Output -match 'Backed up 1 file')) {
        Ok 'T-15: report covers added/unchanged/backed-up/stale + backup location'
    } else { No 'T-15: report covers added/unchanged/backed-up/stale + backup location' }

    Write-Output ''
    Write-Output ("{0} passed, {1} failed" -f $pass, $fail)
}
finally {
    Remove-Item -Recurse -Force -LiteralPath $TMP -ErrorAction SilentlyContinue
}
if ($fail -ne 0) { exit 1 }
exit 0
