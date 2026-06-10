---
id: ""
type: docs-analysis
title: ""
status: draft
created: ""
updated: ""
sources: []
assumptions: []
open_questions: 0
blocking_questions: 0
---

# Documentation Analysis: {{TITLE}}

## Sources Reviewed

<!-- List every source document analyzed (mirror the `sources` front-matter). -->

- `inputs/<file>` — <short description>

## Extracted Requirements

<!--
  Each extracted requirement MUST cite its origin: a source document and section
  (`<!-- source: inputs/<file> § <section> -->`) or a knowledge-base entry
  (`<!-- source: kb/<entry> -->`).
-->

- **ER-001**: … <!-- source: inputs/<file> § <section> -->
- **ER-002**: … <!-- source: kb/<entry> -->

## Gaps & Inconsistencies

<!-- Missing information, contradictions, or conflicts found across sources. -->

- …

## Open Questions

<!--
  Questions needing stakeholder/analyst clarification, in a structured, parseable table.
  Keep the front-matter rollup in sync: `open_questions` = rows with Status `open`;
  `blocking_questions` = `open` rows with Blocking `true`.
  - ID — stable, unique within this artifact (e.g. OQ-001). Downstream skills carry these forward by trace ref.
  - Status — open | resolved | deferred (blank ⇒ open).
  - Blocking — true | false (blank ⇒ false).
  - Origin — the source document/section the question arises from.
  - Resolution — REQUIRED (non "—") when Status is resolved/deferred (answer/decision + rationale;
    for deferred, the defer reason). Leave "—" while open.
-->

| ID | Question | Status | Blocking | Origin | Resolution |
|----|----------|--------|----------|--------|------------|
| OQ-001 | … | open | false | inputs/<file> § <section> | — |

## Assumptions

<!-- Inferred/unsupported content, flagged explicitly. Never stated as fact. -->

- …
