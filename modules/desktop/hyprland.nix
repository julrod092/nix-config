{config, ...}: let
  top = config.dendritic;
in {
  config.dendritic = {
    nixosModules.hyprland = {pkgs, ...}: {
      imports = [ top.nixosModules.wayland ];

      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };

      services.displayManager.defaultSession = "hyprland-uwsm";

      programs.uwsm = {
        enable = true;
        waylandCompositors.hyprland = {
          prettyName = "Hyprland";
          comment = "Hyprland compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/start-hyprland";
        };
      };

      environment.systemPackages = with pkgs; [ grimblast hyprpicker ];
    };

    homeModules.hyprland = {
      ...
    }: {
      imports = [ top.homeModules.wayland ];

      xdg.configFile = {
        "hypr/hyprland.conf".source = ./hyprland/hyprland.conf;
        "hypr/xdph.conf".text = ''
          screencopy {
            allow_token_by_default = true
            max_fps = 60
          }
        '';
      };
    };
  };
}
