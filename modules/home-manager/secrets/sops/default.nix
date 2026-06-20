{
  config,
  pkgs,
  hostname,
  userConfig,
  lib,
  ...
}: let
  secretsPath =
    if pkgs.stdenv.isDarwin
    then "${config.home.homeDirectory}/.config/sops/secrets"
    else "/run/user/1000/secrets";

  macos = {
    secrets = lib.genAttrs [
      "GITHUB_NPM_KEY"
      "GITHUB_REPO_ACCESS"
    ] (s: {});
    templates = {};
  };

  desktop = {
    secrets = lib.genAttrs [
      "authelia/jwt_secret"
      "authelia/session_secret"
      "authelia/encryption_key"
      "authelia/oidc_hmac_secret"
      "authelia/oidc_rsa_pk"
      "authelia/services/trek"
      "aiostreams/secret_key"
      "lldap/key_seed"
      "lldap/jwt_secret"
      "lldap/admin_password"
      "lldap/julian_password"
      "lldap/cpuerta_password"
      "paperless/admin_password"
      "paperless/secret_key"
      "paperless/authelia_client_secret"
      "paperless/db_password"
      "traefik/cf_api_token"
      "rx_resume/auth_secret"
      "rx_resume/db_password"
      "rx_resume/authelia_client_secret"
      "job-ops/rx_resume_api_key"
      "freshrss/authelia_client_secret"
      "freshrss/authelia_crypto_key"
      "tandoor/secret_key"
      "tandoor/db_password"
      "tandoor/authelia_client_secret"
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
