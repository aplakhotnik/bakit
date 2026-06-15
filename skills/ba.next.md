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
exactly what to do next as a click-ready suggestion. Follow `memory/ba-constitution.md`
(§"Next steps" block shape).

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

   When the resolver prints an **`Optional:`** line (a suggested-but-not-gating step such as
   `ba.decompose`), relay it **alongside** the runnable next step — clearly labelled as optional and
   skippable, **never** as a blocker. The analyst may run it or proceed straight to the required
   step:

   ```text
   ## Next steps
   - ◇ ba.decompose  — (optional) build a story map before writing stories; you may skip it
   - ▶ ba.write-stories — convert approved requirements into user stories
   ```

4. **Stay advisory.** Never run a downstream skill automatically — present the option and let
   the analyst choose. If the knowledge base is empty or `workflow.md` is missing, say so plainly
   and suggest the most sensible manual next step instead of failing.
5. **Surface blocking open questions (advisory).** When the resolver prints a blocking-gap warning
   (the approved prerequisite still carries unresolved `blocking_questions`), relay it to the
   analyst — name the artifact, the count, and point to its `## Open Questions` table. Then offer
   two clearly-labelled paths and let the analyst pick:
   - **Resolve first** — go back to the producing skill (e.g. `ba.specify`) to answer the blocking
     question(s) before proceeding.
   - **Proceed anyway** — continue to the suggested next skill despite the open gap.

   This is advisory only: it never auto-approves and never hard-blocks (per the constitution's
   human-in-the-loop principle).
6. **Record an Override when the analyst proceeds anyway.** If the analyst explicitly chooses to
   proceed past blocking open questions, append an **Override Record** capturing: the workflow step
   being entered, the blocking question ID(s) overridden, who approved (the analyst), and a
   timestamp. Write it to:
   - the prerequisite's **elicitation-plan Round Log** (`## Round Log` → Overrides line) in deep
     mode, **or**
   - the requirements artifact's **`## Override Log`** section when no `elicitation-plan.md` exists
     (quick mode).

   Never fabricate the approval — only record an override the analyst actually authorised, and
   never set `status: approved` on the analyst's behalf.
