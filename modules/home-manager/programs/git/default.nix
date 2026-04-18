{userConfig, ...}: {
  # Install git via home-manager module

  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = userConfig.fullName;
          email = userConfig.email;
        };
        pull.rebase = "true";
      };
      # signing = lib.mkIf (!pkgs.stdenv.isDarwin) {
      #   key = userConfig.gitKey;
      #   signByDefault = true;
      # };
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
    };

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
  };

  # Enable catppuccin theming for git delta
  catppuccin.delta.enable = true;
}
