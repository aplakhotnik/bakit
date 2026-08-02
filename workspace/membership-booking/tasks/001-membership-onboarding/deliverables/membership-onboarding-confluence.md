---
id: CONF-001
type: confluence-page
title: "Athlete Membership & Booking — Membership onboarding (Release 1)"
status: approved
created: 2026-08-02
updated: 2026-08-02
derived_from: [US-001]
source_artifact: "US-001"
rendered: 2026-08-02
---

# Athlete Membership & Booking — Membership onboarding (Release 1)

> **ℹ️ Page status:** Approved · **Owner:** Product Manager · **Audience:** Delivery team & stakeholders
>
> Rendered from `US-001` on 2026-08-02. Source of record is the approved artifact.

## Page Information

| Field | Value |
|-------|-------|
| Status | Approved |
| Owner | Product Manager |
| Audience | Delivery team, membership leadership, Legal, Retail Ops |
| Source artifact | `US-001` (user stories) |
| Rendered | 2026-08-02 |
| Version | 1.0 |
| Related pages | Requirements `REQ-001`, Elicitation plan `EP-001`, Docs analysis `DA-001` |

## 1. Executive Summary

The first release lets a person join as a Free member with just an email, give explicit
consent, be placed on a tier, log in, and reach a list of Experiences they can book — on
day one, with no barrier to entry. Booking mechanics, rewards, and payment follow later.

## 2. Background & Context

Discovery ran 2026-07-18 → 2026-07-30 across six sources that initially disagreed. The
analysis reconciled them and two elicitation rounds settled the open scope questions
(see §5). Key outcomes: **booking is available to Free members**; **booking requires
login** (for capacity and check-in); the physical card is discontinued; **consent is
handled properly, pending Legal sign-off**.

## 3. Scope

**In scope**

- Join as a Free member (email + verify).
- Explicit, off-by-default consent step (final copy pending Legal).
- Tier placement (Free by default; Free members can book).
- Logged-in member reaching a bookable Experience list, capacity respected.
- Accessible onboarding (WCAG 2.1 AA).

**Out of scope**

- Booking mechanics, waitlist, rewards, payment (booking & rewards task).
- Physical loyalty card (discontinued).

## 4. User Stories

| ID | Story | Persona | Requirements | Priority |
|----|-------|---------|--------------|----------|
| US-001 | Join as a Free member | Maya | FR-001, NFR-001 | P1 |
| US-002 | Give consent before my data is used | Maya | FR-005 | P1 (blocked) |
| US-003 | Be placed on a membership tier | Maya | FR-002 | P1 |
| US-004 | Log in and reach a bookable Experience | Maya | FR-003, FR-004, FR-007 | P1 |
| US-005 | Accessible onboarding | All | NFR-002 | P2 |

## 5. Key Decisions & Open Questions

| # | Decision / Question | Status | Owner |
|---|---------------------|--------|-------|
| 1 | Bookable activity is called an **Experience** | Decided | PM |
| 2 | **Free members can book** (not tier-gated) | Decided | VP Membership |
| 3 | Booking **requires login** (capacity/check-in) | Decided | Ops / Design |
| 4 | Accessibility target **WCAG 2.1 AA** | Decided | Design |
| 5 | Physical loyalty card **discontinued** | Decided | VP Membership |
| OQ-001 | Legal basis for storing/using member data | **Open (blocking)** | Legal |
| OQ-002 | Points expiry window | Deferred → booking & rewards | PM |

## 6. Stakeholders

| Name / Role | Responsibility (R/A/C/I) |
|-------------|--------------------------|
| Product Manager | A — accountable for scope |
| VP Membership | A — launch decision |
| Experience Designer | C — journeys & accessibility |
| Legal / Data Privacy | C — consent basis (gates FR-005) |
| Retail Ops | C — capacity |
| Delivery team | R — builds the release |

## 7. References

- Source artifact: `US-001`. Upstream: `REQ-001`, `EP-001` (elicitation), `DA-001` (analysis).
- Project KB: glossary, personas, decision log.

## 8. Change Log

| Version | Date | Author | Change |
|---------|------|--------|--------|
| 1.0 | 2026-08-02 | demo analyst | Initial render from `US-001` |
