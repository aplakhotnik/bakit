# Windows PowerShell scripts

This directory holds the Windows PowerShell parity of the POSIX shell scripts in `../sh/`
(see FR-006a). It mirrors `../sh/` one-to-one with the same behavior and output contracts.

## Status

**Implemented.** Requires PowerShell 7+ (`pwsh`). The scripts use 5.1-compatible syntax and run
under `pwsh` on Windows, macOS, and Linux. They produce byte-identical template-expansion output
to the shell scripts and return the same exit codes, so either layer can drive the same workspace.

## Parity map

| POSIX (`../sh/`)     | PowerShell (here)     |
| -------------------- | --------------------- |
| `common.sh`          | `common.ps1`          |
| `init-project.sh`    | `init-project.ps1`    |
| `init-task.sh`       | `init-task.ps1`       |
| `list-artifacts.sh`  | `list-artifacts.ps1`  |
| `check-artifact.sh`  | `check-artifact.ps1`  |
| `next-step.sh`       | `next-step.ps1`       |

The installer has a parity too: `../../install.ps1` mirrors `../../install.sh`.

## Usage

```powershell
.\init-project.ps1 "payments-revamp"
.\init-task.ps1 "payments-revamp" "elicit-requirements"
.\next-step.ps1                       # print the recommended next workflow step
.\list-artifacts.ps1 "payments-revamp"
.\check-artifact.ps1 ..\..\workspace\payments-revamp\tasks\001-elicit-requirements\artifacts\requirements.md
```

The workspace defaults to `.\workspace`; override with the `BAKIT_WORKSPACE` environment
variable (same as the shell layer).

The templates (`../../templates/`) and skills (`../../skills/`) are platform-independent and are
not changed by this script layer, satisfying the "add Windows variants without changing the core
structure or skills" requirement.
