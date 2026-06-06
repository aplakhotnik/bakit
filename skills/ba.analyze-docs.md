---
name: "ba.analyze-docs"
summary: "Analyze existing documents to extract requirements, gaps, and open questions"
inputs: "One or more text-based documents in the active task's inputs/ folder"
prerequisites: "none"
output: "type: docs-analysis -> artifacts/docs-analysis.md (in the active task)"
template: "templates/artifacts/docs-analysis.md"
---

# Skill: `ba.analyze-docs`

Guided documentation analysis. Follow `memory/ba-constitution.md` and
`specs/001-ba-kit-framework/contracts/skill-contract.md`.

## Steps

1. **Resolve the active task** (explicit arg → `.bakit-active` → most-recently-modified).
   Output goes to that task's `artifacts/docs-analysis.md`.
2. **Read the sources.** Process every text-based document in `inputs/`. If a document is
   empty or unreadable, record it under "Sources Reviewed" with a note and continue; do not
   fabricate its contents.
3. **Extract & assess.** Identify candidate requirements, gaps, inconsistencies, and open
   questions across the sources.
4. **Cite everything.** Every extracted requirement and finding MUST cite its source document
   and section/location inline (`<!-- source: inputs/<file> § <section> -->`).
5. **Flag assumptions.** Any inferred or unsupported content goes under "Assumptions" and into
   the `assumptions` front-matter — never stated as established fact.
6. **Draft the artifact.** Populate `templates/artifacts/docs-analysis.md`; set front-matter
   `id`, `title`, `status: draft`, `created`/`updated`, and a NON-EMPTY `sources` list naming
   the reviewed documents.
7. **Present for review.** Show as an editable draft; do not self-approve.

## Validation

```sh
scripts/sh/check-artifact.sh <task>/artifacts/docs-analysis.md
```

(`sources` is required and must be non-empty for this artifact type.)
