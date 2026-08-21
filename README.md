# NixOS and nix-darwin Configurations for My Machines

> **Note:** This repository is based on
> [AlexNabokikh's nix-config](https://github.com/AlexNabokikh/nix-config).

## Structure

- `flake.nix`: Inputs and outputs for NixOS, nix-darwin, and Home Manager
- `fleet/`: Shared host inventory, constructors, and Colmena key declarations
- `hosts/`: NixOS and nix-darwin configurations for each machine
- `home/`: Home Manager configurations for each machine
- `files/`: Configuration files and scripts used by applications and services
- `modules/`: Reusable platform-specific modules
  - `nixos/`: NixOS-specific modules
  - `darwin/`: macOS-specific modules
  - `home-manager/`: User-space configuration modules
- `flake.lock`: Lock file ensuring reproducible builds by pinning input versions
- `overlays/`: Custom Nix overlays for package modifications or additions

### Key Inputs

- **nixpkgs**: Points to the `nixos-26.05` channel, providing stable NixOS packages
- **nixpkgs-unstable**: Provides selected newer packages through an overlay
- **home-manager**: Manages user configuration using `nixpkgs` release 26.05
- **hardware**: Optimizes settings for different hardware configurations
- **catppuccin**: Provides global Catppuccin theme integration
- **darwin**: Enables nix-darwin for macOS system configuration
- **colmena**: Applies `nix-desktop` locally and deploys `prime-mini` remotely
- **nixos-apple-silicon**: Supplies the pinned Asahi kernel and boot support
  for `prime-mini`

## Activation

Home Manager is integrated into each system generation.

```bash
# Evaluate all hosts without building them.
nix flake check --no-build --all-systems

# Apply the local NixOS workstation.
make colmena-local

# Build in the server's ARM Nix store, then test or persist the activation.
make colmena-prime-build
make colmena-prime-test
make colmena-prime-switch

# Run manually on nix-mac. No remote Darwin activation is configured.
sudo darwin-rebuild switch --flake .#nix-mac
```
