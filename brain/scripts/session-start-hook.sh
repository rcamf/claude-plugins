#!/usr/bin/env bash
# SessionStart hook: injects the session-mirroring standing rule into context.
# Opt-in — does nothing unless BRAIN_SESSION_AUTOSTART is 1/true/yes/on and
# BRAIN_VAULT points at a valid vault. stdout becomes session context.
set -u

case "${BRAIN_SESSION_AUTOSTART:-}" in 1|true|yes|on) ;; *) exit 0 ;; esac
[ -n "${BRAIN_VAULT:-}" ] && [ -d "${BRAIN_VAULT}/.git" ] || exit 0

slug=$("$(dirname "$0")/brain.sh" slug 2>/dev/null) || exit 0

cat <<EOF
brAIn session mirroring is enabled (BRAIN_SESSION_AUTOSTART). Standing rule for
this session: whenever you create or substantially update a scratch/planning
markdown doc (plan, notes, design sketch, decision log) in the repo/worktree,
keep the worktree copy AND mirror it into the brAIn vault via the /brain:session
skill (this session's folder: sessions/$slug/). Running notes and decisions with
no worktree file go to that folder's log.md. Do not wait to be asked. Project
deliverables that ship with the repo are not mirrored.
EOF
