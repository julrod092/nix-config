{
  description = "Nix configuratios for all work and personal machines";
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Darwin (for MacOS machines)
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS profiles to optimize settings for different hardware
    hardware.url = "github:nixos/nixos-hardware";

    # Global catppuccin theme
    catppuccin = {
      url = "github:catppuccin/nix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Temporal Zen browser flake
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NVIM nix community scratch
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop enviroment
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix addons
    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    catppuccin,
    darwin,
    home-manager,
    nixpkgs,
    sops-nix,
    nixvim,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # Nixpkgs configuration
    nixpkgsConfig = {
      allowUnfree = true;
    };

    # Define user configurations
    users = {
      "julian.rodriguez" = {
        inherit
          (users.julrod)
          avatar
          email
          fullName
          gitKey
          ;
        name = "julian.rodriguez";
      };
      julrod = {
        avatar = ./files/avatar;
        wallpaper = ./files/wallpaper.jpg;
        email = "jrodriguezrpo@pm.me";
        fullName = "Julian Rodriguez";
        gitKey = "CC597166";
        name = "julrod";
      };
    };

    # Function for NixOS system configuration
    mkNixosConfiguration = hostname: username:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs hostname;
          userConfig = users.${username};
          nixosModules = "${self}/modules/nixos";
        };
        modules = [
          {nixpkgs.config = nixpkgsConfig;}
          ./hosts/${hostname}
        ];
      };

    # Function for nix-darwin system configuration
    mkDarwinConfiguration = hostname: username:
      darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs outputs hostname;
          userConfig = users.${username};
          darwinModules = "${self}/modules/darwin";
        };
        modules = [
          {nixpkgs.config = nixpkgsConfig;}
          ./hosts/${hostname}
        ];
      };

    # Function for Home Manager configuration
    mkHomeConfiguration = system: username: hostname:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config = nixpkgsConfig;
        };
        extraSpecialArgs = {
          inherit inputs outputs;
          userConfig = users.${username};
          nhModules = "${self}/modules/home-manager";
        };
        modules = [
          ./home/${username}/${hostname}
          catppuccin.homeModules.catppuccin
        ];
      };
  in {
    nixosConfigurations = {
      "nix-desktop" = mkNixosConfiguration "nix-desktop" "julrod";
      "nix-laptop" = mkNixosConfiguration "nix-laptop" "julrod";
    };

    darwinConfigurations = {
      "julrod-mac" = mkDarwinConfiguration "julrod-mac" "julrod";
    };

    homeConfigurations = {
      "julrod@julrod-mac" = mkHomeConfiguration "aarch64-darwin" "julrod" "julrod-mac";
      "julrod@nix-desktop" = mkHomeConfiguration "x86_64-linux" "julrod" "nix-desktop";
      "julrod@nix-laptop" = mkHomeConfiguration "x86_64-linux" "julrod" "nix-laptop";
    };

    overlays = import ./overlays {inherit inputs;};
  };
}
