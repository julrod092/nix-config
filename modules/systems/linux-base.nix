{config, inputs, ...}: let
  top = config.dendritic;
in {
  config.dendritic.nixosModules.linux-base = {
    config,
    identity,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      inputs.nixflix.nixosModules.default
    ];

    nixpkgs = {
      overlays = [ top.overlays.unstable-packages ];
      config = top.nixpkgsConfig;
    };

    nix.registry = lib.mapAttrs (_: flake: { inherit flake; }) (lib.filterAttrs (_: lib.isType "flake") inputs);
    nix.nixPath = [
      "/etc/nix/path"
      "nixpkgs=flake:nixpkgs"
    ];

    environment.etc =
      lib.mapAttrs' (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      })
      config.nix.registry;

    nix.settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };

    boot = {
      kernelParams = ["quiet" "splash" "rd.udev.log_level=3"];
      initrd.verbose = false;
      loader = {
        timeout = 10;
        systemd-boot = {
          enable = true;
          configurationLimit = 5;
        };
        efi.canTouchEfiVariables = true;
      };
      plymouth.enable = true;
    };

    systemd.services = {
      NetworkManager-wait-online.enable = false;
      plymouth-quit-wait.enable = false;
    };

    time = {
      timeZone = "America/Bogota";
      hardwareClockInLocalTime = true;
    };

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

    services.libinput.enable = true;
    services.xserver.excludePackages = with pkgs; [ xterm ];

    environment = {
      localBinInPath = true;
      variables.EDITOR = "nvim";
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XCURSOR_SIZE = "24";
      };
    };

    security.rtkit.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
    };

    services = {
      printing.enable = false;
      devmon.enable = true;
      pulseaudio.enable = false;

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      pcscd.enable = true;
      udev.packages = [ pkgs.yubikey-personalization ];
      openssh.enable = true;
    };

    users.users.${identity.user.name} = {
      description = identity.user.fullName;
      extraGroups = ["networkmanager" "wheel" "docker" "input"];
      isNormalUser = true;
      shell = pkgs.zsh;
    };

    system.activationScripts.setUserAvatar.text = ''
      mkdir -p /var/lib/AccountsService/{icons,users}
      cp ${identity.user.avatar} /var/lib/AccountsService/icons/${identity.user.name}

      touch /var/lib/AccountsService/users/${identity.user.name}

      if ! grep -q "^Icon=" /var/lib/AccountsService/users/${identity.user.name}; then
        if ! grep -q "^\[User\]" /var/lib/AccountsService/users/${identity.user.name}; then
          echo "[User]" >> /var/lib/AccountsService/users/${identity.user.name}
        fi
        echo "Icon=/var/lib/AccountsService/icons/${identity.user.name}" >> /var/lib/AccountsService/users/${identity.user.name}
      fi
    '';

    environment.systemPackages = with pkgs; [
      alejandra
      gcc
      gnumake
      killall
      libei
      libportal
      ffmpeg
    ];

    programs.zsh.enable = true;

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
      roboto
    ];
  };
}
