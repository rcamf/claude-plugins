---
name: remember
description: Save a fact, idea, or note into the user's brAIn vault (their Obsidian-style markdown knowledge base synced via git, located by $BRAIN_VAULT). Use when the user says "remember X", "add to my brain/vault", or wants to capture knowledge for later. Searches for an existing note first, updates or creates one with wikilinks, then commits and pushes.
---

# /brain:remember — capture into the brAIn vault

The vault is a git-synced Obsidian vault at `$BRAIN_VAULT`:

```bash
VAULT="$BRAIN_VAULT"
```

If `BRAIN_VAULT` is unset or the directory is missing, stop and tell the user to
run `/brain:init`. Notes are plain Markdown, one topic per file, linked with
`[[wikilinks]]`. Read the vault's `CLAUDE.md` if you need the full conventions.

## Steps

1. **Sync first**: `git -C "$VAULT" pull --rebase --quiet`. If it fails (offline,
   conflict), continue working locally and mention it at the end.
2. **Search before writing**: `rg -il '<topic terms>' "$VAULT" --glob '*.md'` and
   check filenames (`ls`) for an existing note on the topic. Prefer updating an
   existing note over creating a near-duplicate.
3. **Write the note**:
   - New topic → new file, filename is the title: `Topic name.md`.
   - Add `[[wikilinks]]` to related existing notes; links to not-yet-existing notes
     are fine and encouraged.
   - Use absolute dates (e.g. 2026-08-25), never relative ones.
   - Quick unstructured capture with no obvious home → append to `Inbox.md`.
4. **Keep the graph connected**: if you created a new top-level area, link it from
   `Home.md`.
5. **Commit and push**:
   `git -C "$VAULT" add -A && git -C "$VAULT" commit -m "<what changed>" && git -C "$VAULT" push`.
   If push fails, leave the commit and tell the user it will sync next time.
6. Report which note was created/updated, in one or two sentences.

## Arguments

`$ARGUMENTS` is the thing to remember. If empty, ask what to capture.
