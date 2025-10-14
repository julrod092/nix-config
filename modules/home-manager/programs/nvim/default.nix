{ pkgs, ... }: {

  programs.nixvim = {
    enable = true;

    colorschemes.kanagawa.enable = true;
    
    plugins = { 
      lualine.enable = true;
      treesitter = {
        enable = true;

        settings = {
          auto_install = true;
        };

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

      treesitter-context = { 
        enable = true;
      };

      neo-tree.enable = true;
      neorg.enable = true;
            
      telescope = {
        enable = true;
      }; 

      neogit = { 
        enable = true; 
      };

      multicursors = {
        enable = true;
      };

      mini = {
        enable = true;
        mockDevIcons = true;
        modules.icons = { };  # Empty attrset to enable the module
      };

      # Explicitly disable web-devicons since mini.icons is handling it
      web-devicons.enable = false;
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-nix
      nvim-metals
    ];

    opts = {
      number = true;
      relativenumber = false;
      shiftwidth = 2;
    };
  };
}