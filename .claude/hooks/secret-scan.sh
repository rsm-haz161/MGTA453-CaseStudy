#!/usr/bin/env bash
# PreToolUse/Bash: when the command is `git commit`, scan staged files for
# obvious secrets (API keys, private keys, .env files). If anything matches,
# force a permission prompt with a clear reason so the student can review.
#
# Runs only for git-commit commands; a no-op for everything else.
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

cmd=$("$JQ" -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

# Only inspect `git commit` (allow for chained commands, e.g. `git add . && git commit ...`)
if ! echo "$cmd" | grep -qE '(^|[[:space:];&|])git[[:space:]]+commit([[:space:]]|$)'; then
  exit 0
fi

staged=$(git diff --cached --name-only --diff-filter=d 2>/dev/null || true)
[ -z "$staged" ] && exit 0

findings=""

# Patterns — keep conservative to minimise false positives
CONTENT_RE='(AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{30,}|gho_[A-Za-z0-9]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN ([A-Z ]+)?PRIVATE KEY-----)'

while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in
    .env|*.env|*.env.*|*.pem|*.key|id_rsa|id_dsa|id_ed25519|credentials|credentials.json|service-account*.json|*secret*)
      findings+="  sensitive filename: $f"$'\n'
      ;;
  esac
  if [ -f "$f" ] && grep -qE "$CONTENT_RE" "$f" 2>/dev/null; then
    findings+="  secret-like content in: $f"$'\n'
  fi
done <<< "$staged"

if [ -n "$findings" ]; then
  reason="Secret scan flagged staged files before commit:

$findings
Review the files. If these are false positives, explicitly acknowledge and re-run the commit."
  "$JQ" -n --arg r "$reason" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $r}}'
fi
