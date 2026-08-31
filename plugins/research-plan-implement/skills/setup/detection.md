# Project Detection

Reference for Step 1 (analyze) and Step 2 (fill gaps) of the setup skill.

## What to read

Read whichever of these exist, and infer the stack from them:

| File | Tells you |
|---|---|
| `package.json` | Node/TypeScript; scripts block usually has every command you need |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `pyproject.toml`, `requirements.txt` | Python; check for poetry/uv/pdm |
| `Makefile` | Often the real entry point — check for `test`, `lint`, `build` targets |
| `.git/config` | Remote host hints at the issue tracker (github.com, gitlab.com) |

Also check where workflow artifacts should live. `.rpi/` is the default root; note whether it already exists, and whether an older `thoughts/` tree is present (see "Detecting an existing installation").

## What to extract

- Primary language and framework
- Package manager and available scripts
- Test commands — unit, integration, e2e (they're often distinct)
- Lint, format, build, and type-check commands
- Database tooling and its migration workflow (Prisma, SQLAlchemy/Alembic, Django ORM, Diesel, Drizzle)
- Directory structure conventions
- Issue tracker
- Commit message convention (see below)
- Existing artifacts directory, if any

## Detecting the issue tracker

Check for CLIs (`which linear`, `which gh`, `which glab`), ticket files (`.rpi/*-ticket.md`, or a `thoughts/*/tickets/` directory on an older install), and the git remote host. Note both what the project uses *and* whether the CLI is actually installed — the generated skills depend on it.

Install hints if a CLI is missing:
- Linear: `npm install -g @linear/cli`
- GitHub: https://cli.github.com
- GitLab: https://gitlab.com/gitlab-org/cli

## Prefilling the Copilot question

Step 3 asks one yes/no question — will these files ever be opened in VS Code Copilot chat — and your job here is to prefill the answer, not to decide it.

Look for `.vscode/` in the project, a `.vscode/` entry in `.gitignore` (a team that ignores it still uses it), and `.github/prompts/` or `.github/chatmodes/` alongside. Any of those is evidence for **yes**. Nothing at all is evidence for **no**.

Two things this deliberately does not do:

- **It does not detect the editor you are running in.** `CLAUDECODE` and the `CLAUDE_CODE_*` variables tell you setup is running in Claude Code, and that is the wrong question — the generated files get committed and read by teammates on other editors. A repo is not Copilot-free because the person running setup happens not to use it. Don't branch on those variables.
- **It does not treat the two editors as exclusive.** Plenty of teams run both, and "both" is not a third outcome: it produces the same files as Copilot alone.

Carry the evidence into Step 3 as a stated default — "I see `.vscode/`, so I'll generate Copilot-safe files unless you say otherwise" — and let the user overrule it. Never infer silently.

## Detecting the commit convention

`/prepare-pr` writes commit messages, and inferring the convention fresh on every PR is where it
gets this wrong — Conventional Commits is the common guess and plenty of repos don't use it.
Resolve it once, here.

```bash
git log --no-merges --format=%s -30
```

Read the subjects and record **which convention, plus one real example from this repo**. The
example is the part that carries; a label alone still leaves room to guess wrong.

- `feat(scope): lowercase summary` → Conventional Commits. Note whether scopes are actually used.
- `Add the fallow health check` → imperative sentence case, no type prefix.
- Anything with a ticket key (`PROJ-12: …`, `[#451] …`) → record the position and bracket style.

If the last 30 subjects disagree with each other, say so rather than picking a winner, and ask.
A repo with no convention is a real answer — write "no convention; match surrounding history."

## Presenting findings

Show what you found as a compact list — language, framework, package manager, test/lint/format/build/typecheck commands, database, issue tracking, the commit convention with its example, and the artifacts directory. Mark anything you couldn't determine as needing input rather than guessing.

## Filling gaps

Ask for everything you couldn't detect **in as few turns as possible** — every extra turn costs the user more than answering a batched prompt once.

- Command and path gaps are free-text and don't fit `AskUserQuestion`'s multiple-choice shape. Present them as a single numbered block the user fills in one pass, with a realistic example per line and an explicit opt-out (`none` / `skip`).
- The issue-tracker choice *does* fit `AskUserQuestion` (Linear / GitHub / GitLab / local files / none). Use it there, and batch any follow-up into the same call — it takes up to 4 questions.
- Only split into a second round when a later question genuinely depends on an earlier answer.

For a detected database with an unclear migration workflow, ask for two things: how schema changes are applied during development, and how formal migrations are created.

## Confirming

Present the complete resolved configuration and get a yes before generating anything. This is the last cheap moment to correct a wrong assumption.

## Detecting an existing installation

- `.claude/skills/research-codebase/SKILL.md` exists → **upgrade**, see `upgrade.md`
- `.claude/commands/research-codebase.md` exists → **v1 migration**, see `upgrade.md`
- Neither → **fresh install**, continue with Step 2

### Where the existing install writes artifacts

An upgrade must not assume `.rpi/`. Grep the installed skills for the paths they
actually write to — `grep -ho '[A-Za-z._/-]*/\(research\|designs\|plans\|review-metadata\)/' .claude/skills/*/SKILL.md | sort -u` —
and take the common root from that. It's usually `thoughts/shared/`, but a user who
customized their install may have anything. Cross-check against what's on disk;
if the skills and the filesystem disagree, show both and ask.

`upgrade.md` uses this root as the "keep what you have" option.

### Which version is installed

The upgrade summary is composed from the changelog entries between their version and
yours, so you need to know theirs. Read `.claude/.rpi-version` — Step 6 writes it on
every install and upgrade.

Installs generated before the marker existed won't have one, so fall back to what the
file set implies:

| Evidence | Version |
|---|---|
| `.claude/agents/artifact-locator.md` exists | 5.0+ |
| `.claude/skills/prepare-pr/` exists | 3.x–4.1 |
| `.claude/skills/review-changes/` exists | 2.x |
| only `.claude/commands/` | 1.x |

The 2.x/3.x split is reliable — v3 added `/prepare-pr` and removed `/review-changes` in
the same release. Within a major, patch level isn't recoverable from the file set; treat
it as the oldest in the range so the summary errs toward showing a change rather than
omitting it. If the evidence contradicts itself (both `prepare-pr/` and
`review-changes/` present), say so and ask.

## When detection fails

If you can't determine the project type at all, ask directly: what language/framework, how tests run, how linting and formatting work. If there's no test command, offer to skip test-related sections rather than inventing one.
