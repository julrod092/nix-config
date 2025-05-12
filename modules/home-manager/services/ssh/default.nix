{ lib, pkgs, ... }: {
  # Manage kanshi services via Home-manager
  programs.ssh = {
    enable = true;
    matchBlocks = lib.mkIf (!pkgs.stdenv.isDarwin) {
      "jandresrodriguez-ncl.github.com" = {
        hostname = "github.com";
        user = "jandresrodriguez-ncl";
      };
      work = lib.hm.dag.entryBefore ["jandresrodriguez-ncl.github.com"] {
        hostname = "github.com";
        identityFile = "~/.ssh/ncl-ssh";
      };
    };
  };
}
