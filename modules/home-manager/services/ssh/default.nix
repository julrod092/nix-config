{ lib, pkgs, ... }: {
  # Manage kanshi services via Home-manager
  programs.ssh = {
    enable = true;
    matchBlocks = lib.mkIf (pkgs.stdenv.isDarwin) {
      "work" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/ncl-ssh";
      };
    };
  };
}
