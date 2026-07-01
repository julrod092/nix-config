{
  pkgs,
  config,
  lib,
  hostname,
  userConfig,
  ...
}: let
  flake = "${config.home.homeDirectory}/.nix-config";
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  programs.nh = {
    enable = true;
    flake = flake;
    homeFlake = "${flake}#${userConfig.name}@${hostname}";
    osFlake = lib.mkIf (!isDarwin) "${flake}#${hostname}";
    darwinFlake = lib.mkIf isDarwin "${flake}#${hostname}";

    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
  };
}
