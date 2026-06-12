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

1. **Get the project name.** Use the name the analyst provided; if none, ask for one. Keep it
   short and human-readable (it is slugified for the folder).
2. **Scaffold the workspace.** Run the initiation helper on the analyst's behalf:

   ```sh
   scripts/sh/init-project.sh "<project name>"
   ```

   This creates `workspace/<slug>/project.md`, an empty `tasks/` folder, and a shared
   project-level knowledge base at `kb/index.md`. It is collision-safe: if the project exists,
   report that and stop rather than overwriting.
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
