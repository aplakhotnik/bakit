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
you invoke the helper on their behalf. Follow `memory/ba-constitution.md` and
`specs/001-ba-kit-framework/contracts/skill-contract.md` (§"Initiation Skills").

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
3. **Surface the result.** Show the analyst the created paths (project root, `project.md`,
   `kb/index.md`) so they know where work lives. Offer to help fill in `project.md`
   (Overview / Goals / Stakeholders) and to seed shared knowledge into `kb/`.
4. **Point the way forward** with the Next steps block below.

## Next steps

Derived from `workflow.md`. A project needs at least one task before analysis can begin:

```text
## Next steps
- ▶ ba.start-task   — create the first task to hold inputs and artifacts
- ✎ (optional) flesh out project.md and add shared context to kb/index.md
```
