{
  inputs,
  hostname,
  nixosModules,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    "${nixosModules}/common"
    "${nixosModules}/desktop/gnome"
    "${nixosModules}/desktop/niri"
    "${nixosModules}/services/nvidia"
    "${nixosModules}/services/podman"
    "${nixosModules}/services/network"
    "${nixosModules}/programs/nh"
    "${nixosModules}/programs/steam"

  ];

  # Set hostname
  networking.hostName = hostname;

  # Enable Razer Nari Ultimate headset profiles
  # hardware.razer-nari.enable = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.11";
}
