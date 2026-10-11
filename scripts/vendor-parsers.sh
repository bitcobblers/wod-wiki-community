#!/usr/bin/env bash
# Populate vendor/@bitcobblers with freshly built parser packages from the
# wod-wiki monorepo. vendor/ is gitignored — this recreates it after a fresh
# clone. Temporary until the monorepo packages are republished properly and
# this repo switches to registry pins.
#
# Usage: scripts/vendor-parsers.sh [path-to-wod-wiki]   (default: ../wod-wiki)
set -euo pipefail

SEED_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WOD_WIKI="${1:-$SEED_ROOT/../wod-wiki}"

for pkg in core lang wql; do
  src="$WOD_WIKI/packages/$pkg"
  dest="$SEED_ROOT/vendor/@bitcobblers/wod-wiki-$pkg"
  if [[ ! -d "$src/dist" ]]; then
    echo "missing $src/dist — build it first: bun run --cwd $src build" >&2
    exit 1
  fi
  rm -rf "$dest"
  mkdir -p "$dest/dist"
  cp "$src/package.json" "$dest/package.json"
  cp "$src/dist/"* "$dest/dist/"
  rm -f "$dest/dist/"*.map
  echo "vendored wod-wiki-$pkg"
done
