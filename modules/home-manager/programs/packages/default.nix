{ pkgs, lib,  ...}:
let
  jdk = pkgs.zulu21;
in
{
  home.packages = with pkgs;
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
      jdk
      (sbt.override { jre = jdk; })
      maven
      devenv
      scala-cli
      openssl
      unstable.jetbrains.idea-community
      sops
      age
      vscode
      fzf
      synergy-wayland
      
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
    ];
}
