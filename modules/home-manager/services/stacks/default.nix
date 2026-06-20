{
  config,
  lib,
  ...
}: {
  xdg.configFile."containers/storage.conf" = lib.mkForce {
    text = ''
      [storage]
      driver = "overlay"
      graphroot = "${config.home.homeDirectory}/m2/Podman"
      runroot = "/run/user/1000/containers"
    '';
  };

  services.podman.containers = {
    # These containers mount sops-nix secrets at startup.
    aiostreams.dependsOn = ["sops-nix.service"];
    authelia.dependsOn = ["sops-nix.service"];
    lldap.dependsOn = ["sops-nix.service"];
    paperless.dependsOn = ["sops-nix.service"];
    paperless-db.dependsOn = ["sops-nix.service"];
    traefik.dependsOn = ["sops-nix.service"];
    stirling-pdf.dependsOn = ["sops-nix.service"];
    reactive-resume.dependsOn = ["sops-nix.service"];
    job-ops.dependsOn = ["sops-nix.service"];
    tandoor.dependsOn = ["sops-nix.service"];
    tandoor-db.dependsOn = ["sops-nix.service"];
    wallos.dependsOn = ["sops-nix.service"];
    freshrss.dependsOn = ["sops-nix.service"];
    n8n.dependsOn = ["sops-nix.service"];
    trek.dependsOn = ["sops-nix.service"];
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
      adguard.enable = true;
      homeassistant.enable = true;
      networking-toolbox.enable = true;
      it-tools.enable = true;
      n8n.enable = true;
      mazanoke.enable = true;

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
                freshrss.oidc.userGroup
                tandoor.oidc.userGroup
                wallos.oidc.userGroup
                trek.oidc.userGroup
                jotty.oidc.userGroup
              ];
            };
            cpuerta = {
              email = "cpuerta@estudioochosiete.xyz";
              displayName = "Cristina Puerta";
              password_file = config.sops.secrets."lldap/cpuerta_password".path;
              groups = with config.nps.stacks; [
                homebox.oidc.userGroup
                tandoor.oidc.userGroup
                wallos.oidc.userGroup
                trek.oidc.userGroup
                jotty.oidc.userGroup
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
          clientSecretFile = config.sops.secrets."authelia/services/paperless".path;
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
          clientSecretFile = config.sops.secrets."authelia/services/rx_resume".path;
          clientSecretHash = "$pbkdf2-sha512$310000$H9WV2/FSER7SUdTJltfkpQ$F7mBoFWFi7WI6S85ri1ror/M1wkT4/H/c6g5QFQiDGhk7At0friRXgK8py4iRqED5wadtCTq5.5cVPagsPzFHQ";
        };
      };

      job-ops = {
        enable = true;
        extraEnv = {
          LLM_BASE_URL = "http://host.containers.internal:11434";
          LLM_PROVIDER = "ollama";
          MODEL = "qwen3-coder:30b";
        };
        rxResumeApiKeyFile = config.sops.secrets."job-ops/rx_resume_api_key".path;
      };

      freshrss = {
        enable = true;
        oidc = {
          enable = true;
          clientSecretHash = "$pbkdf2-sha512$310000$eKZ0sl3s01gm7gJPXpaqpA$J5rQMe2Km8/1BSiilSteLS8QqJg2EqPQnCq450JZLobZIUWF0F.L4nek0nMlTTcLf/LrPDk1/AUJ.Th3dKecEg";
          clientSecretFile = config.sops.secrets."authelia/services/freshrss".path;
          cryptoKeyFile = config.sops.secrets."freshrss/authelia_crypto_key".path;
        };
      };

      tandoor = {
        enable = true;

        secretKeyFile = config.sops.secrets."tandoor/secret_key".path;
        db.passwordFile = config.sops.secrets."tandoor/db_password".path;

        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."authelia/services/tandoor".path;
          clientSecretHash = "$pbkdf2-sha512$310000$Jn3mVBKwxGdVO0SwnnB7tQ$xw0Irb7RnbCE1PcC28TUAnl.2lLuLSCjemGZJeRbCBViz3qwtbwoBDn3a1QtQPKgnxb50QFY8yZodvDnsp4nrw";
        };

        containers.tandoor.extraEnv = {
          # https://docs.tandoor.dev/system/configuration/#default-permissions
          SOCIAL_DEFAULT_ACCESS = 1;
          SOCIAL_DEFAULT_GROUP = "user";
        };
      };

      wallos = {
        enable = true;
        oidc = {
          registerClient = true;
          clientSecretHash = "$pbkdf2-sha512$310000$HbyoXa5PfRRiOMXny2Q03A$2PNmEypjh0KcPVewrFTSKkoHsyuK0rkLWSWrTeNkQRxU9tD2GeXjOlIjes9UbxOx85SaP9dzyivMC4u.BlBCfQ";
        };
      };

      trek = {
        enable = true;
        oidc = {
          enable = true;
          clientSecretHash = "$pbkdf2-sha512$310000$Y1/SmpPFGRxuxsuw5jZAjw$BRty46BFUPnnC/eSd/fBW6YKTe3m5x0Uv8tI3TfNlJok19Nev1WINfYwdPrMa40uQerDw8pYSborlkoIpaWzGw";
          clientSecretFile = config.sops.secrets."authelia/services/trek".path;
        };
      };

      jotty = {
        enable = true;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."authelia/services/jotty".path;
          clientSecretHash = "$pbkdf2-sha512$310000$LLzzqfk2YcLNvTtTbCYq7g$JHSQ0Dm5KAutsAHI8BhjM1BLmtrOMnL39Z8NF0DHDvXK8tdhzOdDBuF35hMWWZktEs0AGW9y.o2iQQhX.tBv/A";
        };
      };
    };
  };
}
