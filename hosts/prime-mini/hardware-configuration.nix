{
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/EFI\\x20-\\x20NIXOS";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
