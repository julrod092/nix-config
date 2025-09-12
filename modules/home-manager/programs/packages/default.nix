{ pkgs, lib,  ...}:
let
  nodejs = pkgs.stdenv.mkDerivation rec {
    pname = "nodejs";
    version = "20.18.1";
    # Validate sha256 nix-prefetch-url https://nodejs.org/dist/v20.18.1/node-v20.18.1.tar.gz
    src = if pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64 then
      pkgs.fetchurl {
        url = "https://nodejs.org/dist/v${version}/node-v${version}-darwin-arm64.tar.gz";
        sha256 = "sha256-npLOEDJFWpzEGf5x6QiyeuR3eZNxtFoIRO7bAieZIqQ=";
      }
    else pkgs.stdenv.isDarwin 
      pkgs.fetchurl {
        url = "https://nodejs.org/dist/v${version}/node-v${version}-darwin-x64.tar.gz";
        sha256 = "sha256-PLACEHOLDER";
      };
    
    installPhase = ''
      mkdir -p $out
      cp -R * $out/
    '';
    
    dontBuild = true;
    dontConfigure = true;
    dontStrip = true;
  };
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
      maven
      devenv
      scala-cli
      openssl
      synergy
      unstable.jetbrains.idea-community
      sops
      age
      vscode

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
      nodejs
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
      baobab
      stremio
      codecrafters-cli
      unstable.opencode
      unstable.claude-code
    ];
}
