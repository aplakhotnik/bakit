# Concepts & glossary

New to BA-Kit? This page explains the handful of terms you'll see, in plain language. You don't
need to be technical — read this once and the rest of the docs will make sense.

## The big picture

BA-Kit gives your AI assistant a set of **guided BA activities** ("skills") and a **standard folder
structure** to keep your work organized. You talk to your AI assistant as usual; the skills make
sure every output is structured, traceable, and reviewed by you before it moves forward.

```text
Idea / notes / documents  ──▶  guided skills  ──▶  reviewed Markdown artifacts  ──▶  deliverables
```

## Glossary

| Term | What it means (plain English) |
|------|-------------------------------|
| **Skill** | A guided BA activity you run from inside your AI assistant, e.g. `ba.specify`. Think of it as a checklist the AI follows so nothing is missed. |
| **Project** | A folder for one initiative (e.g. *payments-revamp*). It holds all your tasks and a shared knowledge base. |
| **Task** | A unit of work inside a project (e.g. *elicit-requirements*). Each task has its own inputs, outputs, and knowledge base. |
| **Artifact** | A structured document a skill produces — for example `requirements.md`, `story-map.md`, or `user-stories.md`. Always plain Markdown so it's easy to read and review. |
| **Story map** | An optional artifact (`story-map.md`) from `ba.decompose`: a *backbone* of prioritized, independently testable **slices** with an explicit **MVP / walking-skeleton**, dependency notes, and a coverage check. It names a **splitting pattern** per slice and can hold parallel strategy **variants** (one marked *Selected*). |
| **Slice** | A thin, end-to-end piece of work that delivers an observable, testable outcome — the unit a story map is built from and that user stories expand. |
| **Deliverable** | A final, shareable rendering of an approved artifact (e.g. a Confluence-ready page). |
| **Inputs** | The raw material you drop into a task: meeting notes, emails, existing documents, etc. |
| **Knowledge base (`kb/`)** | Curated facts the AI should reuse instead of re-asking you — terms, decisions, constraints. There's one shared per project and one per task. |
| **Front-matter** | A small block of labelled fields at the top of every artifact (title, status, dates, sources). It lets the tools track status and history. You rarely edit it by hand except to approve. |
| **Status: draft → approved** | Every artifact starts as a `draft`. When you're happy with it, you change its status to `approved`. Nothing moves to the next step until you approve. |
| **Review gate** | The rule that a later step won't use an earlier artifact until *you* have approved it. This keeps a human in control. |
| **Workflow** | The recommended order of skills (analyze → specify → *(decompose)* → write stories → render). BA-Kit can always tell you what's sensible to run next. |
| **Open question** | Something that's still unclear or undecided. BA-Kit tracks these so gaps aren't lost; a *blocking* open question is one important enough that you probably want to resolve it before moving on. |
| **Agent / IDE** | The AI tool you use — VS Code (GitHub Copilot), Claude, Cursor, or Antigravity. BA-Kit works the same way in all of them. |

## How you and the AI share the work

1. **You** start a project and a task, then drop in your raw material.
2. **The AI** runs a skill, asks you clarifying questions, and produces a **draft** artifact.
3. **You** review and edit it, then mark it **approved**.
4. **The AI** uses that approved artifact for the next step.

The golden rule: **the AI never approves its own work, and never invents facts** — when something
is unclear it asks you. You stay in control at every step.

## Where things live

```text
workspace/
└── payments-revamp/              ← your project
    ├── project.md                ← project overview + context
    ├── kb/                       ← shared knowledge base
    └── tasks/
        └── 001-elicit-requirements/
            ├── inputs/           ← drop your notes/documents here
            ├── artifacts/        ← skills write drafts here (requirements.md, …)
            ├── deliverables/     ← final shareable outputs (Confluence pages, …)
            └── kb/               ← task-specific knowledge base
```

Next: **[Getting started](getting-started.md)** to install BA-Kit and create your first project.
