---
name: "ba.discover.initiate"
summary: "State 1 of the Discovery workflow: run a structured interview to turn a plain idea into a Project Charter & Context Brief, and create the Living Discovery Document"
inputs: "The stakeholder's plain-language project idea; the project + task knowledge base; project context; optionally raw material in inputs/"
prerequisites: "none (does NOT require any pre-existing document)"
output: "type: project-charter -> artifacts/project-charter.md AND type: discovery-document -> artifacts/discovery-document.md (the Living Discovery Document)"
template: "templates/artifacts/project-charter.md and templates/artifacts/discovery-document.md"
---

# Skill: `ba.discover.initiate`

**State 1 of the separate Discovery workflow** — the front door. It behaves like a systematic,
consultative BA/PO: starting from a stakeholder's plain-language *idea* (no pre-existing document
required), it runs a **structured interview** and produces a **Project Charter & Context Brief**,
while creating the **Living Discovery Document** that persists across all four Discovery states.

Authored as agent-agnostic plain Markdown with the framework's standard front-matter. Follow
`memory/ba-constitution.md` (see §"Skill Behavioral Contract" and §"Discovery workflow
obligations").

> **Separate workflow.** This is **not** part of the default analyst chain and does not modify it.
> The Discovery workflow is declared in `workflow-discovery.md`; advance it with `ba.discover.next`.
> Its deliverables are standard Markdown artifacts an analyst MAY later hand to existing skills, but
> this workflow never auto-triggers them.

## Steps

1. **Resolve the active task.** Use an explicit project/task if the analyst named one; otherwise
   read `workspace/.bakit-active`, else use the most-recently-modified task. Confirm the resolved
   target. Output goes to that task's `artifacts/project-charter.md` and
   `artifacts/discovery-document.md`.

2. **Living Discovery Document first (resume).** Before anything else, read
   `artifacts/discovery-document.md` if it exists:
   - Restore the **current state**, **gate status**, prior decisions, and any recorded answers from
     `## Session State`, `## Open Questions`, and `## Change Log`.
   - **Do NOT re-ask questions already answered** there (FR-024). Resume from where the session left
     off. If the document is absent, this is a fresh State 1 and you will create it in step 5.

3. **Ground in the knowledge base and project context FIRST.** Read the project-level `kb/index.md`,
   then the task-level `kb/index.md` (task knowledge takes precedence), and the project context
   elicited at initiation. Reuse known facts instead of re-asking. Cite grounded content inline
   (`<!-- source: kb/<entry> -->`). A missing/empty `kb/` is not an error.

4. **Run the structured interview (bounded batches).** Elicit vision, business goals, constraints,
   and key stakeholders by asking a **bounded batch of 3–5 questions per turn** (FR-010) — do not
   emit a finished charter on turn one. Each question should be prioritized (scope before detail).
   - **Zero-assumption rule.** When a material point (e.g., the business goal) is ambiguous or
     missing, **halt and ask** — never invent business content (FR-006). Record deferred/declined
     items under `## Open Questions`, never as fact.
   - Continue rounds until enough context exists for a charter (or the analyst defers the rest).

5. **Create / update the Living Discovery Document.** From
   `templates/artifacts/discovery-document.md`, create `artifacts/discovery-document.md` if absent
   (or update it if resuming). Seed/refresh `## Session State` (current state = 1, State 1 gate =
   pending), and the `## Vision & Goals`, `## Constraints`, `## Stakeholders`, and `## Open
   Questions` sections from the interview. Set front-matter `id`, `title`, `status: draft`,
   `created`/`updated`. **Append a `## Change Log` entry** for this update.

6. **Draft the Project Charter & Context Brief.** Populate
   `templates/artifacts/project-charter.md` into `artifacts/project-charter.md` with all required
   sections: `## Vision`, `## Business Goals`, `## Constraints`, `## Stakeholders`, `## High-Level
   Scope`, `## Out of Scope`, `## Open Questions` (FR-011). Set front-matter `id`, a concise
   `title`, `status: draft`, `created`/`updated`. Cite grounded items inline. Any unknown stays an
   Open Question — never an assumption presented as fact.

7. **Guard existing output (non-destructive).** If an **approved** `project-charter.md` already
   exists, do NOT overwrite it without explicit analyst confirmation (FR-009). If a **draft** exists,
   confirm before replacing. Never silently overwrite analyst-approved content.

8. **Phase-gate awareness & staleness.** The charter is the State 1 deliverable; the gate to State 2
   is the charter reaching `status: approved`. Record the gate as pending in `## Session State` until
   approved. If you detect that a previously-approved charter was edited after a downstream state had
   advanced, add a staleness flag under `## Session State` and note that downstream states need
   re-confirmation (FR-025). (Cross-state staleness across all states is also reported by
   `ba.discover.next`.)

9. **Present for review.** Show both artifacts as editable proposals. Do NOT set `status: approved` —
   that is the analyst's sign-off. Once `project-charter.md` is approved, the State 1 → State 2 gate
   opens.

## Validation

After a run, both artifacts MUST pass:

```sh
scripts/sh/check-artifact.sh <task>/artifacts/project-charter.md     # exit 0
scripts/sh/check-artifact.sh <task>/artifacts/discovery-document.md  # exit 0
```

(Windows: `scripts/ps/check-artifact.ps1`.) The charter must contain every required template
section, and the Living Discovery Document must record the current state and an up-to-date Change
Log entry.

## Next steps

Derive the suggestion from `workflow-discovery.md` (never the default `workflow.md`):

```text
## Next steps
- ✎ Review and set `status: approved` in artifacts/project-charter.md to pass the State 1 gate
- ▶ ba.discover.gap-analysis — State 2: Gap Analysis Matrix (enabled when the charter is approved)
- ↻ ba.discover.next — show Discovery progress and the next runnable state
```

Never auto-run a downstream state or any default-chain skill (FR-021). Present the option and let
the analyst choose.
