#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT

mkdir -p \
  "$tmp/scripts" \
  "$tmp/hosts/nix-desktop" \
  "$tmp/hosts/nix-mac"
cp "$root/scripts/check-secret-hygiene" "$tmp/scripts/"
touch \
  "$tmp/.sops.yaml" \
  "$tmp/hosts/nix-desktop/secrets.yaml" \
  "$tmp/hosts/nix-desktop/tailscale.sops.json" \
  "$tmp/hosts/nix-mac/secrets.yaml"

git -C "$tmp" init --quiet
git -C "$tmp" add -A
"$tmp/scripts/check-secret-hygiene"

mkdir "$tmp/fleet"
touch "$tmp/fleet/private.nix"
git -C "$tmp" add fleet/private.nix
rm "$tmp/fleet/private.nix"
rmdir "$tmp/fleet"

if "$tmp/scripts/check-secret-hygiene" >/dev/null 2>&1; then
  printf '%s\n' "hygiene check accepted an index-only private path" >&2
  exit 1
fi

printf '%s\n' "secret hygiene tests passed"
