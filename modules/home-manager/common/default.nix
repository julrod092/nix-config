{
  inputs,
  outputs,
  userConfig,
  pkgs,
  system,
  ...
}: {
  imports = [
    ../programs/aerospace
    ../programs/alacritty
    ../programs/bat
    ../programs/btop
    ../programs/fastfetch
    ../programs/git
    ../programs/lazygit
    ../programs/starship
    ../programs/tmux
    ../programs/zsh
    ../programs/packages
    ../programs/neovim-ide
    ../programs/zen
    ../programs/gpg
    ../scripts
    ../services/ulauncher
    ../services/ssh
    ../services/synergy
  ];

  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
      inputs.neovim-nightly-overlay.overlays.default
      inputs.neovim-flake.overlays.${system}.default
    ];

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
    sessionVariables = {
       EDITOR = "nvim";
     };
  };

  # Catpuccin flavor and accent
  catppuccin = {
    flavor = "macchiato";
    accent = "lavender";
  };
}
