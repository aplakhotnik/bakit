---
name: "ba.write-stories"
summary: "Convert approved requirements into well-formed user stories with acceptance criteria"
inputs: "The approved artifacts/requirements.md in the active task, grounded by the project + task kb/"
prerequisites: "artifacts/requirements.md with status: approved"
output: "type: user-stories -> artifacts/user-stories.md (in the active task)"
template: "templates/artifacts/user-stories.md"
---

# Skill: `ba.write-stories`

Guided user-story writing. Follow `memory/ba-constitution.md` and
`specs/001-ba-kit-framework/contracts/skill-contract.md`.

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
4. **Generate stories.** For each requirement, write one or more well-formed user stories
   ("As a `<role>`, I want `<capability>` so that `<benefit>`") with testable acceptance
   criteria in Given/When/Then form, using personas/terms from the KB where available.
5. **Trace.** Populate the `derived_from` front-matter with the full set of covered
   requirement ids (non-empty); note any unresolved gaps as a story's Open questions.
6. **Draft the artifact.** Populate `templates/artifacts/user-stories.md`; set front-matter
   `id`, `title`, `status: draft`, `created`/`updated`.
7. **Capture reusable knowledge.** If new personas, terms, or decisions emerged, add or update
   the relevant `kb/` entry and reflect it in that `kb/index.md`.
8. **Present for review.** Editable draft; do not self-approve.

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
