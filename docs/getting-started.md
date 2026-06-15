# Getting started

This guide takes you from zero to your first reviewed requirements document. It assumes you can
open a terminal **once** to run the installer — after that, you drive everything from inside your
AI assistant by typing commands like `/ba.start-project`.

New to the terms used here? Read **[Concepts & glossary](concepts.md)** first (5 minutes).

Here's the whole flow in a few seconds — slashing between the BA skills from inside the assistant:

![BA-Kit skills demo: moving through start-project, start-task, analyze-docs, specify, and render-confluence](assets/skill_demo.gif)

## 1. Prerequisites

- **git** — to download BA-Kit.
- One supported AI assistant: **VS Code (GitHub Copilot)**, **Claude**, **Cursor**, or
  **Antigravity**.
- A terminal:
  - **macOS / Linux** — the built-in Terminal app.
  - **Windows** — [PowerShell 7+](https://learn.microsoft.com/powershell/) (`pwsh`).

No build step or internet access is needed beyond the initial download — the installer only copies
files.

## 2. Download BA-Kit

```sh
git clone https://github.com/aplakhotnik/bakit.git
cd bakit
```

## 3. Run the installer (one time)

This connects the BA skills to your AI assistant so you can call them as `/` commands.

**macOS / Linux:**

```sh
./install.sh
```

**Windows (PowerShell 7+):**

```powershell
.\install.ps1
```

You'll see a simple menu. The assistants already detected in your folder are pre-ticked — type the
number(s) you want, press Enter, and confirm:

```text
Select the agent(s) / IDE(s) to install BA-Kit for.

  1) [x] VS Code (GitHub Copilot)
  2) [ ] Claude
  3) [ ] Cursor
  4) [ ] Generic
  5) [ ] Antigravity IDE

Your selection (default = pre-selected [x]):
```

Re-running the installer later is always safe.

> **VS Code (Copilot) first run:** after installing, reload the window
> (Command Palette → *Developer: Reload Window*) and **trust the folder** if prompted, so the new
> `/ba.*` commands appear in Copilot Chat. See the [FAQ](faq.md) if they don't show up.

The exact install location per assistant and the auto-detection rules are listed in the
[main README](../README.md#supported-environments).

## 4. Your first project (from inside your AI assistant)

From here on you don't touch the terminal — just chat with your assistant. Type `/` and pick the
skill, or describe what you want.

**Step 1 — Start a project.**

```text
/ba.start-project   →  "Start a project called payments-revamp"
```

The assistant scaffolds `workspace/payments-revamp/` and asks a few questions to capture **project
context** (vision, stakeholders, constraints) into the shared knowledge base, so later steps reuse
it instead of re-asking.

**Step 2 — Add a task.**

```text
/ba.start-task   →  "Add a task: elicit-requirements"
```

This creates `tasks/001-elicit-requirements/` with `inputs/`, `artifacts/`, `deliverables/`, and a
task `kb/`. The assistant may capture task-specific context here too.

**Step 3 — Drop in your material.** Put any notes, emails, or documents into the task's `inputs/`
folder (drag-and-drop in your editor's file explorer is fine).

**Step 4 — Ask what's next.**

```text
/ba.next
```

BA-Kit reads your workspace and suggests the sensible next skill — typically `ba.analyze-docs` (if
you added documents) or `ba.specify` (to turn a need into requirements).

**Step 5 — Produce requirements.**

```text
/ba.specify
```

The assistant grounds itself in your context, asks targeted clarifying questions, and writes a
**draft** `artifacts/requirements.md`.

**Step 6 — Review and approve.** Open `requirements.md`, edit anything you like, then change the
top line `status: draft` to `status: approved`. That approval is what unlocks the next step.

**Step 7 — Go further (optional).** Run `/ba.next` again to be guided to:
- `/ba.decompose` — *(optional, suggested)* turn approved requirements into a **story map** (a
  backbone of prioritized slices with an MVP/walking-skeleton). You can skip it; `ba.write-stories`
  works with or without a map.
- `/ba.write-stories` — turn approved requirements into user stories, and/or
- `/ba.render-confluence` — render an approved artifact into a Confluence-ready page.

That's the whole loop. For a fuller narrative of how to work day to day, see
**[Working with the default workflow](workflows.md)**.

## Prefer the terminal?

Every scaffolding step is also available as a script, if you'd rather:

```sh
./scripts/sh/init-project.sh "payments-revamp"
./scripts/sh/init-task.sh "payments-revamp" "elicit-requirements"
./scripts/sh/next-step.sh
./scripts/sh/list-artifacts.sh "payments-revamp"
```

By default the workspace is created under `./workspace`. Override it with the `BAKIT_WORKSPACE`
environment variable.

## Troubleshooting

Commands not appearing, or something not working as expected? See the **[FAQ](faq.md)**.
