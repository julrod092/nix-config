# Repository Boundary

The public repository is a standalone workstation flake. It directly owns:

- NixOS configuration for `nix-desktop`;
- nix-darwin configuration for `nix-mac`;
- integrated Home Manager for both systems;
- standalone Home Manager recovery outputs;
- workstation identities, hardware metadata, avatar, and wallpaper;
- encrypted host-local SOPS payloads.

It does not export fleet constructors and contains no prime, homelab, Colmena,
or global fleet topology configuration. Workstation-local network dependencies
remain part of the desktop host configuration. Encrypted files are committed,
but CI only checks their approved paths and never decrypts their contents.

Mutable Tailscale preferences are intentionally outside Nix evaluation. The
apply helper validates the desired and rollback sets from the encrypted payload,
displays field names only, and requires explicit operator confirmation before
invoking `tailscale set`.
