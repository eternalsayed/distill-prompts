# Distill

**A Claude Code skill that turns vague, messy, or under-specified requests into clear, efficient AI-ready instructions — while preserving your intent.**

Use it on-demand, or run it always-on. Either way, if your request is already clear, Distill does nothing.

```
/distill fix this bug
/distill migrate this project from Firebase to Postgres
/distill help me figure out why this test keeps flaking
```

---

## Install

### Claude Code — one line

```bash
curl -fsSL https://raw.githubusercontent.com/eternalsayed/distill-prompts/main/install.sh | bash
```

Installs the skill and updates your `~/.claude/CLAUDE.md` automatically. Start a new Claude Code session and type `/distill` to confirm.

### Always-on mode

After installing, add this block to `~/.claude/CLAUDE.md`:

```markdown
# distill (always-on)
Before answering any request, silently apply Distill using the skill at `~/.claude/skills/distill/SKILL.md`.
Choose the appropriate mode (pass-through, light, structured, context-seeking, or compression) based on the request.
Skip distill and proceed directly if the user prefixes their message with `--raw`.
```

To turn off always-on: remove that block. The explicit `/distill` skill stays.  
To skip on a single request: prefix with `--raw`.

```
--raw just tell me what this function returns
```

### Manual install

<details>
<summary>Expand for step-by-step</summary>

```bash
mkdir -p ~/.claude/skills/distill
curl -fsSL https://raw.githubusercontent.com/eternalsayed/distill-prompts/main/distill.skill.md \
  -o ~/.claude/skills/distill/SKILL.md
```

Then add to `~/.claude/CLAUDE.md`:

```markdown
# distill
- **distill** (`~/.claude/skills/distill/SKILL.md`) — converts vague requests into clear AI-ready instructions. Trigger: `/distill`
When the user types `/distill`, invoke the Skill tool with `skill: "distill"` before doing anything else.
```

</details>

---

### Other AI systems

Distill is a plain Markdown file. Paste the body of `distill.skill.md` (below the `---` frontmatter) into any system that supports custom instructions.

| System | Config file | Trigger |
|---|---|---|
| Codex CLI | `AGENTS.md` or `CODEX.md` | `distill this:` or `use distill:` |
| Cursor | `.cursorrules` or Settings → Rules for AI | `distill this:` |
| Gemini CLI | `GEMINI.md` | `distill this:` |
| Any LLM | system prompt / custom instructions | `distill this:` |

For always-on in any of these, add `"Apply Distill to every request. Skip if the user writes --raw."` to the top of the config file.

---

## Why this is different

Most prompt optimizer tools always do something — they rewrite every prompt, even clear ones. Distill has a genuine **pass-through mode**: when the request is already good, it proceeds without touching it.

Combined with **task-type profiles** (debugging vs refactoring vs architecture vs writing each get different treatment), this means always-on Distill doesn't add noise to requests that don't need it.

| | Distill | prompt-improver | prompt-optimizer | Ponytail |
|---|---|---|---|---|
| Always-on mode | ✅ Optional | ✅ Default only | ✅ Default only | ✅ Default only |
| Explicit `/distill` mode | ✅ | ❌ | ✅ `/optimize` | ❌ |
| Pass-through (no-op on clear requests) | ✅ Core feature | ❌ | ❌ | ❌ |
| Task-type profiles | ✅ 7 profiles | ❌ | ❌ | Code only |
| Compression mode for logs/output | ✅ | ❌ | ❌ | ❌ |
| Per-request off switch (`--raw`) | ✅ | ❌ | ❌ | ❌ |
| Dependencies | None | Hook + marketplace | Go binary + UI | Hook + marketplace |
| Portability | Any LLM system | Claude Code only | Claude Code only | Claude Code + others |

[Ponytail](https://github.com/DietrichGebert/ponytail) and Distill are complementary — Ponytail makes the AI write less code; Distill makes your request clearer before it writes anything.

---

## How it works

Before solving, Distill evaluates the request and picks one of five modes automatically:

| Mode | When used |
|---|---|
| **Pass-through** | Request is already clear — proceeds without rewriting |
| **Light distill** | Slightly vague or wordy — clarifies objective, removes noise |
| **Structured distill** | Complex, multi-step, or high-risk — adds a full execution brief |
| **Context-seeking** | Missing context would change the answer — asks the minimum needed |
| **Compression** | Noisy logs, diffs, or pasted output — extracts signal only |

### Task profiles

- **Debugging** — observed vs expected behavior, root cause, minimal fix, verification step
- **Code implementation** — feature goal, affected areas, edge cases, acceptance criteria
- **Refactor** — behavior preservation, boundaries, risk areas, diff focus
- **Architecture / design** — trade-offs, constraints, recommended path, migration plan
- **Writing / communication** — audience, tone, key message, length
- **Learning / explanation** — knowledge level, depth, examples only where useful
- **Research / comparison** — criteria, options, freshness, sourced recommendation

### Restraint rules

- No fake expertise, fake citations, or invented context
- No clarifying questions unless missing information actually changes the result
- No framework added unless the task needs it
- No rewriting the user's actual deliverable unless asked
- Pass-through when the request is already good

---

## Examples

**Compress noisy logs**
```
/distill help me debug this
<paste 200 lines of terminal output>
```
Extracts the primary error, relevant file/version details, and likely cause — then solves from there.

**Architecture decision**
```
/distill migrate Firestore to Postgres
```
Identifies missing constraints, proposes a phased plan, flags what should stay vs move.

**Inspect what Distill produced**
```
/distill explain docker to me
> what did you distill this into?
```

---

## Files

| File | Purpose |
|---|---|
| `distill.skill.md` | The skill — installed as `~/.claude/skills/distill/SKILL.md` |
| `install.sh` | One-line installer for Claude Code |
| `distill-test-plan.md` | Before/after methodology to measure Distill's impact |

---

## Contributing

If Distill makes a request worse, open an issue with the original request, what Distill produced, and what you expected. That's the most useful signal for improving the task profiles and restraint rules.

---

## License

MIT
