{
  module = {pkgs, lib, config, ...}: let
    cfg = config.nh.programming;
  in {
    config = lib.mkIf (cfg.enable && cfg.languages.rust.enable) {
      home.packages = with pkgs; [
        rust-analyzer
        rustfmt
      ];
    };
  };

  devShell = pkgs:
    pkgs.mkShell {
      packages = with pkgs; [
        rustc
        cargo
        rustfmt
        clippy
        rust-analyzer
      ];
    };
}
