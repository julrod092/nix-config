let
  julrod = {
    avatar = ../files/avatar;
    wallpaper = ../files/wallpaper.jpg;
    email = "jrodriguezrpo@pm.me";
    fullName = "Julian Rodriguez";
    gitKey = "BB07BC58D5058FD9";
    name = "julrod";
  };
in {
  users = {
    inherit julrod;

    julian = {
      inherit (julrod) avatar fullName;
      email = "jandresrodriguez@nclcorp.com";
      gitKey = "";
      name = "julian";
    };

    homelab = {
      email = "";
      fullName = "Homelab Services";
      gitKey = "";
      name = "homelab";
    };
  };

  hosts = {
    nix-desktop = {
      system = "x86_64-linux";
      platform = "nixos";
      homeUser = "julrod";
      roles = ["workstation" "controller"];
      tags = ["nixos" "workstation" "controller" "x86_64"];
      deployment = {
        backend = "colmena-local";
        targetHost = null;
      };
    };

    prime-mini = {
      system = "aarch64-linux";
      platform = "nixos";
      homeUser = "homelab";
      roles = ["server" "homelab" "apple-silicon"];
      tags = ["nixos" "server" "homelab" "aarch64"];
      deployment = {
        backend = "colmena-remote";
        targetHost = "192.168.68.56";
        targetUser = "deploy";
        buildOnTarget = true;
        sshOptions = [
          "-o"
          "ControlMaster=auto"
          "-o"
          "ControlPersist=10m"
          "-o"
          "ControlPath=/tmp/colmena-%C"
        ];
      };
    };

    nix-mac = {
      system = "aarch64-darwin";
      platform = "darwin";
      homeUser = "julian";
      roles = ["workstation"];
      tags = ["darwin" "workstation" "aarch64"];
      deployment.backend = "manual";
    };
  };
}
