---
name: "ba.assumptions-log"
summary: "Capture and track working assumptions — with basis, confidence, owner, validation path, and linkage to open questions/requirements — so unconfirmed items stay explicit and are never asserted as fact"
inputs: "Open/deferred questions and constraints from the project + task kb/ (e.g. kb/open-questions.md, a task's gap-analysis/requirements) plus analyst-supplied assumptions"
prerequisites: "none"
output: "type: assumptions-log -> artifacts/assumptions-log.md (in the active task)"
template: "templates/artifacts/assumptions-log.md"
---

# Skill: `ba.assumptions-log`

Maintains a first-class **assumptions log** — essential when client clarification is unavailable
(e.g. a closed questions window), so every unconfirmed decision is explicit, owned, and tracked to
validation rather than buried as fact. Agent-agnostic. Follow `memory/ba-constitution.md`
(§4 Traceability & Source Grounding — never present an assumption as fact).

## Steps

1. **Resolve the active task** (explicit arg → `.bakit-active` → most-recently-modified). Output →
   `artifacts/assumptions-log.md`.
2. **Ground in the knowledge base FIRST.** Read project `kb/index.md` then the task `kb/` (task
   precedence). Pull candidate assumptions from `kb/open-questions.md` **deferred/unanswered** items,
   any `artifacts/gap-analysis.md` / `requirements.md` `assumptions`, and analyst input. Index-first /
   RLM; a missing/empty KB is not an error.
3. **Record each assumption.** One row: `Assumption` (the working position), `Basis / rationale`,
   `Confidence` (Low/Med/High), `Impact if wrong`, `Owner`, `Validate by / how` (the path to confirm,
   e.g. client Q&A, SME, doc), `Linked OQ/Req`, and `Status` (open | confirmed | invalidated).
   State each as an assumption — never phrase it as an established fact.
4. **Link, don't duplicate.** Where an assumption answers an open question, reference the `OQ-xxx`
   (and vice-versa) so the two stay in sync; do not restate whole findings.
5. **Cite the basis** inline where one exists (`<!-- source: … -->`).
6. **Draft** into `templates/artifacts/assumptions-log.md`; set front-matter `id`, `title`,
   `status: draft`, `created`/`updated`, and a **non-empty `sources`** list.
7. **Guard existing output (non-destructive, traceable).** Do not overwrite an approved log without
   confirmation; when updating, **merge** (stable IDs; flip `Status` as items are confirmed/invalidated).
   Per `memory/ba-constitution.md` §12, **keep** invalidated/withdrawn assumptions (dated `Status` +
   reason in `## Change log`); never delete a row unless the analyst requests it.
8. **Capture reusable knowledge (controlled brain promotion)** per §11: append a `kb/changelog.md`
   entry; reflect **confirmed/invalidated** assumptions back into `kb/open-questions.md` or
   `kb/decisions.md` as appropriate. Digest only; never overwrite analyst-authored KB.
9. **Present for review** as an editable draft; do NOT self-approve.

## Validation

```sh
scripts/sh/check-artifact.sh <task>/artifacts/assumptions-log.md
```

## Next steps

```text
## Next steps
- ✎ Review/approve assumptions-log.md; assign owners and validation paths
- ▶ ba.risk-register — record risks arising from low-confidence / high-impact assumptions
- ↻ Re-run to update statuses as assumptions are confirmed or invalidated
```
