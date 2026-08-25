---
name: update
description: Merge the latest improvements from the brAIn template repo (conventions, templates, bases) into the user's own vault. Use when the user asks to update their brain/vault to the newest template, or sync template changes into their fork.
---

# /brain:update — pull template improvements into the vault

Vaults are created from https://github.com/rcamf/brAIn-template and then diverge
with personal content. This skill merges template-side improvements (CLAUDE.md
conventions, `templates/`, `*.base` files, README) into the vault without
touching the user's notes.

All vault mechanics go through the plugin's helper CLI, `scripts/brain.sh` at
the plugin root (two directories above this skill's base directory):

```bash
BRAIN="<this skill's base directory>/../../scripts/brain.sh"
VAULT=$("$BRAIN" vault)
```

If `vault` fails, stop and relay its message (the fix is `/brain:init`).

## Steps

1. **Sync the vault first**: `"$BRAIN" sync`; make sure the working tree is
   clean (commit pending changes with `"$BRAIN" save "<msg>"` before merging).
2. **Merge**: `"$BRAIN" update` — it adds the `template` remote if missing,
   fetches, and merges `template/main` (bridging unrelated histories on the
   first ever merge automatically).
3. **If it reports conflicts, resolve conservatively**:
   - The user's own notes and `Home.md` content always win — never lose or
     rewrite personal content to match the template.
   - Convention/template files (`CLAUDE.md`, `templates/`, `*.base`) — take the
     template's new material, but preserve any local additions by merging both.
   - If a conflict is genuinely ambiguous, show both sides and ask the user.
   - Finish with `git -C "$VAULT" add -A && git -C "$VAULT" commit --no-edit`.
4. **Push**: `git -C "$VAULT" push`.
5. **Report**: which files changed, in one line each; say "already up to date"
   plainly if nothing came in.
