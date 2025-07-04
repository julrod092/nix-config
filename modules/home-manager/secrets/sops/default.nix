{ config, pkgs, hostname, userConfig, lib, ... }:
let
  darwinSecrets = {
    "npm_github_token" = {};
  };

  linuxSecrets = {
    "synergy_key" = lib.mkIf (!pkgs.stdenv.isDarwin) {
      path = "/home/${userConfig.name}/.synergy/SSL/Synergy.pem";
      mode = "0644";
    };
  };
in
{
  sops = {
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSopsFile = ./../../../../home/${userConfig.name}/${hostname}/secrets/secrets.yaml;
    gnupg.home = "/home/${userConfig.name}/.gnupg";
    
    secrets = (if (pkgs.stdenv.isDarwin) then darwinSecrets else linuxSecrets); # ++ shared-secrets
  };
}