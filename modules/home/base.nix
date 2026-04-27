{config, inputs, ...}: let
  top = config.dendritic;
in {
  config.dendritic.homeModules.base = {
    identity,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
      inputs.nixvim.homeModules.nixvim
    ];

    nixpkgs = {
      overlays = [
        top.overlays.unstable-packages
        top.overlays.expected-package-revision
      ];
      config = top.nixpkgsConfig;
    };

    systemd.user.startServices = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) "sd-switch";

    home = {
      username = identity.user.name;
      homeDirectory =
        if pkgs.stdenv.isDarwin
        then "/Users/${identity.user.name}"
        else "/home/${identity.user.name}";
      stateVersion = "25.11";
      sessionVariables.EDITOR = "nvim";
    };

    programs.home-manager.enable = true;

    catppuccin = {
      flavor = "macchiato";
      accent = "lavender";
    };
  };
}
