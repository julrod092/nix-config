{pkgs, hostname, ...}: 
let
  systemServices = if hostname == "nix-desktop" then {
    synergy-server = {
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
  } else {
    synergy-client = {
      Unit = {
        Description = "Synergy Client";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        # Only enable on non-server hosts
        ConditionHost = "!nix-desktop";
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.synergy}/bin/synergyc --enable-crypto --name ${hostname} nix-desktop.local";
        Restart = "always";
        RestartSec = "10";
        Environment = [
          "DISPLAY=:0"
          "WAYLAND_DISPLAY=wayland-0"
          "XDG_RUNTIME_DIR=/run/user/1000"
          "GDK_BACKEND=x11"
          "QT_QPA_PLATFORM=xcb"
        ];
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
in
{
  # Install synergy via home-manager module
  home.packages = with pkgs; [
    synergy
  ];

  # Source synergy configuration files from the home-manager store
  xdg.configFile = {
    "synergy/synergy.conf".source = ../../../../files/synergy.conf;
  };

  systemd.user.services = systemServices;
} 