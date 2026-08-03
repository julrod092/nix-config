{lib, config, ...}: let
  nixLanguage = import ./languages/nix.nix;
  scalaLanguage = import ./languages/scala.nix;
  rustLanguage = import ./languages/rust.nix;
  goLanguage = import ./languages/go.nix;
in {
  imports = [
    ./common.nix
    ./editors/emacs
    ./editors/neovim
    nixLanguage.module
    scalaLanguage.module
    rustLanguage.module
    goLanguage.module
  ];

  options.nh.programming = {
    enable = lib.mkEnableOption "programming environment";

    common.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install common programming tools.";
    };

    editors = {
      emacs.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Emacs.";
      };
      neovim.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Neovim.";
      };
    };

    languages = {
      nix.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to install Nix development tools.";
      };
      scala.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to install Scala development tools.";
      };
      rust.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to install Rust development tools.";
      };
      go.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to install Go development tools.";
      };
    };
  };
}
