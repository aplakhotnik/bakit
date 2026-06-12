---
id: US-001
type: user-stories
title: "Feedback intake — user stories"
status: approved
created: 2026-06-12
updated: 2026-06-12
derived_from: [REQ-001]
assumptions: []
---

# User Stories: Feedback intake

## Overview

> **Overview** — This set delivers the first release of the Customer Feedback Portal.
> Support agents capture and categorise customer feedback in seconds, the system routes
> each item to the product owner who owns that category, and product owners triage their
> queue so nothing is lost. Every story is traced to an approved requirement in `REQ-001`
> and written to be INVEST-compliant (Independent, Negotiable, Valuable, Estimable, Small,
> Testable).

| Source requirements | Author | Last updated | Status |
|---------------------|--------|--------------|--------|
| REQ-001 (FR-001…FR-005, NFR-001) | example analyst | 2026-06-12 | Approved |

### Personas

| Persona | Goal | Pain today |
|---------|------|------------|
| **Sam — Support Agent** | Log feedback fast and get back to the customer | Feedback is scattered across email/chat; logging it is slow, so it often isn't logged |
| **Priya — Product Owner** | See all feedback for her area and act on it | No single queue; relevant feedback never reaches her |
| **Dana — Support Lead** | Trust that nothing falls through the cracks | No visibility into what was captured or actioned |

### Story map (at a glance)

| ID | Title | Persona | Requirements | Priority |
|----|-------|---------|--------------|----------|
| US-001 | Capture a feedback item quickly | Sam | FR-001, NFR-001 | P1 |
| US-002 | Submit feedback anonymously | Sam | FR-005 | P3 |
| US-003 | Categorise a feedback item | Sam | FR-002 | P1 |
| US-004 | Route feedback to the right owner | (system) | FR-003 | P1 |
| US-005 | Triage my feedback queue | Priya | FR-004 | P2 |
| US-006 | Mark a feedback item actioned | Priya | FR-004 | P2 |

---

## US-001 — Capture a feedback item quickly

> As a **support agent**, I want **to record a piece of customer feedback in just a few
> clicks** so that **it is captured before I move on to the next customer**.

**Context & value** — Speed is the difference between feedback being logged and feedback
being lost. If capture is slow, agents skip it under load — the exact failure the portal
exists to prevent.

**Acceptance Criteria**

1. **Given** I am on the capture screen,
   **When** I enter the feedback text and submit,
   **Then** the item is saved in **no more than three interactions** (click/keystroke
   groups) end to end. *(FR-001)*
2. **Given** I submit a valid feedback item,
   **When** the save completes,
   **Then** the system confirms the save in **under 2 seconds** at expected volume. *(NFR-001)*
3. **Given** I try to submit with an empty feedback body,
   **When** I press submit,
   **Then** the item is **not** saved and I see an inline message telling me the body is
   required.
4. **Given** I have entered text but not yet submitted,
   **When** I navigate away,
   **Then** I am warned that unsaved feedback will be lost.

**Edge cases**

- Very long feedback text is accepted up to a defined limit; beyond it, the field shows a
  character counter and prevents submission.
- Duplicate rapid submissions (double-click) create **one** item, not two.

**Definition of Done**

- Capture screen reachable in one click from the agent's main view.
- All four acceptance criteria covered by automated tests.
- Telemetry records time-to-capture so NFR-001 can be monitored.

**Open questions**

- none

---

## US-002 — Submit feedback anonymously

> As a **support agent**, I want **to log feedback without attaching the customer's
> identity** so that **I stay compliant when the customer hasn't consented to be named**.

**Context & value** — Legal confirmed anonymous feedback is permitted; identity capture is
optional and **off by default** (see `REQ-001` OQ-001 resolution and FR-005).

**Acceptance Criteria**

1. **Given** I am capturing feedback,
   **When** I do not opt in to add customer identity,
   **Then** the item is stored with **no** customer identifier. *(FR-005)*
2. **Given** I choose to add customer identity,
   **When** I save,
   **Then** the identity is stored and visibly associated with the item.
3. **Given** an item was saved anonymously,
   **When** anyone later views it,
   **Then** no customer identity is shown or recoverable.

**Edge cases**

- Switching the identity toggle off after typing a name clears the captured identity before
  save.

**Open questions**

- none

---

## US-003 — Categorise a feedback item

> As a **support agent**, I want **to tag each feedback item with exactly one category** so
> that **it can be routed to the team that owns that area**.

**Acceptance Criteria**

1. **Given** I am saving a feedback item,
   **When** I open the category selector,
   **Then** I see the defined set: **bug**, **feature idea**, **complaint**. *(FR-002)*
2. **Given** the category selector is open,
   **When** I make a selection,
   **Then** I can choose **exactly one** category (single-select, not multi). *(FR-002)*
3. **Given** I attempt to save without selecting a category,
   **When** I press submit,
   **Then** the item is not saved and I am prompted to pick a category.

**Edge cases**

- If the category set changes later, items already saved keep their original category.

**Open questions**

- none

---

## US-004 — Route feedback to the right owner

> As **the system**, I want **to route each categorised item to the product owner mapped to
> its category** so that **the right person sees it without manual triage**.

**Acceptance Criteria**

1. **Given** a feedback item has a category,
   **When** it is saved,
   **Then** it is routed to the product owner mapped to that category. *(FR-003)*
2. **Given** a category has no owner mapped,
   **When** an item in that category is saved,
   **Then** the item is routed to a **fallback triage queue** and is not lost.
3. **Given** the category→owner mapping changes,
   **When** a new item is saved,
   **Then** routing uses the **current** mapping at save time.

**Edge cases**

- Re-categorising an existing item re-routes it to the new owner and removes it from the
  previous owner's queue.

**Open questions**

- How is the category → product-owner mapping maintained — fixed config or assigned by a
  person? *(carried forward as `REQ-001`:OQ-002)*

---

## US-005 — Triage my feedback queue

> As a **product owner**, I want **to see all feedback for the categories I own in one
> list** so that **I can review it in one place instead of hunting across channels**.

**Acceptance Criteria**

1. **Given** feedback exists for categories I own,
   **When** I open my queue,
   **Then** I see every item for those categories in a single list. *(FR-004)*
2. **Given** my queue has many items,
   **When** I view it,
   **Then** items are ordered most-recent-first and I can filter by category and by
   actioned/unactioned state.
3. **Given** I do not own a category,
   **When** I view my queue,
   **Then** items in that category are **not** shown to me.

**Edge cases**

- An empty queue shows a friendly "no feedback yet" state rather than a blank screen.

**Open questions**

- none

---

## US-006 — Mark a feedback item actioned

> As a **product owner**, I want **to mark a feedback item as actioned** so that **my team
> and I can tell what has been handled and what still needs attention**.

**Acceptance Criteria**

1. **Given** I am viewing an item in my queue,
   **When** I mark it actioned,
   **Then** its status updates and it is visually distinguishable from unactioned items.
   *(FR-004)*
2. **Given** an item is actioned,
   **When** I filter by "unactioned",
   **Then** the actioned item is excluded from the results.
3. **Given** I marked an item actioned by mistake,
   **When** I undo within the same session,
   **Then** the item returns to unactioned.

**Edge cases**

- The actioned state and who set it are recorded so the Support Lead (Dana) can see triage
  activity.

**Open questions**

- none

## Out of scope (this release)

- Reporting and SLA dashboards (e.g. volume, response time) — explicitly deferred in
  `REQ-001`.
- Customer-facing feedback submission — agents capture on the customer's behalf for now.

## Assumptions

- none
