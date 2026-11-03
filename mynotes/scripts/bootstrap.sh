#!/usr/bin/env bash
# Fetch the pinned upstream anarlog commit and apply MyNotes patches.
# Usage: mynotes/scripts/bootstrap.sh [target_dir]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-$ROOT/build/anarlog}"
# shellcheck disable=SC1091
source <(grep -E '^(repo|commit)=' "$ROOT/UPSTREAM")

if [ ! -d "$TARGET/.git" ]; then
  mkdir -p "$TARGET"
  git -C "$TARGET" init -q
  git -C "$TARGET" remote add origin "$repo"
fi
git -C "$TARGET" fetch --depth 1 origin "$commit"
git -C "$TARGET" checkout -q --force FETCH_HEAD

# Never ship the commercially licensed enterprise components.
rm -rf "$TARGET/enterprise"

for p in "$ROOT"/patches/*.patch; do
  echo "applying $(basename "$p")"
  git -C "$TARGET" apply --whitespace=nowarn "$p"
done

echo "ready: $TARGET"
