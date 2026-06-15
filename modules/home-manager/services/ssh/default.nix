{
  lib,
  pkgs,
  ...
}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
      "work" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/ncl-ssh";
      };
    };
  };
}
