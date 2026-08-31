# Claude Code Plugins

A marketplace of Claude Code plugins for AI-assisted development workflows.

## Research → Design → Plan → Implement → Review

**Install the plugin, run `/setup`, and you have a full workflow adapted to your codebase and your team's SDLC.**

No templates to fill in and no config to maintain. `/setup` reads your build system, test runner, linter, framework, issue tracker, commit convention, and forge, then writes six skills and eight agents into `.claude/` phrased in your project's own vocabulary. As the plugin improves, update it and re-run `/setup` — your own edits are carried forward, not clobbered.

```bash
/plugin marketplace add lucasnad27/claude-plugins
/plugin install research-plan-implement@research-plan-implement-workflow
```

In VS Code, install it through **Chat: Install Plugin From Source** (`Cmd/Ctrl+Shift+P`) with the same repo, and set `"chat.useAgentSkills": true`. Full steps are in the [plugin README](plugins/research-plan-implement/README.md#install).

Then, in your project: `/setup`, then `/guide`.

### Why put friction back in

![No slop, all vibes — three charts contrasting lines of code against understanding of code, pre-AI, with AI and no friction, and with AI plus deliberate friction; below them the six workflow steps and the human checkpoint at each](docs/no-slop-all-vibes.png)

Before coding agents, understanding was a byproduct of typing — you could not ship a system you did not understand, because writing it *was* how you understood it. Agents severed that link. Point one at a repo and stay out of its way and you get the middle panel: **accumulating code quicker than we are accumulating trust.**

Trust is what actually ships. Code nobody understands cannot be reviewed honestly, debugged at 2am, or safely changed six months later. So this workflow puts a human back at the six points where understanding gets created — issue, research, design, plan, implement, review — and writes down what was understood so the next context can pick it up.

The right panel is the payoff: both lines climb. You do not trade speed for comprehension. **No slop, all vibes.**

[Read the full documentation →](plugins/research-plan-implement/README.md)

### The phases

| Skill | Phase |
| --- | --- |
| `/research-codebase` | 🔬 What exists today, written down. No opinions. |
| `/design-doc` | 🎨 What we're going to do, argued and settled. |
| `/create-plan` | 📋 Vertical phases, each independently verifiable. |
| `/implement-plan` | 🔨 Phase by phase. Tests alongside code. Pause between. |
| `/prepare-pr` | 🔍 PR opened, diff annotated with numbered stops. |
| `/guide` | Contextual orientation — where am I, what's next. |

`/setup` shapes the workflow around the SDLC you already have — your build system, tracker, forge, review norms, deploy gate. A few agent-native tools we like are wired in and entirely optional: [herdr](https://herdr.dev) phase tags, [tuicr](https://tuicr.dev) PR walkthroughs, and design tooling like [Paper](https://paper.design) or [impeccable](https://impeccable.style). Use none of them and nothing breaks.

## Attribution

Inspired by [HumanLayer's](https://humanlayer.dev) research on context engineering for AI-assisted development:

- **Website:** [humanlayer.dev](https://humanlayer.dev)
- **GitHub:** [humanlayer/humanlayer](https://github.com/humanlayer/humanlayer)
- **AI Engineering Talk:** [YouTube](https://youtu.be/rmvDxxNubIg?si=WtKgAdi6MydW8u-i)

Full attribution, including [ponytail](https://github.com/DietrichGebert/ponytail), is in the [plugin README](plugins/research-plan-implement/README.md#attribution).

## License

MIT
