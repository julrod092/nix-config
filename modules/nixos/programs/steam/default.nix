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
    unstable.bottles
    unstable.heroic
  ];

  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
}
