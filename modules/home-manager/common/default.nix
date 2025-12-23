{
  outputs,
  userConfig,
  pkgs,
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
    ../programs/nvim  
    ../programs/zen
    ../programs/gpg
    ../scripts

    # Services
    ../services/ulauncher
    ../services/ssh
  ];

  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
      outputs.overlays.expected-package-revision
      outputs.overlays.synergy
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
      # Help Synergy and other Qt applications use Wayland
      # Falls back to X11 if Wayland is not available
      QT_QPA_PLATFORM = "wayland;xcb";
    };
  };

  # Catpuccin flavor and accent
  catppuccin = {
    flavor = "macchiato";
  };
}
