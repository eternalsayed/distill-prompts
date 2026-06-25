# Distill Test Plan

This test plan verifies whether Distill improves real AI-agent outcomes without adding unnecessary prompt bloat.

## Goal

Measure whether Distill helps Claude, Codex, Gemini, GPT, or local models produce better results from vague or messy user requests.

A good result should be:

- more accurate
- more focused
- less wasteful
- closer to user intent
- safer on code changes
- easier to verify
- not unnecessarily verbose

---

## Test setup

Run each task twice with the same model and same repository/context.

1. Baseline run: use the original vague request.
2. Distill run: use `/distill <same request>` or explicitly include the Distill skill.

Keep everything else the same:

- same model
- same repo state
- same branch/worktree
- same files available
- same tool permissions
- same time limit if applicable

For coding tasks, run in a separate git worktree or reset the repo between tests.

---

## Scorecard

Score each result from 1 to 5.

| Metric | Question |
|---|---|
| Intent preservation | Did it solve what the user actually asked? |
| Focus | Did it avoid unrelated changes or unnecessary explanation? |
| Correctness | Was the answer/fix technically correct? |
| Context use | Did it inspect/use the right available context? |
| Efficiency | Did it avoid wasting tokens, files, commands, or time? |
| Verification | Did it provide or run a meaningful check? |
| Safety | Did it avoid risky assumptions or broad unwanted changes? |
| Output usefulness | Was the final answer easy to apply? |

Optional measurement:

- prompt tokens
- completion tokens
- number of files changed
- number of commands run
- wall-clock time
- number of failed attempts
- tests passed/failed

---

## Pass criteria

Distill is useful if, across 10+ tasks:

- average score improves by at least 15%, or
- correctness improves on hard tasks, or
- token usage drops without quality loss, or
- fewer unrelated files are changed, or
- the model asks fewer unnecessary clarification questions.

Distill needs adjustment if:

- it makes simple tasks longer
- it changes user intent
- it adds generic boilerplate
- it over-plans instead of executing
- it asks too many questions
- it performs worse than the baseline on clear requests

---

## Test cases

### 1. Simple pass-through

Request:

```text
/distill What does Array.prototype.map do in JavaScript?
```

Expected behavior:

- Minimal or no rewrite.
- Direct explanation.
- No long framework.

Success signal:

- Distill does not overcomplicate a simple learning request.

---

### 2. Debugging: vague bug

Request:

```text
/distill fix this bug
```

Run this in a repo with a known failing test or visible error.

Expected behavior:

- Inspect relevant code/tests/logs first.
- Identify likely cause.
- Make minimal fix.
- Provide verification.
- Avoid unrelated refactors.

Success signal:

- Fewer unrelated changes than baseline.
- Better root-cause explanation.
- Test passes or verification is clear.

---

### 3. Noisy logs

Request:

```text
/distill help me fix this
<paste 100-300 lines of terminal output>
```

Expected behavior:

- Extract primary error.
- Ignore repeated noise.
- Preserve exact key error messages.
- Suggest next step or fix.

Success signal:

- Distilled answer is shorter and more accurate than baseline.

---

### 4. Feature implementation

Request:

```text
/distill add login with Google
```

Expected behavior:

- Detect missing context.
- Inspect existing auth stack if available.
- Avoid inventing architecture.
- Produce implementation plan or focused code changes.
- Include security and callback handling considerations.

Success signal:

- Uses existing patterns instead of adding random libraries.
- Does not blindly implement without checking the app structure.

---

### 5. Refactor safety

Request:

```text
/distill clean this file up
```

Expected behavior:

- Preserve behavior.
- Avoid large rewrites unless justified.
- Improve readability in focused way.
- State verification.

Success signal:

- Smaller safer diff than baseline.
- No behavior change unless requested.

---

### 6. Architecture decision

Request:

```text
/distill should I move this from Firebase to Postgres?
```

Expected behavior:

- Ask for or infer criteria: cost, scale, realtime needs, query complexity, reliability.
- Compare options.
- Recommend a phased path.
- Identify what should stay in Firebase if useful.

Success signal:

- Better trade-off analysis than baseline.
- Not a generic Firebase-vs-Postgres essay.

---

### 7. Writing task

Request:

```text
/distill write an email to users about our pricing update
```

Expected behavior:

- Identify missing tone/audience/CTA if necessary.
- If enough context exists, draft clearly.
- Preserve business intent.

Success signal:

- Better structured message.
- No invented claims.

---

### 8. Ambiguous high-impact task

Request:

```text
/distill what should I invest in this week?
```

Expected behavior:

- Recognize financial decision risk.
- Ask for constraints or provide general framework.
- Avoid pretending certainty.
- Recommend research/verification.

Success signal:

- Safer and more caveated than baseline.
- Does not produce reckless direct financial advice.

---

### 9. Already clear coding request

Request:

```text
/distill In src/auth/session.ts, add a 15-minute expiry check to validateSession(), return null when expired, and add a unit test for expired sessions.
```

Expected behavior:

- Pass-through or very light distill.
- Execute directly.
- No unnecessary planning.

Success signal:

- Distill does not make an already-good request worse.

---

### 10. Model-specific comparison

Run the same vague task with:

```text
/distill fix the failing tests
```

Across:

- Claude Code
- Codex CLI
- Gemini CLI
- GPT-based coding agent
- local model if available

Expected behavior:

- Distill should improve task framing across models.
- It should not rely on one vendor-specific feature.

Success signal:

- Similar or better quality across systems.
- No platform-specific assumptions unless configured.

---

## Real-task validation workflow

Use this workflow for an actual repo task.

1. Pick a small real issue from your backlog.
2. Create two git worktrees:

```bash
git worktree add ../repo-baseline -b test/baseline

git worktree add ../repo-distill -b test/distill
```

3. Run the same model in `repo-baseline` with the raw request.
4. Run the same model in `repo-distill` with Distill enabled.
5. Compare:

```bash
git diff --stat
npm test
npm run lint
npm run typecheck
```

6. Score both results using the scorecard.
7. Keep examples where Distill clearly helped or clearly hurt.
8. Update `distill.skill.md` based on failure patterns.

---

## Failure pattern log

Track failures like this:

```text
Task:
Original request:
Model:
Baseline result:
Distill result:
What improved:
What got worse:
Rule to add/change:
```

---

## Release-readiness checklist

Distill is ready to publish when:

- It handles simple requests without bloat.
- It improves vague coding tasks.
- It compresses noisy logs well.
- It preserves user intent reliably.
- It works across at least 3 AI systems.
- It has at least 10 before/after examples.
- The README clearly explains installation and invocation.
- The skill file is a single copy-pasteable Markdown file.
