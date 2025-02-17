{...}: {
  # Install catpuccin
  catppuccin = { 
    flavor = "macchiato";
    alacritty.enable = true;
    bat.enable = true;
    btop.enable = true;
    tmux = {
      enable = true;
      extraConfig = ''
        set -g @catppuccin_flavor "macchiato"
        set -g @catppuccin_status_background "none"

        set -g @catppuccin_window_current_number_color "#{@thm_peach}"
        set -g @catppuccin_window_current_text " #W"
        set -g @catppuccin_window_current_text_color "#{@thm_bg}"
        set -g @catppuccin_window_number_color "#{@thm_blue}"
        set -g @catppuccin_window_text " #W"
        set -g @catppuccin_window_text_color "#{@thm_surface_0}"
        set -g @catppuccin_status_left_separator "█"

        set -g status-right "#{E:@catppuccin_status_host}#{E:@catppuccin_status_date_time}"
        set -g status-left ""
      '';
    };
  };
}
