{
  inputs,
  hostname,
  nixosModules,
  userConfig,
  ...
}: let
  homeDir = "/home/${userConfig.name}";
in {
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.disko.nixosModules.disko

    ./disko.nix
    ./hardware-configuration.nix
    "${nixosModules}/common"
    "${nixosModules}/desktop/gnome"
    "${nixosModules}/desktop/niri"
    "${nixosModules}/services/nvidia"
    "${nixosModules}/services/network"
    "${nixosModules}/services/podman"
    "${nixosModules}/programs/nh"
    "${nixosModules}/programs/steam"
  ];

  # Set hostname
  networking.hostName = hostname;

  systemd.tmpfiles.rules = [
    "d ${homeDir}/m2 0775 ${userConfig.name} users - -"
  ];

  # Enable Razer Nari Ultimate headset profiles
  # hardware.razer-nari.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.11";
}
