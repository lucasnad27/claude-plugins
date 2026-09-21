---
name: design-doc
description: Create a lightweight design discussion document for human-agent alignment before planning
model: opus
effort: xhigh
---

# Design Discussion

You are tasked with creating a lightweight design discussion document (~200 lines) that captures the shared understanding between you and the user about what's being built and how. This is the highest-leverage review moment — corrections here save hundreds of lines of rework downstream.

## What a design doc is

~200 lines of alignment: current state, desired end state, patterns to follow, testing approach.

File-by-file changes, code snippets, and phase ordering belong in `/create-plan` — this doc is what you and the user agree on before that exists. It's enough to agree on direction, not enough to implement from.

## Mark the herdr phase

As your very first action, tag this agent's herdr tab so the session navigator shows the workflow phase (safe no-op outside herdr):

```bash
bash "$(git rev-parse --show-toplevel)/.claude/scripts/herdr-phase.sh" design
```

## Initial Response

When this command is invoked:

1. **Check if parameters were provided:**
   - If a research doc path or ticket reference was provided as $ARGUMENTS, read them FULLY
   - If both a research doc and ticket are provided, read both
   - Begin the design process

2. **If no parameters provided**, respond with:

   ```
   I'll help you create a design discussion to align on what we're building before we plan the implementation.

   Please provide:
   1. A research document (from /research-codebase) or describe what you want to build
   2. Optionally, a ticket or task reference

   Tip: /design-doc .rpi/research-2026-01-05-auth-flow.md
   ```

   Then wait for the user's input.

## Process

### Step 1: Gather Context

1. **Read all provided files FULLY** — research docs, tickets, related docs
2. **Spawn light confirmation agents** (if needed):
   - Use **codebase-pattern-finder** to confirm patterns mentioned in research
   - Use **codebase-locator** to verify file locations if uncertain
   - These are quick confirmations, NOT a full research pass
3. **Read any files identified by confirmation agents**

### Step 2: Draft the Design Document

Write the design document to `.rpi/design-YYYY-MM-DD-description.md`

Use the template from `template.md` in this skill's directory as the starting structure. Adapt each section to the specific project and feature — the template shows what each section should contain and how to adapt based on project context (test infrastructure, API vs UI work, etc.).

**Produce a concrete reference artifact wherever the work has a shape you can render.** A self-contained HTML mockup settles more design questions than three paragraphs describing the same screen, and real JSON settles an API contract faster than a description of it. Write mockups alongside the design doc as `.rpi/design-YYYY-MM-DD-description.html` and link them from the Concrete Reference section. An HTML view made earlier in the conversation — a `/show-me` page, say — moves to that path if it settled a question; later phases read only what the design links. The user reviews the artifact, not your description of it — and the implementing agent builds against it directly.

### Step 3: Walk Through Open Questions

1. Batch open questions through `AskUserQuestion` — it accepts up to 4 questions per call with 2-4 options each. If you have ≤4 multiple-choice questions, send them all in one call. If you have more than 4, or some are free-text, combine the free-text ones into a single consolidated text prompt and use `AskUserQuestion` for the rest. Goal: minimize user turns. Every turn adds reasoning overhead, so don't drip-feed one question per turn.
2. When a question's options differ in shape, give each option a `preview` with its call-tree, file-tree, or component-tree sketch, so the user compares shapes instead of prose. Previews work only on single-select questions and render as monospace text, so use text trees, not Mermaid.
3. Update the design doc with resolved decisions
4. Move resolved questions from "Open Questions" to "Key Decisions" with rationale

### Step 4: Present the Design

```
I've created a design discussion at:
`.rpi/design-YYYY-MM-DD-description.md`

This captures our alignment on:
- [Key point 1]
- [Key point 2]
- [Key point 3]

All open questions are resolved. When you're ready, run `/create-plan` with this design to generate the implementation plan.
```

## Important Guidelines

1. **Target ~200 lines** — Simple features might be 80, complex ones 300. An order of magnitude shorter than a plan.
2. **Be opinionated about patterns** — Show the user which patterns you found and plan to follow. This is where they correct you.
3. **Testing approach is required** — Every design must address how we'll verify the work. Adapt to what the project actually has, don't prescribe TDD if there's no test infrastructure.
4. **No open questions in final doc** — Walk through all questions interactively before finalizing.
5. **Read research fully** — The research doc is your primary input. Don't re-research what's already been done.
6. **Surface patterns to follow explicitly** — This prevents the agent from following the wrong patterns during implementation.

## What This Replaces

Previously, `/create-plan` tried to handle both design alignment AND plan generation in a single 85+ instruction prompt. The design discussion handles alignment so that `/create-plan` can focus purely on tactical planning.
