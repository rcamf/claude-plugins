---
name: consolidate
description: Promote a session's working notes from the brAIn vault's sessions/ area into the main knowledge graph, then archive the session folder. ONLY run when the user explicitly asks to consolidate — never automatically at session end.
---

# /brain:consolidate — fold session memory into the knowledge graph

Session folders under `sessions/` are raw working memory. Consolidation distills
what is worth keeping into proper topic notes. This is deliberate and
user-driven: run it only on explicit request.

All vault mechanics go through the plugin's helper CLI, `scripts/brain.sh` at
the plugin root (two directories above this skill's base directory):

```bash
BRAIN="<this skill's base directory>/../../scripts/brain.sh"
VAULT=$("$BRAIN" vault)
```

If `vault` fails, stop and relay its message (the fix is `/brain:init`).

## Steps

1. **Sync**: `"$BRAIN" sync`.
2. **Pick the session**: `$ARGUMENTS` names a session slug. If empty, list
   `"$VAULT/sessions/"` (excluding `archive/`) and ask the user which to
   consolidate ("all" is a valid answer — then do each in turn).
3. **Read everything** in the session folder.
4. **Promote durable knowledge** into the main vault:
   - Decisions and their reasons, lessons learned, gotchas, useful references,
     facts about projects/tools → update existing topic notes where they fit
     (`"$BRAIN" search <term>` finds them), otherwise create new ones.
   - **Default to the session's repo area**: the session's `log.md` frontmatter
     records the repo path — `AREA=$("$BRAIN" area <that repo path>)` resolves
     (or creates) the project's area folder, and new notes go there. Put a note
     elsewhere only when it is clearly not about that repo. Never write at the
     vault root unless the user explicitly asks.
   - Add `[[wikilinks]]`, use absolute dates, link new areas from `Home.md`.
   - Leave behind the ephemeral: step-by-step narration, dead ends (unless the
     dead end itself is a lesson), stale TODO churn.
5. **Archive the session folder**:
   `mkdir -p "$VAULT/sessions/archive" && git -C "$VAULT" mv "sessions/<slug>" "sessions/archive/<slug>"`.
   Only delete instead of archiving if the user explicitly says to delete.
6. **Save**: `"$BRAIN" save "consolidate session <slug>"`.
7. **Report**: which notes were created/updated with what, and that the session
   folder was archived.
