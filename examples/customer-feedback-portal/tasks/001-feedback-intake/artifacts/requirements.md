---
id: REQ-001
type: requirements
title: "Feedback intake — requirements"
status: approved
created: 2026-06-12
updated: 2026-06-12
sources: [inputs/stakeholder-brief.md]
assumptions: ["Feedback volume is low-to-moderate until measured (see OQ-003)."]
open_questions: 2
blocking_questions: 0
---

# Requirements: Feedback intake

## Overview

Scope for the first release of the Customer Feedback Portal: capturing a feedback
item, categorising it, routing it to the responsible product owner, and letting
that owner triage their queue. Reporting is explicitly deferred. Every requirement
below traces to the stakeholder brief or the prior analysis.

## Functional Requirements

- **FR-001** (P1): The system MUST let a support agent create a feedback item in
  no more than three interactions. <!-- source: inputs/stakeholder-brief.md § "a few clicks" -->
- **FR-002** (P1): Each feedback item MUST be assigned exactly one category from a
  defined set (bug, feature idea, complaint). <!-- source: docs-analysis:ER-002 -->
- **FR-003** (P1): On categorisation, the system MUST route the item to the product
  owner mapped to that category. <!-- source: docs-analysis:ER-003 -->
- **FR-004** (P2): A product owner MUST be able to view all items for their area in
  a single list and mark each as actioned. <!-- source: docs-analysis:ER-004 -->
- **FR-005** (P3): Feedback MAY be submitted anonymously; capturing customer identity
  is optional and off by default. <!-- source: OQ-001 resolution -->

## Non-Functional Requirements

- **NFR-001**: Feedback capture (FR-001) SHOULD complete in under 2 seconds at the
  expected low-to-moderate volume.

## Open Questions

| ID | Question | Status | Blocking | Origin | Resolution |
|----|----------|--------|----------|--------|------------|
| OQ-001 | Must feedback capture identity, or can it be anonymous? | resolved | false | docs-analysis:OQ-001 | Legal confirmed anonymous feedback is permitted; identity capture made optional and off by default (see FR-005). |
| OQ-002 | Is the category → product-owner mapping fixed or assigned by a person? | open | false | docs-analysis:OQ-002 | — |
| OQ-003 | What is the expected volume of feedback per day? | open | false | docs-analysis:OQ-003 | — |

## Override Log

| Step | Overridden question ids | Timestamp | Note |
|------|-------------------------|-----------|------|
| — | — | — | — |

## Assumptions

- Feedback volume is low-to-moderate until measured (OQ-003); NFR-001 is stated
  against that assumption and should be revisited once volume is known.
