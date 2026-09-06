{
  config,
  pkgs,
  lib,
  ...
}: let
  secretsPath = "${config.home.homeDirectory}/.config/sops/secrets";
in {
  sops = {
    defaultSymlinkPath = secretsPath;
    gnupg.home = "${config.home.homeDirectory}/.gnupg";
  };

  systemd.user.services.sops-nix = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit.After = [
      "graphical-session-pre.target"
      "gpg-agent.socket"
    ];
    Install.WantedBy = lib.mkForce ["graphical-session.target"];
  };
}
