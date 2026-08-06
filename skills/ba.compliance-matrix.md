---
name: "ba.compliance-matrix"
summary: "Build a requirement compliance / traceability matrix — map each requirement (with its priority) to a response disposition, approach, proposal reference, and owner, with a MUST-coverage rollup"
inputs: "A requirement set: the project kb requirements register and/or the active task's approved requirements.md or a requirements workbook in inputs/; grounded by the project + task kb/"
prerequisites: "none (works from a requirements register or an approved requirements.md)"
output: "type: compliance-matrix -> artifacts/compliance-matrix.md (in the active task)"
template: "templates/artifacts/compliance-matrix.md"
---

# Skill: `ba.compliance-matrix`

Turns a requirement set into a **compliance / traceability matrix** — the backbone of an RFP or
tender response: every requirement mapped to how we meet it, with a MUST-coverage rollup that
signals responsiveness. Agent-agnostic plain Markdown. Follow `memory/ba-constitution.md`.

## Steps

1. **Resolve the active task** (explicit arg → `.bakit-active` → most-recently-modified). Output
   goes to that task's `artifacts/compliance-matrix.md`.
2. **Choose the scope.** Use the analyst's requested slice (e.g. a domain/section such as "Policy",
   "Claims", or a specific sheet); otherwise cover the whole set. Confirm the slice with the analyst.
3. **Ground in the knowledge base FIRST.** Read the project `kb/index.md`, then the task `kb/`
   (task precedence). Prefer a **requirements register** (e.g. `kb/requirements-register.md`) as the
   requirement source; else an **approved** `requirements.md`; else a requirements workbook in the
   task's `inputs/`. Read index-first and recurse only as needed (lightweight RLM). A missing/empty
   KB is not an error.
4. **Assemble rows.** One row per requirement: `Req ID`, `Priority` (MUST/SHOULD/COULD exactly as
   given), a short `Requirement`, `Domain`. **Preserve source IDs exactly; never invent, merge, or
   renumber requirements.** If the source has hundreds of rows, cover the chosen slice fully rather
   than sampling.
5. **Set the response fields.** For each row fill `Disposition` (Fully Met | Partially Met | Not Met
   | N/A), a concise `Our approach`, `Proposal ref` (doc/section/page where known), `Owner`, and
   `Status`. Where the answer isn't yet supportable, leave `Disposition` **blank/TBD** and add an
   Open Question — never assert a disposition you cannot support.
6. **Roll up MUST coverage.** Complete the `Coverage rollup` table (counts per priority ×
   disposition). Call out every **MUST that is not Fully Met** under `Gaps & risks` — these threaten
   responsiveness/disqualification.
7. **Cite & flag.** Cite each requirement's origin inline (`<!-- source: kb/requirements-register.md § … -->`
   or `<!-- source: inputs/<file> -->`). Record inferences under `assumptions`, never as fact. Keep
   the Open Questions rollup consistent if present.
8. **Draft** into `templates/artifacts/compliance-matrix.md`; set front-matter `id`, `title`,
   `status: draft`, `created`/`updated` (today), and a **non-empty `sources`** list.
9. **Guard existing output (non-destructive, traceable).** Do not overwrite an **approved** matrix
   without explicit confirmation; confirm before replacing a draft. Per `memory/ba-constitution.md`
   §12, on re-run **do not drop requirement rows** — mark any removed/superseded row with a **dated
   reason** in `## Change log` (hard-delete only on explicit request).
10. **Capture reusable knowledge (controlled brain promotion)** per `memory/ba-constitution.md` §11:
    append a `kb/changelog.md` entry and record the **MUST-coverage headline** into the relevant
    register (e.g. `kb/requirements-register.md`). Digest only; never overwrite analyst-authored KB.
11. **Present for review** as an editable draft; do NOT self-approve.

## Validation

```sh
scripts/sh/check-artifact.sh <task>/artifacts/compliance-matrix.md
```

## Next steps

```text
## Next steps
- ✎ Review/approve compliance-matrix.md; fill dispositions for any TBD rows
- ▶ ba.risk-register — turn MUST gaps and TBD dispositions into owned risks
- ▶ ba.prioritize — MoSCoW/coverage view to focus the must-win set
```
