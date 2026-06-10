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
2. **`ba.specify`** — turn a need or raw notes into a structured, testable `requirements` artifact (quick or deep mode).
3. **`ba.write-stories`** — convert **approved** requirements into `user-stories`.
4. **`ba.render-confluence`** — render an **approved** artifact into a Confluence-ready deliverable.

Each step that consumes another artifact is **gated on that artifact's `approved` status**
(human-in-the-loop). A step whose gate is unmet is not advanced automatically; instead the
analyst is pointed to the approval/edit step first.

`ba.analyze-docs` and `ba.specify` can both be entered directly from `inputs/`;
analysts may skip `ba.analyze-docs` when working from notes rather than existing documents.

### Gap-aware advisories (additive, non-blocking)

Artifacts may carry a lightweight rollup of unresolved **open questions** in their front-matter
(`open_questions`, `blocking_questions`) backed by a structured `## Open Questions` table. These
power purely **advisory** behavior that never changes the approval gates above:

- `ba.specify` presents a **decomposition-readiness summary** (resolved / open / blocking) and,
  for each blocking item, options with their implications — informing the analyst without
  auto-approving.
- `next-step.sh` / `ba.next` emit an **advisory warning** when an approved prerequisite still
  carries blocking open questions; the analyst may resolve them first or **proceed anyway**.
  Proceeding records an **Override** (in the elicitation-plan Round Log, or the requirements
  `## Override Log` in quick mode). The exit code and gates are unchanged.
- Open questions detected during `ba.analyze-docs` are **carried forward** into `ba.specify` (with
  an origin trace reference, de-duplicated), so gaps are not silently lost across steps.

Consistent with the constitution's human-in-the-loop principle, none of these advisories
self-approve, silently escalate, or hard-block; the analyst always decides.

## Steps (machine-readable)

The rows below are consumed by `next-step.sh`. Columns are pipe-delimited:

`order | skill | produces | requires | gate`

- `produces` — path (relative to the active task) of the artifact/deliverable the step creates.
- `requires` — prerequisite artifact path, or `none`.
- `gate` — required status of the prerequisite (`approved`), or `none`.

<!-- BAKIT-WORKFLOW-START -->
```
1|ba.analyze-docs|artifacts/docs-analysis.md|none|none
2|ba.specify|artifacts/requirements.md|none|none
3|ba.write-stories|artifacts/user-stories.md|artifacts/requirements.md|approved
4|ba.render-confluence|deliverables|artifacts/requirements.md|approved
```
<!-- BAKIT-WORKFLOW-END -->
