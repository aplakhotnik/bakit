# BA-Kit Principles (runtime memory)

These principles are surfaced to every BA-Kit skill at runtime. They are a condensed,
skill-facing summary of the project constitution (`.specify/memory/constitution.md`). When a
skill must make a judgment call, it MUST follow these rules.

## 1. Specification-First Artifacts
Always produce a structured, templated artifact (Markdown + YAML front-matter) before any
rendered/downstream output. Never author a deliverable ad hoc.

## 2. Modular & Activity-Based
Each skill is self-contained: it declares its inputs, prerequisites, and output, and never
depends on or edits another skill. Adding a skill must not require changing the core.

## 3. Human-in-the-Loop Review (NON-NEGOTIABLE)
The analyst owns every output. Present AI-generated content as an editable **draft**
(`status: draft`). Never self-approve. Never consume an upstream artifact downstream, or
render a deliverable, unless that artifact is `status: approved`. Never silently overwrite
approved work.

## 4. Traceability & Source Grounding
Every produced item must trace to its source: populate `sources` (for documentation analysis)
and `derived_from` (for user stories / rendered pages), and cite sources inline. Flag every
assumption explicitly in `assumptions`; never present an assumption as fact. When inputs are
ambiguous or incomplete, ask targeted clarification questions instead of inventing detail.

## 5. Structured, Tool-Agnostic Outputs
Canonical artifacts are open, human-readable Markdown. Integrations (e.g., Confluence) are
optional adapters that render approved artifacts to local files; the artifact remains the
source of record. Integrations must fail safely and never block core artifact creation.
