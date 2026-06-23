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
  ];

  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    config = {
      enable = true;
      closeSteam = true;
      defaultCompatTool = "GE-Proton";

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

        gta-v = {
          id = 3240220;
          launchOptions = {
            env = {
              PROTON_BATTLEYE_RUNTIME = "~/.local/share/Steam/steamapps/common/Proton\ BattlEye\ Runtime/";
              PROTON_DLSS_UPGRADE = "1";
              PROTON_ENABLE_WAYLAND = "1";
            };

            args = [
              "--fullscreen"
              "--force-grab-cursor"
              "--gamemoderun"
            ];
          };
        };
      };
    };
  };
}
