---
name: ingest
description: Transform a whole code repository into interlinked notes in the brAIn vault — an architecture overview plus one note per subsystem/key concept, wikilinked into the knowledge graph. Use when the user says "ingest this repo", "turn this repo into notes", "document this repo in my brain", or wants a repo mapped into their vault. Re-running updates the existing notes.
---

# /brain:ingest — distill a repository into vault notes

Produces a durable, browsable map of a codebase inside the brAIn vault: what it
is, how it's shaped, and the decisions baked into it — the things a person (or a
future session) needs to get oriented without re-reading the code.

All vault mechanics go through the plugin's helper CLI, `scripts/brain.sh` at
the plugin root (two directories above this skill's base directory):

```bash
BRAIN="<this skill's base directory>/../../scripts/brain.sh"
VAULT=$("$BRAIN" vault)
```

If `vault` fails, stop and relay its message (the fix is `/brain:init`).

## Target repo

`$ARGUMENTS` may name a path; otherwise use the current repo. The repo's notes
live in its area folder: `AREA=$("$BRAIN" area [path])` resolves an existing
area folder by loose name match (e.g. `PadelReplay/` for repo `padel-replay`)
or creates one. Record the current commit (`git rev-parse --short HEAD`) so the
notes say what state they describe.

## Steps

1. **Sync**: `"$BRAIN" sync`.
2. **Explore the repo thoroughly** before writing anything: README and docs,
   entry points, directory layout, major subsystems and how they interact, data
   flow, build/test/deploy setup, and any decision records. For a large repo,
   fan out Explore agents over subsystems instead of reading everything inline.
3. **Write the notes** into `$AREA`:
   - **Overview note** named after the repo (e.g. `PadelReplay.md`): purpose,
     tech stack, high-level architecture, and a linked map of the subsystem
     notes. Frontmatter:

     ```markdown
     ---
     tags: [repo]
     path: <absolute local path>
     branch: <branch>
     commit: <short sha>
     ingested: <YYYY-MM-DD>
     ---

     (`"$BRAIN" ref [path]` prints `repo@branch#sha`; subsystem notes carry the
     same `branch`/`commit`/`ingested` frontmatter.)
     ```

   - **One note per major subsystem or key concept** (aim for the handful that
     matter, not one per file): responsibility, key files with paths, how it
     connects to the rest, non-obvious decisions and gotchas. Wikilink notes to
     each other and to any existing vault notes on related topics.
   - Capture what the code can't say quickly: why it's built this way, invariants,
     sharp edges. Don't transcribe code.
4. **Weave it into the existing knowledge base** — the repo notes must join the
   graph, not sit beside it:
   - Before writing each note, `"$BRAIN" search <terms>` for existing notes on
     related topics — techniques, architectures, tools, other repos — and
     `[[wikilink]]` them wherever they're relevant to this repo.
   - Where the repo is a meaningful example of something an existing topic note
     covers, also add a short line to that note (e.g. under "Seen in":
     `[[<Repo overview>]] — how it's applied there`) so knowledge accumulates on
     the topic side too. Extend existing notes; never duplicate their content
     into the repo notes.
   - Don't invent new general topic notes as part of ingest — dangling
     `[[links]]` are fine and mark topics worth writing up later.
5. **Connect the graph**: link the overview note from `Home.md`.
6. **Re-ingesting**: if the repo's area folder already has notes, update them in
   place (refresh `commit`/`ingested`, revise what changed, keep manually added
   content) — never create duplicates.
7. **Save**: `"$BRAIN" save "ingest <slug> @ <sha>"`.
8. **Report**: list the notes created/updated, one line each.
