# Design: [Feature/Task Name]

## Current State
[What exists today, 3-5 sentences. Enough to ground the conversation, not a full audit.]

## Desired End State
[What does "done" look like? How will we know it works? This is the spec, not the implementation.]

## Patterns to Follow
[Which existing codebase patterns should we model after, with file:line references.]
[This is where you catch the agent following the wrong example before it writes code.]

## Concrete Reference
[The highest-fidelity artifact you can produce for this work. Prose describing an
interface or a contract is the weakest form of spec — replace it with the real thing
wherever the shape of the work allows:]

[If it's UI work:]
- Write a self-contained HTML mockup to `.rpi/design-YYYY-MM-DD-description.html`
  and link it here. A mockup settles layout, states, and copy in one pass — arguments
  that prose would leave unresolved until implementation.
- Include the states that matter: empty, loading, error, populated.

[If it's API work:]
- Write the actual request/response shapes — real JSON, real status codes, real error
  bodies. Not "returns the user object."

[If it's a data model change:]
- Write the actual schema diff or migration sketch.

[If it's internal logic:]
- Write the function signatures and type definitions the implementation will satisfy.

[If it changes structure — a refactor, a new module, rewired calls or components:]
- Show the shape of the change as a diff of the call tree, file tree, or component
  tree: context lines for what stays, `+`/`-` for what changes. Shape only; the code
  is `/create-plan`'s.

  ```diff
   handleRequest
     authenticate
  +  checkPermission(scope)
     loadResource
  ```

[This section is optional only when the work genuinely has no interface — otherwise
it's the most valuable part of the document.]

## Testing Approach
[How should we verify this works? Adapt to the project:]

[If the codebase has good test infrastructure:]
- Name the specific test files that will be added or changed, with the cases each covers
- Reference existing test patterns found in research

[If it's API work:]
- Suggest conformance-style testing: define expected behavior, test against it
- Reference endpoints that could be exercised via curl or similar

[If it's UI work:]
- Suggest manual testing steps the agent can help execute, tied to the mockup above
- Reference any existing UI test patterns

[If the codebase has minimal tests:]
- Frame as: "What would give you confidence this works?"
- Help the user think through verification strategies

[Always:]
- Surface what test patterns already exist in the project
- Suggest the testing approach that fits the shape of this work

## Key Decisions
[Resolved design choices with brief rationale. Things like:]
- "Using the existing queue system rather than adding a new dependency because X"
- "Following the v2 auth pattern, not the legacy one, because Y"

## Open Questions
[Anything you're unsure about — these will be walked through interactively.]

## What We're NOT Doing
[Explicit scope boundaries to prevent creep.]
