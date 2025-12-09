{ lib, pkgs, ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = lib.mkIf (pkgs.stdenv.isDarwin) {
      "work" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/ncl-ssh";
      };
    };
  };
}
