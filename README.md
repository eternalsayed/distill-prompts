# Distill

**A Claude Code skill that turns vague, messy, or under-specified requests into clear, efficient AI-ready instructions — while preserving your intent.**

Use it on-demand, or run it always-on. Either way, if your request is already clear, Distill does nothing.

```
/distill fix this bug
/distill migrate this project from Firebase to Postgres
/distill help me figure out why this test keeps flaking
```

---

## Why this is different

Most "prompt optimizer" tools always do something — they rewrite every prompt, even clear ones. Distill has a genuine **pass-through mode**: when the request is already good, it proceeds without touching it.

Combined with **task-type profiles** (debugging vs refactoring vs architecture vs writing each get different treatment), this means always-on Distill doesn't add noise to requests that don't need it.

| | Distill | prompt-improver | prompt-optimizer | Ponytail |
|---|---|---|---|---|
| Always-on mode | ✅ Optional | ✅ Default only | ✅ Default only | ✅ Default only |
| Explicit `/distill` mode | ✅ | ❌ | ✅ `/optimize` | ❌ |
| Pass-through (no-op on clear requests) | ✅ Core feature | ❌ | ❌ | ❌ |
| Task-type profiles | ✅ 7 profiles | ❌ | ❌ | Code only |
| Compression mode for logs/output | ✅ | ❌ | ❌ | ❌ |
| Per-request off switch | ✅ `--raw` | ❌ | ❌ | ❌ |
| Dependencies | None | Hook + marketplace | Go binary + UI | Hook + marketplace |
| Portability | Any LLM system | Claude Code only | Claude Code only | Claude Code + others |

[Ponytail](https://github.com/DietrichGebert/ponytail) and Distill are complementary — Ponytail makes the AI write less code; Distill makes your request clearer before it writes anything.

---

## Modes

### Explicit mode (default)

You invoke `/distill` when you want it. Everything else is untouched.

```
/distill fix this bug
/distill should we move to a monorepo?
/distill <paste 200 lines of terminal output>
```

### Always-on mode

Distill runs on every request. Clear requests pass through unchanged. Vague or complex ones get distilled first.

**To skip on a single request:**

```
--raw just tell me what this function returns
```

**To disable globally:** remove the always-on snippet from your config (see setup below).

---

## Install

### Claude Code — explicit mode

```bash
# Clone the repo
git clone https://github.com/eternalsayed/distill-prompts.git

# Create the skill directory
mkdir -p ~/.claude/skills/distill

# Copy the skill file
cp distill-prompts/distill.skill.md ~/.claude/skills/distill/SKILL.md
```

Add this to `~/.claude/CLAUDE.md`:

```markdown
# distill
- **distill** (`~/.claude/skills/distill/SKILL.md`) — converts vague requests into clear AI-ready instructions. Trigger: `/distill`
When the user types `/distill`, invoke the Skill tool with `skill: "distill"` before doing anything else.
```

Restart Claude Code. Type `/distill` to confirm it appears in your skills.

### Claude Code — always-on mode

Complete the explicit mode setup first, then **also** add this to `~/.claude/CLAUDE.md`:

```markdown
# distill (always-on)
Before answering any request, silently apply Distill using the skill at `~/.claude/skills/distill/SKILL.md`.
Choose the appropriate mode (pass-through, light, structured, context-seeking, or compression) based on the request.
Skip distill and proceed directly if the user prefixes their message with `--raw`.
```

To disable always-on: remove that block from your CLAUDE.md. The explicit `/distill` skill stays available.

---

### Codex CLI

Paste the body of `distill.skill.md` (the content below the `---` frontmatter) into your `AGENTS.md` or `CODEX.md`.

- Explicit: prefix requests with `distill this:` or `use distill:`
- Always-on: add `"Before answering any request, apply Distill. Skip if the user writes --raw."` to the top of the file.

---

### Cursor

Add the body of `distill.skill.md` to `.cursorrules` in your project root, or to **Settings → Rules for AI**.

- Explicit: prefix requests with `distill this:`
- Always-on: add the always-on instruction to the top of your rules file.

---

### Gemini CLI

Paste the body of `distill.skill.md` into `GEMINI.md` in your project root or `~/.gemini/GEMINI.md`.

- Explicit: prefix with `distill this:`
- Always-on: add the always-on instruction to the top of `GEMINI.md`.

---

### Any other LLM system

Copy the body of `distill.skill.md` into the system prompt or custom instructions.

- Explicit: prefix with `distill this:`
- Always-on: add `"Apply Distill to every request. Skip if the user writes --raw."` to the system prompt.

---

## How Distill works

Before solving, Distill evaluates the request and picks one of five modes automatically:

| Mode | When used |
|---|---|
| **Pass-through** | Request is already clear — proceeds without rewriting |
| **Light distill** | Slightly vague or wordy — clarifies objective, removes noise |
| **Structured distill** | Complex, multi-step, or high-risk — adds a full execution brief |
| **Context-seeking** | Missing context would change the answer — asks the minimum needed |
| **Compression** | Noisy logs, diffs, or pasted output — extracts signal only |

### Task profiles

Different task types get different treatment:

- **Debugging** — observed vs expected behavior, root cause, minimal fix, verification step
- **Code implementation** — feature goal, affected areas, edge cases, acceptance criteria
- **Refactor** — behavior preservation, boundaries, risk areas, diff focus
- **Architecture / design** — trade-offs, constraints, recommended path, migration plan
- **Writing / communication** — audience, tone, key message, length
- **Learning / explanation** — knowledge level, depth, examples only where useful
- **Research / comparison** — criteria, options, freshness, sourced recommendation

### Restraint rules

Distill is explicitly designed not to pad:

- No fake expertise, fake citations, or invented context
- No framework unless the task needs it
- No clarifying questions unless missing information actually changes the result
- No rewriting the user's actual deliverable unless asked
- Pass-through when the request is already good

---

## Examples

### Compress noisy logs

```
/distill help me debug this
<paste 200 lines of terminal output>
```

Extracts the primary error, relevant file/version details, and likely cause — then solves from there.

### Architecture decisions

```
/distill migrate Firestore to Postgres
```

Identifies missing constraints, proposes a phased plan, flags what should stay vs move.

### See what Distill produced

```
/distill explain docker to me
> what did you distill this into?
```

---

## Files

| File | Purpose |
|---|---|
| `distill.skill.md` | The skill — install as `~/.claude/skills/distill/SKILL.md` |
| `distill-test-plan.md` | Before/after methodology to verify Distill improves real tasks |

---

## Contributing

If Distill makes a request worse, open an issue with the original request, what Distill produced, and what you expected. That's the most useful signal for improving the task profiles and restraint rules.

---

## License

MIT
