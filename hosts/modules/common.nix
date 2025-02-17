{
  inputs,
  outputs,
  lib,
  config,
  userConfig,
  pkgs,
  ...
}: {
  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };

  # Register flake inputs for nix commands
  nix.registry = lib.mapAttrs (_: flake: {inherit flake;}) (lib.filterAttrs (_: lib.isType "flake") inputs);

  # Add inputs to legacy channels
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs' (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  # Nix settings
  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  # Boot settings
  boot = {
    kernelParams = ["quiet" "splash"];
    loader = {
        timeout = 10;
        systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # Timezone
  time = {
    timeZone = "America/Bogota";
    hardwareClockInLocalTime = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_CO.UTF-8";
    LC_IDENTIFICATION = "es_CO.UTF-8";
    LC_MEASUREMENT = "es_CO.UTF-8";
    LC_MONETARY = "es_CO.UTF-8";
    LC_NAME = "es_CO.UTF-8";
    LC_NUMERIC = "es_CO.UTF-8";
    LC_PAPER = "es_CO.UTF-8";
    LC_TELEPHONE = "es_CO.UTF-8";
    LC_TIME = "es_CO.UTF-8";
  }; 

  # Input settings
  services.libinput.enable = true;

  # X11 settings
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
    excludePackages = with pkgs; [xterm];
    displayManager.gdm.enable = true;
  };

  # PATH configuration
  environment = {
    localBinInPath = true;
    variables.EDITOR = "neovim";
  };

  # Disable CUPS printing
  services.printing.enable = false;

  # Enable devmon for device management
  services.devmon.enable = true;

  # Enable PipeWire for sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    configPackages = [
      (pkgs.writeTextDir "share/alsa-card-profile/mixer/paths/razer-nari-input.conf" ''
        [General]
        description-key = analog-input-microphone-headset

        [Element Headset]
        volume = merge
        switch = mute
        override-map.1 = all
        override-map.2 = all-left,all-right
      '')
      (pkgs.writeTextDir "share/alsa-card-profile/mixer/paths/razer-nari-output-game.conf" ''
        [General]
        priority = 99
        description-key = steelseries-arctis-output-game-common

        [Element PCM]
        switch = mute
        volume = merge
      '')
      (pkgs.writeTextDir "share/alsa-card-profile/mixer/profile-sets/razer-nari-usb-audio.conf" ''
        [General]
        auto-profiles = yes

        [Mapping analog-chat]
        description = Chat
        device-strings = hw:%f,0,0
        channel-map = mono
        paths-input = razer-nari-input
        paths-output = razer-nari-output-chat

        [Mapping analog-game]
        description = Game
        device-strings = hw:%f,1,0
        channel-map = left,right
        paths-output = razer-nari-output-game
        direction = output

        [Profile output:analog-chat+output:analog-game+input:analog-chat]
        output-mappings = analog-chat analog-game
        input-mappings = analog-chat
        priority = 5100
        skip-probe = yes
      '')
      (pkgs.writeTextDir "lib/udev/rules.d/91-pulseaudio-razer-nari.rules" ''
        ATTRS{idVendor}=="1532", ATTRS{idProduct}=="051a", ENV{ACP_PROFILE_SET}="razer-nari-usb-audio.conf"
        ATTRS{idVendor}=="1532", ATTRS{idProduct}=="051c", ENV{ACP_PROFILE_SET}="razer-nari-usb-audio.conf"
        ATTRS{idVendor}=="1532", ATTRS{idProduct}=="051d", ENV{ACP_PROFILE_SET}="razer-nari-usb-audio.conf"
      '')
    ];
  };

  # User configuration
  users.users.${userConfig.name} = {
    description = userConfig.fullName;
    extraGroups = ["networkmanager" "wheel" "docker"];
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    delta
    dig
    du-dust
    eza
    fd
    jq
    killall
    kubectl
    lazydocker
    mesa
    nh
    openconnect
    pavucontrol
    pipenv
    pulseaudio
    qt6.qtwayland
    ripgrep
    unzip
    wl-clipboard
    home-manager
  ];

  # Zsh configuration
  programs.zsh.enable = true;

  # # Fonts configuration
  # nerdFonts = with (pkgs.nerd-fonts); [
  #   jetbrains-mono
  #   meslo
  # ];

  # Additional services
  services.locate.enable = true;

  # OpenSSH daemon
  services.openssh.enable = true;
}
