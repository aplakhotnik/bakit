# BA-Kit

A spec-driven framework for **Business Analysts** — inspired by
[spec-kit](https://github.com/github/spec-kit), but for BA activities instead of software
features. Clone it, run the installer, then drive everything from inside your AI agent: it
scaffolds a standardized workspace for you and guides you skill-by-skill through the workflow.

## What you get

- **Agent-driven, guided flow** — start work by invoking skills, not by running scripts:
  - `ba.start-project` — scaffold a project workspace (incl. a shared `kb/`)
  - `ba.start-task` — scaffold a task (`inputs/artifacts/deliverables/kb`)
  - `ba.next` — ask the workflow what to run next (approval-gated, click-ready)
- **Standardized workspace structure** — `Project → numbered Task → inputs/artifacts/deliverables`,
  each with a two-level knowledge base (`kb/`).
- **Helper scripts** (POSIX shell) — scaffold projects/tasks, list artifacts, validate status,
  resolve the next workflow step. Skills invoke these on your behalf.
- **Agent-agnostic BA skills** — guided workflows that produce structured Markdown artifacts:
  - `ba.specify` — a described *need* → rigorous specification, via an iterative, KB-grounded
    clarification loop (persisted in a living `elicitation-plan.md`) with a validation gate
  - `ba.specify-requirements` — raw inputs → structured requirements (lightweight path)
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

## Quick start

```sh
# 1. Install (maps skills into your agent's prompt directory, makes scripts executable)
./install.sh                      # auto-detects agent
./install.sh --agent copilot      # VS Code Copilot  -> .github/prompts/*.prompt.md
./install.sh --agent claude       # Claude           -> .claude/commands/*.md
```

On **Windows** (PowerShell 7+), use the parity installer — same flags, same result:

```powershell
.\install.ps1                      # auto-detects agent
.\install.ps1 -Agent copilot       # VS Code Copilot -> .github/prompts/*.prompt.md
.\install.ps1 -Agent claude        # Claude          -> .claude/commands/*.md
```

Then drive the rest **from inside your agent** — you don't run scaffolding scripts by hand:

```text
ba.start-project   # "Start a project called payments-revamp"
ba.start-task      # "Add a task: elicit-requirements"
#   → drop notes/docs into the task's inputs/ folder
ba.next            # asks the workflow what to run next, then you click the suggestion
#   → e.g. ba.analyze-docs / ba.specify-requirements → ba.write-stories → ba.render-confluence
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

## First run in VS Code (Copilot)

When you install with `--agent copilot`, the installer writes skills as
`.github/prompts/ba.*.prompt.md` and enables VS Code's prompt-file discovery for the workspace
(`chat.promptFiles: true` in `.vscode/settings.json`). For the `/` slash commands to appear:

1. **Reload the window** — Command Palette → *Developer: Reload Window* (the prompt files are
   scanned on load).
2. **Trust the folder** — if VS Code shows the Workspace Trust prompt, choose *Trust*. In a
   restricted (untrusted) workspace, workspace settings and prompt-file discovery are limited,
   so the skills won't resolve until the folder is trusted. (Workspace Trust is a VS Code
   security control; the installer intentionally does not try to bypass it.)

Then type `/` in Copilot Chat and pick e.g. `/ba.start-project`. The installer never overwrites
an existing `.vscode/settings.json`; if one exists without the key it tells you what to add.

## First run in Claude

Install with `--agent claude` (POSIX) or `-Agent claude` (PowerShell) and the installer writes
every `ba.*` skill into `.claude/commands/ba.*.md` — Claude's convention for custom commands. No
VS Code workspace settings are created (they don't apply to Claude). After installing:

1. Open the workspace in Claude so it picks up `.claude/commands/`.
2. Invoke a skill as a command, e.g. `/ba.start-project`, just like in Copilot.

The BA skills are identical across agents — only the install location and file extension differ
(`.claude/commands/*.md` for Claude vs. `.github/prompts/*.prompt.md` for Copilot). Re-running
the installer is idempotent.

## Supported agents & platforms

Every BA skill and helper script works identically across the agent × OS matrix below. The
PowerShell helpers under `scripts/ps/` mirror the POSIX shell helpers one-for-one (same commands,
exit codes, and template-expansion output).

| Agent            | macOS / Linux (`install.sh`) | Windows (`install.ps1`) | Install location               |
| ---------------- | ---------------------------- | ----------------------- | ------------------------------ |
| VS Code Copilot  | ✅                            | ✅                       | `.github/prompts/*.prompt.md`  |
| Claude           | ✅                            | ✅                       | `.claude/commands/*.md`        |
| Cursor           | ✅                            | ✅                       | `.cursor/commands/*.md`        |
| Generic          | ✅                            | ✅                       | `.bakit/skills/*.md`           |

### Agent auto-detection precedence

With no `--agent`/`-Agent` flag, the installer auto-detects the target from existing directories
in the working folder, in this fixed order:

1. **Copilot** — a `.github/prompts/` or `.github/` directory is present
2. **Claude** — a `.claude/` directory is present
3. **Cursor** — a `.cursor/` directory is present

The first match wins, so in a **mixed** workspace (e.g. both `.github/` and `.claude/` present)
Copilot is selected; pass an explicit `--agent`/`-Agent` to override. If none are found, the
installer prints manual instructions instead of guessing.

## The workflow (`workflow.md`)

`workflow.md` declares the ordered chain and each step's approval gate:

```text
ba.analyze-docs → ba.specify-requirements → ba.write-stories → ba.render-confluence
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
made **stale** by an edit to an approved upstream deliverable.

Its deliverables are standard Markdown artifacts (`project-charter`, `gap-analysis`,
`product-backlog`, `estimated-backlog`). You **may** optionally hand an approved Discovery
deliverable to an existing skill — for example, feeding the Product Backlog into
`ba.write-stories` or rendering it with `ba.render-confluence` — but the Discovery workflow never
auto-triggers those downstream skills; handoff is always your manual choice.

## Two-level knowledge base & lightweight RLM

Each project gets a shared `kb/` and each task its own `kb/`, both seeded with an `index.md`
(`## Summary` + `## Entries`). Skills ground their work by reading the project index first, then
the task index (task knowledge takes precedence). For large or multi-document inputs they apply a
lightweight **Recursive Language Model** strategy — consult the index, then recurse into only the
relevant entries in focused passes — degrading to a single pass for small inputs. A missing or
empty `kb/` is never an error.

## Workflow & review gates

1. A skill writes a `draft` artifact into the active task's `artifacts/`.
2. You review/edit it, then set `status: approved` in its front-matter.
3. Downstream skills (`ba.write-stories`, `ba.render-confluence`) refuse or warn unless their
   upstream artifact is `approved` — enforcing human-in-the-loop review.

Approval is verified with:

```sh
./scripts/sh/check-artifact.sh --require-approved <artifact.md>
```

## Artifacts are diff-friendly (FR-021)

Every template and artifact is plain Markdown with a YAML front-matter block — no binary or
opaque content — so revisions and their rationale stay reviewable in git over time. The
`updated` front-matter field advances on each edit.

## Layout

```text
bakit/
├── install.sh              # bootstrap / installer
├── workflow.md             # declarative ordered skill chain + approval gates
├── workflow-discovery.md   # separate Discovery state-machine manifest (additive)
├── install.ps1             # bootstrap / installer (Windows PowerShell parity)
├── scripts/sh/             # POSIX shell helper scripts (macOS/Linux)
├── scripts/ps/             # PowerShell helper scripts (Windows) — parity with scripts/sh
├── templates/              # project + task (kb) + artifact templates
├── skills/                 # agent-agnostic BA skill definitions
├── memory/                 # BA principles surfaced to skills at runtime
├── tests/sh/               # shell tests for the scripts
└── tests/ps/               # PowerShell tests — parity with tests/sh
```

## Platform support

POSIX shell (`scripts/sh/`, `install.sh`) for macOS/Linux and PowerShell 7+
(`scripts/ps/`, `install.ps1`) for Windows. The two layers are behavioral parity mirrors: same
commands, same exit codes, and byte-identical template-expansion output. Templates and skills are
shared unchanged across both.

## Extending

See [skills/README.md](skills/README.md) for how to add a new skill (drop in a skill file plus
its template — no core edits required).
