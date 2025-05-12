{ lib, pkgs, ... }: {
  # Manage kanshi services via Home-manager
  programs.ssh = {
    enable = true;
    matchBlocks = lib.mkIf (pkgs.stdenv.isDarwin) {
      "jandresrodriguez-ncl.github.com" = {
        hostname = "github.com";
        user = "jandresrodriguez-ncl";
      };
      "julrod092.github.com" = {
        hostname = "github.com";
        user = "julrod092";
      };
      work = lib.hm.dag.entryBefore ["jandresrodriguez-ncl.github.com"] {
        hostname = "github.com";
        identityFile = "~/.ssh/ncl-ssh";
      };
      personal = lib.hm.dag.entryBefore ["julrod092.github.com"] {
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
