---
name: session
description: Keep this session's working memory in the brAIn vault instead of the repo or worktree. Use whenever you are about to create a plan, notes, design doc, decision log, or any scratch markdown that is not a project deliverable — write it under the vault's sessions/ area instead of the working tree. Also use when the user says "note this down", "keep session notes in the brain", or asks where session docs should go.
---

# /brain:session — per-session working memory in the vault

Sessions must not litter repos and worktrees with PLAN.md / NOTES.md style docs.
That material is memory, and memory lives in the brAIn vault under a per-session
folder: `sessions/<slug>/`.

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
   there with a header noting the repo path, branch, and start date (absolute,
   e.g. 2026-08-25).
3. **Write the doc** into that folder:
   - Running notes, decisions, findings → append dated entries to `log.md`.
   - Substantial docs (a plan, a design) → their own file, e.g. `plan.md`.
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
every subsequent scratch/planning doc goes to the same session folder, never the
working tree. Project deliverables (code, README changes, docs that ship with the
repo) still belong in the repo.

## Arguments

`$ARGUMENTS` optionally describes what to write down. If empty, write down the
session's current state: what it's doing, decisions so far, open questions.
