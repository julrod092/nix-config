{ pkgs, lib,  ...}:
let
  node = pkgs.stable.nodejs_24;
  jdk = if (pkgs.stdenv.isDarwin)
    then pkgs.stable.zulu11
    else pkgs.stable.zulu21;

in
{
  home.packages = with pkgs;
    [
      dig
      du-dust
      eza
      fd
      jq
      kubectl
      lazydocker
      nh
      openconnect
      ripgrep
      stable.zed-editor
      jdk
      (sbt.override { jre = jdk; })
      nixd
      stable.maven
      devenv
      scala-cli
      openssl
    ]
    ++ lib.lists.optionals stdenv.isDarwin [
      dockutil
      colima
      docker
      hidden-bar
      docker-compose
      node
      synergy
      vscode
    ]
    ++ lib.lists.optionals (!stdenv.isDarwin) [
      pavucontrol
      pulseaudio
      tesseract
      unzip
      wl-clipboard
      rclone
      lmstudio
      code-cursor
      libei
      libgbm
      stable.jetbrains.idea-ultimate
    ];
}
