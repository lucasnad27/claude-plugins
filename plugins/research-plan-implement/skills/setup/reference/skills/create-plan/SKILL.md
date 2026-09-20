---
name: create-plan
description: Create vertical implementation plans with per-phase testing from a design document
model: opus
effort: xhigh
---

# Implementation Plan

You are tasked with creating detailed, vertical implementation plans from an approved design document. The design decisions are already made — your job is to translate them into actionable phases.

## Mark the herdr phase

As your very first action, tag this agent's herdr tab so the session navigator shows the workflow phase (safe no-op outside herdr):

```bash
bash "$(git rev-parse --show-toplevel)/.claude/scripts/herdr-phase.sh" plan
```

## Initial Response

When this command is invoked:

1. **Check if parameters were provided:**
   - If a design doc path was provided as $ARGUMENTS, read it FULLY
   - Also check for and read any referenced research docs or tickets
   - Begin the planning process

2. **If no parameters provided**, respond with:

   ```
   I'll help you create an implementation plan. Please provide:
   1. The design document (from /design-doc) — required
   2. Optionally, the research doc or ticket reference

   Tip: /create-plan .rpi/design-2026-01-05-auth-redesign.md
   ```

   Then wait for the user's input.

## Process

### Step 1: Context Gathering

1. **Read the design document FULLY** — this is your primary input
2. **Read any concrete reference artifact it links** — an HTML mockup, a schema diff, example request/response payloads. These are the spec; prefer them over the prose describing them.
3. **Read any referenced research docs and tickets**
4. **Spawn focused research agents if needed:**
   - Use **codebase-locator** to find specific files referenced in the design
   - Use **codebase-analyzer** to understand implementation details needed for planning
   - Only research what the design doc doesn't already cover
5. **Read all files identified by research agents**

### Step 2: Create Plan Outline

Present a high-level outline of vertical phases before writing the full plan:

```
Based on the design document, here's my proposed phasing:

Phase 1: [Name] — [What it accomplishes end-to-end]
  Testing: [How this phase will be verified]

Phase 2: [Name] — [What it accomplishes end-to-end]
  Testing: [How this phase will be verified]

Phase 3: [Name] — [What it accomplishes end-to-end]
  Testing: [How this phase will be verified]

Does this phasing make sense? Should I adjust?
```

Get user approval on the outline before writing the full plan.

### Step 3: Write the Plan

Write the plan to `.rpi/plan-YYYY-MM-DD-description.md`

**Filename format:** `plan-YYYY-MM-DD-[ENG-XXXX-]description.md`
- YYYY-MM-DD is today's date
- ENG-XXXX is the ticket number (omit if no ticket)
- description is a brief kebab-case description

**Use the template from `template.md` in this skill's directory.** The template defines the plan structure with vertical phases, per-phase verification, and design doc references. Adapt it to the specific project and feature.

### Step 4: Present and Iterate

```
I've created the implementation plan at:
`.rpi/plan-YYYY-MM-DD-description.md`

Please spot-check it — the design decisions are already aligned,
so this is about verifying the phasing and testing approach make sense.
```

Iterate based on feedback.

## Plan the smallest thing that works

Phases specify what gets built, so this is where speculative work gets locked in. Before specifying new code for a phase, check in order: does this codebase already have a helper, util, or pattern that covers it; does the standard library or the framework cover it; does an already-installed dependency cover it.

An interface with one implementation, a config value nobody sets, a layer with one caller, an abstraction for a second case that doesn't exist yet — all cheap to delete from a plan and expensive to delete from a merged PR. If the design implies one, put it under **What We're NOT Doing** and let the user overrule you.

## Vertical Phase Design

**Prefer vertical slices over horizontal layers.** A vertical slice is a phase where you can take a real action and validate a real assumption — not just create infrastructure that sits untested until later.

### The problem with horizontal phases:

```
Phase 1: Database schema + migrations
Phase 2: Service layer
Phase 3: API endpoints
Phase 4: Frontend UI
Phase 5: Tests
```

In this ordering, you can't really test Phase 1 in any meaningful way. You create a migration, but you won't discover the data model is wrong until Phase 4 when you try to render it in the UI. By then you've built 3 phases on top of a bad assumption.

### Vertical slices let you validate assumptions early:

**Example: Adding a dashboard feature**
```
Phase 1: UI with mocked data — validate the experience, confirm the data shape
         works for what you need to display. Testable: render the page, verify layout.
Phase 2: Background jobs that compute dashboard metrics — fully testable with
         unit/integration tests, no UI needed.
Phase 3: Wire up the data layer — load function pulls real data, replaces mocks.
         Testable: page renders with real data, metrics match expectations.
```

**Example: Adding a consensus algorithm**
```
Phase 1: Core algorithm with test harness — prove correctness under various
         scenarios. Testable: unit tests, property tests, edge cases.
Phase 2: Integration with the message transport layer — algorithm works over
         real network calls. Testable: integration tests with multiple nodes.
Phase 3: Admin UI and monitoring — trivial UI on top of working system.
         Testable: manual verification of dashboard.
```

### How to decide slice ordering:

1. **Start with the riskiest or most uncertain part** — wherever wrong assumptions will hurt most. That might be UI (data model risk) or backend (algorithmic complexity).
2. **Prefer slices the agent can verify itself** — things with automated tests, curl-able endpoints, or observable output. Save manual checkpoints for things that genuinely need human eyes (UX feel, visual design, business logic judgment calls).
3. **It's OK to use horizontal slices sometimes** — if a feature is straightforward and the data model is well-understood, doing the DB first and wiring up an API is fine. Vertical slices are a preference, not a religion. The goal is testability, not a specific ordering pattern.

### The test: can I take an action after this phase?

If a phase ends and the only thing you can do is "look at the migration file and hope it's right" — that's not a useful phase boundary. If a phase ends and you can render a page, run a test suite, or curl an endpoint — that's a good slice.

## Per-Phase Testing

**Testing is not a section at the bottom. It's part of every phase.**

Each phase's Verification section should specify:
- **The tests themselves** — real file paths and real test case names, drawn from the design doc's Testing Approach. "Add tests for the permission check" is a reminder; a file path with three named cases is a spec the implementing agent can execute against.
- What commands to run
- What "green" looks like — the concrete signal that this phase is working

Adapt the testing approach from the design doc:
- If the design says TDD: write failing tests first in the Changes Required section
- If the design says conformance testing: define the test suite as part of the phase
- If the design says manual testing: specify what to exercise and what to observe
- If the design doesn't specify: run whatever automated checks exist (lint, typecheck, build)

## The Completion Block

Every phase ends with an empty `### Completion` block that `/implement-plan` fills in when that phase finishes. Emit it for every phase, with the stub fields from the template and `Status: not started`. Don't fill any of it in yourself — you're writing a spec, not a record.

It exists because implementation phases are often run by separate agents with fresh context. The plan is the only thing all of them read, so it's where a finished phase leaves what the next one needs: what it actually built versus what this plan specified, what the user waived, and what a later phase now has to account for. Without the block, that knowledge lives only in the context of an agent that has already exited.

Keep it distinct from the review metadata `/implement-plan` writes alongside the plan. The split is by audience:

- **Completion block** — what changed *relative to the plan*. Read by the next phase, and by whoever revises the plan later.
- **Review metadata** — per-file Critical / Mechanical / Tests triage. Read by `/prepare-pr`.

The same fact rarely belongs in both.

**Never edit a filled-in `### Completion` block.** This holds for you, for a later agent, and for a hand edit. It's the record of what a finished phase actually did, often written by an agent that has since exited, and later phases read it as their only memory of earlier ones. If a change invalidates something a completed phase recorded, say so in the *new* phase's spec rather than rewriting history — a rewritten block is indistinguishable from a true one, and the next fresh agent will act on it.

## Revising an existing plan

Plans get revised mid-flight; that's normal and it isn't a separate phase. Edit the plan directly and keep it internally consistent:

- **A new phase** follows the existing phase pattern, including an empty `### Completion` block with `Status: not started`.
- **A scope change** updates "What We're NOT Doing" in the same pass.
- **An approach change** updates "Implementation Approach."
- **Completed phases are history.** Carry their Completion blocks across intact, even when restructuring around them.
- **A revision that changes what the interface shows goes back to `/design-doc`**, so the plan and its reference artifact can't disagree.

Edit surgically — preserve what doesn't need changing, keep `file:line` references accurate, and hold new content to the original's bar: specific paths, measurable criteria, real verification commands. Research only what the specific change requires; rewording a criterion or splitting a phase needs none.

## Important Guidelines

1. **Design decisions are already made** — Don't re-litigate. The design doc has the rationale.
2. **Keep it tactical** — This is for the implementing agent. File paths, code snippets, commands.
3. **Vertical slices** — Every phase must be independently testable.
4. **Per-phase testing** — No "Testing Strategy" section at the bottom.
5. **Shorter than v1 plans** — Design alignment is already done. Focus on the how, not the what or why.
6. **Spot-check, don't deep-review** — Tell the user to spot-check, not spend an hour reviewing.
7. **No open questions** — If something is unclear, go back to the design doc or ask. Batch clarifying questions into as few user turns as possible (`AskUserQuestion` takes up to 4 multiple-choice questions per call; use a consolidated text prompt for free-text).
