{lib, ...}: {
  # Manage kanshi services via Home-manager
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

  systemd.user.services.kanshi.Unit.ConditionEnvironment = lib.mkForce [
    "WAYLAND_DISPLAY"
    "XDG_CURRENT_DESKTOP=niri"
  ];
}
