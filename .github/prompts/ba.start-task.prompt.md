---
name: "ba.start-task"
summary: "Start a new task inside a project on the analyst's behalf (no manual scripts)"
inputs: "A project (active or named) and a task name from the analyst"
prerequisites: "An existing project (create one with ba.start-project)"
output: "A scaffolded task: tasks/NNN-<slug>/ with inputs/, artifacts/, deliverables/, kb/index.md"
template: "templates/task/kb-index.md"
---

# Skill: `ba.start-task`

Agent-driven task initiation. You invoke the helper on the analyst's behalf — no manual shell
scripts. Follow `memory/ba-constitution.md` and
`specs/001-ba-kit-framework/contracts/skill-contract.md` (§"Initiation Skills").

## When invoked, you MUST

1. **Resolve the project.** Use the project the analyst named, or the active project
   (`workspace/.bakit-active`). If no project exists, tell the analyst to run
   `ba.start-project` first and stop.
2. **Get the task name.** Use the analyst's name; if none, ask for one.
3. **Scaffold the task.** Run the initiation helper on the analyst's behalf:

   ```sh
   scripts/sh/init-task.sh "<project>" "<task name>"
   ```

   This creates `tasks/NNN-<slug>/` with `inputs/`, `artifacts/`, `deliverables/`, and a
   task-level `kb/index.md`, then sets it active. Numbering is sequential and collision-safe.
4. **Surface the result.** Show the created paths and explain where to put source material
   (`inputs/`), where artifacts land (`artifacts/`), where rendered output goes
   (`deliverables/`), and where task-scoped knowledge lives (`kb/index.md`).
5. **Point the way forward** with the Next steps block below.

## Next steps

Derived from `workflow.md`. The first workflow step depends on what the analyst has:

```text
## Next steps
- ▶ ba.analyze-docs        — if there are existing documents in inputs/ to analyze
- ▶ ba.specify             — to capture requirements from a need or notes/conversation
- ▶ ba.next                — ask anytime for the recommended next step
```
