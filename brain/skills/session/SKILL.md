---
name: session
description: Mirror this session's working docs (plans, notes, design docs, decision logs) into the brAIn vault's sessions/ area so they are browsable in Obsidian and synced across machines. Use whenever creating or updating a scratch/planning markdown doc in a repo or worktree — keep the worktree copy AND mirror it to the vault. Also use when the user says "note this down" or "add session notes to the brain".
---

# /brain:session — mirror session working memory into the vault

Working docs (PLAN.md, NOTES.md, design sketches, decision logs) are created in
the repo/worktree exactly as usual — that stays the working copy. This skill
ADDS a synced copy in the brAIn vault, so every session's memory is browsable
in Obsidian and available on other machines. Never delete or relocate the
worktree originals.

All vault mechanics go through the plugin's helper CLI, `scripts/brain.sh` at
the plugin root (two directories above this skill's base directory):

```bash
BRAIN="<this skill's base directory>/../../scripts/brain.sh"
DIR=$("$BRAIN" session-dir)   # ensures sessions/<slug>/ with a frontmattered log.md
```

If it fails, stop and relay its message (the fix is `/brain:init`).
`session-dir` derives the slug from the current repo/worktree and branch and
seeds `log.md` with the frontmatter that feeds the vault's `Sessions.base`.

## Steps

1. **Sync**: `"$BRAIN" sync` (tolerate a local-only result; mention it).
2. **Mirror into `$DIR`**:
   - Scratch/planning docs created in the worktree → copy them into `$DIR`,
     same filename; re-copy whenever they change meaningfully.
   - Running notes, decisions, findings with no worktree file → append dated
     entries to `$DIR/log.md`.
   - Wikilink to vault notes (`[[Topic]]`) where relevant — that's what makes
     later consolidation easy.
3. **Do NOT promote anything into the main vault.** Session folders are working
   memory; moving knowledge into topic notes happens only via
   `/brain:consolidate` when the user explicitly asks.
4. **Save**: `"$BRAIN" save "session $("$BRAIN" slug): <what>"`.

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
