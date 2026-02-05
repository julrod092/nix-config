{ ... }: {

  # Enable networking
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedUDPPorts = [ 24800 4242 ];
      allowedTCPPorts = [ 24800 4242 ];
    };
  };
}
