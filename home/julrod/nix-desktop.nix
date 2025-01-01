{ inputs, system, ...}: 
let 
  overlays = [
    inputs.neovim-nightly-overlay.overlays.default
    inputs.nur.overlay
    inputs.alacritty-theme.overlays.default
    inputs.neovim-flake.overlays.${system}.default
  ];
in
{
  imports = [
    ../modules/common.nix
    ../modules/firefox.nix

    inputs.neovim-flake.homeManagerModules.${system}.default
  ];
  
  nixpkgs.overlays = overlays;

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
