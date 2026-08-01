---
id: DA-002
type: docs-analysis
title: "Booking & rewards — documentation analysis"
status: approved
created: 2026-08-01
updated: 2026-08-01
sources:
  - "inputs/01_booking-ops-notes_2026-07-29.md"
  - "inputs/02_rewards-rules-draft_2026-07-31.md"
kb_inherited: ["../../kb/decisions.md (D-1..D-4)", "../../kb/glossary.md", "tasks/001-membership-onboarding/artifacts/docs-analysis.md"]
assumptions:
  - "Inherits task 001 decisions D-1..D-4; does not re-open them."
open_questions: 3
blocking_questions: 0
---

# Documentation Analysis: Booking & rewards

Scope: booking an Experience (capacity, waitlist, check-in) and reward points
(earn, redeem, expiry). Two inputs. Vocabulary and cross-cutting decisions are
**inherited from the project KB** rather than re-derived.

## Inherited from the KB (not re-analysed)

Because these are already settled in `../../kb/decisions.md`, this analysis takes
them as given and does **not** raise them as questions:

- **D-1** — the bookable activity is an **Experience** (naming closed).
- **D-2** — **Free members can book**; earning rate differs by tier, not eligibility.
- **D-3** — no physical card; points are app-based.
- **D-4** — consent is explicit/off-by-default; **booking history is member data**
  under the same basis, so no new consent question is opened here.

> This is the KB force: task 001's reconciliation means task 002 starts from settled
> ground and only analyses what is genuinely new.

## Extracted Requirements

- **ER-001**: A member can **book** an Experience; on booking, the Experience's
  available capacity decreases by one. <!-- source: 01_booking-ops-notes -->
- **ER-002**: When capacity reaches zero the Experience is **full** and cannot be
  overbooked. <!-- source: 01_booking-ops-notes; inherited FR-006 -->
- **ER-003**: A **waitlist** is desired: on a cancellation, the next waitlisted
  member is offered the freed spot. (Design-for; not launch-critical.) <!-- source: 01_booking-ops-notes -->
- **ER-004**: Staff can **check in** attendees on the day against the booking list;
  check-in requires a booking tied to an identity. <!-- source: 01_booking-ops-notes -->
- **ER-005**: A member earns **points for attendance** (confirmed via check-in);
  **no-shows earn nothing**. <!-- source: 02_rewards-rules-draft -->
- **ER-006**: Points can be **redeemed against perks** (catalogue TBD). <!-- source: 02_rewards-rules-draft -->
- **ER-007**: Earning **rate varies by tier** (Plus/Premium earn more; Free earns
  base rate). <!-- source: 02_rewards-rules-draft; inherited D-2 -->

## Gaps & Inconsistencies

- **Points expiry unresolved (inherited open item OQ-A).** Legacy 12 months vs an
  unconfirmed 24; the PM asks to treat expiry as an open decision. Carried, not guessed.
- **Cancellation cut-off undefined.** Ops suggests "a few hours before" but no cut-off
  is set — see OQ-002.
- **Payment provider & refund window undecided.** Premium and some Experiences are
  paid; no provider chosen and no refund policy — see OQ-003.
- **Booking identity (guest vs login) still open (inherited OQ-B).** Ops strongly
  argues login is required for reliable check-in; carried from task 001.

## Open Questions

| ID | Question | Status | Blocking | Origin | Resolution |
|----|----------|--------|----------|--------|------------|
| OQ-001 | Points **expiry window** — 12 vs 24 months (unconfirmed)? | open | false | inherited KB OQ-A; 02_rewards-rules-draft | — |
| OQ-002 | **Cancellation cut-off** before an Experience? | open | false | 01_booking-ops-notes | — |
| OQ-003 | **Payment provider** and **refund/cancellation window** for paid items? | open | false | 02_rewards-rules-draft | — |

## Assumptions

- Task 001 decisions D-1…D-4 hold; not re-opened.
- Waitlist and paid-Experience payment can be phased after the launch booking loop.

## Next steps

- Proceed to `ba.specify`; carry OQ-001…OQ-003. None are blocking for the core
  booking-and-earn loop.
