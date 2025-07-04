{ config, pkgs, hostname, userConfig, lib, ... }:
let
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
  sharedSecrets = {};
in
{
  sops = {
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSopsFile = ./../../../../home/${userConfig.name}/${hostname}/secrets/secrets.yaml;
    gnupg.home = "/home/${userConfig.name}/.gnupg";

    secrets = sharedSecrets 
      // (lib.optionalAttrs pkgs.stdenv.isDarwin darwinSecrets)
      // (lib.optionalAttrs (!pkgs.stdenv.isDarwin) linuxSecrets);
  };
}