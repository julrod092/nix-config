{
  inputs,
  nhModules,
  pkgs,
  ...
}: let
  workspaces = {
    browser = "";
    code = "";
    terminal = "";
    steam = "";
    games = "";
  };

  fullWidth = {
    proportion = 1.0;
  };
in {
  imports = [
    inputs.niri.homeModules.config
    "${nhModules}/desktop/wayland-common"
  ];

  nixpkgs.overlays = [
    inputs.niri.overlays.niri
  ];

  programs.niri = {
    package = pkgs.niri-stable;

    settings = {
      # Input
      input = {
        keyboard = {
          xkb.layout = "us";
          repeat-delay = 250;
          repeat-rate = 40;
        };

        touchpad = {
          tap = true;
          natural-scroll = true;
        };

        mouse = {
          accel-profile = "flat";
          accel-speed = 0.5;
        };

        trackpoint.enable = false;

        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "0%";
        };
      };

      # Outputs
      outputs = {
        "DP-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 144.001;
          };
          focus-at-startup = true;
          variable-refresh-rate = true;
        };

        "DP-2" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 144.001;
          };
          variable-refresh-rate = true;
        };
      };

      # General
      spawn-at-startup = [
        {argv = ["noctalia-shell"];}
      ];

      prefer-no-csd = true;
      hotkey-overlay.skip-at-startup = true;
      gestures.hot-corners.enable = false;

      # Layout
      layout = {
        background-color = "#000000";
        gaps = 6;
        center-focused-column = "never";

        preset-column-widths = [
          {proportion = 0.5;}
          {proportion = 0.66667;}
          {proportion = 0.33333;}
        ];

        default-column-width = {
          proportion = 0.5;
        };

        focus-ring = {
          width = 1;
          active.color = "#b7bdf8";
          inactive.color = "#494d64";
        };

        border = {
          enable = false;
          width = 4;
          active.color = "#b7bdf8";
          inactive.color = "#494d64";
          urgent.color = "#ed8796";
        };

        shadow = {
          enable = false;
          softness = 30;
          spread = 5;
          offset = {
            x = 0;
            y = 5;
          };
          color = "#181926aa";
        };
      };

      animations.enable = false;

      # Workspaces
      workspaces = {
        "01-browser".name = workspaces.browser;
        "02-code".name = workspaces.code;
        "03-terminal".name = workspaces.terminal;
        "04-steam".name = workspaces.steam;
        "05-games".name = workspaces.games;
      };

      # Layer rules
      layer-rules = [
        {
          matches = [{namespace = "^noctalia-backdrop";}];
          place-within-backdrop = true;
        }
      ];

      # Window rules
      window-rules = [
        {
          geometry-corner-radius = let
            r = 8.0;
          in {
            top-left = r;
            top-right = r;
            bottom-left = r;
            bottom-right = r;
          };
          clip-to-geometry = true;
        }
        {
          matches = [{app-id = "^zen-twilight$";}];
          default-column-width = fullWidth;
          open-on-workspace = workspaces.browser;
        }
        {
          matches = [{app-id = ''^jetbrains-idea"$'';}];
          default-column-width = fullWidth;
          open-on-workspace = workspaces.code;
        }
        {
          matches = [{app-id = "^Code$";}];
          default-column-width = fullWidth;
          open-on-workspace = workspaces.code;
        }
        {
          matches = [{app-id = "^code$";}];
          default-column-width = fullWidth;
          open-on-workspace = workspaces.code;
        }
        {
          matches = [{app-id = "^Alacritty$";}];
          default-column-width = fullWidth;
          open-on-workspace = workspaces.terminal;
        }
        {
          matches = [{app-id = "^steam$";}];
          default-column-width = fullWidth;
          open-on-workspace = workspaces.steam;
        }
        {
          matches = [{app-id = ''^org\.prismlauncher\.PrismLauncher$'';}];
          open-floating = true;
        }
        {
          matches = [{app-id = "^COBBLEVERSE$";}];
          default-column-width = fullWidth;
          open-on-workspace = workspaces.games;
        }
        {
          matches = [{app-id = ''^steam_app_\d+$'';}];
          open-on-workspace = workspaces.games;
        }
        {
          matches = [{app-id = ''^org\.pulseaudio\.pavucontrol$'';}];
          open-floating = true;
        }
        {
          matches = [{title = "^_crx_.*$";}];
          open-floating = true;
          block-out-from = "screencast";
        }
        {
          matches = [{app-id = ''^(gnome-calculator|org\.gnome\.Calculator)$'';}];
          open-floating = true;
        }
        {
          matches = [
            {
              app-id = "^anki$";
              title = "^Study Deck$";
            }
          ];
          open-floating = true;
        }
        {
          matches = [{title = "^Albert$";}];
          focus-ring.enable = false;
          border.enable = false;
          shadow.enable = false;
          open-floating = true;
          default-floating-position = {
            x = 0;
            y = 300;
            relative-to = "top";
          };
        }
        {
          matches = [{title = ''^.*is sharing (your screen|a window)\.$'';}];
          focus-ring.enable = false;
          border.enable = false;
          open-floating = true;
          default-floating-position = {
            x = 0;
            y = 0;
            relative-to = "bottom";
          };
        }
        {
          matches = [{app-id = ''^steam_app_\d+$'';}];
          excludes = [{title = "^$";}];
          open-fullscreen = true;
          variable-refresh-rate = true;
        }
      ];

      # Bindings
      binds = {
        "Mod+Shift+Slash".action.show-hotkey-overlay = [];

        "Mod+Shift+Return" = {
          hotkey-overlay.title = "Open Terminal";
          action.spawn = "alacritty";
        };
        "Mod+Shift+B" = {
          hotkey-overlay.title = "Open Zen Browser";
          action.spawn = "zen-twilight";
        };

        "Mod+D" = {
          hotkey-overlay.title = "Open Noctalia Launcher";
          action.spawn = ["noctalia-shell" "ipc" "call" "launcher" "toggle"];
        };
        "Ctrl+Space" = {
          hotkey-overlay.title = "Toggle Albert";
          action.spawn = ["albert" "toggle"];
        };

        "Alt+Shift+V" = {
          hotkey-overlay.title = "Clipboard History";
          action.spawn = ["noctalia-shell" "ipc" "call" "launcher" "clipboard"];
        };
        "Mod+Shift+C" = {
          hotkey-overlay.title = "Color Picker";
          action.spawn-sh = "niri msg pick-color | grep -o '#.*' | wl-copy";
        };
        "Mod+Shift+S" = {
          hotkey-overlay.title = "Screenshot Area";
          action.spawn-sh = ''grim -g "$(slurp)" - | swappy -f -'';
        };
        "Mod+Ctrl+S" = {
          hotkey-overlay.title = "Screenshot Screen";
          action.spawn-sh = "grim - | swappy -f -";
        };
        "Mod+Shift+R" = {
          hotkey-overlay.title = "Toggle Screen Recording";
          action.spawn = ["noctalia-shell" "ipc" "call" "plugin" "togglePanel" "screen-recorder"];
        };
        "Ctrl+Alt+L" = {
          hotkey-overlay.title = "Lock Screen";
          action.spawn = ["noctalia-shell" "ipc" "call" "lockScreen" "lock"];
        };
        "Mod+C" = {
          hotkey-overlay.title = "Toggle Control Center";
          action.spawn = ["noctalia-shell" "ipc" "call" "controlCenter" "toggle"];
        };
        "Mod+N" = {
          hotkey-overlay.title = "Toggle Notifications";
          action.spawn = ["noctalia-shell" "ipc" "call" "notifications" "toggleHistory"];
        };
        "Mod+Shift+Backspace" = {
          hotkey-overlay.title = "Clear Notifications";
          action.spawn = ["noctalia-shell" "ipc" "call" "notifications" "clear"];
        };

        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action.spawn = ["noctalia-shell" "ipc" "call" "brightness" "increase"];
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = ["noctalia-shell" "ipc" "call" "brightness" "decrease"];
        };
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn = ["noctalia-shell" "ipc" "call" "volume" "increase"];
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn = ["noctalia-shell" "ipc" "call" "volume" "decrease"];
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn = ["noctalia-shell" "ipc" "call" "volume" "muteOutput"];
        };
        "Shift+XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn = ["noctalia-shell" "ipc" "call" "volume" "increaseInput"];
        };
        "Shift+XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn = ["noctalia-shell" "ipc" "call" "volume" "decreaseInput"];
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action.spawn = ["noctalia-shell" "ipc" "call" "volume" "muteInput"];
        };

        "Mod+Q" = {
          repeat = false;
          action.close-window = [];
        };
        "Mod+F".action.toggle-window-floating = [];
        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [];
        "Mod+M".action.maximize-column = [];
        "Mod+Shift+M".action.fullscreen-window = [];
        "Mod+W".action.toggle-column-tabbed-display = [];
        "Mod+O" = {
          repeat = false;
          action.toggle-overview = [];
        };

        "Mod+Left".action.focus-column-left = [];
        "Mod+Down".action.focus-window-down = [];
        "Mod+Up".action.focus-window-up = [];
        "Mod+Right".action.focus-column-right = [];
        "Mod+H".action.focus-column-left = [];
        "Mod+J".action.focus-window-down = [];
        "Mod+K".action.focus-window-up = [];
        "Mod+L".action.focus-column-right = [];

        "Mod+Ctrl+Left".action.move-column-left = [];
        "Mod+Ctrl+Down".action.move-window-down = [];
        "Mod+Ctrl+Up".action.move-window-up = [];
        "Mod+Ctrl+Right".action.move-column-right = [];
        "Mod+Ctrl+H".action.move-column-left = [];
        "Mod+Ctrl+J".action.move-window-down = [];
        "Mod+Ctrl+K".action.move-window-up = [];
        "Mod+Ctrl+L".action.move-column-right = [];

        "Mod+Home".action.focus-column-first = [];
        "Mod+End".action.focus-column-last = [];
        "Mod+Ctrl+Home".action.move-column-to-first = [];
        "Mod+Ctrl+End".action.move-column-to-last = [];

        "Mod+Shift+Left".action.focus-monitor-left = [];
        "Mod+Shift+Down".action.focus-monitor-down = [];
        "Mod+Shift+Up".action.focus-monitor-up = [];
        "Mod+Shift+Right".action.focus-monitor-right = [];
        "Mod+Shift+H".action.focus-monitor-left = [];
        "Mod+Shift+J".action.focus-monitor-down = [];
        "Mod+Shift+K".action.focus-monitor-up = [];
        "Mod+Shift+L".action.focus-monitor-right = [];

        "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [];
        "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [];
        "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [];
        "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [];
        "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [];
        "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [];
        "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [];
        "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [];

        "Mod+Page_Down".action.focus-workspace-down = [];
        "Mod+Page_Up".action.focus-workspace-up = [];
        "Mod+U".action.focus-workspace-down = [];
        "Mod+I".action.focus-workspace-up = [];

        "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [];
        "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [];
        "Mod+Ctrl+U".action.move-column-to-workspace-down = [];
        "Mod+Ctrl+I".action.move-column-to-workspace-up = [];

        "Mod+Shift+Page_Down".action.move-workspace-down = [];
        "Mod+Shift+Page_Up".action.move-workspace-up = [];
        "Mod+Shift+U".action.move-workspace-down = [];
        "Mod+Shift+I".action.move-workspace-up = [];

        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action.focus-workspace-down = [];
        };
        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action.focus-workspace-up = [];
        };
        "Mod+Ctrl+WheelScrollDown" = {
          cooldown-ms = 150;
          action.move-column-to-workspace-down = [];
        };
        "Mod+Ctrl+WheelScrollUp" = {
          cooldown-ms = 150;
          action.move-column-to-workspace-up = [];
        };

        "Mod+WheelScrollRight".action.focus-column-right = [];
        "Mod+WheelScrollLeft".action.focus-column-left = [];
        "Mod+Ctrl+WheelScrollRight".action.move-column-right = [];
        "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [];
        "Mod+Shift+WheelScrollDown".action.focus-column-right = [];
        "Mod+Shift+WheelScrollUp".action.focus-column-left = [];
        "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [];
        "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [];

        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+0".action.focus-workspace = 10;

        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;
        "Mod+Shift+6".action.move-column-to-workspace = 6;
        "Mod+Shift+7".action.move-column-to-workspace = 7;
        "Mod+Shift+8".action.move-column-to-workspace = 8;
        "Mod+Shift+9".action.move-column-to-workspace = 9;
        "Mod+Shift+0".action.move-column-to-workspace = 10;

        "Mod+BracketLeft".action.consume-or-expel-window-left = [];
        "Mod+BracketRight".action.consume-or-expel-window-right = [];
        "Mod+Comma".action.consume-window-into-column = [];
        "Mod+Period".action.expel-window-from-column = [];

        "Mod+R".action.switch-preset-column-width = [];
        "Mod+Ctrl+R".action.reset-window-height = [];
        "Mod+Ctrl+F".action.expand-column-to-available-width = [];
        "Mod+Ctrl+C".action.center-visible-columns = [];
        "Ctrl+Alt+C".action.center-column = [];
        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        "Mod+Space".action.switch-layout = "next";

        "Mod+Escape" = {
          allow-inhibiting = false;
          action.toggle-keyboard-shortcuts-inhibit = [];
        };
        "Mod+Shift+E".action.quit = [];
        "Ctrl+Alt+Q".action.quit = [];
        "Mod+Shift+P".action.power-off-monitors = [];
      };
    };
  };
}
