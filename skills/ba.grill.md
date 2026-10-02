---
name: "ba.grill"
summary: "Interrogate a loose idea in prerequisite-ordered rounds until it can be committed to — surfacing decisions, open questions, assumptions and un-grillable items before any artifact is written"
inputs: "A loose idea, need, direction or decision stated by the analyst (plus, when they exist, the project/task kb/ for grounding)"
prerequisites: "none"
output: "none by default (stateless — an aligned understanding in the conversation); with --capture, an append-only KB digest (project kb/ registers + changelog, or a task kb/ entry)"
template: "none"
---

# Skill: `ba.grill`

Structured **grilling**: the agent interviews the analyst about an idea until the idea is sharp
enough to commit to. It is the *front door for vagueness* — you invoke it **before** `ba.specify`,
`ba.discover.initiate`, `ba.decompose` or any scoping commitment, precisely when you cannot yet
state the thing precisely.

Agent-agnostic. Follow `memory/ba-constitution.md` — especially §3 (human-in-the-loop),
§4 (clarify over assume; never present an assumption as fact) and §13 (grill before committing).

> Method adapted for BA-Kit from the `/grill-me` skill described at
> <https://www.aihero.dev/skills-grill-me> (AI Hero, Matt Pocock). This file is BA-Kit's own
> implementation of that interviewing pattern, wired to the constitution and the KB.

## Core stance

- **Stateless by default.** Grilling writes **no artifact** and creates no workspace. The only
  output is a sharper idea plus, at the end, an in-conversation summary. Use `--capture` when the
  analyst explicitly wants the result preserved (see step 7).
- **Do not rush to a plan.** Producing a plan, spec or backlog during a grilling session is a
  failure mode. Stay in inquiry until the frontier is empty; handing off is a separate step.
- **The analyst owns the scope, not you.** Your job is questions and pushback, not consensus.
- **No self-approval, no invention.** Anything unconfirmed is recorded as an assumption or an open
  question — never asserted.

## When invoked, you MUST

1. **Restate the idea in one paragraph, then say what you think it is *not*.**
   Ask the analyst to correct both. This is the cheapest scope check available; do it before any
   questions. If they supplied documents or transcripts, read them first and ground the restatement
   in them (cite where a claim came from).

2. **Ground in existing knowledge (index-first).** If a project/task exists, read project
   `kb/index.md` then the task `kb/` (task precedence), plus `kb/open-questions.md`,
   `kb/decisions.md` and `kb/glossary.md` when present. **Never ask a question the KB already
   answers**; instead, state the recorded answer and ask only whether it still holds. A missing or
   empty KB is never an error.

3. **Build the question tree, then ask by *frontier*, not by list.**
   Internally map the questions the idea implies and their prerequisite links (question B is
   *blocked* if its sensible answer depends on the answer to A). Then:
   - A **round** = every question currently on the frontier (all prerequisites settled).
   - Never ask a blocked question early — it forces the analyst to guess, and the guess becomes a
     fake constraint.
   - Number questions per round (`R1.1`, `R1.2`, …) so answers can be given tersely and out of order.
   - For each question give: the question, 2–4 concrete **options** where they exist, and the
     **implication** of each (what it makes cheap, what it forecloses). Options are prompts, not a
     menu — "none of these, actually it's X" is a first-class answer.
   - Order within a round: **scope before detail, irreversible before reversible.**
   - Default batch size is the whole frontier; if the analyst asks for one question at a time,
     honour that for the rest of the session.

4. **Run the rounds until the frontier is empty.** Each round: fold the answers in, mark questions
   `settled` / `open` / `deferred` / `ungrillable`, re-derive the frontier (answers usually unblock
   new questions *and* delete questions that no longer apply), then ask the next round. Count
   **rounds, not questions** — a handful of rounds with many questions each is normal. Between
   rounds, report in one or two lines what just changed (what got decided, what it killed, what it
   opened).
   Stop early and say so when: the analyst signals they have enough, the scope is clearly too large
   for one session (propose splitting it and grilling each piece), or the remaining questions are
   all ungrillable.

5. **Push back — a session with no disagreement was not needed.**
   You MUST, at least once per round when warranted:
   - name the **implicit decision** hiding inside an answer ("choosing X means you've decided Y —
     is that intended?");
   - flag **scope drift** the moment answers start growing the thing;
   - challenge an answer that conflicts with an earlier one, or with the KB, and ask which wins;
   - accept **"I don't know"** as a real answer — do not re-ask it in a new costume. Record it as an
     open question with an owner and a way to find out.
   Never answer your own questions to keep momentum, and never treat silence or "agreed" as
   confirmation of something material; ask it back in different words once, then record it as open.

6. **Detect *ungrillable* questions and stop grilling them.** Some questions cannot be answered by
   talking — they need something to react to (a layout, a wording, a feel, a real dataset, a system
   behaviour nobody has observed). When you hit one:
   - say it is ungrillable and why;
   - propose the cheapest thing that makes it answerable — a throwaway mock/prototype, a sample
     document, a walkthrough with a real user, a spike, a 15-minute call with a named person;
   - park it and move on. **Do not** rephrase-and-retry; that is where sessions balloon.

7. **Close with the session summary** (in-conversation, always):

   ```text
   ## Grilling summary — <idea>
   Rounds: <n>
   ### Decisions (defensible, with the reason)
   ### Ruled out (and why)
   ### Open questions  (owner · how it gets answered · blocking? y/n)
   ### Assumptions we're proceeding on (never stated as fact)
   ### Ungrillable — needs a prototype/artefact to react to
   ### Changed from the original idea
   ```

   Then check the two failure modes out loud: *"Did you disagree with anything?"* and *"Can you
   defend each decision above to someone who wasn't in this conversation?"* If the answer to either
   is no, name the specific items that are still soft.

   **`--capture` (opt-in, append-only).** If the analyst asks to preserve the session — and in a
   `kb_mode: brain` project you SHOULD offer it — promote a **digest only** per constitution §11/§12:
   - append a dated entry to project `kb/changelog.md` (date · task/skill · 3–5 bullets);
   - merge decisions into `kb/decisions.md`, open questions into `kb/open-questions.md`, new terms
     into `kb/glossary.md`, confirmed needs into `kb/requirements-register.md`;
   - or, with no project yet, write the summary to the task `kb/grill-<topic>.md` and list it in
     `kb/index.md` under `## Entries`.
   Never copy the whole transcript, never overwrite analyst-authored content (supersede with a date
   and reason), and never let capture imply approval.

8. **Hand off in the same conversation.** The value of a grilling session is the context just built,
   so do **not** start a fresh session to write the spec. Point at the next skill and carry the
   answers into it.

## Anti-patterns (you are doing it wrong if…)

- you produced a plan, spec, backlog or estimate during the session;
- you asked forty questions and the analyst agreed with all of them;
- you asked a question whose answer was already in the KB or in an earlier answer;
- you kept rephrasing an ungrillable question instead of proposing something to react to;
- you widened scope to absorb uncertainty instead of naming the uncertainty;
- you wrote files without `--capture`.

## Next steps

```text
## Next steps
- ▶ ba.specify            — turn the grilled idea into testable requirements (deep mode, same conversation)
- ▶ ba.discover.initiate  — if this is a full discovery pursuit, start the charter with these answers
- ▶ ba.assumptions-log    — record the assumptions the session is proceeding on
- ▶ ba.risk-register      — record risks surfaced by the open/ungrillable items
- ↻ ba.grill <sub-idea>   — if the scope was too large, split it and grill each piece
```
