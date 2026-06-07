---
id: ba-kit-workflow-discovery
type: workflow
title: "BA-Kit Discovery workflow"
status: active
created: 2026-06-07
updated: 2026-06-07
---

# BA-Kit Discovery Workflow

This manifest is the **single source of truth** for the ordered chain of the **Discovery**
state machine. It is **separate from and additive to** the default `workflow.md` — the default
analyst chain is not modified and continues to work unchanged.

`scripts/sh/next-step.sh --workflow workflow-discovery.md` (and the PowerShell
`next-step.ps1 -Workflow workflow-discovery.md`) read this file to suggest the next Discovery
state, and the `ba.discover.*` skills derive their "Next steps" blocks from it. The helper skill
`ba.discover.next` is the convenient entry point.

The Discovery workflow walks a stakeholder from a plain project idea to an estimated, road-mapped
backlog, persisting a single **Living Discovery Document** (`artifacts/discovery-document.md`)
across all states:

1. **`ba.discover.initiate`** — State 1: Initiation & Elicitation → `project-charter` (also creates
   the Living Discovery Document).
2. **`ba.discover.gap-analysis`** — State 2: Strategy & Gap Analysis → `gap-analysis`.
3. **`ba.discover.backlog`** — State 3: Requirements Definition & Scoping → `product-backlog`.
4. **`ba.discover.estimate`** — State 4: Estimation & Planning → `estimated-backlog` (+ roadmap).

Each state that consumes the prior state's deliverable is **gated on that deliverable's `approved`
status** (explicit human-in-the-loop phase gate). A state whose gate is unmet is not advanced
automatically; the analyst is pointed to the approval/edit step first.

## Steps (machine-readable)

The rows below are consumed by `next-step.sh`. Columns are pipe-delimited:

`order | skill | produces | requires | gate`

- `produces` — path (relative to the active task) of the artifact the state creates.
- `requires` — prerequisite artifact path, or `none`.
- `gate` — required status of the prerequisite (`approved`), or `none`.

<!-- BAKIT-WORKFLOW-START -->
```
1|ba.discover.initiate|artifacts/project-charter.md|none|none
2|ba.discover.gap-analysis|artifacts/gap-analysis.md|artifacts/project-charter.md|approved
3|ba.discover.backlog|artifacts/product-backlog.md|artifacts/gap-analysis.md|approved
4|ba.discover.estimate|artifacts/estimated-backlog.md|artifacts/product-backlog.md|approved
```
<!-- BAKIT-WORKFLOW-END -->
