{ caelestia-shell, ... }: {
  imports = [
    caelestia-shell.homeManagerModules.default
  ];

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
      source = ./config/shell.json;
    };
  };
}