---
name: "ba.specify"
summary: "Turn a plain-language need into a rigorous, review-ready specification via an iterative, KB-grounded elicitation loop"
inputs: "The analyst's plain-language description of a need; the project + task knowledge base; project context captured at initiation; optionally raw material in inputs/"
prerequisites: "none (does NOT require a pre-existing BRD/FRD)"
output: "type: requirements -> artifacts/requirements.md (the specification) AND type: elicitation-plan -> artifacts/elicitation-plan.md (the living plan)"
template: "templates/artifacts/requirements.md and templates/artifacts/elicitation-plan.md"
---

# Skill: `ba.specify`

The **robust, front-door elicitation skill** — the BA analogue of `speckit.specify`. It starts
from a stakeholder's plain-language *need* (no pre-existing BRD/FRD required), grounds the work in
the knowledge base and project context, runs an **iterative, multi-round "deep research"
clarification loop** (persisted in a living elicitation plan), validates the result against a
quality checklist, and presents a `draft` specification for human approval.

Authored as agent-agnostic plain Markdown with the framework's standard front-matter — no
agent-proprietary features. Follow `memory/ba-constitution.md`,
`specs/001-ba-kit-framework/contracts/skill-contract.md`, and
`specs/002-specify-skill/contracts/ba-specify.md`.

> **Coexistence.** `ba.specify` does **not** replace `ba.specify-requirements`. The lightweight
> "raw notes/inputs → requirements list" path remains available via `ba.specify-requirements`;
> use `ba.specify` when you are starting from a described *need* and want rigorous, multi-round
> elicitation. Both skills write the same `artifacts/requirements.md`.

## Steps

1. **Resolve the active task.** Use an explicit project/task if the analyst named one; otherwise
   read `workspace/.bakit-active`, else use the most-recently-modified task. Confirm the resolved
   target with the analyst. Output goes to that task's `artifacts/requirements.md` and
   `artifacts/elicitation-plan.md`.

2. **Intake the need.** Take the analyst's plain-language description of the need (a sentence to a
   few paragraphs). You MUST NOT require a pre-existing requirements document (BRD/FRD).
   - **Empty input:** if no description was given AND there is no usable content in the task's
     `kb/` or `inputs/`, ask the analyst for a description rather than fabricating a specification.
   - **Formal-requirements input:** if `inputs/` already contains a pasted BRD/FRD (content that
     is already structured as formal requirements), recommend `ba.analyze-docs` for that material
     instead of duplicating documentation analysis — then continue only with the genuinely
     net-new need, if any.

3. **Ground in the knowledge base and project context FIRST.** Before drafting, consult curated
   context so you reuse known facts instead of re-asking:
   - Read the **project-level** `kb/index.md`, then the active task's `kb/index.md` (task
     knowledge takes precedence). Use the `## Summary`/`## Entries` to decide what is relevant;
     follow the index into specific entries and process them in focused chunks (lightweight RLM)
     for large/multi-entry knowledge, single-pass for small. A missing/empty `kb/` is NOT an
     error — continue.
   - Consult the **project context** elicited at initiation by `ba.start-project` (stored in the
     project-level `kb/`). Do NOT re-elicit it here. If it is absent, continue and note its
     absence as an assumption.
   - Cite grounded content inline where you use it: `<!-- source: kb/<entry> -->`.

4. **Run the iterative elicitation loop (deep research).** Repeat the following as multiple
   rounds until the analyst signals common understanding (or explicitly defers the rest):
   1. **Detect & question.** Identify ambiguities, gaps, and conflicts. Raise a **bounded**
      (default ≤3 per round), **prioritized** (scope before detail) set of clarification
      questions, each with **options and the implication of each option**. Never silently guess on
      decisions that materially change scope. Surface any contradiction as a question rather than
      picking a side.
   2. **Update the elicitation plan.** Create or refresh `artifacts/elicitation-plan.md` from
      `templates/artifacts/elicitation-plan.md`: refine **Current Shared Understanding**, refresh
      **Open Questions**, restate **Next Steps**, and **append a Round Log entry** (questions
      asked / answers received). Set front-matter `id`, `title`, `status: draft`,
      `created`/`updated`, and bump `round` each pass.
   3. **Fold in answers.** Incorporate the analyst's answers; move resolved items to **Resolved**.
      Record any deferred question as a flagged assumption / open question — never as fact.
   4. **Check convergence.** Ask the analyst whether understanding is complete. If not, run
      another round. If yes (or they defer remaining items), proceed to draft the specification.

5. **Draft the specification.** Derive a concise, human-readable `title` for the need, then
   populate `templates/artifacts/requirements.md` **as the existing `type: requirements` artifact
   (reused unchanged)** so it slots into the workflow chain:
   - Prioritized, independently testable **user scenarios**.
   - Numbered, **testable functional requirements** (and non-functional where relevant).
   - **Measurable, technology-agnostic success criteria**.
   - **Key entities** where the need involves data.
   - Cite each derived item's source inline (`<!-- source: kb/<entry> -->` or
     `<!-- source: inputs/<file> -->`).
   - Set front-matter: a unique `id`, the `title`, `status: draft`, `created`/`updated` to today.
   - Populate `assumptions` (also reflected in the Assumptions section); never present an
     assumption as fact.

6. **Guard existing output (non-destructive).** Before writing `requirements.md`:
   - If an **approved** `requirements.md` already exists, do NOT overwrite it without explicit
     analyst confirmation.
   - Because `ba.specify` and `ba.specify-requirements` share this output, if a **draft**
     `requirements.md` already exists (from either skill), confirm before replacing it, noting
     which skill last wrote it.

7. **Validate against the quality checklist.** After drafting, self-validate and iterate within a
   bounded number of passes (default ≤3):
   - Each functional requirement is **testable and unambiguous**.
   - Each success criterion is **measurable and free of implementation/technology detail**.
   - **Scope is bounded**; assumptions are recorded; **no unresolved clarification markers**
     remain (deferred items live under Open Questions/assumptions, not as fact).
   - Flag each failing item with the specific issue, revise, and re-check. If the checklist cannot
     fully pass within the pass limit, record the remaining issues and **warn** the analyst rather
     than presenting the spec as complete.

8. **Capture reusable knowledge.** If durable, reusable knowledge emerged (agreed terms,
   decisions, constraints), add or update the relevant `kb/` entry and reflect it in that
   `kb/index.md` (task-level for task-specific facts, project-level for shared ones).

9. **Present for review.** Show both artifacts as editable proposals. Do NOT set `status:
   approved` — that is the analyst's decision. Once `requirements.md` is approved it becomes the
   source of truth for `ba.write-stories`.

## Validation

After a converged run, both artifacts must pass:

```sh
scripts/sh/check-artifact.sh <task>/artifacts/requirements.md
scripts/sh/check-artifact.sh <task>/artifacts/elicitation-plan.md
```

Both MUST exit 0. The specification MUST additionally satisfy the quality checklist from step 7
(no untestable requirement or non-measurable success criterion presented as final).

## Next steps

Derived from `workflow.md`. `ba.write-stories` is gated on `requirements.md` being **approved**
(run `scripts/sh/next-step.sh` to confirm the live state):

```text
## Next steps
- ▶ ba.write-stories — convert this specification into user stories (enabled when requirements.md is approved)
- ✎ Review/approve requirements.md first if it is still draft
- 🔁 Continue ba.specify if the elicitation plan still has open questions
```
