# Template Adaptation

Reference for Step 5 of the setup skill.

Adapt each template by reasoning about what the project actually needs — read the template fully, find every project-specific reference, and rewrite those sections. Preserve the workflow logic and agent behaviors; change the tooling around them.

## What varies by project

**Commands.** Every `npm run test:unit`, `npm run lint`, `npm run format`, `npm run build`, and database command in the templates is a placeholder for whatever this project actually uses. Replace them with the detected commands, including in checklists and verification sections.

**Commit convention.** `/prepare-pr`'s commit step carries `[CONVENTION]` and `[EXAMPLE]` markers. Replace both with what detection found, keeping the example a real subject line from this repo's history rather than an invented one. When detection found no convention — or subjects that disagree — write `no fixed convention; match the surrounding history` and delete the `, e.g. ...` clause rather than falling back to Conventional Commits, which is the guess this whole step exists to prevent. A bracket left in place ships as prose and will be read as an instruction.

**Directory structure.** Adjust paths to the project's layout — `src/` vs `pkg/`/`internal/`, `tests/` vs `__tests__/`, framework-specific trees like `src/routes/`.

**Framework guidance.** Where a template gives framework-specific advice, replace it with advice for the detected framework — SvelteKit load functions and form actions, Django models/views/urls, Next.js app router and server actions, Axum extractors and response types. Keep it generic if no framework is detected.

**Database workflow.** Include the detected tool's develop-then-migrate cycle (Prisma `db push` → `migrate dev`, Django `makemigrations` → `migrate`, Alembic revisions, Diesel migrations). Remove database sections entirely if there's no database.

**Artifacts directory.** The templates write to `.rpi/`, flat, with the type as the filename's last segment — `YYYY-MM-DD-[TICKET-]description-{research,design,plan,review}.md`. If the user chose a different root, rewrite every occurrence: the `ls -lt .rpi/*-plan.md` commands in `guide/SKILL.md`, the example paths in `guide/topics.md`, and the `path: ".rpi"` search scope in `artifact-locator`. The naming convention itself doesn't change — `/implement-plan` and `/prepare-pr` find the review metadata by swapping a plan's `-plan` suffix for `-review`, and that only works if both ends agree.

**Forge.** `/prepare-pr` posts its review guide as inline comments on a GitHub pull request via `gh api`. On GitLab, Azure DevOps, or anywhere without `gh`, strip Step 6 and the tuicr PR-mode material, and make `--no-stops` behavior the default: the numbered guide stays in the description, with each index line expanded into its full stop text.

**Issue tracking.** Wire in the detected tracker's commands (`gh issue view`, `glab issue view`, Linear MCP/CLI, or local ticket file paths). If there's no tracker, remove ticket-specific references and fall back to generic "task description" language.

## branch-ticket-detector

The agent's "Issue Tracker" section has one subsection per tracker. **Keep only the subsection matching the detected tracker and delete the rest**, so its identifier pattern and fetch command match reality. For local files, set the project's actual ticket path.

**If issue tracking is None**, don't generate this agent at all. Then:
- In `research-codebase/SKILL.md`, strip the detection branch from "Initial Setup" and keep only the plain "ask the user for a research question" fallback, and drop the "For ticket context" bullet from step 3
- Drop the "run it with no arguments" branch-detection mention from `guide/topics.md`

Otherwise the generated skills reference an agent that doesn't exist.

## prepare-pr/tuicr-walkthrough.md

Copy it essentially verbatim — it documents a third-party TUI, not the project. Two things to touch:

- The **standard checks** in "Applying fixes mid-walk" become the project's real commands.
- If the forge isn't GitHub, the "stops are already there" path doesn't exist. Lead with the local-seeding fallback instead of demoting it, and drop the `resolveReviewThread` GraphQL.

Don't trim the gotchas to save space. Each one is a silent failure someone already hit; they are the reason the file exists.

## The herdr-phase script

`reference/scripts/herdr-phase.sh` is project-agnostic — no commands, paths, or tooling to adapt. Copy it **verbatim** to `.claude/scripts/herdr-phase.sh` and `chmod +x` it. Do not rewrite it. It no-ops outside herdr, so install it unconditionally; each phase skill already calls it.

## VS Code Copilot chat

VS Code reads `.claude/skills/` and `.claude/agents/` directly, so both editors load one set of files and there is no second copy to keep in sync. But they read frontmatter differently, and one difference will hang the editor.

### Strip `model:` and `effort:` from generated SKILL.md files

**When VS Code Copilot is a target, no generated `SKILL.md` may carry `model:` or `effort:`.**

`model:` is not part of VS Code's SKILL.md spec — the documented fields are `name`, `description`, `argument-hint`, `user-invocable`, and `disable-model-invocation`. A skill carrying `model:` wedges the chat session when invoked: no output, no error, and no subsequent command works until VS Code is restarted. The key triggers it regardless of value, so a Copilot-format id like `'Claude Opus 4.5 (copilot)'` is not a workaround. `effort:` is undocumented the same way and goes with it.

Claude Code-only installs keep both fields — that is where they do their work (opus/xhigh for research and planning, haiku/low for guide). The cost of stripping them is that VS Code runs every skill on whichever model the user has selected in chat; it offers no per-skill override. That tradeoff is why Step 3 asks, rather than always stripping. It asks about the repository, not the machine setup is running on — the files get committed, so a teammate on the other editor inherits whatever was generated.

**Strip mechanically, not by hand.** The reference templates keep `model:` and `effort:`, so every generated file starts out carrying them. Write the files normally and then run `scripts/strip-copilot-frontmatter.sh` over `.claude/skills` and `.claude/agents` (Step 6). Omitting the lines by eye across fifteen files is exactly the kind of thing that misses one, and one miss costs the user a wedged editor. The script touches only the leading frontmatter block, leaves body text alone, is idempotent, and verifies itself before exiting.

Everything else about the generated files is identical for both editors. The skill frontmatter is the only thing to branch on.

### Agent frontmatter: strip `model:` and `effort:` too, for now

VS Code *does* support `model:` on custom agents, but expects Copilot ids like `'Claude Sonnet 4.5 (copilot)'` — not the bare `sonnet` these templates carry. Whether a bare value hangs an agent the way it hangs a skill is **unverified**. Until it is, strip both fields from generated agents when VS Code is a target: the failure mode is severe enough (a restart, mid-workflow) that guessing the safe way is worth the lost pinning.

### The setting

If Copilot is a target, merge into `.vscode/settings.json`:

```json
{ "chat.useAgentSkills": true }
```

**Merge, don't overwrite.** Projects keep real configuration there. Read what exists, add the one key, and leave the rest — including formatting and comments — untouched. Create the file only if it's absent.

Note that current VS Code docs describe `chat.agentSkillsLocations` instead, and list `.claude/skills` among its defaults, with skills enabled by default since 1.109 — so this merge may be a no-op on current builds. It is harmless, and kept for older ones.

### Unverified claims to re-check before relying on them

Earlier versions of this file asserted a frontmatter mapping that turned out not to exist. Two neighbouring claims came from the same source and have **not** been confirmed:

- That VS Code maps `Bash`/`Grep`/`Glob`/`Read`/`Edit`/`Write`/`WebSearch`/`WebFetch`/`Task` in an agent's `tools:` to its own tools. VS Code's own agent examples use names like `['read', 'search', 'web']`. A wrong tool name degrades an agent rather than hanging it, so this is lower severity — but don't cite it as fact.
- That `LS` and `TodoWrite` are simply dropped. Same provenance, same status.

## What must survive adaptation

Six behaviors carry the workflow. Change the tooling around them freely; if any of them doesn't make it into the generated files, the adaptation failed.

**The documentarian split.** Research agents describe what exists; they don't critique or recommend. Design and planning are where opinions belong. Each agent states this once — in its `description` and one line of body — so it's easy to drop by accident while rewriting. Carry it through.

**Parallel sub-agent execution.** `/research-codebase` fans out across research questions in a single response. Preserve the fan-out instruction, not just the agent list — sequential research is the failure mode it exists to prevent.

**Interactive planning.** `/design-doc` and `/create-plan` stop and confirm with the user at defined points: the design's open questions, the plan's phase outline. Keep those checkpoints, and keep the batching guidance that stops them turning into a question-per-turn drip.

**The automated vs. manual verification split.** Plans separate what an agent can verify itself from what needs a human. This distinction drives the pause-between-phases behavior in `/implement-plan`. Adapt the commands; keep the two categories.

**One stop list, rendered up to three ways.** `/prepare-pr` builds the stop list once, then renders it as inline review comments, as a numbered index in the description, and — if the author walks it — as the thing you narrate in tuicr. The failure mode is letting the three drift apart, or reinflating the description back into per-file prose sections. Keep the length budget.

**Comment discipline.** `/implement-plan`'s "Comments: default to none" is a user-visible outcome, not boilerplate — it is the difference between a diff a human wants to read and one padded with restated design rationale. Keep both tests (would a reader be *surprised*; is it under three lines) and keep the end-of-phase re-read. Swap the example comment for one in the project's language.

## The register these templates are written in

The templates are terse on purpose, and each constraint appears exactly once. That's a deliberate choice you need to preserve, because the natural instinct while adapting is to be helpful and explain more.

Current models infer intent well. A rule stated three times doesn't land three times harder — it makes the model spend effort reconciling near-duplicates instead of doing the work, and if the restatements drift even slightly apart, it has to decide which one wins. That reconciliation is pure cost. One clear statement outperforms a stack of emphatic ones.

So while adapting:

- **Add project specifics, not explanation.** Their test command, their patterns, their framework's idioms — yes. A paragraph on why documenting beats critiquing — no, it's already there once.
- **Don't restate a rule for emphasis.** If you find yourself writing "remember," you're duplicating something above.
- **Prefer defining over forbidding.** "A design doc is ~200 lines of alignment; file-by-file changes belong in `/create-plan`" beats three `DO NOT` bullets. Same boundary, less to reconcile.
- **Keep the prohibitions that guard a real cost.** A few remain deliberately — the repo-local search scope in `artifact-locator`, "don't check off manual testing until the user confirms" in `/implement-plan`, the read-only contract in `branch-ticket-detector`. These earn their place because being wrong is expensive. Carry them through.

**A check worth running:** if your adapted file is materially longer than the template it came from, look at what you added. Project-specific detail is why you're here. Re-explanation of something the template already says is the thing to cut.

## Judgment calls

- Multiple test commands → use the most comprehensive as the default, and keep the specific ones where the template distinguishes unit/integration/e2e
- No linter or formatter → omit those sections rather than leaving broken commands
- A Makefile with standard targets often beats the package manager's scripts — prefer whatever the team actually types
- Genuinely unclear → ask, don't guess

## The bar

Adapt by understanding, not by substitution. The templates describe a workflow; your job is to express that same workflow in this project's vocabulary. A generated file that mentions a command the project doesn't have, or a framework it doesn't use, is a failure even if every other line is correct.

The result should read as though it were written for this project, not like a generic template forced to fit.
