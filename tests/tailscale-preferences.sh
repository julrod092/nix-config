#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
validator="$root/scripts/validate-tailscale-preferences"
fixture="$root/tests/fixtures/tailscale-desktop.json"

if grep --quiet -E 'tailscale (debug prefs|get)' "$root/scripts/apply-tailscale-preferences"; then
  printf '%s\n' "apply helper captures raw Tailscale preferences" >&2
  exit 1
fi

"$validator" desktop "$fixture"

mapfile -t flags < <("$root/scripts/render-tailscale-flags" desired "$fixture")
[[ " ${flags[*]} " == *" --accept-dns=true "* ]]
[[ " ${flags[*]} " == *" --accept-routes=true "* ]]
[[ " ${flags[*]} " == *" --advertise-routes= "* ]]
[[ " ${flags[*]} " == *" --ssh=false "* ]]

invalid=$(mktemp)
trap 'rm -f -- "$invalid"' EXIT
jq '.desired.dangerous = true' "$fixture" >"$invalid"

if "$validator" desktop "$invalid" 2>/dev/null; then
  printf '%s\n' "validator accepted an unknown preference" >&2
  exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf -- "$invalid" "$tmp"' EXIT
export MOCK_LOG="$tmp/commands"

cat >"$tmp/hostname" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' nix-desktop
EOF
cat >"$tmp/sudo" <<'EOF'
#!/usr/bin/env bash
printf 'sudo %s\n' "$*" >>"$MOCK_LOG"
EOF
chmod +x "$tmp/hostname" "$tmp/sudo"

if printf '%s\n' NO | PATH="$tmp:$PATH" \
  "$root/scripts/apply-tailscale-preferences" desired "$fixture" >/dev/null 2>&1; then
  printf '%s\n' "apply helper accepted invalid confirmation" >&2
  exit 1
fi
if [[ -s "$MOCK_LOG" ]]; then
  printf '%s\n' "cancelled apply invoked a privileged command" >&2
  exit 1
fi

printf '%s\n' APPLY | PATH="$tmp:$PATH" \
  "$root/scripts/apply-tailscale-preferences" desired "$fixture" >/dev/null
grep -q '^sudo tailscale set .*--ssh=false' "$MOCK_LOG"
