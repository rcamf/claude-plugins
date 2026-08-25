---
name: recall
description: Search the user's brAIn vault (their Obsidian-style markdown knowledge base synced via git, located by $BRAIN_VAULT) and answer from it. Use when the user asks "what do I know about X", "check my brain/vault/notes", or when past personal notes would answer their question.
---

# /brain:recall — retrieve from the brAIn vault

All vault mechanics go through the plugin's helper CLI, `scripts/brain.sh` at
the plugin root (two directories above this skill's base directory):

```bash
BRAIN="<this skill's base directory>/../../scripts/brain.sh"
VAULT=$("$BRAIN" vault)
```

If `vault` fails, stop and relay its message (the fix is `/brain:init`).

## Steps

1. **Sync**: `"$BRAIN" sync` (if it reports working locally, note the answer
   may be slightly stale).
2. **Search broadly**: `"$BRAIN" search <term>...` — it matches filenames and
   content. Try synonyms if the first terms miss.
3. **Read the matching notes** and follow `[[wikilinks]]` one hop when they
   look relevant to the question.
4. **Answer from the vault**, naming the notes the answer came from (e.g. "from
   [[Postgres tuning]]"). If the vault has nothing, say so plainly — don't pad
   with general knowledge unless the user wants it.
5. Read-only: do not modify or commit anything during recall.

## Arguments

`$ARGUMENTS` is the question or topic. If empty, ask what to look up.
