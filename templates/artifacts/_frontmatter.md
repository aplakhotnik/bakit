# Artifact front-matter convention

Every BA-Kit artifact and deliverable begins with this YAML front-matter block. It is the
machine-readable contract that `scripts/sh/check-artifact.sh` validates and that downstream
skills read to enforce the review gate. This file is the source of truth for the convention.

```yaml
---
id: ""                 # stable id within the task, e.g. "REQ-001" (required)
type: ""               # requirements | docs-analysis | user-stories | confluence-page | project (required)
title: ""              # human-readable title (required)
status: draft          # draft | approved  (created as draft; only an analyst sets approved)
created: ""            # YYYY-MM-DD (required)
updated: ""            # YYYY-MM-DD; advances on every edit (required)
sources: []            # required & non-empty for type: docs-analysis
derived_from: []       # required & non-empty for type: user-stories and confluence-page
assumptions: []        # explicitly flagged assumptions (present when assumptions were made)
open_questions: 0      # (007) optional rollup: count of status:open questions; absent ⇒ 0
blocking_questions: 0  # (007) optional rollup: count of open questions with blocking:true; absent ⇒ 0
---
```

## Rules

- `status` is `draft` on creation. Only the analyst changes it to `approved`. No skill
  self-approves.
- `updated` MUST advance whenever the artifact is edited (supports FR-021 reviewability).
- Traceability fields are conditionally required by `type`:
  - `docs-analysis` → `sources` (cited input documents/sections)
  - `user-stories`, `confluence-page` → `derived_from` (upstream artifact ids)

## Open-question rollup (007 additive extension)

`open_questions` and `blocking_questions` are an **additive extension introduced by feature 007**
(gap-aware workflow). They layer on top of the base required fields above (which remain the source
of truth) for the default-chain artifact types only.

- They apply to `docs-analysis`, `requirements`, and `elicitation-plan` artifacts. Other types
  (including all Discovery artifacts) ignore them.
- Both are OPTIONAL integers. **Absent ⇒ `0`** (backward compatible; never an error).
- `open_questions` counts questions with `status: open` only (resolved/deferred excluded).
- `blocking_questions` counts `open` questions whose `blocking` is `true`; `blocking_questions ≤ open_questions`.
- The rollup is the machine-readable summary `scripts/sh/check-artifact.sh` (and the PowerShell
  mirror) reports, and that `scripts/sh/next-step.sh` reads for its advisory blocking-gap warning.
  Detailed questions live in the artifact body under `## Open Questions` (see those templates).

- Validate at any time with:

  ```sh
  scripts/sh/check-artifact.sh <artifact.md>
  scripts/sh/check-artifact.sh --require-approved <artifact.md>
  scripts/sh/check-artifact.sh --require-no-blocking <artifact.md>   # (007) exit 3 if blocking remain
  ```
