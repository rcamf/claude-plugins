---
name: session
description: Mirror this session's working docs (plans, notes, design docs, decision logs) into the brAIn vault's sessions/ area so they are browsable in Obsidian and synced across machines. Use whenever creating or updating a scratch/planning markdown doc in a repo or worktree — keep the worktree copy AND mirror it to the vault. Also use when the user says "note this down" or "add session notes to the brain".
---

# /brain:session — mirror session working memory into the vault

Working docs (PLAN.md, NOTES.md, design sketches, decision logs) are created in
the repo/worktree exactly as usual — that stays the working copy. This skill
ADDS a synced copy in the brAIn vault under `sessions/<slug>/`, so every
session's memory is browsable in Obsidian and available on other machines.
Never delete or relocate the worktree originals.

```bash
VAULT="$BRAIN_VAULT"
```

If `BRAIN_VAULT` is unset or the directory is missing, stop and tell the user to
run `/brain:init`.

## Session slug

Derive it from where the session is working, and reuse the same folder for the
whole session (and for later sessions in the same worktree/branch):

```bash
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || ROOT=$PWD
BRANCH=$(git -C "$ROOT" branch --show-current 2>/dev/null)
SLUG=$(basename "$ROOT")
case "$BRANCH" in ""|main|master) ;; *) SLUG="$SLUG-$BRANCH";; esac
SLUG=$(printf '%s' "$SLUG" | tr '/ ' '--')
```

## Steps

1. **Sync first**: `git -C "$VAULT" pull --rebase --quiet` (tolerate failure —
   work locally, mention it).
2. **Create/reuse** `"$VAULT/sessions/$SLUG/"`. On first use, create `log.md`
   there with frontmatter matching the vault's `templates/Session log.md`
   template — real values, not `{{placeholders}}`:

   ```markdown
   ---
   tags: [session]
   repo: <absolute repo/worktree path>
   branch: <branch>
   started: <YYYY-MM-DD>
   ---
   ```

   (The frontmatter feeds the vault's `Sessions.base` overview.)
3. **Mirror the docs**:
   - Scratch/planning docs created in the worktree → copy them into the session
     folder, and re-copy whenever they change meaningfully. Same filename.
   - Running notes, decisions, findings with no worktree file → append dated
     entries to `log.md`.
   - Wikilink to main vault notes (`[[Topic]]`) where relevant — that's what
     makes later consolidation easy.
4. **Do NOT promote anything into the main vault.** Session folders are working
   memory; moving knowledge into topic notes happens only via `/brain:consolidate`
   when the user explicitly asks.
5. **Commit and push**:
   `git -C "$VAULT" add -A && git -C "$VAULT" commit -m "session $SLUG: <what>" && git -C "$VAULT" push`
   (if push fails, leave the commit; it syncs later).

## Standing rule for the session

Once this skill has been used, keep following it for the rest of the session:
whenever a scratch/planning doc is created or substantially updated in the
worktree, mirror it to the session folder. Project deliverables (code, README
changes, docs that ship with the repo) live only in the repo — don't mirror
those.

## Arguments

`$ARGUMENTS` optionally describes what to write down. If empty, mirror any
existing session docs from the worktree and record the session's current state:
what it's doing, decisions so far, open questions.
