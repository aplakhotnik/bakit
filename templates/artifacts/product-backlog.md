---
id: ""
type: product-backlog
title: ""
status: draft
created: ""
updated: ""
derived_from: []
---

# Product Backlog: {{TITLE}}

<!--
  State 3 (ba.discover.backlog) deliverable. Requires an APPROVED Gap Analysis Matrix (the
  State 2 → State 3 phase gate). Populate `derived_from` with the gap-analysis id. EVERY backlog
  item MUST be traceable to a gap or elicited need recorded in the Living Discovery Document (see
  the Traceability section). Gherkin acceptance criteria are available on request but not
  mandatory. Present as an editable draft; the analyst sets `status: approved` to pass the
  State 3 → State 4 gate.
-->

## Epics

<!-- "Source Gap" cites the gap (from gap-analysis.md) the epic addresses. -->

| Epic ID | Title | Description | Source Gap |
|---------|-------|-------------|------------|
| E1 | <title> | <description> | <gap ref> |

## User Stories

<!-- "Source" cites the gap/need each story derives from. -->

| Story ID | Epic | As a / I want / So that | Acceptance Criteria | Source |
|----------|------|-------------------------|---------------------|--------|
| S1 | E1 | As a <role>, I want <capability>, so that <benefit> | see below | <gap/need ref> |

## Acceptance Criteria

<!-- Plain bullet criteria, OR Gherkin (Given/When/Then) when requested. Optional per story. -->

### S1

- <criterion>

<!-- Gherkin example (optional):
```gherkin
Scenario: <name>
  Given <context>
  When <action>
  Then <outcome>
```
-->

## Traceability

<!-- Every epic/story maps back to a gap or elicited need in the Living Discovery Document. -->

| Backlog Item | Traces to (gap / need) |
|--------------|------------------------|
| E1 | <gap/need> |
| S1 | <gap/need> |
