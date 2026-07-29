Formatting stdin.
Use --help to see all command line options.
use --quiet to suppress this and other messages.
{
  pkgs,
  lib,
  inputs,
  ...
}: let
  mainJdk = pkgs.zulu21;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  home = {
    file = lib.mkIf isDarwin {
      "jdks/zulu8".source = pkgs.zulu8;
      "jdks/zulu11".source = pkgs.zulu11;
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
        unstable.jetbrains.rust-rover
        sops
        vscode
        fzf
        inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default

        # Nix servers
        nixd
        nil

        # Security
        sops
        age
        smithy-cli
      ]
      ++ lib.lists.optionals isDarwin [
        dockutil
        colima
        docker
        unstable.hidden-bar
        docker-compose
        unstable.raycast
        (expected-rev "8374ab2113c7522766acf5ab1af9d8c6824c06d4" "${pkgs.stdenv.hostPlatform.system}").haproxy
        (expected-rev "5d5288fa1b2665243a1fd5dd99703077d25d4218" "${pkgs.stdenv.hostPlatform.system}").nodejs_24
        charles4
        synergy
        slack
        appcleaner
        unstable.zoom-us
        unstable.google-chrome
        unstable.awscli2
        unstable.go
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
        unstable.prismlauncher
        unstable.deluge
        unstable.xclip
        python314
      ];
  };
}

Congratulations! Your code complies with the Alejandra style.

👏 Special thanks to https://mercury.com for being a sponsor of Alejandra!
