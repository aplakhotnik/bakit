---
name: "ba.prioritize"
summary: "Produce a MoSCoW prioritization and coverage view of a requirement set — MUST/SHOULD/COULD tallies per area, our coverage (Have/Partial/Gap), gaps-to-win, and an MVP/must-win set"
inputs: "A requirement set: the project kb requirements register and/or the active task's approved requirements.md; capability context from the kb/; grounded by the project + task kb/"
prerequisites: "none"
output: "type: prioritization -> artifacts/prioritization.md (in the active task)"
template: "templates/artifacts/prioritization.md"
---

# Skill: `ba.prioritize`

Produces a **MoSCoW + coverage** view of a requirement set: how many MUST/SHOULD/COULD exist per
area, where we are strong vs. gapped, and the minimum must-win set. Complements `ba.specify`
(which captures requirements) and `ba.compliance-matrix` (which records per-requirement disposition).
Agent-agnostic. Follow `memory/ba-constitution.md`.

## Steps

1. **Resolve the active task** (explicit arg → `.bakit-active` → most-recently-modified). Output →
   `artifacts/prioritization.md`.
2. **Choose the scope** (a domain/area/sheet, or the whole set). Confirm with the analyst.
3. **Ground in the knowledge base FIRST.** Read project `kb/index.md` then the task `kb/` (task
   precedence). Use a **requirements register** (e.g. `kb/requirements-register.md`) or an approved
   `requirements.md` as the requirement source, and any capability/context entries for coverage.
   Index-first / RLM; a missing/empty KB is not an error.
4. **Tally MoSCoW.** Complete the `MoSCoW tally` — counts of MUST/SHOULD/COULD per area/sheet.
   Use the priorities exactly as given in the source; if a priority is missing, mark it and add an
   open question rather than assigning one.
5. **Assess coverage & gaps-to-win.** For each priority group (especially MUST), record our
   `Coverage` (Have / Partial / Gap) and the concrete `Gap-to-win / action` and `Owner`. Base
   coverage on grounded capability facts; where unknown, mark it and flag an assumption.
6. **Define the MVP / must-win view** — the minimum set that must be Fully Met to be responsive and
   competitive (typically all MUSTs plus differentiating SHOULDs).
7. **Cite & flag.** Cite requirement/coverage origins inline; record inferences under `assumptions`.
8. **Draft** into `templates/artifacts/prioritization.md`; set front-matter `id`, `title`,
   `status: draft`, `created`/`updated`, and a **non-empty `sources`** list.
9. **Guard existing output (non-destructive, traceable).** Do not overwrite an approved artifact
   without confirmation. Per `memory/ba-constitution.md` §12, on re-run **do not silently drop** rows
   — supersede them with a **dated reason** in `## Change log` (hard-delete only on explicit request).
10. **Capture reusable knowledge (controlled brain promotion)** per §11: append a `kb/changelog.md`
    entry and record the MUST/SHOULD/COULD tallies + must-win headline into `kb/requirements-register.md`.
    Digest only; never overwrite analyst-authored KB.
11. **Present for review** as an editable draft; do NOT self-approve.

## Validation

```sh
scripts/sh/check-artifact.sh <task>/artifacts/prioritization.md
```

## Next steps

```text
## Next steps
- ✎ Review/approve prioritization.md; confirm the must-win set
- ▶ ba.compliance-matrix — record per-requirement disposition against the priorities
- ▶ ba.risk-register — capture risks for MUSTs currently at Partial/Gap coverage
```
