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
      outputs.overlays.unstable-packages
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
    initrd.verbose = false;
    loader = {
      timeout = 10;
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
#      grub = {
#        enable = true;
#        version = 2;
#        device = "nodev";
#        efiSupport = true;
#        useOSProber = true;
#      };
    };
    plymouth.enable = true;
  };

  # Disable systemd services that are affecting the boot time
  systemd.services = {
    NetworkManager-wait-online.enable = false;
    plymouth-quit-wait.enable = false;
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

  # PATH configuration
  environment = {
    localBinInPath = true;
    variables.EDITOR = "nvim";
  };
  
  security.rtkit.enable = true;

  services = {
    # Disable CUPS printing
    printing.enable = false;
    
    # Enable devmon for device management
    devmon.enable = true;

    # Enable PipeWire for sound
    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Enable PC/SC daemon for YubiKey support
    pcscd.enable = true;
    udev.packages = [pkgs.yubikey-personalization];

    # Additional services
    locate.enable = true;

    # OpenSSH daemon
    openssh.enable = true;
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
    gcc
    glib
    gnumake
    killall
    ly
    mesa
  ];

  # Zsh configuration
  programs.zsh.enable = true;

  # Fonts configuration
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    roboto
  ];
}
