# Changelog

All notable changes to the `research-plan-implement` plugin are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com).

## [Unreleased]

### Added

- README section on running the generated files in another editor, and the one
  incompatibility that matters: a generated `SKILL.md` carries `model:`, which
  hangs VS Code Copilot chat on invocation until VS Code restarts. Documentation
  only — no change to what setup generates.

## [5.0.1] - 2026-08-31

### Fixed

- **`/prepare-pr`'s tuicr walkthrough documented a reply endpoint that 404s.** Replying to
  a review comment needs the PR number:
  `gh api repos/{owner}/{repo}/pulls/<n>/comments/<id>/replies`. The shorter
  `pulls/comments/<id>/replies` form it previously showed does not resolve.

## [5.0.0] - 2026-08-31

Three independent changes ship together.

**Where artifacts live.** `thoughts/shared/` was inherited from HumanLayer's original
workflow, where it named a place for an agent's working notes. Two things were wrong
with it. The name described a mood rather than a content type, and the
directory-per-type hierarchy meant four `mkdir`s and four globs to express something a
filename already says. Artifacts now live flat in `.rpi/`, and the agents that read them
no longer have a directory name baked into their own.

**How much prose the workflow produces.** The previous version was too willing to write
it. `/prepare-pr` wrote PR descriptions long enough that the "read this carefully"
section stopped being read carefully, and `/implement-plan` finished each phase holding
the whole design rationale in context and parked it in the source as comments. Both are
now bounded.

**How many skills there are.** `/iterate-plan` described revising a plan as a workflow
phase. It isn't one — editing a file is not a phase, and every step the skill described
was either generic agent behavior or a restatement of `/create-plan`. It's gone, and the
two rules worth keeping moved into `/create-plan`.

### Changed

- **Default artifacts directory is `.rpi/`, and it's flat.** The type moved from
  the directory into the filename's last segment:

  ```
  thoughts/shared/plans/2026-01-05-auth.md  ->  .rpi/2026-01-05-auth-plan.md
  ```

  Names are `YYYY-MM-DD-[TICKET-]description-{research,design,plan,review}.md`.
  Date-first sorts one feature's whole chain together, which is the order you
  actually read them in. A hidden root that only this workflow writes to also
  takes a one-line `.gitignore` entry — under a shared directory you'd be
  ignoring by glob and silently catching hand-written docs with it.
- `/implement-plan` and `/prepare-pr` locate review metadata by **swapping a
  plan's `-plan` suffix for `-review`** rather than mirroring a basename across
  two directories. Same deterministic lookup, one less directory.
- `thoughts-locator` and `thoughts-analyzer` are now **`artifact-locator` and
  `artifact-analyzer`**. The location is the user's to choose, so the agent names
  no longer assert one. `/research-codebase` and `/iterate-plan` reference the
  new names.
- The two agents are **always generated**. They were previously conditional on a
  `thoughts/` directory the workflow wrote to regardless, so the condition never
  meant anything.
- `artifact-locator` categorizes by filename suffix instead of by directory, and
  carries the one caveat a hidden root introduces: an unscoped search skips
  `.rpi/`, so the directory has to be named explicitly (`path: ".rpi"`). Scoped
  that way it reads normally even when gitignored.
- Setup states the `.rpi/` default rather than asking how to structure a
  directory, and takes an override for the root only. The naming convention is
  fixed — the metadata lookup above depends on both ends agreeing.
- The gitignore recommendation is one line, `.rpi/`.
- **`/prepare-pr` builds one numbered list of stops instead of a prose review
  guide.** A stop is a file, a line or range, a type, and a *claim to test* — not a
  description of what the code does. The list is built once and rendered in up to
  three places:
  - **Inline review comments on the PR** — the detail, anchored to the line it's
    about, posted as one `COMMENT` review via `gh api .../pulls/<n>/reviews`. Each
    stop becomes a resolvable thread, so a reviewer ticks stops off as they go.
  - **A numbered index in the PR description** — one line per stop, capped at
    **60 lines for the whole description**. Mechanical files get one line, not an
    inventory; "Suggested Review Order" is gone because the numbering *is* the order.
  - **A tuicr session**, when the author walks it.
  - Stop types carry intent: `issue`, `note`, `suggestion`, and `yagni` — the last
    for an abstraction, config, or layer with one caller that could be inlined until
    it has two.
  - `--no-stops` keeps the whole guide in the description. That's also the behavior
    `/setup` generates for projects on a forge without inline review comments.
- **`/implement-plan` defaults to writing no comments.** A comment now has to clear
  two tests before it's written: would a competent reader be *surprised*, and is it
  under three lines. Narration, history ("previously X, now Y"), symmetry notes,
  justification of the ordinary, and restated design decisions are called out by name
  as things not to write. Every phase ends with a re-read that deletes the comments
  that don't clear both bars. A deliberate simplification with a known ceiling goes in
  the phase's `### Completion` block under **Waived or unproven**, where `/prepare-pr`
  already looks — not into a source comment.
- **`/implement-plan` fixes root causes, not symptoms.** A phase that names a bug names
  a symptom; the skill now checks every caller of the function it's about to touch
  first, on the grounds that one guard in the shared function is both the smaller diff
  and the real fix.
- **`/create-plan` plans the smallest thing that works.** Before specifying new code for
  a phase it checks, in order, for an existing helper or pattern in the codebase, the
  standard library or framework, and an already-installed dependency. An interface with
  one implementation or a config value nobody sets goes under **What We're NOT Doing**
  for the user to overrule.
- `/guide`'s `review` topic and phase tips describe the stop model.
- **The `/design` skill is now `/design-doc`.** Same inputs, same ~200-line
  artifact, same `-design.md` output — only the skill's name changed. Every
  cross-reference in the other skills points at it, and the herdr phase glyph is
  still 🎨.
  - Upgrades write `.claude/skills/design-doc/` and remove the old
    `.claude/skills/design/` after asking. Local edits have to be carried
    across first — a rename can't merge them for you.
  - Aliases, scripts, and team docs that invoke `/design` need updating by hand.

### Added

- **Upgrade asks before moving anything.** An existing install picks one of
  three: keep the root it has, adopt `.rpi/`, or name its own. Setup recovers the
  current root by grepping the installed skills rather than assuming
  `thoughts/shared/`.
- Choosing to move **relocates, renames, and relinks**. Because the type moves
  from the directory into the filename, a prefix swap isn't enough: every
  cross-reference — plan to its design and research, review metadata to its plan,
  design doc to its `.html` mockup — is rewritten per type. The migration handles
  untracked files (the old default recommended gitignoring `thoughts/`, so most
  of them are), skips rather than overwrites an occupied destination, reports
  anything that isn't `.md` or `.html`, and leaves everything outside the
  workflow's own directories alone.
- **`prepare-pr/tuicr-walkthrough.md`** — a progressive-disclosure sibling for walking a
  PR with the author in [tuicr](https://github.com/agavra/tuicr), stop by stop. Because
  the stops are posted as GitHub review threads, `tuicr pr <n>` renders them natively
  and there is no seeding step; resolving a thread ticks it off in both places. Covers
  session discovery, the six ways a stop silently disappears (a resolved thread, a reviewed
  hunk, hidden reviewed files, an exclusion filter, a stale in-memory copy, and `dd` — the
  only one that actually deletes anything), applying fixes mid-walk, and a local-seeding
  fallback for walks with no PR or a non-GitHub forge. Entirely optional — if `tuicr`
  isn't installed the skill says so once and moves on, and the stops are on the PR either
  way. Written against tuicr 0.24.0.

- **Commit convention is detected once at setup**, with a real example subject line from the
  repo's own history, and `/prepare-pr` uses it instead of re-inferring one per PR. Conventional
  Commits was the standing guess and plenty of repos don't use it.

### Removed

- **`/iterate-plan`.** Six skills now instead of seven. Its two rules worth keeping moved
  into `/create-plan` under **Revising an existing plan**:
  - Keep the plan internally consistent when you edit it — a new phase carries an empty
    `### Completion` block, a scope change updates "What We're NOT Doing", and a revision
    that changes what the interface shows goes back to `/design-doc`.
  - **Never edit a filled-in `### Completion` block.** This is the one that had to move.
    A completed phase's block is a record, often written by an agent that has since
    exited, and the next fresh agent reads it as its only memory of that phase — a
    rewritten block is indistinguishable from a true one. The rule lived only inside
    `/iterate-plan`, so the people most likely to break it, anyone editing a plan by
    hand, were the people who never saw it.

  Upgrades will not delete the skill for you; `upgrade.md` lists it under retired files
  and asks. An install that keeps it keeps offering a command nothing else references.

### Fixed

- **`/guide`'s workspace probes failed under zsh.** `ls -lt .rpi/*-research.md 2>/dev/null`
  aborts with `no matches found` when nothing matches, because zsh fails an unmatched glob
  before the command runs — so the redirect never applies. Bash's default hides it, which is
  why it survived. Every fresh install hit it on the first `/guide`, when `.rpi/` is
  necessarily empty. The three probes now filter `ls` output instead of globbing.
- **`/guide <skill-name>` didn't resolve to a topic.** Topics are named for the phase
  (`design`, `review`), so the skill names users had just been trained to type — `design-doc`
  most of all, having just been renamed — missed and got the topic list back. Skill names are
  now accepted as aliases.

### Notes

- Ideas adapted from [ponytail](https://github.com/DietrichGebert/ponytail) (MIT): the
  reuse-before-writing ladder, root-cause-over-symptom, and treating an abstraction with
  one caller as a reviewable finding. Ponytail's `ponytail:` marker convention was
  deliberately *not* adopted — the `### Completion` block and review metadata already
  carry deliberate shortcuts into the PR, and a second mechanism for the same job would
  drift from the first.

## [4.1.0] - 2026-08-15

The `### Completion` block and the incremental review metadata below come from
one gap: the templates assumed a single agent spanning every phase of a plan,
accumulating notes in its own context. Running a fresh agent per phase — which
is the point of the workflow — deletes that context at every boundary. Anything
a later phase or `/prepare-pr` needs now has to be on disk before a phase stops,
so both files that outlive a phase gained a per-phase record.

### Added

- Plans now carry a `### Completion` block per phase. `/create-plan` emits it
  empty; `/implement-plan` fills it in before the pause message with the
  phase's deviations, anything the user waived or left unproven, and anything a
  later phase has to account for. The plan is the one file every phase agent
  reads, so it's where a finished phase leaves what the next one needs.
  - `/iterate-plan` carries filled-in blocks across intact and never edits
    them — they're the record of a phase whose author has already exited
  - `/prepare-pr` reads them for the deviations and waivers that belong in the
    PR description
  - Splits cleanly from the review metadata by audience: the completion block
    is what changed relative to the plan, the metadata is per-file review
    triage

### Changed

- `/implement-plan` now builds review metadata **incrementally, one section per
  phase**, instead of writing it once after the last phase. Under the old
  design a phase-5 agent had to re-derive the per-file triage by reading a diff
  it never wrote — which is the exact cost the metadata existed to eliminate,
  just moved from `/prepare-pr` to the last phase:
  - The metadata file's basename now **mirrors the plan's**, so an agent with no
    memory of earlier phases finds it in one Read instead of globbing a
    directory by date
  - Each phase appends a `## Phase N` section covering only the files it
    touched — Needs careful review / Mechanical / Tests / Deliberate non-fixes —
    written while the reasoning is still in context, before the pause message
  - The last phase adds a `## Summary` for the cross-cutting reads no single
    phase owns: what to open first, what's unproven across the whole change,
    what a later phase superseded
  - A section reconstructed after the fact is headed `(reconstructed from the
    diff — not authored in-phase)`, so downstream readers can tell author-grade
    triage from reader-grade
  - `review-metadata-template.md` reshaped from one flat document into the
    per-phase sections, with a back-link to the plan it belongs to
- `/prepare-pr` reads the metadata by mirroring the plan's basename rather than
  matching recent dates, and treats reconstructed sections as claims to verify
  against the diff rather than author intent to repeat. It also reads the plan
  itself now, not just the design doc.
- `/implement-plan`'s review metadata is no longer described as optional, and is
  written silently — it's plumbing between two skills, not a deliverable, and
  the user shouldn't have to decide about it on every phase.

### Fixed

- `herdr-phase.sh` stamped the phase glyph onto the **focused** tab rather than
  the agent's own tab, so in a multi-tab workspace the agent's label went stale
  while a sibling tab (often a human-run orchestrator) collected a stray prefix
  that later runs couldn't strip. The script now resolves its tab from
  `$HERDR_TAB_ID`, which herdr exports into each pane, and keeps the
  focused-pane scan only as a fallback. Existing installs carry a copy of this
  script at `.claude/scripts/herdr-phase.sh` — re-run `/setup` to pick up the
  fix, and clean up any stacked prefixes by hand with
  `herdr tab rename <id> "<label>"`. ([#15](https://github.com/lucasnad27/claude-plugins/issues/15))
- `/implement-plan` gave contradictory instructions about small plan deviations,
  telling the agent both to record them in the review metadata and to leave them
  to the plan. Deviations now go wherever they aren't already: cross-referenced
  when the plan carries per-phase completion blocks, recorded in the metadata
  when it doesn't.

## [4.0.0] - 2026-07-27

### Changed

- Rewrote the agent and skill templates for the Claude 5 generation of models,
  following Anthropic's [context engineering
  guidance](https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models).
  Newer models infer intent well enough that the old guardrails cost more than
  they bought:
  - Collapsed the triplicated "documentarian" prohibition blocks in
    `codebase-analyzer`, `codebase-locator`, `codebase-pattern-finder`, and
    `research-codebase` down to a single statement each, folded into the
    `description` so it also improves dispatch
  - Resolved four instruction conflicts, including `codebase-pattern-finder`
    being told both to note the preferred pattern and never to recommend one
  - Replaced the 120-line invented pagination example in
    `codebase-pattern-finder` with an output contract — the example was
    JavaScript in an agent that runs against Rust, Go, and Python repos
  - Split the 745-line `setup` skill into a routing spine plus `detection.md`,
    `adaptation.md`, and `upgrade.md`, loaded only on the path that needs them
  - Restated `/design`'s three `DO NOT` lines as a definition of what a design
    doc is — same boundary, no fence
  - Slimmed `/iterate-plan` (276 → 117 lines) by cutting worked interaction
    examples and a subagent-spawning tutorial the agent descriptions cover
  - Rewrote the `web-search-researcher`, `thoughts-analyzer`, and
    `thoughts-locator` descriptions, which were jokes; descriptions drive
    dispatch and count against the skill-listing character cap
  - Dropped `/implement-plan`'s "never use limit/offset" instruction, which
    fought the Read tool's own guidance
- `/setup` now carries the reasoning behind the template style, so an agent
  regenerating someone's skills understands what it's preserving rather than
  copying shapes:
  - `adaptation.md` explains the register the templates are written in — one
    statement per constraint, definitions over prohibitions, and which
    prohibitions deliberately remain — with a length check against the source
    template to catch re-explanation creeping back in
  - `upgrade.md` gives a decision rule for the hard call in any upgrade:
    project-specific content is the user's and must survive, while an
    instruction repeated within a file is stale template and should collapse
  - `upgrade.md` lists the v3-and-earlier residue that is safe to replace
    without asking, scoped so it can be deleted once those installs age out
  - The upgrade summary is now composed from `CHANGELOG.md` for the user's
    actual version delta, instead of always showing the v2→v3 story
- `/design` now produces a concrete reference artifact — a self-contained HTML
  mockup for UI work, real payloads for an API, a schema diff for data model
  changes — and `/create-plan` and `/implement-plan` build against it rather
  than against prose describing it. `/guide design` describes the artifact as
  part of a good design, rather than counting code snippets against one
- `/create-plan` phases now specify test files and named test cases instead of
  "add tests for X" checkboxes
- `/guide tips` no longer pins its closing section to a specific model release.
  It had gone stale twice, and most of what it said ("give complete context
  upfront", "`/implement-plan` is the auto-mode candidate") describes the
  workflow rather than any one model. The durable advice stays under a
  model-neutral heading; the release-specific steering phrases and effort
  defaults are gone, since `effort:` lives in each skill's frontmatter anyway

### Fixed

- `codebase-pattern-finder` had a malformed code fence that rendered its own
  operating guidelines (Pattern Categories, Important Guidelines, What NOT to
  Do) inside a code block
- `/setup` listed a `read-ticket` skill and a `ticket-reader` agent in its
  output tree that no reference template ever backed, and `/research-codebase`
  pointed at "the project's ticket-reading agent" to match. Both dropped;
  `branch-ticket-detector` already fetches ticket contents, and a one-off
  lookup of a related ticket doesn't need a subagent

### Added

- herdr phase markers: each workflow skill tags its herdr tab with an emoji
  prefix (🔬 research · 🎨 design · 📋 plan · 🔨 implement · 🔍 review) so the
  session sidebar doubles as a phase board. Backed by a copied-verbatim
  `scripts/herdr-phase.sh` that no-ops outside herdr, so it's harmless for
  projects whose author doesn't use herdr
- `/guide herdr` topic explaining the phase markers and the manual override
- `.claude/.rpi-version`, written on every install and upgrade, so `/setup` can
  tell which version generated a user's files. The changelog-driven upgrade
  summary needs their version to pick the right entries, and nothing recorded
  it before. Installs predating this fall back to inferring the major from the
  file set — `/prepare-pr` means 3.x, `/review-changes` means 2.x

## [3.0.0] - 2026-06-03

### Added

- `/prepare-pr` skill that bundles the change review and pull-request
  preparation into a single guided flow
- `branch-ticket-detector` agent that infers the associated ticket from the
  current branch name
- `/research-codebase` now auto-detects the ticket from the branch and folds
  it into the research context

### Removed

- `/review-changes` skill, replaced by `/prepare-pr`

## [2.1.1] - 2026-04-21

### Fixed

- Scoped the `thoughts-locator` agent template to the current repo's
  `thoughts/` directory only. Previously it ranged across parent directories,
  sibling worktrees, and `~/thoughts`, causing slow searches and excessive
  permission prompts. Also dropped unused references to `thoughts/searchable/`,
  `thoughts/global/`, and per-user subdirs in the `research-codebase` skill.

## [2.1.0] - 2026-04-16

Optimizations for Claude Opus 4.7.

### Changed

- Bumped reasoning effort to `xhigh` for agentic skills (`research-codebase`,
  `create-plan`, `implement-plan`, `iterate-plan`, `design`, `review-changes`)
  to take advantage of Opus 4.7's extended thinking
- Refined skill guidance across `create-plan`, `implement-plan`,
  `research-codebase`, `iterate-plan`, `design`, and `review-changes` for
  Opus 4.7
- Updated `codebase-analyzer` and `thoughts-analyzer` agent prompts
- Expanded setup skill and `/guide` topics

### Fixed

- Corrected `AskUserQuestion` batching guidance

## [2.0.0] - 2026-04-05

Major rewrite migrating the workflow to the skills format, with new alignment
and review stages and testing-aware planning/implementation.

### Added

- `/design` skill for lightweight human-agent alignment before planning
- `/review-changes` skill for structured, guided code review
- `/guide` skill providing contextual workflow orientation (consolidates the
  former `/guide` and `/workflow-guide` into a single entry point)
- `query-planner` agent for objective research decomposition
- Vertical phase planning with per-phase testing in `create-plan`
- Testing-aware implementation and review metadata in `implement-plan`
- Pattern-finder now discovers existing testing infrastructure
- Upgrade intelligence and skills migration support in the setup skill
- Backtick injection in `/guide` for instant workspace state

### Changed

- Migrated `create-plan`, `iterate-plan`, and `implement-plan` from the
  commands format to the skills format
- Rewrote vertical phase guidance with concrete examples
- Updated README and workflow docs to reflect the 5-step flow
- Output templates extracted into dedicated supporting files
- Research/plan commands now use the `AskUserQuestion` tool for open questions
- Setup skill now recommends creating a branch before running

### Fixed

- README inconsistencies surfaced in review
- Missing space between `/review-changes` command and its filename argument

### Removed

- Old `reference/commands` directory (migrated to `reference/skills`)
