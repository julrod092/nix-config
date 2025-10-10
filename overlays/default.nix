{inputs, ...}: 

{
  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # If a version is needed, this function here can take the revision number of the version
  # and the system. Note: System is already on pkgs, use it from there.
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
