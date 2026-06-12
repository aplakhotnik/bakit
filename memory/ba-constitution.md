# BA-Kit Principles & Skill Contract (runtime memory)

This document is the **self-contained** governance that every BA-Kit skill is surfaced at runtime.
It combines the framework's core principles with the behavioral contract that all skills MUST
satisfy. When a skill must make a judgment call, it MUST follow these rules. (Skills reference
only this file — there is no external contract to look up.)

## 1. Specification-First Artifacts
Always produce a structured, templated artifact (Markdown + YAML front-matter) before any
rendered/downstream output. Never author a deliverable ad hoc.

## 2. Modular & Activity-Based
Each skill is self-contained: it declares its inputs, prerequisites, and output, and never
depends on or edits another skill. Adding a skill must not require changing the core.

## 3. Human-in-the-Loop Review (NON-NEGOTIABLE)
The analyst owns every output. Present AI-generated content as an editable **draft**
(`status: draft`). Never self-approve. Never consume an upstream artifact downstream, or
render a deliverable, unless that artifact is `status: approved`. Never silently overwrite
approved work.

## 4. Traceability & Source Grounding
Every produced item must trace to its source: populate `sources` (for documentation analysis)
and `derived_from` (for user stories / rendered pages), and cite sources inline. Flag every
assumption explicitly in `assumptions`; never present an assumption as fact. When inputs are
ambiguous or incomplete, ask targeted clarification questions instead of inventing detail.

## 5. Structured, Tool-Agnostic Outputs
Canonical artifacts are open, human-readable Markdown. Integrations (e.g., Confluence) are
optional adapters that render approved artifacts to local files; the artifact remains the
source of record. Integrations must fail safely and never block core artifact creation.

---

## Skill Behavioral Contract

Every skill under `skills/` MUST satisfy this contract so skills stay agent-agnostic, composable,
and review-gated.

**Required header.** Each skill file begins with a front-matter header declaring: `name`,
`summary`, `inputs`, `prerequisites` (upstream artifact(s) that must be `approved`, or `none`),
`output` (the artifact `type` and target path), and `template`.

**Behavioral rules (MUST):**

1. **Agent-agnostic** — rely only on plain prompt instructions plus the shell/PowerShell helpers;
   never depend on a single agent's proprietary features.
2. **Prerequisite gate** — before producing output, verify each prerequisite artifact exists and is
   `status: approved` (use `check-artifact.sh --require-approved`). If not, stop and explain what is
   missing; never proceed on unapproved input.
3. **Draft output** — write output as `status: draft` and present it as an editable proposal the
   analyst can change, regenerate, or reject. Never mark your own output `approved`.
4. **Clarify over assume** — on ambiguous or incomplete input, ask targeted clarification questions
   rather than fabricating content.
5. **Traceability** — populate provenance front-matter (`sources` and/or `derived_from`) and cite
   sources inline (`<!-- source: ... -->`) where applicable.
6. **Flag assumptions** — list every assumption in the `assumptions` front-matter; never present an
   assumption as fact.
7. **Template conformance** — output contains all required sections of its template.
8. **Non-destructive** — never overwrite an existing `approved` artifact without explicit
   confirmation.
9. **KB-aware grounding** — before producing output, consult the Knowledge Base at both levels
   (project `kb/` then task `kb/`, task taking precedence), reading each `kb/index.md` first. For
   large or multi-document inputs, use the lightweight RLM approach (index first, then recurse into
   only the relevant entries) rather than loading everything; degrade to a single pass for small
   inputs. Update the relevant `kb/index.md` when you add reusable knowledge. A missing/empty KB is
   never an error.
10. **Next-steps guidance** — end every run with a "Next steps" block naming the next workflow
    skill(s) (per `workflow.md`) as ready-to-run invocations, gated on the current artifact's
    approval status; when a prerequisite is unmet, point to the approval/edit step instead of
    advancing.

**"Next steps" block shape** (rendered as agent-appropriate runnable commands, derived from
`workflow.md`):

```text
## Next steps
- ▶ <next-skill>   — <what it produces>   (enabled when <this artifact> is approved)
- ✎ Edit/approve this artifact first if it is still draft
```

**Initiation skills** (`ba.start-project`, `ba.start-task`) MUST drive scaffolding by invoking the
helper scripts (`init-project.sh` / `init-task.sh`) on the analyst's behalf — the analyst is never
required to run shell scripts manually — then surface the resulting paths and a "Next steps" block.

## ba.specify obligations (front-door requirements)

In addition to the contract above, `ba.specify`:

- accepts a **plain-language need** and works without any pre-existing BRD/FRD; derives a concise
  title;
- **deep mode** runs a multi-round elicitation loop, each round raising a **bounded** (default ~3),
  **prioritized** (scope before detail) set of clarification questions with options + implications,
  persisting the living `elicitation-plan.md`, and folding answers back in until the analyst signals
  common understanding or defers the rest;
- after drafting, **validates** the spec against a quality checklist (testable requirements;
  measurable, tech-agnostic success criteria; bounded scope; recorded assumptions; no unresolved
  markers) and warns rather than presenting as complete if it cannot fully pass; also passes
  `check-artifact.sh`;
- **quick mode** captures already-clear inputs in a single pass with no elicitation plan, escalating
  to deep mode (never silently) when a material contradiction or blocking question surfaces.

## Discovery workflow obligations

The Discovery skills (`ba.discover.*`) satisfy the contract above and additionally:

1. **Living Discovery Document first** — on entry, read `artifacts/discovery-document.md` (if
   present) to restore state, gate status, and prior decisions; never re-ask answered questions.
   State 1 creates it; every state updates it and appends a `## Change Log` entry before finishing.
2. **Explicit phase gate** — States 2–4 verify the prior state's deliverable is `approved` before
   producing their own; otherwise they stop and direct the analyst to review/approve it.
3. **Zero-assumption** — when a goal, constraint, gap, or estimate is ambiguous or missing, halt and
   ask a targeted clarification set; record deferred/declined items under `## Open Questions`, never
   as fact.
4. **Draft + sign-off** — deliverables are written `status: draft`; the skill never self-approves.
5. **Traceability** — States 2–4 populate `derived_from` and keep every backlog item traceable to a
   recorded gap/need.
6. **No auto-chaining** — the "Next steps" block points only to the next **Discovery** state (per
   `workflow-discovery.md`), never to a default-chain skill.
7. **Staleness** — if an approved upstream deliverable is edited after a downstream state advanced,
   flag the affected downstream state(s) as potentially stale and ask for re-confirmation.

For I/O details, follow each skill's own header and steps.
