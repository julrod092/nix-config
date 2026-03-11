{...}: {
  nixflix = {
    enable = true;
    mediaDir = "/data/media";
    stateDir = "/data/.state";
    mediaUsers = ["julrod"];

    theme = {
      enable = true;
      name = "overseerr";
    };

    nginx = {
      enable = true;
      addHostsEntries = true; # Disable this is you have your own DNS configuration
    };

    postgres.enable = true;

    sonarr = {
      enable = true;
      config = {
        apiKey = "8a2d7a929e25122f7ccd46fd93fa17a8dba31f60f206cec13d8a7fe8329001cd";
        hostConfig.password = "qwerty123";
      };
    };

    radarr = {
      enable = true;
      config = {
        apiKey = "21aac71bcc5d2e7acbadb0f3921617681e3bc3b3317a1289eb2fd1749e701359";
        hostConfig.password = "qwerty123";
      };
    };

    lidarr = {
      enable = true;
      config = {
        apiKey = "21aac71bcc5d2e7acbadb0f3921617681e3bc3b3317a1289eb2fd1749e701359";
        hostConfig.password = "qwerty123";
      };
    };

    prowlarr = {
      enable = true;
      config = {
        apiKey = "21aac71bcc5d2e7acbadb0f3921617681e3bc3b3317a1289eb2fd1749e701359";
        hostConfig.password = "qwerty123";
        indexers = [
          {
            name = "NZBFinder";
            apiKey = "5f107e020c075f159495a109e3b05bb1";
          }
          {
            name = "NzbPlanet";
          }
        ];
      };
    };

    jellyfin = {
      enable = true;
      users = {
        admin = {
          mutable = false;
          policy.isAdministrator = true;
          password = "qwerty123";
        };
      };
    };

    jellyseerr = {
      enable = true;
      apiKey = "ce7a146f4a1f7f5d1c406a4284581cdae110d8314634ab6d65a5e09be8634b2a";
    };

    downloadarr = {
      enable = true;
      deluge = {
        enable = true;
        username = "localclient"; # Default Deluge username
        password = "deluge";
        host = "127.0.0.1"; # Use IP instead of localhost
        port = 8112; # Deluge web UI port (used by *arr services)
      };
    };
  };
}
