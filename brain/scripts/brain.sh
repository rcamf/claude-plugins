#!/usr/bin/env bash
# brain.sh — helper CLI consumed by the brain plugin skills.
# Every command prints its result to stdout; errors go to stderr with exit 2.
set -euo pipefail

vault() {
  [ -n "${BRAIN_VAULT:-}" ] || { echo "error: BRAIN_VAULT is not set — run /brain:init" >&2; exit 2; }
  [ -d "$BRAIN_VAULT/.git" ] || { echo "error: BRAIN_VAULT ($BRAIN_VAULT) is not a git repo — run /brain:init" >&2; exit 2; }
  printf '%s\n' "$BRAIN_VAULT"
}

repo_root() {
  git -C "${1:-.}" rev-parse --show-toplevel 2>/dev/null || (cd "${1:-.}" && pwd)
}

norm() { printf '%s' "$1" | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]'; }

cmd=${1:-}; [ $# -gt 0 ] && shift
case "$cmd" in
  vault)
    vault ;;

  sync)
    V=$(vault)
    if git -C "$V" pull --rebase --autostash --quiet >/dev/null 2>&1; then
      echo "synced"
    else
      echo "sync failed (offline, or another session mid-change) — working locally"
    fi ;;

  save)
    V=$(vault); msg=${1:?usage: brain.sh save "<message>"}
    git -C "$V" add -A
    if git -C "$V" diff --cached --quiet && [ ! -f "$V/.git/MERGE_HEAD" ]; then echo "nothing to commit"; exit 0; fi
    git -C "$V" commit -q -m "$msg"
    if git -C "$V" push -q 2>/dev/null; then echo "committed and pushed"; else echo "committed (push failed — will sync later)"; fi ;;

  slug)
    root=$(repo_root "${1:-.}")
    branch=$(git -C "$root" branch --show-current 2>/dev/null || true)
    slug=$(basename "$root")
    case "$branch" in ""|main|master) ;; *) slug="$slug-$branch" ;; esac
    printf '%s\n' "$slug" | tr '/ ' '--' ;;

  ref)
    # Provenance for the repo at [path]: repo@branch#shortsha. Silent if not a repo.
    root=$(git -C "${1:-.}" rev-parse --show-toplevel 2>/dev/null) || exit 0
    sha=$(git -C "$root" rev-parse --short HEAD 2>/dev/null || true)
    branch=$(git -C "$root" branch --show-current 2>/dev/null || true)
    printf '%s@%s#%s\n' "$(basename "$root")" "${branch:-detached}" "${sha:-none}" ;;

  area)
    # Resolve (or create) the area folder for the repo at [path]; loose name match.
    V=$(vault)
    root=$(repo_root "${1:-.}")
    name=$(basename "$root")
    # A repo named like a structural folder must not claim that folder.
    case "$name" in sessions|templates|attachments) name="$name (repo)" ;; esac
    want=$(norm "$name")
    for d in "$V"/*/; do
      [ -d "$d" ] || continue
      b=$(basename "$d")
      case "$b" in sessions|templates|attachments) continue ;; esac
      if [ "$(norm "$b")" = "$want" ]; then printf '%s\n' "$V/$b"; exit 0; fi
    done
    mkdir -p "$V/$name"
    printf '%s\n' "$V/$name" ;;

  session-dir)
    # Ensure sessions/<slug>/ with a frontmattered log.md; print the dir.
    V=$(vault)
    slug=$("$0" slug "${1:-.}")
    root=$(repo_root "${1:-.}")
    branch=$(git -C "$root" branch --show-current 2>/dev/null || true)
    dir="$V/sessions/$slug"
    mkdir -p "$dir"
    if [ ! -f "$dir/log.md" ]; then
      {
        echo '---'
        echo 'tags: [session]'
        echo "repo: $root"
        echo "branch: $branch"
        echo "started: $(date +%F)"
        echo '---'
        echo
        echo "# $slug"
        echo
      } > "$dir/log.md"
    fi
    printf '%s\n' "$dir" ;;

  search)
    # List notes matching any term, by filename or content.
    V=$(vault)
    [ $# -gt 0 ] || { echo "usage: brain.sh search <term>..." >&2; exit 2; }
    for t in "$@"; do
      find "$V" -name '*.md' -not -path '*/.obsidian/*' -ipath "*${t}*" 2>/dev/null || true
      if command -v rg >/dev/null 2>&1; then
        rg -il --glob '*.md' -g '!.obsidian' -- "$t" "$V" 2>/dev/null || true
      else
        grep -rli --include='*.md' -- "$t" "$V" 2>/dev/null || true
      fi
    done | sort -u ;;

  update)
    # Merge template repo updates into the vault (first merge bridges histories).
    V=$(vault)
    git -C "$V" remote get-url template >/dev/null 2>&1 || \
      git -C "$V" remote add template "${BRAIN_TEMPLATE_URL:-https://github.com/rcamf/brAIn-template}"
    git -C "$V" fetch -q template
    if git -C "$V" merge-base HEAD template/main >/dev/null 2>&1; then
      git -C "$V" merge template/main -m "Merge brAIn template updates"
    else
      git -C "$V" merge template/main --allow-unrelated-histories -m "Merge brAIn template updates"
    fi ;;

  *)
    cat >&2 <<'USAGE'
usage: brain.sh <command>
  vault               print the vault path (validates BRAIN_VAULT)
  sync                pull --rebase the vault (tolerates offline)
  save "<msg>"        add/commit/push everything in the vault (tolerates offline)
  slug [path]         session/repo slug for a working directory
  ref [path]          provenance of a working directory: repo@branch#shortsha
  area [path]         resolve or create the repo's area folder; print its path
  session-dir [path]  ensure sessions/<slug>/ with log.md; print its path
  search <term>...    list notes matching terms (filename or content)
  update              merge brAIn-template updates into the vault
USAGE
    exit 2 ;;
esac
