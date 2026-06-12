---
name: "ba.discover.gap-analysis"
summary: "State 2 of the Discovery workflow: map current vs. future state from the approved charter and produce a grounded Gap Analysis Matrix"
inputs: "The approved Project Charter; the Living Discovery Document; the project + task knowledge base"
prerequisites: "An approved artifacts/project-charter.md (State 1 → State 2 phase gate)"
output: "type: gap-analysis -> artifacts/gap-analysis.md"
template: "templates/artifacts/gap-analysis.md"
---

# Skill: `ba.discover.gap-analysis`

**State 2 of the separate Discovery workflow.** With an approved Project Charter in hand, it maps the
current state against the desired future state and produces a **Gap Analysis Matrix**, grounded in
the charter and the Living Discovery Document. It applies standard **BABOK-aligned analysis
practices conceptually** — there is no dependency on external or licensed BABOK content.

Agent-agnostic plain Markdown. Follow `memory/ba-constitution.md` (see §"Skill Behavioral
Contract" and §"Discovery workflow obligations").

## Steps

1. **Resolve the active task** (as in State 1) and locate `artifacts/project-charter.md`,
   `artifacts/discovery-document.md`, and `artifacts/gap-analysis.md` (if a prior draft exists).

2. **Living Discovery Document first (resume).** Read `artifacts/discovery-document.md` to restore
   prior decisions and answered questions; do NOT re-ask them (FR-024).

3. **Enforce the phase gate (FR-005, SC-002).** Verify the charter is approved:

   ```sh
   scripts/sh/check-artifact.sh --require-approved <task>/artifacts/project-charter.md
   ```

   (Windows: `scripts/ps/check-artifact.ps1 --require-approved ...`.) If this does not exit 0, **stop**
   and direct the analyst to review/approve the charter first. Do NOT advance.

4. **Staleness check on entry (FR-025).** If a prior `gap-analysis.md` exists and the approved charter
   was edited after it (compare front-matter `updated` / mtime), flag this state as potentially stale
   in the Living Discovery Document's `## Session State` and re-confirm the affected analysis with the
   analyst before regenerating.

5. **Analyze and elicit the missing detail.** From the charter, derive the current state and the
   desired future state. Where current- or future-state detail is missing or ambiguous, **halt and
   ask a targeted, bounded clarification set** — never invent gaps (FR-006).

6. **Draft the Gap Analysis Matrix.** Populate `templates/artifacts/gap-analysis.md` into
   `artifacts/gap-analysis.md` with required sections `## Summary`, `## Gap Matrix`
   (`Area | Current State | Future State | Gap | Implication | Source`), and `## Open Questions`
   (FR-012/013). Set front-matter `id`, `title`, `status: draft`, `created`/`updated`, and
   **`derived_from`** referencing the charter's id.
   - Each gap MUST be substantiated from captured inputs/charter; cite the source inline
     (`<!-- source: artifacts/project-charter.md#... -->`).
   - **Unsubstantiated** suspected gaps go to `## Open Questions`, not the matrix (SC-003).
   - If **no gaps** are found, state that explicitly in `## Summary` rather than inventing gaps.

7. **Update the Living Discovery Document.** Refresh `## Gaps` from the matrix and **append a
   `## Change Log` entry**. Advance `## Session State` to reflect State 2 in progress / its gate.

8. **Guard existing output (non-destructive).** Do not overwrite an **approved** `gap-analysis.md`
   without explicit confirmation (FR-009).

9. **Present for review.** Show the matrix as an editable draft. Do NOT set `status: approved` — that
   is the analyst's sign-off, which opens the State 2 → State 3 gate.

## Validation

```sh
scripts/sh/check-artifact.sh <task>/artifacts/gap-analysis.md   # exit 0 (derived_from present)
```

## Next steps

Derive from `workflow-discovery.md`:

```text
## Next steps
- ✎ Review and set `status: approved` in artifacts/gap-analysis.md to pass the State 2 gate
- ▶ ba.discover.backlog — State 3: Product Backlog (enabled when the gap analysis is approved)
- ↻ ba.discover.next — show Discovery progress and the next runnable state
```

Never auto-run a downstream state or any default-chain skill (FR-021).
