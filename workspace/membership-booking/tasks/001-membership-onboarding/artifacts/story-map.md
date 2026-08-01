---
id: story-map-membership-onboarding
type: story-map
title: "Membership onboarding — story map"
status: approved
created: 2026-08-01
updated: 2026-08-01
derived_from: [REQ-001]
open_questions: 3
blocking_questions: 1
---

# Story Map: Membership onboarding

Produced by `ba.decompose` from the approved [`requirements.md`](requirements.md). It decomposes the
first-release onboarding scope into a shape-aware backbone of prioritized slices, evaluates two
strategies, and selects one. Every requirement is covered by at least one slice of the chosen variant.

## Solution Shape

| Dimension | Applies? | Notes |
|-----------|----------|-------|
| UI | yes | join, consent, tier, first-Experience list |
| Service / API | yes | account creation, consent record, tier assignment |
| Data / persistence | yes | member, consent record, tier |
| External dependency | yes | **Legal sign-off gates consent (FR-004)** |
| Batch / integration | no | none in scope |
| Manual / process | no | self-service onboarding |
| Reporting | no | out of scope for v1 |

## Depth

- **Proposed:** iterative loop — multiple UI steps plus an externally-gated consent
  step made a linear split risky; worth comparing an identity-first variant.
- **Confirmed:** iterative loop (two variants evaluated; V1 selected).

## Variants

### Variant V1: journey path — **Selected variant**

**Backbone:** Join (email) → Consent → Place on tier → See & reach first Experience

| Slice | Pattern | Covers | MVP? | Notes |
|-------|---------|--------|------|-------|
| V1-S1 | Workflow/Path | FR-001 | ✅ walking skeleton | create Free member from verified email |
| V1-S2 | Business-Rule | FR-004 | | explicit opt-in consent, off by default (copy pending Legal) |
| V1-S3 | Business-Rule | FR-002 | | place member on a tier, default Free |
| V1-S4 | Workflow/Path | FR-003 | | Free member reaches a bookable Experience list |
| V1-S5 | Business-Rule | FR-006 | | capacity respected; no overbooking at booking entry |

**Dependencies:** V1-S2 is gated by Legal (OQ-001); V1-S4 depends on tier placement
(V1-S3). FR-005 (points) is acknowledged but delivered in task 002.

### Variant V2: identity-first

**Backbone:** Account/login first → then consent/tier/booking added

| Slice | Pattern | Covers | MVP? | Notes |
|-------|---------|--------|------|-------|
| V2-S1 | Interface/Channel | FR-001 | | full account + login before anything else |
| V2-S2 | Business-Rule | FR-002, FR-004 | | tier + consent together |
| V2-S3 | Workflow/Path | FR-003, FR-006 | | booking entry |

**Dependencies:** front-loads login friction; **rejected** — it contradicts the VP's
"no barrier to join" intent and delays the demonstrable join-and-reach-booking path.

## Coverage

| Requirement | Slice ids |
|-------------|-----------|
| FR-001 | [V1-S1] |
| FR-002 | [V1-S3] |
| FR-003 | [V1-S4] |
| FR-004 | [V1-S2] |
| FR-006 | [V1-S5] |

- **Uncovered:** FR-005 (points) — deliberately deferred to task 002.
- **Orphan slices:** none.

## Open Questions

| ID | Question | Status | Blocking | Origin | Resolution |
|----|----------|--------|----------|--------|------------|
| OQ-001 | Legal basis for consent — gates V1-S2. | open | **true** | requirements:OQ-001 | — build V1-S1/S3/S4 first; hold S2 detail. |
| OQ-002 | Guest vs login-required booking — affects V1-S4 entry. | open | false | requirements:OQ-002 | — assume login for capacity trust pending decision. |
| OQ-003 | WCAG target — affects all UI slices. | open | false | requirements:OQ-003 | — assume AA. |

## Session State

- **Iteration:** 2
- **Confirmed depth:** loop
- **Upstream snapshot:** requirements.md `updated: 2026-08-01`
- **Pending items:** OQ-001 blocking on consent detail

## Change Log

- 2026-08-01 — Drafted V1 (journey path); characterized shape (external Legal gate on
  consent). Carried OQ-001…OQ-003 forward.
- 2026-08-01 — Added V2 (identity-first) for comparison; selected V1 (respects
  no-barrier-to-join). Coverage check passed (FR-001…FR-006 → V1 slices; FR-005 deferred).
