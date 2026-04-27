{...}: {
  config.dendritic.homeModules.security = {
    lib,
    pkgs,
    ...
  }: let
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  in {
    home.packages = with pkgs;
      [
        yubikey-manager
        yubico-piv-tool
        cfssl
        pcsc-tools
      ]
      ++ lib.optionals (!isDarwin) [
        yubioath-flutter
        rng-tools
      ];

    programs.gpg = {
      enable = true;
      scdaemonSettings.disable-ccid = true;
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

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = lib.mkIf isDarwin {
        work = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/ncl-ssh";
        };
      };
    };

    programs.zsh.localVariables = lib.mkIf (!isDarwin) {
      SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
    };

    services.gpg-agent = lib.mkIf (!isDarwin) {
      enable = true;
      defaultCacheTtl = 60;
      enableSshSupport = true;
      maxCacheTtlSsh = 120;
      pinentry.package = pkgs.pinentry-gnome3;
      enableScDaemon = true;
    };
  };
}
