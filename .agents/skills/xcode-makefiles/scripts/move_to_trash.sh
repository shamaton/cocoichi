#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: move_to_trash.sh <paths...>
USAGE
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

delete_fallback() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    return 0
  fi

  local abs_path
  abs_path="$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
  local cwd
  cwd="$(pwd -P)"

  case "$abs_path" in
    /tmp/*|/private/tmp/*|/var/folders/*/T/*|"$cwd"/*)
      /bin/rm -rf "$abs_path"
      ;;
    *)
      echo "Failed to move '$abs_path' to Trash. Refusing permanent delete outside temp/current directory." >&2
      return 1
      ;;
  esac
}

trash_failed=0
if command -v trash >/dev/null 2>&1; then
  if trash "$@" 2>/dev/null; then
    exit 0
  fi
  trash_failed=1
elif command -v osascript >/dev/null 2>&1; then
  osa_failed=0
  for path in "$@"; do
    if [[ -e "$path" ]]; then
      if ! /usr/bin/osascript -e 'tell application "Finder" to delete POSIX file '"'"$path"'"''; then
        osa_failed=1
      fi
    fi
  done
  if [[ $osa_failed -eq 0 ]]; then
    exit 0
  fi
fi

if [[ $trash_failed -eq 1 ]]; then
  echo "Trash move failed; falling back to direct delete for sandbox-safe paths." >&2
fi

for path in "$@"; do
  delete_fallback "$path"
done
