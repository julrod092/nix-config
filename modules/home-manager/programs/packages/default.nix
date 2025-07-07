{ pkgs, lib,  ...}:
let
  node = pkgs.nodejs_24;
  jdk = if (pkgs.stdenv.isDarwin)
    then pkgs.zulu11
    else pkgs.zulu21;
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
      ripgrep
      jdk
      (sbt.override { jre = jdk; })
      nixd
      maven
      # devenv  # Temporarily disabled due to Nix 2.24 patch issues
      scala-cli
      openssl
      synergy
      unstable.jetbrains.idea-ultimate
      sops
      age
    ]
    ++ lib.lists.optionals stdenv.isDarwin [
      dockutil
      colima
      docker
      hidden-bar
      docker-compose
      node
      vscode
      raycast
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
      zed-editor
      baobab
      stremio
    ];
}
