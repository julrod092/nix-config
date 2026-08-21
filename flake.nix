{
  description = "Nix configuratios for all work and personal machines";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon/release-2026-07-30";
    };

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

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
    };

    agent-shell = {
      url = "github:kdoomsday/agent-shell/20faf1cd827bd48375bd7d6f6001257937d6e026";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
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
        ];
        trusted-substituters = [
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    fleet = import ./fleet/constructors.nix {
      inherit self inputs outputs nixpkgsConfig nixCacheSettings;
    };
    inherit (fleet) mkPkgs;
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  in {
    inherit (fleet) nixosConfigurations darwinConfigurations homeConfigurations colmena;

    colmenaHive = inputs.colmena.lib.makeHive self.outputs.colmena;

    overlays = import ./overlays {inherit inputs;};

    formatter = nixpkgs.lib.genAttrs supportedSystems (system: (mkPkgs system).alejandra);

    checks = {
      x86_64-linux.nix-desktop = fleet.nixosConfigurations.nix-desktop.config.system.build.toplevel;
      aarch64-linux.prime-mini = fleet.nixosConfigurations.prime-mini.config.system.build.toplevel;
      aarch64-darwin.nix-mac = fleet.darwinConfigurations.nix-mac.system;
      aarch64-darwin.home-julian = fleet.homeConfigurations."julian@nix-mac".activationPackage;
    };

    apps.x86_64-linux.colmena = {
      type = "app";
      program = "${inputs.colmena.packages.x86_64-linux.colmena}/bin/colmena";
      meta.description = "Deploy the NixOS fleet with Colmena";
    };

    devShells = nixpkgs.lib.genAttrs supportedSystems (system: let
      pkgs = mkPkgs system;
      nixLanguage = import ./modules/home-manager/programming/languages/nix.nix;
      scalaLanguage = import ./modules/home-manager/programming/languages/scala.nix;
      rustLanguage = import ./modules/home-manager/programming/languages/rust.nix;
      goLanguage = import ./modules/home-manager/programming/languages/go.nix;
    in {
      nix = nixLanguage.devShell pkgs;
      scala = scalaLanguage.devShell pkgs;
      rust = rustLanguage.devShell pkgs;
      go = goLanguage.devShell pkgs;
    });
  };
}
