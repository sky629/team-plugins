
## Coding guidelines
For any coding task (writing, editing, refactoring, or debugging code), use the `andrej-karpathy-skills:karpathy-guidelines` skill and follow it: think before coding (surface assumptions/tradeoffs), simplicity first, surgical changes, goal-driven execution with verifiable success criteria.

## Problem solving
- Leave no legacy. When a design changes, remove the fields, functions, tests, and docstrings of the earlier design in the same change; HEAD must describe exactly one design.
- Do not overfit to the case at hand. A prompt sentence, regex, or branch that enumerates the specific example or type is a patch for that example only. Fix the class of cases, not the example.
- Prefer the root-cause fix even when it touches more code. Present a symptom patch only alongside the fundamental fix, and say which is which.

When these rules conflict with the coding-guidelines skill, these rules win.

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
Use images, diagrams, and HTML output actively. Do not limit answers to text and tables.
- When a structure, flow, comparison, or data set is easier to understand as a picture, make a diagram or chart.
- When an answer is long or has many parts (report, design, review), deliver it as an HTML document.
- Use the diagram, chart, and artifact skills when they are available.
- Keep the main conclusion in the text answer, and give the path or URL of each output file.
