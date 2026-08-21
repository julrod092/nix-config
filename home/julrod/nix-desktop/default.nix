{nhModules, ...}: {
  imports = [
    "${nhModules}/roles/workstation"
    "${nhModules}/desktop/niri"
    "${nhModules}/secrets/sops"
   # "${nhModules}/services/stacks"
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  nh.programming.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
