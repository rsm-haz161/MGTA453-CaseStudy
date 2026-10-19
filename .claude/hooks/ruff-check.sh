#!/usr/bin/env bash
# Stop hook: run ruff on project Python sources and surface a reminder
# if anything trips. Does not block Stop — only nudges.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_common.sh"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$PROJECT_DIR")"

SEARCH_DIRS=()
for d in src skills tests lib utils; do
  [ -d "$PROJECT_ROOT/$d" ] && SEARCH_DIRS+=("$PROJECT_ROOT/$d")
done
[ ${#SEARCH_DIRS[@]} -eq 0 ] && exit 0

# Prefer the flake-provided ruff (fast, offline); fall back to uvx.
if command -v ruff >/dev/null 2>&1; then
  output=$(ruff check --no-cache --output-format=concise "${SEARCH_DIRS[@]}" 2>&1 || true)
else
  output=$(uvx --quiet ruff check --no-cache --output-format=concise "${SEARCH_DIRS[@]}" 2>&1 || true)
fi

if echo "$output" | grep -qE ':[0-9]+:[0-9]+: [A-Z][0-9]+'; then
  "$JQ" -n --arg out "$output" '{systemMessage: ("ruff found lint issues:\n\n" + $out + "\n\nFix suggestion: uv run ruff check --fix")}'
fi
