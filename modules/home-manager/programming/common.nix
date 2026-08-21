{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.nh.programming;
in {
  config = lib.mkIf (cfg.enable && cfg.common.enable) {
    home.packages = with pkgs; [
      unstable.jetbrains.idea
      zulu21
      bash-language-server
      shellcheck
      shfmt
      marksman
      markdownlint-cli
      mdformat
      taplo
      vscode-langservers-extracted
      yaml-language-server
      yamlfmt
      yamllint
      treefmt
      unstable.devenv
    ];

    home.file = {
      "jdks/zulu8".source = pkgs.zulu8;
      "jdks/zulu11".source = pkgs.zulu11;
      "jdks/zulu21".source = pkgs.zulu21;
    };

    home.sessionVariables.JAVA_HOME = "${pkgs.zulu21}";
  };
}
