---
name: consolidate
description: Promote a session's working notes from the brAIn vault's sessions/ area into the main knowledge graph, then archive the session folder. ONLY run when the user explicitly asks to consolidate — never automatically at session end.
---

# /brain:consolidate — fold session memory into the knowledge graph

Session folders under `sessions/` are raw working memory. Consolidation distills
what is worth keeping into proper topic notes. This is deliberate and user-driven:
run it only on explicit request.

```bash
VAULT="$BRAIN_VAULT"
```

If `BRAIN_VAULT` is unset or the directory is missing, stop and tell the user to
run `/brain:init`.

## Steps

1. **Sync first**: `git -C "$VAULT" pull --rebase --quiet`.
2. **Pick the session**: `$ARGUMENTS` names a session slug. If empty, list
   `sessions/` (excluding `archive/`) and ask the user which to consolidate
   ("all" is a valid answer — then do each in turn).
3. **Read everything** in the session folder.
4. **Promote durable knowledge** into the main vault:
   - Decisions and their reasons, lessons learned, gotchas, useful references,
     facts about projects/tools → update existing topic notes where they fit
     (`rg` for them first), otherwise create new ones. **Default to the
     session's repo area**: the session slug names the repo it worked in, so new
     notes go into that project's area folder (e.g. `PadelReplay/`), created if
     needed. Put a note elsewhere only when it is clearly not about that repo.
     Never write at the vault root unless the user explicitly asks. Add
     `[[wikilinks]]`, use absolute dates, link new areas from `Home.md`.
   - Leave behind the ephemeral: step-by-step narration, dead ends (unless the
     dead end itself is a lesson), stale TODO churn.
5. **Archive the session folder**: `mkdir -p "$VAULT/sessions/archive" && git -C "$VAULT" mv "sessions/<slug>" "sessions/archive/<slug>"`.
   Only delete instead of archiving if the user explicitly says to delete.
6. **Commit and push**:
   `git -C "$VAULT" add -A && git -C "$VAULT" commit -m "consolidate session <slug>" && git -C "$VAULT" push`.
7. **Report**: which notes were created/updated with what, and that the session
   folder was archived.
