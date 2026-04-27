{config, inputs, ...}: let
  repo = config.dendritic;
in {
  config.dendritic = {
    nixosConfigurations.nix-desktop = {
      system = "x86_64-linux";
      user = "julrod";
      modules = [
        inputs.hardware.nixosModules.common-cpu-amd
        inputs.hardware.nixosModules.common-pc-ssd
        inputs.disko.nixosModules.disko
        repo.nixosModules.nix-desktop-storage
        repo.nixosModules.nix-desktop-hardware
        repo.nixosModules.linux-base
        repo.nixosModules.gnome
        repo.nixosModules.niri
        repo.nixosModules.nvidia
        repo.nixosModules.network
        repo.nixosModules.podman
        repo.nixosModules.nh
        repo.nixosModules.steam
        {
          networking.hostName = "nix-desktop";
          systemd.tmpfiles.rules = [
            "d /home/julrod/m2 0775 julrod users - -"
          ];
          system.stateVersion = "25.11";
        }
      ];
    };

    homeConfigurations."julrod@nix-desktop" = {
      system = "x86_64-linux";
      user = "julrod";
      host = "nix-desktop";
      modules = [
        repo.homeModules.base
        repo.homeModules.terminal
        repo.homeModules.development
        repo.homeModules.utilities
        repo.homeModules.security
        repo.homeModules.browsing
        repo.homeModules.niri
      ];
    };
  };
}
