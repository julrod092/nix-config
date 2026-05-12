{config, ...}: {
  services.podman.containers = {
    # These containers mount sops-nix secrets at startup.
    aiostreams.dependsOn = ["NetworkManager" "sops-nix.service"];
    authelia.dependsOn = ["NetworkManager" "sops-nix.service"];
    lldap.dependsOn = ["NetworkManager" "sops-nix.service"];
    paperless.dependsOn = ["NetworkManager" "sops-nix.service"];
    paperless-db.dependsOn = ["NetworkManager" "sops-nix.service"];
    traefik.dependsOn = ["NetworkManager" "sops-nix.service"];
    stirling-pdf.dependsOn = ["NetworkManager" "sops-nix.service"];
    reactive-resume.dependsOn = ["NetworkManager" "sops-nix.service"];
    job-ops.dependsOn = ["NetworkManager" "sops-nix.service"];
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
      adguard.enable = true;
      homeassistant.enable = true;
      networking-toolbox.enable = true;
      n8n.enable = true;
      it-tools.enable = true;

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
                reactive-resume.oidc.userGroup
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

      # Media

      aiostreams = {
        enable = true;
        secretKeyFile = config.sops.secrets."aiostreams/secret_key".path;
      };

      paperless = {
        enable = true;
        adminProvisioning = {
          username = "admin";
          email = "admin@estudioochosiete.xyz";
          passwordFile = config.sops.secrets."paperless/admin_password".path;
        };
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."paperless/authelia_client_secret".path;
        };
        secretKeyFile = config.sops.secrets."paperless/secret_key".path;
        db.passwordFile = config.sops.secrets."paperless/db_password".path;
      };

      stirling-pdf = {
        enable = true;
      };

      reactive-resume = {
        enable = true;
        authSecretFile = config.sops.secrets."rx_resume/auth_secret".path;
        db.passwordFile = config.sops.secrets."rx_resume/db_password".path;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."rx_resume/authelia_client_secret".path;
          clientSecretHash = "$pbkdf2-sha512$310000$H9WV2/FSER7SUdTJltfkpQ$F7mBoFWFi7WI6S85ri1ror/M1wkT4/H/c6g5QFQiDGhk7At0friRXgK8py4iRqED5wadtCTq5.5cVPagsPzFHQ";
        };
      };

      job-ops = {
        enable = true;
        rxResumeApiKeyFile = config.sops.secrets."job-ops/rx_resume_api_key".path;
      };
    };
  };
}
