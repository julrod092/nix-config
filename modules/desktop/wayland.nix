{config, ...}: let
  top = config.dendritic;
in {
  config.dendritic = {
    nixosModules.wayland = {pkgs, ...}: {
      services.displayManager.ly.enable = true;
      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;

      services.gnome.gnome-keyring.enable = true;
      security.polkit.enable = true;
      security.pam.services.ly.enableGnomeKeyring = true;

      environment.systemPackages = with pkgs; [
        file-roller
        gnome-calculator
        gnome-text-editor
        loupe
        nautilus
        seahorse
        showtime
        gpu-screen-recorder
        grim
        libnotify
        pamixer
        pavucontrol
        slurp
      ];
    };

    homeModules.wayland = {
      config,
      lib,
      ...
    }: {
      imports = [
        top.homeModules.wayland-ui
        top.homeModules.noctalia
      ];

      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = config.gtk.cursorTheme.package;
        name = config.gtk.cursorTheme.name;
        size = 24;
      };

      dconf.settings = {
        "org/gnome/calculator" = {
          accuracy = 9;
          angle-units = "degrees";
          base = 10;
          button-mode = "basic";
          number-format = "automatic";
          show-thousands = false;
          show-zeroes = false;
          source-currency = "";
          source-units = "degree";
          target-currency = "";
          target-units = "radian";
          window-maximized = false;
        };

        "org/gnome/desktop/wm/preferences".button-layout = lib.mkForce "";

        "org/gnome/nautilus/preferences" = {
          default-folder-viewer = "list-view";
          migrated-gtk-settings = true;
          search-filter-time-type = "last_modified";
          search-view = "list-view";
        };

        "org/gtk/gtk4/settings/file-chooser".show-hidden = true;

        "org/gtk/settings/file-chooser" = {
          date-format = "regular";
          location-mode = "path-bar";
          show-hidden = true;
          show-size-column = true;
          show-type-column = true;
          sort-column = "name";
          sort-directories-first = false;
          sort-order = "ascending";
          type-format = "category";
          view-type = "list";
        };
      };
    };
  };
}
