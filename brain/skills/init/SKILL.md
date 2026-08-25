---
name: init
description: Set up a new brAIn memory vault on this machine — create it from the brAIn template repo (or clone the user's existing vault) and configure the BRAIN_VAULT environment variable. Use when the user wants to create their brain/memory vault or when another brain skill reports BRAIN_VAULT is not configured.
---

# /brain:init — set up a brAIn vault

A brAIn is a private git repo of Markdown notes (an Obsidian vault) used as
persistent memory by the user and AI sessions. All brain skills locate it via the
`BRAIN_VAULT` environment variable — there is no default path.

Template: https://github.com/rcamf/brAIn-template

Use only plain `git` — do not assume `gh` or any other forge CLI is installed.

## Steps

1. **Check existing config**: if `BRAIN_VAULT` is set and the directory is a git
   repo, the vault is already configured — report that and stop.
2. **Determine the situation** (ask if unclear from `$ARGUMENTS`):
   - **User already has a vault repo** (e.g. created on another machine) → ask for
     its git URL and the local path to clone to, then `git clone <url> <path>`.
   - **Brand new vault** → ask for a local path, then create it from the template
     with fresh history:

     ```bash
     git clone --depth 1 https://github.com/rcamf/brAIn-template "<path>"
     rm -rf "<path>/.git"
     git -C "<path>" init -b main
     git -C "<path>" add -A
     git -C "<path>" commit -m "Initialize brAIn vault from template"
     ```

     Then ask the user to create an **empty private repo** on their forge of
     choice (GitHub/GitLab/etc. — it's their memory, keep it private) and paste
     its git URL. When they do:

     ```bash
     git -C "<path>" remote add origin <url>
     git -C "<path>" push -u origin main
     ```

     If they'd rather skip the remote for now, that's fine — the vault works
     locally; remind them it won't sync until they add one.
3. **Persist BRAIN_VAULT** in BOTH places:
   - **Shell profile**: append `export BRAIN_VAULT="<absolute path>"`. Pick the
     right file: honor `$ZDOTDIR` if set (`$ZDOTDIR/.zshrc`), else `~/.zshrc`
     for zsh or `~/.bashrc` for bash (check `$SHELL`). Skip if an identical line
     exists.
   - **Claude Code settings**, so sessions get it even when the profile isn't
     sourced: merge `{"env": {"BRAIN_VAULT": "<absolute path>"}}` into
     `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json` — read the file if it
     exists and add/update only the `env.BRAIN_VAULT` key, never overwrite other
     settings (use python3/jq for the JSON merge, and create the file with just
     that env block if missing). If the user runs multiple Claude config dirs,
     offer to update each.
4. **Verify**: confirm the path contains `CLAUDE.md` and `Home.md`.
5. Report: the vault path, its remote (or that none is set), and suggest opening
   the folder as a vault in Obsidian. Note that `BRAIN_VAULT` takes effect in new
   shells/sessions.
