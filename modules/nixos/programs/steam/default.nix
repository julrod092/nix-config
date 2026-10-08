{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
    protonup-ng
    unstable.lutris
    unstable.heroic
    unstable.shadps4
    unstable.shadps4-qtlauncher
  ];

  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

}
