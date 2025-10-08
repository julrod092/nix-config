{userConfig, lib, pkgs, ...}: {
  # Install git via home-manager module

  programs.git = {
    enable = true;
    userName = userConfig.fullName;
    userEmail = userConfig.email;
    signing = lib.mkIf (!pkgs.stdenv.isDarwin) {
      key = userConfig.gitKey;
      signByDefault = true;
    };
    ignores = [
      # Devenv
      ".devenv*"
      "devenv.local.nix"
      "devenv*"

      # direnv
      ".direnv"

      #env
      ".envrc"

      # Local configs
      "local*"
    ];
    delta = {
      enable = true;
      options = {
        keep-plus-minus-markers = true;
        light = false;
        line-numbers = true;
        navigate = true;
        width = 280;
      };
    };
    extraConfig = {
      pull.rebase = "true";
    };
  };

  # Enable catppuccin theming for git delta
  catppuccin.delta.enable = true;
}
