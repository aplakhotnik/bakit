# Working with the default workflow

This is the everyday BA flow: turn raw material into reviewed requirements and, optionally, into
user stories and a Confluence-ready page. It's deliberately simple and linear.

> First time here? Do the one-time setup in **[Getting started](getting-started.md)** and skim the
> **[glossary](concepts.md)**. Looking for the more consultative idea-to-roadmap process? That's the
> separate, advanced **[Discovery workflow](discovery.md)**.

## The flow at a glance

```text
ba.start-project → ba.start-task → (add inputs) → ba.analyze-docs → ba.specify → (ba.decompose) → ba.write-stories → ba.render-confluence
       │                │                              │                │            │              │                    │
   project +        task +                      extract from      structured    story map      user stories        shareable
   context          context                     documents         requirements  (optional)     + criteria          deliverable
```

Each arrow is **review-gated**: a step that consumes an earlier artifact won't proceed until you've
marked that artifact `approved`. At any point, run `/ba.next` to be told exactly what's runnable now.

## Step 1 — Create the project (with context)

```text
/ba.start-project   →  "Start a project called payments-revamp"
```

Beyond creating folders, the assistant captures **project context** — vision, key stakeholders,
constraints, glossary terms — into the shared project `kb/`. This is grounding the AI reuses across
every task, so you don't repeat yourself. Spend a couple of minutes here; it pays off later.

## Step 2 — Add a task (with context)

```text
/ba.start-task   →  "Add a task: elicit-requirements"
```

Tasks are how you slice the work (e.g. *elicit-requirements*, *payment-gateway-analysis*). Each task
gets its own `inputs/`, `artifacts/`, `deliverables/`, and `kb/`. Task knowledge takes precedence
over project knowledge when the two overlap, so a task can refine or override shared facts.

## Step 3 — Add your inputs

Drop everything relevant into the task's `inputs/` folder: meeting notes, emails, an existing BRD,
screenshots' text, exported tickets. Plain text and Markdown work best. You don't have to tidy them
up — that's what analysis is for.

## Step 4 — Analyze existing documents (optional but recommended)

```text
/ba.analyze-docs
```

When you have source documents, this skill reads them (grounded in your knowledge base first) and
produces `artifacts/docs-analysis.md`: extracted candidate requirements, **gaps**, inconsistencies,
and **open questions** — each citing where it came from. If two documents disagree on something
important, the skill can run a short, focused round of clarifying questions before recording what's
still unresolved.

Review `docs-analysis.md`, edit as needed, and set `status: approved` when you're happy. (If you're
working purely from notes rather than documents, you can skip straight to the next step.)

## Step 5 — Specify the requirements

```text
/ba.specify
```

This is the front door to a structured `artifacts/requirements.md`. It has two modes:

- **Deep mode (default)** — for an open-ended *need* or ambiguous inputs. It runs an iterative,
  multi-round clarification loop (saved in a living `elicitation-plan.md`), asking a small, prioritized
  set of questions each round, then validates the draft against a quality checklist.
- **Quick mode** — for already-clear notes you just want captured. A single clarification pass, no
  elicitation plan. If a real contradiction surfaces, it will recommend switching to deep mode rather
  than guessing.

If you ran analysis first, any open questions from `docs-analysis.md` are **carried forward** so
nothing is lost. Before you decompose further, `ba.specify` shows a **readiness summary**: what's
resolved, what's still open, and — for anything blocking — what's needed to close it.

Review `requirements.md`, edit freely, then set `status: approved`. This approval unlocks the
downstream steps.

> **Tip:** if `ba.specify` notes there are still *blocking* open questions, you can either resolve
> them now or consciously proceed — `ba.next` will remind you, but it never forces you.

## Step 5b — Decompose into a story map (optional, suggested)

```text
/ba.decompose
```

With an **approved** `requirements.md`, this optional step produces `artifacts/story-map.md`: a
shape-aware **backbone** of prioritized, independently testable **slices**, an explicit **MVP /
walking-skeleton**, dependency notes, and a coverage check that every requirement maps to at least
one slice. It characterizes the *solution shape* and names a **splitting pattern** for each slice
(see [decomposition patterns](decomposition-patterns.md)), can evaluate **parallel strategy
variants** in one map (with a single *Selected variant*), and runs as a **resumable loop** that
remembers your decisions.

It is **suggested, never required** — `ba.next` will offer it, but you can skip straight to
`ba.write-stories`. When a map exists and is approved, `ba.write-stories` expands its selected
variant's slices into stories; when it doesn't, `ba.write-stories` still light-decomposes the
requirements itself. Review `story-map.md`, edit, and set `status: approved` when ready.

## Step 6 — Write user stories (optional)

```text
/ba.write-stories
```

With an **approved** `requirements.md`, this produces `artifacts/user-stories.md`: well-formed user
stories with acceptance criteria, each traceable back to a requirement. If an **approved**
`story-map.md` exists, the stories expand its **selected variant's slices** and trace to the map;
otherwise they are light-decomposed straight from the requirements (never a raw 1:1 dump). Review
and approve as usual.

## Step 7 — Render a deliverable (optional)

```text
/ba.render-confluence
```

Point it at any **approved** artifact (requirements or user stories) and it renders a
Confluence-ready Markdown file into `deliverables/`. It produces a **local file only** — no network
calls — so you stay in control of what gets published.

You can produce stories, a Confluence page, or both — they're independent optional steps off the
same approved requirements.

## Asking "what's next?" any time

```text
/ba.next
```

`ba.next` reads `workflow.md` (the recommended order) plus your current artifacts and tells you the
single sensible next action — or which artifact needs approval first. Every skill also ends with its
own **Next steps** block, so the guided path is consistent wherever you are.

## The review gate, in one sentence

A skill will **only** consume an upstream artifact that is `status: approved` — so you always review
AI output before it flows forward, and nothing is silently overwritten.

## What you end up with

```text
tasks/001-elicit-requirements/
├── inputs/            ← your raw material
├── artifacts/
│   ├── docs-analysis.md      (approved)
│   ├── requirements.md       (approved)
│   ├── elicitation-plan.md   (deep mode only)
│   └── user-stories.md       (approved)
└── deliverables/
    └── requirements-confluence.md
```

All plain Markdown, all reviewable in git over time.

> **Taking a BA-Kit update?** Upgrading the package and re-running the installer never touches this
> workspace — your inputs, artifacts, and deliverables are yours. Any installed command you tuned is
> backed up before it's replaced. Preview first with `./install.sh --check` (or `.\install.ps1
> -Check`); see **[Getting started → Upgrading BA-Kit](getting-started.md#upgrading-ba-kit)**.

---

Next: the per-skill reference in **[skills/README.md](../skills/README.md)**, or the advanced
**[Discovery workflow](discovery.md)**.
