# Review Metadata: [Feature Name]

Plan: `.rpi/plan-YYYY-MM-DD-description.md`

One section per phase, appended as each phase completes. Do not rewrite earlier
sections — a later phase that supersedes an earlier one says so in its own
section, or in the Summary.

## Phase 1 — [title]

### Needs careful review

- `path/to/file.ext:45-89` — [what makes it load-bearing or security-sensitive]

### Mechanical

- `path/to/types.ext` — [type mirror / import move / copy-only edit]

### Tests

- **Proves**: [what this phase's tests actually establish] — `tests/path/test.ext`
- **Does not prove**: [what can't be shown end to end, and why]

### Deliberate non-fixes

- [known-imperfect thing left alone, and why it was a decision]

## Phase 2 — [title]

[…same shape…]

## Summary

_Written on the last phase only._

- **Open first**: [the files a reviewer should read before the rest]
- **Unproven across the change**: [what no test or manual step covers]
- **Superseded**: [anything a later phase changed about an earlier one]
