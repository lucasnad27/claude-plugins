---
name: setup
description: Generate project-specific research/plan/implement workflow by analyzing your project and intelligently adapting reference templates
---

# Setup Research-Plan-Implement Workflow

This skill analyzes a project's language, framework, and tooling, then adapts the reference templates into customized skills and agents in the project's `.claude/` directory.

Supporting references in this skill's directory (`${CLAUDE_SKILL_DIR}`) — read each when you reach the step that needs it, not upfront:

- **`detection.md`** — what to read, what to extract, how to fill gaps (Steps 1-2)
- **`adaptation.md`** — how to adapt each template: what must survive, what register to write in, where to use judgment (Step 5)
- **`upgrade.md`** — upgrading an existing install: telling a user's customizations apart from stale template, and the migration paths
- **`scripts/strip-copilot-frontmatter.sh`** — run over the generated tree when VS Code is a target (Step 6); a setup-time tool, not copied into the project

## Before You Start

This skill carries no `model:` or `effort:` frontmatter, for the same reason it strips
those fields from what it generates: a `model:` key hangs VS Code Copilot chat on
invocation, and this skill has to be runnable in both editors. It reads a whole codebase
and writes fifteen files, so it wants a capable model at high effort — if the session is
on something small, say so and let the user switch before Step 1.

Recommend the user create a branch first, so they can review the generated files as a diff:

```
Tip: I recommend creating a branch before we set up the workflow — that way
you can review the generated files as a diff before merging them into your project.

  git checkout -b setup-rpi-workflow
```

If they're already on a feature branch, that's fine — just make sure they know setup will create files in `.claude/`.

## Step 1: Analyze the project

Read `detection.md`, then inspect the project: language, framework, package manager, test/lint/format/build/typecheck commands, database tooling, issue tracker, and where workflow artifacts should live.

Present what you found, marking anything you couldn't determine.

**Then check for an existing installation** (see `detection.md`). If one exists, switch to `upgrade.md` instead of continuing here.

## Step 2: Fill in the gaps

Ask for whatever you couldn't detect, batched into as few turns as possible — see `detection.md` for the batching approach. Then present the complete configuration and confirm it before generating anything.

## Step 3: Ask preferences

1. **Artifacts directory** — where research, designs, plans, and review metadata get written. Default to `.rpi/`; state it rather than asking an open question, and let them name a different root if they want one. It's flat: the type is the filename's last segment (`-research`, `-design`, `-plan`, `-review`), so nothing nests. Don't offer to customize the naming.
2. **Additional commands** — any custom verification commands or project-specific testing notes to fold in?
3. **Gitignore** — recommend ignoring the artifacts root: these are working notes, not source, and keeping them out of git keeps PRs clean. One line, `.rpi/`. If artifacts are already tracked, offer `git rm --cached -r .rpi/` to untrack without deleting.
4. **Copilot compatibility** — one yes/no question: *will these files ever be opened in VS Code Copilot chat, by them or a teammate?* Lead with the answer `detection.md` prefilled and let them correct it; don't ask it open-ended.

   Ask it about the **repository, not this machine**. The generated files get committed, so the person running setup isn't necessarily the person who opens them — a repo generated in Claude Code and later opened in Copilot by a teammate is exactly the case this protects. If they aren't sure, yes is the safer answer.

   Yes strips `model:` and `effort:` from every generated skill and agent, because a skill carrying `model:` hangs Copilot chat until VS Code is restarted (see `adaptation.md`), and writes `.vscode/settings.json`. No keeps both fields and the per-skill model pinning they buy — research and planning on opus at high effort, `/guide` on haiku. Say what yes costs before they answer: in Copilot every skill runs on whatever model is selected in chat, and there's no per-skill override.

   There is no third answer. "Both editors" produces the same files as "Copilot only" — once Copilot is anywhere in the picture the fields have to go, so the question is binary by construction.
5. **Confirm** — ready to generate?

## Step 4: Read the reference templates

All paths below are relative to this skill's directory (`${CLAUDE_SKILL_DIR}`), not the target project.

**Skills** (`reference/skills/*/SKILL.md`): research-codebase, design-doc, create-plan, implement-plan, prepare-pr, guide

**Agents** (`reference/agents/*.md`): codebase-analyzer, codebase-locator, codebase-pattern-finder, query-planner, web-search-researcher, artifact-locator, artifact-analyzer

**Conditional agent:** branch-ticket-detector — only if an issue tracker is configured

**Script:** `reference/scripts/herdr-phase.sh` — copied verbatim, never adapted

Some skill directories also carry a sibling file — `template.md`, `review-metadata-template.md`, `topics.md`, `tuicr-walkthrough.md`. These are progressive-disclosure files the generated skill loads on demand — copy them alongside their SKILL.md.

## Step 5: Adapt each template

Read `adaptation.md` and work through the templates. The core of this skill is here: adapt by understanding what the project needs, not by substituting strings.

## Step 6: Write the files

```
.claude/
├── skills/
│   ├── research-codebase/SKILL.md
│   ├── design-doc/SKILL.md + template.md
│   ├── create-plan/SKILL.md + template.md
│   ├── implement-plan/SKILL.md + review-metadata-template.md
│   ├── prepare-pr/SKILL.md + tuicr-walkthrough.md
│   └── guide/SKILL.md + topics.md
├── scripts/
│   └── herdr-phase.sh                # verbatim, chmod +x
└── agents/
    ├── codebase-analyzer.md
    ├── codebase-locator.md
    ├── codebase-pattern-finder.md
    ├── query-planner.md
    ├── web-search-researcher.md
    ├── artifact-locator.md
    ├── artifact-analyzer.md
    └── branch-ticket-detector.md     # if an issue tracker is configured
```

If Step 3's Copilot question was answered yes, two things change — both covered in `adaptation.md`:

1. **Strip `model:` and `effort:`** from every generated `SKILL.md` and agent file. Don't do this by hand while writing them — write the files normally, then run the script over the whole tree from the project root:

   ```bash
   bash "${CLAUDE_SKILL_DIR}/scripts/strip-copilot-frontmatter.sh"
   ```

   It edits only the leading frontmatter block, is idempotent, and re-scans afterwards to prove no field survived. A non-zero exit means a file is still carrying one — stop and fix it before telling the user setup succeeded. This is non-negotiable and mechanical for a reason: a single missed `model:` hangs Copilot chat on invocation, and recovery is a full VS Code restart.

2. **Merge** `"chat.useAgentSkills": true` into `.vscode/settings.json`.

Write `.claude/.rpi-version` alongside them (see `upgrade.md` for what reads it):

```
version: [the "version" field from ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json]
generated: YYYY-MM-DD
```

The phase skills invoke the script via `"$(git rev-parse --show-toplevel)/.claude/scripts/herdr-phase.sh"`, so it resolves from any working directory and propagates to every worktree.

## Step 7: Present the summary

```
Created research-design-plan-implement workflow in .claude/

Generated files:
- 6 skills: /research-codebase, /design-doc, /create-plan, /implement-plan, /prepare-pr, /guide
- [N] agents: query-planner, codebase-locator, codebase-analyzer, pattern-finder, web-search-researcher, artifact-locator, artifact-analyzer[, branch-ticket-detector]
- 1 settings merge: .vscode/settings.json — chat.useAgentSkills (only if VS Code Copilot is a target)
- model:/effort: frontmatter — [kept for Claude Code | stripped, since VS Code Copilot is a target]
- 1 script: scripts/herdr-phase.sh — tags each tab with its workflow phase in the herdr sidebar (no-op outside herdr; run /guide herdr to learn more)

Adapted for your project:
- Test command: [detected command]
- Lint command: [detected command]
- Format command: [detected command]
- Build command: [detected command]
- Database: [detected tool and commands]
- Issue tracking: [detected system]
- Artifacts directory: [chosen root] (flat; type is the filename suffix)

Workflow:
  /research-codebase -> /design-doc -> /create-plan -> /implement-plan -> /prepare-pr
  /guide (run anytime for orientation)

Quick start:
  /research-codebase "How does authentication work?"
  /design-doc .rpi/2026-01-05-auth-flow-research.md
  /create-plan .rpi/2026-01-05-auth-redesign-design.md
  /implement-plan .rpi/2026-01-05-auth-redesign-plan.md
  /prepare-pr

These files are yours now — edit them freely as you learn what your team needs.
```

## Step 8: Show workflow quick tips

```
Understanding the Research -> Design -> Plan -> Implement -> Review Workflow

This workflow uses "INTENTIONAL COMPACTION" to manage context windows:

RESEARCH (/research-codebase)
   Explores codebase without polluting main context
   Sub-agents handle messy file discovery
   Output: Clean research document with findings

DESIGN (/design-doc)
   Lightweight ~200-line alignment artifact
   Captures: current state, desired end state, patterns, testing approach
   This is your highest-leverage review moment
   Output: Design discussion document

PLAN (/create-plan)
   Takes design as input — decisions already made
   Vertical phases (end-to-end slices, not horizontal layers)
   Per-phase testing baked in
   Output: Tactical implementation plan

IMPLEMENT (/implement-plan)
   Testing-aware: follows the testing approach from design/plan
   Generates review metadata as it goes
   Phase-by-phase with verification checkpoints

REVIEW (/prepare-pr)
   Commits outstanding work and opens the PR
   Lands a numbered review guide: a short index in the description,
   the detail as inline comments anchored to the diff
   Optionally walks the PR with you in tuicr, stop by stop

ORIENTATION (/guide)
   Run anytime to see where you are and what's next

Key Success Factors:
  Always research before designing
  Design is your highest-leverage review moment
  Plans use vertical slices with per-phase testing
  Run /prepare-pr to commit, open the PR, and land the review guide as inline stops
  Run /guide if you forget where you are

Attribution:
  Inspired by HumanLayer's research on AI-assisted development
  Informed by talks from Dex (CRISPY) and Simon Willison (TDD/conformance)
  Reuse-before-writing, root-cause-over-symptom, and the yagni stop type
    adapted from ponytail (MIT) - github.com/DietrichGebert/ponytail
  Website: humanlayer.dev
  GitHub: github.com/humanlayer/humanlayer
```

## Step 9: Create the artifacts directory

`mkdir -p` the chosen root if it doesn't exist. There's nothing to create inside it — the skills write flat files named for their type:

```
.rpi/
├── 2026-01-05-auth-research.md
├── 2026-01-05-auth-design.md
├── 2026-01-05-auth-design.html      # optional mockup from /design-doc
├── 2026-01-05-auth-plan.md
└── 2026-01-05-auth-review.md
```

## Success criteria

The setup worked when the project analysis was accurate, the user's preferences were captured, every template was adapted to this project's real tooling, the files are in `.claude/`, and the user knows what to run next.

The generated workflow should feel native to the project — not like a generic template forced to fit.
