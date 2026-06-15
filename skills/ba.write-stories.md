---
name: "ba.write-stories"
summary: "Convert approved requirements into well-formed user stories with acceptance criteria — consuming an approved story map when one exists, or light-decomposing the requirements directly when it does not"
inputs: "The approved artifacts/requirements.md in the active task (and artifacts/story-map.md when present), grounded by the project + task kb/"
prerequisites: "artifacts/requirements.md with status: approved"
output: "type: user-stories -> artifacts/user-stories.md (in the active task)"
template: "templates/artifacts/user-stories.md"
---

# Skill: `ba.write-stories`

Guided user-story writing. Follow `memory/ba-constitution.md`.

If an approved `artifacts/story-map.md` exists, this skill **consumes the selected variant's
slices**; if none exists, it **still light-decomposes** the requirements (decomposition + story
mapping + INVEST) rather than emitting a raw 1:1 dump. Either way it produces the same
`artifacts/user-stories.md`, so the optional `ba.decompose` step is never required.

## Steps

1. **Resolve the active task** (explicit arg → `.bakit-active` → most-recently-modified).
2. **Enforce the prerequisite gate (REQUIRED).** Verify the requirements artifact is approved:

   ```sh
   scripts/sh/check-artifact.sh --require-approved <task>/artifacts/requirements.md
   ```

   - If it exits non-zero (missing, invalid, or `status: draft`), STOP. Tell the analyst the
     requirements must be approved first and do NOT proceed. Never generate stories from
     unapproved or missing requirements.
3. **Ground in the knowledge base.** Consult the **project-level** `kb/index.md` then the task's
   `kb/index.md` (task precedence) for personas, domain terms, and constraints that shape the
   stories. Read the index first and recurse into entries only as needed (lightweight RLM); a
   missing or empty `kb/` is NOT an error — continue from the approved requirements.
4. **Detect a story map and choose the path.** Check for `<task>/artifacts/story-map.md`:

   - **If present, require it approved** before consuming it:

     ```sh
     scripts/sh/check-artifact.sh --require-approved <task>/artifacts/story-map.md
     ```

     If it exists but is **draft**, tell the analyst to approve it (or to proceed from requirements
     instead) — do not consume an unapproved map.
   - **If absent**, take the fallback path (step 6).

5. **Map path — consume the selected variant (when an approved map exists).**
   - Read the **single Selected variant** from the map. If the approved map has **no Selected
     variant**, STOP and ask the analyst to select one rather than guessing.
   - **Expand each slice of the selected variant** into one or more well-formed INVEST user stories
     ("As a `<role>`, I want `<capability>` so that `<benefit>`") with testable acceptance criteria
     in Given/When/Then form.
   - **Record traceability:** set `derived_from` to the **story-map id** (the direct predecessor),
     and record each story's originating **slice id(s)** (e.g. `V1-S1`). Requirement traceability
     flows transitively through the map's slice → requirement coverage.
   - **Coverage:** ensure **every slice of the selected variant** is covered by ≥1 story; flag any
     uncovered slice as an Open question rather than dropping it.
   - Skip step 6.

6. **Fallback path — light decomposition (when no story map exists).**
   - Do **NOT** emit a 1:1 requirement→story dump. Perform a **light decomposition**: characterize
     the shape, sketch a quick backbone, and split oversized/ambiguous requirements into thin,
     independently testable slices using a **named** splitting pattern from
     `docs/decomposition-patterns.md` (link once; do not inline it), then apply **INVEST** to each
     resulting story.
   - Derive the stories from the **approved requirements**; set `derived_from` to the covered
     **requirement ids** (non-empty). Write **no** `story-map.md` artifact in this path.
7. **Trace & gaps.** Populate `derived_from` (story-map id on the map path; requirement ids on the
   fallback path), and note any unresolved ambiguity as a story's Open questions.
8. **Draft the artifact.** Populate `templates/artifacts/user-stories.md`; set front-matter
   `id`, `title`, `status: draft`, `created`/`updated`.
9. **Capture reusable knowledge.** If new personas, terms, or decisions emerged, add or update
   the relevant `kb/` entry and reflect it in that `kb/index.md`.
10. **Present for review.** Editable draft; do not self-approve.

## Validation

```sh
scripts/sh/check-artifact.sh <task>/artifacts/user-stories.md
```

(`derived_from` is required and must be non-empty for this artifact type.)

## Next steps

Derived from `workflow.md`. `ba.render-confluence` requires an **approved** source artifact
(run `scripts/sh/next-step.sh` to confirm the live state):

```text
## Next steps
- ▶ ba.render-confluence — render an approved artifact into a Confluence-ready deliverable
- ✎ Approve user-stories.md (or requirements.md) first if still draft
```
