#!/usr/bin/env bash
# PostToolUse/Write|Edit: auto-format Python files with ruff.
# Uses `uvx` so it works even before the student has added ruff as a dev dep.
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

file=$("$JQ" -r '.tool_response.filePath // .tool_input.file_path // empty')
[ -z "$file" ] && exit 0
[[ "$file" == *.py ]] || exit 0
[ -f "$file" ] || exit 0

# Prefer the flake-provided ruff (fast, offline); fall back to uvx so this still
# works if a student runs claude outside the RSM env.
if command -v ruff >/dev/null 2>&1; then
  ruff format "$file" >/dev/null 2>&1 || true
else
  uvx --quiet ruff format "$file" >/dev/null 2>&1 || true
fi
