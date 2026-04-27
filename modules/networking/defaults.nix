{...}: {
  config.dendritic.nixosModules.network = {
    ...
  }: {
    networking = {
      networkmanager.enable = true;
      firewall = {
        enable = true;
        allowedUDPPorts = [24800 5212];
        allowedTCPPorts = [24800 5212];
      };
    };
  };
}
