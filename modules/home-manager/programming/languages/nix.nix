{
  module = {pkgs, lib, config, ...}: let
    cfg = config.nh.programming;
  in {
    config = lib.mkIf (cfg.enable && cfg.languages.nix.enable) {
      home.packages = with pkgs; [
        alejandra
        deadnix
        nil
        statix
      ];
    };
  };

  devShell = pkgs:
    pkgs.mkShell {
      packages = with pkgs; [
        alejandra
        deadnix
        nil
        statix
      ];
    };
}
