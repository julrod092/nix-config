{pkgs, ...}: {
  # Enable Ly display manager for Wayland sessions.
  services.displayManager.ly.enable = true;

  # Enable Power management support
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Enable security services
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  security.pam.services = {
    ly.enableGnomeKeyring = true;
  };

  # Common packages for Wayland compositors
  environment.systemPackages = with pkgs; [
    # GNOME apps
    file-roller # archive manager
    gnome-calculator
    gnome-text-editor
    loupe # image viewer
    nautilus # file manager
    seahorse # keyring manager
    showtime # Video player

    # Wayland utilities
    gpu-screen-recorder
    grim
    libnotify
    pamixer
    pavucontrol
    slurp
  ];
}
