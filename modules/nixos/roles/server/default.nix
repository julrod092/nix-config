{
  lib,
  pkgs,
  ...
}: {
  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [22];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users = {
    groups.homelab.gid = 1001;
    users = {
      deploy = {
        uid = 1000;
        isNormalUser = true;
        hashedPassword = "!";
        extraGroups = ["wheel"];
        openssh.authorizedKeys.keyFiles = [../../../../files/nix-desktop-yubikey.pub];
      };

      homelab = {
        uid = 1001;
        group = "homelab";
        isNormalUser = true;
        hashedPassword = "!";
        home = "/var/lib/homelab";
        createHome = true;
        shell = lib.getExe' pkgs.shadow "nologin";
        linger = true;
        subUidRanges = [
          {
            startUid = 100000;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 100000;
            count = 65536;
          }
        ];
      };
    };
  };

  security.sudo.extraRules = [
    {
      users = ["deploy"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  nix.settings = {
    experimental-features = ["nix-command" "flakes" "pipe-operators"];
    max-jobs = 1;
    trusted-users = ["root" "deploy"];
  };

  virtualisation.podman.enable = true;

  systemd.tmpfiles.rules = [
    "d /var/lib/containers 0700 homelab homelab - -"
    "d /var/lib/homelab 0750 homelab homelab - -"
    "d /var/lib/nix-fleet 0750 root homelab - -"
    "d /var/lib/nix-fleet/secrets 0750 root homelab - -"
    "d /var/lib/nix-fleet/secrets/aiostreams 0750 root homelab - -"
    "d /var/lib/nix-fleet/secrets/authelia 0750 root homelab - -"
    "d /var/lib/nix-fleet/secrets/lldap 0750 root homelab - -"
    "d /var/lib/nix-fleet/secrets/memos 0750 root homelab - -"
    "d /var/lib/nix-fleet/secrets/norish 0750 root homelab - -"
    "d /var/lib/nix-fleet/secrets/outline 0750 root homelab - -"
    "d /var/lib/nix-fleet/secrets/traefik 0750 root homelab - -"
  ];

  environment.systemPackages = with pkgs; [
    git
    smartmontools
    vim
  ];

  services.smartd.enable = true;
}
