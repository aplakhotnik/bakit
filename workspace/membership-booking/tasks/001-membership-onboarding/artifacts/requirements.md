---
id: REQ-001
type: requirements
title: "Membership onboarding — requirements"
status: approved
created: 2026-08-02
updated: 2026-08-02
sources: [inputs/, artifacts/docs-analysis.md, artifacts/elicitation-plan.md]
assumptions:
  - "Consent copy/flow finalised once Legal confirms basis (OQ-001)."
  - "Latest steering (06, 2026-07-30) governs where inputs conflict."
open_questions: 2
blocking_questions: 1
---

# Requirements: Membership onboarding

## Overview

Scope for the first release: a person joins as a Free member, gives explicit consent,
is placed on a tier, and reaches the point of booking their first **Experience**.
Produced by `ba.specify` (deep mode) from the approved analysis and two rounds of
elicitation (`elicitation-plan.md`). Booking mechanics, rewards, and payment are out of
scope here. Every requirement traces to a source input, the analysis, or an elicitation
decision. Vocabulary follows the project glossary.

## Functional Requirements

- **FR-001** (P1): The system MUST let a person become a **Free member** by entering an
  email and verifying it. <!-- source: inputs/01_stakeholder-brief_2026-07-18.md -->
- **FR-002** (P1): During onboarding the system MUST place the member on a **tier**,
  defaulting to **Free**. <!-- source: artifacts/elicitation-plan.md RQ-106 -->
- **FR-003** (P1): The system MUST allow **Free members to book Experiences**; tier MUST
  NOT gate whether booking is allowed. <!-- source: artifacts/elicitation-plan.md RQ-101 -->
- **FR-004** (P1): Booking an Experience MUST require the member to be **logged in**
  (a trusted identity is needed for capacity and check-in). <!-- source: artifacts/elicitation-plan.md RQ-102 -->
- **FR-005** (P1, **blocked**): Before storing member data or contacting the member, the
  system MUST capture **explicit, opt-in, off-by-default consent**. The gate is firm; the
  exact basis and copy are pending Legal (OQ-001). <!-- source: inputs/06_revised-direction_2026-07-30.md § consent -->
- **FR-006** (P2): The system MUST reuse a **reward points** concept and MUST NOT
  implement a physical card or till-scanning. <!-- source: inputs/03_legacy-membership-prd_2025.md § analyst note -->
- **FR-007** (P2): Onboarding and booking MUST respect each Experience's **fixed
  capacity** and MUST NOT allow overbooking. <!-- source: inputs/06_revised-direction_2026-07-30.md § "fixed capacity" -->

## Non-Functional Requirements

- **NFR-001**: The onboarding journey (email → verify → consent → tier → first-Experience
  list) SHOULD be completable in under two minutes on mobile.
- **NFR-002**: Onboarding and booking MUST meet **WCAG 2.1 AA**. <!-- source: artifacts/elicitation-plan.md RQ-104 -->

## Open Questions

| ID | Question | Status | Blocking | Origin | Resolution |
|----|----------|--------|----------|--------|------------|
| OQ-001 | Legal basis for storing member data (incl. booking history) and contacting members? Gates FR-005 detail. | open | true | docs-analysis:OQ-001 | — |
| OQ-002 | Points expiry window (12 vs 24 months)? | deferred | false | docs-analysis:OQ-004 | Deferred to the booking & rewards task; implement expiry as a configurable setting, not hard-coded. |

## Override Log

<!-- Override recorded in the elicitation plan Round Log (Round 2); mirrored here for visibility. -->

| Step | Overridden question ids | Timestamp | Note |
|------|-------------------------|-----------|------|
| draft specification | OQ-001 | 2026-08-02 | Analyst proceeded to draft with the consent legal-basis blocker still open (Legal pending); flagged, not guessed. |

## Decomposition-Readiness Summary

- **Resolved:** who-can-book (Free), booking identity (login-required), vocabulary
  (Experience), accessibility (WCAG 2.1 AA), default tier (Free).
- **Open (non-blocking):** points expiry (deferred to booking & rewards).
- **Blocking:** OQ-001 — consent legal basis. To close it: Legal confirms the lawful
  basis (options: consent-only; consent + legitimate-interest for service comms; or await
  ruling). Until then FR-005's copy is provisional. The spec is otherwise **ready to
  decompose**; the walking skeleton (join → tier → reach booking) does not depend on the
  blocked consent copy.

## Assumptions

- FR-005's consent copy/flow is finalised once Legal confirms the basis (OQ-001); the
  gate itself is not optional.
- Points expiry is owned by the booking & rewards task.
