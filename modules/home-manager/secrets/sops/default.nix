{
  config,
  pkgs,
  hostname,
  userConfig,
  lib,
  ...
}: let
  secretsPath = "${config.home.homeDirectory}/.config/sops/secrets";

  macos = {
    secrets = lib.genAttrs [
      "GITHUB_NPM_KEY"
      "GITHUB_REPO_ACCESS"
      "localstack"
    ] (s: {});
    templates = {};
  };

  desktop = {
    secrets =
      {
        "gpg-ssh-key" = {path = "${config.home.homeDirectory}/.ssh/id_rsa.pub";};
        "localstack" = {};
      }
      // lib.genAttrs [
        "authelia/jwt_secret"
        "authelia/session_secret"
        "authelia/encryption_key"
        "authelia/oidc_hmac_secret"
        "authelia/oidc_rsa_pk"
        "authelia/services/trek"
        "authelia/services/tandoor"
        "authelia/services/freshrss"
        "authelia/services/rx_resume"
        "authelia/services/paperless"
        "authelia/services/jotty"
        "authelia/services/wallos"
        "authelia/services/homelable"
        "aiostreams/secret_key"
        "lldap/key_seed"
        "lldap/jwt_secret"
        "lldap/admin_password"
        "lldap/julian_password"
        "lldap/cpuerta_password"
        "paperless/admin_password"
        "paperless/secret_key"
        "paperless/db_password"
        "traefik/cf_api_token"
        "rx_resume/auth_secret"
        "rx_resume/db_password"
        "job-ops/rx_resume_api_key"
        "freshrss/authelia_crypto_key"
        "tandoor/secret_key"
        "tandoor/db_password"
        "homelable/secret_key"
      ] (s: {});
    templates = {};
  };
in {
  sops = {
    defaultSymlinkPath = secretsPath;
    defaultSopsFile = ./../../../../home/${userConfig.name}/secrets.yaml;
    gnupg.home = "${config.home.homeDirectory}/.gnupg";

    secrets =
      lib.optionalAttrs pkgs.stdenv.isDarwin macos.secrets
      // (lib.optionalAttrs (hostname == "nix-desktop") desktop.secrets);

    templates =
      lib.optionalAttrs pkgs.stdenv.isDarwin macos.templates
      // (lib.optionalAttrs (hostname == "nix-desktop") desktop.templates);
  };
}
