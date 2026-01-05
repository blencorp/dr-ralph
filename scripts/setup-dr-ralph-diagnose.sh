#!/bin/bash

# Dr. Ralph Diagnose Setup Script
# Creates state file for full diagnostic workflow

set -euo pipefail

# Parse arguments
PROMPT_PARTS=()
MAX_ITERATIONS=0
COMPLETION_PROMISE="null"
QUESTION_COUNT=15
OUTPUT_DIR="@notes"
PATIENT_NAME="anonymous"

# Parse options and positional arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Dr. Ralph Diagnose - Full diagnostic workflow for medical symptoms

USAGE:
  /dr-ralph:diagnose [SYMPTOMS...] [OPTIONS]

ARGUMENTS:
  SYMPTOMS...    Description of symptoms to investigate

OPTIONS:
  --patient <name>               Patient name for case file (default: anonymous)
  --questions <n>                Maximum interview questions (default: 15)
  --output <dir>                 Directory for case files (default: @notes/)
  --max-iterations <n>           Maximum iterations before auto-stop
  --completion-promise '<text>'  Promise phrase to signal completion
  -h, --help                     Show this help message

DESCRIPTION:
  Conducts a full diagnostic workflow through 5 phases:
  1. Interview - Comprehensive medical intake using AskUserQuestion
  2. Research - Web search for literature and treatment protocols
  3. Differential - Analyze symptoms to determine diagnosis
  4. Treatment - Research-backed action plan
  5. Report - SOAP format documentation

  Patient notes are maintained in @notes/[patient-name].md and persist
  across sessions for continuity of care.

EXAMPLES:
  /dr-ralph:diagnose "I've been having back pain for 3 months"
  /dr-ralph:diagnose "Headaches" --patient "John Doe" --completion-promise DONE
  /dr-ralph:diagnose "Chest tightness" --patient "Jane" --questions 20

OUTPUT:
  - Running notes: @notes/[patient].md
  - Final report: @notes/[patient]-report-[timestamp].md
HELP_EOF
      exit 0
      ;;
    --max-iterations)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "❌ Error: --max-iterations requires a positive integer" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --completion-promise)
      if [[ -z "${2:-}" ]]; then
        echo "❌ Error: --completion-promise requires a text argument" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    --questions)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]] || [[ "$2" -lt 1 ]]; then
        echo "❌ Error: --questions requires a positive integer" >&2
        exit 1
      fi
      QUESTION_COUNT="$2"
      shift 2
      ;;
    --output)
      if [[ -z "${2:-}" ]]; then
        echo "❌ Error: --output requires a directory path" >&2
        exit 1
      fi
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --patient)
      if [[ -z "${2:-}" ]]; then
        echo "❌ Error: --patient requires a name" >&2
        exit 1
      fi
      PATIENT_NAME="$2"
      shift 2
      ;;
    *)
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

# Join all prompt parts with spaces
SYMPTOMS="${PROMPT_PARTS[*]}"

# Validate symptoms description is non-empty
if [[ -z "$SYMPTOMS" ]]; then
  echo "❌ Error: No symptoms provided" >&2
  echo "" >&2
  echo "   Examples:" >&2
  echo "     /dr-ralph:diagnose \"I've been having back pain for 3 months\"" >&2
  echo "     /dr-ralph:diagnose Headaches and dizziness --patient \"John Doe\"" >&2
  exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Sanitize patient name for filename
PATIENT_FILE=$(echo "$PATIENT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
PATIENT_NOTES_PATH="$OUTPUT_DIR/$PATIENT_FILE.md"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_PATH="$OUTPUT_DIR/$PATIENT_FILE-report-$TIMESTAMP.md"

# Check for existing patient notes
EXISTING_NOTES=""
if [[ -f "$PATIENT_NOTES_PATH" ]]; then
  EXISTING_NOTES="yes"
fi

# Create state file for stop hook
mkdir -p .claude

# Quote completion promise for YAML
if [[ -n "$COMPLETION_PROMISE" ]] && [[ "$COMPLETION_PROMISE" != "null" ]]; then
  COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""
else
  COMPLETION_PROMISE_YAML="null"
fi

# Build the comprehensive diagnostic prompt
DIAGNOSE_PROMPT=$(cat <<PROMPT_EOF
# Dr. Ralph Diagnostic Session

## Patient Information
- **Patient:** $PATIENT_NAME
- **Notes File:** $PATIENT_NOTES_PATH
- **Report File:** $REPORT_PATH
- **Session Started:** $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Chief Complaint
$SYMPTOMS

---

## IMPORTANT DISCLAIMERS

**This is an AI-assisted diagnostic tool. It is NOT a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider for medical concerns.**

**Remind the patient to redact any sensitive information from files or answers they provide.**

---

## Phase-Based Workflow

You will proceed through 5 phases. Maintain running notes in \`$PATIENT_NOTES_PATH\` throughout.

### PHASE 1: INTERVIEW (Current Phase)

#### STEP 1: Medical Records Intake (DO THIS FIRST)

Before asking about symptoms, check for existing medical records:

1. **Ask about records** using AskUserQuestion:
   - Question: "Do you have any previous medical records, lab results, imaging, or reports you'd like to share?"
   - Options: "Yes, I have files to share" / "No, proceed without records"

2. **If patient has files:**
   - Ask for the file path(s) or directory containing the records
   - Use Bash to list files and check sizes: \`ls -la [path]\` or \`stat -f%z [file]\`
   - **Process files ONE BY ONE** (never all at once)
   - For EACH file:
     - Check file size first
     - **If file > 3MB (3145728 bytes):**
       - Alert: "The file [filename] is [X]MB, which may be too large to process reliably."
       - Use AskUserQuestion: "How would you like to proceed with this file?"
         - Options: "Skip this file" / "I'll provide a smaller version"
       - Suggest: "Tip: You can use Adobe Acrobat or similar tools to split large PDFs into smaller sections (under 3MB each)."
     - **If file <= 3MB:**
       - Read and analyze the file
       - Extract key findings (dates, diagnoses, lab values, medications, etc.)
       - Note findings in patient notes
   - If a file read fails, note the error and continue with other files
   - Keep track of: files processed, files skipped, files failed

3. **After processing records (or if none):** Proceed to symptom interview

---

#### STEP 2: Symptom Interview

**Instructions:**
1. If patient notes exist at \`$PATIENT_NOTES_PATH\`, READ them first to understand history
2. Use the \`AskUserQuestion\` tool for ALL questions - do NOT output plain text questions
3. Ask up to $QUESTION_COUNT comprehensive questions covering:
   - Symptom details (onset, location, duration, character, severity, timing, aggravating/alleviating)
   - Associated symptoms
   - Medical history (previous episodes, chronic conditions, surgeries)
   - Current medications (prescription and OTC)
   - Allergies (medications, foods, environmental)
   - Lifestyle factors (occupation, stress, exercise, diet, sleep) - ask about substances only if symptoms suggest relevance
   - Family history
4. If patient provides files (labs, images, reports), analyze them thoroughly
5. Flag any RED FLAGS (chest pain + SOB, sudden severe headache, etc.) but continue interview

**Question Guidelines:**
- Ask IN-DEPTH, NON-OBVIOUS questions
- Don't ask what patient already told you
- Use multiSelect when multiple answers could apply
- Provide 2-4 answer options with descriptions

**After completing interview:**
- Write detailed findings to \`$PATIENT_NOTES_PATH\` with timestamp
- Announce: "Interview complete. Moving to PHASE 2: RESEARCH"

---

### PHASE 2: RESEARCH

**Instructions:**
1. Based on interview findings, generate initial differential diagnoses
2. Use \`WebSearch\` tool to search for:
   - Literature on symptoms and conditions
   - Treatment protocols and guidelines
   - Recent research on differential diagnoses
3. Use iterative refinement: Search → Analyze → Refine queries → Search again
4. Use inline citations: "According to Mayo Clinic [link]..."
5. Append research findings to \`$PATIENT_NOTES_PATH\`

**After completing research:**
- Announce: "Research complete. Moving to PHASE 3: DIFFERENTIAL DIAGNOSIS"

---

### PHASE 3: DIFFERENTIAL DIAGNOSIS

**Instructions:**
1. Analyze all collected information (interview + research)
2. Determine confidence level:
   - If >80% confident → Present single most likely diagnosis
   - If uncertain → Present top 3-5 differential diagnoses ranked by likelihood
3. For each potential diagnosis, note:
   - Supporting evidence from interview
   - Supporting evidence from research
   - Distinguishing features
   - Tests that would confirm/rule out
4. Append differential to \`$PATIENT_NOTES_PATH\`

**After completing differential:**
- Announce: "Differential complete. Moving to PHASE 4: TREATMENT PLAN"

---

### PHASE 4: TREATMENT PLAN

**Instructions:**
1. Based on diagnosis/differential, develop treatment plan
2. Include:
   - Prioritized treatment steps
   - Urgency levels (immediate, short-term, long-term)
   - Specific specialist referrals if needed
   - Tests to request
   - Follow-up schedule
3. Keep recommendations diagnosis-specific (no general wellness filler)
4. Append treatment plan to \`$PATIENT_NOTES_PATH\`

**After completing treatment plan:**
- Announce: "Treatment plan complete. Moving to PHASE 5: REPORT GENERATION"

---

### PHASE 5: REPORT GENERATION

**Instructions:**
1. Write comprehensive SOAP report to \`$REPORT_PATH\`:

\`\`\`markdown
# Patient Report: $PATIENT_NAME
## Date: [Current Date]

## Executive Summary
[2-3 paragraph overview of findings and recommendations]

---

## Subjective
[Patient's reported symptoms and history from interview]

## Objective
[Relevant findings from file analysis, research citations]

## Assessment
[Diagnosis or differential with confidence levels]
[Inline citations to supporting research]

## Plan
[Structured treatment plan with urgency levels]
[Follow-up schedule]
[Recommended tests/referrals]

---

## Detailed Findings

### Interview Responses
[Full interview Q&A]

### Research Analysis
[Key research findings with citations]

### Differential Reasoning
[How each diagnosis was considered/ruled out]

## References
[All sources cited]

---

**DISCLAIMER:** This report was generated by an AI-assisted diagnostic tool and is not a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider.
\`\`\`

2. After writing report, output: \`<promise>$COMPLETION_PROMISE</promise>\`

---

## Running Notes Format

Maintain \`$PATIENT_NOTES_PATH\` with this structure:

\`\`\`markdown
# Patient: $PATIENT_NAME

## Session: [Date/Time]

### Chief Complaint
[Symptoms]

### Interview Findings
[Detailed Q&A responses]

### Research Notes
[Key findings with citations]

### Differential
[Working diagnosis/differential]

### Treatment Plan
[Current recommendations]

---
[Previous sessions below, most recent first]
\`\`\`

---

## Begin Phase 1: Interview

$(if [[ -n "$EXISTING_NOTES" ]]; then echo "**NOTE:** Existing patient notes found at \`$PATIENT_NOTES_PATH\`. Read them first to understand history before beginning interview."; else echo "**NOTE:** This is a new patient. No previous notes exist."; fi)

**START WITH STEP 1:** First, ask the patient about any medical records they want to share (using AskUserQuestion). Process any files ONE BY ONE, checking sizes before reading. Then proceed to the symptom interview.
PROMPT_EOF
)

# Write state file
cat > .claude/dr-ralph-loop.local.md <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
diagnose_mode: true
patient_name: "$PATIENT_NAME"
patient_file: "$PATIENT_NOTES_PATH"
report_file: "$REPORT_PATH"
question_count: $QUESTION_COUNT
output_dir: "$OUTPUT_DIR"
---

$DIAGNOSE_PROMPT
EOF

# Output setup message
cat <<EOF
🩺 Dr. Ralph Diagnostic Session Started

Patient: $PATIENT_NAME
Chief Complaint: $SYMPTOMS
Notes File: $PATIENT_NOTES_PATH
Report File: $REPORT_PATH
Max Questions: $QUESTION_COUNT
$(if [[ -n "$EXISTING_NOTES" ]]; then echo "Previous Notes: Found (will be read for context)"; else echo "Previous Notes: None (new patient)"; fi)

Phases:
  1. Interview (using AskUserQuestion tool)
  2. Research (web search for literature)
  3. Differential Diagnosis
  4. Treatment Plan
  5. Report Generation (SOAP format)

⚠️  DISCLAIMER: This is an AI-assisted tool, not a substitute for
    professional medical advice, diagnosis, or treatment.

🩺 Beginning Phase 1: Interview...
EOF

# Display completion info if set
if [[ "$COMPLETION_PROMISE" != "null" ]]; then
  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo "Session will complete when all phases are done and"
  echo "output: <promise>$COMPLETION_PROMISE</promise>"
  echo "═══════════════════════════════════════════════════════════"
fi
