{
  osConfig,
  pkgs,
  ...
}: let
  uid = osConfig.users.users.homelab.uid;
in {
  home = {
    username = "homelab";
    homeDirectory = "/var/lib/homelab";
    stateVersion = "26.05";
    packages = [pkgs.podman];
  };

  programs.home-manager.enable = true;

  services.podman.settings.storage.storage = {
    driver = "overlay";
    graphroot = "/var/lib/containers";
    runroot = "/run/user/${toString uid}/containers";
  };

  nps = {
    hostUid = uid;
    defaultTz = "America/Bogota";
    hostIP4Address = "192.168.68.56";
    storageBaseDir = "/var/lib/homelab";
    externalStorageBaseDir = "/srv/homelab";
  };

  systemd.user.startServices = "sd-switch";

  assertions = [
    {
      assertion = uid == 1001;
      message = "The prime-mini homelab account UID must remain 1001.";
    }
  ];
}
