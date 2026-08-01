---
id: CONF-001
type: confluence-page
title: "Athlete Membership & Booking — Membership onboarding (Release 1)"
status: approved
created: 2026-08-01
updated: 2026-08-01
derived_from: [US-001]
source_artifact: "US-001"
rendered: 2026-08-01
---

# Athlete Membership & Booking — Membership onboarding (Release 1)

<!--
  Confluence-ready Markdown rendered from the APPROVED user-stories artifact (US-001).
  The source artifact remains the canonical source of record; this page is a deliverable.
-->

> **ℹ️ Page status:** Approved · **Owner:** Product Manager · **Audience:** Delivery team & stakeholders
>
> Rendered from `US-001` on 2026-08-01. Source of record is the approved artifact, not this page.

## Page Information

| Field | Value |
|-------|-------|
| Status | Approved |
| Owner | Product Manager |
| Audience | Delivery team, membership leadership, Legal, Retail Ops |
| Source artifact | `US-001` (user stories) |
| Rendered | 2026-08-01 |
| Version | 1.0 |
| Related pages | Requirements `REQ-001`, Docs analysis (onboarding), Decision log |

## 1. Executive Summary

The first release of **Athlete Membership & Booking** lets a person join as a Free
member with just an email, give explicit consent, be placed on a tier, and reach a
list of Experiences they can book — on day one, with no barrier to entry. Booking
mechanics, rewards, and payment follow in the next task.

## 2. Background & Context

Today, sign-up and event booking live in different tools, so prospective members
drop out. Discovery ran 2026-07-18 → 2026-07-30 across six sources that initially
disagreed (see §5). The steering decision of 2026-07-30 set the current direction:
**booking is the hook and it is available to Free members**; the physical loyalty
card is discontinued; **consent is done properly with Legal sign-off**.

## 3. Scope

**In scope**

- Join as a Free member (email + verify).
- Explicit, off-by-default consent step (final copy pending Legal).
- Tier placement (Free by default; Free members can book).
- Reaching a bookable Experience list with capacity respected.
- Accessible onboarding (target assumed WCAG 2.1 AA).

**Out of scope**

- Booking mechanics, waitlist, rewards earn/redeem, payment (task 002).
- Physical loyalty card (discontinued).

## 4. User Stories

| ID | Story | Persona | Requirements | Priority |
|----|-------|---------|--------------|----------|
| US-001 | Join as a Free member | Maya | FR-001, NFR-001 | P1 |
| US-002 | Give consent before my data is used | Maya | FR-004 | P1 (blocked) |
| US-003 | Be placed on a membership tier | Maya | FR-002 | P1 |
| US-004 | Reach a bookable Experience as a Free member | Maya | FR-003, FR-006 | P1 |
| US-005 | Accessible onboarding | All | NFR-002 | P2 |

### Highlights

- **No barrier to join.** Email + verify makes a Free member (US-001).
- **Consent is explicit and off by default**, and nothing ships until Legal confirms
  the basis (US-002 / FR-004).
- **Free members can book** — the direction changed during discovery and this is now
  settled (US-003/US-004, decision D-2).

## 5. Key Decisions & Open Questions

| # | Decision / Question | Status | Owner |
|---|---------------------|--------|-------|
| D-1 | Bookable activity is called an **Experience** | Decided | PM |
| D-2 | **Free members can book** (booking is not tier-gated) | Decided | VP Membership |
| D-3 | Physical loyalty card **discontinued** | Decided | VP Membership |
| D-4 | Consent is explicit, off-by-default; Legal sign-off required | Decided (basis) | Legal |
| OQ-001 | Legal basis for storing/using member data | **Open (blocking)** | Legal |
| OQ-002 | Guest booking vs login-required | Open | Design / Ops |
| OQ-003 | Target WCAG level (assumed AA) | Open | Design |

## 6. Stakeholders

| Name / Role | Responsibility (R/A/C/I) |
|-------------|--------------------------|
| Product Manager | A — accountable for scope |
| VP Membership | A — accountable for launch decision |
| Experience Designer | C — journeys & accessibility |
| Legal / Data Privacy | C — consent basis (gates FR-004) |
| Retail Ops | C — capacity |
| Delivery team | R — builds the release |

## 7. References & Related Material

- Source artifact: `US-001` — user stories (approved).
- Upstream: `REQ-001` — requirements; docs analysis (onboarding).
- Project KB: decision log (`decisions.md`), glossary, personas.

## 8. Change Log

| Version | Date | Author | Change |
|---------|------|--------|--------|
| 1.0 | 2026-08-01 | demo analyst | Initial render from `US-001` |
