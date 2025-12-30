{ config, pkgs, ... }:

{
  services = {
    xserver.enable = true;
    xserver.displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
