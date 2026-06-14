{
  inputs,
  nixosModules,
  pkgs,
  ...
}: {
  imports = [
    inputs.niri.nixosModules.niri
    "${nixosModules}/desktop/wayland-common"
  ];

  nixpkgs.overlays = [
    inputs.niri.overlays.niri
  ];

  # Enable Niri
  programs.niri = {
    enable = true;
    package = pkgs.niri-stable;
  };

  # Enable Xwayland
  environment.systemPackages = with pkgs; [
    xwayland-satellite-stable
  ];
}
