# Getting started

This guide takes you from zero to your first reviewed requirements document. It assumes you can
open a terminal **once** to run the installer — after that, you drive everything from inside your
AI assistant by typing commands like `/ba.start-project`.

New to the terms used here? Read **[Concepts & glossary](concepts.md)** first (5 minutes).

Here's the whole flow in a few seconds — slashing between the BA skills from inside the assistant:

![BA-Kit skills demo: moving through start-project, start-task, analyze-docs, specify, and render-confluence](assets/skill_demo.gif)

## 1. Prerequisites (fresh machine)

If you are starting from scratch, install these first:

- **git** (required to clone BA-Kit)
  - macOS: run `xcode-select --install`
  - Windows: install Git for Windows from https://git-scm.com/download/win
  - Linux: install from your distro package manager (for example, `sudo apt install git`)
- **IDE/assistant** (focus first on one or both of these)
  - **VS Code + GitHub Copilot**
    - Install Visual Studio Code
    - Install the GitHub Copilot extension in VS Code
    - Sign in to GitHub in VS Code so Copilot Chat is available
  - **Antigravity IDE**
    - Install Antigravity IDE
    - Complete first-launch/sign-in so local skills can be detected
- **Terminal**
  - **macOS / Linux** — built-in Terminal
  - **Windows** — [PowerShell 7+](https://learn.microsoft.com/powershell/) (`pwsh`)

No build step or internet access is needed beyond the initial download — the installer only copies
files.

## 2. Download BA-Kit

```sh
git clone https://github.com/aplakhotnik/bakit.git
cd bakit
```

## 3. Run the installer (VS Code + Antigravity first)

This connects BA skills to your assistant as `/` commands.

### Option A: VS Code (Copilot)

**macOS / Linux**

```sh
./install.sh --agent copilot
```

**Windows (PowerShell 7+)**

```powershell
.\install.ps1 -Agent copilot
```

After install in VS Code:

- Reload window: Command Palette -> `Developer: Reload Window`
- Trust folder if prompted
- In Copilot Chat type `/` and confirm commands like `ba.start-project`

### Option B: Antigravity IDE

Workspace scope (recommended when starting):

```sh
./install.sh --agent antigravity --scope workspace
# .\install.ps1 -Agent antigravity -Scope workspace
```

Global scope (all projects on this machine):

```sh
./install.sh --agent antigravity --scope global
# .\install.ps1 -Agent antigravity -Scope global
```

### Option C: Interactive menu (if you prefer selecting by number)

Run without `--agent` / `-Agent` to open the menu. The assistants already detected in your folder
are pre-ticked. Type number(s), press Enter, then confirm:

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

### Quick install checks

- VS Code install: `.github/prompts/ba.start-project.prompt.md` exists
- Antigravity workspace install: `.agents/skills/ba.start-project/SKILL.md` exists
- Antigravity global install: `~/.gemini/config/skills/ba.start-project/SKILL.md` exists

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

## Upgrading BA-Kit

When a newer BA-Kit comes out, you upgrade the **whole package** and re-run the installer. Re-running
is always safe: your project folders and any installed command you hand-tuned are **backed up before**
they are replaced — nothing you changed is silently overwritten.

**1. Preview what will change (recommended).** Every install run prints a short preview first. To see
it *without writing anything*, add the dry-run flag:

```sh
./install.sh --check          # macOS / Linux
.\install.ps1 -Check          # Windows (PowerShell 7+)
```

If nothing you installed differs from the new package, you'll see **"safe to upgrade"**. Otherwise
the preview lists exactly which files differ and will be backed up.

**2. Get the newer package.**

- **Cloned the repo?** `cd bakit && git pull`.
- **Downloaded a copy?** Replace your old `bakit/` folder with the new one.

**3. Re-run the installer** (`./install.sh` or `.\install.ps1`). The end-of-run report tells you what
was `added` / `updated` / `unchanged` / `backed-up`, how many files were backed up, and where.

### Where backups go, and how to restore

If the installer is about to overwrite a command you tuned, it first copies the existing file —
verbatim — into a timestamped folder at your workspace root, then writes the new version live:

```text
.bakit-backup/
└── 20250101T120000Z/                     # UTC run timestamp (colon-free)
    └── .github/prompts/ba.next.prompt.md  # your tuned copy, mirrored install path
```

For Antigravity installs the backup mirrors the bundle path (e.g.
`.bakit-backup/<timestamp>/.agents/skills/ba.next/SKILL.md`). `.bakit-backup/` is added to your
`.gitignore` automatically.

**To restore a tuned command**, copy it back from the mirrored path inside the timestamped folder to
its install location:

```sh
cp .bakit-backup/20250101T120000Z/.github/prompts/ba.next.prompt.md .github/prompts/ba.next.prompt.md
```

> Installed `ba.*` commands that no longer match any package skill are reported as **stale** — they
> are surfaced in the report but never auto-deleted, so a renamed or custom command is never lost.

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
