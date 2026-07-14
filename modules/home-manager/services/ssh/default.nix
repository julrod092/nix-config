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
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        addKeysToAgent = "yes";
      };
    };
  };
}
