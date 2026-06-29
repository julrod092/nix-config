{
  inputs,
  pkgs,
  ...
}: {
  # Steam gaming platform configuration

  imports = [
    inputs.steam-config-nix.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
    protonup-ng
    unstable.lutris
    unstable.bottles
    unstable.heroic
  ];

  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    config = {
      enable = true;
      closeSteam = true;
      defaultCompatTool = "GE-Proton11-1";

      apps = {
        uncharted = {
          id = 1659420;
          launchOptions = {
            env = {
              PROTON_DLSS_UPGRADE = "1";
              PROTON_ENABLE_WAYLAND = "1";
            };

            args = [
              "--gamemoderun"
            ];
          };
        };
      };
    };
  };
}
