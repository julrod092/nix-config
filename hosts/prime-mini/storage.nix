{
  lib,
  pkgs,
  ...
}: {
  fileSystems."/srv/homelab" = {
    device = "/dev/disk/by-label/homelab-data";
    fsType = "ext4";
    options = [
      "noatime"
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8192;
    }
  ];

  systemd.services.prepare-homelab-storage = {
    description = "Prepare external homelab storage";
    after = ["srv-homelab.mount"];
    requires = ["srv-homelab.mount"];
    unitConfig.ConditionPathIsMountPoint = "/srv/homelab";
    serviceConfig.Type = "oneshot";
    script = ''
      ${lib.getExe' pkgs.coreutils "install"} -d -m 0750 -o homelab -g homelab \
        /srv/homelab/prometheus \
        /srv/homelab/archives \
        /srv/homelab/bulk
    '';
    wantedBy = ["multi-user.target"];
  };
}
