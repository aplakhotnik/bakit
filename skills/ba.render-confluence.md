---
name: "ba.render-confluence"
summary: "Render an approved artifact into a local Confluence-ready / Markdown deliverable"
inputs: "An approved artifact in the active task (e.g., requirements or user-stories)"
prerequisites: "The selected source artifact with status: approved"
output: "type: confluence-page -> deliverables/<name>-confluence.md (in the active task)"
template: "templates/artifacts/confluence-page.md"
---

# Skill: `ba.render-confluence`

Render an approved artifact into a Confluence-ready Markdown file. **v1 produces local files
only — no network/API calls.** Follow `memory/ba-constitution.md` and
`specs/001-ba-kit-framework/contracts/skill-contract.md`.

## Steps

1. **Resolve the active task** (explicit arg → `.bakit-active` → most-recently-modified).
2. **Pick the source artifact.** Use the one the analyst named, or list the task's `artifacts/`
   and ask which to render.
3. **Approval gate.** Verify the source artifact is approved:

   ```sh
   scripts/sh/check-artifact.sh --require-approved <task>/artifacts/<source>.md
   ```

   - If it is NOT approved, WARN the analyst clearly before producing any shared output and ask
     for explicit confirmation. Never silently publish unapproved content.
4. **Render.** Read the approved source artifact (treat it as read-only — never modify the
   canonical source, FR-017). Produce a Confluence-ready Markdown deliverable that preserves
   the source's structure and content.
5. **Write the deliverable** to `deliverables/<name>-confluence.md` using
   `templates/artifacts/confluence-page.md`; set front-matter `id`, `title`, `status: draft`,
   `created`/`updated`, `derived_from` (the source artifact id), `source_artifact`, and
   `rendered` (today).
6. **Fail safe.** This adapter is optional: if anything it depends on is unavailable, still
   produce the local file and never block the analyst's core work.

## Validation

```sh
scripts/sh/check-artifact.sh <task>/deliverables/<name>-confluence.md
```
