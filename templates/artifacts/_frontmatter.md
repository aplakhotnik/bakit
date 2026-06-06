# Artifact front-matter convention

Every BA-Kit artifact and deliverable begins with this YAML front-matter block. It is the
machine-readable contract that `scripts/sh/check-artifact.sh` validates and that downstream
skills read to enforce the review gate. Keep this in sync with the contract at
`specs/001-ba-kit-framework/contracts/artifact-frontmatter.md`.

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
---
```

## Rules

- `status` is `draft` on creation. Only the analyst changes it to `approved`. No skill
  self-approves.
- `updated` MUST advance whenever the artifact is edited (supports FR-021 reviewability).
- Traceability fields are conditionally required by `type`:
  - `docs-analysis` → `sources` (cited input documents/sections)
  - `user-stories`, `confluence-page` → `derived_from` (upstream artifact ids)
- Validate at any time with:

  ```sh
  scripts/sh/check-artifact.sh <artifact.md>
  scripts/sh/check-artifact.sh --require-approved <artifact.md>
  ```
