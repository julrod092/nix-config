{lib, ...}: {
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = lib.genAttrs [
      "GITHUB_NPM_KEY"
      "GITHUB_REPO_ACCESS"
      "localstack"
      "tf_gateway_api_key"
    ] (_: {});
  };
}
