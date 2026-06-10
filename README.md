# BA-Kit

> A spec-driven, agent-agnostic framework for **Business Analysts** — clone it, run one
> installer, then drive everything from inside your AI agent.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Linux%20%7C%20Windows-blue.svg)](#supported-environments)
[![Agents](https://img.shields.io/badge/agents-Copilot%20%7C%20Claude%20%7C%20Cursor%20%7C%20Antigravity-7952b3.svg)](#supported-environments)

BA-Kit is inspired by [spec-kit](https://github.com/github/spec-kit), but for **BA activities**
instead of software features. It scaffolds a standardized workspace and guides you skill-by-skill
through a review-gated workflow that turns ideas, notes, and documents into structured,
diff-friendly Markdown artifacts. Skills are plain Markdown, so the same framework works across
multiple AI agents and IDEs.

## Table of contents

- [Prerequisites](#prerequisites)
- [Getting started](#getting-started)
  - [1. Clone the repository](#1-clone-the-repository)
  - [2. Run the installer](#2-run-the-installer)
- [Supported environments](#supported-environments)
  - [Agent auto-detection precedence](#agent-auto-detection-precedence)
- [First run by agent](#first-run-by-agent)
- [Usage: the guided BA flow](#usage-the-guided-ba-flow)
- [What you get](#what-you-get)
- [The workflow](#the-workflow-workflowmd)
- [The Discovery workflow](#the-discovery-workflow-workflow-discoverymd)
- [Knowledge base & review gates](#knowledge-base--review-gates)
- [Project layout](#project-layout)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

- **git** — to clone the repository.
- One supported AI agent / IDE — VS Code (GitHub Copilot), Claude, Cursor, or Antigravity.
- A shell to run the installer:
  - **macOS / Linux** — any POSIX `sh` (built in).
  - **Windows** — [PowerShell 7+](https://learn.microsoft.com/powershell/) (`pwsh`).

No build step, package manager, or network access is required — the installer only copies files.

## Getting started

### 1. Clone the repository

```sh
git clone https://github.com/aplakhotnik/speckit-bakit.git
cd speckit-bakit/bakit
```

### 2. Run the installer

The installer maps the BA skills into your agent's command directory and makes the helper scripts
executable. Run it with **no arguments** for a simple guided menu — ideal for non-technical users.

**macOS / Linux:**

```sh
./install.sh
```

**Windows (PowerShell 7+):**

```powershell
.\install.ps1
```

You'll see a numbered list of agents/IDEs with the ones already detected in your folder
pre-selected. Type the number(s) you want (e.g. `1 3`), press Enter, confirm, and you're done:

```text
Select the agent(s) / IDE(s) to install BA-Kit for.
Enter the numbers separated by spaces (e.g. '1 3'), then press Enter.

  1) [x] VS Code (GitHub Copilot)
  2) [ ] Claude
  3) [ ] Cursor
  4) [ ] Generic
  5) [ ] Antigravity IDE

Your selection (default = pre-selected [x]):
```

Prefer a one-liner (CI, scripts, or if you already know your target)? Pass flags instead of using
the menu:

```sh
./install.sh --agent copilot                 # VS Code Copilot -> .github/prompts/*.prompt.md
./install.sh --agent claude                  # Claude          -> .claude/commands/*.md
./install.sh --agent cursor                  # Cursor          -> .cursor/commands/*.md
./install.sh --agent antigravity             # Antigravity     -> .agents/skills/<skill>/SKILL.md
./install.sh --agent antigravity --scope global   # install Antigravity skills for all workspaces
```

```powershell
.\install.ps1 -Agent copilot
.\install.ps1 -Agent antigravity -Scope global
```

Run `./install.sh --help` (or `.\install.ps1 -Help`) for the full option list. Re-running the
installer is always safe and idempotent.

## Supported environments

Every BA skill and helper script works identically across the agent × OS matrix below. The
PowerShell helpers under `scripts/ps/` mirror the POSIX shell helpers one-for-one (same commands,
exit codes, and byte-identical template-expansion output).

| Agent / IDE         | macOS / Linux (`install.sh`) | Windows (`install.ps1`) | Install location                          |
| ------------------- | :--------------------------: | :---------------------: | ----------------------------------------- |
| VS Code (Copilot)   | ✅ | ✅ | `.github/prompts/*.prompt.md`                            |
| Claude              | ✅ | ✅ | `.claude/commands/*.md`                                  |
| Cursor              | ✅ | ✅ | `.cursor/commands/*.md`                                  |
| Generic             | ✅ | ✅ | `.bakit/skills/*.md`                                     |
| Antigravity IDE     | ✅ | ✅ | `.agents/skills/<skill>/SKILL.md` (or global `~/.gemini/config/skills/`) |

Antigravity skills are installed as **self-contained folders** — each `ba.<skill>/` holds a
`SKILL.md` plus any helper scripts/templates that skill needs, so it works even when installed
globally. Use `--scope global` / `-Scope global` to install once for all your workspaces.

### Agent auto-detection precedence

With no `--agent` / `-Agent` flag in a non-interactive context (CI or piped input), the installer
auto-detects the target from existing directories, in this fixed order:

1. **Copilot** — a `.github/prompts/` or `.github/` directory is present
2. **Claude** — a `.claude/` directory is present
3. **Cursor** — a `.cursor/` directory is present
4. **Antigravity** — a `.agents/` directory is present

The first match wins, so in a **mixed** workspace Copilot is selected; pass an explicit
`--agent` / `-Agent` to override. If none are found, the installer prints manual instructions
instead of guessing — it never blocks.

## First run by agent

**VS Code (Copilot).** The installer writes `.github/prompts/ba.*.prompt.md` and enables prompt
files for the workspace (`chat.promptFiles: true` in `.vscode/settings.json`). To surface the `/`
commands: **Reload the window** (Command Palette → *Developer: Reload Window*) and **Trust the
folder** if prompted. Then type `/` in Copilot Chat and pick e.g. `/ba.start-project`. The
installer never overwrites an existing `.vscode/settings.json`; if one exists without the key it
tells you what to add.

**Claude.** The installer writes every `ba.*` skill into `.claude/commands/ba.*.md`. Open the
workspace in Claude and invoke a skill as a command, e.g. `/ba.start-project`.

**Cursor.** Skills install into `.cursor/commands/ba.*.md`; invoke them the same way.

**Antigravity.** Skills install as `.agents/skills/ba.<skill>/SKILL.md` folders (workspace), or
under `~/.gemini/config/skills/` with `--scope global`. Open the workspace in Antigravity and
invoke a skill, e.g. `ba.start-project`.

The BA skills are identical across agents — only the install location and packaging differ.

## Usage: the guided BA flow

Once installed, drive the rest **from inside your agent** — you don't run scaffolding scripts by
hand:

```text
ba.start-project   # "Start a project called payments-revamp"
ba.start-task      # "Add a task: elicit-requirements"
#   → drop notes/docs into the task's inputs/ folder
ba.next            # asks the workflow what to run next, then you click the suggestion
#   → e.g. ba.analyze-docs / ba.specify → ba.write-stories → ba.render-confluence
```

Prefer scripts? The same scaffolding is available directly:

```sh
./scripts/sh/init-project.sh "payments-revamp"
./scripts/sh/init-task.sh "payments-revamp" "elicit-requirements"
./scripts/sh/next-step.sh                  # print the recommended next workflow step
./scripts/sh/list-artifacts.sh "payments-revamp"
./scripts/sh/check-artifact.sh workspace/payments-revamp/tasks/001-elicit-requirements/artifacts/requirements.md
```

By default the workspace is created under `./workspace`. Override with the `BAKIT_WORKSPACE`
environment variable.

## What you get

- **Agent-driven, guided flow** — start work by invoking skills, not by running scripts:
  - `ba.start-project` — scaffold a project workspace (incl. a shared `kb/`)
  - `ba.start-task` — scaffold a task (`inputs/artifacts/deliverables/kb`)
  - `ba.next` — ask the workflow what to run next (approval-gated, click-ready)
- **Standardized workspace structure** — `Project → numbered Task → inputs/artifacts/deliverables`,
  each with a two-level knowledge base (`kb/`).
- **Helper scripts** (POSIX shell + PowerShell) — scaffold projects/tasks, list artifacts,
  validate status, resolve the next workflow step. Skills invoke these on your behalf.
- **Agent-agnostic BA skills** — guided workflows that produce structured Markdown artifacts:
  - `ba.specify` — a described *need* or raw notes → structured requirements. **Deep mode**
    (default) runs an iterative, KB-grounded clarification loop (persisted in a living
    `elicitation-plan.md`) with a validation gate; **quick mode** captures clear inputs in a
    single pass.
  - `ba.analyze-docs` — existing documents → extracted requirements, gaps, open questions
  - `ba.write-stories` — approved requirements → user stories with acceptance criteria
  - `ba.render-confluence` — approved artifact → local Confluence-ready Markdown
- **Discovery workflow (separate, additive)** — a consultative BA/PO state machine that turns a
  plain idea into an estimated, road-mapped backlog, persisting a Living Discovery Document:
  - `ba.discover.initiate` → `ba.discover.gap-analysis` → `ba.discover.backlog` →
    `ba.discover.estimate`, with `ba.discover.next` for guidance. Declared in
    `workflow-discovery.md`; coexists with the default chain and never auto-triggers it.
- **Declarative workflow** — `workflow.md` defines the ordered skill chain and per-step approval
  gates; it is the single source of truth for next-step suggestions.
- **Two-level knowledge base + lightweight RLM** — a shared project `kb/` and per-task `kb/`,
  each with an auto-seeded `index.md`. Skills read the index first and only recurse into details
  when needed (Recursive-Language-Model style), so large inputs don't overwhelm context.
- **Review gates & traceability** — every artifact carries `status: draft → approved` and
  provenance in YAML front-matter.

## The workflow (`workflow.md`)

`workflow.md` declares the ordered chain and each step's approval gate:

```text
ba.analyze-docs → ba.specify → ba.write-stories → ba.render-confluence
```

`next-step.sh` (and the `ba.next` skill) read this manifest plus the current artifacts to tell
you exactly what is runnable now and which artifact, if any, must be approved first. Every skill
also ends with a **Next steps** block derived from the same manifest, so the guided path is
consistent everywhere.

## The Discovery workflow (`workflow-discovery.md`)

Alongside the default chain there is a **separate, more robust Discovery workflow** — a
consultative BA/PO that walks a stakeholder from a plain project idea to an estimated,
road-mapped backlog. It is **additive**: it does not modify or replace the default chain, and the
two coexist without interference.

It is a **sequential four-state machine** declared in its own manifest, `workflow-discovery.md`,
and it persists a single **Living Discovery Document** (`artifacts/discovery-document.md`) across
every state:

```text
ba.discover.initiate → ba.discover.gap-analysis → ba.discover.backlog → ba.discover.estimate
   (Project Charter)      (Gap Analysis Matrix)     (Product Backlog)    (Estimated Backlog + Roadmap)
```

- **Explicit phase gates.** Each state refuses to advance until the prior state's deliverable is
  `status: approved` (the same approval gate the default chain uses).
- **Zero-assumption.** When something is ambiguous or missing, the agent halts and asks targeted
  questions rather than inventing business content; deferred items are recorded as open questions.
- **Stateful + resumable.** The Living Discovery Document is the canonical record and lets an
  interrupted session resume at the right state.

Ask the Discovery workflow what to run next (it reads its own manifest, never `workflow.md`):

```sh
./scripts/sh/next-step.sh --workflow workflow-discovery.md      # macOS/Linux
./scripts/ps/next-step.ps1 -Workflow workflow-discovery.md      # Windows
```

The `ba.discover.next` skill is the convenient entry point and also flags any downstream state
made **stale** by an edit to an approved upstream deliverable. You **may** optionally hand an
approved Discovery deliverable to an existing skill (e.g. feed the Product Backlog into
`ba.write-stories`), but the Discovery workflow never auto-triggers downstream skills.

## Knowledge base & review gates

**Two-level KB + lightweight RLM.** Each project gets a shared `kb/` and each task its own `kb/`,
both seeded with an `index.md` (`## Summary` + `## Entries`). Skills ground their work by reading
the project index first, then the task index (task knowledge takes precedence). For large or
multi-document inputs they apply a lightweight **Recursive Language Model** strategy — consult the
index, then recurse into only the relevant entries — degrading to a single pass for small inputs.
A missing or empty `kb/` is never an error.

**Review gates.**

1. A skill writes a `draft` artifact into the active task's `artifacts/`.
2. You review/edit it, then set `status: approved` in its front-matter.
3. Downstream skills refuse or warn unless their upstream artifact is `approved` — enforcing
   human-in-the-loop review. Approval is verified with
   `./scripts/sh/check-artifact.sh --require-approved <artifact.md>`.

**Diff-friendly artifacts.** Every template and artifact is plain Markdown with a YAML
front-matter block — no binary or opaque content — so revisions and their rationale stay
reviewable in git over time. The `updated` front-matter field advances on each edit.

## Project layout

```text
bakit/
├── install.sh              # installer (macOS/Linux) — interactive menu + flags
├── install.ps1             # installer (Windows PowerShell) — parity with install.sh
├── workflow.md             # declarative ordered skill chain + approval gates
├── workflow-discovery.md   # separate Discovery state-machine manifest (additive)
├── skills/                 # agent-agnostic BA skill definitions
├── templates/              # project + task (kb) + artifact templates
├── scripts/sh/             # POSIX shell helper scripts (macOS/Linux)
├── scripts/ps/             # PowerShell helper scripts (Windows) — parity with scripts/sh
├── memory/                 # BA principles surfaced to skills at runtime
├── tests/sh/               # shell tests for the scripts
├── tests/ps/               # PowerShell tests — parity with tests/sh
├── LICENSE                 # MIT
└── CONTRIBUTING.md         # contribution guide
```

## Contributing

Contributions are welcome — new skills, fixes, docs, and platform-parity work. Please read
[CONTRIBUTING.md](CONTRIBUTING.md) and see [skills/README.md](skills/README.md) for how to add a
new skill (drop in a skill file plus its template — no core/installer edits required). All tests
in both `tests/sh/` and `tests/ps/` must pass before a change is merged.

## License

BA-Kit is released under the [MIT License](LICENSE).
