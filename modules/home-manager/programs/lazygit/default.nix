{
  pkgs,
  lib,
  ...
}: let
  # Declarative lazygit configuration.
  settings = {
    git.paging = {
      colorArg = "always";
      pager = "delta --color-only --dark --paging=never";
    };
  };

  # Render the settings to a YAML file in the Nix store.
  configFile = (pkgs.formats.yaml {}).generate "lazygit-config.yml" settings;

  # lazygit's per-platform config directory (see `lazygit --print-config-dir`).
  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Application Support/lazygit"
    else ".config/lazygit";
in {
  # Install lazygit as a plain package. We deliberately avoid the
  # `programs.lazygit` module: it always delivers config.yml as an immutable
  # read-only Nix store symlink, and lazygit rewrites config.yml on startup
  # (config migration/normalization), which fails with "permission denied".
  # Instead we own the config path ourselves and write a writable copy below.
  home.packages = [pkgs.lazygit];

  home.activation.lazygitConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    cfgDir="$HOME/${configDir}"
    mkdir -p "$cfgDir"
    # Replace any previous (possibly read-only) config with a writable copy.
    rm -f "$cfgDir/config.yml"
    install -m 0644 ${configFile} "$cfgDir/config.yml"
  '';
}
