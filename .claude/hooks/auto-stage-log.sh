#!/usr/bin/env bash
# PreToolUse (git commit): auto-stage the usage log so it ships with every commit.
#
# SCOPE: only in course-org repos (rsm-msba-*), matching usage-log.sh. Silent
# no-op elsewhere, and silent on failure — we never block a commit because
# logging failed.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$PROJECT_DIR")"
LOG_DIR="$PROJECT_DIR/usage-log"

# --- telemetry scope guard: course-org repos only -------------------------
_pat="${RSM_COURSE_ORG_PATTERN:-rsm-msba-}"
_origin=$(git -C "$PROJECT_ROOT" remote get-url origin 2>/dev/null || true)
case "$_origin" in
  *"$_pat"*) ;;
  *) exit 0 ;;
esac

if [ -d "$LOG_DIR" ]; then
  (cd "$PROJECT_ROOT" && git add "$LOG_DIR" 2>/dev/null) || true
fi
