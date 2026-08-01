---
id: US-002
type: user-stories
title: "Booking & rewards — user stories"
status: approved
created: 2026-08-01
updated: 2026-08-01
derived_from: [REQ-002]
assumptions: []
---

# User Stories: Booking & rewards

## Overview

> **Overview** — Delivers booking an Experience within capacity, check-in, and the
> earn/redeem points loop. Personas and cross-cutting decisions are reused from the
> project KB (`../../kb/`), so these stories build directly on task 001 without
> re-deciding vocabulary, tier eligibility, or consent.

| Source requirements | Author | Last updated | Status |
|---------------------|--------|--------------|--------|
| REQ-002 (FR-001…FR-007, NFR-001) | demo analyst | 2026-08-01 | Approved |

### Story map (at a glance)

| ID | Title | Persona | Requirements | Priority |
|----|-------|---------|--------------|----------|
| US-001 | Book an Experience within capacity | Maya | FR-001, FR-002 | P1 |
| US-002 | Check in attendees on the day | Priya | FR-003 | P1 |
| US-003 | Earn points for attending | Maya | FR-004, FR-006 | P1 |
| US-004 | Redeem points for a perk | Deno | FR-005 | P2 |
| US-005 | Join a waitlist when full | Maya | FR-007 | P3 |

---

## US-001 — Book an Experience within capacity

> As a **member**, I want **to book a place at an Experience** so that **I have a
> guaranteed spot**.

**Acceptance Criteria**

1. **Given** an Experience has spots, **When** I book, **Then** my place is confirmed
   and available capacity decreases by one. *(FR-001)*
2. **Given** an Experience is full, **When** I view it, **Then** it shows as full and
   I cannot book it. *(FR-002)*
3. **Given** I am a Free member, **When** I book, **Then** I am not blocked by tier.
   *(inherited decision D-2)*

**Open questions** — OQ-002 (cancellation cut-off) affects cancel/rebook.

---

## US-002 — Check in attendees on the day

> As **Retail Ops (Priya)**, I want **to check in attendees against the booking
> list** so that **I know who turned up and can manage capacity**.

**Acceptance Criteria**

1. **Given** an Experience with bookings, **When** I open its check-in list, **Then**
   I see each booked member and can mark them present. *(FR-003)*
2. **Given** a member is marked present, **When** points are calculated, **Then** only
   present members are eligible to earn. *(links FR-004)*

**Open questions** — booking identity (guest vs login) inherited-open (KB OQ-B).

---

## US-003 — Earn points for attending

> As a **member**, I want **to earn points when I actually attend** so that **showing
> up is rewarded**.

**Acceptance Criteria**

1. **Given** I am checked in at an Experience, **When** points are calculated, **Then**
   I earn points at my **tier's rate**. *(FR-004, FR-006)*
2. **Given** I booked but did not attend, **When** points are calculated, **Then** I
   earn **nothing**. *(FR-004)*
3. **Given** points have an expiry, **When** it is configured, **Then** the expiry is
   a **setting**, not hard-coded. *(NFR-001; value pending OQ-001)*

**Open questions** — OQ-001: expiry window.

---

## US-004 — Redeem points for a perk

> As a **returning member (Deno)**, I want **to redeem my points against a perk** so
> that **my participation gives me something back**.

**Acceptance Criteria**

1. **Given** I have enough points, **When** I redeem against a perk, **Then** my
   balance decreases and the perk is granted. *(FR-005)*
2. **Given** a perk requires payment (e.g. a premium Experience), **When** I proceed,
   **Then** payment follows the chosen provider. *(pending OQ-003)*

**Open questions** — OQ-003: payment provider & refund window.

---

## US-005 — Join a waitlist when full

> As a **member**, I want **to join a waitlist for a full Experience** so that **I get
> a spot if someone cancels**.

**Acceptance Criteria**

1. **Given** an Experience is full, **When** I choose to waitlist, **Then** I am added
   in order. *(FR-007)*
2. **Given** a booked member cancels, **When** a spot frees, **Then** the next
   waitlisted member is offered it. *(FR-007)*

**Open questions** — OQ-002: cancellation cut-off drives when spots free.

## Out of scope (this release)

- Payment provider integration detail (pending OQ-003).
- Perk catalogue management UI (configurable data for launch).

## Assumptions

- Inherits task 001 decisions D-1…D-4 (vocabulary, Free-can-book, no card, consent).
