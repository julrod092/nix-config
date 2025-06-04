{
  pkgs,
  outputs,
  userConfig,
  ...
}: {

  imports = [
    ./dock
  ];
  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };

  # Nix settings
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
    };
    optimise.automatic = true;
    package = pkgs.nix;
  };

  # User configuration
  users.users.${userConfig.name} = {
    name = "${userConfig.name}";
    home = "/Users/${userConfig.name}";
  };

  homebrew = {
    # This is a module from nix-darwin
    # Homebrew is *installed* via the flake input nix-homebrew
    enable = true;
    casks = pkgs.callPackage ./homebrew/casks.nix {};

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
  };

  # Add ability to use TouchID for sudo
  # security.pam.services.sudo_local.touchIdAuth = true;
  environment.variables = {
    EDITOR = "vim";
  };

  # System settings
  system = {
    primaryUser = userConfig.name;
    defaults = {
      CustomUserPreferences = {
        NSGlobalDomain."com.apple.mouse.linear" = true;
      };
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        PMPrintingExpandedStateForPrint = true;
      };
      LaunchServices = {
        LSQuarantine = false;
      };
      trackpad = {
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
        Clicking = true;
      };
      finder = {
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
      };
      dock = {
        autohide = true;
        expose-animation-duration = 0.15;
        show-recents = false;
        showhidden = true;
        persistent-apps = [];
        tilesize = 30;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
      };
      screencapture = {
        location = "/Users/${userConfig.name}/Downloads/temp";
        type = "png";
        disable-shadow = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      # Remap §± to ~
      userKeyMapping = [
        {
          HIDKeyboardModifierMappingDst = 30064771125;
          HIDKeyboardModifierMappingSrc = 30064771172;
        }
      ];
    };
  };

  local = {
    dock.enable = true;
    dock.username = userConfig.name;
    dock.entries = [
      { path = "/Applications/Zen.app/"; }
      { path = "/Applications/Microsoft\ Teams.app/"; }
      { path = "/Applications/AppCleaner.app/"; }
      { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
      { path = "${pkgs.stable.synergy}/Applications/Synergy.app/"; }
      { path = "${pkgs.stable.jetbrains.idea-ultimate}/Applications/IntelliJ\ IDEA.app/"; }
      { path = "${pkgs.stable.zed-editor}/Applications/Zed.app/"; }
      {
        path = "/Users/${userConfig.name}/Downloads";
        section = "others";
        options = "--sort name --view grid --display stack";
      }
      {
        path = "/Users/${userConfig.name}/Applications";
        section = "others";
        options = "--sort name --view grid --display stack";
      }
    ];
  };

  # Zsh configuration
  programs.zsh.enable = true;

  # # Fonts configuration
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.meslo-lg
    nerd-fonts.symbols-only
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 6;
}
