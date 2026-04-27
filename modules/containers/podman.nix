{...}: {
  config.dendritic.nixosModules.podman = {pkgs, ...}: {
    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
        dockerSocket.enable = true;
      };
      oci-containers.backend = "podman";
    };

    environment.systemPackages = with pkgs; [
      qemu
      dive
      podman-tui
      docker-compose
      podman-compose
    ];
  };
}
