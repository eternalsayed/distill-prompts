#!/usr/bin/env bash
set -e

REPO="eternalsayed/distill-prompts"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
SKILL_NAME="distill"
SKILL_FILE="distill.skill.md"

# ── Install paths ─────────────────────────────────────────────────────────────
CLAUDE_SKILL_DIR="${HOME}/.claude/skills/${SKILL_NAME}"
CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
CODEX_AGENTS_MD="${HOME}/.codex/AGENTS.md"
GEMINI_SKILL_DIR="${HOME}/.gemini/skills/${SKILL_NAME}"
ANTIGRAVITY_SKILL_DIR="${HOME}/.gemini/config/skills/${SKILL_NAME}"

# ── Flags ─────────────────────────────────────────────────────────────────────
INSTALL_CLAUDE=false
INSTALL_CODEX=false
INSTALL_GEMINI=false
INSTALL_ANTIGRAVITY=false
AUTO=true

usage() {
  echo "Usage: install.sh [options]"
  echo ""
  echo "  (no flags)      auto-detect installed agents and install for all found"
  echo "  --claude        install for Claude Code only"
  echo "  --codex         install for Codex CLI only"
  echo "  --gemini        install for Gemini CLI only"
  echo "  --antigravity   install for Antigravity only"
  echo "  --all           install for all agents regardless of detection"
  echo "  --help          show this message"
}

for arg in "$@"; do
  case "$arg" in
    --claude)       INSTALL_CLAUDE=true;      AUTO=false ;;
    --codex)        INSTALL_CODEX=true;       AUTO=false ;;
    --gemini)       INSTALL_GEMINI=true;      AUTO=false ;;
    --antigravity)  INSTALL_ANTIGRAVITY=true; AUTO=false ;;
    --all)          INSTALL_CLAUDE=true; INSTALL_CODEX=true; INSTALL_GEMINI=true; INSTALL_ANTIGRAVITY=true; AUTO=false ;;
    --help|-h)      usage; exit 0 ;;
    *) echo "Unknown flag: $arg"; usage; exit 1 ;;
  esac
done

# ── Auto-detect ───────────────────────────────────────────────────────────────
if [ "$AUTO" = true ]; then
  command -v claude  >/dev/null 2>&1             && INSTALL_CLAUDE=true
  command -v codex   >/dev/null 2>&1             && INSTALL_CODEX=true
  command -v gemini  >/dev/null 2>&1             && INSTALL_GEMINI=true
  [ -d "${HOME}/.gemini/skills" ]                && INSTALL_GEMINI=true
  [ -d "${HOME}/.gemini/antigravity" ] \
    || [ -d "${HOME}/.gemini/config" ]           && INSTALL_ANTIGRAVITY=true
fi

if [ "$INSTALL_CLAUDE" = false ] && [ "$INSTALL_CODEX" = false ] && \
   [ "$INSTALL_GEMINI" = false ] && [ "$INSTALL_ANTIGRAVITY" = false ]; then
  echo "No supported agents detected."
  echo "Use --all to install for all agents, or pick one: --claude --codex --gemini --antigravity"
  exit 1
fi

# ── Fetch skill file once ─────────────────────────────────────────────────────
TMP_SKILL=$(mktemp)
trap 'rm -f "$TMP_SKILL"' EXIT
curl -fsSL "${RAW_BASE}/${SKILL_FILE}" -o "$TMP_SKILL"

# Strip YAML frontmatter (--- ... ---) for agents that use plain markdown
strip_frontmatter() {
  awk 'NR==1&&/^---$/{skip=1;next} skip&&/^---$/{skip=0;next} !skip' "$1"
}

# ── Claude Code ───────────────────────────────────────────────────────────────
install_claude() {
  echo "[claude]"
  mkdir -p "$CLAUDE_SKILL_DIR"
  cp "$TMP_SKILL" "${CLAUDE_SKILL_DIR}/SKILL.md"
  echo "  skill  → ${CLAUDE_SKILL_DIR}/SKILL.md"

  local entry
  entry="
# distill
- **distill** (\`~/.claude/skills/distill/SKILL.md\`) — converts vague requests into clear AI-ready instructions. Trigger: \`/distill\`
When the user types \`/distill\`, invoke the Skill tool with \`skill: \"distill\"\` before doing anything else."

  if [ -f "$CLAUDE_MD" ]; then
    if grep -q 'skill: "distill"' "$CLAUDE_MD" 2>/dev/null; then
      echo "  CLAUDE.md already configured — skipping"
    else
      printf '%s\n' "$entry" >> "$CLAUDE_MD"
      echo "  CLAUDE.md → ${CLAUDE_MD}"
    fi
  else
    echo "  No CLAUDE.md at ${CLAUDE_MD}"
    echo "  Create it and add:${entry}"
  fi
  echo "  Trigger: /distill"
}

# ── Codex CLI ─────────────────────────────────────────────────────────────────
install_codex() {
  echo "[codex]"
  if [ ! -f "$CODEX_AGENTS_MD" ]; then
    mkdir -p "$(dirname "$CODEX_AGENTS_MD")"
    touch "$CODEX_AGENTS_MD"
    echo "  created ${CODEX_AGENTS_MD}"
  fi
  if grep -q "## Distill" "$CODEX_AGENTS_MD" 2>/dev/null; then
    echo "  AGENTS.md already has Distill — skipping"
  else
    {
      printf '\n## Distill\n\n'
      printf 'When a request is prefixed with `distill this:` or `use distill:`, apply the Distill skill before answering.\n\n'
      strip_frontmatter "$TMP_SKILL"
    } >> "$CODEX_AGENTS_MD"
    echo "  AGENTS.md → ${CODEX_AGENTS_MD}"
  fi
  echo "  Trigger: distill this: <request>"
}

# ── Gemini CLI ────────────────────────────────────────────────────────────────
install_gemini() {
  echo "[gemini]"
  mkdir -p "$GEMINI_SKILL_DIR"
  cp "$TMP_SKILL" "${GEMINI_SKILL_DIR}/SKILL.md"
  echo "  skill  → ${GEMINI_SKILL_DIR}/SKILL.md"
  echo "  Trigger: distill this: <request>"
}

# ── Antigravity ───────────────────────────────────────────────────────────────
install_antigravity() {
  echo "[antigravity]"
  mkdir -p "$ANTIGRAVITY_SKILL_DIR"
  cp "$TMP_SKILL" "${ANTIGRAVITY_SKILL_DIR}/SKILL.md"
  echo "  skill  → ${ANTIGRAVITY_SKILL_DIR}/SKILL.md"
  echo "  Trigger: /distill"
}

# ── Run ───────────────────────────────────────────────────────────────────────
echo "Installing Distill..."
echo ""
[ "$INSTALL_CLAUDE" = true ]      && install_claude      && echo ""
[ "$INSTALL_CODEX" = true ]       && install_codex       && echo ""
[ "$INSTALL_GEMINI" = true ]      && install_gemini      && echo ""
[ "$INSTALL_ANTIGRAVITY" = true ] && install_antigravity && echo ""

echo "Done."
echo ""
echo "Always-on mode:"
echo "  https://github.com/${REPO}#always-on-mode"
