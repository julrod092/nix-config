{...}: {
  config.dendritic.homeModules.wayland-ui = {
    config,
    pkgs,
    ...
  }: {
    gtk = {
      enable = true;
      colorScheme = "dark";
      gtk4.theme = config.gtk.theme;
      theme = {
        name = "catppuccin-${config.catppuccin.flavor}-${config.catppuccin.accent}-compact";
        package = pkgs.catppuccin-gtk.override {
          accents = [ config.catppuccin.accent ];
          variant = config.catppuccin.flavor;
          size = "compact";
        };
      };
      iconTheme = {
        name = "Tela-circle-dark";
        package = pkgs.tela-circle-icon-theme;
      };
      cursorTheme = {
        name = "Yaru";
        package = pkgs.yaru-theme;
        size = 24;
      };
      font = {
        name = "Roboto";
        size = 11;
      };
      gtk3.bookmarks = [
        "file://${config.home.homeDirectory}/Documents"
        "file://${config.home.homeDirectory}/Downloads"
        "file://${config.home.homeDirectory}/Pictures"
        "file://${config.home.homeDirectory}/Videos"
        "file://${config.home.homeDirectory}/Downloads/temp"
        "file://${config.home.homeDirectory}/Documents/repositories"
      ];
    };

    qt = {
      enable = true;
      platformTheme = {
        name = "qtct";
        package = pkgs.kdePackages.qt6ct;
      };
      style.name = "kvantum";
      qt6ctSettings.Appearance.icon_theme = config.gtk.iconTheme.name;
    };

    catppuccin.kvantum.enable = true;

    xdg = {
      enable = true;
      desktopEntries = {
        uuctl = {
          name = "uuctl";
          noDisplay = true;
        };
        qt6ct = {
          name = "qt6ct";
          noDisplay = true;
        };
        kvantummanager = {
          name = "kvantum";
          noDisplay = true;
        };
      };
      mimeApps = {
        enable = true;
        defaultApplicationPackages = [
          pkgs.gnome-text-editor
          pkgs.loupe
          pkgs.showtime
        ];
      };
      userDirs = {
        enable = true;
        createDirectories = true;
      };
      configFile."swappy/config".text = ''
        [Default]
        save_dir=$HOME/Pictures
        save_filename_format=screenshot-%Y%m%d-%H%M%S.png
      '';
    };

    home.packages = [ pkgs.swappy ];

    services.hypridle = {
      enable = true;
      settings.general = {
        before_sleep_cmd = "noctalia-shell ipc call lockScreen lock";
        after_sleep_cmd = "pidof Hyprland >/dev/null && hyprctl dispatch dpms on || niri msg action power-on-monitors";
        lock_cmd = "noctalia-shell ipc call lockScreen lock";
      };
    };

    services.kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";
      settings = [
        {
          profile.name = "docked";
          profile.outputs = [
            {
              criteria = "DP-1";
              status = "enable";
              position = "0,0";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        }
        {
          profile.name = "undocked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              position = "0,0";
            }
          ];
        }
      ];
    };
  };
}
