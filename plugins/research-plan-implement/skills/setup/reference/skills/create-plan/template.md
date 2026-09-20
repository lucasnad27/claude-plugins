# [Feature/Task Name] Implementation Plan

## Overview
[1-2 sentence summary of what we're implementing]

## Design Reference
- Design: `.rpi/design-YYYY-MM-DD-description.md`
- Research: `.rpi/research-YYYY-MM-DD-description.md` (if applicable)
- Ticket: [reference if applicable]

## Implementation Approach
[High-level strategy — keep brief, the design doc has the details]

## What We're NOT Doing
[Copy from design doc — prevents scope creep during implementation]

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes — should be a vertical slice, not a horizontal layer]

### Changes Required:

#### 1. [Component/File Group]
**File**: `path/to/file.ext`
**Changes**: [Summary of changes]

```[language]
// Specific code to add/modify
```

### Verification:

#### Tests to write:
[Name real files and real test cases — this is the phase's spec, not a reminder to test.
The implementing agent should be able to create these files from this block alone.]

**File**: `path/to/feature.test.ext`

```[language]
// Signatures and cases this phase must satisfy
test('rejects a request with no auth header', ...)
test('returns 403 when the role lacks the permission', ...)
test('passes through when the permission is granted', ...)
```

#### Automated:
- [ ] [Specific test command]: `test command here`
- [ ] [Lint/typecheck]: `lint command here`

#### Manual:
- [ ] [Verification step requiring human eyes, if applicable]

**What "green" looks like:** [Concrete description — the actual output, status code, or
observable behavior that means this phase is done]

**After automated verification passes, pause for manual confirmation before proceeding to the next phase.**

### Completion
_`/implement-plan` fills this in when the phase finishes. Leave it as-is when writing the plan._

- **Status**: not started
- **Deviations**: —
- **Waived or unproven**: —
- **Later phases must know**: —

---

## Phase 2: [Descriptive Name]
[Same structure — vertical slice with per-phase testing, ending in its own Completion block]

---

## References
- Design: `.rpi/design-[file].md`
- Research: `.rpi/research-[file].md`
- Similar implementation: `[file:line]`
