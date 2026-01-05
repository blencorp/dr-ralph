<img src="dr-ralph-banner.png" alt="Dr. Ralph Banner">

# Dr. Ralph Plugin

A Claude Code plugin for AI-assisted medical diagnostics with comprehensive symptom analysis and research-backed treatment plans.

## Overview

Dr. Ralph provides a structured 5-phase diagnostic workflow: Interview → Research → Differential Diagnosis → Treatment Plan → SOAP Report. It uses Claude Code's Stop hook system to iterate through phases until reaching a convincing diagnosis.

## Installation

### Option 1: From GitHub (Recommended)

Add the plugin marketplace from GitHub:

```bash
claude plugin marketplace add blencorp/dr-ralph
claude plugin install dr-ralph
```

### Option 2: Local Directory (Development)

Clone the repo and use the `--plugin-dir` flag:

```bash
git clone git@github.com:blencorp/dr-ralph.git
claude --plugin-dir /path/to/dr-ralph
```

### Option 3: Configure in settings.json

Add to your project's `.claude/settings.json`:

```json
{
  "marketplaces": ["blencorp/dr-ralph"],
  "plugins": {
    "dr-ralph@blencorp": "enabled"
  }
}
```

Or to your user settings at `~/.claude/settings.json` for global access.

### Verify Installation

After installation, restart Claude Code and run:

```bash
/dr-ralph:help
```

See the [Claude Code plugins documentation](https://code.claude.com/docs/en/plugins) for more details.

## Quick Start
```bash
/dr-ralph:diagnose "Persistent fatigue and joint pain" --patient "John Doe" --completion-promise "DONE"
```

---

## Commands

### /dr-ralph:diagnose

**Full diagnostic workflow with 5 phases: Interview → Research → Differential → Treatment → Report**

```bash
/dr-ralph:diagnose "I've been having back pain for 3 months" --patient "John Doe"
/dr-ralph:diagnose "Headaches and dizziness" --completion-promise DONE --questions 20
```

**Options:**
| Flag | Default | Description |
|------|---------|-------------|
| `--patient <name>` | anonymous | Patient name for case file |
| `--questions <n>` | 15 | Maximum interview questions |
| `--output <dir>` | @notes/ | Directory for case files |
| `--max-iterations <n>` | unlimited | Max iterations before auto-stop |
| `--completion-promise <text>` | none | Phrase that signals completion |

**5-Phase Workflow:**

| Phase | Description |
|-------|-------------|
| 1. Interview | Medical records intake first, then comprehensive symptom questions |
| 2. Research | Web search for literature, iterative refinement |
| 3. Differential | Confidence-based diagnosis (>80% = single, else top 3-5) |
| 4. Treatment | Action plan with urgency levels and follow-up schedule |
| 5. Report | SOAP format with executive summary |

**Medical Records Handling:**
- Records are requested FIRST, before symptom questions
- Files processed one-by-one (never all at once)
- Size check before reading - files >3MB trigger warning
- Options: skip large file or provide smaller version
- Tip: Use Adobe Acrobat to split large PDFs into sections <3MB

**Output Files:**
- `@notes/[patient].md` - Running notes (persists across sessions)
- `@notes/[patient]-report-[timestamp].md` - Final SOAP report

---

### /dr-ralph:cancel

**Cancel an active diagnostic session**

```bash
/dr-ralph:cancel
```

---

## Diagnostic System Details

### Patient Case Management

```
@notes/
├── john-doe.md              # Patient notes (grows over time)
├── john-doe-report-20240105.md  # SOAP report
├── jane-smith.md
└── anonymous.md             # Default if no --patient specified
```

- **Persistence:** Notes are regular markdown files, persist across sessions
- **Continuity:** Previous notes auto-read at session start
- **Multiple patients:** Switch cases with `--patient` flag

### SOAP Report Format

```markdown
# Patient Report: John Doe
## Date: 2024-01-05

## Executive Summary
[2-3 paragraph overview]

---

## Subjective
[Patient's reported symptoms]

## Objective
[Research findings with citations]

## Assessment
[Diagnosis or differential with confidence]

## Plan
[Treatment plan with urgency levels]

---

## Detailed Findings
[Full interview, research, reasoning]

## References
[Cited sources]
```

### Research Phase

- **Iterative refinement:** Search → Analyze → Refine → Search again
- **Inline citations:** "According to Mayo Clinic [link]..."
- **Sources:** PubMed, Mayo Clinic, Cleveland Clinic, NHS, clinical guidelines

### Diagnosis Output

- **>80% confident:** Single most likely diagnosis
- **Uncertain:** Top 3-5 differential diagnoses ranked by likelihood
- **Transparency:** States uncertainty, distinguishing features, recommended tests

---

## Philosophy

### Iteration > Perfection
Don't aim for perfect on first try. Let the diagnostic workflow refine understanding through multiple phases.

### Thoroughness Over Speed
A comprehensive interview and research phase leads to better differential diagnoses.

### Transparency in Uncertainty
When confidence is below 80%, present a differential diagnosis rather than a single answer.

---

## Disclaimer

**THIS SOFTWARE IS FOR INFORMATIONAL AND EDUCATIONAL PURPOSES ONLY.**

Dr. Ralph is an AI-assisted tool and is **NOT** a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of a qualified healthcare provider with any questions regarding a medical condition. Never disregard professional medical advice or delay seeking it because of something generated by this tool.

**BLEN Corporation and the authors of this software assume no responsibility or liability for any errors, omissions, or outcomes arising from the use of this tool.** Use at your own risk.

**Red Flag Handling:**
Emergency symptoms (chest pain + SOB, sudden severe headache, etc.) are flagged prominently but the workflow continues to gather complete information.

**Data Privacy:**
Remind patients to redact sensitive information from files and answers.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Usage Tips

### Safety Limits

Use `--max-iterations` as a safety net to prevent runaway sessions:

```bash
/dr-ralph:diagnose "Symptoms" --max-iterations 10 --completion-promise DONE
```

### Patient Tracking

Use `--patient` to maintain continuity across sessions:

```bash
/dr-ralph:diagnose "Follow-up on headaches" --patient "John Doe"
```

---

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

---

## Architecture

```
dr-ralph/
├── .claude-plugin/
│   └── plugin.json           # Plugin metadata
├── commands/
│   ├── diagnose.md           # /dr-ralph:diagnose
│   ├── cancel.md             # /dr-ralph:cancel
│   └── help.md               # /dr-ralph:help
├── scripts/
│   └── setup-dr-ralph-diagnose.sh
├── hooks/
│   ├── hooks.json            # Stop hook registration
│   └── stop-hook.sh          # Iteration control
├── docs/
│   └── diagnose-spec.md      # Full diagnostic spec
└── README.md
```

---

## Learn More

- Original Ralph technique: https://ghuntley.com/ralph/
- Ralph Orchestrator: https://github.com/mikeyobrien/ralph-orchestrator
- Ralph Wiggum Plugin: https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-wiggum

## Help

Run `/help` in Claude Code for detailed command reference and examples.
