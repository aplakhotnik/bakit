# The Discovery workflow (advanced)

> **This is a separate, more advanced workflow.** Most BA work uses the simpler
> **[default workflow](workflows.md)** (analyze → specify → write stories → render). Reach for
> Discovery when you're starting from a raw *project idea* and need to walk a stakeholder all the
> way to an estimated, road-mapped backlog. The two workflows coexist and never interfere — Discovery
> never auto-triggers the default chain.

## What it is

Discovery is a **consultative BA/PO process** implemented as a **four-state machine**. It behaves
like an experienced analyst interviewing a stakeholder, and it persists everything in a single
**Living Discovery Document** (`artifacts/discovery-document.md`) so a session can be paused and
resumed at the right place.

```text
ba.discover.initiate → ba.discover.gap-analysis → ba.discover.backlog → ba.discover.estimate
   (Project Charter)      (Gap Analysis Matrix)      (Product Backlog)    (Estimated Backlog + Roadmap)
```

| State | Skill | Produces |
|-------|-------|----------|
| 1 | `ba.discover.initiate` | `project-charter.md` (+ creates the living `discovery-document.md`) |
| 2 | `ba.discover.gap-analysis` | `gap-analysis.md` (current → future → gap → implication) |
| 3 | `ba.discover.backlog` | `product-backlog.md` (epics, stories, acceptance criteria) |
| 4 | `ba.discover.estimate` | `estimated-backlog.md` (+ release roadmap) |
| — | `ba.discover.next` | guidance: the next state + staleness checks |

## How it behaves

- **Explicit phase gates.** Each state refuses to advance until the previous state's deliverable is
  `status: approved` — the same human-in-the-loop gate the default workflow uses.
- **Zero-assumption.** When something is ambiguous or missing, the assistant halts and asks targeted
  questions rather than inventing business content. Deferred items are recorded as open questions.
- **Stateful & resumable.** The Living Discovery Document is the canonical record; an interrupted
  session resumes at the correct state.
- **Estimation, honestly.** State 4 offers at least Fibonacci, T-Shirt, and PERT, runs an
  item-by-item session in your chosen scale, and flags anything it can't size as `UNESTIMABLE`
  rather than guessing.

## Running it

Invoke the convenient entry point from inside your assistant:

```text
/ba.discover.initiate     ← start (State 1)
/ba.discover.next         ← ask which Discovery state to run next
```

`ba.discover.next` reads the Discovery manifest (`workflow-discovery.md`), never the default
`workflow.md`, and also flags any downstream state made **stale** by an edit to an approved upstream
deliverable.

Prefer the terminal? Point the next-step helper at the Discovery manifest:

```sh
./scripts/sh/next-step.sh --workflow workflow-discovery.md      # macOS/Linux
./scripts/ps/next-step.ps1 -Workflow workflow-discovery.md      # Windows
```

## Combining with the default workflow

The workflows are independent, but you **may** hand a Discovery output to a default-chain skill — for
example, feed an approved Product Backlog into `ba.write-stories`. Discovery itself will never do
this automatically; it always waits for you.

---

See the per-skill reference for the Discovery skills in
**[skills/README.md](../skills/README.md#discovery-activities-consultative-bapo-state-machine)**.
