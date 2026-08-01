---
id: REQ-001
type: requirements
title: "Membership onboarding — requirements"
status: approved
created: 2026-08-01
updated: 2026-08-01
sources: [inputs/, artifacts/docs-analysis.md]
assumptions: ["Consent copy/flow finalised once Legal confirms basis (OQ-001)."]
open_questions: 3
blocking_questions: 1
---

# Requirements: Membership onboarding

## Overview

Scope for the first release: a person joins as a Free member, gives explicit
consent, is placed on a tier, and reaches the point of booking their first
**Experience**. Booking mechanics, rewards, and payment are scoped in task 002.
Every requirement traces to an approved analysis finding (`docs-analysis.md`) or a
source input. Vocabulary follows the project glossary.

## Functional Requirements

- **FR-001** (P1): The system MUST let a person become a **Free member** by entering
  an email and verifying it. <!-- source: docs-analysis:ER-001 -->
- **FR-002** (P1): During onboarding the system MUST place the member on a **tier**,
  defaulting to **Free**. Tiers are Free / Plus / Premium. <!-- source: docs-analysis:ER-002/ER-005 -->
- **FR-003** (P1): The system MUST allow **Free members to book Experiences**;
  tier MUST NOT gate whether booking is allowed. <!-- source: docs-analysis:ER-003 (decision D-2) -->
- **FR-004** (P1, **blocked**): Before storing member data or contacting the member,
  the system MUST capture **explicit, opt-in, off-by-default consent**. The exact
  basis and copy are pending Legal (OQ-001) — the requirement to gate on consent is
  firm; its detail is not. <!-- source: docs-analysis:ER-004 (decision D-4) -->
- **FR-005** (P2): The system MUST reuse a **reward points** concept; it MUST NOT
  implement a physical card or till-scanning (out of scope). <!-- source: docs-analysis:ER-006 (decision D-3) -->
- **FR-006** (P2): Onboarding and booking MUST respect each Experience's **fixed
  capacity** and MUST NOT allow overbooking. <!-- source: docs-analysis:ER-007 -->

## Non-Functional Requirements

- **NFR-001**: The onboarding journey (email → verify → consent → tier → first
  Experience list) SHOULD be completable in under two minutes on mobile.
- **NFR-002**: Onboarding and booking MUST meet the agreed accessibility target
  (assumed **WCAG 2.1 AA** pending confirmation — OQ-003).

## Open Questions

| ID | Question | Status | Blocking | Origin | Resolution |
|----|----------|--------|----------|--------|------------|
| OQ-001 | Legal basis for storing member data (incl. booking history) and contacting members? Gates FR-004 detail. | open | **true** | docs-analysis:OQ-001 | — |
| OQ-002 | Guest booking (name + email) vs login-required? | open | false | docs-analysis:OQ-002 | — |
| OQ-003 | Target WCAG level (assumed AA)? Gates NFR-002. | open | false | docs-analysis:OQ-003 | — |

## Override Log

| Step | Overridden question ids | Timestamp | Note |
|------|-------------------------|-----------|------|
| — | — | — | — |

## Assumptions

- FR-004's consent copy/flow is finalised once Legal confirms the basis (OQ-001);
  the gate itself is not optional.
- Points expiry (OQ-004 in analysis) is owned by task 002 and not required here.
