# Contributing to BA-Kit

Thanks for your interest in improving BA-Kit! This project is a tool-agnostic,
Markdown-first framework for Business Analysts. Contributions of all kinds are
welcome: new skills, bug fixes, documentation, and platform parity work.

## Ground rules

BA-Kit follows a small set of non-negotiable principles (see
`memory/ba-constitution.md`). In short:

1. **Specification-first** — behavior is described before it is implemented.
2. **Modular, activity-based skills** — each skill does one BA activity well.
3. **Human-in-the-loop** — artifacts move `draft → approved`; nothing skips review.
4. **Traceability & source grounding** — outputs cite their inputs/knowledge base.
5. **Structured, tool-agnostic outputs** — plain Markdown + YAML front-matter, no
   binary or agent-specific formats.

## Project layout

| Path | Purpose |
|------|---------|
| `skills/` | Agent-agnostic BA skill definitions (`ba.*.md`). |
| `templates/` | Project, task, and artifact templates. |
| `workflow.md` / `workflow-discovery.md` | Declarative ordered skill chains + approval gates. |
| `scripts/sh/` · `scripts/ps/` | POSIX shell and PowerShell helper scripts (full parity). |
| `tests/sh/` · `tests/ps/` | Test suites mirroring each other across shells. |
| `install.sh` · `install.ps1` | Installers that map skills into each supported agent/IDE. |

## Development setup

### Prerequisites

- `git`
- POSIX shell (`sh`) for `tests/sh/*`
- PowerShell 7+ (`pwsh`) for `tests/ps/*`

If you do not have `git` yet:

- macOS: `xcode-select --install`
- Windows: install Git for Windows from https://git-scm.com/download/win
- Linux: install from your distro package manager (for example, `sudo apt install git`)

No build step and no network access are required. Clone the repository and run
the test suites:

```sh
# macOS / Linux
sh tests/sh/run-all.sh

# Windows / PowerShell 7+
pwsh -File tests/ps/run-all.ps1
```

All suites must pass before a change is merged.

## Adding a new skill

See [skills/README.md](skills/README.md). In short: drop a new `ba.<name>.md`
skill file (and any template it needs) into `skills/` / `templates/`. The
installers discover skills by naming convention — **no installer changes are
needed** to ship a new skill to every supported agent/IDE.

## Cross-platform parity

Every change to a POSIX shell helper (`scripts/sh/`) must be mirrored in its
PowerShell counterpart (`scripts/ps/`), and vice versa. The two layers must
produce the same commands, exit codes, and byte-identical template output. Add
or update the matching tests in both `tests/sh/` and `tests/ps/`.

## Pull requests

1. Keep changes focused and additive where possible.
2. Update or add tests in **both** shells for any behavior change.
3. Update the README / skill docs when user-facing behavior changes.
4. Ensure `tests/sh/run-all.sh` and `tests/ps/run-all.ps1` both pass.

## License

By contributing, you agree that your contributions will be licensed under the
[MIT License](LICENSE).
