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
    then "${config.users.users.${userConfig.name}.home}/.config/sops/secrets"
    else "/run/user/1000/secrets";

  macos = {};

  desktop = {
    secrets = lib.genAttrs [
      "authelia/jwt_secret"
      "authelia/session_secret"
      "authelia/encryption_key"
      "authelia/oidc_hmac_secret"
      "authelia/oidc_rsa_pk"
      "aiostreams/secret_key"
      "lldap/key_seed"
      "lldap/jwt_secret"
      "lldap/admin_password"
      "lldap/julian_password"
      "paperless/admin_password"
      "paperless/secret_key"
      "paperless/authelia_client_secret"
      "paperless/db_password"
      "traefik/cf_api_token"
    ] (s: {});
    templates = {};
  };
in {
  sops = {
    defaultSymlinkPath = secretsPath;
    defaultSopsFile = ./../../../../home/${userConfig.name}/${hostname}/secrets.yaml;
    gnupg.home = "${config.home.homeDirectory}/.gnupg";

    secrets =
      lib.optionalAttrs pkgs.stdenv.isDarwin macos.secrets
      // (lib.optionalAttrs (hostname == "nix-desktop") desktop.secrets);

    templates =
      lib.optionalAttrs pkgs.stdenv.isDarwin macos.templates
      // (lib.optionalAttrs (hostname == "nix-desktop") desktop.templates);
  };
}
