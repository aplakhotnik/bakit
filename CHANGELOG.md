# Changelog

All notable changes to BA-Kit are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project aims to follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-06-12

First public release.

### Added

- **Documentation set** under `docs/`: [Getting started](docs/getting-started.md),
  [Concepts & glossary](docs/concepts.md), [Working with the default workflow](docs/workflows.md),
  the advanced [Discovery workflow](docs/discovery.md), and an [FAQ](docs/faq.md).
- **Worked example** under `examples/`: a finished sample project (`customer-feedback-portal`)
  showing the default flow end to end — raw input → docs-analysis → approved requirements →
  user stories → rendered Confluence page — so newcomers can see the output before running
  anything. The user stories now include personas, a story map, and detailed Given/When/Then
  acceptance criteria, and a `deliverables/` folder holds a Confluence-ready page rendered from
  the approved stories.
- **Demo recording** (`docs/assets/skill_demo.gif`) embedded in the README and Getting started
  guide, showing the BA skills driven from inside the AI assistant.
- **Continuous integration** (`.github/workflows/ci.yml`): runs the full shell and PowerShell
  test suites on Linux, macOS, and Windows for every push and pull request.
- **New guard tests** (mirrored sh + ps): a Markdown link checker (`test-doc-links`) that fails
  on broken relative links, and a dangling-reference guard (`test-no-dangling-refs`) that keeps
  the package self-contained.
- `CHANGELOG.md` (this file) and a `.gitignore` for installer-generated outputs and runtime
  workspaces.
- Gap-aware workflow (feature 007): structured open-question tracking with `open_questions` /
  `blocking_questions` front-matter rollups, a `--require-no-blocking` validator flag, advisory
  blocking-gap warnings in `ba.next` / `next-step`, decomposition-readiness summary in `ba.specify`,
  carry-forward of open questions from analysis, and an optional clarify round in `ba.analyze-docs`.

### Changed

- **README** trimmed to a friendly overview that links into the new `docs/` set; the detailed
  Discovery write-up moved to [docs/discovery.md](docs/discovery.md).
- **`memory/ba-constitution.md`** is now self-contained: it folds in the Skill Behavioral Contract,
  the "Next steps" block shape, initiation rules, the `ba.specify` obligations, and the Discovery
  workflow obligations. Skills now reference only this file.

### Fixed

- Resolving a project or task by an explicit name now slugifies the argument, matching the
  lowercase, slugified directory names created on disk. Previously an explicit name like `Demo`
  resolved to a `Demo/` path that only existed on case-insensitive filesystems (macOS, Windows);
  on case-sensitive filesystems (Linux) the lookup failed. Fixed in both the shell and PowerShell
  helpers.
- Removed dangling references to `specs/**/contracts/*.md` and `.specify/memory/constitution.md`
  across skills, templates, and contributor docs — those files are not part of the distributed
  package, so the references are now self-contained.
- Stopped shipping installer-generated outputs (`.github/prompts/`, `.vscode/settings.json`) that
  duplicated `skills/` and risked drifting from the source of truth.

[Unreleased]: https://github.com/aplakhotnik/bakit/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/aplakhotnik/bakit/releases/tag/v0.1.0
