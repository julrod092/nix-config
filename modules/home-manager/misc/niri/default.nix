{ config, pkgs, inputs, ... }:

{

  imports = [#
    inputs.noctalia.homeModules.default
  ];

  xdg.configFile."niri/config.kdl".source = ./config.kdl;
  xdg.configFile."swaylock/config".source = ./swaylock.conf;
  home.file.".local/bin/nws.sh".source = ./nws.sh;

  programs = {
    noctalia-shell = {
      enable = true;
      systemd.enable = true;
      settings = {
        # configure noctalia here
        bar = {
          density = "compact";
          position = "top";
          barType = "floating";
          showCapsule = false;
          backgroundOpacity = 0.8;
          useSeparateOpacity = true;
          floating = true;
          marginVertical = 10;
          marginHorizontal = 15;
          widgets = {
            left = [
              {
                id = "ControlCenter";
                useDistroLogo = true;
              }
              {
                id = "Launcher";
              }
            ];
            center = [
              {
                formatHorizontal = "dd-MM-yyyy HH:mm";
                formatVertical = "HH mm";
                id = "Clock";
                useMonospacedFont = true;
                usePrimaryColor = true;
              }
              {
                hideUnoccupied = false;
                id = "Workspace";
                labelMode = "none";
              }
            ];
            right = [
              {
                id = "Network";
              }
              {
                id = "Bluetooth";
              }
            ];
          };
        };
        colorSchemes.predefinedScheme = "Monochrome";
        general = {
          avatarImage = "/home/drfoobar/.face";
          radiusRatio = 0.2;
        };
        location = {
          name = "El Carmen de Viboral, Colombia";
        };
        dock = {
          enabled = false;
        };
        sessionMenu = {
          enableCountdown = true;
          countdownDuration = 10000;
          position = "right";
          showHeader = true;
          largeButtonsStyle = true;
          largeButtonsLayout = "single-row";
          showNumberLabels = true;
          powerOptions = [
            {
              action = "lock";
              enabled = true;
            }
            {
              action = "suspend";
              enabled = true;
            }
            {
              action = "hibernate";
              enabled = true;
            }
            {
              action = "reboot";
              enabled = true;
            }
            {
              action = "logout";
              enabled = true;
            }
            {
              action = "shutdown";
              enabled = true;
            }
          ];
        };
      };
    };
  };
}
