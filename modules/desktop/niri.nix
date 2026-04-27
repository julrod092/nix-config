{config, ...}: let
  top = config.dendritic;
in {
  config.dendritic = {
    nixosModules.niri = {pkgs, ...}: {
      imports = [ top.nixosModules.wayland ];

      programs.niri.enable = true;
      environment.systemPackages = with pkgs; [ xwayland-satellite ];
    };

    homeModules.niri = {
      ...
    }: {
      imports = [ top.homeModules.wayland ];

      xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;
    };
  };
}
