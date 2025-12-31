{ config, pkgs, ... }:

{ 

  environment.gnome.excludePackages =
    (with pkgs; [ gnome-tour gnome-shell-extensions ]);

  programs.gnome-terminal.enable = false;

  services = {

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    gnome = {
      games.enable = false;
      core-utilities.enable = false;
    };
    
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };

  dconf.enable = true;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      workspace-names = [ "Code" "Terminal" "Browser" ];
    };
  };
}
