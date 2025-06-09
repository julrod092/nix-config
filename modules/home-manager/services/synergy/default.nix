{pkgs, ...}: {
  # Install synergy via home-manager module
  home.packages = with pkgs; [
    synergy
  ];

  # Source synergy configuration files from the home-manager store
  xdg.configFile = {
    "synergy/synergy.conf".source = ../../../../files/synergy.conf;
  };

  # Synergy server systemd user service
  systemd.user.services.synergy-server = {
    Unit = {
      Description = "Synergy Server";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.synergy}/bin/synergys -f --config %h/.config/synergy/synergy.conf --enable-crypto";
      Restart = "always";
      RestartSec = "10";
      Environment = [
        "DISPLAY=:0"
        "WAYLAND_DISPLAY=wayland-0"
        "XDG_RUNTIME_DIR=/run/user/1000"
      ];
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
} 