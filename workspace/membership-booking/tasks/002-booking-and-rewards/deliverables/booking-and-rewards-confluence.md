---
id: CONF-002
type: confluence-page
title: "Athlete Membership & Booking — Booking & rewards (Release 1)"
status: approved
created: 2026-08-01
updated: 2026-08-01
derived_from: [US-002]
source_artifact: "US-002"
rendered: 2026-08-01
---

# Athlete Membership & Booking — Booking & rewards (Release 1)

> **ℹ️ Page status:** Approved · **Owner:** Product Manager · **Audience:** Delivery team & stakeholders
>
> Rendered from `US-002` on 2026-08-01. Source of record is the approved artifact.

## Page Information

| Field | Value |
|-------|-------|
| Status | Approved |
| Owner | Product Manager |
| Audience | Delivery team, Retail Ops, membership leadership |
| Source artifact | `US-002` (user stories) |
| Rendered | 2026-08-01 |
| Version | 1.0 |
| Related pages | Requirements `REQ-002`, Docs analysis (booking & rewards), Onboarding (task 001), Decision log |

## 1. Executive Summary

This release delivers the booking-and-rewards loop on top of onboarding: members book
Experiences within a fixed capacity, staff check attendees in on the day, and members
earn points for attending and redeem them against perks. It **builds directly on task
001** — vocabulary, tier eligibility, and consent are inherited from the project
decision log, not re-decided.

## 2. Background & Context

Task 001 settled who can book (everyone, including Free members), the term
"Experience", and the consent basis. This task adds the mechanics Retail Ops and the
PM described (2026-07-29 / 07-31): capacity, waitlist, check-in, and the points rules.

## 3. Scope

**In scope**

- Book an Experience within capacity; prevent overbooking.
- Check-in on the day; attendance drives earning.
- Earn points on attendance (tiered rate); redeem against perks.
- Waitlist (design-for; phaseable).

**Out of scope / pending**

- Payment provider integration (OQ-003).
- Perk catalogue management UI.

## 4. User Stories

| ID | Story | Persona | Requirements | Priority |
|----|-------|---------|--------------|----------|
| US-001 | Book an Experience within capacity | Maya | FR-001, FR-002 | P1 |
| US-002 | Check in attendees on the day | Priya | FR-003 | P1 |
| US-003 | Earn points for attending | Maya | FR-004, FR-006 | P1 |
| US-004 | Redeem points for a perk | Deno | FR-005 | P2 |
| US-005 | Join a waitlist when full | Maya | FR-007 | P3 |

### Highlights

- **Attendance, not booking, earns points** — no-shows earn nothing (US-003).
- **Capacity is never exceeded**; waitlist fills freed spots (US-001/US-005).
- **Built on inherited decisions** — no re-litigation of vocabulary, eligibility, or
  consent (see §5).

## 5. Inherited Decisions & Open Questions

| # | Item | Status | Source |
|---|------|--------|--------|
| D-1 | Bookable activity = **Experience** | Inherited (task 001) | Decision log |
| D-2 | **Free members can book**; rate varies by tier | Inherited (task 001) | Decision log |
| D-4 | Consent basis covers booking history | Inherited (task 001) | Decision log |
| OQ-001 | Points expiry window (12 vs 24 months) | Open | Rewards draft |
| OQ-002 | Cancellation cut-off | Open | Ops notes |
| OQ-003 | Payment provider & refund window | Open | Rewards draft |

## 6. Stakeholders

| Name / Role | Responsibility (R/A/C/I) |
|-------------|--------------------------|
| Product Manager | A — scope & rewards rules |
| Retail Ops (Priya) | C — capacity, check-in |
| Experience Designer | C — booking journey |
| Delivery team | R — builds the release |

## 7. References

- Source artifact: `US-002`. Upstream: `REQ-002`, docs analysis (booking & rewards).
- Inherited: onboarding (task 001), project decision log & glossary.

## 8. Change Log

| Version | Date | Author | Change |
|---------|------|--------|--------|
| 1.0 | 2026-08-01 | demo analyst | Initial render from `US-002` |
