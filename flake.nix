{
  description = "NixOS and nix-darwin configs for my machines";
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS profiles to optimize settings for different hardware
    hardware.url = "github:nixos/nixos-hardware";

    # Global catppuccin theme
    catppuccin.url = "github:catppuccin/nix";

    # NixOS Spicetify
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Darwin (for MacOS machines)
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Homebrew
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # Neovim flake
    neovim-flake = {
      url = "github:gvolpe/neovim-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.flake-schemas.follows = "flake-schemas";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # Temporal Zen browser flake
    zen-browser.url = "github:MarceColl/zen-browser-flake";
  };

  outputs = {
    self,
    catppuccin,
    darwin,
    home-manager,
    nixpkgs,
    nix-homebrew,
    homebrew-bundle,
    homebrew-core,
    homebrew-cask,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # Define user configurations
    users = {
      julrod = {
        avatar = ./files/avatar/face;
        email = "jrodriguezrpo@proton.me";
        fullName = "Julian Rodriguez";
        # gitKey = "C5810093";
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
        modules = [./hosts/${hostname}];
      };

    # Function for nix-darwin system configuration
    mkDarwinConfiguration = hostname: username:
      darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs outputs hostname;
          userConfig = users.${username};
        };
        modules = [
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "${username}";
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };
              mutableTaps = false;
              autoMigrate = true;
            };
          }
          ./hosts/${hostname}
        ];
      };

    # Function for Home Manager configuration
    mkHomeConfiguration = system: username: hostname:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {inherit system;};
        extraSpecialArgs = {
          inherit inputs outputs system;
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
    };

    darwinConfigurations = {
      "julrod-mac" = mkDarwinConfiguration "julrod-mac" "julrod";
    };

    homeConfigurations = {
      "julrod@julrod-mac" = mkHomeConfiguration "aarch64-darwin" "julrod" "julrod-mac";
      "julrod@nix-desktop" = mkHomeConfiguration "x86_64-linux" "julrod" "nix-desktop";
    };

    overlays = import ./overlays {inherit inputs;};
  };
}
