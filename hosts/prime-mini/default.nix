{
  config,
  lib,
  nixosModules,
  ...
}: let
  stackEnabled = config.home-manager.users.homelab.nh.primeMiniStack.enable;
in {
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    "${nixosModules}/hardware/apple-silicon"
    "${nixosModules}/roles/server"
  ];

  networking.hostName = "prime-mini";

  networking.firewall = {
    allowedTCPPorts = lib.mkIf stackEnabled [53 80 443 853];
    allowedUDPPorts = lib.mkIf stackEnabled [53];
  };

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = lib.mkIf stackEnabled 53;

  systemd.services.home-manager-homelab = lib.mkIf stackEnabled {
    after = [
      "network-online.target"
      "systemd-sysctl.service"
    ];
    requires = ["systemd-sysctl.service"];
    wants = ["network-online.target"];
  };

  system.stateVersion = "26.11";
}
