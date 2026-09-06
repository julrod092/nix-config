{config, ...}: {
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "gpg-ssh-key".path = "${config.home.homeDirectory}/.ssh/id_rsa.pub";
      localstack = {};
      tailscale-preferences = {
        sopsFile = ./tailscale.sops.json;
        format = "binary";
      };
    };
  };
}
