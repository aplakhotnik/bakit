---
id: membership-booking-decisions
type: kb-entry
level: project
title: "Decision Log — Athlete Membership & Booking"
created: 2026-07-15
updated: 2026-08-02
---

# Decision Log

> Cross-task decisions, once settled, are promoted here so **later tasks inherit
> them automatically** and don't re-open closed questions. Each entry names the
> task that settled it and the source. This is the project's institutional memory.

| ID | Decision | Settled by | Status | Source |
|----|----------|-----------|--------|--------|
| **D-1** | Agreed term for a bookable activity is **Experience** (not session/class/event). | task 001 | Settled | `glossary.md`; docs-analysis DA-001 RQ-003 |
| **D-2** | **Free** members **can book** Experiences — booking is the core Free-tier hook; tiers differ on window/rewards, not eligibility. | task 001 | Settled | revised-direction 2026-07-30; requirements REQ-001 FR-003 |
| **D-3** | The 2025 physical **loyalty card** programme is **discontinued** and out of scope. | task 001 | Settled | legacy-prd (marked superseded); glossary note |
| **D-4** | Consent is an **explicit, off-by-default opt-in** gating any data storage/marketing. The *gate* is fixed; the **legal basis is still open** (OQ-A, with Legal). | task 001 | Gate settled; basis open | elicitation-plan EP-001; requirements REQ-001 FR-005 |
| **D-5** | Booking an Experience **requires login** (trusted identity needed for capacity + check-in). Guest booking rejected. | task 001 | Settled | elicitation-plan EP-001 RQ-102; requirements FR-004 |
| **D-6** | Accessibility target is **WCAG 2.1 AA**. | task 001 | Settled | elicitation-plan EP-001 RQ-104; requirements NFR-002 |

## Still open (carried, not yet decided)

| ID | Open question | Owner | Blocking? | Where tracked |
|----|---------------|-------|-----------|---------------|
| OQ-A | **Legal basis** for storing member data (incl. booking history) & marketing. Gates final consent copy. | Legal | **yes** | task 001 (REQ-001 OQ-001) |
| OQ-B | Reward-point **expiry window** (legacy 12 mo vs an unconfirmed 24). | Product Manager | no | deferred → booking & rewards |
| OQ-C | **Payment provider** and refund/cancellation window for paid items. | Product Manager | no | future booking & rewards |
