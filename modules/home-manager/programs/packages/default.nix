{ inputs, pkgs, lib, system, ...}:
let
  node = pkgs.stable.nodejs_24;
  jdk = pkgs.stable.zulu11;
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
      synergy
      stable.zed-editor
      stable.jetbrains.idea-ultimate
      node
      jdk
      (sbt.override { jre = jdk; })
      nixd
      maven
      code-cursor
      devenv
    ]
    ++ lib.optionals stdenv.isDarwin [
      dockutil
      colima
      docker
      hidden-bar
      raycast
    ]
    ++ lib.optionals (!stdenv.isDarwin) [
      pavucontrol
      pulseaudio
      tesseract
      unzip
      wl-clipboard
      rclone
      lmstudio
      libei
      libgbm
    ];
}
