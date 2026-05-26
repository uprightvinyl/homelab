# CLAUDE.md

The tool-agnostic guidance for this repository lives in @AGENTS.md — read and
follow it. The notes below apply to Claude Code specifically.

## Claude Code specifics
- Honour the read-only / advisory default from AGENTS.md: use read-only tools
  (Read, Grep, Glob and read-only Bash) freely, but do not use Edit or Write,
  and do not run mutating commands, unless I explicitly ask in that request.
- Prefer Plan mode for anything non-trivial — present a plan or recommendations
  rather than making changes.
- I review changes in VS Code's Source Control view and commit them myself; do
  not commit or push unless I ask.