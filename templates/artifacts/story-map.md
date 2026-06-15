---
id: ""
type: story-map
title: ""
status: draft
created: ""
updated: ""
derived_from: [requirements-<task-slug>]
open_questions: 0
blocking_questions: 0
---

# Story Map: {{TITLE}}

<!--
  Produced by `ba.decompose` from APPROVED requirements. This is the optional, suggested
  decomposition step between `ba.specify` and `ba.write-stories`. Populate `derived_from` with the
  approved requirements artifact id (inline, non-empty). Keep `open_questions` / `blocking_questions`
  in sync with the `## Open Questions` table below (absent ⇒ 0). The body MUST contain EXACTLY ONE
  selected-variant marker (see `## Variants`); `check-artifact` counts it and requires a count of 1.
  Present as an editable draft — the analyst sets `status: approved`. No skill self-approves.
-->

## Solution Shape

<!--
  Characterize the requirement set across the delivery dimensions before proposing slices. Mark
  which apply and why; this drives pattern selection and the proposed depth. See the catalogue in
  docs/decomposition-patterns.md.
-->

| Dimension | Applies? | Notes |
|-----------|----------|-------|
| UI | <yes/no> | <what UI is involved> |
| Service / API | <yes/no> | <endpoints, logic> |
| Data / persistence | <yes/no> | <entities, storage> |
| External dependency | <yes/no> | <third-party / upstream> |
| Batch / integration | <yes/no> | <scheduled / pipeline work> |
| Manual / process | <yes/no> | <human steps> |
| Reporting | <yes/no> | <analytics / exports> |

## Depth

<!-- Propose quick single pass vs. iterative loop from the solution shape; the analyst confirms or
     overrides. Never silently force a depth. -->

- **Proposed:** <quick single pass | iterative loop> — <one-line rationale from the shape above>
- **Confirmed:** <analyst's choice>

## Variants

<!--
  One `### Variant V{n}: <name>` per decomposition strategy. A single-pass map has just V1. Each
  variant has a backbone (ordered activities), prioritized slices with variant-scoped ids
  (`V{n}-S{m}`) that name a splitting pattern and the requirement ref(s), an MVP / walking-skeleton
  marker, and optional dependency notes. EXACTLY ONE variant heading carries the bold
  selected-variant marker shown on V1 below.
-->

### Variant V1: <strategy name> — **Selected variant**

**Backbone:** <ordered activity 1> → <activity 2> → <activity 3>

| Slice | Pattern | Covers | MVP? | Notes |
|-------|---------|--------|------|-------|
| V1-S1 | <named pattern> | <FR-00x> | ✅ walking skeleton | <note> |
| V1-S2 | <named pattern> | <FR-00y> | | <note> |

**Dependencies:** <UI/service/data/external dependency notes, or "none">

<!--
  To evaluate a parallel strategy, duplicate the block below as `### Variant V2: <name>` (without
  the marker) and re-slice the backbone differently. Move the marker to whichever variant the
  analyst selects — keep it on exactly one.

### Variant V2: <alternative strategy>

**Backbone:** …

| Slice | Pattern | Covers | MVP? | Notes |
|-------|---------|--------|------|-------|
| V2-S1 | <named pattern> | <FR-00x> | | <note> |

**Dependencies:** …
-->

## Coverage

<!-- Map every approved requirement to ≥1 slice id of the chosen variant. Flag any requirement
     with zero slices (uncovered) and any slice that maps to no requirement (orphan); each becomes
     an Open Question. -->

| Requirement | Slice ids |
|-------------|-----------|
| FR-001 | [V1-S1] |
| FR-002 | [V1-S2] |

- **Uncovered requirements:** <list, or "none">
- **Orphan slices:** <list, or "none">

## Open Questions

<!-- Structured entries (007 pattern). Keep the front-matter rollups in sync: `open_questions` =
     count of `open` rows; `blocking_questions` = count of `open` rows with Blocking = true. Carry
     forward unresolved questions from requirements.md with an origin trace. -->

| ID | Question | Status | Blocking | Origin | Resolution |
|----|----------|--------|----------|--------|------------|
| OQ-001 | <ambiguity surfaced during decomposition> | open | false | <decompose \| requirements:OQ-00x> | — |

## Session State

<!-- Resumable-loop state so re-entry never re-asks answered questions. -->

- **Iteration:** <n>
- **Confirmed depth:** <quick | loop>
- **Upstream snapshot:** requirements.md `updated: <YYYY-MM-DD>` (re-confirm if it changes)
- **Pending items:** <open decisions, or "none">

## Change Log

<!-- Append-only; one entry per material update. -->

- {{DATE}} — <what changed and why>
