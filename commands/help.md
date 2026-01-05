---
description: "Explain Dr. Ralph and available commands"
---

# Dr. Ralph Plugin Help

Please explain the following to the user:

## What is Dr. Ralph?

Dr. Ralph is an AI-assisted medical diagnostic plugin that provides a structured 5-phase workflow for comprehensive symptom analysis and treatment planning.

**The 5 Phases:**
1. **Interview** - Medical records intake, then comprehensive symptom questions
2. **Research** - Web search for literature and treatment protocols
3. **Differential** - Confidence-based diagnosis analysis
4. **Treatment** - Research-backed action plan with urgency levels
5. **Report** - SOAP format documentation

Dr. Ralph maintains patient notes across sessions and generates professional medical reports.

## Available Commands

### /dr-ralph:diagnose <SYMPTOMS> [OPTIONS]

Full diagnostic workflow: interview → research → differential → treatment → report.

**Usage:**
```
/dr-ralph:diagnose "I've been having back pain for 3 months" --patient "John Doe"
/dr-ralph:diagnose "Headaches and dizziness" --completion-promise DONE
```

**Options:**
- `--patient <name>` - Patient name for case file (default: anonymous)
- `--questions <n>` - Maximum interview questions (default: 15)
- `--output <dir>` - Directory for case files (default: @notes/)
- `--max-iterations <n>` - Max iterations before auto-stop
- `--completion-promise <text>` - Promise phrase to signal completion

**5-Phase Workflow:**
1. **Interview** - Comprehensive intake using AskUserQuestion tool
2. **Research** - Web search for literature and treatment protocols
3. **Differential** - Analyze symptoms to determine diagnosis (confidence-based)
4. **Treatment** - Research-backed action plan with urgency levels
5. **Report** - SOAP format documentation with executive summary

**Output Files:**
- `@notes/[patient].md` - Running notes (persists across sessions)
- `@notes/[patient]-report-[timestamp].md` - Final SOAP report

**Diagnosis Output:**
- >80% confident → Single most likely diagnosis
- Uncertain → Top 3-5 differential diagnoses ranked by likelihood

**Note:** AI-assisted diagnostic tool. Not a substitute for professional medical advice.

---

### /dr-ralph:cancel

Cancel an active diagnostic session.

**Usage:**
```
/dr-ralph:cancel
```

**How it works:**
- Checks for active state file
- Removes the session state
- Reports cancellation with iteration count
- Patient notes are preserved

---

## Example

```
/dr-ralph:diagnose "Persistent fatigue and joint pain" --patient "Jane Doe" --completion-promise DONE
```

Dr. Ralph will:
- Conduct comprehensive interview (Phase 1)
- Research conditions and treatments (Phase 2)
- Generate differential diagnosis (Phase 3)
- Create treatment action plan (Phase 4)
- Write SOAP format report (Phase 5)

## When to Use Dr. Ralph

**Good for:**
- Comprehensive medical symptom analysis
- Research-backed diagnostic workflows
- Structured patient intake interviews
- Generating SOAP-format documentation
- Tracking patient cases over multiple sessions

**Not good for:**
- Emergency medical situations (call 911)
- Replacing professional medical advice
- Quick one-off health questions

## Learn More

- Original Ralph technique: https://ghuntley.com/ralph/
