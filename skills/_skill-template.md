---
name: "ba.<verb>-<noun>"
summary: "<one-line description of the activity>"
inputs: "<required inputs: source files and/or upstream artifacts>"
prerequisites: "<upstream artifact(s) that must be status: approved, or 'none'>"
output: "type: <artifact-type> -> <relative output path in the active task>"
template: "templates/artifacts/<template>.md"
---

# Skill: `ba.<verb>-<noun>`

> Agent-agnostic BA-Kit skill. Copy this template to create a new skill. Keep behavior aligned
> with the principles and Skill Behavioral Contract in `memory/ba-constitution.md`.

## When invoked, you MUST

1. **Resolve the active task** — determine the target project/task (an explicit argument, the
   `.bakit-active` pointer, or the most-recently-modified task). Write output into that task's
   `artifacts/` (or `deliverables/` for rendered output).
2. **Check prerequisites** — for each prerequisite artifact, run
   `scripts/sh/check-artifact.sh --require-approved <path>`. If any is missing or not
   `approved`, STOP and explain exactly what the analyst must approve first. Do NOT proceed on
   unapproved input.
3. **Gather & read inputs** — read declared inputs. If an input is empty/unreadable, report it
   rather than inventing content.
4. **Clarify, don't assume** — when inputs are ambiguous or incomplete, ask targeted
   clarification questions before producing the artifact.
5. **Produce a DRAFT artifact** — populate the declared template, set `status: draft`, fill
   `created`/`updated`, and populate traceability fields (`sources` / `derived_from`) plus any
   `assumptions`. Cite sources inline where applicable.
6. **Present for review** — show the draft as an editable proposal. Do NOT set `approved`
   yourself. Never overwrite an existing `approved` artifact without explicit confirmation.

## Output

A single Markdown artifact conforming to its template and the front-matter convention
(`templates/artifacts/_frontmatter.md`).
