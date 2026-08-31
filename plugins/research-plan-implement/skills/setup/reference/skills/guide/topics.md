# Guide Topics

Present the content for the requested topic. Keep it practical and scannable.

## Topic: overview

### The Workflow

```
/research-codebase → /design-doc → /create-plan → /implement-plan → /prepare-pr
                                /guide (run anytime)
```

Running inside herdr, each phase skill tags its tab (🔬 🎨 📋 🔨 🔍) so the sidebar shows where every feature sits in the pipeline. See `/guide herdr`.

This workflow uses **intentional compaction** — periodically pausing work and distilling progress into structured artifacts (research docs, designs, plans) before starting fresh context windows.

**Why it matters:** Your context window is the ONLY lever you have to affect output quality without retraining models.

**The five phases:**

1. **Research** (`/research-codebase`) — Explore the codebase. Sub-agents do the messy file discovery. Output: clean research document. Run it with no arguments and it detects the ticket from your current branch and researches against that.
2. **Design** (`/design-doc`) — ~200-line alignment artifact. Current state, desired end state, patterns, testing approach. Your highest-leverage review moment.
3. **Plan** (`/create-plan`) — Vertical implementation phases with per-phase testing. Takes the design as input — decisions are already made.
4. **Implement** (`/implement-plan`) — Testing-aware, phase-by-phase execution. Generates review metadata as it goes.
5. **Review** (`/prepare-pr`) — Commit, open the PR, and land a numbered review guide: a short index in the description, the detail as inline comments anchored to the diff. Can also write a guide onto a PR opened outside the loop.

**Strategic human review points:**

| Phase | Your Role | Impact |
|-------|-----------|--------|
| Design | Correct agent's thinking early | Prevents hundreds of lines of wrong code |
| Research | Validate findings are accurate | Prevents cascading errors |
| Planning | Review phasing and testing | Bad plan → bad implementation |
| Implementation | Manual testing between phases | Catch issues before they compound |
| Review | Focus on critical sections | Fast, targeted PR reviews |

**Real-world results:**
- 300k LOC Rust codebase: 1-hour bug fix by non-expert, PR approved without revision
- 35k LOC feature: 7 hours vs 3-5 days estimated, minimal PR revisions

## Topic: research

### Research Phase Deep Dive

**Purpose:** Thoroughly explore the codebase before making any design or implementation decisions.

**When to research:**
- Before starting any new feature
- Before fixing complex bugs
- Before refactoring
- When you don't understand how something works
- Even for "simple" tasks (prevents assumptions)

**What good research looks like:**
- Specific file paths with line numbers
- Explanation of data flow
- Identification of existing patterns (including test patterns)
- Examples of similar implementations
- Edge cases and gotchas discovered

**What bad research looks like:**
- Vague descriptions without file references
- Assumptions instead of verified facts
- Missing edge cases
- No examples of existing patterns
- Surface-level understanding

**Best practices:**
- Be specific in your research question
- Review the research document before designing
- Ask follow-up questions if unclear
- Validate findings match your understanding
- Look for multiple examples of patterns

## Topic: design

### Design Phase Deep Dive

**Purpose:** Create a lightweight alignment artifact before the full plan. Corrections here prevent hundreds of lines of wrong code.

**When to design:**
- After research, before planning
- For any non-trivial feature or change
- When you want to validate your understanding with the agent

**What a good design looks like:**
- ~200 lines (not 1000)
- Current state and desired end state clearly stated
- Patterns to follow explicitly called out
- A concrete reference artifact wherever the work has a shape worth rendering — a
  self-contained HTML mockup for UI, real request/response payloads for an API, a
  schema diff for a data model change
- Testing approach decided (not deferred to planning)
- Key decisions documented with rationale
- Scope boundaries defined (what we're NOT doing)
- All open questions resolved

**What a bad design looks like:**
- Just a restated ticket
- Walks through the file-by-file changes — that's `/create-plan`'s job
- No testing approach
- Unresolved questions left in the doc
- Patterns not specified (agent will pick wrong ones)

**Best practices:**
- Read the research doc before starting
- Pay attention to "Patterns to Follow" — this is where you correct the agent
- Review the concrete reference artifact, not the prose describing it — a mockup
  settles layout and states in one pass, and the implementing agent builds against it
- The testing approach should match your project's actual infrastructure
- Use this as a shareable artifact — send to teammates for quick alignment

## Topic: plan

### Planning Phase Deep Dive

**Purpose:** Create a detailed spec that guides implementation. Design decisions are already made — this focuses on execution order and verification.

**What makes a good plan:**
- Specific file paths and line numbers
- Code examples showing the pattern
- Vertical phases (each delivers working, testable functionality)
- Per-phase testing aligned with the design's testing approach
- No open questions or "TBD" items

**What makes a bad plan:**
- Vague instructions like "implement feature X"
- Horizontal layers (all DB, then all API, then all UI)
- Testing deferred to a bottom section instead of per-phase
- Unresolved questions

**Planning workflow:**
1. Read the design document
2. Break into vertical phases (each delivers working functionality)
3. Add per-phase testing based on the design's testing approach
4. Detail each phase with specifics
5. Define success criteria per phase
6. Get approval — spot-check, not deep-review

## Topic: implement

### Implementation Phase Deep Dive

**Purpose:** Execute the plan with testing-aware implementation and verification at each step.

**Workflow:**
1. Read entire plan first
2. Implement Phase 1 completely (vertical slice)
3. Run per-phase tests as specified
4. Run automated verification
5. Pause for manual testing
6. Get confirmation, mark phase complete
7. Proceed to Phase 2

**Testing-aware implementation:**
- Follow the testing approach from the design doc
- Write tests as part of each phase, not after all phases
- Per-phase testing ensures each slice works before moving on
- Use the project's actual test infrastructure

**When to pause:**
- After each phase completes
- When context > 70% utilized
- When encountering unexpected complexity
- When tests are failing and unclear why
- When plan needs significant changes

**Resuming across sessions:**
1. Update plan with current status (checkboxes)
2. Start fresh context with the plan
3. Implementation picks up from last completed phase

## Topic: review

### Review Phase Deep Dive

**Purpose:** Make reviewing a large PR fast and focused, by saying where to look — anchored to the lines it's about.

**When to use it:**
- After implementation is complete — to commit and open the PR
- When a PR already exists and just needs a guide (pass the PR number)
- When preparing a PR for a coworker's branch

**The review guide is a numbered list of stops.** A stop is a file, a line or range, a type, and a *claim to test* — not a description of what the code does. The reviewer can already see the code; what they can't see is what you want them to decide.

One artifact, three places it appears:
- **Inline review comments on the PR** — the detail, anchored to the line. Each is a resolvable thread, so reviewers tick stops off as they go.
- **A numbered index in the PR description** — one line per stop, so the guide reads without opening the diff.
- **A tuicr session**, if you walk it — GitHub review threads render natively in `tuicr pr <n>`, so a posted guide needs no seeding.

**Stop types:** `issue` (you believe something is wrong), `note` (verify this is correct), `suggestion` (decide whether you accept this), `yagni` (an abstraction with one caller that could be inlined until it has two).

**Best practices:**
- 6-10 stops for a typical PR. Fewer than 4 isn't guiding; more than 12 emphasizes nothing.
- Keep the description under 60 lines. If it's longer, the detail belongs in a stop.
- Mechanical files get one line, not an inventory. A reviewer who wants the file list opens the Files tab.
- Walk the PR with the author before anyone else is asked to look — findings become commits on the open PR.
- If something critical is untested, say so under **Not tested** rather than implying proof.

**Flags:** `--no-stops` keeps the whole guide in the description (use on forges without inline review comments); `--walk` / `--no-walk` forces or suppresses the tuicr walkthrough.

## Topic: context

### Context Window Management

**Why context matters:** Your context window is the ONLY lever you have to affect AI output quality without retraining models.

**Optimization hierarchy:**
1. **Incorrect information** (most damaging) — wrong file paths, outdated code, false assumptions
2. **Missing information** — incomplete understanding, missing edge cases
3. **Excessive noise** — file search results, debug logs, tool outputs

**Target utilization: 40-60%**
- Greenfield features: 40-50% (need room for exploration)
- Bug fixes: 50-60% (more focused)
- Complex refactoring: 40% (lots of discovery)

**When to start fresh context:**
- Moving between phases (research → design → plan → implement)
- Completing a major implementation phase
- Context utilization > 70%
- Conversation became noisy with debugging

**What to carry forward:**
- Load the research/design/plan documents
- Reference specific findings
- Don't copy entire conversation history

**What gets compacted:**
- File search results → Research document
- Design discussion → Design document
- Implementation progress → Plan document (checkboxes)
- Debugging session → Updated plan

## Topic: patterns

### Common Workflow Patterns

**Greenfield Feature:**
```bash
/research-codebase "How are similar features implemented?"
/design-doc .rpi/2026-01-05-feature-research.md
/create-plan .rpi/2026-01-05-feature-design.md
/implement-plan .rpi/2026-01-05-feature-plan.md
/prepare-pr
```

**Bug Fix:**
```bash
/research-codebase "Why is X failing?"
/design-doc .rpi/2026-01-05-bug-research.md
/create-plan .rpi/2026-01-05-bug-design.md
/implement-plan .rpi/2026-01-05-bug-plan.md
/prepare-pr
```

**Refactoring:**
```bash
/research-codebase "How does module X work currently?"
/design-doc .rpi/2026-01-05-refactor-research.md
/create-plan .rpi/2026-01-05-refactor-design.md
/implement-plan .rpi/2026-01-05-refactor-plan.md
/prepare-pr
```

**Multi-Day Feature:**
```bash
# Day 1: Research, design, plan
/research-codebase "How should feature X integrate?"
/design-doc .rpi/2026-01-05-feature-research.md
/create-plan .rpi/2026-01-05-feature-design.md

# Day 2+: Implement (resumes from last checkpoint)
/implement-plan .rpi/2026-01-05-feature-plan.md

# Final: Review
/prepare-pr
```

**Revising a Plan:** edit it directly — there's no separate command. Keep it consistent (new phases get an empty `### Completion` block; a scope change updates "What We're NOT Doing") and leave completed phases' Completion blocks alone.

## Topic: tips

### Best Practices by Phase

**Research:**
- Be specific in questions
- Validate findings before designing
- Look for multiple pattern examples
- Include file:line references
- Don't skip research for "simple" tasks

**Design:**
- Keep it to ~200 lines
- Decide testing approach here, not later
- Explicitly call out patterns to follow
- Resolve all open questions
- Define what's NOT in scope

**Planning:**
- Include specific file paths
- Create vertical phases (testable slices)
- Include per-phase testing
- Resolve all questions before finalizing
- Don't write horizontal layers

**Implementation:**
- Complete one vertical phase at a time
- Run per-phase tests between phases
- Update checkboxes in plan
- Don't skip manual testing
- If blocked, update the plan — don't diverge

**Review:**
- Run /prepare-pr to commit, open the PR, and land the review guide as inline stops
- Focus on "Critical Review" sections
- Check the test coverage map
- Pass an existing PR number to refresh its description

**Context Management:**
- Keep utilization 40-60%
- Compact into documents
- Start fresh contexts between phases
- Carry forward key documents, not conversation history

**Driving the agent:**
- Treat it as a delegated engineer — give it complete context upfront rather than
  steering turn-by-turn. The research, design, and plan artifacts exist to make that
  possible; a good plan is what lets implementation run unattended.
- `/implement-plan` is the ideal auto-mode candidate (Shift+Tab to toggle) — the plan
  already carries the phases, file paths, and verification commands it needs
- Research is supposed to fan out. If it's drilling one question at a time instead of
  spawning subagents in parallel, say so explicitly.
- Reasoning effort is per-skill, in each SKILL.md's `effort:` frontmatter — the phase
  skills ship at `xhigh`, `/guide` at `low`. If a phase consistently under-thinks, raise
  that skill's effort rather than re-prompting every run.

## Topic: examples

### Real-World Success Stories

**300k LOC Rust Codebase:**
- Task: Fix a bug in large Rust codebase
- Developer: Non-expert in the codebase
- Time: 1 hour total
- Result: PR approved without revision
- Key lesson: Brownfield codebases are approachable with proper research

**Complex Feature (35k LOC):**
- Task: Add cancellation support + WASM compilation
- Estimated time: 3-5 days per senior engineer
- Actual time: 7 hours (3 research/planning, 4 implementation)
- Result: Both PRs completed with minimal revision
- Key lesson: Research time pays off exponentially

**Failure Case — Hadoop Dependencies:**
- Task: Remove dependencies from Parquet Java
- Issue: Insufficient dependency tree exploration
- Result: Failed to complete task
- Key lesson: Domain expertise matters; research depth requires adequate effort

## Topic: herdr

### Phase Markers in the herdr Sidebar

When you run inside [herdr](https://herdr.dev), each phase skill tags its own tab so the session navigator doubles as a milestone board — every tab shows both its feature and where it is in the pipeline.

**Two independent dimensions:**

| Dimension | Who sets it | What you see |
|-----------|-------------|--------------|
| **State** | herdr (auto) | working / done / idle / blocked status icon |
| **Phase** | these skills | 🔬 🎨 📋 🔨 🔍 prefix on the tab label |

**Glyphs:** 🔬 research · 🎨 design · 📋 plan · 🔨 implement · 🔍 review

**How it works:** each phase skill (`/research-codebase`, `/design-doc`, `/create-plan`, `/implement-plan`, `/prepare-pr`) runs `.claude/scripts/herdr-phase.sh <phase>` as its first action. It rewrites *this tab's* label, swapping any prior phase glyph for the new one — so `336-global-sidebar` becomes `🎨 336-global-sidebar` during design, then `🔨 336-global-sidebar` during implementation. It persists until the next phase skill overwrites it.

**Manual override** — set or clear a tab's phase without invoking a skill:

```bash
bash .claude/scripts/herdr-phase.sh review   # force the review marker
bash .claude/scripts/herdr-phase.sh clear    # strip the marker, keep the feature name
```

**Notes:**
- Safe no-op outside herdr (CI, plain terminals, headless agents) — nothing to configure.
- Each worktree picks this up once its branch contains the script + skill changes.

## Topic: copilot

### Running This Workflow in VS Code Copilot Chat

VS Code scans `.claude/skills/` and `.claude/agents/` alongside its own `.github/` equivalents, so there is nothing to port and nothing to keep in sync. One difference in the generated files matters, and it is not cosmetic.

**Skills must not carry `model:` or `effort:`.**

A skill whose frontmatter includes `model:` hangs Copilot chat the moment it is invoked — no output, no error, and every later command in that session is dead until VS Code is restarted. The key triggers it whatever the value: a Copilot-format id like `'Claude Opus 4.5 (copilot)'` hangs the same way `opus` does. VS Code's SKILL.md spec documents only `name`, `description`, `argument-hint`, `user-invocable`, and `disable-model-invocation`.

Setup strips both fields when its Copilot question is answered yes, so a workflow generated that way is already correct. If yours came from an install generated before that question existed and `/research-codebase` hangs, that's this bug — re-run setup's upgrade path, or delete the two lines from each `.claude/skills/*/SKILL.md` by hand.

What you give up is per-skill model pinning. In Claude Code these templates pin research and planning to opus at high effort and `/guide` to haiku; in Copilot every skill runs on whichever model you have selected in chat. Pick the model yourself before starting a research or planning pass.

**Enable it** — one setting, in workspace or user settings:

```json
{ "chat.useAgentSkills": true }
```

Current VS Code documents `chat.agentSkillsLocations` instead and lists `.claude/skills` among its defaults, with skills on by default since 1.109 — so on a current build you may need no setting at all. Type `/` in the chat input; the phase skills appear as slash commands, the same as in Claude Code.

**Nested subagents** are off by default (`chat.subagents.allowInvocationsFromSubagents`). This workflow never needs them — a phase skill spawning research agents is one level deep.

### What is still unverified

An earlier version of this guide published a frontmatter mapping table — `model: opus` becoming Claude Opus, `Bash` becoming `execute`, and so on — and stated that unknown keys "sit inert rather than erroring." The hang above disproves the last part, and the table was never sourced from documented behaviour. Two related questions are open:

- Whether VS Code translates Claude tool names (`Bash`, `Grep`, `Read`, `Task`) in an agent's `tools:` list. Its own agent examples use names like `['read', 'search', 'web']`. A wrong tool name should degrade an agent rather than hang it.
- Whether a bare `model: sonnet` on an agent hangs it the way it hangs a skill. VS Code does support `model:` on custom agents, but expects ids like `'Claude Sonnet 4.5 (copilot)'`. Until this is settled, setup strips the field from agents too when Copilot is a target.

If you hit a hang this topic doesn't explain, open **Chat view → Diagnostics** — it lists every loaded customization file with its status and any load errors.

## Attribution

This workflow is inspired by **HumanLayer's** research on AI-assisted development, with additional influences from **CRISPY/Dex** (design-before-planning, instruction budgets) and **Simon Willison** (TDD, conformance-driven development).

- [humanlayer.dev](https://humanlayer.dev)
- [humanlayer/humanlayer](https://github.com/humanlayer/humanlayer)
- [AI Engineering Talk](https://youtu.be/rmvDxxNubIg?si=WtKgAdi6MydW8u-i)
