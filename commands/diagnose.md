---
description: "Start Dr. Ralph full diagnostic workflow"
argument-hint: "SYMPTOMS [--patient NAME] [--questions N] [--output DIR] [--max-iterations N] [--completion-promise TEXT]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-dr-ralph-diagnose.sh)", "Bash(ls *)", "Bash(stat *)", "AskUserQuestion", "Write", "Read", "WebSearch", "WebFetch"]
hide-from-slash-command-tool: "true"
---

# Dr. Ralph Diagnose Command

Execute the setup script to initialize the full diagnostic workflow:

`"${CLAUDE_PLUGIN_ROOT}/scripts/setup-dr-ralph-diagnose.sh" $ARGUMENTS`

## PHASE-BASED WORKFLOW

This command runs through 5 phases:

1. **Interview** - Use AskUserQuestion for comprehensive medical intake
2. **Research** - WebSearch for literature, guidelines, treatment protocols
3. **Differential** - Analyze findings to determine diagnosis
4. **Treatment** - Develop research-backed action plan
5. **Report** - Generate SOAP format documentation

## CRITICAL RULES

### 0. MEDICAL RECORDS FIRST
Before symptom questions, ask if patient has medical records to share. Process files ONE BY ONE:
- Check file size with `ls -la` or `stat` before reading
- If file > 3MB: Alert user, offer to skip or provide smaller version
- Suggest Adobe Acrobat to split large PDFs
- Never let one bad file crash the workflow

### 1. USE AskUserQuestion FOR ALL INTERVIEW QUESTIONS
You MUST use the AskUserQuestion tool for every interview question. Do NOT output questions as plain text.

### 2. MAINTAIN RUNNING NOTES
Write findings to the patient notes file after each phase. Use timestamps for all entries.

### 3. READ EXISTING PATIENT HISTORY
If patient notes exist, READ them first to understand previous sessions before beginning.

### 4. USE WebSearch FOR RESEARCH
Search for medical literature, guidelines, and treatment protocols. Use inline citations.

### 5. FOLLOW PHASE ORDER
Complete each phase fully before moving to the next. Announce phase transitions.

### 6. MEDICAL DISCLAIMER
This is an AI-assisted tool. Always remind patients this is not a substitute for professional medical advice. Remind them to redact sensitive information.

### 7. FLAG RED FLAGS
If emergency symptoms are detected (chest pain + SOB, sudden severe headache, etc.), flag them prominently but continue the workflow.

## OUTPUT FILES

- **Running Notes:** `@notes/[patient].md` - Updated throughout session
- **Final Report:** `@notes/[patient]-report-[timestamp].md` - SOAP format
