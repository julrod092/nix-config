{inputs, ...}: 

{
  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  expected-package-revision = final: _prev: {
    expected-rev = rev: _system:
      import (builtins.fetchTree {
        type = "github";
        owner = "nixos";
        repo = "nixpkgs";
        rev = "${rev}";
      }) {
        system = "${_system}"; 
      };
  };
}
