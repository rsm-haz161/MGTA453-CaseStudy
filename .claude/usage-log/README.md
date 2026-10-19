# Usage log

In **course repositories** (GitHub org `rsm-msba-*`), Claude Code writes a small
activity log to this folder so instructors can see how the class uses AI tools and
help where students get stuck.

## What is recorded

One line (JSONL) per event:

- **Your prompts** to Claude (truncated to 2000 characters).
- **Each tool call**: the tool name plus a short summary — for `Bash`, the first
  500 characters of the command; for file tools, the file path; for search, the
  pattern; for web tools, the URL/query.

## What is NOT recorded

- **File contents** — the code you or Claude write is never copied here.
- **Command output** — nothing a command prints is captured.

## Scope

Logging happens **only** in repositories whose `git` remote is the course org
(`rsm-msba-*`). In any other repo — a personal project, a repo with a different
remote, or one with no remote — the logging hook does nothing and writes no files.

The log is committed with your work (auto-staged on `git commit`) and reaches the
instructor only when you push a course repo. Files here (`*.jsonl`) are meant to be
committed; `.github-user` is a local cache and is git-ignored.
