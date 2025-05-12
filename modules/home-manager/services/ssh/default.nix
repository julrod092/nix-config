{ lib, pkgs, ... }: {
  # Manage kanshi services via Home-manager
  programs.ssh = {
    enable = true;
    matchBlocks = lib.mkIf (!pkgs.stdenv.isDarwin) {
      "ncl" = {
        hostname = "github.com";
        user = "jandresrodriguez-ncl";
      };
      "personal" = {
        hostname = "github.com";
        user = "julrod092";
      };
      work = lib.hm.dag.entryBefore ["ncl"] {
        hostname = "github.com";
        identityFile = "~/.ssh/ncl-ssh";
      };
      xebia = lib.hm.dag.entryBefore ["personal"] {
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
