{
  description = "Nix configuratios for all work and personal machines";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    lan-mouse.url = "github:feschber/lan-mouse";
    hardware.url = "github:nixos/nixos-hardware";
    nixvim.url = "github:nix-community/nixvim/nixos-26.05";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Darwin (for MacOS machines)
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop enviroment
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix addons
    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix stacks
    nix-podman-stacks = {
      url = "github:julrod092/nix-podman-stacks/release/personal";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets managements
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arctis-sound-manager = {
      url = "github:loteran/Arctis-Sound-Manager?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs"; 
    };

    # Experiments
    herdr = {
      url = "github:ogulcancelik/herdr";
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

    nixCacheSettings = {
      nix.settings = {
        substituters = [
          "https://nix-community.cachix.org"
          "https://lan-mouse.cachix.org/"
        ];
        trusted-substituters = [
          "https://nix-community.cachix.org"
          "https://lan-mouse.cachix.org/"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "lan-mouse.cachix.org-1:KlE2AEZUgkzNKM7BIzMQo8w9yJYqUpor1CAUNRY6OyM="
        ];
      };
    };

    # Define user configurations
    users = {
      "julian" = {
        inherit
          (users.julrod)
          avatar
          fullName
          ;
        email = "jandresrodriguez@nclcorp.com";
        gitKey = "86D656A8DE022933";
        name = "julian";
      };
      julrod = {
        avatar = ./files/avatar;
        wallpaper = ./files/wallpaper.jpg;
        email = "jrodriguezrpo@pm.me";
        fullName = "Julian Rodriguez";
        gitKey = "BB07BC58D5058FD9";
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
          nixCacheSettings
          inputs.sops-nix.nixosModules.sops
          inputs.arctis-sound-manager.nixosModules.default
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
          nixCacheSettings
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
          inputs.lan-mouse.homeManagerModules.default
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
