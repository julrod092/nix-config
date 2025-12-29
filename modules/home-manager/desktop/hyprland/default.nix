{
  config,
  lib,
  nhModules,
  pkgs,
  caelestia-shell,
  ...
}: 
let
    hyprlandConfig = lib.sourceFiles ./configuration;
in
{
  imports = [
    "${nhModules}/misc/gtk"
    # "${nhModules}/misc/wallpaper"
    "${nhModules}/misc/xdg"
    "${nhModules}/programs/swappy"
    "${nhModules}/programs/wofi"
    "${nhModules}/services/cliphist"
    "${nhModules}/services/kanshi"
    "${nhModules}/services/swaync"
    caelestia-shell.homeManagerModules.default
  ];

  # Consistent cursor theme across all applications (matching caelestia config)
  # Note: sweet-cursors may not be available in nixpkgs, using fallback
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.yaru-theme;  # Fallback - you can install sweet-cursors manually if needed
    name = "Yaru";  # Change to "sweet-cursors" if you install it manually
    size = 24;
  };

  programs.caelestia = {
    enable = true;
    systemd = {
      enable = true; # Use systemd for more reliable startup
      target = "graphical-session.target";
      environment = [];
    };
    settings = {
      bar.status = {
        showBattery = false;
      };
      paths.wallpaperDir = "~/Pictures/Wallpapers";
    };
    cli = {
      enable = true; # Also add caelestia-cli to path
      settings = {
        theme.enableGtk = false;
      };
    };
  };

  # Temporarily disable custom config to debug black screen issue
  xdg.configFile = {
    "caelestia/shell.json" = {
      source = ./configuration/shell.json;
    };
    "hypr" = {
      source = ./configuration;
      recursive = true;
    };
  };
}
