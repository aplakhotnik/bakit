---
id: REQ-002
type: requirements
title: "Booking & rewards — requirements"
status: approved
created: 2026-08-01
updated: 2026-08-01
sources: [inputs/, artifacts/docs-analysis.md]
assumptions: ["Inherits task 001 decisions D-1..D-4."]
open_questions: 3
blocking_questions: 0
---

# Requirements: Booking & rewards

## Overview

Scope for the booking-and-rewards release: book an **Experience** within capacity,
support waitlist and check-in, and earn/redeem **reward points**. Cross-cutting
decisions (vocabulary, Free-can-book, consent basis) are **inherited** from task 001
via the project KB and are not restated as questions here.

## Functional Requirements

- **FR-001** (P1): A member MUST be able to **book** an Experience; booking MUST
  decrement available capacity by one. <!-- docs-analysis:ER-001 -->
- **FR-002** (P1): The system MUST prevent **overbooking**; a full Experience MUST be
  shown as full. <!-- docs-analysis:ER-002; inherited task001 FR-006 -->
- **FR-003** (P1): Staff MUST be able to **check in** attendees against the booking
  list on the day. <!-- docs-analysis:ER-004 -->
- **FR-004** (P1): A member MUST earn **points on confirmed attendance** (check-in);
  no-shows MUST earn nothing. <!-- docs-analysis:ER-005 -->
- **FR-005** (P2): A member MUST be able to **redeem points** against perks
  (catalogue configurable). <!-- docs-analysis:ER-006 -->
- **FR-006** (P2): Earning **rate MUST vary by tier** (Free base; Plus/Premium
  higher). <!-- docs-analysis:ER-007; inherited D-2 -->
- **FR-007** (P3): The system SHOULD support a **waitlist**: on cancellation, offer
  the freed spot to the next waitlisted member. <!-- docs-analysis:ER-003 -->

## Non-Functional Requirements

- **NFR-001**: Point **expiry** MUST be a configurable setting (value pending
  OQ-001), not hard-coded. <!-- docs-analysis:OQ-001 -->

## Open Questions

| ID | Question | Status | Blocking | Origin | Resolution |
|----|----------|--------|----------|--------|------------|
| OQ-001 | Points expiry window (12 vs 24 months)? | open | false | docs-analysis:OQ-001 | — |
| OQ-002 | Cancellation cut-off before an Experience? | open | false | docs-analysis:OQ-002 | — |
| OQ-003 | Payment provider and refund window for paid items? | open | false | docs-analysis:OQ-003 | — |

## Override Log

| Step | Overridden question ids | Timestamp | Note |
|------|-------------------------|-----------|------|
| — | — | — | — |

## Assumptions

- Task 001 decisions D-1…D-4 hold; consent basis covers booking history.
- Waitlist (FR-007) and paid-Experience payment are phaseable after the core loop.
