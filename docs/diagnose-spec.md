# Dr. Ralph Diagnostic System - Comprehensive Specification

## Overview

Dr. Ralph is a Claude Code plugin that provides a full diagnostic workflow for medical symptom analysis. It iterates on patient symptoms through structured phases until reaching a convincing diagnosis with a research-backed treatment plan.

**Command:** `/dr-ralph:diagnose`

---

## Core Design Principles

| Aspect | Decision |
|--------|----------|
| Expertise Level | Full diagnostic workflow (intake → research → differential → treatment) |
| Target Users | Both personal health tracking and healthcare practitioner intake |
| Interaction Style | Interactive with running notes in `@notes/` directory |
| Completion | Auto-complete when confidence threshold reached |
| Output Format | SOAP notes with tiered sections (executive summary + detailed) |

---

## Phase-Based Workflow

### Phase 1: Interview
**Purpose:** Comprehensive medical intake using AskUserQuestion tool

#### Step 1: Medical Records Intake (First)

Before symptom questions, ask about existing medical records:

1. **Ask about records** using AskUserQuestion:
   - "Do you have any previous medical records, lab results, imaging, or reports to share?"
   - Options: "Yes, I have files" / "No, proceed without"

2. **If patient has files:**
   - Ask for file path(s) or directory
   - Check file sizes before reading (`ls -la` or `stat`)
   - **Process files ONE BY ONE** (never all at once)
   - **Large file handling (>2MB):**
     - Alert: "File [name] is [X]MB, which may be too large to process reliably."
     - Offer options: Skip file / Provide smaller version
     - Suggest: "Use Adobe Acrobat to split large PDFs into sections under 2MB"
   - **For files ≤2MB:** Read, analyze, extract key findings
   - If a file read fails, note error and continue with others
   - Track: files processed, skipped, failed

#### Step 2: Symptom Interview

**Specifications:**
- Use `AskUserQuestion` tool for ALL questions (no plain text questions)
- Maximum 15 questions by default (increase only if clinically necessary)
- Context-dependent sensitive topics (mental health, substances, sexual health) - only ask if symptoms suggest relevance
- Auto-read previous patient notes from `@notes/` to inform session

**Coverage Areas:**
1. Symptom details (onset, location, duration, character, severity, timing, aggravating/alleviating)
2. Associated symptoms
3. Medical history (previous episodes, chronic conditions, surgeries)
4. Current medications (prescription and OTC)
5. Allergies (medications, foods, environmental)
6. Lifestyle factors (occupation, stress, exercise, diet, sleep, substances)
7. Family history

**Red Flag Handling:** Flag concerning symptoms and continue interview, emphasize in final report

---

### Phase 2: Research
**Purpose:** Search web for literature, evidence, and treatment protocols

**Specifications:**
- AI judges source relevance (not restricted to specific sites)
- **Iterative refinement:** Search → Analyze → Refine queries → Search again
- Generate hypothesis-driven searches to confirm/rule out differential diagnoses
- Inline citations: `According to Mayo Clinic [link]...`

**Sources to Consider:**
- Peer-reviewed literature (PubMed, journals)
- Reputable medical sites (Mayo Clinic, Cleveland Clinic, NHS)
- Clinical guidelines and treatment protocols
- Recent research and case studies

---

### Phase 3: Differential Diagnosis
**Purpose:** Analyze symptoms and research to determine diagnosis

**Specifications:**
- **Confidence-based output:**
  - If >80% confident → Single most likely diagnosis
  - If uncertain → Top 3-5 differential diagnoses ranked by likelihood
- Full transparency when uncertain:
  - State uncertainty clearly
  - Present differential with distinguishing features
  - Recommend specific tests/questions to narrow down
- Build on previous sessions (read patient history)

---

### Phase 4: Treatment Plan
**Purpose:** Research-backed, actionable treatment recommendations

**Specifications:**
- Diagnosis-specific only (no general wellness filler)
- Structured action plan with:
  - Prioritized treatment steps
  - Urgency levels (immediate, short-term, long-term)
  - Follow-up schedule
  - Specific specialist referrals if needed
  - Tests to request

---

### Phase 5: Report Generation
**Purpose:** Comprehensive documentation in SOAP format

**Output Structure:**
```markdown
# Patient Report: [Patient Name]
## Date: [Timestamp]

## Executive Summary
[2-3 paragraph overview of findings and recommendations]

---

## Subjective
[Patient's reported symptoms and history]

## Objective
[Relevant findings from file analysis, research]

## Assessment
[Diagnosis or differential with confidence levels]
[Inline citations to supporting research]

## Plan
[Structured treatment plan with urgency levels]
[Follow-up schedule]
[Recommended tests/referrals]

---

## Detailed Findings
[Full interview responses]
[Research analysis]
[Differential reasoning]

## References
[Sources cited in report]
```

---

## Patient Case Management

### File Structure
```
@notes/
├── john-doe.md          # Single file per patient, grows over time
├── jane-smith.md
└── case-anonymous-001.md
```

### Patient Identification
- `--patient "John Doe"` → Creates/loads `john-doe.md`
- Sanitized filename from patient name
- Multiple concurrent cases supported

### Session Persistence
- File-based persistence (regular markdown files)
- Auto-read previous notes at session start
- Append new findings with dated entries

---

## Command Interface

```bash
# Basic usage
/dr-ralph:diagnose "I've been having back pain for 3 months"

# With patient tracking
/dr-ralph:diagnose "Headaches and dizziness" --patient "John Doe"

# With options
/dr-ralph:diagnose "Chest tightness" --patient "Jane Smith" --questions 20 --output ./medical-cases/
```

### Flags
| Flag | Default | Description |
|------|---------|-------------|
| `--patient <name>` | anonymous | Patient name for case file |
| `--questions <n>` | 15 | Maximum interview questions |
| `--output <dir>` | `@notes/` | Directory for case files |
| `--max-iterations <n>` | unlimited | Max loop iterations |
| `--completion-promise <text>` | none | Completion signal phrase |

---

## Safety & Disclaimers

**Required Disclaimers:**
- "This is an AI-assisted tool, not a substitute for professional medical advice, diagnosis, or treatment"
- "Always consult a qualified healthcare provider for medical concerns"
- "Remind user to redact sensitive information from files and answers"

**Red Flag Protocol:**
- Identify emergency symptoms (chest pain + shortness of breath, sudden severe headache, etc.)
- Flag in report with high urgency
- Continue interview but note concerns prominently

---

## Future Considerations (Not in v1)

- Export formats (PDF, HTML)
- Share links for reports
- Integration with health records systems
- Voice input for symptoms
- Image analysis for visible symptoms
