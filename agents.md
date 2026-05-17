# uprightlab — AI agent briefing

## About this project
A personal homelab built on Proxmox and Kubernetes.
See README.md for full project context and documentation.

## Working style
- I am learning — explain what you are doing and why before doing it
- Work in small steps, not large automated changes
- Ask before creating or modifying any file
- Never run destructive commands without explicit confirmation
- Never generate whole files unprompted

## Conventions
- British English throughout — spelling, terminology and comments
- Hostnames follow the pattern: name.uprightlab.local
- All infrastructure is managed as code from this repository

## Secrets
- Never commit secrets, passwords or keys to the repository
- Secrets are managed with SOPS — see docs/decisions.md
