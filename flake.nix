{
  description = "NixOS and nix-darwin workstation configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arctis-sound-manager = {
      url = "github:loteran/Arctis-Sound-Manager?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:nix-community/nixvim/nixos-26.05";

    agent-shell = {
      url = "github:kdoomsday/agent-shell/20faf1cd827bd48375bd7d6f6001257937d6e026";
      flake = false;
    };
  };

  outputs = {
    self,
    catppuccin,
    darwin,
    home-manager,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    nixpkgsConfig.allowUnfree = true;
    nixCacheSettings.nix.settings = {
      substituters = ["https://nix-community.cachix.org"];
      trusted-substituters = ["https://nix-community.cachix.org"];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    users = let
      julrod = {
        avatar = ./files/avatar;
        wallpaper = ./files/wallpaper.jpg;
        email = "jrodriguezrpo@pm.me";
        fullName = "Julian Rodriguez";
        gitKey = "BB07BC58D5058FD9";
        name = "julrod";
      };
    in {
      inherit julrod;
      julian = {
        inherit (julrod) avatar fullName;
        email = "jandresrodriguez@nclcorp.com";
        gitKey = "";
        name = "julian";
      };
    };
    sharedOverlays = [
      inputs.niri.overlays.niri
      outputs.overlays.unstable-packages
      outputs.overlays.expected-package-revision
    ];
    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config = nixpkgsConfig;
        overlays = sharedOverlays;
      };
    mkSpecialArgs = hostname: username: {
      inherit inputs outputs hostname;
      userConfig = users.${username};
      nixosModules = "${self}/modules/nixos";
      darwinModules = "${self}/modules/darwin";
      nhModules = "${self}/modules/home-manager";
      agentShellSource = inputs.agent-shell;
    };
    sharedHomeModules = [
      catppuccin.homeModules.catppuccin
      inputs.sops-nix.homeManagerModules.sops
    ];
    integratedHomeModule = hostname: username: {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-backup";
        extraSpecialArgs = mkSpecialArgs hostname username;
        sharedModules = sharedHomeModules;
        users.${username} = import ./home/${username}/${hostname};
      };
    };
    mkNixosConfiguration = hostname: username:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = mkSpecialArgs hostname username;
        modules = [
          {
            nixpkgs = {
              config = nixpkgsConfig;
              overlays = sharedOverlays;
            };
          }
          nixCacheSettings
          inputs.sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          (integratedHomeModule hostname username)
          ./hosts/${hostname}
        ];
      };
    mkDarwinConfiguration = hostname: username:
      darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = mkSpecialArgs hostname username;
        modules = [
          {
            nixpkgs = {
              config = nixpkgsConfig;
              overlays = sharedOverlays;
            };
          }
          nixCacheSettings
          home-manager.darwinModules.home-manager
          (integratedHomeModule hostname username)
          ./hosts/${hostname}
        ];
      };
    mkHomeConfiguration = system: hostname: username:
      home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;
        extraSpecialArgs =
          mkSpecialArgs hostname username
          // {osConfig = null;};
        modules = sharedHomeModules ++ [./home/${username}/${hostname}];
      };
    supportedSystems = ["x86_64-linux" "aarch64-darwin"];
  in {
    nixosConfigurations.nix-desktop = mkNixosConfiguration "nix-desktop" "julrod";
    darwinConfigurations.nix-mac = mkDarwinConfiguration "nix-mac" "julian";
    homeConfigurations = {
      "julrod@nix-desktop" = mkHomeConfiguration "x86_64-linux" "nix-desktop" "julrod";
      "julian@nix-mac" = mkHomeConfiguration "aarch64-darwin" "nix-mac" "julian";
    };

    overlays = import ./overlays {inherit inputs;};
    formatter = nixpkgs.lib.genAttrs supportedSystems (system: (mkPkgs system).alejandra);
    checks = {
      x86_64-linux = {
        nix-desktop = self.nixosConfigurations.nix-desktop.config.system.build.toplevel;
        home-julrod = self.homeConfigurations."julrod@nix-desktop".activationPackage;
      };
      aarch64-darwin = {
        nix-mac = self.darwinConfigurations.nix-mac.system;
        home-julian = self.homeConfigurations."julian@nix-mac".activationPackage;
      };
    };
    apps = nixpkgs.lib.genAttrs supportedSystems (system: {
      gitleaks = {
        type = "app";
        program = "${(mkPkgs system).gitleaks}/bin/gitleaks";
        meta.description = "Scan workstation configuration for plaintext secrets";
      };
    });
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
      ci = pkgs.mkShell {
        packages = [pkgs.alejandra pkgs.gitleaks pkgs.jq pkgs.shellcheck];
      };
    });
  };
}
