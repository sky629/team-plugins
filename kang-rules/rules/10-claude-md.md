
## Coding guidelines
Apply these guidelines to every coding task (writing, editing, refactoring, or debugging code).

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly.
- If multiple interpretations exist and the choice is hard to reverse or changes the scope, present them and ask. Otherwise pick one, state it, and continue.
- If a simpler approach exists, say so. Push back when warranted.
- Stop and ask only when you cannot continue without the answer. Name what is unclear.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what the change needs. Clean up everything the change makes obsolete.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken. A root-cause fix is not such a refactor.
- Match existing style, even if you'd do it differently.
- If you notice dead code that is unrelated to the change, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code that is unrelated to the change unless asked.

The test: Every changed line should trace directly to the user's request, to its root cause, or to the design it replaces.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

When the project's CLAUDE.md defines a test-first procedure, follow it. Otherwise write the test first when a cheap local test target exists or the user asks for it, and verify with the project's existing checks in other cases.

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Problem solving
- Leave no legacy. When a design changes, remove the fields, functions, tests, and docstrings of the earlier design in the same change; HEAD must describe exactly one design.
- Do not overfit to the case at hand. A prompt sentence, regex, or branch that enumerates the specific example or type is a patch for that example only. Fix the class of cases, not the example.
- Prefer the root-cause fix even when it touches more code. Present a symptom patch only alongside the fundamental fix, and say which is which.

## Working rules
- Do not commit, push, or merge to a shared branch (main, develop, or an environment branch) unless the user tells you to. Work on a task branch.
- Create a pull request only after the user approves it. "Push" does not mean "create a PR".
- For writes outside the repository (Notion, GitHub issues and comments, published pages), prepare a draft and wait for approval.
- Use ego-browser for all browser work. Do not use Playwright MCP or claude-in-chrome.
- Write code comments for the current design only. Do not put dates, ticket or trace IDs, environment names, or design history in them.
- Use the superpowers brainstorming and writing-plans skills only for new features and design changes. Skip them for bug fixes with a known cause, documentation, and configuration changes.
- Save superpowers specs and plans outside the repository (default `~/Documents/dev/superpowers/`). Do not commit them.

## Answer style
Write answers with the structural rules of ASD-STE100 (Simplified Technical English). Keep the answer language; apply these rules in any language:
- One topic per sentence.
- Use the active voice.
- Use one term for one meaning, and use the same term every time.
- Write procedures as numbered steps, one instruction per step, in the imperative.
- Max 6 sentences per paragraph.
- Do not use idioms or vague words.

Apply these rules at about 80% strictness. When a rule makes a sentence unnatural or harder to read, relax that rule.

Sentence length is not a target. Never shorten a sentence by dropping particles, endings, or adverbs that carry meaning.
For Korean, KOREAN.md governs the sentence and word level; this section governs structure. When they conflict, KOREAN.md wins at the sentence level.

## Visual output
- When a structure, flow, comparison, or data set is easier to understand as a picture, make a diagram or chart.
- Deliver a report, design, or review as an HTML document when it has more than three tables or figures, or when the user asks for a document. Otherwise answer in text.
- Keep the main conclusion in the text answer, and give the path or URL of each output file.
