{
  description = "Nix configurations for work and personal machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";

    catppuccin = {
      url = "github:catppuccin/nix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixflix = {
      url = "github:kiriwalawren/nixflix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    darwin,
    home-manager,
    nixpkgs,
    self,
    ...
  }: let
    lib = nixpkgs.lib;

    collectModules = dir:
      let
        entries = builtins.readDir dir;
        names = builtins.sort builtins.lessThan (builtins.attrNames entries);
      in
        lib.flatten (map (
          name:
            let
              path = dir + "/${name}";
              kind = entries.${name};
            in
              if kind == "directory"
              then collectModules path
              else if lib.hasSuffix ".nix" name
              then [path]
              else []
        ) names);

    top = lib.evalModules {
      specialArgs = {inherit inputs self;};
      modules = collectModules ./modules;
    };

    repo = top.config.dendritic;

    mkIdentityArgs = hostName: userName: {
      _module.args.identity = {
        inherit hostName userName;
        user = repo.users.${userName};
      };
    };

    mkNixosConfiguration = hostName: definition:
      lib.nixosSystem {
        system = definition.system;
        modules = [
          (mkIdentityArgs hostName definition.user)
        ] ++ definition.modules;
      };

    mkDarwinConfiguration = hostName: definition:
      darwin.lib.darwinSystem {
        system = definition.system;
        modules = [
          (mkIdentityArgs hostName definition.user)
        ] ++ definition.modules;
      };

    mkHomeConfiguration = _profileName: definition:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = definition.system;
          config = repo.nixpkgsConfig;
        };
        modules = [
          (mkIdentityArgs definition.host definition.user)
        ] ++ definition.modules;
      };
  in {
    nixosConfigurations = lib.mapAttrs mkNixosConfiguration repo.nixosConfigurations;
    darwinConfigurations = lib.mapAttrs mkDarwinConfiguration repo.darwinConfigurations;
    homeConfigurations = lib.mapAttrs mkHomeConfiguration repo.homeConfigurations;
    overlays = repo.overlays;
  };
}
