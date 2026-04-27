{...}: {
  config.dendritic.nixosModules.nh = {identity, pkgs, ...}: let
    homePath =
      if pkgs.stdenv.isDarwin
      then "/Users/${identity.user.name}"
      else "/home/${identity.user.name}";
  in {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "${homePath}/.nix-config";
    };
  };
}
