---
id: ba-kit-workflow
type: workflow
title: "BA-Kit default analyst workflow"
status: active
created: 2025-01-01
updated: 2025-01-01
---

# BA-Kit Workflow

This manifest is the **single source of truth** for the ordered chain of BA skills.
`scripts/sh/next-step.sh` and the `ba.next` skill read it to suggest what to run next,
and the existing skills derive their "Next steps" blocks from it.

The default chain moves raw inputs toward a shared, review-ready deliverable:

1. **`ba.analyze-docs`** — analyze existing documents into a `docs-analysis` artifact.
2. **`ba.specify-requirements`** — produce a structured, testable `requirements` artifact.
3. **`ba.write-stories`** — convert **approved** requirements into `user-stories`.
4. **`ba.render-confluence`** — render an **approved** artifact into a Confluence-ready deliverable.

Each step that consumes another artifact is **gated on that artifact's `approved` status**
(human-in-the-loop). A step whose gate is unmet is not advanced automatically; instead the
analyst is pointed to the approval/edit step first.

`ba.analyze-docs` and `ba.specify-requirements` can both be entered directly from `inputs/`;
analysts may skip `ba.analyze-docs` when working from notes rather than existing documents.

## Steps (machine-readable)

The rows below are consumed by `next-step.sh`. Columns are pipe-delimited:

`order | skill | produces | requires | gate`

- `produces` — path (relative to the active task) of the artifact/deliverable the step creates.
- `requires` — prerequisite artifact path, or `none`.
- `gate` — required status of the prerequisite (`approved`), or `none`.

<!-- BAKIT-WORKFLOW-START -->
```
1|ba.analyze-docs|artifacts/docs-analysis.md|none|none
2|ba.specify-requirements|artifacts/requirements.md|none|none
3|ba.write-stories|artifacts/user-stories.md|artifacts/requirements.md|approved
4|ba.render-confluence|deliverables|artifacts/requirements.md|approved
```
<!-- BAKIT-WORKFLOW-END -->
