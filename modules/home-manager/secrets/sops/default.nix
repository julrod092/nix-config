{ config, pkgs, hostname, userConfig, ... }:
{
  sops = {
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSopsFile = ./../../../../home/${userConfig.name}/${hostname}/secrets/secrets.yaml;
    gnupg.home = "/home/${userConfig.name}/.gnupg";

    secrets = {
      "synergy_key" = {
        path = "~/.synergy/SSL/Synergy.pem";
        owner = userConfig.name;
        group = userConfig.name;
        mode = "0644";
      };
    };
  };
}