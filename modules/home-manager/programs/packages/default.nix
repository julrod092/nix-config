{
  pkgs,
  lib,
  ...
}: let
  mainJdk = pkgs.zulu21;
in {
  home = {
    file = {
      "jdks/zulu8".source = pkgs.zulu8;
      "jdks/zulu11".source = pkgs.zulu11;
      "jdks/zulu21".source = mainJdk;
    };
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
        mainJdk
        (sbt.override {jre = mainJdk;})
        maven
        unstable.devenv
        scala-cli
        openssl
        unstable.jetbrains.idea
        sops
        vscode
        fzf

        # Nix servers
        nixd
        nil
      ]
      ++ lib.lists.optionals stdenv.isDarwin [
        dockutil
        colima
        docker
        hidden-bar
        docker-compose
        raycast
        (expected-rev "e518d4ad2bcad74f98fec028cf21ce5b1e5020dd" "${pkgs.stdenv.hostPlatform.system}").nodejs_20
        (expected-rev "8374ab2113c7522766acf5ab1af9d8c6824c06d4" "${pkgs.stdenv.hostPlatform.system}").haproxy
        (expected-rev "a1bab9e494f5f4939442a57a58d0449a109593fe" "${pkgs.stdenv.hostPlatform.system}").charles
        unstable.synergy
        google-chrome
        slack
        appcleaner
        unstable.zoom-us
      ]
      ++ lib.lists.optionals (!stdenv.isDarwin) [
        pavucontrol
        pulseaudio
        tesseract
        unzip
        wl-clipboard
        baobab
        # stremio
        codecrafters-cli
        code-cursor
        unstable.discord
        nautilus
        obsidian
        libheif
        unstable.deskflow
      ];
  };
}
