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

    disko = {
      url = "github:nix-community/disko";
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

    # nix stacks
    nix-podman-stacks = {
      url = "github:Tarow/nix-podman-stacks/v0.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets managements
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    catppuccin,
    darwin,
    home-manager,
    nixpkgs,
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
          (users.julrod users.julian)
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
      julian = {
        avatar = ./files/avatar;
        wallpaper = ./files/wallpaper.jpg;
        email = "jrodriguezrpo@pm.me";
        fullName = "Julian Rodriguez";
        gitKey = "CC597166";
        name = "julian";
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
          inputs.sops-nix.nixosModules.sops
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
          inherit inputs outputs hostname;
          userConfig = users.${username};
          nhModules = "${self}/modules/home-manager";
        };
        modules = [
          ./home/${username}/${hostname}
          catppuccin.homeModules.catppuccin
          nixvim.homeModules.nixvim
          inputs.sops-nix.homeManagerModules.sops
          inputs.nix-podman-stacks.homeModules.nps
        ];
      };
  in {
    nixosConfigurations = {
      "nix-desktop" = mkNixosConfiguration "nix-desktop" "julrod";
    };

    darwinConfigurations = {
      "nix-mac" = mkDarwinConfiguration "nix-mac" "julian";
    };

    homeConfigurations = {
      "julian@nix-mac" = mkHomeConfiguration "aarch64-darwin" "julian" "nix-mac";
      "julrod@nix-desktop" = mkHomeConfiguration "x86_64-linux" "julrod" "nix-desktop";
    };

    overlays = import ./overlays {inherit inputs;};
  };
}
