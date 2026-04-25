{pkgs, ...}: {
  # Steam gaming platform configuration

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
    protonup-ng
    lutris
    heroic
  ];

  programs.gamemode.enable = true;
}
