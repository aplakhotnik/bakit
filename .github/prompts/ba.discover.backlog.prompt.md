---
name: "ba.discover.backlog"
summary: "State 3 of the Discovery workflow: translate approved gaps into a traceable Product Backlog of Epics, User Stories, and Acceptance Criteria"
inputs: "The approved Gap Analysis Matrix; the Living Discovery Document"
prerequisites: "An approved artifacts/gap-analysis.md (State 2 → State 3 phase gate)"
output: "type: product-backlog -> artifacts/product-backlog.md"
template: "templates/artifacts/product-backlog.md"
---

# Skill: `ba.discover.backlog`

**State 3 of the separate Discovery workflow.** With an approved Gap Analysis Matrix, it translates
the identified gaps into actionable backlog items — **Epics, User Stories, and Acceptance Criteria**
(with optional BDD/Gherkin) — and produces a **Product Backlog** where every item is traceable to a
gap or elicited need.

Agent-agnostic plain Markdown. Follow `memory/ba-constitution.md`,
`specs/001-ba-kit-framework/contracts/skill-contract.md`, and
`specs/004-discovery-agent-workflow/contracts/discovery-skills.md`.

## Steps

1. **Resolve the active task** and locate `artifacts/gap-analysis.md`,
   `artifacts/discovery-document.md`, and any prior `artifacts/product-backlog.md`.

2. **Living Discovery Document first (resume).** Read `artifacts/discovery-document.md`; do NOT re-ask
   answered questions (FR-024).

3. **Enforce the phase gate (FR-005, SC-002).** Verify the gap analysis is approved:

   ```sh
   scripts/sh/check-artifact.sh --require-approved <task>/artifacts/gap-analysis.md
   ```

   If this does not exit 0, **stop** and direct the analyst to approve the gap analysis first. Do NOT
   advance.

4. **Staleness check on entry (FR-025).** If a prior `product-backlog.md` exists and the approved
   gap analysis was edited after it, flag this state as potentially stale in `## Session State` and
   re-confirm before regenerating.

5. **Draft the backlog from the gaps.** Populate `templates/artifacts/product-backlog.md` into
   `artifacts/product-backlog.md` with required sections `## Epics`
   (`Epic ID | Title | Description | Source Gap`), `## User Stories`
   (`Story ID | Epic | As a / I want / So that | Acceptance Criteria | Source`),
   `## Acceptance Criteria`, and `## Traceability` (FR-014/015). Set front-matter `id`, `title`,
   `status: draft`, `created`/`updated`, and **`derived_from`** referencing the gap analysis id.
   - Offer **Gherkin** (Given/When/Then) acceptance criteria **when the analyst requests it**;
     otherwise plain criteria are fine (optional per story).
   - Where a needed detail is missing or ambiguous, **halt and ask** rather than inventing scope
     (FR-006).

6. **Guarantee traceability (FR-016, SC-004).** **Every** epic and story MUST map to a gap or elicited
   need recorded in the Living Discovery Document; complete the `## Traceability` section so no item
   is untraceable. Cite the source gap/need inline.

7. **Update the Living Discovery Document.** Refresh `## Requirements & Scope` and **append a
   `## Change Log` entry**. Advance `## Session State` for State 3.

8. **Guard existing output (non-destructive).** Do not overwrite an **approved** `product-backlog.md`
   without explicit confirmation (FR-009).

9. **Present for review.** Show the backlog as an editable draft. Do NOT set `status: approved` — the
   analyst's sign-off opens the State 3 → State 4 gate.

## Validation

```sh
scripts/sh/check-artifact.sh <task>/artifacts/product-backlog.md   # exit 0 (derived_from present)
```

## Next steps

Derive from `workflow-discovery.md`:

```text
## Next steps
- ✎ Review and set `status: approved` in artifacts/product-backlog.md to pass the State 3 gate
- ▶ ba.discover.estimate — State 4: Estimated Backlog & Roadmap (enabled when the backlog is approved)
- ↻ ba.discover.next — show Discovery progress and the next runnable state
```

Never auto-run a downstream state or any default-chain skill (FR-021). The approved Product Backlog
MAY optionally be handed to an existing skill (e.g., `ba.write-stories`) at the analyst's discretion —
but that is a manual choice, never automatic.
