---
description: "Cancel active Dr. Ralph session"
allowed-tools: ["Bash(test -f .claude/dr-ralph-loop.local.md:*)", "Bash(rm .claude/dr-ralph-loop.local.md)", "Read(.claude/dr-ralph-loop.local.md)"]
hide-from-slash-command-tool: "true"
---

# Cancel Dr. Ralph

To cancel the Dr. Ralph diagnostic session:

1. Check if `.claude/dr-ralph-loop.local.md` exists using Bash: `test -f .claude/dr-ralph-loop.local.md && echo "EXISTS" || echo "NOT_FOUND"`

2. **If NOT_FOUND**: Say "No active Dr. Ralph session found."

3. **If EXISTS**:
   - Read `.claude/dr-ralph-loop.local.md` to get the current iteration number from the `iteration:` field
   - Note patient_name if present in the state file
   - Remove the file using Bash: `rm .claude/dr-ralph-loop.local.md`
   - Report: "Cancelled Dr. Ralph diagnostic session (was at iteration N)"
   - If patient notes exist, mention: "Patient notes were saved to [patient_file path]"
