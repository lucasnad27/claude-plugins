---
name: implement-plan
description: Implement technical plans from .rpi/ with verification
model: opus
effort: xhigh
---

# Implement Plan

You are tasked with implementing an approved technical plan (`.rpi/plan-*.md`). These plans contain phases with specific changes and success criteria.

## Mark the herdr phase

As your very first action, tag this agent's herdr tab so the session navigator shows the workflow phase (safe no-op outside herdr):

```bash
bash "$(git rev-parse --show-toplevel)/.claude/scripts/herdr-phase.sh" implement
```

## Getting Started

When given a plan path:

- Read the plan completely and check for any existing checkmarks (- [x])
- Read the original ticket and all files mentioned in the plan
- Read any concrete reference artifact the design linked — an HTML mockup, schema diff, or example payloads. Build against the artifact, not against prose describing it.
- Think carefully and step-by-step about how the pieces fit together — the plan is the spec, but real code rarely matches the plan exactly
- Create a todo list to track your progress
- Start implementing if you understand what needs to be done

If no plan path provided, ask for one.

**This skill is designed for long-running autonomous execution.** The plan provides complete upfront context — phases, file paths, verification commands — so the implementing agent can work end-to-end without progressive guidance. Users running this skill should consider enabling auto mode (Shift+Tab) to cut cycle time on multi-phase implementations.

## Implementation Philosophy

Plans are carefully designed, but reality can be messy. Your job is to:

- Follow the plan's intent while adapting to what you find
- Implement each phase fully before moving to the next
- Verify your work makes sense in the broader codebase context
- Update checkboxes in the plan as you complete sections
- **Fix the root cause, not the symptom.** A phase that names a bug names a symptom. Before editing, check every caller of the function you're about to touch — one guard in the shared function is both the smaller diff and the real fix, where a guard per call site leaves every caller nobody filed a ticket about still broken.

## Testing-Aware Implementation

Before implementing each phase, read its Verification section and adapt your workflow:

**If the phase specifies TDD / red-green testing:**
1. Write the failing tests first
2. Run them to confirm they fail
3. Implement the minimum code to make them pass
4. Run tests again to confirm green
5. Refactor if needed, keeping tests green
6. Commit tests and implementation separately when practical — this makes the red-to-green progression visible in the diff

**If the phase specifies conformance testing:**
1. Generate the test suite that defines correct behavior
2. Run it to confirm it fails (the feature doesn't exist yet)
3. Implement against the test suite
4. Run tests until green

**If the phase specifies manual testing:**
1. Implement the phase
2. Exercise the work yourself — start a server, run curl commands, call the API
3. Report what you observed in your phase completion message
4. Include the commands you ran and their output

**If the phase has no specific testing approach:**
1. Implement the phase
2. Run whatever automated checks exist (lint, typecheck, build, existing tests)

The testing approach was decided in `/design-doc` and specified per-phase in `/create-plan`. Follow it — don't decide on a different approach.

## Comments: default to none

Implementing from a plan makes over-commenting easy: you finish a phase holding all the design rationale in context, and the reflex is to park it in the source. **The plan and the design doc are where rationale lives. The source is not.**

A comment has to survive two tests before you write it:

- **Would a competent developer reading this code be surprised?** Not "is this interesting" — *surprised*. A non-obvious constraint, a workaround for a library's actual behavior, a deliberate omission that looks like a bug. If the code plainly says what it does, say nothing.
- **Is it under three lines?** If it needs a paragraph, it's design rationale wearing a comment's clothes. Cut it to the single surprising fact, or leave it in the plan.

Do **not** write:

- **Narration** — "Fetch the user, then check the role." The call and the type already said that.
- **History** — "previously X, now Y", "moved here in Phase 2", "this used to live in `utils/`". Git and the plan hold history.
- **Symmetry notes** — "the read-only sibling of the helper above." Ambient structure, not a question.
- **Justification of the ordinary** — why you validated input, wrapped a multi-statement write in a transaction, or followed an established repo pattern. Following the convention is the default; it needs no defense.
- **Restated design decisions** — the reasoning chain for a choice already argued in the design doc. Keep the one-line verdict if the code looks wrong without it; drop the argument.

Do write, tersely:

```
// The unique index spans soft-removed rows, so a re-add has to clear the tombstone first.
```

That names a fact invisible in the code, which would cause a real bug if someone "simplified" it away.

A deliberate simplification with a known ceiling — a global lock, an O(n^2) scan over a list you're assuming stays small — belongs in the phase's `### Completion` block under **Waived or unproven**, where `/prepare-pr` will find it. Add a one-line comment at the call site *as well* only when the ceiling can't be seen from the code.

When a phase completes, re-read every comment you added in it and delete the ones that don't clear both bars. Comment fluff is cheaper to cut at the end of a phase than to argue about in review.

## The Completion Block

Each phase in the plan ends with a `### Completion` block that `/create-plan` left empty. **Fill in your phase's block before the pause message**, replacing the stub fields:

```markdown
### Completion
- **Status**: ✅ complete — 2026-08-06
- **Deviations**: extracted the guard into `lib/permissions.ts` instead of inlining it
  in the handler; the plan assumed one call site and there were three
- **Waived or unproven**: the audit-table write has no local sink, so the phase's tests
  cover the call but not the row landing
- **Later phases must know**: the guard now takes a `scope` argument, so Phase 3's
  endpoint list needs it too
```

Write `none` where a field genuinely has nothing, rather than deleting the field — a missing field reads as "the agent forgot," and `none` reads as "checked, nothing to report."

The next phase is likely a fresh agent with no memory of yours, and the plan is the only file it's guaranteed to read. Anything it needs from you goes here or it's gone.

Keep this distinct from the review metadata below. The split is by audience:

- **Completion block** — what changed *relative to the plan*. Read by the next phase, and by whoever revises the plan later. Once filled in it is a record — see `/create-plan`, "Revising an existing plan".
- **Review metadata** — per-file Critical / Mechanical / Tests triage. Read by `/prepare-pr`.

If a plan predates this convention and has no `### Completion` blocks, don't retrofit them mid-implementation — record the same information in your review-metadata section instead.

## Review Metadata (write silently — never surface it)

`/prepare-pr` needs a **per-file Critical / Mechanical / Tests triage** so it doesn't have to re-derive one from a large diff. That triage is only cheap to write while you still hold the reasoning for the code you just wrote — so it is built up **incrementally, at the end of every phase**, never reconstructed wholesale at the end.

**Write your section when the phase's automated checks pass, before the pause message.** Do this on every phase, including when you're running several back-to-back and skipping the intermediate pauses. Assume the next phase runs in a fresh context with no memory of yours: anything a later phase or `/prepare-pr` needs from you has to be on disk before you stop.

### Where it lives

Swap the plan's `plan-` prefix for `review-`:

```
.rpi/plan-YYYY-MM-DD-description.md
.rpi/review-YYYY-MM-DD-description.md
```

Same date and description, always — that's how a fresh agent finds the file without guessing. **Read it before you write.** If it exists, append your section with Edit and leave the earlier ones alone; never Write over a file that already has phases in it. If it doesn't exist, create it from `review-metadata-template.md` in this skill's directory.

### What each phase contributes

One `## Phase N — <title>` section covering **only the files that phase touched**:

- **Needs careful review** — `file.ext:45-89`, and what makes it load-bearing or security-sensitive. This is the part only you can write; an agent reading your diff later recovers it partially at best.
- **Mechanical** — the boilerplate a reviewer can skim: type mirrors, import moves, copy-only edits.
- **Tests** — what your phase's tests actually prove, and **what they don't**. If something can't be proven (an out-of-band sink, a flow with no local harness, a step the user waived), say so here so the PR states it plainly instead of implying proof.
- **Deliberate non-fixes** — anything known-imperfect you consciously left alone. It reads as an oversight in review unless the metadata says it was a decision.

Deviations go wherever they aren't already: if the plan carries a per-phase completion block, cross-reference it and pull forward only the deviations that change how a reviewer should read the diff. If it doesn't, record them here.

### On the last phase

After appending your own section, add a short `## Summary` — the cross-cutting reads no single phase owns: which files a reviewer should open first, what's left unproven across the whole change, and anything a later phase superseded in an earlier one.

### If an earlier phase left no section

Phases get skipped, and a plan can be resumed by an agent that never ran the earlier ones. Reconstruct what you can from the plan's completed-phase notes and `git diff`, and head each reconstructed section with `(reconstructed from the diff — not authored in-phase)`. That flag is the point: it tells `/prepare-pr` which triage came from the author and which from a reader.

### Never surface it

This file is plumbing between two skills, not a deliverable. **Do not mention it, offer it, or ask whether to write it** — not in phase-completion messages, not in the final summary, not as a follow-up suggestion. The user should never have to decide about it.

## Verification Approach

After implementing a phase:

- Run the success criteria checks (usually `make check test` covers everything)
- Fix any issues before proceeding
- Update your progress in both the plan and your todos
- Check off completed items in the plan file itself using Edit
- **Fill in the phase's `### Completion` block** — see "The Completion Block" above
- **Pause for human verification**: After completing all automated verification for a phase, pause and inform the human that the phase is ready for manual testing. Use this format:

  ```
  Phase [N] Complete - Ready for Manual Verification

  Automated verification passed:
  - [List automated checks that passed]

  Please perform the manual verification steps listed in the plan:
  - [List manual verification items from the plan]

  Let me know when manual testing is complete so I can proceed to Phase [N+1].
  ```

If instructed to execute multiple phases consecutively, skip the pause until the last phase. Otherwise, assume you are just doing one phase.

do not check off items in the manual testing steps until confirmed by the user.

## When Things Don't Match the Plan

When things don't match the plan exactly:

- **Small deviations** (function signature changed, slightly different file path): Record it where the Review Metadata section says deviations go, and keep going. Mention it in your phase completion message.
- **Structural deviations** (approach won't work, missing dependency, wrong assumption): STOP and present the issue clearly:

  ```
  Issue in Phase [N]:
  Expected: [what the plan says]
  Found: [actual situation]
  Why this matters: [explanation]
  Shape: [when the fix changes structure: the plan's call tree or file tree as a diff,
         `-` for what the plan assumed, `+` for what the code needs]

  Options:
  1. Adapt and continue (if the change is contained)
  2. Revise the plan, then continue against the revised version
  ```

The plan is your guide, but your judgment matters. Small adaptations are fine. Structural changes need alignment.

## If You Get Stuck

When something isn't working as expected:

- First, make sure you've read and understood all the relevant code
- Consider if the codebase has evolved since the plan was written
- Present the mismatch clearly and ask for guidance

Use sub-tasks sparingly - mainly for targeted debugging or exploring unfamiliar territory.

## Resuming Work

If the plan has existing checkmarks:

- Trust that completed work is done
- Pick up from the first unchecked item
- Verify previous work only if something seems off
- Read the review-metadata file (the plan's name with `plan-` swapped for `review-`) to see which phases have already contributed a triage section — you append to it, you don't restart it

Remember: You're implementing a solution, not just checking boxes. Keep the end goal in mind and maintain forward momentum.
