# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }: 

let 
  system = "x86_64-linux";
  overlays = [
    inputs.neovim-nightly-overlay.overlays.default
    inputs.nur.overlay
    inputs.alacritty-theme.overlays.default
    inputs.neovim-flake.overlays.${system}.default
  ];
in
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./apps/firefox.nix
    ./apps/zsh.nix
    ./apps/alacritty.nix
    ./apps/neovim.nix

    # flake imports
    inputs.neovim-flake.homeManagerModules.${system}.default
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = overlays;
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # TODO: Set your username
  home = {
    username = "julrod";
    homeDirectory = "/home/julrod";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # Utilities
    synergy
    vscode
    zoom-us
    firefox
    tmux
    
    # Virtualization
    vmware-horizon-client

    # Scala
    jdk17
    sbt
    scala-cli

    # Rust
    cargo
    rustc
    rust-analyzer

    # Fonts
    fira-code
    fira-code-symbols
    dejavu_fonts
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  
  programs.git = {
    enable = true;
    userName = "Julian Rodriguez";
    userEmail = "jrodriguezrpo@proton.me";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
