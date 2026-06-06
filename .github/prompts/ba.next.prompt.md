---
name: "ba.next"
summary: "Show where the analyst is in the workflow and the recommended next skill"
inputs: "The active (or named) project/task state"
prerequisites: "An existing task (create one with ba.start-task)"
output: "A guided 'what's next' suggestion with ready-to-run skills, gated on approvals"
template: "none"
---

# Skill: `ba.next`

On-demand workflow guidance. Read the workspace state and `workflow.md`, then tell the analyst
exactly what to do next as a click-ready suggestion. Follow
`specs/001-ba-kit-framework/contracts/skill-contract.md` (§"Next Steps Block").

## When invoked, you MUST

1. **Resolve the task.** Use the analyst's named project/task, or the active one
   (`workspace/.bakit-active`). If none exists, tell them to run `ba.start-project` /
   `ba.start-task` first.
2. **Compute the next step.** Run the resolver on the analyst's behalf:

   ```sh
   scripts/sh/next-step.sh
   ```

   It reads `workflow.md` (the ordered chain) plus the current artifacts and prints:
   - the next runnable skill, or
   - an unmet approval gate (which artifact must be approved first), or
   - that all workflow steps have produced output.
3. **Render a Next steps block.** Translate the resolver output into a human-centered,
   ready-to-run suggestion. Gate every suggestion on the relevant artifact's status:

   ```text
   ## Next steps
   - ▶ <next-skill>   — <what it produces>   (enabled when <prerequisite> is approved)
   - ✎ Approve <artifact> first if it is still draft
   ```

4. **Stay advisory.** Never run a downstream skill automatically — present the option and let
   the analyst choose. If the knowledge base is empty or `workflow.md` is missing, say so plainly
   and suggest the most sensible manual next step instead of failing.
