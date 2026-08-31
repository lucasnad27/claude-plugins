---
name: guide
description: Contextual workflow orientation — where you are, what's next, and topic-based deep dives
model: haiku
effort: low
allowed-tools: Bash Glob
---

# Workflow Guide

You provide contextual orientation for the research-design-plan-implement workflow.

**Two modes:**
- `/guide` (no args) → Short orientation: where am I, what's next? (5-10 lines max)
- `/guide [topic]` → Deep dive on a specific topic (see `topics.md` in this skill's directory)

## Mode 1: Orientation (no args)

### Current Workspace State

Recent research docs:
!`ls -lt .rpi 2>/dev/null | grep -E -- '-research\.md$' | head -3`

Recent design docs:
!`ls -lt .rpi 2>/dev/null | grep -E -- '-design\.md$' | head -3`

Recent plan docs:
!`ls -lt .rpi 2>/dev/null | grep -E -- '-plan\.md$' | head -3`

Git status:
!`git status --short 2>/dev/null`

PR status:
!`gh pr status 2>/dev/null | head -5`

### Determine Current Phase

Based on the workspace state above:

- No artifacts → **Getting started**
- Research doc exists, no design → **Ready for design**
- Design doc exists, no plan → **Ready for planning**
- Plan doc exists, some phases incomplete → **In implementation**
- Plan doc with all phases complete → **Ready for review**
- Open PR → **In review**

### Output Format

Respond with ONLY this format:

```
**[Current phase]**
[Most relevant artifact with path]
Next: [What to do next with the specific command]
Tip: [One-line tip relevant to current phase]
```

### Phase-Specific Tips

- **Getting started:** "Start with /research-codebase to explore the area you'll be working in."
- **Ready for design:** "This is your highest-leverage review moment — corrections here save hundreds of lines of rework."
- **Ready for planning:** "/create-plan takes your design and produces vertical phases with per-phase testing."
- **In implementation:** "Each phase should be testable on its own. If it's not, the plan may need vertical restructuring."
- **Ready for review:** "Run /prepare-pr to commit, open the PR, and land a numbered review guide — a short index in the description, the detail as inline comments on the diff."
- **In review:** "Each stop is a resolvable thread; resolving one ticks it off. Point /prepare-pr at an existing PR number to write a guide onto a PR opened outside the loop."

### Orientation Rules

- **5-10 lines max** — This is orientation, not a tutorial
- **Show the most recent relevant artifact** — Not all of them
- **One tip only** — Relevant to where they are right now
- **Don't explain the workflow** — Just show where they are and what's next
- **If artifacts are ambiguous**, show the most recent and mention others exist

## Mode 2: Topic Deep Dive (with args)

If $ARGUMENTS is provided, it's a topic name. Read `topics.md` in this skill's directory and present the content for that topic.

**Available topics:** overview, research, design, plan, implement, review, herdr, copilot, context, patterns, tips, examples

Topics are named for the *phase*, so a skill name is an accepted alias — `design-doc` → `design`, `research-codebase` → `research`, `create-plan` → `plan`, `implement-plan` → `implement`, `prepare-pr` → `review`. Resolve the alias and show the topic; don't make the user guess again.

If the topic still isn't recognized, show the list of available topics.
