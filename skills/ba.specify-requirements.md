---
name: "ba.specify-requirements"
summary: "Turn raw inputs into a structured, testable, prioritized requirements artifact"
inputs: "Raw notes/statements in the active task's inputs/ folder and/or the analyst's description"
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
2. **Gather inputs.** Read everything in the task's `inputs/` folder plus any description the
   analyst provided. If a file is empty/unreadable, report it; do not invent content.
3. **Analyze.** Identify candidate requirements, actors, constraints, and priorities.
4. **Clarify, don't assume.** For every ambiguous or missing detail, ask the analyst targeted
   clarification questions before finalizing. List unresolved items under "Open Questions".
5. **Draft the artifact.** Populate `templates/artifacts/requirements.md`:
   - Numbered, testable, prioritized functional requirements (and non-functional where
     relevant).
   - For each requirement derived from an input, cite the source inline
     (`<!-- source: inputs/<file> -->`).
   - Set front-matter: a unique `id`, `title`, `status: draft`, `created`/`updated` to today.
   - Populate `assumptions` with any assumptions made (also reflect them in the Assumptions
     section). Never present an assumption as fact.
6. **Present for review.** Show the draft as an editable proposal. Do NOT set `status:
   approved` — that is the analyst's decision. Once approved, this artifact becomes the source
   of truth for `ba.write-stories`.

## Validation

After writing, the artifact must pass:

```sh
scripts/sh/check-artifact.sh <task>/artifacts/requirements.md
```
