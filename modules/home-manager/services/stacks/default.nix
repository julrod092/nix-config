{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.nh.primeMiniStack;
  secretRoot = "/var/lib/nix-fleet/secrets";
  keyPath = service: name: "${secretRoot}/${service}/${name}";
  qualifiedImages = {
    adguard = "docker.io/adguard/adguardhome:v0.107.79@sha256:aba9e3bf0613be3ba3755e1fc311b126e2c24bec25e18b6483894a88283074f0";
    aiostreams = "ghcr.io/viren070/aiostreams:v2.33.2@sha256:b169ccfb2b6f351f1bc5a8a460e4e102db77a11fb4fc58222e411d96b3adb85b";
    authelia = "ghcr.io/authelia/authelia:4.39.20@sha256:1b363e9279e742397966333f364e0876ae02bf5c876de73e83af6d48c57ff51b";
    docker-socket-proxy = "ghcr.io/tecnativa/docker-socket-proxy:v0.5.0@sha256:1f5038b54f06c3e18422902cf00ba21803d1c97805aae032e5e6673d532d3459";
    grafana = "docker.io/grafana/grafana:13.2.0@sha256:3fd54ae1214669f8355f065ec9f6445d5279a3d77095ab048ca045685272429b";
    homepage = "ghcr.io/gethomepage/homepage:v2.1.0@sha256:d0aeae2e24387af7267d38c8573692b61e0543aa083c689ad04f32267fe6706a";
    job-ops = "ghcr.io/dakheera47/job-ops:v0.11.0@sha256:37b11b43f2e88b034a3b64066cedd530687e7f280d5a980b60af1714434ef43d";
    lldap = "ghcr.io/lldap/lldap:2026-08-10-alpine-rootless@sha256:ef56e5717738734cedc41bef70c6ece5fb79531322cf58016d015acd99ca1b09";
    memos = "ghcr.io/usememos/memos:0.30.0@sha256:71a5b4738d1bed96e92112004054f0888e92791b64eb78afd79077c96e6f9327";
    memos-db = "docker.io/postgres:17@sha256:e38411452a464af89e5adadb8d223bf53b898d47d6ef918b2d58c08707350449";
    norish = "docker.io/norishapp/norish:v0.20.0-beta@sha256:a289b81273dac3b7e7a17fd2a8a2c313d5edc673e5ba42781dc155196b38b6e8";
    norish-browser = "docker.io/zenika/alpine-chrome:124@sha256:e3048875b6f75d0332085b093d55a82009fb8e688a1394106800397b534b9b23";
    norish-db = "docker.io/postgres:18@sha256:06cad38a5d9f5d24b4d83d86def30795d5e4b757fedbf5281172b576dedcd941";
    norish-redis = "docker.io/redis:8@sha256:691577adaf11927f4bb8871d40a5dd69a5c300d4453b742e8f6383c3e6e8d2e1";
    ntfy = "docker.io/binwiederhier/ntfy:v2.27.0@sha256:f2419f405127afa868f10985c1a41449e673477cee1eb19994339a5ae8b592e7";
    outline = "docker.io/outlinewiki/outline:1.9.2@sha256:32d76719c378931dd65d93945930ca380d8376a0337d98a991fcc12b266f33cf";
    outline-db = "docker.io/postgres:17@sha256:e38411452a464af89e5adadb8d223bf53b898d47d6ef918b2d58c08707350449";
    outline-redis = "docker.io/redis:8.2@sha256:69549d08c5a19b8c28214dea5dfe3b6afa7ac1ad7ea61d66c29a8454b875df40";
    prometheus = "docker.io/prom/prometheus:v3.14.0@sha256:5ce7540c3c00ef4ab0c9d2c995c6a5b9c421f44b4a115d97a2c7af3b1c21cbb0";
    traefik = "docker.io/traefik:v3.7.11@sha256:5203c3f39ca70de6790d964624e042463ffbd57715bc82be155cf224c0dd5144";
  };
  forwardAuthContainers = [
    "adguard"
    "homepage"
    "job-ops"
    "lldap"
    "prometheus"
    "traefik"
    "networking-toolbox"
    "it-tools"
    "stirling-pdf"
  ];
in {
  options.nh.primeMiniStack.enable = lib.mkEnableOption "the prime-mini homelab stack";

  config = {
    nps.stacks = {
      adguard.enable = cfg.enable;
      aiostreams = {
        enable = cfg.enable;
        secretKeyFile = keyPath "aiostreams" "aiostreams-secret-key";
      };
      memos = {
        enable = cfg.enable;
        db = {
          type = "postgres";
          passwordFile = keyPath "memos" "memos-db-password";
        };
        oidc = {
          registerClient = true;
          clientSecretHash.toHash = keyPath "memos" "memos-oidc-client-secret";
        };
      };
      norish = {
        enable = cfg.enable;
        masterKeyFile = keyPath "norish" "norish-master-key";
        db.passwordFile = keyPath "norish" "norish-db-password";
        oidc = {
          enable = true;
          clientSecretFile = keyPath "norish" "norish-oidc-client-secret";
        };
      };
      outline = {
        enable = cfg.enable;
        secretKeyFile = keyPath "outline" "outline-secret-key";
        utilsSecretFile = keyPath "outline" "outline-utils-secret";
        db.passwordFile = keyPath "outline" "outline-db-password";
        oidc = {
          enable = true;
          clientSecretFile = keyPath "outline" "outline-oidc-client-secret";
        };
      };
      docker-socket-proxy.enable = cfg.enable;
      homepage.enable = cfg.enable;
      job-ops.enable = cfg.enable;
      networking-toolbox.enable = cfg.enable;
      it-tools.enable = cfg.enable;
      stirling-pdf.enable = cfg.enable;
      mazanoke.enable = cfg.enable;

      lldap = {
        enable = cfg.enable;
        baseDn = "DC=estudioochosiete,DC=xyz";
        jwtSecretFile = keyPath "lldap" "lldap-jwt-secret";
        keySeedFile = keyPath "lldap" "lldap-key-seed";
        adminPasswordFile = keyPath "lldap" "lldap-admin-password";
        bootstrap = {
          cleanUp = false;
          users = {
            julrod = {
              email = "julianrodriguez@estudioochosiete.xyz";
              displayName = "Julian Rodriguez";
              password_file = keyPath "lldap" "lldap-julian-password";
              groups = [
                config.nps.stacks.monitoring.grafana.oidc.adminGroup
                config.nps.stacks.memos.oidc.userGroup
                config.nps.stacks.norish.oidc.adminGroup
                config.nps.stacks.outline.oidc.userGroup
              ];
            };
            cpuerta = {
              email = "cpuerta@estudioochosiete.xyz";
              displayName = "Cristina Puerta";
              password_file = keyPath "lldap" "lldap-cpuerta-password";
              groups = [
                config.nps.stacks.monitoring.grafana.oidc.userGroup
                config.nps.stacks.memos.oidc.userGroup
                config.nps.stacks.norish.oidc.userGroup
                config.nps.stacks.outline.oidc.userGroup
              ];
            };
          };
        };
      };

      authelia = {
        enable = cfg.enable;
        jwtSecretFile = keyPath "authelia" "authelia-jwt-secret";
        sessionSecretFile = keyPath "authelia" "authelia-session-secret";
        storageEncryptionKeyFile = keyPath "authelia" "authelia-storage-encryption-key";
        oidc = {
          enable = true;
          hmacSecretFile = keyPath "authelia" "authelia-oidc-hmac-secret";
          jwksRsaKeyFile = keyPath "authelia" "authelia-oidc-rsa-key";
        };
        settings.notifier = lib.mkForce {
          smtp = {
            address = "smtp://ntfy:25";
            sender = "Authelia <authelia@estudioochosiete.xyz>";
            startup_check_address = "julianrodriguez@estudioochosiete.xyz";
            disable_require_tls = true;
          };
        };
      };

      ntfy = {
        enable = cfg.enable;
        settings = {
          enable-login = true;
          auth-default-access = "deny-all";
          cache-duration = "15m";
          smtp-server-listen = ":25";
          smtp-server-domain = "estudioochosiete.xyz";
          auth-users = [
            ''julrod:{{ file.Read `${keyPath "ntfy" "ntfy-julrod-password-bcrypt"}` }}:user''
            ''cpuerta:{{ file.Read `${keyPath "ntfy" "ntfy-cpuerta-password-bcrypt"}` }}:user''
          ];
          auth-access = [
            "julrod:julianrodriguez:read-only"
            "cpuerta:cpuerta:read-only"
            "julrod:cpuerta:deny"
            "cpuerta:julianrodriguez:deny"
            "*:julianrodriguez:write-only"
            "*:cpuerta:write-only"
          ];
        };
      };

      traefik = {
        enable = cfg.enable;
        domain = "estudioochosiete.xyz";
        extraEnv.CF_DNS_API_TOKEN.fromFile = keyPath "traefik" "traefik-cloudflare-token";
        geoblock.allowedCountries = ["CO"];
        dynamicConfig.http.middlewares.lan.ipAllowList.sourceRange = ["192.168.68.0/22"];
        enablePrometheusExport = true;
        enableGrafanaMetricsDashboard = true;
        enableGrafanaAccessLogDashboard = false;
      };

      monitoring = {
        enable = cfg.enable;
        loki.enable = false;
        alloy.enable = false;
        podmanExporter.enable = false;
        alertmanager.enable = false;
        grafana = {
          enable = true;
          oidc = {
            enable = true;
            clientSecretFile = keyPath "authelia" "authelia-grafana-client-secret";
          };
          datasources = lib.mkForce {
            apiVersion = 1;
            datasources = [
              {
                name = "Prometheus";
                type = "prometheus";
                access = "proxy";
                url = "http://prometheus:9090";
                isDefault = true;
              }
            ];
          };
        };
        prometheus.enable = true;
      };
    };

    services.podman.containers = lib.mkIf cfg.enable (lib.mkMerge [
      {
        prometheus = {
          exec = lib.mkForce ''--config.file=/etc/prometheus/prometheus.yml --storage.tsdb.retention.time=30d --storage.tsdb.retention.size=100GB'';
          volumeMap.data = lib.mkForce "/srv/homelab/prometheus:/prometheus";
          extraConfig = {
            Unit.ConditionPathIsMountPoint = "/srv/homelab";
            Service.ExecStartPre = lib.mkForce [
              "${lib.getExe' pkgs.util-linux "mountpoint"} --quiet /srv/homelab"
            ];
          };
        };

        aiostreams.extraConfig.Unit.ConditionPathExists = keyPath "aiostreams" "aiostreams-secret-key";
        memos.extraConfig.Unit.ConditionPathExists = [
          (keyPath "memos" "memos-db-password")
          (keyPath "memos" "memos-oidc-client-secret")
        ];
        memos.extraEnv.MEMOS_DSN.fromTemplate = lib.mkForce "postgres://memos:{{ file.Read `${keyPath "memos" "memos-db-password"}` | urlquery }}@memos-db/memos?sslmode=disable";
        memos-db.extraConfig.Unit.ConditionPathExists = keyPath "memos" "memos-db-password";
        norish.extraConfig.Unit.ConditionPathExists = [
          (keyPath "norish" "norish-master-key")
          (keyPath "norish" "norish-db-password")
          (keyPath "norish" "norish-oidc-client-secret")
        ];
        norish.extraEnv.DATABASE_URL.fromTemplate = lib.mkForce "postgres://norish:{{ file.Read `${keyPath "norish" "norish-db-password"}` | urlquery }}@norish-db/norish?sslmode=disable";
        norish-db.extraConfig.Unit.ConditionPathExists = keyPath "norish" "norish-db-password";
        outline = {
          dependsOnContainer = [
            "outline-db"
            "outline-redis"
          ];
          extraConfig.Unit.ConditionPathExists = [
            (keyPath "outline" "outline-secret-key")
            (keyPath "outline" "outline-utils-secret")
            (keyPath "outline" "outline-db-password")
            (keyPath "outline" "outline-oidc-client-secret")
          ];
          extraEnv.DATABASE_URL.fromTemplate = lib.mkForce "postgres://outline:{{ file.Read `${keyPath "outline" "outline-db-password"}` | urlquery }}@outline-db/outline";
        };
        outline-db.extraConfig.Unit.ConditionPathExists = keyPath "outline" "outline-db-password";
        traefik.extraConfig.Unit.ConditionPathExists = keyPath "traefik" "traefik-cloudflare-token";
        grafana.extraConfig.Unit.ConditionPathExists = keyPath "authelia" "authelia-grafana-client-secret";
        docker-socket-proxy = {
          network = lib.mkAfter [config.nps.stacks.traefik.network.name];
          ports = lib.mkForce [];
          traefik.name = lib.mkForce null;
        };

        # Authelia already starts after its LLDAP backend; the reverse edge from ForwardAuth is cyclic.
        lldap.wantsContainer = lib.mkForce [];
        authelia.wantsContainer = lib.mkAfter ["ntfy"];
        ntfy = {
          environment.NTFY_UPSTREAM_BASE_URL = lib.mkForce null;
          extraConfig.Unit.ConditionPathExists = [
            (keyPath "ntfy" "ntfy-julrod-password-bcrypt")
            (keyPath "ntfy" "ntfy-cpuerta-password-bcrypt")
          ];
        };
      }
      (lib.mapAttrs (_: image: {
          autoUpdate = lib.mkForce null;
          image = lib.mkForce image;
        })
        qualifiedImages)
      (lib.genAttrs forwardAuthContainers (_: {
        forwardAuth = {
          enable = true;
          rules = [{policy = "two_factor";}];
        };
      }))
      {
        aiostreams.traefik.middleware.lan.enable = true;
      }
    ]);

    systemd.user.sockets = lib.mkIf cfg.enable {
      podman-traefik-80.Socket.ListenDatagram = lib.mkForce [];
      podman-traefik-443.Socket.ListenDatagram = lib.mkForce [];
    };
  };
}
