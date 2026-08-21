{
  lib,
  pkgs,
  self,
}: let
  encryptedBundle = "${self}/home/julrod/secrets.yaml";
  readSecret = "${self}/scripts/fleet-read-secret";
  bcryptSecret = "${self}/scripts/fleet-bcrypt-secret";

  mkKey = {
    extract,
    service,
  }: {
    keyCommand = [
      "/run/current-system/sw/bin/bash"
      readSecret
      extract
      encryptedBundle
    ];
    destDir = "/var/lib/nix-fleet/secrets/${service}";
    user = "root";
    group = "homelab";
    permissions = "0440";
    uploadAt = "pre-activation";
  };

  mkBcryptKey = {
    extract,
    service,
  }:
    (mkKey {inherit extract service;})
    // {
      keyCommand = [
        "/run/current-system/sw/bin/bash"
        bcryptSecret
        readSecret
        (lib.getExe' pkgs.apacheHttpd "htpasswd")
        extract
        encryptedBundle
      ];
    };
in {
  aiostreams-secret-key = mkKey {
    service = "aiostreams";
    extract = ''["aiostreams"]["secret_key"]'';
  };

  memos-db-password = mkKey {
    service = "memos";
    extract = ''["memos"]["db_password"]'';
  };
  memos-oidc-client-secret = mkKey {
    service = "memos";
    extract = ''["memos"]["oidc_client_secret"]'';
  };

  norish-master-key = mkKey {
    service = "norish";
    extract = ''["norish"]["master_key"]'';
  };
  norish-db-password = mkKey {
    service = "norish";
    extract = ''["norish"]["db_password"]'';
  };
  norish-oidc-client-secret = mkKey {
    service = "norish";
    extract = ''["norish"]["oidc_client_secret"]'';
  };

  outline-secret-key = mkKey {
    service = "outline";
    extract = ''["outline"]["secret_key"]'';
  };
  outline-utils-secret = mkKey {
    service = "outline";
    extract = ''["outline"]["utils_secret"]'';
  };
  outline-db-password = mkKey {
    service = "outline";
    extract = ''["outline"]["db_password"]'';
  };
  outline-oidc-client-secret = mkKey {
    service = "outline";
    extract = ''["outline"]["oidc_client_secret"]'';
  };

  authelia-jwt-secret = mkKey {
    service = "authelia";
    extract = ''["authelia"]["jwt_secret"]'';
  };
  authelia-session-secret = mkKey {
    service = "authelia";
    extract = ''["authelia"]["session_secret"]'';
  };
  authelia-storage-encryption-key = mkKey {
    service = "authelia";
    extract = ''["authelia"]["encryption_key"]'';
  };
  authelia-oidc-hmac-secret = mkKey {
    service = "authelia";
    extract = ''["authelia"]["oidc_hmac_secret"]'';
  };
  authelia-oidc-rsa-key = mkKey {
    service = "authelia";
    extract = ''["authelia"]["oidc_rsa_pk"]'';
  };
  authelia-grafana-client-secret = mkKey {
    service = "authelia";
    extract = ''["authelia"]["services"]["homelable"]'';
  };

  lldap-key-seed = mkKey {
    service = "lldap";
    extract = ''["lldap"]["key_seed"]'';
  };
  lldap-jwt-secret = mkKey {
    service = "lldap";
    extract = ''["lldap"]["jwt_secret"]'';
  };
  lldap-admin-password = mkKey {
    service = "lldap";
    extract = ''["lldap"]["admin_password"]'';
  };
  lldap-julian-password = mkKey {
    service = "lldap";
    extract = ''["lldap"]["julian_password"]'';
  };
  lldap-cpuerta-password = mkKey {
    service = "lldap";
    extract = ''["lldap"]["cpuerta_password"]'';
  };

  ntfy-julrod-password-bcrypt = mkBcryptKey {
    service = "ntfy";
    extract = ''["lldap"]["julian_password"]'';
  };
  ntfy-cpuerta-password-bcrypt = mkBcryptKey {
    service = "ntfy";
    extract = ''["lldap"]["cpuerta_password"]'';
  };

  traefik-cloudflare-token = mkKey {
    service = "traefik";
    extract = ''["traefik"]["cf_api_token"]'';
  };
}
