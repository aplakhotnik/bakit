# Windows PowerShell scripts (planned — not implemented in v1)

This directory is a placeholder for the planned Windows PowerShell parity of the POSIX shell
scripts in `../sh/` (see FR-006a).

## Status

**v1 ships shell scripts only** (`../sh/`, macOS/Linux). Windows support is a later enhancement.

## Plan

When implemented, this folder will mirror `../sh/` one-to-one, with the same behavior and
output contracts:

| POSIX (`../sh/`) | PowerShell (planned, here) |
|------------------|----------------------------|
| `common.sh` | `common.ps1` |
| `init-project.sh` | `init-project.ps1` |
| `init-task.sh` | `init-task.ps1` |
| `list-artifacts.sh` | `list-artifacts.ps1` |
| `check-artifact.sh` | `check-artifact.ps1` |

The templates (`../../templates/`) and skills (`../../skills/`) are platform-independent and
will not change — only this script layer is added, satisfying the "add Windows variants without
changing the core structure or skills" requirement.
