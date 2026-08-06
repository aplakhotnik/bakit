---
name: "ba.risk-register"
summary: "Build and maintain a risk register from identified gaps, open questions, and constraints — a convergence-driven **deep mode** (default) and a lightweight **quick mode** — with likelihood, impact, severity, rating rationale, response, mitigation, residual, owner, and inter-risk dependencies"
inputs: "Gaps/open questions and constraints from the project + task kb/ (e.g. kb/open-questions.md, a task's gap-analysis/docs-analysis) plus any analyst-supplied risks"
prerequisites: "none"
output: "type: risk-register -> artifacts/risk-register.md (in the active task)"
template: "templates/artifacts/risk-register.md"
---

# Skill: `ba.risk-register`

Builds and maintains a **risk register** — converting known gaps, blocking questions, and
constraints into owned, assessed, and mitigated risks. Offers **two modes**:

- **Deep mode (default)** — a **convergence-driven** loop: keep hunting, substantiating, and
  cross-linking risks **until no material risk is left uncaptured and every High/critical risk is
  fully substantiated** (or the analyst defers). Use for a real pursuit / decision-grade register.
- **Quick mode** — a single synthesis pass (seed → assess → summarize). Use for fast triage.

Agent-agnostic. Follow `memory/ba-constitution.md`.

## Steps

1. **Resolve the active task** (explicit arg → `.bakit-active` → most-recently-modified). Output →
   `artifacts/risk-register.md`.
2. **Ground in the knowledge base FIRST.** Read project `kb/index.md` then the task `kb/` (task
   precedence), plus any task `artifacts/gap-analysis.md` / `docs-analysis.md` and the source
   `reference/` material relevant to risk. Index-first / RLM. A missing/empty KB is not an error.
3. **Choose the mode.** **Deep** (default) for a decision-grade register; **quick** when the analyst
   asks or a fast triage is enough. When unsure, prefer deep. You may start quick and **escalate to
   deep** (never silently) if High risks are under-substantiated or new material risks surface.
4. **Seed candidate risks.** Convert each **High-severity gap** and each **blocking open question**
   into a candidate risk; add delivery, commercial, security, data/migration, and dependency risks.
   **One risk per row.** Cite each risk's origin (`gap G-xxx`, `OQ-xxx`, or a source doc). Never
   fabricate a risk with no basis.
5. **Deep-mode iterative loop (no fixed round cap).** Repeat rounds until **convergence** — defined
   as: (i) a fresh scan of the sources/gaps surfaces **no new material risk**, **and** (ii) every
   **High/critical** risk has a **substantiated rating** (a rationale tied to evidence — an RFP
   clause, a volume/benchmark, or a stated assumption), a concrete **mitigation** with **owner** and
   **trigger**, and a **residual** assessment. There is **no fixed cap on rounds**; the loop ends
   only when (i)+(ii) hold or the analyst **explicitly defers** the remainder (recorded as open
   items, never as fact). Each round:
   1. **Hunt.** Scan the corpus and gaps for **un-captured risks**, including **secondary/cascade**
      risks and risks that arise **from mitigations or assumptions** themselves. Add them.
   2. **Substantiate.** For each risk set `Likelihood` and `Impact` **with a rationale** (the
      evidence behind the rating); derive `Severity`; choose a `Response` (Avoid/Mitigate/Transfer/
      Accept); write a concrete `Mitigation`, `Owner`, `Trigger`; and assess the **residual** risk
      after mitigation.
   3. **Cross-link.** Record inter-risk **dependencies and cascade paths** (risk X raises/triggers Y).
   4. **Bounded questions.** Where a rating or mitigation genuinely needs an analyst decision, ask a
      **bounded batch** (≤3) of prioritized questions — do not guess materially. Fold answers back in.
   5. **Check convergence.** Re-scan; if new material risks or unsubstantiated High risks remain, run
      **another round**. Proceed only when none remain, or the analyst defers the remainder.
6. **Quick-mode pass (if selected).** Single pass: seed (step 4), assess each risk
   (Likelihood/Impact/Severity/Response/Mitigation/Owner), and summarize — note any depth
   (rationale/residual/dependencies) deferred, and offer deep mode.
7. **Summarize.** Complete the `Severity summary` counts; note the top risks in `## Summary`.
8. **Cite & flag.** Every risk traces to its origin inline; record inferences under `assumptions`,
   never as fact.
9. **Draft** into `templates/artifacts/risk-register.md`; set front-matter `id`, `title`,
   `status: draft`, `created`/`updated`, and a **non-empty `sources`** list. In deep mode, complete
   the `## Method`, `## Rating basis & residual`, and `## Dependencies & cascade risks` sections.
10. **Guard existing output (non-destructive, traceable).** Do not overwrite an approved register
    without confirmation; when updating, **merge** (keep IDs stable, add/adjust rows) rather than
    regenerating. Per `memory/ba-constitution.md` §12, **never delete a risk row** on re-run — retire
    it by setting its `Status` (e.g. `closed` / `superseded`) with a **dated reason** in `## Change
    log`; hard-delete only if the analyst explicitly asks.
11. **Capture reusable knowledge (controlled brain promotion)** per `memory/ba-constitution.md` §11:
    append a `kb/changelog.md` entry; optionally reflect the **top/critical risks** into
    `kb/decisions.md` or `kb/open-questions.md`. Digest only; never overwrite analyst-authored KB.
12. **Present for review** as an editable draft; do NOT self-approve.

## Validation

```sh
scripts/sh/check-artifact.sh <task>/artifacts/risk-register.md
```

## Next steps

```text
## Next steps
- ✎ Review/approve risk-register.md; assign owners and confirm severities
- ▶ ba.assumptions-log — record the assumptions used to accept/mitigate risks
- ↻ Re-run to fold in new gaps/questions as the analysis evolves
```
