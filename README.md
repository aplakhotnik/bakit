# BA-Kit

A spec-driven framework for **Business Analysts** — inspired by
[spec-kit](https://github.com/github/spec-kit), but for BA activities instead of software
features. Clone it, run the installer, scaffold a standardized workspace, and run guided BA
"skills" inside your AI coding agent.

## What you get

- **Standardized workspace structure** — `Project → numbered Task → inputs/artifacts/deliverables`.
- **Helper scripts** (POSIX shell) — scaffold projects/tasks, list artifacts, validate status.
- **Agent-agnostic BA skills** — guided workflows that produce structured Markdown artifacts:
  - `ba.specify-requirements` — raw inputs → structured requirements
  - `ba.analyze-docs` — existing documents → extracted requirements, gaps, open questions
  - `ba.write-stories` — approved requirements → user stories with acceptance criteria
  - `ba.render-confluence` — approved artifact → local Confluence-ready Markdown
- **Review gates & traceability** — every artifact carries `status: draft → approved` and
  provenance in YAML front-matter.

## Quick start

```sh
# 1. Install (maps skills into your agent's prompt directory, makes scripts executable)
./install.sh                      # auto-detects agent; or: ./install.sh --agent copilot

# 2. Scaffold a project and a task
./scripts/sh/init-project.sh "payments-revamp"
./scripts/sh/init-task.sh "payments-revamp" "elicit-requirements"

# 3. Add raw inputs, then run a skill in your agent
#    (drop notes/docs into the task's inputs/ folder, then invoke ba.specify-requirements)

# 4. Inspect status / validate artifacts
./scripts/sh/list-artifacts.sh "payments-revamp"
./scripts/sh/check-artifact.sh workspace/payments-revamp/tasks/001-elicit-requirements/artifacts/requirements.md
```

By default the workspace is created under `./workspace`. Override with the `BAKIT_WORKSPACE`
environment variable.

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
├── scripts/sh/             # POSIX shell helper scripts (macOS/Linux)
├── scripts/ps/             # placeholder for planned Windows PowerShell parity
├── templates/              # project + artifact templates
├── skills/                 # agent-agnostic BA skill definitions
├── memory/                 # BA principles surfaced to skills at runtime
└── tests/sh/               # shell tests for the scripts
```

## Platform support

POSIX shell (macOS/Linux) for v1. Windows PowerShell variants are planned under `scripts/ps/`
and can be added without changing templates or skills.

## Extending

See [skills/README.md](skills/README.md) for how to add a new skill (drop in a skill file plus
its template — no core edits required).
