{
  config,
  lib,
  ...
}: {
  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = lib.genAttrs [
      "GITHUB_NPM_KEY"
      "GITHUB_REPO_ACCESS"
      "localstack"
      "tf_gateway_api_key"
    ] (_: {});
  };

  programs.zsh.initContent = lib.mkAfter ''
    export TF_GATEWAY_API_KEY=$(cat ${config.sops.secrets.tf_gateway_api_key.path})
  '';
}
