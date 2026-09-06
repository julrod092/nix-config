{lib, ...}: {
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = lib.genAttrs [
      "GITHUB_NPM_KEY"
      "GITHUB_REPO_ACCESS"
      "localstack"
    ] (_: {});
  };
}
