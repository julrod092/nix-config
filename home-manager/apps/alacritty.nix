{ inputs, pkgs, ... }: {

 programs.alacritty = {
    enable = true;
    settings = {
        window = {
          padding = { x = 4; y = 8; };
          decorations = "full";
          opacity = 1;
          startup_mode = "Windowed";
          title = "Alacritty";
          dynamic_title = true;
        };

        import = [
          pkgs.alacritty-theme.citylights
          #"~/.config/alacritty/themes/themes/citylights.toml"
        ];

        font = let fira = style: {
          family = "DejaVu Sans Mono";
          inherit style;
        }; in {
          size = 10;
          normal = fira "Regular";
          bold = fira "Bold";
          italic = fira "Italic";
          bold_italic = fira "Bold Italic";
        };

        cursor = {
          style = "Block";
        };

        live_config_reload = true;
      };
  };

}