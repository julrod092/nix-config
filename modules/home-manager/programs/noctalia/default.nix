{
  inputs,
  pkgs,
  userConfig,
  ...
}: let
  homeDir = "/home/${userConfig.name}";
  noctaliaPackage = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  wallpaperPath = toString userConfig.wallpaper;
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    package = noctaliaPackage;
    settings = {
      settingsVersion = 59;

      audio = {
        volumeOverdrive = false;
        volumeFeedback = false;
      };

      bar = {
        barType = "floating";
        position = "top";
        density = "default";
        showOutline = false;
        showCapsule = true;
        capsuleOpacity = 1.0;
        capsuleColorKey = "none";
        widgetSpacing = 6;
        contentPadding = 8;
        backgroundOpacity = 0.0;
        marginVertical = 6;
        marginHorizontal = 6;
        frameRadius = 12;
        displayMode = "always_visible";
        showOnWorkspaceSwitch = true;
        widgets = {
          left = [
            {
              id = "Workspace";
              labelMode = "name";
              hideUnoccupied = true;
              characterCount = 2;
              showLabelsOnlyWhenOccupied = true;
              focusedColor = "primary";
              occupiedColor = "secondary";
              emptyColor = "secondary";
              pillSize = 0.6;
              fontWeight = "bold";
              iconScale = 0.8;
              colorizeIcons = false;
              showApplications = false;
              showApplicationsHover = false;
            }
          ];
          center = [
            {
              id = "Clock";
              formatHorizontal = "HH:mm ddd, MMM dd";
              formatVertical = "HH\\nmm";
              tooltipFormat = "HH:mm dddd, MMMM dd";
            }
          ];
          right = [
            {
              id = "Tray";
              drawerEnabled = true;
            }
            {
              id = "KeyboardLayout";
              displayMode = "always";
              showIcon = true;
            }
            {
              id = "Network";
              displayMode = "icon";
            }
            {
              id = "Volume";
              displayMode = "icon";
            }
            {
              id = "NotificationHistory";
              hideWhenZeroUnread = false;
            }
            {
              id = "Battery";
              displayMode = "graphic-clean";
              hideIfNotDetected = true;
            }
            {
              id = "CustomButton";
              icon = "video";
              showIcon = true;
              hideMode = "alwaysExpanded";
              leftClickExec = "noctalia-shell ipc call plugin togglePanel screen-recorder";
              generalTooltipText = "Screen Recorder";
            }
            {
              id = "ControlCenter";
              icon = "noctalia";
            }
          ];
        };
      };

      general = {
        avatarImage = "${userConfig.avatar}";
        telemetryEnabled = false;
        animationDisabled = true;
        showChangelogOnStartup = false;
        enableShadows = false;
        enableBlurBehind = true;
        lockScreenBlur = 0.0;
        lockScreenTint = 0.0;
        lockScreenAnimations = false;
        keybinds = {
          keyUp = ["Up" "Ctrl+K"];
          keyDown = ["Down" "Ctrl+J"];
          keyLeft = ["Left" "Ctrl+H"];
          keyRight = ["Right" "Ctrl+L"];
          keyEnter = ["Return" "Enter"];
          keyEscape = ["Esc"];
        };
      };

      ui = {
        panelBackgroundOpacity = 1.0;
        panelsAttachedToBar = true;
        settingsPanelMode = "attached";
      };

      location = {
        name = "El Carmen de Viboral";
        autoLocate = false;
        weatherEnabled = false;
      };

      notifications = {
        enabled = true;
        backgroundOpacity = 1.0;
        overlayLayer = true;
        location = "top_right";
        sounds = {
          enabled = false;
          volume = 0.5;
        };
      };

      osd = {
        location = "top_right";
        overlayLayer = true;
        backgroundOpacity = 1.0;
      };

      brightness = {
        enableDdcSupport = false;
      };

      colorSchemes = {
        predefinedScheme = "Noctalia (default)";
        darkMode = true;
        schedulingMode = "off";
        manualSunrise = "06:30";
        manualSunset = "18:30";
        syncGsettings = true;
      };

      nightLight = {
        enabled = false;
        forced = false;
        autoSchedule = false;
        dayTemp = "6500";
        nightTemp = "4000";
        manualSunrise = "06:30";
        manualSunset = "18:30";
      };

      appLauncher = {
        enableClipboardHistory = false;
        autoPasteClipboard = false;
        showCategories = false;
        iconMode = "tabler";
        viewMode = "list";
        terminalCommand = "alacritty -e";
      };

      controlCenter = {
        position = "close_to_bar_button";
        shortcuts = {
          left = [
            {id = "Network";}
            {id = "Bluetooth";}
            {id = "Notifications";}
          ];
          right = [
            {id = "PowerProfile";}
            {id = "KeepAwake";}
            {id = "NightLight";}
          ];
        };
      };

      wallpaper = {
        enabled = true;
        overviewEnabled = false;
        directory = "${homeDir}/Pictures/Wallpapers";
        automationEnabled = false;
        fillMode = "crop";
        fillColor = "#000000";
        transitionDuration = 0;
        transitionType = ["none"];
        skipStartupTransition = true;
        transitionEdgeSmoothness = 0.05;
      };

      hooks = {
        enabled = true;
        startup = "noctalia-shell ipc call wallpaper set ${wallpaperPath} all";
      };

      dock = {
        enabled = false;
      };
    };
  };
}
