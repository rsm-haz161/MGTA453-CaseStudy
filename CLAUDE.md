# Working well with Claude Code (RSM-MSBA)

These are the house rules for using Claude Code in your RSM-MSBA coursework. They
load automatically every session — you don't need to repeat them. The goal is to
**use AI to go faster _and_ understand more**, not to hand off your thinking.

> **Usage may be logged.** In course repositories (GitHub org `rsm-msba-*`), your
> prompts and a short summary of each tool call are written to
> `.claude/usage-log/` and committed with your work, for instructor review. File
> contents and command output are **never** logged, and **nothing is logged in
> your personal repos** (any repo whose remote is not the course org). See
> `.claude/usage-log/README.md`.

## 1. Verify everything — you own the review

You are responsible for the code that lands under your name. Before you accept or
commit AI-written changes:

- **Read the diff.** `git diff HEAD` — actually read it, don't skim.
- **Explain it.** If you can't explain in plain English what a change does and why,
  you're not ready to commit it. Ask `/explain <file-or-function>`.
- **Run the tests**, then **exercise it yourself** — run the function on a real
  input (`uv run python -c "..."`), not just "the tests pass." Passing tests do not
  prove the code does what you intended.
- **Check the agent's claims.** Don't trust a summary that says "done, it works."
  Confirm it against what you actually see.

Ask Claude to use the **`verify-ai-code`** skill when you want a structured
read-and-verify pass. Never commit code you haven't reviewed yourself.

## 2. Tests are how you tell the agent what "done" means

- Every function you add or change should have at least one test: a happy-path case
  plus the obvious edge cases (empty input, boundary values, invalid input).
- Prefer writing (or asking for) the **test first**, watch it fail, then make it
  pass — that proves the test actually checks something.
- Run tests often: `uv run pytest`. A Stop-hook will remind you if Python files
  changed since your last test run.

## 3. Git is your safety net

- Commit early and often, in **small, reviewable steps** — one idea per commit.
- Look before you commit (`/review` or `git diff HEAD`).
- Destructive commands (`git push/reset/rebase/merge/clean`, `rm`) will pause and
  ask — read what they'll do before approving.
- Stuck with push/pull/merge conflicts? Ask for help — the **`git-workflow`** skill
  walks through it from your actual repo state without destroying work.

## 4. Package management — use `uv`, never `pip`

- Add a dependency: `uv add <package>` (dev-only: `uv add --dev <package>`).
- Run Python via `uv run …`. `pip` / `python -m pip` / `uv pip install` are blocked
  because they bypass `pyproject.toml` / `uv.lock` and vanish on the next `uv sync`.

## 5. Never commit secrets

Before any `git commit`, a hook scans staged files for API keys, private keys, and
`.env`-style files, and pauses if it finds one. If it fires, open the file and
confirm there's no real secret — don't push through the warning blindly.

## Slash commands

| Command | What it does |
| --- | --- |
| `/run-tests` | Run the full test suite and report results. |
| `/review` | Review your current diff — flags bugs, missing tests, style issues. No edits. |
| `/add-function` | Walk you through adding a new function **with** its tests, in one shot. |
| `/explain <thing>` | Beginner-friendly explanation of a file, function, or concept. Read-only. |

## Handy commands (justfile)

If a `justfile` is present: `just test` (run tests), `just check` (tests + lint),
`just review` (show your diff), `just save "msg"` (checkpoint commit),
`just verify` (tests, then show the diff to review).

To see what the hooks do, `just hooks-off` / `just hooks-on` toggle them for this
folder (restart Claude Code to apply). `just status-line` turns on a status bar
showing your model, context left, and (on Pro/Max) your 5-hour and 7-day usage.
