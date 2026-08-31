# Research → Design → Plan → Implement → Review

**Install the plugin, run `/setup`, and you have a research → design → plan → implement → review workflow adapted to your codebase and your team's SDLC.**

That is the entire setup. `/setup` reads your project — build system, test runner, linter, framework, database tooling, issue tracker, commit convention, forge — and writes six skills and eight agents into `.claude/`, phrased in your project's own vocabulary. Nothing to fill in, no config file to maintain, no templates to keep in sync.

The payoff is velocity you can actually ship: a 35k-LOC feature landed in 7 hours against a 3–5 day estimate, with minimal PR revision. Roughly 5x — without lowering the review bar, because raising it is how you get there.

As the plugin improves, update it and re-run `/setup`. Your edits come with you — [see below](#upgrading--your-edits-come-with-you).

---

## Why put friction back in

![No slop, all vibes — three charts contrasting lines of code against understanding of code, pre-AI, with AI and no friction, and with AI plus deliberate friction; below them the six workflow steps and the human checkpoint at each](../../docs/no-slop-all-vibes.png)

Before coding agents, understanding was a byproduct of typing. You could not ship a system you did not understand, because writing it line by line *was* how you came to understand it. The two lines in the left panel move together because they were never really two lines.

Agents severed that link. Code volume is now decoupled from comprehension — an agent produces more in an afternoon than a team absorbs in a week. The middle panel is what you get when you point one at a repo and stay out of its way: **accumulating code quicker than we are accumulating trust.**

That gap is the whole problem, because trust is what actually ships. Code nobody understands cannot be reviewed honestly, cannot be debugged at 2am, and cannot be safely changed six months from now. Velocity that outruns understanding is not velocity. It is debt at a higher frame rate.

The fix is not slowing the agent down. It is putting a human back at the specific points where understanding gets created, and writing down what was understood so the next context can pick it up. That is the bottom row of the diagram — six steps, each with a named human and something they have to actually read and agree to:

| Step | Who | What the friction buys |
| --- | --- | --- |
| **Issue** | Team | Agreement on what the problem even is, before anyone opens an editor |
| **Research** | Dev | A written account of how the code works *today* — no recommendations, no critique |
| **Design** | Dev | The approach argued and settled while it is still cheap to change |
| **Plan** | Dev | Vertical phases with explicit verification, so "done" is defined before work starts |
| **Implement** | Dev | A pause between phases — tests green, manual check, then the next one |
| **Review** | Team | Numbered stops on the diff naming what to decide, so understanding lands back with the team |

Each phase leaves an artifact behind, and the artifact does double duty: it is the record of what was understood, and it is the input that seeds the next phase's fresh context. That is the compaction half of the workflow. The checkpoint is the friction half.

The right panel is the payoff. Both lines climb. You do not trade speed for comprehension — the friction is what lets you keep both.

**No slop, all vibes.**

---

## Install

### Claude Code

Add the marketplace, then the plugin:

```bash
/plugin marketplace add lucasnad27/claude-plugins
/plugin install research-plan-implement@research-plan-implement-workflow
```

### VS Code (Copilot chat)

VS Code's Agent Plugins resolver reads `.claude-plugin/marketplace.json` as one of its four recognized manifest formats, so this repo installs as-is — there's no separate VS Code package.

1. `Cmd/Ctrl+Shift+P` → **Chat: Install Plugin From Source**
2. Enter `lucasnad27/claude-plugins`
3. Turn on agent skills in your settings:

   ```json
   { "chat.useAgentSkills": true }
   ```

Requires VS Code 1.108 or newer; on older builds the setting is named `github.copilot.chat.skillTool.enabled`.

### Then, in your project

```bash
cd my-project
/setup      # generates the workflow, adapted to this repo
/guide      # where am I, what's next
```

Start working:

```bash
/research-codebase "How does user authentication work?"
/design-doc .rpi/2026-04-02-auth-research.md
```

### Editors

The generated files run in **Claude Code** and **VS Code Copilot chat** from a single copy — VS Code scans `.claude/skills/` and `.claude/agents/` alongside its own `.github/` equivalents. One difference is load-bearing, so `/setup` asks a single yes/no question: will these files ever be opened in Copilot chat? It asks about the repository rather than your machine — the files get committed, so a teammate on the other editor inherits whatever was generated.

**Skills generated for VS Code carry no `model:` or `effort:` frontmatter.** A skill whose frontmatter includes `model:` hangs Copilot chat when invoked — no output, no error, and the session stays dead until VS Code restarts. The key does it regardless of value; VS Code's SKILL.md spec documents only `name`, `description`, `argument-hint`, `user-invocable`, and `disable-model-invocation`. Setup strips both fields when Copilot is a target, and the upgrade path strips them from installs generated before it was one.

The tradeoff is per-skill model pinning. Claude Code-only installs keep it — research and planning on opus at high effort, `/guide` on haiku. In Copilot every skill runs on the model selected in chat, so choose it before starting a research or planning pass.

Answer yes during `/setup` and it also merges `chat.useAgentSkills` into `.vscode/settings.json` for you. Run `/guide copilot` for the full picture, including what remains unverified about tool-name translation.

---

## What you get

`/setup` and `/guide` ship with the plugin. Everything below is generated into your repo and is yours to edit.

**Skills**

| Skill | What it does |
| --- | --- |
| `/research-codebase` | Fans out parallel sub-agents to document how something works today |
| `/design-doc` | Settles the approach through discussion, ~200 lines plus a concrete mockup |
| `/create-plan` | Turns a design or ticket into vertical phases with per-phase verification |
| `/implement-plan` | Executes phase by phase, runs your real checks, pauses for manual testing |
| `/prepare-pr` | Commits, opens the PR, and lands a numbered review guide as inline stops |
| `/guide` | Contextual orientation — where am I in the workflow, what's next |

**Agents**

| Agent | What it does |
| --- | --- |
| `codebase-locator` | Finds *where* code lives |
| `codebase-analyzer` | Explains *how* it works |
| `codebase-pattern-finder` | Finds similar patterns worth modeling after |
| `query-planner` | Decomposes a research question into targeted sub-queries |
| `branch-ticket-detector` | Reads the ticket off your branch, so `/research-codebase` works bare |
| `web-search-researcher` | Researches external docs |
| `artifact-locator` | Finds prior research, designs, plans, and tickets |
| `artifact-analyzer` | Pulls the decisions and constraints out of one of them |

**Script** — `scripts/herdr-phase.sh`, for [herdr](https://herdr.dev) users. Harmless if you aren't one; see [tooling](#bring-your-own-tooling).

---

## The five phases

```
/research-codebase  🔬   What exists today, written down. No opinions.
/design-doc         🎨   What we're going to do, argued and settled.
/create-plan        📋   Vertical phases, each independently verifiable.
/implement-plan     🔨   Phase by phase. Tests alongside code. Pause between.
/prepare-pr         🔍   PR opened, diff annotated with numbered stops.
```

Each writes to `.rpi/`, flat, with the type as the filename's last segment:

```
.rpi/
├── 2026-01-05-auth-research.md    # /research-codebase
├── 2026-01-05-auth-design.md      # /design-doc
├── 2026-01-05-auth-design.html    #   ...and its mockup, when the work has a shape
├── 2026-01-05-auth-plan.md        # /create-plan
└── 2026-01-05-auth-review.md      # /implement-plan
```

A dated name sorts one feature's whole chain together, which is the order you read them in. A directory only this workflow writes to takes a one-line `.gitignore` entry without stepping on anything else. Setup asks before settling on a root, so `.output/`, `notes/`, or anything else works — the naming convention stays either way, since `/prepare-pr` finds a plan's review metadata by swapping `-plan` for `-review`.

Revising a plan is a direct edit — there is no command for it. Keep it internally consistent, and leave a completed phase's `### Completion` block alone: it is a record, and a later phase reads it as its only memory of the earlier one.

### About review stops

`/prepare-pr` does not write a prose review guide. It builds one numbered list of **stops** — each a file, a line or range, a type, and a claim to test — and renders it in up to three places:

- **Inline review comments on the PR**, one resolvable thread per stop, posted as a single `COMMENT` review
- **A numbered index in the description**, capped at 60 lines for the whole thing
- **A [tuicr](https://tuicr.dev) session**, if you walk it with the author

Stop types carry intent: `issue`, `note`, `suggestion`, and `yagni` — the last for an abstraction, config, or layer with one caller that could be inlined until it has two. `--no-stops` keeps the whole guide in the description, which is also what setup generates for forges without inline review comments.

---

## Bring your own tooling

`/setup` shapes the workflow around your SDLC, not the other way around — your build system, test runner, issue tracker, forge, commit convention, review norms, deploy gate. **Tell your agent what you use and it wires that into the phases.** The generated skills are plain markdown in your repo, so anything you can describe to an agent, they can be taught.

**You don't need any particular tool for this to work.** Nothing below is required, and skipping all of it costs you nothing.

Two "agent-native" tools are wired in already, because we reach for them daily. Both are optional and both degrade quietly:

- **[herdr](https://herdr.dev)** — a terminal multiplexer for coding agents. Each phase tags its tab with a glyph (🔬 🎨 📋 🔨 🔍), turning the sidebar into a phase board across every worktree you have open. The script installs unconditionally and is a silent no-op outside herdr, so there's nothing to disable if you don't run it.
- **[tuicr](https://tuicr.dev)** — a terminal PR reviewer. Because stops are posted as GitHub review threads, `tuicr pr <n>` renders them natively with no seeding step, and resolving a thread ticks it off in both places. If it isn't installed, `/prepare-pr` says so once and moves on — the stops are on the PR either way.

Design tooling works the same way. `/design-doc` produces a self-contained HTML mockup by default; name [Paper](https://paper.design), [impeccable](https://impeccable.style), Figma, or whatever your team actually opens, and it routes the artifact through that instead.

So does everything else — your linter, your migration tool, your deploy check, your org's PR template, the review checklist that currently lives in someone's head. Setup asks for custom verification commands and folds them into the phases that need them.

None of this is a plugin API. The skills are files; describing your tooling to the agent that writes them is the extension mechanism.

### Upgrading — your edits come with you

This is why the extension story works. Update the plugin and re-run `/setup`:

```bash
/plugin marketplace update research-plan-implement-workflow
/setup
```

Setup pins your installed version, reads the changelog between it and the current release, and **shows you the delta before touching a file** — new skills, retired ones, what changed in the ones you have.

Then it upgrades *on top of your modifications*. Your commands, your conventions, your domain guidance, whole sections you wrote that match no template — those are carried into the regenerated files. Where it genuinely cannot tell your work from an older template's residue, it shows you the specific lines and asks. It does not guess, because guessing wrong in the "that's stale" direction deletes your work.

Two upgrades reach further and always ask first: moving your artifacts root (v4.1 and earlier used `thoughts/shared/`), which relocates, renames, and relinks every cross-reference; and renamed skills or agents, where local edits have to be carried across before the old file goes.

---

## What it adapts to

Detection is reasoning over your config files, not a lookup table — but these are the paths that are well-worn:

| | |
| --- | --- |
| **Languages** | TypeScript/JavaScript (Node, Deno, Bun), Python, Go, Rust |
| **Frameworks** | SvelteKit, Next.js, Django, FastAPI, Axum, and generic defaults |
| **Build systems** | npm/yarn/pnpm scripts, Makefile, Cargo, Poetry, Go modules |
| **Databases** | Prisma, Drizzle, SQLAlchemy, Django ORM, Diesel |
| **Forges** | GitHub via `gh` (inline stops), GitLab and others (guide in the description) |
| **Trackers** | GitHub Issues, GitLab, Linear, local ticket files, or none |

What adaptation means in practice: a SvelteKit repo gets `npm run test:unit` because that is the script that exists, not a generic `npm test`; a Rust repo gets `cargo clippy`; a Django repo gets `makemigrations` → `migrate`. The commit convention is detected once at setup from your actual history, with a real subject line as the example, rather than assuming Conventional Commits every time.

---

## Philosophy

1. **Documentarian approach** — research documents what EXISTS, not what SHOULD BE
2. **Design before planning** — settle the approach while changing it is still cheap
3. **Parallel sub-agents** — fan out concurrently; sequential research is the failure mode
4. **Interactive planning** — defined checkpoints where a human confirms, batched, not a drip
5. **Testing-aware implementation** — tests are built into each phase, not appended
6. **Automated + manual verification** — an explicit split between what an agent can prove and what needs you
7. **The smallest thing that works** — existing helper, then stdlib, then an installed dependency, before new code
8. **Comments default to none** — rationale lives in the design doc and the plan, not narrated into the source
9. **Review is navigation, not a verdict** — numbered stops naming what to decide, on the lines they are about

---

## Troubleshooting

**"I couldn't detect your project type."** Detection looks for `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, or `requirements.txt`. With none of them present it asks you to name your stack.

**"Reference templates not found."** The plugin is not installed correctly — confirm `skills/setup/reference/` exists under the plugin directory.

**Generated skills don't match my project.** Re-run `/setup` with corrections, or edit the files directly — they are yours. If detection got something wrong that it should have caught, please file an issue.

**My artifacts are still in `thoughts/shared/`.** Nothing breaks; an upgrade only moves them if you ask. Re-run `/setup` and pick `.rpi/` or your own root when it asks, and it relocates, renames, and relinks. Keeping what you have is equally supported.

**`/guide` fails with `no matches found`.** Fixed in v5.0.0 — zsh aborts an unmatched glob before the command runs, so `2>/dev/null` never applied. Upgrade.

**Upgrading from v1.** Generated files moved from `.claude/commands/` to `.claude/skills/`. Re-run `/setup`, then delete the old `commands/` files once the skills are confirmed working.

---

## Contributing

Contributions welcome, particularly:

- Additional language support (Java, C#, PHP)
- Framework-specific guidance improvements
- Better project detection heuristics
- Documentation improvements

---

## Attribution

Inspired by and adapted from several sources in the AI-assisted development community.

**Primary inspiration — HumanLayer.** The original research → plan → implement pattern and the intentional compaction strategy.

- [humanlayer.dev](https://humanlayer.dev) · [humanlayer/humanlayer](https://github.com/humanlayer/humanlayer)
- [AI Engineering talk](https://youtu.be/rmvDxxNubIg?si=WtKgAdi6MydW8u-i) — deep dive on context engineering for coding agents
- [Advanced Context Engineering for Coding Agents](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents)

**Additional influences**

- **CRISPY / Dex** — design-before-planning discipline and structured review phases
- **Simon Willison** — practical AI-assisted development patterns and the value of explicit workflow documentation
- **[ponytail](https://github.com/DietrichGebert/ponytail)** (MIT, by DietrichGebert) — the reuse-before-writing ladder in `/create-plan`, root-cause-over-symptom in `/implement-plan`, and treating a one-caller abstraction as a reviewable finding (the `yagni` stop type in `/prepare-pr`)

The intentional compaction strategy and multi-phase workflow originated from HumanLayer's work on optimizing agent effectiveness through context window management, expanded here with design alignment and review phases drawn from the broader community.

## License

MIT
