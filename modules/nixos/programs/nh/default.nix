{
  config,
  pkgs,
  userConfig,
  ...
}: let
  osHomePath =
    if (pkgs.stdenv.isDarwin)
    then "/Users/${userConfig.name}"
    else "/home/${userConfig.name}";
in {
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "${osHomePath}/.nix-config";
  };
}
