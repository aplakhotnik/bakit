---
id: ""
type: requirements
title: ""
status: draft
created: ""
updated: ""
sources: []
assumptions: []
open_questions: 0
blocking_questions: 0
---

# Requirements: {{TITLE}}

## Overview

<!-- Context, scope, and goal of this requirements set. -->

## Functional Requirements

<!--
  Numbered, testable, prioritized. Use MoSCoW or P1/P2/P3 priority.
  Cite the origin of each derived requirement: a knowledge-base entry
  (`<!-- source: kb/<entry> -->`) or a raw input (`<!-- source: inputs/<file> -->`).
-->

- **FR-001** (P1): The system MUST … <!-- source: kb/<entry> | inputs/<file> -->
- **FR-002** (P2): Users MUST be able to …

## Non-Functional Requirements

- **NFR-001**: …

## Open Questions

<!--
  Targeted clarification questions for ambiguous/incomplete input, in a structured, parseable table.
  Keep the front-matter rollup in sync: `open_questions` = rows with Status `open`;
  `blocking_questions` = `open` rows with Blocking `true`.
  - ID — stable, unique within this artifact (e.g. OQ-001).
  - Status — open | resolved | deferred (blank ⇒ open).
  - Blocking — true | false (blank ⇒ false).
  - Origin — source ref, or a trace ref to a carried-forward item (e.g. `docs-analysis:OQ-002`).
  - Resolution — REQUIRED (non "—") when Status is resolved/deferred: the answer/decision + rationale
    (for deferred, the defer reason). Leave "—" while open.
-->

| ID | Question | Status | Blocking | Origin | Resolution |
|----|----------|--------|----------|--------|------------|
| OQ-001 | … | open | false | inputs/<file> § <section> | — |

## Override Log

<!--
  Append-only audit trail (007). Records when the analyst consciously proceeded past an advisory
  blocking-gap warning AND no elicitation-plan.md exists to hold the override (e.g. quick mode).
  When an elicitation plan exists, the override is recorded in its Round Log instead.
  One row per override: the step proceeded into, the blocking question id(s) overridden, and when.
-->

| Step | Overridden question ids | Timestamp | Note |
|------|-------------------------|-----------|------|
| — | — | — | — |

## Assumptions

<!-- Mirror the `assumptions` front-matter list; never present these as fact. -->

- …
