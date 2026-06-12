---
name: "ba.render-confluence"
summary: "Render an approved artifact into a local Confluence-ready / Markdown deliverable"
inputs: "An approved artifact in the active task (e.g., requirements or user-stories), plus house style from kb/"
prerequisites: "The selected source artifact with status: approved"
output: "type: confluence-page -> deliverables/<name>-confluence.md (in the active task)"
template: "templates/artifacts/confluence-page.md"
---

# Skill: `ba.render-confluence`

Render an approved artifact into a Confluence-ready Markdown file. **v1 produces local files
only — no network/API calls.** Follow `memory/ba-constitution.md`.

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
4. **Ground in the knowledge base.** Consult the **project-level** `kb/index.md` then the task's
   `kb/index.md` (task precedence) for house style, naming conventions, audience, and any
   page-metadata defaults (owner, stakeholders). Read the index first and recurse only if the
   source artifact is large; a missing or empty `kb/` is NOT an error — continue.
5. **Render.** Read the approved source artifact (treat it as read-only — never modify the
   canonical source, FR-017). Populate every section of `templates/artifacts/confluence-page.md`
   — page metadata table, executive summary, scope, the rendered body (preserving the source's
   structure and content), stakeholders, references, and change log — using the KB conventions
   from step 4.
6. **Write the deliverable** to `deliverables/<name>-confluence.md`; set front-matter `id`,
   `title`, `status: draft`, `created`/`updated`, `derived_from` (the source artifact id),
   `source_artifact`, and `rendered` (today).
7. **Fail safe.** This adapter is optional: if anything it depends on is unavailable, still
   produce the local file and never block the analyst's core work.

## Validation

```sh
scripts/sh/check-artifact.sh <task>/deliverables/<name>-confluence.md
```

## Next steps

This is the terminal step of the default `workflow.md` chain:

```text
## Next steps
- ▶ ba.next — ask for the recommended next action across the task
- ✎ Review the deliverable; v1 produces a local file only (no publishing)
```
