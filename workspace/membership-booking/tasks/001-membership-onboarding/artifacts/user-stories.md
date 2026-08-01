---
id: US-001
type: user-stories
title: "Membership onboarding — user stories"
status: approved
created: 2026-08-01
updated: 2026-08-01
derived_from: [REQ-001, story-map-membership-onboarding]
assumptions: []
---

# User Stories: Membership onboarding

## Overview

> **Overview** — This set delivers the first release of membership onboarding: a
> person joins as a Free member, gives explicit consent, is placed on a tier, and
> reaches the point of booking their first Experience. Every story traces to an
> approved requirement in `REQ-001` and is written INVEST-compliant. Personas are
> reused from the project KB (`../../kb/personas.md`).

| Source requirements | Author | Last updated | Status |
|---------------------|--------|--------------|--------|
| REQ-001 (FR-001…FR-006, NFR-001/002) | demo analyst | 2026-08-01 | Approved |

### Personas (from project KB)

| Persona | Goal | Pain today |
|---------|------|------------|
| **Maya — new joiner** | Join fast and reach a bookable Experience | Sign-up and booking are separate; she gives up |
| **Deno — returning enthusiast** | Be recognised and get early access | No reward for loyalty |
| **Priya — Retail Ops** | Trust who's coming; manage fixed capacity | Paper/spreadsheet booking; over/under-booking |

### Story map (at a glance)

| ID | Title | Persona | Requirements | Priority |
|----|-------|---------|--------------|----------|
| US-001 | Join as a Free member | Maya | FR-001, NFR-001 | P1 |
| US-002 | Give consent before my data is used | Maya | FR-004 | P1 (blocked) |
| US-003 | Be placed on a membership tier | Maya | FR-002 | P1 |
| US-004 | Reach a bookable Experience as a Free member | Maya | FR-003, FR-006 | P1 |
| US-005 | Accessible onboarding | (all) | NFR-002 | P2 |

---

## US-001 — Join as a Free member

> As a **prospective member**, I want **to join with just my email** so that **there
> is no barrier to getting started**.

**Acceptance Criteria**

1. **Given** I enter a valid email, **When** I submit, **Then** I receive a
   verification and, on verifying, I am a **Free member**. *(FR-001)*
2. **Given** I enter an invalid or already-registered email, **When** I submit,
   **Then** I get a clear inline message and no duplicate account is created.
3. **Given** I complete join on mobile, **When** I proceed, **Then** the flow to a
   first-Experience list is completable in **under two minutes**. *(NFR-001)*

**Open questions** — none.

---

## US-002 — Give consent before my data is used

> As a **new member**, I want **to be asked clearly what I consent to** so that **my
> data is only used in ways I agreed to**.

**Context & value** — Consent is an **explicit, off-by-default opt-in** (decision
D-4). The exact copy and legal basis are **pending Legal (OQ-001)** — this story is
**blocked for final wording** but the gate is fixed.

**Acceptance Criteria**

1. **Given** I am onboarding, **When** I reach the consent step, **Then** consent to
   be contacted is presented as **opt-in, unticked by default**. *(FR-004)*
2. **Given** I do not opt in, **When** I continue, **Then** my data is not used for
   marketing and I can still become a member.
3. **Given** Legal confirms the basis, **When** the copy is finalised, **Then** the
   step reflects the approved wording. *(pending OQ-001)*

**Open questions** — OQ-001 (blocking): legal basis for storing/using member data.

---

## US-003 — Be placed on a membership tier

> As a **new member**, I want **to be placed on a tier** so that **I know what I get**.

**Acceptance Criteria**

1. **Given** I join, **When** onboarding completes, **Then** I am on the **Free**
   tier by default. *(FR-002)*
2. **Given** I am on any tier, **When** I view my membership, **Then** I can see that
   **booking is available to me** regardless of tier. *(FR-003, decision D-2)*

**Open questions** — none.

---

## US-004 — Reach a bookable Experience as a Free member

> As a **Free member**, I want **to reach a list of Experiences I can book** so that
> **I get value on day one**.

**Acceptance Criteria**

1. **Given** I am a Free member, **When** onboarding completes, **Then** I land on a
   list of bookable **Experiences**. *(FR-003)*
2. **Given** an Experience is at **capacity**, **When** I view it, **Then** it is
   shown as full and I cannot overbook it. *(FR-006)*
3. **Given** booking may require identity for capacity/check-in, **When** I start a
   booking, **Then** the behaviour follows the guest-vs-login decision. *(OQ-002)*

**Open questions** — OQ-002: guest booking vs login-required (booking detail lands in
task 002).

---

## US-005 — Accessible onboarding

> As **any member, including those using assistive technology**, I want **the
> onboarding journey to meet an accessibility standard** so that **I can join
> independently**.

**Acceptance Criteria**

1. **Given** the agreed target (assumed **WCAG 2.1 AA**), **When** onboarding is
   built, **Then** each step meets that level. *(NFR-002)*

**Open questions** — OQ-003: confirm the WCAG target.

## Out of scope (this release)

- Booking mechanics detail, waitlist, rewards earn/redeem, payment — **task 002**.
- Physical loyalty card — discontinued (decision D-3).

## Assumptions

- none
