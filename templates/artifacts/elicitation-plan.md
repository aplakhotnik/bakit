---
id: ""
type: elicitation-plan
title: ""
status: draft
created: ""
updated: ""
round: 1
assumptions: []
open_questions: 0
blocking_questions: 0
---

# Elicitation Plan: {{TITLE}}

<!--
  A LIVING "deep research" plan maintained by `ba.specify` across clarification rounds.
  It is a process/audit artifact (how intent converged into the specification), not a
  shippable deliverable. Update it every round: refine the shared understanding, refresh
  the open questions, append a Round Log entry, and restate the next steps. The per-round
  question cap still applies — do not dump every question at once.
-->

## Current Shared Understanding

<!-- The agreed picture of the need so far. Rewrite/refine this each round as answers land. -->

- <what we now understand about the need, scope, actors, and constraints>

## Open Questions

<!--
  Prioritized (scope before detail), bounded per round. Each question offers options and the
  implication of each, so the analyst can choose quickly. Move answered items to "Resolved".
  Keep the front-matter rollup in sync: `open_questions` = rows with Status `open`;
  `blocking_questions` = `open` rows with Blocking `true`.
  - ID — stable, unique within this artifact (e.g. OQ-001).
  - Status — open | resolved | deferred (blank ⇒ open).
  - Blocking — true | false (blank ⇒ false).
  - Origin — where it came from, or a trace ref to a carried-forward item (e.g. `docs-analysis:OQ-002`).
-->

| ID | Question | Options (with implication) | Status | Blocking | Origin | Priority |
|----|----------|----------------------------|--------|----------|--------|----------|
| OQ-001 | <ambiguity / gap / conflict> | a) <option> — <implication>; b) <option> — <implication> | open | false | <source / trace ref> | High |

## Resolved

<!-- Questions answered in earlier rounds, with the decision taken (the resolution note). -->

| ID | Question | Resolution (decision + rationale) | Round |
|----|----------|-----------------------------------|-------|
| — | — | — | — |

## Next Steps

<!-- Structured actions for the upcoming round (what to clarify, draft, or validate next). -->

1. <next action>

## Round Log

<!-- Append-only. One entry per round: questions asked and answers received (traceability). -->

### Round 1 — {{DATE}}

- **Asked**: <questions raised this round>
- **Answered**: <analyst's answers, or "pending">
- **Overrides**: <none, or: proceeded into <step> past blocking OQ-<ids> at <timestamp> — optional note>

## Convergence

<!--
  The explicit signal/criteria for when the analyst considers understanding complete. The loop
  continues until the analyst confirms alignment here (or defers remaining items as assumptions).
-->

- **Status**: in progress
- **Criteria for "aligned"**: <what must be settled before converging on the specification>
