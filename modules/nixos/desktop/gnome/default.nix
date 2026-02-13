{
  config,
  pkgs,
  ...
}: {
  environment.gnome.excludePackages = with pkgs; [gnome-tour gnome-shell-extensions];

  programs.gnome-terminal.enable = false;

  services = {
    desktopManager.gnome.enable = true;

    gnome = {
      games.enable = false;
      core-apps.enable = false;
    };
  };
}
