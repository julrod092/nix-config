{ config, pkgs, ... }: {

  # Install synergy package
  environment.systemPackages = with pkgs; [
    synergy
  ];

  # Copy synergy configuration files with proper permissions
  environment.etc."synergy/synergy.conf".source = ../../../../files/synergy.conf;
  environment.etc."synergy/SSL/Synergy.pem" = {
    source = ../../../../files/synergy-ssl/Synergy.pem;
    mode = "0600";
    user = "root";
    group = "users";
  };

  # Synergy server systemd user service template
  systemd.user.services.synergy-server = {
    description = "Synergy Server";
    after = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    wantedBy = [ "default.target" ];
    
    environment = {
      DISPLAY = ":0";
      WAYLAND_DISPLAY = "wayland-0";
      XDG_RUNTIME_DIR = "/run/user/1000";
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.synergy}/bin/synergys -f --config /etc/synergy/synergy.conf --enable-crypto --tls-cert /etc/synergy/SSL/Synergy.pem";
      Restart = "always";
      RestartSec = "10";
    };
  };

  # Enable lingering for the main user to start user services on boot
  systemd.services.enable-synergy-linger = {
    description = "Enable lingering for synergy user services";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.systemd}/bin/loginctl enable-linger julrod";
      ExecStop = "${pkgs.systemd}/bin/loginctl disable-linger julrod";
    };
  };

  # Open firewall for synergy
  networking.firewall = {
    allowedTCPPorts = [ 24800 ];
    allowedUDPPorts = [ 24800 ];
  };
} 