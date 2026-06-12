# FAQ & troubleshooting

## Installing & first run

**The `/ba.*` commands don't appear in VS Code (Copilot).**
1. Reload the window: Command Palette → *Developer: Reload Window*.
2. **Trust the folder** if VS Code prompts you.
3. Confirm prompt files are enabled — the installer sets `chat.promptFiles: true` in
   `.vscode/settings.json`. If you already had a `.vscode/settings.json`, the installer won't
   overwrite it; add the key yourself.
4. Type `/` in Copilot Chat and look for `ba.start-project`.

**Where did the installer put the skills?** It depends on your assistant:

| Assistant | Location |
|-----------|----------|
| VS Code (Copilot) | `.github/prompts/*.prompt.md` |
| Claude | `.claude/commands/*.md` |
| Cursor | `.cursor/commands/*.md` |
| Generic | `.bakit/skills/*.md` |
| Antigravity | `.agents/skills/ba.<skill>/SKILL.md` (or `~/.gemini/config/skills/` with `--scope global`) |

These are **generated** from `skills/` — never edit them directly; edit the source under `skills/`
and re-run the installer. (That's also why they're git-ignored.)

**Can I install for more than one assistant?** Yes — pick multiple numbers in the menu, or run the
installer again with a different `--agent` flag. Re-running is always safe and idempotent.

**Do I need internet access?** Only to `git clone` the repo. The installer and all skills make no
network calls.

## Using the workflow

**What's the difference between an artifact and a deliverable?** An *artifact* (e.g.
`requirements.md`) is your structured working document. A *deliverable* (e.g. a Confluence page) is
a final rendering of an **approved** artifact, meant for sharing.

**A skill says it can't proceed because something isn't approved.** That's the review gate working as
intended. Open the named artifact, review it, and change its top line to `status: approved`, then run
the skill again. Run `/ba.next` if you're unsure which artifact needs approval.

**How do I approve an artifact?** Open the `.md` file and change `status: draft` to
`status: approved` in the front-matter block at the top. Save the file.

**`ba.specify` keeps asking me questions.** Deep mode runs a few short rounds on purpose, to remove
ambiguity. You can answer, or say you'd like to defer the rest — it will record deferred items as
open questions and converge. For already-clear inputs, ask for **quick mode**.

**It mentions "blocking open questions" — am I stuck?** No. Those are advisory. BA-Kit will remind
you they're unresolved, but you can consciously proceed; doing so is recorded as an override for
traceability.

**Quick vs deep mode — which do I pick?** Use **deep** when starting from an open-ended need or messy
inputs; use **quick** when your notes are already clear and you just want them captured. When unsure,
deep is the safe default.

**Where are my files?** Under `workspace/<project>/tasks/<NNN-task>/`. Override the workspace location
with the `BAKIT_WORKSPACE` environment variable.

## Knowledge base

**What should go in the `kb/`?** Durable, reusable facts: agreed terminology, decisions, constraints,
house style. Skills read it first so they reuse known facts instead of re-asking. A missing or empty
`kb/` is never an error.

**Project `kb/` vs task `kb/`?** Project knowledge is shared across all tasks; task knowledge is
specific to one task and takes precedence where they overlap.

## Customizing & contributing

**Can I add my own skill?** Yes — drop a new `ba.<name>.md` into `skills/` (plus any template) and
re-run the installer. No core changes needed. See
[skills/README.md](../skills/README.md#how-to-add-a-new-skill-no-core-edits-required).

**Where are the rules a skill must follow?** In [`../memory/ba-constitution.md`](../memory/ba-constitution.md)
— the self-contained principles and Skill Behavioral Contract.

**Found a bug or want to contribute?** See [CONTRIBUTING.md](../CONTRIBUTING.md). All tests in
`tests/sh/` and `tests/ps/` must pass.
