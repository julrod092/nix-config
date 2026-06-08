{
  pkgs,
  userConfig,
  ...
}: {
  # Enable common container config files in /etc/containers
  virtualisation = {
    containers = {
      enable = true;
      storage.settings = {
        storage = {
          driver = "overlay";
          graphroot = "/home/${userConfig.name}/m2/Podman-root";
          runroot = "/run/containers/storage";
          rootless_storage_path = "/home/${userConfig.name}/m2/Podman";
        };
      };
    };
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
      dockerSocket.enable = true;
    };
    oci-containers.backend = "podman";
  };

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 53;

  environment.systemPackages = with pkgs; [
    qemu # Essential to run fedora based image
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev
    podman-compose # start group of containers for dev
  ];
}
