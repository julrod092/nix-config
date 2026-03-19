{
  pkgs,
  lib,
  ...
}: let
  mainJdk = pkgs.zulu21;
in {
  home = {
    file = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
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
        unstable.colima
        docker
        unstable.hidden-bar
        docker-compose
        raycast
        (expected-rev "8374ab2113c7522766acf5ab1af9d8c6824c06d4" "${pkgs.stdenv.hostPlatform.system}").haproxy
        (expected-rev "5d5288fa1b2665243a1fd5dd99703077d25d4218" "${pkgs.stdenv.hostPlatform.system}").nodejs_24
        charles4
        unstable.synergy
        slack
        appcleaner
        unstable.zoom-us
        unstable.claude-code
        unstable.google-chrome
      ]
      ++ lib.lists.optionals (!stdenv.isDarwin) [
        pavucontrol
        pulseaudio
        tesseract
        unzip
        baobab
        # stremio
        codecrafters-cli
        code-cursor
        unstable.discord
        obsidian
        libheif
        unstable.deskflow
        unstable.prismlauncher
        unstable.deluge
      ];
  };
}
