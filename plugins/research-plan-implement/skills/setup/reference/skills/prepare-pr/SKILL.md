---
name: prepare-pr
description: Commit outstanding changes, open a pull request, and land a numbered review guide — a short index in the description, the detail as inline review comments anchored to the diff
model: opus
effort: high
allowed-tools: Read Grep Glob Bash Write Edit
---

# Prepare PR

You are tasked with getting a change ready for review: commit any outstanding work, open a pull request, and land a **review guide** that points human attention at what matters. You don't replace code review — you make it faster by saying where to look, anchored to the lines it's about.

`Write` and `Edit` are for the PR body, the review payload, and any source fix the user explicitly asks for during a walkthrough — never for unprompted changes.

This is the final step of the research → design → plan → implement → review workflow.

## Mark the herdr phase

As your very first action, tag this agent's herdr tab so the session navigator shows the workflow phase (safe no-op outside herdr):

```bash
bash "$(git rev-parse --show-toplevel)/.claude/scripts/herdr-phase.sh" review
```

## Initial Response

Determine the mode from `$ARGUMENTS`:

- **No arguments** → **Create mode.** Commit outstanding changes on the current branch, push, open a new PR, land the guide.
- **A PR number (e.g. `123`)** → **Update mode.** Leave existing commits alone; write the guide onto that PR. Use this when a PR was created outside this skill loop.
- **A branch name** → **Create mode** targeting that branch's diff against the default branch.

Flags, anywhere in `$ARGUMENTS`:

- `--no-stops` — keep the whole guide in the PR description; post no inline comments.
- `--walk` / `--no-walk` — force or suppress the Step 7 walkthrough without asking.

If the mode is ambiguous, state your assumption and proceed; don't stall on a question you can answer from context.

## The review guide is a numbered list of stops

One artifact, three places it appears:

- **Inline review comments on the PR** — the detail, anchored to the line it's about. This is its home.
- **A numbered index in the PR description** — one line per stop, so the guide is legible without opening the diff.
- **A tuicr session**, if the author walks it — GitHub review threads render natively in `tuicr pr <n>`, so a posted review needs no seeding.

A stop is a file, a line or range, a type, and **a claim to test**. Not a description of what the code does — the reviewer is looking at the code. What they can't see is what you want them to *decide*.

> ✅ "The claim: a downgrade means 'the capability set shrank', derived from `OFFICE_CAPABILITIES` rather than a hardcoded ranking — so adding a fourth role can't silently produce a wrong answer."
>
> ❌ "This function computes whether a role change is a downgrade."

**6–10 stops for a typical PR.** Fewer than 4 and you're not guiding; more than 12 and nothing is emphasized. Types carry intent:

- `issue` — you believe something is wrong
- `note` — verify this is correct
- `suggestion` — decide whether you accept this
- `yagni` — an abstraction, config, or layer that has one caller and could be inlined until it has two

Separate "verify this is correct" from "decide whether you accept this." Load-bearing conventions with nothing enforcing them, and gaps in test coverage, are judgment calls — that's where a human's time pays off.

## Process

### Step 1: Establish the diff and gather context

1. **Determine the default branch:** `git remote show origin | sed -n '/HEAD branch/s/.*: //p'`, falling back to `main`.

2. **Determine the diff source:**
   - Create mode, current branch: `git diff [default-branch]...HEAD`
   - Create mode, named branch: `git diff [default-branch]...[branch]`
   - Update mode: `gh pr diff [number]`

3. **Read the full diff.** It is the source of truth.

4. **Check for supporting context (all optional):**
   - A design doc (`.rpi/design-*.md`) matching the recent dates or the branch name — the *intent* behind the change, and any concrete reference artifact it links.
   - The plan (`.rpi/plan-*.md`) this branch implemented. Its per-phase `### Completion` blocks record what was actually built versus specified — deviations, waivers, anything left unproven. `.rpi/` is working state that dies with the worktree, so the PR is the only durable home for anything that outlives the merge.
   - Review metadata at **the plan's name with `plan-` swapped for `review-`**. If you found a plan, that path is deterministic — read it directly rather than globbing; fall back to matching recent dates only when there's no plan in hand. Its per-file Critical / Mechanical / Tests triage was written by the agent that wrote the code, so it picks stops far better than the diff can.
   - The issue the work is tied to, if the project tracks them.
   - These sharpen the guide, but it works from the diff alone — which is exactly the case when preparing a PR for someone else's branch.

5. **Sweep for deferred work — a backstop, not the mechanism.** Reading the plan is how you find deferred work; this catches what lives elsewhere.

   ```bash
   grep -rniE "defer|owed|can'?t be verified|until (it )?(merges|deploys)|follow-up|out of scope" .rpi/ 2>/dev/null
   ```

   It matches on wording, so it misses phrasings nobody anticipated. A hit is a pointer to go read the surrounding paragraph; silence is not evidence that nothing was deferred.

### Step 2: Commit outstanding changes (create mode only)

Skip this entire step in update mode.

1. **Check the working tree:** `git status --short`.

2. **If there are uncommitted changes:**
   - Group them into a sensible commit, or a few if the work is clearly separable.
   - Run the project's verification commands first and report results — don't commit on top of a red build without flagging it.
   - Propose a commit message in this project's convention: **[CONVENTION]**, e.g. `[EXAMPLE]`. Confirm it still holds against `git log --no-merges --format=%s -10`, and follow the history if it has moved.
   - **Confirm the message with the user**, then commit.
   - Never add a "Co-authored-by" or "Generated with" trailer unless the repo's own history shows that convention.

3. **If the tree is clean**, say so and move on.

**Don't push yet.** Pushing happens in Step 5, so the branch and its guide go up together.

### Step 3: Build the stop list

This is the work. Everything downstream is formatting.

1. **Pick the stops.** Start from the review metadata's "Needs careful review" entries; fall back to reading the diff. A file earns a stop when it carries business logic, touches auth/permissions/validation/secrets, changes a data model or migration, alters an external contract, deviated from the plan, or isn't covered by tests. A `yagni` stop earns its place when the diff introduces an abstraction with one caller.

2. **Verify every anchor.** A stop's line number must fall inside a diff hunk, or GitHub rejects the whole payload in Step 6. Read the hunk headers — `@@ -old,+new @@` — from the same diff you're describing:

   ```bash
   git diff [default-branch]...HEAD -- <file>          # create mode: no PR exists yet
   gh api repos/{owner}/{repo}/pulls/<N>/files --jq '.[] | "\(.filename)\n\(.patch)"'   # update mode
   ```

   Confirm each stop's line falls in a new-side range. For a stop about a *deleted* line, use the old-side number with `side: "LEFT"`. A stop whose subject isn't in any hunk moves to the nearest in-hunk line, and says so in its text.

3. **Record the list** in your scratchpad as `n`, `path`, `line` (or `start_line`–`line`), `side`, `type`, and the claim. Steps 4, 6, and 7 all render from it, and they must not drift apart.

### Step 4: Write the PR description

**Under 60 lines.** If it's longer, the detail belongs in a stop.

```markdown
## Summary
[≤5 sentences: what this change does, why, and the approach. Link the issue.]

[Structural changes only: one tree diff, or a Mermaid sequence diagram if the forge
renders Mermaid, ≤12 lines. Reuse the design doc's shape diff, updated to what landed.]

## Review guide (N stops)
Each stop is an inline comment on the line it names.

1. `path/to/file.ext:52` — [the claim to test, one line]
2. `path/to/file.ext:118-140` — [the claim to test, one line]
...

## Test coverage
**Tested:** [behavior] — `tests/path` · [behavior] — `tests/path`
**Not tested:** [behavior] — [why]

## Deferred
[Work this PR cannot verify before merge — cloud-only surfaces, anything needing a deployed
environment. When the plan has such a section, carry its wording verbatim rather than
summarizing. Omit this heading entirely when there is nothing deferred; an empty section
trains readers to skip it.]
```

Everything else stays out. The mechanical files get **one line** at the end of the guide — "the remaining 14 files are generated migrations, import moves, and copy tweaks" — not an inventory. A reviewer who wants the file list opens the Files tab.

**With `--no-stops`, or on a forge where inline review comments aren't available**, expand each numbered index line into its full stop text under the same heading, drop the "Each stop is an inline comment" line, and skip Step 6. The description gets longer; nothing else changes.

### Step 5: Push and create the PR

Do this **before** posting the stops — inline comments need a PR to attach to.

**Create mode:**

1. Derive a concise PR title following the repo's convention.
2. Show the title and description to the user and confirm.
3. Push with upstream tracking: `git push -u origin HEAD`.
4. `gh pr create --title "..." --body-file <file>` against the default branch. Use `--body-file` to preserve formatting.
5. Return the PR URL.

**Update mode:** the PR exists — don't create anything. Push any local commits so the branch on GitHub matches the diff you described, then publish the description with `gh pr edit [number] --body-file <file>`. Leave the title alone unless it's clearly wrong; ask before changing it.

### Step 6: Post the stops as a review

Skip on `--no-stops`, or when `gh` isn't available or the forge isn't GitHub.

**In update mode, check for a guide you already posted** before adding a second one:

```bash
gh api repos/{owner}/{repo}/pulls/<N>/reviews --jq '.[] | "\(.id) \(.user.login) \(.state)"'
```

Write the payload, one entry per stop, in guide order:

```json
{
  "event": "COMMENT",
  "body": "Review guide — 7 stops, numbered in reading order. Each names a claim to test, not a description of the code.",
  "comments": [
    {
      "path": "src/hooks.server.ts",
      "line": 52,
      "side": "RIGHT",
      "body": "**STOP 1 · note** — The claim: the guard runs before session refresh, so a stale cookie can't reach the handler.\n\nWhat to verify: `refreshSession` is called on the branch below, not above.\nRisk: an expired session reads as valid for one request."
    },
    {
      "path": "src/lib/server/db/schema.ts",
      "start_line": 118,
      "line": 140,
      "side": "RIGHT",
      "body": "**STOP 2 · issue** — ..."
    }
  ]
}
```

**Confirm before posting** — the review lands on the PR under the authenticated account (`gh auth status`). Then:

```bash
gh api repos/{owner}/{repo}/pulls/<N>/reviews --input stops.json
```

Four things to know:

- **`event` is always `COMMENT`.** Never `APPROVE` or `REQUEST_CHANGES` — the guide is navigation, not a verdict, and it's the author's own PR.
- **`line` is the line in the file, on the side you name**, and must be inside a diff hunk. Ranges use `start_line`–`line`. This is what Step 3.2 verified.
- **A bad anchor rejects the whole payload with a 422** that names the offending comment. Fix that stop's line and re-post — but **check for a review that landed before you retry**, using the `reviews` call above. Never blind-retry.
- **Each stop becomes a resolvable thread.** That's the point: a reviewer ticks stops off as they go, and resolving one hides it from `tuicr pr <n>` too.

Report the review URL alongside the PR URL.

### Step 7: Walk the PR with the author (optional)

The guide you just posted is exactly the input a guided walkthrough needs — ordered stops, anchored to lines, each naming a claim to test. If [tuicr](https://github.com/agavra/tuicr) is installed and someone is there to answer, project it into their terminal instead of leaving it in a browser tab.

**Read `tuicr-walkthrough.md` in this skill's directory and follow it.** The short version: the stops are already on the PR as review threads, so `tuicr pr <n>` shows them with no seeding step — you narrate, they drive, and anything you find becomes a commit on the open PR before another reviewer is asked to look.

Offer it once and wait:

```
PR is up: <url> — 7 stops posted as inline comments. Want to walk them in tuicr?
I'll narrate each one and we can fix anything we find before anyone else looks.

Open `tuicr pr <n>` in another pane, or say "skip" and it's ready for review as-is.
```

Skip straight to Step 8 if the user declines, if `command -v tuicr` finds nothing (say so once, don't belabor it), if the diff is trivially mechanical, or if you're running unattended.

### Step 8: Reconcile

Only when Step 7 produced commits. Otherwise you're done — return the PR URL.

1. **Recompute every line reference.** Walk commits shift them all. An index pointing at `:270` when the code now lives at `:306` is worse than no line number, and GitHub marks the moved threads outdated.
2. **Add the new commits to the story.** A short note near the top for anyone who reviewed the earlier push: what moved, and — just as important — what didn't.
3. **Fold findings into the right place.** A behavior change that came out of a fix belongs in the stop it came from (reply to that thread); anything the fix left unexercised belongs under **Not tested**.
4. **Write down what you agreed to defer** under **Deferred**, added here if the original description didn't need it.
5. **Re-publish the description** with `gh pr edit [number] --body-file <file>`.

## Important Guidelines

1. **Guide attention, don't find bugs.** This is navigation, not a verdict. The stop says what to decide; the human decides it.
2. **A stop and its index line carry the same claim.** If a stop needs something the description doesn't say, the description is missing it — not the other way around.
3. **Be specific about lines.** "Review auth.ts" is useless. A stop anchored to `auth.ts:52` naming what could go wrong is the whole product.
4. **Mechanical doesn't mean unimportant** — it means it follows an established pattern and doesn't need creative review. It gets one line, not a section.
5. **Works without metadata.** With no design doc or review metadata, build the stop list from the diff. Less precise, still useful.
6. **Trust in-phase triage over reconstructed triage.** A metadata section headed `(reconstructed from the diff — not authored in-phase)` was written by an agent reading the diff, not the one that wrote the code. Check those claims against the diff before turning them into stops.
7. **Confirm before outward-facing or irreversible actions** — committing, pushing, creating the PR, posting the review. The guide itself is cheap; these are not.
8. **Match the repo's conventions** — commit style, PR title format, issue linking. Read recent history rather than imposing a style.
9. **Never launch the tuicr TUI in a foreground shell.** `tuicr`, `tuicr -w`, and `tuicr pr` are interactive and will hang your turn. You drive `tuicr review *` only.
