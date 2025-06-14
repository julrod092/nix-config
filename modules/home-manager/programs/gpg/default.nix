{
  pkgs,
  lib,
  ...
}: {
  # Install gpg via home-manager module

  home.packages = with pkgs; [
    # Yubikey
    yubikey-manager
    # yubikey-manager-qt
    # yubikey-personalization
    # yubikey-personalization-gui
    yubico-piv-tool
    yubioath-flutter
    # yubikeyGuide

    # Password generation tools
    rng-tools

    # Other tools
    cfssl
    pcsctools
  ];

  programs.gpg = {
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

  services.gpg-agent = lib.mkIf (!pkgs.stdenv.isDarwin) {
    enable = true;
    defaultCacheTtl = 60;
    enableSshSupport = true;
    maxCacheTtlSsh = 120;
    pinentry.package = pkgs.pinentry-gnome3;
    enableScDaemon = true;
  };
}
