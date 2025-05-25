{ pkgs, ... }: {
  # Enable common container config files in /etc/containers
  virtualisation = {
    containers.enable = true;
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

  environment = {
    # Useful other development tools
    systemPackages = with pkgs; [
      qemu # Essential to run fedora based image
      dive # look into docker image layers
      podman-tui # status of containers in the terminal
      docker-compose # start group of containers for dev
      podman-compose # start group of containers for dev
    ];

    variables = {
      DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock"; # needs to run docker container based images
    };
  };
}