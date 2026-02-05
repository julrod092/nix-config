{nhModules,...}: {
  imports = [
    "${nhModules}/common"
    "${nhModules}/misc/gtk"
    "${nhModules}/misc/xdg"
    "${nhModules}/misc/qt"
    "${nhModules}/misc/niri"
    "${nhModules}/programs/lan-mouse"
    # "${nhModules}/secrets/sops"
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
