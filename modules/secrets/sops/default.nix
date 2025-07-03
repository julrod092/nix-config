{ config, pkgs, hostname, userConfig,... }:
let
  basePath = if pkgs.stdenv.isDarwin 
             then "/Users/${userConfig.name}" 
             else "/home/${userConfig.name}";
  nixSopsConfig = if pkgs.stdenv.isDarwin
                  then "nixosModules"
                  else "darwinModules";
in 
{
  imports = [
    inputs.nix-sops.${nixSopsConfig}.sops
  ];

  sops = {
    defaultSopsFile = "${basePath}/.nix-config/${hostname}/secrets/secrets.yaml"; # Path to this machine's secrets
    gnupg.home = "${basePath}/${userConfig.name}/.gnupg";
  };
}