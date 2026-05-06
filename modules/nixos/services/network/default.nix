{...}: {
  # Enable networking
  networking = {
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
