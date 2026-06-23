{
  lib,
  pkgs,
  ...
}: {
  # Enable networking
  networking = {
    extraHosts = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) ''
      127.0.0.1 paradise-s1.battleye.com
      127.0.0.1 test-s1.battleye.com
      127.0.0.1 paradiseenhanced-s1.battleye.com
    '';
    networkmanager = {
      enable = true;
      insertNameservers = ["192.168.68.58"];
    };
    firewall = {
      enable = true;
      allowedUDPPorts = [53 80 443 24800 5212];
      allowedTCPPorts = [53 80 443 24800 5212];
    };
  };
}
