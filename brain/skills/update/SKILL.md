---
name: update
description: Merge the latest improvements from the brAIn template repo (conventions, templates, bases) into the user's own vault. Use when the user asks to update their brain/vault to the newest template, or sync template changes into their fork.
---

# /brain:update — pull template improvements into the vault

Vaults are created from https://github.com/rcamf/brAIn-template and then diverge
with personal content. This skill merges template-side improvements (CLAUDE.md
conventions, `templates/`, `*.base` files, README) into the vault without
touching the user's notes.

```bash
VAULT="$BRAIN_VAULT"
```

If `BRAIN_VAULT` is unset or the directory is missing, stop and tell the user to
run `/brain:init`.

## Steps

1. **Sync the vault first**: `git -C "$VAULT" pull --rebase --quiet`; make sure
   the working tree is clean (commit or stash anything pending before merging).
2. **Ensure the template remote**:

   ```bash
   git -C "$VAULT" remote get-url template 2>/dev/null || \
     git -C "$VAULT" remote add template https://github.com/rcamf/brAIn-template
   git -C "$VAULT" fetch template
   ```

3. **Merge**: `git -C "$VAULT" merge template/main -m "Merge brAIn template updates"`.
   If the vault has no previous template merge (unrelated histories), add
   `--allow-unrelated-histories` — after this first merge, future updates share
   a merge base and stay clean.
4. **Resolve conflicts conservatively**:
   - The user's own notes and `Home.md` content always win — never lose or
     rewrite personal content to match the template.
   - Convention/template files (`CLAUDE.md`, `templates/`, `*.base`) — take the
     template's new material, but preserve any local additions by merging both.
   - If a conflict is genuinely ambiguous, show both sides and ask the user.
5. **Push**: `git -C "$VAULT" push`.
6. **Report**: which files changed, in one line each; say "already up to date"
   plainly if nothing came in.
