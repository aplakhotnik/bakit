---
id: ""
type: discovery-document
title: ""
status: draft
created: ""
updated: ""
---

# Living Discovery Document: {{TITLE}}

<!--
  The CANONICAL, continuously-updated record of the whole Discovery workflow (stateful memory).
  Created in State 1 (ba.discover.initiate) and updated at the end of EVERY state. This is the
  single source of truth for vision, goals, constraints, gaps, requirements, and estimates, and
  the basis for resuming an interrupted session. Never invent answers: deferred or declined
  questions live under "## Open Questions", never as fact. When an already-approved upstream
  deliverable is edited after a downstream state advanced, add a staleness flag under
  "## Session State".
-->

## Session State

<!--
  The machine/human readable state of the Discovery session. Update on every transition.
  - current_state: 1 | 2 | 3 | 4 | complete
  - gate status per state: pending | approved
  - estimation_method: set in State 4 (Fibonacci | T-Shirt | PERT)
  - staleness flags: note any downstream state made potentially stale by an upstream edit
-->

- **Current state**: 1 (Initiation & Elicitation)
- **Gates**:
  - State 1 — Project Charter: pending
  - State 2 — Gap Analysis: pending
  - State 3 — Product Backlog: pending
  - State 4 — Estimated Backlog & Roadmap: pending
- **Estimation method**: <not chosen yet>
- **Staleness flags**: none

## Vision & Goals

<!-- Distilled from State 1 (Project Charter). -->

- <vision and business goals as they are agreed>

## Constraints

<!-- Distilled from State 1. -->

- <known constraints>

## Stakeholders

<!-- Distilled from State 1. -->

- <key stakeholders and their interest>

## Gaps

<!-- Distilled from State 2 (Gap Analysis). "No gaps found" is recorded explicitly when true. -->

- <identified gaps>

## Requirements & Scope

<!-- Distilled from State 3 (Product Backlog): epics, stories, scope decisions. -->

- <agreed scope / backlog summary>

## Estimates & Plan

<!-- Distilled from State 4: chosen method, sizes, release roadmap summary. -->

- <estimates and release plan summary>

## Open Questions

<!-- Unresolved clarifications across all states. Never fabricate answers. -->

| # | Question | Raised in state | Status |
|---|----------|-----------------|--------|
| Q1 | <ambiguity / gap / conflict> | 1 | open |

## Change Log

<!-- Append-only. One entry per state/update for traceability and resume. -->

### {{DATE}} — State 1 initialized

- **State**: 1 (Initiation & Elicitation)
- **Change**: Living Discovery Document created; elicitation started.
