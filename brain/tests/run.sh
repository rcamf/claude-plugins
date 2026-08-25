#!/usr/bin/env bash
# Tests for scripts/brain.sh. Runs entirely in a throwaway temp directory with
# a local bare "origin" and a local fake template repo — never touches the real
# vault or the network. Usage: tests/run.sh
set -u

HERE=$(cd "$(dirname "$0")" && pwd)
BRAIN="$HERE/../scripts/brain.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Isolate git from user/system config and give it an identity.
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@test
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@test

pass=0; fail=0
ok()  { pass=$((pass+1)); printf 'ok   - %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL - %s\n' "$1"; }
eq()  { [ "$2" = "$3" ] && ok "$1" || bad "$1 — expected [$2] got [$3]"; }
has() { case "$3" in *"$2"*) ok "$1" ;; *) bad "$1 — output lacks [$2]: [$3]" ;; esac; }

# --- fixture: vault with a local bare origin ---------------------------------
git init -q --bare "$TMP/origin.git"
git -C "$TMP/origin.git" symbolic-ref HEAD refs/heads/main
V="$TMP/vault"
git init -q -b main "$V"
mkdir -p "$V/sessions" "$V/templates" "$V/attachments" "$V/PadelReplay"
echo "# Home" > "$V/Home.md"
echo "conventions" > "$V/CLAUDE.md"
echo "court calibration details" > "$V/PadelReplay/Calibration.md"
git -C "$V" add -A && git -C "$V" commit -qm init
git -C "$V" remote add origin "$TMP/origin.git"
git -C "$V" push -qu origin main
export BRAIN_VAULT="$V"

# --- vault -------------------------------------------------------------------
BRAIN_VAULT= "$BRAIN" vault >/dev/null 2>&1;          eq "vault: empty BRAIN_VAULT exits 2" 2 "$?"
BRAIN_VAULT="$TMP/nope" "$BRAIN" vault >/dev/null 2>&1; eq "vault: missing dir exits 2" 2 "$?"
eq "vault: prints path" "$V" "$("$BRAIN" vault)"

# --- slug --------------------------------------------------------------------
P="$TMP/proj"
git init -q -b main "$P"; echo x > "$P/x"; git -C "$P" add -A; git -C "$P" commit -qm x
eq "slug: main branch -> repo name" "proj" "$("$BRAIN" slug "$P")"
git -C "$P" checkout -qb feat/x
eq "slug: feature branch appended, / flattened" "proj-feat-x" "$("$BRAIN" slug "$P")"
mkdir -p "$TMP/plain dir"
eq "slug: non-git dir -> basename, space flattened" "plain-dir" "$("$BRAIN" slug "$TMP/plain dir")"

# --- area --------------------------------------------------------------------
mkdir -p "$TMP/padel-replay"
eq "area: loose match finds PadelReplay/" "$V/PadelReplay" "$("$BRAIN" area "$TMP/padel-replay")"
eq "area: no match creates folder" "$V/proj" "$("$BRAIN" area "$P")"
[ -d "$V/proj" ] && ok "area: created folder exists" || bad "area: created folder exists"
mkdir -p "$TMP/sessions"
eq "area: repo named like structural folder gets its own area" "$V/sessions (repo)" "$("$BRAIN" area "$TMP/sessions")"

# --- session-dir -------------------------------------------------------------
D=$("$BRAIN" session-dir "$P")
eq "session-dir: path under sessions/<slug>" "$V/sessions/proj-feat-x" "$D"
[ -f "$D/log.md" ] && ok "session-dir: log.md created" || bad "session-dir: log.md created"
has "session-dir: log.md has session tag" "tags: [session]" "$(cat "$D/log.md")"
has "session-dir: log.md records branch" "branch: feat/x" "$(cat "$D/log.md")"
echo "marker-entry" >> "$D/log.md"
"$BRAIN" session-dir "$P" >/dev/null
has "session-dir: idempotent (keeps existing log)" "marker-entry" "$(cat "$D/log.md")"

# --- search ------------------------------------------------------------------
has "search: matches filename and content" "PadelReplay/Calibration.md" "$("$BRAIN" search calibration)"
eq "search: dedupes name+content hits" "1" "$("$BRAIN" search calibration | wc -l | tr -d ' ')"
eq "search: no args exits 2" 2 "$(("$BRAIN" search >/dev/null 2>&1); echo $?)"

# --- save --------------------------------------------------------------------
echo "note" > "$V/proj/Note.md"
has "save: commits and pushes" "committed and pushed" "$("$BRAIN" save "add note")"
eq "save: message reaches origin" "add note" "$(git -C "$TMP/origin.git" log --format=%s -1 main)"
eq "save: clean tree is a no-op" "nothing to commit" "$("$BRAIN" save "noop")"

# --- sync --------------------------------------------------------------------
git clone -q "$TMP/origin.git" "$TMP/clone2"
echo "remote note" > "$TMP/clone2/Remote.md"
git -C "$TMP/clone2" add -A && git -C "$TMP/clone2" commit -qm remote && git -C "$TMP/clone2" push -q
echo "local edit" >> "$V/Home.md"   # dirty tree: sync must autostash around the pull
eq "sync: pulls with autostash" "synced" "$("$BRAIN" sync)"
[ -f "$V/Remote.md" ] && ok "sync: remote commit arrived" || bad "sync: remote commit arrived"
has "sync: local uncommitted edit survived" "local edit" "$(cat "$V/Home.md")"
"$BRAIN" save "keep local edit" >/dev/null

# --- update ------------------------------------------------------------------
T="$TMP/template"
git init -q -b main "$T"
mkdir -p "$T/templates"
echo "new template" > "$T/templates/Extra.md"
git -C "$T" add -A && git -C "$T" commit -qm template
BRAIN_TEMPLATE_URL="$T" "$BRAIN" update >/dev/null 2>&1
eq "update: first merge succeeds (unrelated histories)" 0 "$?"
[ -f "$V/templates/Extra.md" ] && ok "update: template file merged in" || bad "update: template file merged in"
"$BRAIN" update >/dev/null 2>&1
eq "update: re-run is clean (shared history)" 0 "$?"

# --- session-start hook ------------------------------------------------------
HOOK="$HERE/../scripts/session-start-hook.sh"
eq "hook: silent when not opted in" "" "$(cd "$P" && BRAIN_SESSION_AUTOSTART= "$HOOK")"
eq "hook: silent when opted out" "" "$(cd "$P" && BRAIN_SESSION_AUTOSTART=0 "$HOOK")"
eq "hook: silent when vault invalid" "" "$(cd "$P" && BRAIN_SESSION_AUTOSTART=1 BRAIN_VAULT="$TMP/nope" "$HOOK")"
has "hook: opted in emits standing rule with slug" "sessions/proj-feat-x/" "$(cd "$P" && BRAIN_SESSION_AUTOSTART=1 "$HOOK")"

# --- summary -----------------------------------------------------------------
echo
echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
