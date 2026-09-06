# Workstation Nix Configuration

This public flake owns the complete `nix-desktop` and `nix-mac`
configurations. It exports integrated NixOS/nix-darwin systems plus standalone
Home Manager recovery outputs.

Encrypted workstation payloads remain host-local:

- `hosts/nix-desktop/secrets.yaml`
- `hosts/nix-desktop/tailscale.sops.json`
- `hosts/nix-mac/secrets.yaml`

Tailscale enrollment stays declarative. Sops-nix decrypts the mutable desktop
preferences into the Home Manager secret directory, but applying either the
desired or rollback set remains an explicit operator action:

```bash
./scripts/apply-tailscale-preferences desired "$HOME/.config/sops/secrets/tailscale-preferences"
./scripts/apply-tailscale-preferences rollback "$HOME/.config/sops/secrets/tailscale-preferences"
```

The Mac has no Tailscale configuration. Prime and homelab configuration live
in the separate private fleet repository.

## Checks

```bash
make format-check
make lint
make test
make secret-check
make flake-check
make build-linux
```

Linux checks build and evaluate on `nix-desktop`. Darwin and standalone Mac
outputs evaluate on Linux; a native Mac build remains an operator-run gate.
