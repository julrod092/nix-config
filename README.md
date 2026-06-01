# NixOS and nix-darwin Configurations for My Machines

---
**Note:** This Repository is based on [AlexNabokikh - nix-config](https://github.com/AlexNabokikh/nix-config). Go there first and take a look as it is the based structure of this 
---

## Structure

- `flake.nix`: The flake itself, defining inputs and outputs for NixOS, nix-darwin, and Home Manager configurations.
- `hosts/`: NixOS and nix-darwin configurations for each machine
- `home/`: Home Manager configurations for each machine
- `files/`: Miscellaneous configuration files and scripts used across various applications and services
- `modules/`: Reusable platform-specific modules
  - `nixos/`: NixOS-specific modules
  - `darwin/`: macOS-specific modules
  - `home-manager/`: User-space configuration modules
- `flake.lock`: Lock file ensuring reproducible builds by pinning input versions
- `overlays/`: Custom Nix overlays for package modifications or additions

### Key Inputs

- **nixpkgs**: Points to the `nixos-26.05` channel, providing stable NixOS packages
- **nixpkgs-stable**: Points to the `nixos-unstable` channel for access to the latest packages
- **home-manager**: Manages user-specific configurations, following the `nixpkgs` input (release-26.05)
- **hardware**: Optimizes settings for different hardware configurations
- **catppuccin**: Provides global Catppuccin theme integration
- **darwin**: Enables nix-darwin for macOS system configuration