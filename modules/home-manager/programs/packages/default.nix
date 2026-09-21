{
  pkgs,
  lib,
  inputs,
  ...
}: let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  home = {
    packages = with pkgs;
      [
        dig
        dust
        eza
        fd
        jq
        kubectl
        lazydocker
        nh
        ripgrep
        openssl
        sops
        inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default

        # Security
        age
      ]
      ++ lib.lists.optionals isDarwin [
        dockutil
        unstable.hidden-bar
        unstable.raycast
        synergy
        slack
        appcleaner
        unstable.zoom-us
        unstable.google-chrome
      ]
      ++ lib.lists.optionals (!isDarwin) [
        pavucontrol
        pulseaudio
        tesseract
        unzip
        baobab
        codecrafters-cli
        unstable.discord
        obsidian
        libheif
        unstable.deskflow
        unstable.deluge
        unstable.xclip
        unstable.vlc
      ];
  };
}
