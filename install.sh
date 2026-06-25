#!/usr/bin/env bash
set -e

REPO="eternalsayed/distill-prompts"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
SKILL_DIR="${HOME}/.claude/skills/distill"
CLAUDE_MD="${HOME}/.claude/CLAUDE.md"

CLAUDE_MD_ENTRY='
# distill
- **distill** (`~/.claude/skills/distill/SKILL.md`) — converts vague requests into clear AI-ready instructions. Trigger: `/distill`
When the user types `/distill`, invoke the Skill tool with `skill: "distill"` before doing anything else.'

echo "Installing Distill..."

# Create skill directory and download SKILL.md
mkdir -p "$SKILL_DIR"
curl -fsSL "${RAW_BASE}/distill.skill.md" -o "${SKILL_DIR}/SKILL.md"
echo "  skill installed → ${SKILL_DIR}/SKILL.md"

# Add CLAUDE.md entry if not already present
if [ -f "$CLAUDE_MD" ]; then
  if grep -q 'skill: "distill"' "$CLAUDE_MD" 2>/dev/null; then
    echo "  CLAUDE.md already has distill entry — skipping"
  else
    printf '%s\n' "$CLAUDE_MD_ENTRY" >> "$CLAUDE_MD"
    echo "  CLAUDE.md updated → ${CLAUDE_MD}"
  fi
else
  echo ""
  echo "  No CLAUDE.md found at ${CLAUDE_MD}"
  echo "  Add this manually to enable /distill:"
  echo "${CLAUDE_MD_ENTRY}"
fi

echo ""
echo "Done. Start a new Claude Code session and type /distill to confirm."
echo ""
echo "Always-on mode:"
echo "  https://github.com/${REPO}#always-on-mode"
