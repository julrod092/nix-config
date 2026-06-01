{
  pkgs,
  lib,
  ...
}: let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  pinentryPackage =
    if isDarwin
    then pkgs.pinentry_mac
    else pkgs.pinentry-gnome3;
in {
  # Install gpg via home-manager module

  home.packages = with pkgs;
    [
      yubikey-manager
      yubico-piv-tool

      # Other tools
      cfssl
      pcsc-tools
    ]
    ++ lib.lists.optionals (!isDarwin) [
      yubioath-flutter
      # Password generation tools
      rng-tools
      pinentry-gnome3
    ]
    ++ lib.lists.optionals isDarwin [
      pinentry_mac
    ];

  programs = {
    gpg = {
      enable = true;
      scdaemonSettings = {
        disable-ccid = true;
      };
      settings = {
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        charset = "utf-8";
        fixed-list-mode = true;
        no-comments = true;
        no-emit-version = true;
        no-greeting = true;
        keyid-format = "0xlong";
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";
        with-key-origin = true;
        with-fingerprint = true;
        require-cross-certification = true;
        require-secmem = true;
        no-symkey-cache = true;
        armor = true;
        use-agent = true;
        throw-keyids = true;
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 60;
    enableSshSupport = true;
    maxCacheTtlSsh = 120;
    enableScDaemon = true;
    pinentry.package = pinentryPackage;
  };
}
