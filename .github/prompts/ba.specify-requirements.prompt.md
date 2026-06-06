---
name: "ba.specify-requirements"
summary: "Turn raw inputs into a structured, testable, prioritized requirements artifact"
inputs: "The active task's knowledge base (project + task kb/), raw material in inputs/, and/or the analyst's description"
prerequisites: "none"
output: "type: requirements -> artifacts/requirements.md (in the active task)"
template: "templates/artifacts/requirements.md"
---

# Skill: `ba.specify-requirements`

Guided requirements analysis. Follow `memory/ba-constitution.md` and
`specs/001-ba-kit-framework/contracts/skill-contract.md`.

## Steps

1. **Resolve the active task.** Use an explicit project/task if the analyst named one;
   otherwise read `workspace/.bakit-active`, else use the most-recently-modified task. Confirm
   the resolved target with the analyst. Output goes to that task's
   `artifacts/requirements.md`.
2. **Ground in the knowledge base FIRST.** Before reading raw inputs, consult the two-level
   knowledge base so you reuse known facts instead of re-deriving them:
   - Read the **project-level** `kb/index.md`, then the active task's `kb/index.md` (task
     knowledge takes precedence). Use the `## Summary` and `## Entries` sections to decide what
     is relevant — do not load every file blindly.
   - For large or multi-entry knowledge, follow the index into specific entries and process them
     in focused chunks/sub-passes (lightweight RLM); for small knowledge bases a single pass is
     fine. A missing or empty `kb/` is NOT an error — continue.
3. **Gather raw material.** Read everything in the task's `inputs/` folder plus any description
   the analyst provided. Treat `inputs/` as raw source material and `kb/` as curated, reusable
   context; combine both. If an input file is empty/unreadable, report it; do not invent content.
4. **Analyze.** Identify candidate requirements, actors, constraints, and priorities, grounded in
   the KB context from step 2 and the raw material from step 3.
5. **Clarify, don't assume.** For every ambiguous or missing detail not already settled by the
   KB, ask the analyst targeted clarification questions before finalizing. List unresolved items
   under "Open Questions".
6. **Draft the artifact.** Populate `templates/artifacts/requirements.md`:
   - Numbered, testable, prioritized functional requirements (and non-functional where
     relevant).
   - Cite the source of each derived requirement inline — a knowledge-base entry
     (`<!-- source: kb/<entry> -->`) or a raw input (`<!-- source: inputs/<file> -->`).
   - Set front-matter: a unique `id`, `title`, `status: draft`, `created`/`updated` to today.
   - Populate `assumptions` with any assumptions made (also reflect them in the Assumptions
     section). Never present an assumption as fact.
7. **Capture reusable knowledge.** If this run produced durable, reusable knowledge (agreed
   terms, decisions, constraints), add or update the relevant `kb/` entry and reflect it in that
   `kb/index.md` (task-level for task-specific facts, project-level for shared ones).
8. **Present for review.** Show the draft as an editable proposal. Do NOT set `status:
   approved` — that is the analyst's decision. Once approved, this artifact becomes the source
   of truth for `ba.write-stories`.

## Validation

After writing, the artifact must pass:

```sh
scripts/sh/check-artifact.sh <task>/artifacts/requirements.md
```

## Next steps

Derived from `workflow.md`. `ba.write-stories` is gated on this artifact being **approved**
(run `scripts/sh/next-step.sh` to confirm the live state):

```text
## Next steps
- ▶ ba.write-stories — convert these requirements into user stories (enabled when requirements.md is approved)
- ✎ Approve requirements.md first if it is still draft
```
