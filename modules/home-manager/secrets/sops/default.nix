{ config, pkgs, hostname, userConfig,... }:
let
  basePath = if pkgs.stdenv.isDarwin 
             then "/Users/${userConfig.name}" 
             else "/home/${userConfig.name}";
in 
{
  sops = {
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
    defaultSopsFile = "${basePath}/.nix-config/home/${userConfig.name}/${hostname}/secrets/secrets.yaml";
    gnupg.home = "${basePath}/${userConfig.name}/.gnupg";

    secrets.test = {};
  };
}