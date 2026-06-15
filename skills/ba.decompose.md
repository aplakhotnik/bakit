---
name: "ba.decompose"
summary: "Deliberately decompose approved requirements into a shape-aware story map (backbone, prioritized slices, MVP/walking-skeleton, dependencies), with a resumable loop, parallel strategy variants, INVEST gating, gap harvesting, and a coverage check"
inputs: "The approved artifacts/requirements.md in the active task, grounded by the project + task kb/; the splitting-pattern catalogue in docs/decomposition-patterns.md"
prerequisites: "artifacts/requirements.md with status: approved"
output: "type: story-map -> artifacts/story-map.md (in the active task)"
template: "templates/artifacts/story-map.md"
---

# Skill: `ba.decompose`

The **optional, suggested decomposition step** between `ba.specify` and `ba.write-stories`. It turns
**approved** requirements into a `story-map` artifact: a shape-aware backbone of prioritized,
independently testable slices with an explicit MVP / walking-skeleton, dependency notes, parallel
strategy variants, harvested open questions, and a coverage check. It never blocks story writing —
`ba.write-stories` can still run from approved requirements without a map.

Agent-agnostic plain Markdown. Follow `memory/ba-constitution.md` (see §"Skill Behavioral
Contract"). Ground all splitting decisions in the catalogue at `docs/decomposition-patterns.md`.

## Steps

1. **Resolve the active task** (explicit arg → `workspace/.bakit-active` → most-recently-modified).
   Output goes to that task's `artifacts/story-map.md`.

2. **Enforce the prerequisite gate (REQUIRED).** Verify the requirements artifact is approved:

   ```sh
   scripts/sh/check-artifact.sh --require-approved <task>/artifacts/requirements.md
   ```

   (Windows: `scripts/ps/check-artifact.ps1 --require-approved ...`.) If it exits non-zero
   (missing, invalid, or `status: draft`), **STOP**. Tell the analyst the requirements must be
   approved first and do NOT proceed. Never decompose from unapproved or missing requirements.

3. **Ground in the knowledge base.** Consult the **project-level** `kb/index.md`, then the task's
   `kb/index.md` (task precedence), for personas, domain terms, and constraints that shape the
   slicing. Read the index first and recurse into entries only as needed (lightweight RLM); a
   missing or empty `kb/` is **NOT an error** — continue from the approved requirements.

4. **Resume from `## Session State` (loop entry).** If a prior `artifacts/story-map.md` exists, read
   its `## Session State` and `## Change Log` first to **restore prior decisions** and do **not
   re-ask** questions already answered. Confirm the resolved variant set and confirmed depth before
   continuing.
   - **Staleness check.** If the approved `requirements.md` was re-approved or edited after the map
     (compare front-matter `updated` / the `## Session State` upstream snapshot), flag the affected
     slices as potentially stale in `## Session State` and **re-confirm** them with the analyst
     before regenerating. Never silently discard prior work.
   - **Non-destructive guard.** Do **not** overwrite an **approved** `story-map.md` without explicit
     analyst confirmation.

5. **Characterize the solution shape.** Before proposing any slice, characterize the requirement set
   across the delivery dimensions — **UI, service/API, data/persistence, external dependency,
   batch/integration, manual/process, reporting** — and record which apply (and why) in
   `## Solution Shape`. This drives both the proposed depth and the splitting-pattern selection.

6. **Propose the depth (analyst confirms).** From the solution shape, **propose** either a **quick
   single pass** (one variant, simple/well-understood shape) or an **iterative loop** (multiple
   dimensions, ambiguity, or parallel strategies worth comparing). Record the proposal and the
   analyst's **confirmed** choice in `## Depth`. **Never silently force a depth** — the analyst
   confirms or overrides.

7. **Select and name the splitting pattern(s).** For each area, select the fitting pattern(s) from
   `docs/decomposition-patterns.md` (Workflow/Path, Business-Rule variation, Interface/Channel, Data
   variation, Operations/CRUD, Spike/Investigation, Dependency-based) and **name** the pattern on
   each slice so the reasoning is reviewable. Link to the catalogue **once**; do not inline its
   content.

8. **Draft the story map.** Populate `templates/artifacts/story-map.md` into
   `artifacts/story-map.md`:
   - a **backbone** (ordered activities a user moves through),
   - **prioritized slices** with **variant-scoped ids** (`V{n}-S{m}`, starting `V1-S1`…), each
     naming its splitting pattern and requirement ref(s),
   - an explicit **MVP / walking-skeleton** marker (the thinnest end-to-end happy path),
   - a **dependencies** section (UI/service/data/external),
   - assign the first strategy variant id **`V1`** and emit a single **Selected variant** marker so a
     single-pass map still validates.
   - Set front-matter `id`, `title`, `status: draft`, `created`/`updated`, and **`derived_from`**
     referencing the approved requirements id (inline, non-empty).

9. **INVEST-gate every slice.** Test each slice against **I**ndependent, **N**egotiable, **V**aluable,
   **E**stimable, **S**mall, **T**estable. If a slice is **oversized** or **not independently
   testable**, split it using a **named pattern** from the catalogue rather than leaving a
   non-compliant slice. Never ship a slice that fails INVEST.

10. **Harvest gaps as structured open questions.** Capture decomposition gaps (ambiguities surfaced
    while slicing, unresolved dependencies, spikes needed) as structured `## Open Questions` entries
    (ID, Question, Status, Blocking, Origin, Resolution). **Carry forward** unresolved questions from
    `requirements.md` with an **origin trace** (e.g. `requirements:OQ-002`), **de-duplicated** by
    origin/trace id first, then normalized text. Keep the front-matter rollups in sync:
    `open_questions` = count of `open` rows; `blocking_questions` = count of `open` rows with
    `Blocking: true`.

11. **Coverage check.** Record a `requirement id → [slice ids]` mapping in `## Coverage` for **every**
    approved requirement (e.g. `FR-001 → [V1-S1]`). Ensure each requirement is covered by **≥1
    slice**; **flag uncovered requirements** and **orphan slices** (slices mapping to no requirement)
    — each becomes an Open Question rather than being silently dropped.

12. **Parallel strategy variants (loop only).** When the analyst wants to compare strategies, add
    additional `### Variant V{n}` sections in the **one** `story-map.md` (e.g. a Workflow/Path split
    vs. a Business-Rule split), each fully sliced with variant-scoped ids. Maintain **exactly one**
    **Selected variant** marker; when the analyst selects or changes the selection, move the marker —
    never leave zero or two.

13. **Bounded clarification.** When detail is genuinely missing, **halt and ask at most three**
    targeted, prioritized questions (with options + implications) rather than inventing slices. Fold
    answers back into the map and `## Session State`; record any deferred item as an Open Question.

14. **Update loop state.** Refresh `## Session State` (iteration, confirmed depth, upstream snapshot,
    pending items) and **append a `## Change Log` entry** for every material update.

15. **Present for review.** Show the map as an **editable draft**. Do **NOT** set `status: approved`
    — that is the analyst's sign-off.

## Validation

```sh
scripts/sh/check-artifact.sh <task>/artifacts/story-map.md   # exit 0: derived_from present + exactly one Selected variant
```

(`derived_from` is required and non-empty for this type, and the body must mark exactly one
**Selected variant**.)

## Next steps

Derived from `workflow.md`. `ba.decompose` is **optional** and never gates story writing
(run `scripts/sh/next-step.sh` to confirm the live state):

```text
## Next steps
- ✎ Review and set `status: approved` in artifacts/story-map.md when the map is ready
- ▶ ba.write-stories — expand the selected variant's slices into INVEST stories (also runnable
    directly from approved requirements if you skip the map)
- ↻ ba.next — show progress and the next runnable step
```

Never auto-run a downstream skill (per the constitution's human-in-the-loop principle).
