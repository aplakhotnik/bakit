# Decomposition patterns & solution shapes

A conceptual catalogue used by `ba.decompose` (and the fallback path in `ba.write-stories`) to split
large or vague requirements into small, independently testable slices. It is **vocabulary and
heuristics only** — there is no licensed or proprietary content here; the patterns are the common,
widely-described ways to vertically slice work (conceptually aligned with the SPIDR family and
classic story-splitting practice).

Two ideas work together:

1. **Solution shape** — *what kind of work* a requirement set involves. The shape tells you which
   splitting patterns are likely to apply.
2. **Splitting patterns** — *named ways* to cut a too-big slice into thin, end-to-end pieces, each
   delivering observable value and each independently testable (INVEST).

Always prefer **vertical** slices (a thin path through every layer that produces an observable
outcome) over **horizontal** ones (UI-only, then service-only, then data-only) — a vertical slice
can be demonstrated and validated; a horizontal one cannot.

---

## Solution-shape dimensions

Characterize each requirement set across these dimensions before slicing. A requirement set usually
spans several; the mix points to the patterns below.

| Dimension | What it covers | Typical splitting levers |
|-----------|----------------|--------------------------|
| **UI** | screens, forms, interactions | Interface/Channel, Workflow/Path, Data variation |
| **Service / API** | endpoints, business logic | Business-Rule variation, Workflow/Path, Operations/CRUD |
| **Data / persistence** | entities, storage, migrations | Data variation, Operations/CRUD |
| **External dependency** | third-party / upstream systems | Dependency-based, Spike/Investigation, Interface/Channel |
| **Batch / integration** | scheduled jobs, pipelines, feeds | Workflow/Path, Data variation, Dependency-based |
| **Manual / process** | human steps, approvals, hand-offs | Workflow/Path, Operations/CRUD |
| **Reporting** | analytics, exports, dashboards | Data variation, Interface/Channel |

---

## Splitting patterns

Each pattern answers "this slice is too big — how do I cut it?" Pick the one that yields the
thinnest demonstrable increment. Name the pattern you used on every slice so reviewers can see the
reasoning.

### Workflow / Path (steps of a flow)

Split an end-to-end workflow by its steps or by happy-path vs. alternate/exception paths. Deliver
the **walking skeleton** (simplest end-to-end happy path) first, then add steps and edge paths.

> *Example:* "Submit feedback" → (1) submit + store the simplest valid item; (2) add validation
> errors; (3) add attachments; (4) add the moderation step.

### Business-Rule variation (rules & conditions)

Split by the business rules a feature must honor. Implement the simplest/most-common rule first,
then add the rarer or more complex variations.

> *Example:* pricing → flat rate first; then discounts; then tax/region rules.

### Interface / Channel (how it's accessed)

Split by the interface, channel, or device. Deliver one channel end-to-end first.

> *Example:* notifications → email first; then in-app; then SMS.

### Data variation (kinds/volumes of data)

Split by data type, format, source, or volume. Support one representative shape first, then widen.

> *Example:* import → CSV first; then Excel; then API feed.

### Operations / CRUD (granularity of actions)

Split a "manage X" capability into its operations. Often Read/Create first; Update/Delete and bulk
operations later.

> *Example:* "manage tags" → view + create first; then edit; then delete; then merge.

### Spike / Investigation (reduce the unknown)

When the unknown is too large to estimate or test, carve out a **time-boxed spike** that produces a
decision/answer (not shippable behavior). Its output is knowledge that unblocks real slices — track
the open question it resolves.

> *Example:* "integrate with legacy billing" → spike the auth + a single read call, record the
> finding, then slice the real integration.

### Dependency-based (sequence by what must come first)

Split so that slices needing an external/cross-team dependency are isolated and sequenced behind a
thin independent slice, so progress isn't blocked on the dependency. Note the dependency explicitly.

> *Example:* deliver the local capture + queue first; integrate the third-party API behind it as a
> later slice.

---

## Applying the catalogue

1. **Characterize the shape** (the dimension table) for the requirement set.
2. **Draft a backbone** — the ordered activities a user moves through.
3. **Slice each backbone step** with the most fitting pattern; give every slice a variant-scoped id
   (`V{n}-S{m}`) and name its pattern + requirement ref(s).
4. **INVEST-test** each slice; if a slice is oversized or not independently testable, re-split it
   with a named pattern rather than leaving it non-compliant.
5. **Mark the MVP / walking skeleton** — the smallest set of slices that proves the path end-to-end.
6. **Check coverage** — every requirement maps to ≥1 slice; flag uncovered requirements and orphan
   slices as Open Questions.

These patterns are heuristics, not rules — the goal is always the thinnest slice that delivers
observable, testable value.
