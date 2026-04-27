# Dendritic Migration Rules

## Core Rules

1. `flake.nix` is the only entry point for the repository outputs.
2. Every Nix file under `dendritic/` is a top-level module of one shared `lib.evalModules` evaluation.
3. File paths under `dendritic/` name features or concerns, not configuration classes.
4. Each top-level module should implement one feature across every lower-level configuration it applies to.
5. Lower-level NixOS, Home Manager, and nix-darwin modules must be stored as top-level configuration values.
6. Lower-level modules should use `deferredModule`-style composition semantics so they can participate in multiple outputs.
7. Automatic recursive importing is required for `dendritic/` so feature files can be moved freely without editing a central import list.

## Repository Conventions

1. Shared repository data lives in `config.dendritic`.
2. Feature modules contribute to one or more of these namespaces:
   `dendritic.users`
   `dendritic.overlays`
   `dendritic.nixosModules`
   `dendritic.homeModules`
   `dendritic.darwinModules`
   `dendritic.nixosConfigurations`
   `dendritic.homeConfigurations`
   `dendritic.darwinConfigurations`
3. Host modules compose features; they do not own large blocks of implementation details.
4. Shared values should come from `config.dendritic`, not by threading broad `specialArgs` sets through lower-level evaluations.
5. The only lower-level metadata passed into system or home evaluations is the selected identity for the host/profile.
6. Feature modules should prefer minimal composition and small, explicit imports.

## Design Patterns

1. Cross-cutting concerns should live in one place even when they affect multiple classes.
2. Home Manager and NixOS halves of the same feature belong together when that improves cohesion.
3. File path meaning must stay independent from the final output it participates in.
4. Modules should stay easy to rename, move, or split without changing the architecture.
5. The pattern is feature-oriented, not host-oriented and not target-class-oriented.

## Anti-Patterns

1. Do not organize the active configuration tree by `nixos/`, `home-manager/`, and `darwin/` first.
2. Do not rely on `specialArgs` or `extraSpecialArgs` as the main sharing mechanism between lower-level modules.
3. Do not make file type ambiguous; a Nix file in `dendritic/` must always be a top-level module.
4. Do not encode semantics in the directory layout of lower-level configuration classes.

## Migration Constraints

1. Preserve these outputs:
   `nixosConfigurations.nix-desktop`
   `darwinConfigurations.nix-mac`
   `homeConfigurations."julrod@nix-desktop"`
   `homeConfigurations."julian@nix-mac"`
2. Preserve user identity data currently defined in the flake.
3. Preserve current host state versions unless explicitly changed.
4. Preserve the current package overlay behavior for `unstable` and `expected-rev`.
5. Legacy files may remain temporarily during migration, but active composition must come from `dendritic/`.
