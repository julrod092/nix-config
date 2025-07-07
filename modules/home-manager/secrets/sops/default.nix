{ config, pkgs, hostname, userConfig, lib, ... }:
let
  homeDirectory = if pkgs.stdenv.isDarwin
    then "/Users/${userConfig.name}"
    else "/home/${userConfig.name}";

  secretsPath = if pkgs.stdenv.isDarwin 
    then "${homeDirectory}/.config/sops/secrets"
    else "/run/user/1000/secrets";

  darwinSecrets = {
    "npm_github_token" = {};
  };

  linuxSecrets = {
    "synergy_key" = {
      path = "/home/${userConfig.name}/.synergy/SSL/Synergy.pem";
      mode = "0600";
    };
  };

  # Shared secrets for all platforms
  sharedSecrets = {
    "hello" = {
      sopsFile = ./../shared/secrets.yaml;
    };
  };
in
{
  sops = {
    defaultSymlinkPath = secretsPath;
    defaultSopsFile = ./../../../../home/${userConfig.name}/${hostname}/secrets/secrets.yaml;
    gnupg.home = "${homeDirectory}/.gnupg";

    secrets = sharedSecrets 
      // (lib.optionalAttrs pkgs.stdenv.isDarwin darwinSecrets)
      // (lib.optionalAttrs (!pkgs.stdenv.isDarwin) linuxSecrets);
  };
}