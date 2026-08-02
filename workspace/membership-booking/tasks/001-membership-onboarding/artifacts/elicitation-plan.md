---
id: EP-001
type: elicitation-plan
title: "Membership onboarding — elicitation plan"
status: approved
created: 2026-08-02
updated: 2026-08-02
round: 2
assumptions:
  - "Latest steering (06, 2026-07-30) governs where inputs conflict."
open_questions: 1
blocking_questions: 1
---

# Elicitation Plan: Membership onboarding

Living "deep research" plan maintained by `ba.specify` across clarification rounds. It
seeded its open questions from `artifacts/docs-analysis.md` (Open Questions + Gaps),
grounded in the project knowledge base, then ran two clarification rounds with the
analyst. This artifact is the audit trail of *how* the specification converged — and it
is where the difficulty of this task is visible.

## Current Shared Understanding

- A person joins as a **Free member** (email + verify) and is placed on a tier (Free by
  default). Tiers are Free / Plus / Premium; Premium is paid.
- **Free members can book Experiences** — settled by the 2026-07-30 steering note; tier
  affects booking window / rewards, not eligibility.
- Booking requires the member to be **logged in** (decided this round — Ops/Design need
  a trusted identity for capacity and check-in; guest booking rejected).
- Onboarding must gate on **explicit, off-by-default consent**; the **legal basis is
  still unconfirmed** and remains blocking (Legal engaged, response pending).
- Accessibility target confirmed as **WCAG 2.1 AA**.
- Points concept reused; **expiry window deferred** to the booking & rewards task.
- Physical loyalty card is out of scope (discontinued).

## Open Questions

| ID | Question | Options (with implication) | Status | Blocking | Origin | Priority |
|----|----------|----------------------------|--------|----------|--------|----------|
| OQ-001 | Legal basis for storing member data (incl. booking history) and contacting members? | a) Consent-only — simplest, but limits later data use; b) Consent + legitimate-interest for service comms — more usable, needs Legal sign-off; c) Await Legal ruling — blocks final consent copy | open | true | docs-analysis:OQ-001 | High |

## Resolved

| ID | Question | Resolution (decision + rationale) | Round |
|----|----------|-----------------------------------|-------|
| RQ-101 | Can Free members book, or is it Plus-only? | **Free members can book.** Latest steering (06) overrides the workshop's Plus-only position. | 1 |
| RQ-102 | Guest booking (name + email) or login-required? | **Login-required.** Capacity management and on-the-day check-in need a trusted identity; guest booking can't be trusted for capacity. | 1 |
| RQ-103 | Agreed term for the bookable activity? | **Experience** (project glossary) — reconciles session/class/event. | 1 |
| RQ-104 | Target accessibility level? | **WCAG 2.1 AA** confirmed with the analyst. | 2 |
| RQ-105 | Points expiry window (12 vs 24 months)? | **Deferred** to the booking & rewards task; make it a configurable setting, don't hard-code. | 2 |
| RQ-106 | Default tier at onboarding? | **Free** by default. | 2 |

## Next Steps

1. Draft `requirements.md` from the settled understanding above.
2. Record OQ-001 as a **blocking** open question in the requirements; analyst chose to
   proceed to draft while Legal is pending (override logged below).
3. Present the decomposition-readiness summary flagging the single blocking item.

## Round Log

### Round 1 — 2026-08-02 (scope)

- **Asked**: (1) Free vs Plus-only booking? (2) Guest vs login-required booking?
  (3) Is the legal/consent basis known?
- **Answered**: (1) Free can book — per latest steering. (2) Login-required — for
  capacity/check-in trust. (3) No — Legal not yet confirmed; treat as blocking.
- **Overrides**: none.

### Round 2 — 2026-08-02 (detail)

- **Asked**: (1) Confirm WCAG target? (2) Points expiry now or defer? (3) Default tier?
- **Answered**: (1) WCAG 2.1 AA. (2) Defer expiry to booking & rewards; keep it a
  setting. (3) Free by default.
- **Overrides**: analyst elected to **proceed to drafting with OQ-001 (consent) still
  open/blocking** while Legal responds — recorded so it is not lost. 2026-08-02.

## Convergence

- **Status**: aligned except for one blocking item (OQ-001, consent legal basis).
- **Criteria for "aligned"**: scope (who can book, identity model, tiers), vocabulary,
  and accessibility settled; remaining blocker (consent basis) explicitly acknowledged
  and carried into the requirements rather than guessed.
