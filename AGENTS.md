# uprightlab — AI agent briefing

This is the tool-agnostic briefing for any AI coding assistant working in this
repository (Claude Code, Cursor, etc.). Keep everything here portable across
tools. Tool-specific instructions live in their own files alongside this one
(e.g. CLAUDE.md for Claude Code) and should contain only things that do not
apply to other tools.

## About this project
A personal homelab built on Proxmox and Kubernetes, managed as code.
See README.md and the docs/ folder for full context — design decisions,
network, hardware and build history.

## Role and boundaries
- Operate as a **read-only advisor by default**: read freely, analyse, explain
  and recommend — but do **not** create, edit or delete files, and do not run
  state-changing commands (git commit/push, ansible, docker, etc.).
- Present proposed changes as diffs or snippets for me to apply and commit
  myself.
- Only make edits or run mutating commands when I explicitly ask for them in
  that request. The default is always recommendation, not action.
- This is a learning environment — I want to understand changes before they are
  made. See docs/decisions.md ("Use of AI").

## Working style
- I am learning — explain what you are doing and why before doing it.
- Work in small steps, not large automated changes.
- Never generate whole files unprompted.
- When referencing code, cite file paths (and line numbers where useful).

## Conventions
- British English throughout — spelling, terminology and comments.
- Hostnames follow the pattern: hostname.lab.uprightlab.com
- All infrastructure is managed as code from this repository.

## Secrets
- Never commit plaintext secrets or private keys to the repository.
- In-lab credentials are encrypted with Ansible Vault and may be committed.
- Externally-usable credentials stay out of the repo (stored in 1Password).
- Public keys, and password hashes where a platform requires them in config,
  may be committed.
- See docs/decisions.md for the full secrets rationale.

## References
Consider the following when responding on related topics:
- https://docs.ansible.com/projects/ansible/latest/tips_tricks/sample_setup.html
- https://semaphoreui.com/docs/admin-guide/installation/docker