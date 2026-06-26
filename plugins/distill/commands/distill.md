---
description: Convert a vague or under-specified request into a clear, efficient AI-ready instruction
---

# Distill

A universal AI skill that turns vague, messy, or under-specified user requests into clearer, more useful instructions before solving them.

Distill does **not** exist to make prompts longer. It exists to preserve the user's intent, reduce ambiguity, add structure only when useful, and help the underlying AI produce a better result with less waste.

Use it with:

```text
/distill fix this bug
```

```text
@distill help me migrate this project
```

```text
distill this: review my API design
```

```text
Use Distill before answering: explain why this test fails
```

---

## Invocation modes

Distill supports two invocation modes. The behavior — modes, profiles, restraint rules — is identical in both.

### Explicit mode (default)

Triggered manually with `/distill`, `@distill`, or `distill this:`. Does nothing on other requests.

### Always-on mode

Applied automatically to every request. When a request is already clear, Distill passes through without rewriting. When the input is noisy, vague, or complex, it distills first.

**To skip Distill on a single request in always-on mode**, prefix with `--raw`:

```text
--raw just tell me what this function returns
```

**To disable always-on globally**, remove the always-on snippet from your CLAUDE.md or equivalent config file.

See the README for setup instructions per platform.

---

## Core instruction

When Distill is invoked, do not immediately solve the user's request.

First, transform the request into the most useful execution form for the current AI model, task type, and available context.

Then proceed using the distilled version unless the user explicitly asks to only produce the distilled request.

Distill must behave like a careful editor, not a prompt bloat generator.

---

## Prime directive

Preserve the user's intent.

Improve only what helps the AI understand, plan, execute, verify, or explain the task better.

Do not add requirements the user did not ask for or clearly imply.

Do not overcomplicate simple requests.

Do not ask clarifying questions unless the missing information materially changes the result.

---

## Invocation detection

Treat any of the following as invoking Distill:

- `/distill ...`
- `@distill ...`
- `distill ...`
- `distill this ...`
- `use distill ...`
- `sharpen this ...`
- `polish this ...`
- `make this clearer for AI ...`
- `turn this into a better request ...`

If the user only asks to install, describe, edit, or discuss Distill, do not run Distill on their request unless they explicitly ask you to.

---

## Operating modes

Choose one mode automatically.

### 1. Pass-through

Use when the request is already clear, simple, and low risk.

Behavior:

- Keep the original request.
- Do not expand it.
- Proceed directly.

Optional visible note:

```text
Distill: no rewrite needed.
```

### 2. Light distill

Use when the request is understandable but slightly vague, wordy, or unfocused.

Behavior:

- Clarify the objective.
- Remove noise.
- Preserve tone and intent.
- Add only minimal structure.

### 3. Structured distill

Use when the request is complex, multi-step, high-risk, technical, ambiguous, or likely to benefit from planning.

Behavior:

- Identify the task type.
- State the objective.
- Capture constraints.
- Define assumptions.
- Choose execution strategy.
- Specify expected output.
- Add verification steps where useful.

### 4. Context-seeking distill

Use when missing context would materially affect the answer.

Behavior:

- Ask the fewest necessary questions.
- Explain what is blocked.
- If partial progress is possible, provide a safe partial answer while asking.

### 5. Compression distill

Use when the input contains long logs, repeated output, large diffs, pasted files, or noisy terminal output.

Behavior:

- Extract only relevant errors, facts, versions, filenames, commands, stack traces, and symptoms.
- Remove repetition.
- Preserve exact error messages when important.
- Produce a compact execution brief.

---

## Distill decision process

Before solving, silently evaluate:

1. What is the user actually trying to achieve?
2. Is the request already good enough?
3. What task type is this?
4. What context is present?
5. What context is missing?
6. What constraints did the user state or imply?
7. What output format would be most useful?
8. Is this task better handled by direct answer, plan, code, checklist, diagnosis, rewrite, or step-by-step execution?
9. Would expanding the request improve the result, or only waste tokens?
10. What should the model avoid doing?

---

## Task profiles

Use these profiles to shape the distilled request.

### Debugging

Distill toward:

- observed behavior
- expected behavior
- error messages
- likely affected files/components
- reproduction steps if available
- minimal safe fix
- verification command/test
- avoid speculative rewrites

Preferred execution instruction:

```text
Inspect the relevant code and evidence first. Identify the smallest likely cause. Make the minimal fix. Explain the change. Provide a verification step.
```

### Code implementation

Distill toward:

- feature goal
- affected areas
- constraints
- data flow
- edge cases
- tests
- acceptance criteria

Preferred execution instruction:

```text
Implement the requested feature with minimal disruption to existing architecture. Preserve existing style. Include tests or verification steps when feasible.
```

### Refactor

Distill toward:

- reason for refactor
- boundaries
- non-goals
- behavior preservation
- risk areas
- verification

Preferred execution instruction:

```text
Refactor without changing behavior. Keep the diff focused. Explain any behavior-affecting changes separately.
```

### Architecture / design

Distill toward:

- objective
- scale assumptions
- constraints
- trade-offs
- alternatives
- recommended path
- migration plan

Preferred execution instruction:

```text
Compare practical options, state trade-offs, recommend one path, and include implementation steps.
```

### Writing / communication

Distill toward:

- audience
- goal
- tone
- key message
- constraints
- desired length

Preferred execution instruction:

```text
Preserve the user's intended message while improving clarity, structure, and usefulness for the target audience.
```

### Learning / explanation

Distill toward:

- current knowledge level if known
- concept to explain
- depth
- examples
- misconceptions

Preferred execution instruction:

```text
Explain clearly at the right depth. Use examples only where they improve understanding.
```

### Research / comparison

Distill toward:

- decision to make
- criteria
- current options
- constraints
- freshness requirements
- source quality

Preferred execution instruction:

```text
Answer with current, sourced information where needed. Compare options against the user's criteria and make a recommendation.
```

---

## Output behavior

By default, after Distill is invoked:

1. Create the distilled request silently.
2. Solve the distilled request.
3. Do not show the distilled request unless useful.

Show the distilled request when:

- the user asks for the transformed prompt/request only
- the request is complex and the user would benefit from seeing the execution brief
- the user is testing Distill
- the user asks "what did you distill this into?"

When visible, use this format:

```text
Distilled request:
<clear execution request>
```

Then continue with the answer if appropriate.

---

## Distilled request template

Use this template only when structure helps. Do not force it onto simple requests.

```text
Task: <what needs to be done>

Context: <relevant information already provided>

Goal: <desired outcome>

Constraints:
- <constraint 1>
- <constraint 2>

Approach:
- <step 1>
- <step 2>
- <step 3>

Output:
- <expected format>

Verification:
- <how to check correctness>

Avoid:
- <things the AI should not do>
```

---

## Restraint rules

Distill must follow these rules:

- Prefer shorter distilled requests when they preserve quality.
- Do not add fake expertise, fake citations, or invented context.
- Do not turn every request into a long framework.
- Do not add tests unless they are useful for the task.
- Do not force "act as an expert" unless role framing improves output.
- Do not ask for confirmation when a reasonable assumption is enough.
- Do not remove emotional nuance from personal requests.
- Do not rewrite the user's actual deliverable unless asked.
- Do not reveal hidden reasoning.
- Do not claim certainty where evidence is missing.

---

## Quality bar

A good Distill result should be:

- faithful to the original intent
- clearer than the original request
- no longer than necessary
- easier for an AI agent to execute
- less ambiguous
- less likely to cause wasted work
- safer for code, legal, medical, finance, or other high-impact tasks
- explicit about assumptions when assumptions matter

---

## Examples

### Example 1

User:

```text
/distill fix this bug
```

Distilled request:

```text
Task: Diagnose and fix the bug with the smallest safe change.

Approach:
- Inspect the relevant code, error output, and recent changes first.
- Identify the likely root cause before editing.
- Make a focused fix that preserves existing behavior.
- Explain what changed and why.
- Provide a command or manual step to verify the fix.

Avoid:
- Broad refactors.
- Guessing without inspecting available context.
- Changing unrelated files.
```

### Example 2

User:

```text
distill this: make my app faster
```

Distilled request:

```text
Task: Identify practical performance improvements for the app.

Approach:
- First determine which part of the app is slow: load time, runtime UI, API, database, build, or infrastructure.
- Use available measurements if present.
- Prioritize fixes by expected impact and implementation effort.
- Suggest quick wins first, then deeper improvements.

Output:
- Likely bottlenecks
- Recommended actions
- How to measure improvement

Avoid:
- Generic performance advice not connected to the app.
```

### Example 3

User:

```text
@distill migrate firestore to postgres
```

Distilled request:

```text
Task: Plan a safe migration from Firestore to Postgres.

Goal: Reduce Firestore cost/usage while preserving realtime behavior where Firestore is still valuable.

Approach:
- Identify which collections should move first based on read/write volume, query patterns, and migration risk.
- Propose a Postgres schema and indexing strategy.
- Define dual-write or phased migration steps.
- Include rollback, validation, and monitoring.
- Keep realtime/high-churn presence-like data in Firestore if that remains cheaper and simpler.

Output:
- Migration plan
- Schema outline
- Step-by-step implementation tasks
- Risk and rollback plan
```

### Example 4

User:

```text
/distill explain docker to me
```

Distilled request:

```text
Explain Docker in simple terms for someone who writes code but may not know container internals. Cover what problem Docker solves, how images and containers differ, and when Docker is useful. Use one practical example. Avoid unnecessary low-level detail.
```

### Example 5

User:

```text
/distill summarize this noisy terminal output
<pasted logs>
```

Distilled request:

```text
Task: Extract the useful debugging signal from the pasted terminal output.

Output:
- Primary error
- Relevant command
- Relevant file/path/package/version details
- Likely cause
- Next diagnostic step
- Suggested fix if evidence is sufficient

Avoid:
- Repeating the full logs
- Treating repeated warnings as separate issues unless they have distinct causes
```
