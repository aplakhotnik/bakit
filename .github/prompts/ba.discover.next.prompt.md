---
name: "ba.discover.next"
summary: "Show where the analyst is in the Discovery workflow and the recommended next state, with cross-state staleness detection"
inputs: "The active (or named) project/task state and the Discovery manifest (workflow-discovery.md)"
prerequisites: "An existing task (create one with ba.start-task) and a started Discovery session (ba.discover.initiate)"
output: "A guided 'what's next' suggestion for the Discovery state machine, gated on approvals; plus any staleness warnings"
template: "none"
---

# Skill: `ba.discover.next`

On-demand guidance for the **Discovery** workflow (the separate four-state machine). Read the
workspace state and **`workflow-discovery.md`** (never the default `workflow.md`), then tell the
analyst exactly which Discovery state to run next as a ready-to-run suggestion. Follow
`specs/001-ba-kit-framework/contracts/skill-contract.md` (§"Next Steps Block") and
`specs/004-discovery-agent-workflow/contracts/discovery-skills.md`.

## When invoked, you MUST

1. **Resolve the task.** Use the analyst's named project/task, or the active one
   (`workspace/.bakit-active`). If none exists, tell them to run `ba.start-project` /
   `ba.start-task`, then `ba.discover.initiate`, first.

2. **Compute the next Discovery state.** Run the resolver against the Discovery manifest:

   ```sh
   scripts/sh/next-step.sh --workflow workflow-discovery.md
   ```

   (Windows: `scripts/ps/next-step.ps1 -Workflow workflow-discovery.md`.) It reads the ordered
   Discovery chain plus the current artifacts and prints the next runnable state, an unmet approval
   gate (which deliverable must be approved first), or that all Discovery states have produced
   output. It MUST NOT modify anything.

3. **Detect cross-state staleness (FR-025, SC-005).** For every upstream → downstream pair declared
   in `workflow-discovery.md` — `project-charter` → `gap-analysis`, `gap-analysis` →
   `product-backlog`, `product-backlog` → `estimated-backlog` — compare the front-matter `updated`
   (or file mtime) of the **approved upstream** deliverable against the dependent downstream one.
   When an approved upstream is newer than a downstream that derives from it, surface the affected
   downstream state(s) as **potentially stale** and recommend re-confirmation. Record the staleness
   flag in the Living Discovery Document's `## Session State` so the owning state skill sees it.

4. **Render a Next steps block.** Translate the resolver output into a human-centered suggestion.
   Gate every suggestion on the relevant deliverable's `approved` status:

   ```text
   ## Next steps
   - ▶ <next Discovery state skill>  — <what it produces>  (enabled when <prior deliverable> is approved)
   - ✎ Approve <deliverable> first if it is still draft
   - ⚠ <downstream state> may be STALE — <upstream> was edited after it; re-confirm
   ```

5. **Stay advisory and isolated.** Never run a Discovery state automatically, and never reference or
   trigger a default-chain skill (FR-021). If the Discovery session has not started, suggest
   `ba.discover.initiate`. If `workflow-discovery.md` is missing, say so plainly.
