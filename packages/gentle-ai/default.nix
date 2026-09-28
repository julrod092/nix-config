{
  lib,
  stdenvNoCC,
  fetchurl,
}: let
  version = "3.7.0";
  archives = {
    x86_64-linux = {
      name = "gentle-ai_${version}_linux_amd64.tar.gz";
      hash = "sha256-pzCmGkN1jwTMmkrGRJRcwOhlKh4z1pl6Cj0/AETS//U=";
    };
    aarch64-linux = {
      name = "gentle-ai_${version}_linux_arm64.tar.gz";
      hash = "sha256-o6PTqXTz2bZ9k1/p4waug8MF2k7Buu1KUxnBCwRM0Os=";
    };
    aarch64-darwin = {
      name = "gentle-ai_${version}_darwin_arm64.tar.gz";
      hash = "sha256-ZutXQMRQbLLP0cxSB0OcYc/gdniFT0rHyDAnqVoOZmo=";
    };
  };
  archive = archives.${stdenvNoCC.hostPlatform.system}
    or (throw "gentle-ai is unsupported on ${stdenvNoCC.hostPlatform.system}");
in
  stdenvNoCC.mkDerivation {
    pname = "gentle-ai";
    inherit version;

    src = fetchurl {
      url = "https://github.com/Gentleman-Programming/gentle-ai/releases/download/v${version}/${archive.name}";
      inherit (archive) hash;
    };

    unpackPhase = "tar -xzf $src";

    installPhase = ''
      install -Dm755 gentle-ai "$out/bin/gentle-ai"
    '';

    meta = {
      description = "Deterministic engineering environment for AI coding agents";
      homepage = "https://github.com/Gentleman-Programming/gentle-ai";
      license = lib.licenses.mit;
      platforms = builtins.attrNames archives;
      mainProgram = "gentle-ai";
    };
  }
