{pkgs, ...}: {
  # Starship configuration
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = pkgs.lib.importTOML ./presets/gruvbox-rainbow.toml;
  };
}
