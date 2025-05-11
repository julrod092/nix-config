{
  inputs,
  outputs,
  userConfig,
  pkgs,
  system,
  ...
}:
let
  vimOverlays = [
    inputs.neovim-nightly-overlay.overlays.default
    # inputs.alacritty-theme.overlays.default
    inputs.neovim-flake.overlays.${system}.default
  ];
in
{
  imports = [
    ../programs/aerospace
    ../programs/alacritty
    ../programs/atuin
    ../programs/bat
    ../programs/btop
    ../programs/fastfetch
    ../programs/git
    ../programs/lazygit
    ../programs/starship
    ../programs/tmux
    ../programs/zsh
    ../programs/packages
    ../scripts
    ../services/easyeffects
  ];

  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
    ] ++ vimOverlays;

    config = {
      allowUnfree = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Home-Manager configuration for the user's home environment
  home = {
    username = "${userConfig.name}";
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${userConfig.name}"
      else "/home/${userConfig.name}";
  };

  # Catpuccin flavor and accent
  catppuccin = {
    flavor = "macchiato";
    accent = "lavender";
  };
}
