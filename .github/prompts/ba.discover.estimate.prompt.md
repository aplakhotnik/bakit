---
name: "ba.discover.estimate"
summary: "State 4 of the Discovery workflow: pick an estimation method, run a guided estimation session over the approved backlog, and produce an Estimated Backlog and Release Roadmap"
inputs: "The approved Product Backlog; the Living Discovery Document"
prerequisites: "An approved artifacts/product-backlog.md (State 3 → State 4 phase gate)"
output: "type: estimated-backlog -> artifacts/estimated-backlog.md (sized backlog + release roadmap)"
template: "templates/artifacts/estimated-backlog.md"
---

# Skill: `ba.discover.estimate`

**State 4 — the final state of the separate Discovery workflow.** With an approved Product Backlog,
it offers estimation methodology options, guides an interactive estimation session using the chosen
method, and produces an **Estimated Backlog** plus a **Release Roadmap**. It never guesses an
estimate: any item it cannot size is flagged `UNESTIMABLE`.

Agent-agnostic plain Markdown. Follow `memory/ba-constitution.md`,
`specs/001-ba-kit-framework/contracts/skill-contract.md`, and
`specs/004-discovery-agent-workflow/contracts/discovery-skills.md`.

## Steps

1. **Resolve the active task** and locate `artifacts/product-backlog.md`,
   `artifacts/discovery-document.md`, and any prior `artifacts/estimated-backlog.md`.

2. **Living Discovery Document first (resume).** Read `artifacts/discovery-document.md` to restore
   prior decisions and, if set, the previously chosen estimation method; do NOT re-ask answered
   items (FR-024).

3. **Enforce the phase gate (FR-005, SC-002).** Verify the product backlog is approved:

   ```sh
   scripts/sh/check-artifact.sh --require-approved <task>/artifacts/product-backlog.md
   ```

   If this does not exit 0, **stop** and direct the analyst to approve the backlog first. Do NOT
   advance.

4. **Staleness check on entry (FR-025).** If a prior `estimated-backlog.md` exists and the approved
   backlog was edited after it, flag this state as potentially stale in `## Session State` and
   re-confirm before regenerating.

5. **Offer estimation methods (FR-017).** Present at least **Fibonacci**, **T-Shirt**, and **PERT**,
   briefly describing each, and ask the analyst to choose one. Record the chosen method. **Do not mix
   scales.** If the analyst switches methods later, **re-estimate** the affected items under the new
   method rather than mixing scales silently (edge case).

6. **Run the interactive estimation session (FR-018, SC-009).** Walk the backlog **item by item** and
   record an estimate in the chosen scale. When an item lacks the information needed to size it,
   **flag it `UNESTIMABLE`** with the missing detail captured as a question under `## Open Questions`
   — **never guess** a value.

7. **Produce the deliverable.** Populate `templates/artifacts/estimated-backlog.md` into
   `artifacts/estimated-backlog.md` with required sections `## Estimation Method` (chosen method +
   scale legend), `## Estimated Backlog` (`Story ID | Title | Estimate | Confidence/Notes`, with
   `UNESTIMABLE` markers where applicable), `## Release Roadmap`
   (`Release / Milestone | Included Items | Rationale`), and `## Open Questions` (FR-019). Set
   front-matter `id`, `title`, `status: draft`, `created`/`updated`, and **`derived_from`**
   referencing the product backlog id.

8. **Update the Living Discovery Document.** Refresh `## Estimates & Plan` (chosen method, sizes,
   roadmap summary), record the chosen method in `## Session State`, and **append a `## Change Log`
   entry**.

9. **Guard existing output (non-destructive).** Do not overwrite an **approved** `estimated-backlog.md`
   without explicit confirmation (FR-009).

10. **Present for review.** Show the Estimated Backlog & Roadmap as an editable draft. Do NOT set
    `status: approved` — that is the analyst's sign-off. This completes the Discovery workflow.

## Validation

```sh
scripts/sh/check-artifact.sh <task>/artifacts/estimated-backlog.md   # exit 0 (derived_from present)
```

## Next steps

Derive from `workflow-discovery.md` — this is the terminal state:

```text
## Next steps
- ✎ Review and set `status: approved` in artifacts/estimated-backlog.md to finalize Discovery
- ↻ ba.discover.next — confirm all Discovery states have produced output
- (optional, manual) Hand an approved Discovery deliverable to an existing skill if you choose
```

Never auto-run any default-chain skill (FR-021). Handoff is always the analyst's manual choice.
