{ config, pkgs, hostname, userConfig, lib, ... }:
let
  homeDirectory = if pkgs.stdenv.isDarwin
    then "/Users/${userConfig.name}"
    else "/home/${userConfig.name}";

  secretsPath = if pkgs.stdenv.isDarwin
    then "${homeDirectory}/.config/sops/secrets"
    else "/run/user/1000/secrets";

  macos = {
    secrets = {
      "npm_github_token" = {};
      "github_repo_token_access" = {};
    };
    templates = {};
  };

  desktop = {
    secrets = {
      "synergy_key" = {
        path = "/home/${userConfig.name}/.synergy/SSL/Synergy.pem";
        mode = "0600";
      };
    };
    templates = {};
  };

  laptop = {
    secrets = {};
    templates = {};
  };

  # Shared secrets for all platforms
  sharedSecrets = {
    secrets = {};
    templates = {};
  };
in
{
  sops = {
    defaultSymlinkPath = secretsPath;
    defaultSopsFile = ./../../../home/${userConfig.name}/${hostname}/secrets/secrets.yaml;
    gnupg.home = "${homeDirectory}/.gnupg";

    secrets = sharedSecrets.secrets 
      // (lib.optionalAttrs pkgs.stdenv.isDarwin macos.secrets)
      // (lib.optionalAttrs (hostname == "nix-desktop") desktop.secrets)
      // (lib.optionalAttrs (hostname == "nix-laptop") laptop.secrets);

      templates = sharedSecrets.templates 
      // (lib.optionalAttrs pkgs.stdenv.isDarwin macos.templates)
      // (lib.optionalAttrs (hostname == "nix-desktop") desktop.templates)
      // (lib.optionalAttrs (hostname == "nix-laptop") laptop.templates);
  };
}