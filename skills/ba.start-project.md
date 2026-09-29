---
name: "ba.start-project"
summary: "Start a new BA project workspace on the analyst's behalf (no manual scripts)"
inputs: "A project name from the analyst"
prerequisites: "none"
output: "A scaffolded project: workspace/<slug>/ with project.md, tasks/, and a shared kb/index.md"
template: "templates/project/project.md"
---

# Skill: `ba.start-project`

Agent-driven project initiation. The analyst MUST NOT have to run shell scripts themselves —
you invoke the helper on their behalf. Follow `memory/ba-constitution.md`
(§"Initiation skills").

## When invoked, you MUST

1. **Get the project name and choose a mode.** Use the name the analyst provided; if none, ask for
   one (it is slugified for the folder). Then pick the **project mode**:
   - **independent** (default) — a light shared `kb/index.md`; best for a single task or a small,
     loosely-coupled set of tasks. Brain promotion (§11) is best-effort.
   - **brain** — the project `kb/` is the **single source of truth**; init scaffolds `changelog.md`
     plus registers (`requirements-register`, `open-questions`, `decisions`, `glossary`). Best for a
     multi-task pursuit (e.g. an RFP) where knowledge must compound across tasks; promotion (§11) is
     expected on every task. If the analyst is unsure, default to **independent** — it can be
     upgraded later.
2. **Scaffold the workspace.** Run the initiation helper on the analyst's behalf (pass the chosen
   mode; omit `--mode` for the default):

   ```sh
   scripts/sh/init-project.sh "<project name>" --mode <independent|brain>
   ```

   This creates `workspace/<slug>/project.md` (recording `kb_mode`), an empty `tasks/` folder, and
   the shared project-level knowledge base at `kb/index.md`. In **brain** mode it also scaffolds the
   changelog + registers. It is collision-safe: if the project exists, report that and stop rather
   than overwriting. An existing independent project can later be upgraded with
   `scripts/sh/init-project.sh "<name>" --upgrade-to-brain`.
3. **Elicit project context.** Ask the analyst a short, bounded set of questions to capture
   durable, project-wide context that downstream skills (e.g. `ba.specify`) will consult instead
   of re-asking: business goals/outcomes, key stakeholders/roles, domain terms, known constraints
   (regulatory, technical, timeline), and any house style or conventions. Keep it light — this is
   optional and non-blocking: if the analyst skips or defers, continue without error.
   - Persist the answers into the **project-level** knowledge base: write a `kb/context.md` entry
     and reference it from `kb/index.md` (under `## Entries`) so it is discoverable. Record
     anything uncertain as an assumption rather than fact.
4. **Surface the result.** Show the analyst the created paths (project root, `project.md`,
   `kb/index.md`, and `kb/context.md` if written) so they know where work lives. Offer to help
   fill in `project.md` (Overview / Goals / Stakeholders) and to seed further shared knowledge
   into `kb/`.
5. **Point the way forward** with the Next steps block below.

## Next steps

Derived from `workflow.md`. A project needs at least one task before analysis can begin:

```text
## Next steps
- ▶ ba.start-task   — create the first task to hold inputs and artifacts
- ✎ (optional) flesh out project.md and add shared context to kb/index.md (and kb/context.md)
```
