#!/bin/zsh

set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "usage: scripts/run-codex-review.sh [prompt]" >&2
  exit 64
fi

if [[ $# -eq 1 ]]; then
  if [[ "$1" == -* ]]; then
    echo "option arguments are not allowed; pass a prompt string or use stdin" >&2
    exit 64
  fi

  exec codex exec --sandbox read-only --ephemeral "$1"
fi

exec codex exec --sandbox read-only --ephemeral -
