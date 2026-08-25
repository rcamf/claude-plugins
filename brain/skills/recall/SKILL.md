---
name: recall
description: Search the user's brAIn vault (their Obsidian-style markdown knowledge base synced via git, located by $BRAIN_VAULT) and answer from it. Use when the user asks "what do I know about X", "check my brain/vault/notes", or when past personal notes would answer their question.
---

# /brain:recall — retrieve from the brAIn vault

The vault is a git-synced Obsidian vault at `$BRAIN_VAULT`:

```bash
VAULT="$BRAIN_VAULT"
```

If `BRAIN_VAULT` is unset or the directory is missing, stop and tell the user to
run `/brain:init`. Notes are plain Markdown, one topic per file, connected with
`[[wikilinks]]`.

## Steps

1. **Sync first**: `git -C "$VAULT" pull --rebase --quiet` (ignore failures —
   answer from the local copy and note it wasn't refreshed).
2. **Search broadly**: filenames first (`ls "$VAULT"/*.md`), then content:
   `rg -il '<term>' "$VAULT" --glob '*.md'`. Try synonyms if the first term
   misses.
3. **Read the matching notes** and follow `[[wikilinks]]` one hop when they look
   relevant to the question.
4. **Answer from the vault**, naming the notes the answer came from (e.g. "from
   [[Postgres tuning]]"). If the vault has nothing, say so plainly — don't pad
   with general knowledge unless the user wants it.
5. Read-only by default: do not modify or commit anything during recall.

## Arguments

`$ARGUMENTS` is the question or topic. If empty, ask what to look up.
