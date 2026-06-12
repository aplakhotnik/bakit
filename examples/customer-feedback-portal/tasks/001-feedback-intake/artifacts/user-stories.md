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

> **Overview** — These stories deliver the first release of the feedback portal:
> agents capture and categorise feedback, and product owners triage what reaches
> their queue. Derived from the approved requirements in `REQ-001`.

| Source requirements | Author | Last updated |
|---------------------|--------|--------------|
| REQ-001 (FR-001…FR-005) | example analyst | 2026-06-12 |

## US-001 — Capture a feedback item quickly

> As a `support agent`, I want `to record a piece of customer feedback in a few
> clicks` so that `it is captured before I move to the next customer`.

**Acceptance Criteria**

1. **Given** I am on the capture screen, **When** I enter the feedback text and
   submit, **Then** the item is saved in no more than three interactions (FR-001).
2. **Given** I submit without choosing to add customer identity, **When** the item
   is saved, **Then** it is stored anonymously (FR-005).

**Open questions**

- none

---

## US-002 — Categorise and route feedback

> As a `support agent`, I want `to tag each feedback item with a category` so that
> `it reaches the product owner responsible for that area`.

**Acceptance Criteria**

1. **Given** I am saving a feedback item, **When** I select a category, **Then** I
   must choose exactly one from the defined set (FR-002).
2. **Given** a category is selected, **When** the item is saved, **Then** it is
   routed to the product owner mapped to that category (FR-003).

**Open questions**

- How is the category → product-owner mapping maintained? (carried forward as
  REQ-001:OQ-002)

---

## US-003 — Triage my queue

> As a `product owner`, I want `to see all feedback for my area in one list and
> mark items actioned` so that `nothing falls through the cracks`.

**Acceptance Criteria**

1. **Given** feedback exists for my area, **When** I open my queue, **Then** I see
   every item for the categories I own in a single list (FR-004).
2. **Given** I have handled an item, **When** I mark it actioned, **Then** its
   status updates and it is distinguishable from unactioned items (FR-004).

**Open questions**

- none

## Assumptions

- none
