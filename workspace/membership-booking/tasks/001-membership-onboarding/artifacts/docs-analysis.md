---
id: DA-001
type: docs-analysis
title: "Membership onboarding — documentation analysis"
status: approved
created: 2026-08-02
updated: 2026-08-02
sources: ["inputs/01_stakeholder-brief_2026-07-18.md", "inputs/02_discovery-workshop_2026-07-22.md", "inputs/03_legacy-membership-prd_2025.md", "inputs/04_slack-thread_2026-07-25.md", "inputs/05_designer-personas-journey_2026-07-24.md", "inputs/06_revised-direction_2026-07-30.md"]
assumptions:
  - "Source 06 (2026-07-30) is the latest steering direction and supersedes earlier sources where they conflict."
  - "App-first programme; the 2025 physical loyalty card is discontinued."
open_questions: 4
blocking_questions: 1
---

# Documentation Analysis: Membership onboarding

Reconciles six inputs gathered 2026-07-18 → 2026-07-30. The inputs disagree on several
points; this analysis records what each source said, which source wins, and what is
still open. Vocabulary follows the project glossary (`../../kb/glossary.md`): the
bookable activity is an **Experience** (inputs also call it session / class / event).

## Sources Reviewed

| Source | Date | Role in the picture |
|--------|------|---------------------|
| `01_stakeholder-brief` | 2026-07-18 | VP's original intent; broad, ambitious |
| `02_discovery-workshop` | 2026-07-22 | Cross-team detail; introduced conflicts |
| `03_legacy-membership-prd` | 2025 | Historical; card programme now discontinued |
| `04_slack-thread` | 2026-07-25 | Half-made decisions; surfaced the blocker |
| `05_designer-personas-journey` | 2026-07-24 | Journey, accessibility, identity concern |
| `06_revised-direction` | 2026-07-30 | **Latest** steering; resolves key conflicts |

## Extracted Requirements

- **ER-001**: A person can become a **Free member** by signing up with an email and
  verifying it. <!-- source: inputs/01_stakeholder-brief_2026-07-18.md § "free member just by signing up" -->
- **ER-002**: The programme has three tiers — **Free / Plus / Premium**; Premium is
  paid. <!-- source: inputs/02_discovery-workshop_2026-07-22.md § tiers -->
- **ER-003**: **Free members can book Experiences.** Tiers differentiate on booking
  window, rewards, and early access — not on whether booking is allowed.
  <!-- source: inputs/06_revised-direction_2026-07-30.md § "Free members can book" -->
- **ER-004**: Onboarding must capture **explicit, opt-in, off-by-default consent**
  before storing member data or contacting the member. <!-- source: inputs/06_revised-direction_2026-07-30.md § consent -->
- **ER-005**: A member is placed on a **tier** during onboarding (Free by default).
  <!-- source: inputs/06_revised-direction_2026-07-30.md § tiers -->
- **ER-006**: The **points** concept is reused from the prior programme; the physical
  card and till-scanning are **out of scope**. <!-- source: inputs/03_legacy-membership-prd_2025.md § analyst note -->
- **ER-007**: Every Experience has a **fixed capacity**; onboarding/booking must not
  allow overbooking. <!-- source: inputs/06_revised-direction_2026-07-30.md § "fixed capacity" -->

## Reconciliation (evolving inputs)

The inputs changed over two weeks. Recording what moved so nothing is silently lost:

- **Who can book** — the VP's brief (07-18) said Free members can book; the workshop
  (07-22) argued booking should be Plus-only. **Resolved by 06 (07-30): Free members
  can book.** → RQ-001.
- **Bookable activity naming** — "session" (01), "class"/"session" (02), "event" (03),
  "experience" (05). **Standardised to Experience** per glossary → RQ-003.
- **Loyalty card** — present in the 2025 PRD (03); **discontinued**. Reuse points only
  → RQ-002. Do not carry the card into requirements.
- **Consent** — escalated from "someone should check" (01) to "blocking the design"
  (04) to "nothing ships until Legal confirms" (06). Basis is now a **prerequisite**,
  not an assumption — captured as blocking OQ-001.

## Gaps & Inconsistencies

- **Points expiry conflicts and is unconfirmed.** Legacy PRD (03) says **12 months**;
  the Slack thread (04) says the team "said 24" but explicitly marks it **needs
  confirming**. No source is authoritative — see OQ-004.
- **Guest booking vs login-required conflicts.** The workshop (02) wanted guest booking
  with name + email; Ops (04) and Design (05) push back — capacity and check-in need a
  trusted identity, implying **login-required**. Unresolved — see OQ-002.
- **Accessibility target unstated.** Design (05) assumed **WCAG 2.1 AA** but no one has
  confirmed the level; it affects component choices — see OQ-003.
- **Capacity-full behaviour undefined.** Fixed capacity is required (ER-007) but the
  behaviour when full (waitlist vs "full") is not settled; noted, out of this task's scope.

## Open Questions

| ID | Question | Status | Blocking | Origin | Resolution |
|----|----------|--------|----------|--------|------------|
| OQ-001 | What is the **legal basis** for storing member data (incl. booking history) and contacting members? Onboarding consent design is blocked until confirmed. | open | true | inputs/04_slack-thread_2026-07-25.md § "legal basis"; inputs/06_revised-direction_2026-07-30.md § consent | — |
| OQ-002 | Is booking **guest-allowed** (name + email) or **login-required**? Capacity management and check-in argue for login. | open | false | inputs/02_discovery-workshop_2026-07-22.md vs inputs/04_slack-thread_2026-07-25.md / inputs/05_designer-personas-journey_2026-07-24.md | — |
| OQ-003 | What is the target **WCAG accessibility level** for onboarding & booking (assumed AA)? | open | false | inputs/05_designer-personas-journey_2026-07-24.md § accessibility | — |
| OQ-004 | What is the **points expiry window** (legacy 12 mo vs "24" unconfirmed)? | open | false | inputs/03_legacy-membership-prd_2025.md vs inputs/04_slack-thread_2026-07-25.md | — |

## Resolved / Closed Questions

| ID | Question | Status | Origin | Resolution |
|----|----------|--------|--------|------------|
| RQ-001 | Can Free members book, or is booking Plus-only? | closed | 01 vs 02 | Latest steering (06, 2026-07-30): **Free members can book.** |
| RQ-002 | Is the physical loyalty card in scope? | closed | 03 | No — programme discontinued; reuse points only. |
| RQ-003 | What is the agreed term for the bookable activity? | closed | 01–05 | **Experience** (project glossary). |

## Assumptions

- Source 06 is the current source of truth where inputs conflict.
- App-first; no physical card.
- Booking mechanics (capacity behaviour, waitlist, rewards, payment) are out of scope
  for onboarding; this task takes the member to the point of booking.

## Next steps

- Proceed to `ba.specify` (deep mode) to turn these into testable requirements; OQ-001
  remains blocking for the consent requirement — carry it forward.
