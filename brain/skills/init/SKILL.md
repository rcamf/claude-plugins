---
name: init
description: Set up a new brAIn memory vault on this machine — create it from the brAIn template repo (or clone the user's existing vault) and configure the BRAIN_VAULT environment variable. Use when the user wants to create their brain/memory vault or when another brain skill reports BRAIN_VAULT is not configured.
---

# /brain:init — set up a brAIn vault

A brAIn is a private git repo of Markdown notes (an Obsidian vault) used as
persistent memory by the user and AI sessions. All brain skills locate it via the
`BRAIN_VAULT` environment variable — there is no default path.

Template: https://github.com/rcamf/brAIn-template

## Steps

1. **Check existing config**: if `BRAIN_VAULT` is set and the directory is a git
   repo, the vault is already configured — report that and stop.
2. **Determine the situation** (ask if unclear from `$ARGUMENTS`):
   - **User already has a vault repo** (e.g. on another machine) → ask for its git
     URL and the local path to clone to, then `git clone <url> <path>`.
   - **Brand new vault** → ask for a local path and a repo name, then create a
     private repo from the template and clone it:
     `gh repo create <name> --private --template rcamf/brAIn-template --clone`
     (run in the parent directory of the desired path; requires `gh` auth — if
     unavailable, fall back to `git clone https://github.com/rcamf/brAIn-template <path>`
     followed by removing the `origin` remote, and tell the user to add their own
     private remote for sync).
3. **Persist BRAIN_VAULT**: append to the user's shell profile (`~/.zshrc` for
   zsh, `~/.bashrc` for bash — check `$SHELL`):
   `export BRAIN_VAULT="<absolute path>"`. Skip if an identical line exists.
4. **Verify**: confirm the path contains `CLAUDE.md` and `Home.md`.
5. Report: the vault path, its remote, and suggest opening the folder as a vault
   in Obsidian. Note that `BRAIN_VAULT` takes effect in new shells/sessions.
