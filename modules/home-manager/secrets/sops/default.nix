{
  config,
  pkgs,
  hostname,
  userConfig,
  lib,
  ...
}: let
  secretsPath =
    if pkgs.stdenv.isDarwin
    then "${config.users.users.${userConfig.name}.home}/.config/sops/secrets"
    else "/run/user/1000/secrets";

  macos = {};

  desktop = {
    secrets = {};
    templates = {};
  };
in {
  sops = {
    defaultSymlinkPath = secretsPath;
    defaultSopsFile = ./../../../home/${userConfig.name}/${hostname}/secrets/secrets.yaml;
    gnupg.home = "${config.users.users.${userConfig.name}.home}/.gnupg";

    secrets =
      lib.optionalAttrs pkgs.stdenv.isDarwin macos.secrets
      // (lib.optionalAttrs (hostname == "nix-desktop") desktop.secrets);

    templates =
      lib.optionalAttrs pkgs.stdenv.isDarwin macos.templates
      // (lib.optionalAttrs (hostname == "nix-desktop") desktop.templates);
  };
}
