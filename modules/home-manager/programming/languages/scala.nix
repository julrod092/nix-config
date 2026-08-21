{
  module = {
    pkgs,
    lib,
    config,
    ...
  }: let
    cfg = config.nh.programming;
  in {
    config = lib.mkIf (cfg.enable && cfg.languages.scala.enable) {
      home.packages = with pkgs; [
        metals
        scalafmt
      ];
    };
  };

  devShell = pkgs:
    pkgs.mkShell {
      packages = with pkgs; [
        zulu21
        (sbt.override {jre = zulu21;})
        scala-cli
        metals
        scalafmt
      ];
    };
}
