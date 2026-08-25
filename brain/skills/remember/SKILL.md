---
name: remember
description: Save a fact, idea, or note into the user's brAIn vault (their Obsidian-style markdown knowledge base synced via git, located by $BRAIN_VAULT). Use when the user says "remember X", "add to my brain/vault", or wants to capture knowledge for later. Searches for an existing note first, updates or creates one with wikilinks, then commits and pushes.
---

# /brain:remember — capture into the brAIn vault

All vault mechanics go through the plugin's helper CLI, `scripts/brain.sh` at
the plugin root (two directories above this skill's base directory):

```bash
BRAIN="<this skill's base directory>/../../scripts/brain.sh"
VAULT=$("$BRAIN" vault)
```

If `vault` fails, stop and relay its message (the fix is `/brain:init`).
Notes are plain Markdown, one topic per file, linked with `[[wikilinks]]`.
Read the vault's `CLAUDE.md` if you need the full conventions.

## Steps

1. **Sync**: `"$BRAIN" sync` (if it reports working locally, mention that at
   the end).
2. **Search before writing**: `"$BRAIN" search <term>...` — try synonyms too.
   Prefer updating an existing note over creating a near-duplicate.
3. **Write the note**:
   - **Default to the current repo's area**: `AREA=$("$BRAIN" area)` resolves
     (or creates) the area folder for the repo the session is running in. Only
     place the note elsewhere when the fact is clearly unrelated to the current
     repo (or there is no repo context); then pick the best-fitting general
     area folder. Never save a note at the vault root unless the user
     explicitly asks.
   - New topic → new file, filename is the title: `Topic name.md`.
   - Add `[[wikilinks]]` to related existing notes; links to not-yet-existing
     notes are fine and encouraged.
   - Use absolute dates (e.g. 2026-08-25), never relative ones.
   - Quick unstructured capture with no obvious home → append to `Inbox.md`.
4. **Keep the graph connected**: if you created a new area folder, link it from
   `Home.md`.
5. **Save**: `"$BRAIN" save "<what changed>"`.
6. Report which note was created/updated, in one or two sentences.

## Arguments

`$ARGUMENTS` is the thing to remember. If empty, ask what to capture.
