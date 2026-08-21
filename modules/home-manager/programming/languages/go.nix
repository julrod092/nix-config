{
  module = {
    pkgs,
    lib,
    config,
    ...
  }: let
    cfg = config.nh.programming;
  in {
    config = lib.mkIf (cfg.enable && cfg.languages.go.enable) {
      home.packages = with pkgs; [
        gopls
        gofumpt
      ];
    };
  };

  devShell = pkgs:
    pkgs.mkShell {
      packages = with pkgs; [
        go
        gopls
        delve
        gofumpt
        gosimports
        golangci-lint
      ];
    };
}
