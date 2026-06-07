# BA-Kit Skills

Skills are **agent-agnostic** guided BA activities. Each is a single Markdown file with a
structured front-matter header and step instructions. A skill produces one structured artifact
into the active task and enforces the human-in-the-loop review gate.

## Available skills

### Orchestration (agent-driven flow)

These drive the workspace and the guided path for you — you invoke them instead of running
shell scripts by hand:

| Skill | Does | Prerequisite |
|-------|------|--------------|
| `ba.start-project` | scaffold a project (`project.md`, `tasks/`, shared `kb/`) | none |
| `ba.start-task` | scaffold a task (`inputs/artifacts/deliverables/kb`) | a project |
| `ba.next` | resolve & suggest the next workflow step (approval-gated) | a task |

### BA activities (produce artifacts)

| Skill | Produces | Prerequisite |
|-------|----------|--------------|
| `ba.specify` | `artifacts/requirements.md` + `artifacts/elicitation-plan.md` | none |
| `ba.specify-requirements` | `artifacts/requirements.md` | none |
| `ba.analyze-docs` | `artifacts/docs-analysis.md` | none |
| `ba.write-stories` | `artifacts/user-stories.md` | approved `requirements.md` |
| `ba.render-confluence` | `deliverables/*-confluence.md` | an approved source artifact |

### Discovery activities (consultative BA/PO state machine)

A separate, additive workflow that turns a plain idea into an estimated, road-mapped backlog
while persisting a Living Discovery Document. Each step is phase-gated on the prior artifact's
approval. Declared in [`../workflow-discovery.md`](../workflow-discovery.md) — it coexists with
the default chain and never auto-triggers it.

| Skill | Produces | Prerequisite |
|-------|----------|--------------|
| `ba.discover.initiate` | `artifacts/project-charter.md` (+ living `discovery-document.md`) | none |
| `ba.discover.gap-analysis` | `artifacts/gap-analysis.md` | approved `project-charter.md` |
| `ba.discover.backlog` | `artifacts/product-backlog.md` | approved `gap-analysis.md` |
| `ba.discover.estimate` | `artifacts/estimated-backlog.md` | approved `product-backlog.md` |
| `ba.discover.next` | resolves the next discovery step + cross-state staleness check | a task |

> **Run the discovery chain** by pointing the next-step helper at its manifest:
> `next-step.sh --workflow workflow-discovery.md` (PowerShell: `-Workflow workflow-discovery.md`),
> or just invoke `ba.discover.next`, which does this for you.

> **`ba.specify` vs. `ba.specify-requirements`.** Both produce the same `requirements.md`, and
> they coexist. Use **`ba.specify`** when starting from a plain-language *need*: it runs an
> iterative, KB-grounded "deep research" clarification loop (persisted in a living
> `elicitation-plan.md`) and validates the draft against a quality checklist before presenting
> it. Use the lighter **`ba.specify-requirements`** for the quick "raw notes/inputs →
> requirements list" case. Because they share `requirements.md`, each confirms before
> overwriting an existing draft or approved spec.

The ordered chain and per-step approval gates live in [`../workflow.md`](../workflow.md) — the
single source of truth that `ba.next` / `next-step.sh` and every skill's **Next steps** block
are derived from.

## Knowledge base & lightweight RLM

Each project and task carries a `kb/index.md` (`## Summary` + `## Entries`). Activity skills
ground their work by reading the project index first, then the task index (task precedence),
and for large inputs recurse into only the relevant entries in focused passes (lightweight
Recursive-Language-Model strategy), degrading to a single pass for small inputs. A missing or
empty `kb/` never causes failure. See the contract's §"KB-aware grounding".

## How to add a new skill (no core edits required)

BA-Kit is modular: a new skill is a drop-in file plus its template. You do **not** modify any
existing skill, script, or template.

1. **Copy the skill template**: `cp _skill-template.md ba.<verb>-<noun>.md`.
2. **Fill the header**: `name`, `summary`, `inputs`, `prerequisites`, `output`, `template`.
3. **Write the steps** following the contract in
   `specs/001-ba-kit-framework/contracts/skill-contract.md`:
   resolve the active task → check prerequisites → gather inputs → clarify → produce a `draft`
   artifact with traceability/assumptions → present for review (never self-approve).
4. **Add a template** under `templates/artifacts/<template>.md` using the front-matter
   convention in `templates/artifacts/_frontmatter.md`. If your artifact `type` needs new
   conditional required fields, extend `scripts/sh/check-artifact.sh` accordingly.
5. **Re-run the installer** (`./install.sh`) to map the new skill into your agent.

That's it — the new skill works alongside the others without touching them (validates FR-019 /
SC-004).

## Agent-agnostic validation note (FR-009a)

These skills avoid agent-proprietary features and rely only on plain prompt instructions plus
the shell helpers, so they run consistently across agents (e.g., Copilot, Claude, Cursor). To
spot-check: run `ba.specify-requirements` on the same inputs in a second agent and confirm the
produced `requirements.md` conforms to the same template and passes `check-artifact.sh`.

<!-- Record cross-agent validation results here as you verify them. -->
