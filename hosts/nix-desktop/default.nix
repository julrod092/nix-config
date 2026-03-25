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
    "${nixosModules}/services/network"
    "${nixosModules}/services/podman"
    "${nixosModules}/programs/nh"
    "${nixosModules}/programs/steam"
    # "${nixosModules}/services/nixflix"
  ];

  # Set hostname
  networking.hostName = hostname;

  fileSystems."/home/julrod/m2" = {
    device = "/dev/disk/by-uuid/f943f8f5-5917-41bf-9a39-382a04fb1986";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  systemd.tmpfiles.rules = [
    "d /home/julrod/m2 0775 julrod users - -"
  ];

  # Enable Razer Nari Ultimate headset profiles
  # hardware.razer-nari.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.11";
}
