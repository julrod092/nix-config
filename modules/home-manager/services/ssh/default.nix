{
  lib,
  pkgs,
  ...
}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
      "work" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/ncl-ssh";
      };
    };
  };
}
