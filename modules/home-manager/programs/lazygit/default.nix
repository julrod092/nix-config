{
  pkgs,
  lib,
  ...
}: let
  settings = {
    git.paging = {
      colorArg = "always";
      pager = "delta --color-only --dark --paging=never";
    };
  };

  configFile = (pkgs.formats.yaml {}).generate "lazygit-config.yml" settings;

  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Application Support/lazygit"
    else ".config/lazygit";
in {
  home.packages = [pkgs.lazygit];

  home.activation.lazygitConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    cfgDir="$HOME/${configDir}"
    mkdir -p "$cfgDir"
    rm -f "$cfgDir/config.yml"
    install -m 0644 ${configFile} "$cfgDir/config.yml"
  '';
}
