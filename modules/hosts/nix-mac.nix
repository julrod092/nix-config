{config, ...}: let
  repo = config.dendritic;
in {
  config.dendritic = {
    darwinConfigurations.nix-mac = {
      system = "aarch64-darwin";
      user = "julian";
      modules = [
        repo.darwinModules.darwin-base
        {
          system.stateVersion = 6;
        }
      ];
    };

    homeConfigurations."julian@nix-mac" = {
      system = "aarch64-darwin";
      user = "julian";
      host = "nix-mac";
      modules = [
        repo.homeModules.base
        repo.homeModules.terminal
        repo.homeModules.development
        repo.homeModules.utilities
        repo.homeModules.security
        repo.homeModules.browsing
        repo.homeModules.aerospace
      ];
    };
  };
}
