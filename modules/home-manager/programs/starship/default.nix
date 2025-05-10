{pkgs, ...}: {
  # Starship configuration
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = pkgs.lib.importTOML ./presets/gruvbox-rainbow.toml;
  };

  # Enable catppuccin theming for starship.
  # catppuccin.starship.enable = true;
}
