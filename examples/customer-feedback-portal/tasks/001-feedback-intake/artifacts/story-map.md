---
id: story-map-feedback-intake
type: story-map
title: "Feedback intake — story map"
status: approved
created: 2026-06-15
updated: 2026-06-15
derived_from: [REQ-001]
open_questions: 2
blocking_questions: 0
---

# Story Map: Feedback intake

Produced by `ba.decompose` from the approved [`requirements.md`](requirements.md). It decomposes the
first-release scope into a shape-aware backbone of prioritized, INVEST-tested slices, evaluates two
strategies as parallel variants, and selects one. Every requirement is covered by at least one slice
of the chosen variant.

## Solution Shape

| Dimension | Applies? | Notes |
|-----------|----------|-------|
| UI | yes | capture form (FR-001) and product-owner queue (FR-004) |
| Service / API | yes | categorisation + routing logic (FR-002, FR-003) |
| Data / persistence | yes | feedback item, category, owner mapping |
| External dependency | no | self-contained first release |
| Batch / integration | no | none in scope |
| Manual / process | yes | product-owner triage (FR-004) |
| Reporting | no | explicitly deferred (see requirements Overview) |

## Depth

- **Proposed:** iterative loop — multiple dimensions (UI + service + manual process) and a routing
  rule worth comparing against an interface-first split made the loop worthwhile.
- **Confirmed:** iterative loop (two variants evaluated; V1 selected).

## Variants

### Variant V1: end-to-end workflow path — **Selected variant**

**Backbone:** Capture feedback → Categorise → Route to owner → Triage queue

| Slice | Pattern | Covers | MVP? | Notes |
|-------|---------|--------|------|-------|
| V1-S1 | Workflow/Path | FR-001 | ✅ walking skeleton | capture + store a feedback item in ≤3 interactions |
| V1-S2 | Business-Rule variation | FR-002 | | assign exactly one category from the defined set |
| V1-S3 | Workflow/Path | FR-003 | | route the categorised item to the mapped product owner |
| V1-S4 | Operations/CRUD | FR-004 | | owner views their queue and marks items actioned |
| V1-S5 | Business-Rule variation | FR-005 | | optional anonymous submission (off by default) |

**Dependencies:** V1-S3 depends on the category set from V1-S2; V1-S4 depends on routing (V1-S3).
No external systems.

### Variant V2: interface-first (capture channel before triage)

**Backbone:** Capture channel → Persist → (categorise/route/triage added later)

| Slice | Pattern | Covers | MVP? | Notes |
|-------|---------|--------|------|-------|
| V2-S1 | Interface/Channel | FR-001 | | ship the capture form alone first |
| V2-S2 | Workflow/Path | FR-002, FR-003 | | add categorise + route together afterwards |
| V2-S3 | Operations/CRUD | FR-004 | | owner triage queue |
| V2-S4 | Business-Rule variation | FR-005 | | anonymous option |

**Dependencies:** defers routing value; rejected because it delays the demonstrable end-to-end path.

## Coverage

| Requirement | Slice ids |
|-------------|-----------|
| FR-001 | [V1-S1] |
| FR-002 | [V1-S2] |
| FR-003 | [V1-S3] |
| FR-004 | [V1-S4] |
| FR-005 | [V1-S5] |

- **Uncovered requirements:** none (NFR-001 is exercised through FR-001 / V1-S1).
- **Orphan slices:** none.

## Open Questions

| ID | Question | Status | Blocking | Origin | Resolution |
|----|----------|--------|----------|--------|------------|
| OQ-001 | Is the category → product-owner mapping fixed or assigned by a person? | open | false | requirements:OQ-002 | — affects V1-S3; assumed fixed mapping for the MVP. |
| OQ-002 | What is the expected volume of feedback per day? | open | false | requirements:OQ-003 | — informs sizing of V1-S4; no blocker for slicing. |

## Session State

- **Iteration:** 2
- **Confirmed depth:** loop
- **Upstream snapshot:** requirements.md `updated: 2026-06-12` (re-confirm if it changes)
- **Pending items:** none

## Change Log

- 2026-06-15 — Drafted V1 (workflow path) and characterized the solution shape; carried OQ-002/OQ-003
  forward from requirements.
- 2026-06-15 — Added V2 (interface-first) for comparison; selected V1 as it delivers the end-to-end
  path soonest. Coverage check passed (FR-001..FR-005 → V1 slices).
