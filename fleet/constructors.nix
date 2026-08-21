{
  self,
  inputs,
  outputs,
  nixpkgsConfig,
  nixCacheSettings,
}: let
  inherit (inputs.nixpkgs) lib;
  inventory = import ./inventory.nix;
  inherit (inventory) hosts users;
  sharedOverlays = [
    inputs.niri.overlays.niri
    outputs.overlays.unstable-packages
    outputs.overlays.expected-package-revision
  ];

  mkPkgs = system:
    import inputs.nixpkgs {
      inherit system;
      config = nixpkgsConfig;
      overlays = sharedOverlays;
    };

  homePath = hostname: host: ../home + "/${host.homeUser}/${hostname}";

  mkSpecialArgs = hostname: host: {
    inherit inputs outputs hostname;
    userConfig = users.${host.homeUser};
    nixosModules = "${self}/modules/nixos";
    darwinModules = "${self}/modules/darwin";
    nhModules = "${self}/modules/home-manager";
    agentShellSource = inputs.agent-shell;
  };

  sharedHomeModules = [
    inputs.catppuccin.homeModules.catppuccin
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-podman-stacks.homeModules.nps
  ];

  integratedHomeModule = hostname: host: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = mkSpecialArgs hostname host;
      sharedModules = sharedHomeModules;
      users.${host.homeUser} = import (homePath hostname host);
    };
  };

  nixosModulesFor = hostname: host: [
    {
      nixpkgs = {
        config = nixpkgsConfig;
        overlays = sharedOverlays;
      };
    }
    nixCacheSettings
    inputs.home-manager.nixosModules.home-manager
    (integratedHomeModule hostname host)
    (../hosts + "/${hostname}")
  ];

  darwinModulesFor = hostname: host: [
    {
      nixpkgs = {
        config = nixpkgsConfig;
        overlays = sharedOverlays;
      };
    }
    nixCacheSettings
    inputs.home-manager.darwinModules.home-manager
    (integratedHomeModule hostname host)
    (../hosts + "/${hostname}")
  ];

  nixosHosts = lib.filterAttrs (_: host: host.platform == "nixos") hosts;
  darwinHosts = lib.filterAttrs (_: host: host.platform == "darwin") hosts;
  standaloneHomeHosts = lib.filterAttrs (_: host: lib.elem "workstation" host.roles) darwinHosts;
  primeMiniKeys = import ./prime-mini-keys.nix {
    inherit lib self;
    pkgs = mkPkgs "x86_64-linux";
  };

  mkNixosConfiguration = hostname: host:
    inputs.nixpkgs.lib.nixosSystem {
      inherit (host) system;
      specialArgs = mkSpecialArgs hostname host;
      modules = nixosModulesFor hostname host;
    };

  mkDarwinConfiguration = hostname: host:
    inputs.darwin.lib.darwinSystem {
      inherit (host) system;
      specialArgs = mkSpecialArgs hostname host;
      modules = darwinModulesFor hostname host;
    };

  mkHomeConfiguration = hostname: host:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs host.system;
      extraSpecialArgs =
        mkSpecialArgs hostname host
        // {
          osConfig = null;
        };
      modules = sharedHomeModules ++ [(homePath hostname host)];
    };

  colmenaNode = hostname: host: {
    imports = nixosModulesFor hostname host;

    deployment =
      {
        tags = host.tags;
        targetHost = host.deployment.targetHost;
        allowLocalDeployment = host.deployment.backend == "colmena-local";
        targetUser = host.deployment.targetUser or null;
        buildOnTarget = host.deployment.buildOnTarget or false;
        sshOptions = host.deployment.sshOptions or [];
      }
      // lib.optionalAttrs (hostname == "prime-mini") {
        keys = primeMiniKeys;
      };
  };
in {
  inherit inventory mkPkgs;

  nixosConfigurations = lib.mapAttrs mkNixosConfiguration nixosHosts;
  darwinConfigurations = lib.mapAttrs mkDarwinConfiguration darwinHosts;

  homeConfigurations = lib.mapAttrs' (hostname: host:
    lib.nameValuePair "${host.homeUser}@${hostname}" (mkHomeConfiguration hostname host))
  standaloneHomeHosts;

  colmena =
    {
      meta = {
        nixpkgs = mkPkgs "x86_64-linux";
        nodeNixpkgs = lib.mapAttrs (_: host: mkPkgs host.system) nixosHosts;
        nodeSpecialArgs = lib.mapAttrs mkSpecialArgs nixosHosts;
      };
    }
    // lib.mapAttrs colmenaNode nixosHosts;
}
