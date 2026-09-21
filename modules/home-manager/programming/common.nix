{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.nh.programming;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  config = lib.mkIf (cfg.enable && cfg.common.enable) {
    home.packages = with pkgs;
      [
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
        smithy-cli
        unstable.localstack
        unstable.vscode
        unstable.pi-coding-agent
      ]
      ++ lib.lists.optionals isDarwin [
        colima
        docker
        docker-compose
        (expected-rev "5d5288fa1b2665243a1fd5dd99703077d25d4218" "${pkgs.stdenv.hostPlatform.system}").nodejs_24
        unstable.awscli2
      ]
      ++ lib.lists.optionals (!isDarwin) [
        codecrafters-cli
        python314
      ];

    home.file = {
      "jdks/zulu8".source = pkgs.zulu8;
      "jdks/zulu11".source = pkgs.zulu11;
      "jdks/zulu21".source = pkgs.zulu21;
    };

    home.sessionVariables.JAVA_HOME = "${pkgs.zulu21}";
  };
}
