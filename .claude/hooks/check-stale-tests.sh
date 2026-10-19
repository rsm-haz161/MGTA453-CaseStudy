#!/usr/bin/env bash
# Stop hook: soft-remind if Python source files were modified more recently
# than the last pytest run. Does NOT block — just surfaces a system message
# so the user sees it and can ask Claude to run tests.
#
# Skips silently if:
#   - no tests have ever been run in this project (no timestamp file)
#   - no .py files exist under tracked source/test directories
#   - all .py files are older than the last pytest run
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_common.sh"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$PROJECT_DIR")"
TIMESTAMP_FILE="$PROJECT_DIR/.last-test-time"

[ -f "$TIMESTAMP_FILE" ] || exit 0

SEARCH_DIRS=()
for d in src skills tests lib utils; do
  [ -d "$PROJECT_ROOT/$d" ] && SEARCH_DIRS+=("$PROJECT_ROOT/$d")
done
[ ${#SEARCH_DIRS[@]} -eq 0 ] && exit 0

stale=$(find "${SEARCH_DIRS[@]}" -type f -name '*.py' -newer "$TIMESTAMP_FILE" -print -quit 2>/dev/null)

if [ -n "$stale" ]; then
  "$JQ" -n --arg msg "Python files have changed since the last pytest run. Consider running: uv run pytest" \
    '{systemMessage: $msg}'
fi
