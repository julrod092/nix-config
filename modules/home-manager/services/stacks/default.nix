{config, ...}: {
  services.podman.containers = {
    # These containers mount sops-nix secrets at startup.
    aiostreams.dependsOn = ["sops-nix.service"];
    authelia.dependsOn = ["sops-nix.service"];
    lldap.dependsOn = ["sops-nix.service"];
    paperless.dependsOn = ["sops-nix.service"];
    paperless-db.dependsOn = ["sops-nix.service"];
    traefik.dependsOn = ["sops-nix.service"];
  };

  nps = {
    defaultTz = "America/Bogota";
    hostIP4Address = "192.168.68.58";
    storageBaseDir = "${config.home.homeDirectory}/m2/stacks/volumes";
    externalStorageBaseDir = "${config.home.homeDirectory}/m2/stacks";

    stacks = {
      homepage.enable = true;
      docker-socket-proxy.enable = true;
      monitoring.enable = true;
      bentopdf.enable = true;

      aiostreams = {
        enable = true;
        secretKeyFile = config.sops.secrets."aiostreams/secret_key".path;
      };

      authelia = {
        enable = true;
        jwtSecretFile = config.sops.secrets."authelia/jwt_secret".path;
        sessionSecretFile = config.sops.secrets."authelia/session_secret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/encryption_key".path;
        oidc = {
          enable = true;
          hmacSecretFile = config.sops.secrets."authelia/oidc_hmac_secret".path;
          jwksRsaKeyFile = config.sops.secrets."authelia/oidc_rsa_pk".path;
        };
      };

      blocky = {
        enable = true;
        enableGrafanaDashboard = true;
        enablePrometheusExport = true;
        containers.blocky = {
          # When clicking the Blocky icon in the homepage, it will redirect to the Grafana dashboard.
          homepage.settings.href = "${config.nps.containers.grafana.traefik.serviceUrl}/d/blocky";
        };
      };

      lldap = {
        enable = true;
        baseDn = "DC=estudioochosiete,DC=xyz";
        jwtSecretFile = config.sops.secrets."lldap/jwt_secret".path;
        keySeedFile = config.sops.secrets."lldap/key_seed".path;
        adminPasswordFile = config.sops.secrets."lldap/admin_password".path;
        bootstrap = {
          cleanUp = true;
          users = {
            julrod = {
              email = "julianrodriguez@estudioochosiete.xyz";
              displayName = "Julian Rodriguez";
              password_file = config.sops.secrets."lldap/julian_password".path;
              groups = with config.nps.stacks; [
                paperless.oidc.userGroup
              ];
            };
          };
        };
      };

      traefik = {
        enable = true;
        domain = "estudioochosiete.xyz";
        extraEnv = {
          CF_DNS_API_TOKEN.fromFile = config.sops.secrets."traefik/cf_api_token".path;
        };
        geoblock.allowedCountries = ["CO"];
        enablePrometheusExport = true;
        enableGrafanaMetricsDashboard = true;
        enableGrafanaAccessLogDashboard = true;
      };

      paperless = {
        enable = true;
        adminProvisioning = {
          username = "julrod";
          email = "julianrodriguez@estudioochosiete.xyz";
          passwordFile = config.sops.secrets."paperless/admin_password".path;
        };
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."paperless/authelia_client_secret".path;
        };
        secretKeyFile = config.sops.secrets."paperless/secret_key".path;
        db = {
          passwordFile = config.sops.secrets."paperless/db_password".path;
        };
      };
    };
  };
}
