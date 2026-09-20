# Template Adaptation

Reference for Step 5 of the setup skill.

Adapt each template by reasoning about what the project actually needs — read the template fully, find every project-specific reference, and rewrite those sections. Preserve the workflow logic and agent behaviors; change the tooling around them.

## What varies by project

**Commands.** Every `npm run test:unit`, `npm run lint`, `npm run format`, `npm run build`, and database command in the templates is a placeholder for whatever this project actually uses. Replace them with the detected commands, including in checklists and verification sections.

**Commit convention.** `/prepare-pr`'s commit step carries `[CONVENTION]` and `[EXAMPLE]` markers. Replace both with what detection found, keeping the example a real subject line from this repo's history rather than an invented one. When detection found no convention — or subjects that disagree — write `no fixed convention; match the surrounding history` and delete the `, e.g. ...` clause rather than falling back to Conventional Commits, which is the guess this whole step exists to prevent. A bracket left in place ships as prose and will be read as an instruction.

**Directory structure.** Adjust paths to the project's layout — `src/` vs `pkg/`/`internal/`, `tests/` vs `__tests__/`, framework-specific trees like `src/routes/`.

**Framework guidance.** Where a template gives framework-specific advice, replace it with advice for the detected framework — SvelteKit load functions and form actions, Django models/views/urls, Next.js app router and server actions, Axum extractors and response types. Keep it generic if no framework is detected.

**Database workflow.** Include the detected tool's develop-then-migrate cycle (Prisma `db push` → `migrate dev`, Django `makemigrations` → `migrate`, Alembic revisions, Diesel migrations). Remove database sections entirely if there's no database.

**Artifacts directory.** The templates write to `.rpi/`, flat, with the type as the filename's first segment — `{research,design,plan,review}-YYYY-MM-DD-[TICKET-]description.md`. If the user chose a different root, rewrite every occurrence: the `ls -lt .rpi` probes in `guide/SKILL.md`, the example paths in `guide/topics.md`, and the `path: ".rpi"` search scope in `artifact-locator`. The naming convention itself doesn't change — `/implement-plan` and `/prepare-pr` find the review metadata by swapping a plan's `plan-` prefix for `review-`, and that only works if both ends agree.

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
