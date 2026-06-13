{
  inputs,
  pkgs,
  userConfig,
  ...
}: let
  homeDir = "/home/${userConfig.name}";
  noctaliaPackage = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  screenRecorderScript = "${noctaliaPackage}/share/noctalia/assets/scripts/screen_recorder.lua";
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    package = noctaliaPackage;
    settings = {
      audio = {
        enable_overdrive = false;
        enable_sounds = false;
        sound_volume = 0.5;
      };

      backdrop = {
        blur_intensity = 0.4;
        enabled = true;
        tint_intensity = 0.6;
      };

      brightness = {
        enable_ddcutil = false;
      };

      bar = {
        order = ["main"];
        main = {
          auto_hide = false;
          background_opacity = 0.0;
          capsule = true;
          capsule_fill = "surface_variant";
          capsule_opacity = 1.0;
          capsule_radius = 8.0;
          center = ["clock"];
          end = [
            "tray"
            "keyboard_layout"
            "network"
            "volume"
            "notifications"
            "battery"
            "screen_recorder"
            "control-center"
          ];
          margin_edge = 6;
          margin_ends = 6;
          padding = 8;
          position = "top";
          radius = 12;
          shadow = false;
          start = ["workspaces"];
          thickness = 34;
          widget_spacing = 6;
        };
      };

      control_center = {
        shortcuts = [
          {type = "wifi";}
          {type = "bluetooth";}
          {type = "notification";}
          {type = "power_profile";}
          {type = "nightlight";}
          {type = "screen_recorder";}
        ];
        sidebar = "compact";
      };

      keybinds = {
        cancel = ["escape"];
        down = ["down" "ctrl+j"];
        left = ["left" "ctrl+h"];
        right = ["right" "ctrl+l"];
        up = ["up" "ctrl+k"];
        validate = ["return" "kp_enter"];
      };

      location = {
        address = "El Carmen de Viboral";
        auto_locate = false;
        sunrise = "06:30";
        sunset = "18:30";
      };

      lockscreen = {
        blur_intensity = 0.0;
        blurred_desktop = false;
        tint_intensity = 0.0;
      };

      nightlight = {
        enabled = false;
        force = false;
        temperature_day = 6500;
        temperature_night = 4000;
      };

      notification = {
        background_opacity = 1.0;
        enable_daemon = true;
        layer = "overlay";
        position = "top_right";
      };

      osd = {
        position = "top_right";
      };

      shell = {
        avatar_path = "${userConfig.avatar}";
        clipboard_auto_paste = "off";
        settings_show_advanced = false;
        setup_wizard_enabled = false;
        show_location = false;
        telemetry_enabled = false;

        animation = {
          enabled = false;
          speed = 1.0;
        };

        panel = {
          borders = false;
          launcher_categories = false;
          open_near_click_control_center = true;
          shadow = false;
          transparency_mode = "solid";
        };
      };

      system = {
        monitor = {
          cpu_poll_seconds = 5.0;
          disk_poll_seconds = 10.0;
          enabled = true;
          gpu_poll_seconds = 0.0;
          memory_poll_seconds = 5.0;
          network_poll_seconds = 2.0;
        };
      };

      theme = {
        builtin = "Noctalia";
        mode = "dark";
        source = "builtin";
      };

      wallpaper = {
        automation = {
          enabled = false;
        };
        default = {
          path = "${userConfig.wallpaper}";
        };
        directory = "${homeDir}/Pictures/Wallpapers";
        edge_smoothness = 0.05;
        enabled = true;
        fill_color = "#000000";
        fill_mode = "crop";
        transition_duration = 0;
        transition_on_startup = false;
      };

      widget = {
        battery = {
          display_mode = "icon";
          show_label = false;
        };
        clock = {
          format = "{:%H:%M %a, %b %d}";
          tooltip_format = "{:%H:%M %A, %B %d}";
          vertical_format = "{:%H\n%M}";
        };
        keyboard_layout = {
          display = "short";
          show_icon = true;
          show_label = true;
        };
        network = {
          show_label = false;
        };
        notifications = {
          hide_when_no_unread = false;
        };
        screen_recorder = {
          script = screenRecorderScript;
          type = "scripted";
        };
        tray = {
          drawer = true;
        };
        volume = {
          device = "output";
          show_label = false;
        };
        workspaces = {
          display = "id";
          empty_color = "secondary";
          focused_color = "primary";
          hide_when_empty = true;
          labels_only_when_occupied = true;
          max_label_chars = 2;
          occupied_color = "secondary";
          pill_scale = 0.6;
        };
      };
    };
  };
}
