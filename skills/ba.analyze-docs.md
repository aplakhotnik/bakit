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
5. **Clarification loop (analyst-driven, iterative).** If step 4 surfaced **material contradictions**
   between sources (or against the KB), run one or more clarification rounds — each a **bounded batch**
   of at most three prioritized questions (highest-impact contradictions first) — and **keep iterating
   until the material contradictions are resolved or the analyst explicitly defers them**. There is
   **no fixed cap on rounds** (the batch size caps questions per round, not the number of rounds). This
   loop is optional/skippable: if there are no material contradictions, or the analyst prefers a
   one-shot analysis, **skip it and proceed directly to drafting** (the one-shot path is always
   available).
   - Ask the bounded questions, then **fold the analyst's answers** into the extracted findings
     (update requirements/gaps and cite the answer's origin).
   - For any contradiction that remains **unresolved** after the analyst defers, record it as a
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
9. **Capture reusable knowledge (controlled brain promotion).** Promote durable results to the
   project brain per `memory/ba-constitution.md` §11: **append** an entry to `kb/changelog.md`
   (date · task · `ba.analyze-docs` · 3–5 bullets · link to this artifact) and merge concise facts
   into the relevant project `kb/` register/log (e.g. `requirements-register.md`, `open-questions.md`,
   `decisions.md`, `glossary.md`, `source-register.md`), updating `kb/index.md` if you add a new
   entry. **Digest only** — never copy the whole artifact or raw sources into the KB; never overwrite
   analyst-authored KB content (supersede instead). Task-specific facts may stay in the task `kb/`;
   a project without these KB files may skip this.
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
