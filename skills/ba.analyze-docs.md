---
name: "ba.analyze-docs"
summary: "Analyze existing documents to extract requirements, gaps, and open questions"
inputs: "Source documents in the active task's inputs/ folder, grounded by the project + task kb/"
prerequisites: "none"
output: "type: docs-analysis -> artifacts/docs-analysis.md (in the active task)"
template: "templates/artifacts/docs-analysis.md"
---

# Skill: `ba.analyze-docs`

Guided documentation analysis. Follow `memory/ba-constitution.md`.

## Steps

1. **Resolve the active task** (explicit arg → `.bakit-active` → most-recently-modified).
   Output goes to that task's `artifacts/docs-analysis.md`.
2. **Ground in the knowledge base FIRST.** Before reading the source documents, consult the
   two-level knowledge base so prior facts inform the analysis:
   - Read the **project-level** `kb/index.md`, then the active task's `kb/index.md` (task
     knowledge takes precedence). Use the `## Summary` and `## Entries` sections to decide what
     is relevant — do not load every file blindly.
   - For large or multi-entry knowledge, follow the index into specific entries in focused
     chunks/sub-passes (lightweight RLM); for small knowledge bases a single pass is fine. A
     missing or empty `kb/` is NOT an error — continue.
3. **Read the sources.** Process every text-based document in `inputs/`. If a document is
   empty or unreadable, record it under "Sources Reviewed" with a note and continue; do not
   fabricate its contents.
4. **Extract & assess.** Identify candidate requirements, gaps, inconsistencies, and open
   questions across the sources, reconciling them against the KB context from step 2 (flag where
   a source contradicts known knowledge).
5. **Optional clarification round (analyst-driven, bounded).** If step 4 surfaced **material
   contradictions** between sources (or against the KB), you MAY run a **single** clarification
   round of **at most three** prioritized questions before drafting — focus on the highest-impact
   contradictions first. This round is optional: if there are no material contradictions, or the
   analyst prefers a one-shot analysis, **skip it and proceed directly to drafting** (the one-shot
   path is always available).
   - Ask the bounded questions, then **fold the analyst's answers** into the extracted findings
     (update requirements/gaps and cite the answer's origin).
   - For any contradiction that remains **unresolved** after the round, record it as a
     **structured open question** in the artifact's `## Open Questions` table (ID, Question,
     Status `open`, Blocking flag, Origin, Resolution `—`) and keep the front-matter rollup
     (`open_questions` / `blocking_questions`) in sync. Never resolve a contradiction by asserting
     an assumption as fact.
6. **Cite everything.** Every extracted requirement and finding MUST cite its origin inline — a
   source document and section (`<!-- source: inputs/<file> § <section> -->`) or a knowledge-base
   entry (`<!-- source: kb/<entry> -->`).
7. **Flag assumptions.** Any inferred or unsupported content goes under "Assumptions" and into
   the `assumptions` front-matter — never stated as established fact.
8. **Draft the artifact.** Populate `templates/artifacts/docs-analysis.md`; set front-matter
   `id`, `title`, `status: draft`, `created`/`updated`, and a NON-EMPTY `sources` list naming
   the reviewed documents.
9. **Capture reusable knowledge.** If the analysis surfaced durable, reusable facts (agreed
   terms, decisions, constraints), add or update the relevant `kb/` entry and reflect it in that
   `kb/index.md`.
10. **Present for review.** Show as an editable draft; do not self-approve.

## Validation

```sh
scripts/sh/check-artifact.sh <task>/artifacts/docs-analysis.md
```

(`sources` is required and must be non-empty for this artifact type.)

## Next steps

Derived from `workflow.md`. After presenting the draft, surface this block (run
`scripts/sh/next-step.sh` to confirm the live state):

```text
## Next steps
- ▶ ba.specify — turn these findings into a structured requirements artifact
- ✎ Review and (optionally) approve docs-analysis.md so it can ground later steps
```
