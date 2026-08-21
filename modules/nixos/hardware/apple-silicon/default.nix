{
  inputs,
  lib,
  ...
}: let
  asahiPkgs = import inputs.nixos-apple-silicon.inputs.nixpkgs {
    system = "aarch64-linux";
    overlays = [inputs.nixos-apple-silicon.overlays.default];
  };
in {
  imports = [inputs.nixos-apple-silicon.nixosModules.default];

  hardware.asahi = {
    enable = true;
    extractPeripheralFirmware = false;
    overlay = null;
    pkgs = lib.mkForce asahiPkgs;
  };

  boot.loader = {
    timeout = 10;
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = false;
  };
}
