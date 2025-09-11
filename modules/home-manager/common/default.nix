{
  inputs,
  outputs,
  userConfig,
  pkgs,
  system,
  config,
  lib,
  ...
}: 
let
  sharedVariables = {
    EDITOR = "nvim";
  };

  darwinVariables = {
    JAVA_HOME = "${pkgs.zulu11}/bin";
    REPO_ACCESS = "$(cat ${config.sops.secrets."github_repo_token_access".path} 2>/dev/null || echo '')";
    NPM_GITHUB_TOKEN = "$(cat ${config.sops.secrets."npm_github_token".path} 2>/dev/null || echo '')";
    M2_HOME = "${pkgs.maven}/bin";
  };

  linuxVariables = {};
in
{
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
      outputs.overlays.unstable-packages
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
    sessionVariables = sharedVariables 
      // (lib.optionalAttrs pkgs.stdenv.isDarwin darwinVariables)
      // (lib.optionalAttrs (!pkgs.stdenv.isDarwin) linuxVariables);
  };

  # Catpuccin flavor and accent
  catppuccin = {
    flavor = "macchiato";
    accent = "lavender";
  };
}
