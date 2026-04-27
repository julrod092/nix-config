{...}: {
  config.dendritic.homeModules.development = {
    identity,
    lib,
    pkgs,
    ...
  }: let
    mainJdk = pkgs.zulu21;
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  in {
    home.file = lib.mkIf isDarwin {
      "jdks/zulu8".source = pkgs.zulu8;
      "jdks/zulu11".source = pkgs.zulu11;
      "jdks/zulu21".source = mainJdk;
    };

    home.packages = with pkgs;
      [
        dig
        dust
        eza
        fd
        jq
        kubectl
        lazydocker
        nh
        ripgrep
        mainJdk
        (sbt.override { jre = mainJdk; })
        maven
        unstable.devenv
        scala-cli
        openssl
        unstable.jetbrains.idea
        sops
        vscode
        fzf
        unstable.opencode
        nixd
        nil
      ]
      ++ lib.optionals isDarwin [
        dockutil
        unstable.colima
        docker
        unstable.hidden-bar
        docker-compose
        unstable.raycast
        (expected-rev "8374ab2113c7522766acf5ab1af9d8c6824c06d4" pkgs.stdenv.hostPlatform.system).haproxy
        (expected-rev "5d5288fa1b2665243a1fd5dd99703077d25d4218" pkgs.stdenv.hostPlatform.system).nodejs_24
        charles4
        unstable.synergy
        slack
        appcleaner
        unstable.zoom-us
        unstable.claude-code
        unstable.codex
        unstable.google-chrome
      ]
      ++ lib.optionals (!isDarwin) [
        pavucontrol
        pulseaudio
        tesseract
        unzip
        baobab
        codecrafters-cli
        unstable.discord
        obsidian
        libheif
        unstable.deskflow
        unstable.prismlauncher
        unstable.deluge
      ];

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = identity.user.fullName;
          email = identity.user.email;
        };
        pull.rebase = "true";
      };
      ignores = [
        ".devenv*"
        "devenv.local.nix"
        "devenv*"
        ".direnv"
        ".envrc"
        "local*"
      ];
    };

    programs.delta = {
      enable = true;
      options = {
        keep-plus-minus-markers = true;
        light = false;
        line-numbers = true;
        navigate = true;
        width = 280;
      };
    };

    catppuccin.delta.enable = true;

    programs.lazygit = {
      enable = true;
      settings.git.paging = {
        colorArg = "always";
        pager = "delta --color-only --dark --paging=never";
      };
    };

    programs.nixvim = {
      enable = true;
      colorschemes.kanagawa.enable = true;
      plugins = {
        lualine.enable = true;
        treesitter = {
          enable = true;
          settings.auto_install = true;
          grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
            bash
            java
            json
            lua
            make
            markdown
            nix
            regex
            rust
            scala
            toml
            vim
            vimdoc
            xml
            yaml
          ];
        };
        treesitter-context.enable = true;
        neo-tree.enable = true;
        neorg.enable = true;
        telescope.enable = true;
        neogit.enable = true;
        multicursors.enable = true;
        mini = {
          enable = true;
          mockDevIcons = true;
          modules.icons = {};
        };
        web-devicons.enable = false;
      };
      extraPlugins = with pkgs.vimPlugins; [ vim-nix nvim-metals ];
      opts = {
        number = true;
        relativenumber = false;
        shiftwidth = 2;
      };
    };
  };
}
