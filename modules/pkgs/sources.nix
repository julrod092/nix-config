{inputs, ...}: {
  config.dendritic.overlays = {
    unstable-packages = final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    };

    expected-package-revision = final: _prev: {
      expected-rev = rev: system:
        import (builtins.fetchTree {
          type = "github";
          owner = "nixos";
          repo = "nixpkgs";
          inherit rev;
        }) {
          inherit system;
        };
    };
  };
}
