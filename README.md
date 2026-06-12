# BA-Kit

> A spec-driven, agent-agnostic framework for **Business Analysts** — clone it, run one
> installer, then drive everything from inside your AI assistant.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Linux%20%7C%20Windows-blue.svg)](#supported-environments)
[![Agents](https://img.shields.io/badge/agents-Copilot%20%7C%20Claude%20%7C%20Cursor%20%7C%20Antigravity-7952b3.svg)](#supported-environments)

BA-Kit turns ideas, notes, and documents into structured, review-ready Markdown artifacts —
requirements, user stories, and shareable pages — by giving your AI assistant a set of **guided BA
activities** ("skills") and a **standard, organized workspace**. Skills are plain Markdown, so the
same framework works across multiple AI assistants and IDEs.

Inspired by [spec-kit](https://github.com/github/spec-kit), but for **BA activities** instead of
software features.

## New here? Start with the docs

| If you want to… | Read |
|-----------------|------|
| Understand the terms (no jargon) | **[Concepts & glossary](docs/concepts.md)** |
| Install and create your first project | **[Getting started](docs/getting-started.md)** |
| Learn the everyday BA flow | **[Working with the default workflow](docs/workflows.md)** |
| Run the consultative idea-to-roadmap process | **[Discovery workflow (advanced)](docs/discovery.md)** |
| See a finished project before you start | **[Worked example](examples/README.md)** |
| Look up a specific skill | **[Skills reference](skills/README.md)** |
| Fix a problem | **[FAQ & troubleshooting](docs/faq.md)** |

## Quickstart

```sh
# 1. Download
git clone https://github.com/aplakhotnik/bakit.git
cd bakit

# 2. Install (one time) — connects the skills to your AI assistant
./install.sh            # macOS / Linux
# .\install.ps1         # Windows (PowerShell 7+)
```

Then, **from inside your AI assistant**, drive the flow by typing `/` commands:

```text
/ba.start-project   # "Start a project called payments-revamp"
/ba.start-task      # "Add a task: elicit-requirements"
#   → drop notes/documents into the task's inputs/ folder
/ba.next            # asks the workflow what to run next, then you pick the suggestion
#   → e.g. /ba.analyze-docs → /ba.specify → /ba.write-stories → /ba.render-confluence
```

Full walkthrough with expected output: **[Getting started](docs/getting-started.md)**.

> **VS Code (Copilot):** after installing, reload the window and trust the folder so the `/ba.*`
> commands appear. See the [FAQ](docs/faq.md) if they don't.

## What you get

- **Agent-driven, guided flow** — start work by invoking skills, not by running scripts.
- **Standardized workspace** — `Project → numbered Task → inputs / artifacts / deliverables`, each
  with a two-level knowledge base (`kb/`).
- **Agent-agnostic BA skills** that produce structured Markdown artifacts:
  - `ba.specify` — a described *need* or raw notes → structured requirements (deep or quick mode).
  - `ba.analyze-docs` — existing documents → extracted requirements, gaps, open questions.
  - `ba.write-stories` — approved requirements → user stories with acceptance criteria.
  - `ba.render-confluence` — approved artifact → local Confluence-ready Markdown.
- **Review gates & traceability** — every artifact carries `status: draft → approved` and provenance
  in YAML front-matter; nothing flows forward until you approve it.
- **Two-level knowledge base** — shared project `kb/` + per-task `kb/` so the AI reuses known facts
  instead of re-asking.
- **Helper scripts** (POSIX shell + PowerShell, full parity) the skills run on your behalf — or that
  you can run directly.
- **A separate, advanced [Discovery workflow](docs/discovery.md)** — a consultative BA/PO state
  machine that turns a plain idea into an estimated, road-mapped backlog.

See **[Working with the default workflow](docs/workflows.md)** for the day-to-day narrative.

## The workflows

- **Default chain** (most BA work): `ba.analyze-docs → ba.specify → ba.write-stories →
  ba.render-confluence`, declared in [`workflow.md`](workflow.md). `ba.next` reads this manifest plus
  your current artifacts to tell you what's runnable now and which artifact must be approved first.
- **Discovery** (advanced, separate): a four-state consultative process declared in
  [`workflow-discovery.md`](workflow-discovery.md). It coexists with the default chain and never
  auto-triggers it. See **[docs/discovery.md](docs/discovery.md)**.

## Supported environments

Every BA skill and helper script works identically across the agent × OS matrix below. The
PowerShell helpers under `scripts/ps/` mirror the POSIX shell helpers one-for-one (same commands,
exit codes, and byte-identical output).

| Agent / IDE         | macOS / Linux (`install.sh`) | Windows (`install.ps1`) | Install location                          |
| ------------------- | :--------------------------: | :---------------------: | ----------------------------------------- |
| VS Code (Copilot)   | ✅ | ✅ | `.github/prompts/*.prompt.md`                            |
| Claude              | ✅ | ✅ | `.claude/commands/*.md`                                  |
| Cursor              | ✅ | ✅ | `.cursor/commands/*.md`                                  |
| Generic             | ✅ | ✅ | `.bakit/skills/*.md`                                     |
| Antigravity IDE     | ✅ | ✅ | `.agents/skills/<skill>/SKILL.md` (or global `~/.gemini/config/skills/`) |

The install locations are **generated** from `skills/` and are git-ignored — edit the source under
`skills/` and re-run the installer. For the interactive menu, flags (`--agent`, `--scope global`),
and auto-detection precedence, run `./install.sh --help` (or `.\install.ps1 -Help`); details are in
**[Getting started](docs/getting-started.md)** and the **[FAQ](docs/faq.md)**.

## Project layout

```text
bakit/
├── install.sh / install.ps1   # one-time installers (macOS/Linux · Windows), full parity
├── workflow.md                # default ordered skill chain + approval gates
├── workflow-discovery.md      # separate Discovery state-machine manifest (advanced)
├── docs/                      # guides: getting-started, concepts, workflows, discovery, faq
├── examples/                  # a finished sample project you can read before running anything
├── skills/                    # agent-agnostic BA skill definitions (+ skills/README.md reference)
├── templates/                 # project + task (kb) + artifact templates
├── scripts/sh/ · scripts/ps/  # POSIX shell + PowerShell helpers (full parity)
├── memory/                    # principles + skill contract surfaced to skills at runtime
├── tests/sh/ · tests/ps/      # mirrored test suites (run in CI on Linux/macOS/Windows)
├── CHANGELOG.md · CONTRIBUTING.md · LICENSE
```

## Contributing

Contributions are welcome — new skills, fixes, docs, and platform-parity work. Read
[CONTRIBUTING.md](CONTRIBUTING.md) and see [skills/README.md](skills/README.md) for how to add a new
skill (drop in a skill file plus its template — no core/installer edits required). All tests in both
`tests/sh/` and `tests/ps/` must pass before a change is merged.

## License

BA-Kit is released under the [MIT License](LICENSE).
