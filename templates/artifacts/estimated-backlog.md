---
id: ""
type: estimated-backlog
title: ""
status: draft
created: ""
updated: ""
derived_from: []
---

# Estimated Backlog & Release Roadmap: {{TITLE}}

<!--
  State 4 (ba.discover.estimate) deliverable. Requires an APPROVED Product Backlog (the
  State 3 → State 4 phase gate). Populate `derived_from` with the product-backlog id. Present at
  least Fibonacci, T-Shirt, and PERT and record the CHOSEN method below. Every item is either
  sized in the chosen scale OR explicitly marked `UNESTIMABLE` with the missing detail as a
  question — never guessed. Do not mix scales; switching methods re-estimates affected items.
  Present as an editable draft; the analyst sets `status: approved`.
-->

## Estimation Method

<!-- The method chosen by the analyst and the scale legend. -->

- **Chosen method**: <Fibonacci | T-Shirt | PERT>
- **Scale legend**: <e.g., Fibonacci 1,2,3,5,8,13,21 | XS,S,M,L,XL | PERT (O,M,P) → expected>

## Estimated Backlog

<!-- One row per backlog item. Use the `UNESTIMABLE` marker + reason where an item cannot be
     sized; capture the blocking question under Open Questions. -->

| Story ID | Title | Estimate | Confidence / Notes |
|----------|-------|----------|--------------------|
| S1 | <title> | <size or `UNESTIMABLE`> | <confidence / reason> |

## Release Roadmap

<!-- A phased delivery outline grouping items into releases/milestones. -->

| Release / Milestone | Included Items | Rationale |
|---------------------|----------------|-----------|
| R1 | <story ids> | <why this grouping / sequencing> |

## Open Questions

<!-- Items blocking estimation (each `UNESTIMABLE` item should have a question here). -->

| # | Question | Blocks |
|---|----------|--------|
| Q1 | <missing detail> | <story id> |
