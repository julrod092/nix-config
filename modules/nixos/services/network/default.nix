{...}: {
  # Enable networking
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedUDPPorts = [24800];
      allowedTCPPorts = [24800];
    };
  };
}
