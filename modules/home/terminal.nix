{...}: {
  config.dendritic.homeModules.terminal = {
    identity,
    pkgs,
    ...
  }: let
    systemRebuild =
      if pkgs.stdenv.isDarwin
      then "darwin-rebuild"
      else "nixos-rebuild";
    copyCmd = if pkgs.stdenv.hostPlatform.isDarwin then "pbcopy" else "wl-copy";
  in {
    home.file.".local/bin" = {
      recursive = true;
      source = ./terminal/bin;
    };

    home.sessionPath = pkgs.lib.optionals pkgs.stdenv.isDarwin [ "$HOME/.local/bin" ];

    programs.alacritty = {
      enable = true;
      settings = {
        general.live_config_reload = true;
        terminal.shell = {
          program = "zsh";
          args = ["-l" "-c" "tmux attach || tmux "];
        };
        env.TERM = "xterm-256color";
        window = {
          decorations = if pkgs.stdenv.isDarwin then "buttonless" else "none";
          dynamic_title = false;
          dynamic_padding = true;
          dimensions = {
            columns = 170;
            lines = 45;
          };
          padding = {
            x = 5;
            y = 1;
          };
        };
        scrolling = {
          history = 10000;
          multiplier = 3;
        };
        font = {
          size = 12;
          normal = {
            family = "MesloLGS Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "MesloLGS Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "MesloLGS Nerd Font";
            style = "Italic";
          };
          bold_italic = {
            family = "MesloLGS Nerd Font";
            style = "Italic";
          };
        };
        selection = {
          semantic_escape_chars = '',│`|:"' ()[]{}<>'';
          save_to_clipboard = true;
        };
      };
    };

    catppuccin.alacritty.enable = true;

    programs.fzf = {
      enable = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--bind '?:toggle-preview'"
        "--bind 'ctrl-a:select-all'"
        "--bind 'ctrl-e:execute(echo {+} | xargs -o nvim)'"
        "--bind 'ctrl-y:execute-silent(echo {+} | ${copyCmd})'"
        "--color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'"
        "--height=40%"
        "--info=inline"
        "--layout=reverse"
        "--multi"
        "--preview '([[ -f {} ]] && (bat --color=always --style=numbers,changes {} || cat {})) || ([[ -d {} ]] && (ls -la --color=always {})) || echo {} 2> /dev/null | head -200'"
        "--preview-window=:hidden"
        "--prompt='~ ' --pointer='▶' --marker='✓'"
      ];
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = pkgs.lib.importTOML ./terminal/gruvbox-rainbow.toml;
    };

    programs.tmux = {
      enable = true;
      baseIndex = 1;
      escapeTime = 10;
      historyLimit = 10000;
      keyMode = "vi";
      mouse = true;
      sensibleOnTop = false;
      terminal = "screen-256color";
      extraConfig = ''
        set -g prefix C-q
        unbind C-b
        unbind '"'
        unbind %
        bind v split-window -h -c "#{pane_current_path}"
        bind s split-window -v -c "#{pane_current_path}"
        bind -n S-Down resize-pane -D 8
        bind -n S-Up resize-pane -U 8
        bind -n S-Left resize-pane -L 8
        bind -n S-Right resize-pane -R 8
        bind r command-prompt -I "#W" "rename-window '%%'"
        bind R source-file ~/.config/tmux/tmux.conf \; display "TMUX Conf Reloaded"
        bind C-l send-keys 'C-l'
        bind-key -n C-f run-shell "tmux new-window -t 10 -n project-selector cd-to-project"
        set -ga terminal-overrides ",xterm-256color:RGB:smcup@:rmcup@"
        set -g focus-events on
        set-option -sg escape-time 10
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf|atuin)(diff)?$'"
        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
      '';
    };

    catppuccin.tmux = {
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

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      shellAliases = {
        ff = "fastfetch";
        nix-clean = "sudo nix-env --delete-generations old && nix-env --delete-generations old && sudo  nix-collect-garbage -d && nix-collect-garbage -d";
        nix-update = "sudo ${systemRebuild} switch --flake ~/.nix-config#${identity.hostName}";
        hm-update = "home-manager switch --flake ~/.nix-config#${identity.user.name}@${identity.hostName} && source ~/.zshrc";
        flake-update = "nix flake update --flake ~/.nix-config";
        nix-full-update = "flake-update && nix-update && hm-update && nix-clean";
      };
      oh-my-zsh = {
        enable = true;
        plugins = ["git"];
        theme = "agnoster";
      };
      initContent = ''
        prompt_context() {
          if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
            prompt_segment black default "%(!.%{%F{yellow}%}.) λ "
          fi
        }
      '';
    };
  };
}
