{ pkgs, ... }: {

  programs.nixvim = {
    enable = true;

    colorschemes.catppuccin.enable = true;
    
    plugins = { 
      lualine.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-nix
      nvim-metals
    ];

    opts = {
      number = true;         # Show line numbers
      relativenumber = false; # Show relative line numbers

      shiftwidth = 2;        # Tab width should be 2
    };
  };
}