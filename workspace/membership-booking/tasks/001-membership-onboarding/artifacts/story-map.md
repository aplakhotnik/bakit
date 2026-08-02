---
id: story-map-membership-onboarding
type: story-map
title: "Membership onboarding — story map"
status: approved
created: 2026-08-02
updated: 2026-08-02
derived_from: [REQ-001]
open_questions: 2
blocking_questions: 1
---

# Story Map: Membership onboarding

Produced by `ba.decompose` from the approved [`requirements.md`](requirements.md). Decomposes the
first-release onboarding scope into a shape-aware backbone of prioritized slices, evaluates two
strategies, and selects one. Every requirement is covered by at least one slice of the chosen variant.

## Solution Shape

| Dimension | Applies? | Notes |
|-----------|----------|-------|
| UI | yes | join, consent, tier, first-Experience list |
| Service / API | yes | account creation, login, consent record, tier assignment |
| Data / persistence | yes | member, consent record, tier |
| External dependency | yes | **Legal sign-off gates consent (FR-005)** |
| Manual / process | no | self-service onboarding |
| Reporting | no | out of scope for v1 |

## Depth

- **Confirmed:** iterative loop (two variants evaluated; V1 selected).

## Variants

### Variant V1: journey path — **Selected variant**

**Backbone:** Join (email) → Consent → Place on tier → Log in & reach first Experience

| Slice | Pattern | Covers | MVP? | Notes |
|-------|---------|--------|------|-------|
| V1-S1 | Workflow/Path | FR-001 | ✅ walking skeleton | create Free member from verified email |
| V1-S2 | Business-Rule | FR-005 | | explicit opt-in consent, off by default (copy pending Legal) |
| V1-S3 | Business-Rule | FR-002 | | place member on a tier, default Free |
| V1-S4 | Workflow/Path | FR-003, FR-004 | | logged-in Free member reaches a bookable Experience list |
| V1-S5 | Business-Rule | FR-007 | | capacity respected; no overbooking at booking entry |

**Dependencies:** V1-S2 is gated by Legal (OQ-001); V1-S4 depends on tier placement (V1-S3) and
login (FR-004). FR-006 (points) is acknowledged but delivered in the booking & rewards task.

### Variant V2: identity-first (rejected)

Front-loads full login before consent/tier — **rejected**: contradicts the VP's "no barrier to
join" intent and delays the demonstrable join-and-reach-booking path.

## Coverage

| Requirement | Slice ids |
|-------------|-----------|
| FR-001 | [V1-S1] |
| FR-002 | [V1-S3] |
| FR-003 | [V1-S4] |
| FR-004 | [V1-S4] |
| FR-005 | [V1-S2] |
| FR-007 | [V1-S5] |

- **Uncovered:** FR-006 (points) — deferred to booking & rewards. NFR-002 (WCAG AA) applies across
  all UI slices.
- **Orphan slices:** none.

## Open Questions

| ID | Question | Status | Blocking | Origin | Resolution |
|----|----------|--------|----------|--------|------------|
| OQ-001 | Legal basis for consent — gates V1-S2. | open | true | requirements:OQ-001 | — build V1-S1/S3/S4 first; hold S2 copy. |
| OQ-002 | Points expiry window. | deferred | false | requirements:OQ-002 | Deferred to booking & rewards. |

## Session State

- **Iteration:** 2 · **Confirmed depth:** loop
- **Upstream snapshot:** requirements.md `updated: 2026-08-02`

## Change Log

- 2026-08-02 — Drafted V1 (journey path); external Legal gate on consent noted; added V2 for
  comparison and selected V1. Coverage check passed (FR-001…FR-007 → V1 slices; FR-006 deferred).
