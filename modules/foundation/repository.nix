{lib, ...}: let
  inherit (lib) mkOption types;
  sharedUser = {
    avatar = ../../files/avatar;
    wallpaper = ../../files/wallpaper.jpg;
    email = "jrodriguezrpo@pm.me";
    fullName = "Julian Rodriguez";
    gitKey = "CC597166";
  };
  userType = types.submodule {
    options = {
      name = mkOption { type = types.str; };
      avatar = mkOption { type = types.path; };
      wallpaper = mkOption { type = types.path; };
      email = mkOption { type = types.str; };
      fullName = mkOption { type = types.str; };
      gitKey = mkOption { type = types.str; };
    };
  };
  configurationType = extraOptions:
    types.submodule ({...}: {
      options =
        {
          system = mkOption { type = types.str; };
          user = mkOption { type = types.str; };
          modules = mkOption {
            type = types.listOf types.deferredModule;
            default = [];
          };
        }
        // extraOptions;
    });
in {
  options.dendritic = {
    users = mkOption {
      type = types.attrsOf userType;
      default = {};
    };

    nixpkgsConfig = mkOption {
      type = types.attrsOf types.anything;
      default = {};
    };

    overlays = mkOption {
      type = types.attrsOf types.raw;
      default = {};
    };

    nixosModules = mkOption {
      type = types.attrsOf types.deferredModule;
      default = {};
    };

    homeModules = mkOption {
      type = types.attrsOf types.deferredModule;
      default = {};
    };

    darwinModules = mkOption {
      type = types.attrsOf types.deferredModule;
      default = {};
    };

    nixosConfigurations = mkOption {
      type = types.attrsOf (configurationType {});
      default = {};
    };

    homeConfigurations = mkOption {
      type = types.attrsOf (configurationType {
        host = mkOption { type = types.str; };
      });
      default = {};
    };

    darwinConfigurations = mkOption {
      type = types.attrsOf (configurationType {});
      default = {};
    };
  };

  config.dendritic = {
    nixpkgsConfig = {
      allowUnfree = true;
    };

    users = {
      julrod = sharedUser // { name = "julrod"; };
      julian = sharedUser // { name = "julian"; };
      "julian.rodriguez" = sharedUser // { name = "julian.rodriguez"; };
    };
  };
}
