{
  pkgs,
  hostname,
  userConfig,
  ...
}: let
  system-rebuild =
    if pkgs.stdenv.isDarwin
    then "darwin-rebuild"
    else "nixos-rebuild";
  # sharedVariables = {};
  # darwinVariables = {
  #  JAVA_HOME = "${pkgs.zulu11}/bin";
  #   REPO_ACCESS = "$(cat ${config.sops.secrets."github_repo_token_access".path})";
  #  NPM_GITHUB_TOKEN = "$(cat ${config.sops.secrets."npm_github_token".path})";
  #  M2_HOME = "${pkgs.maven}/bin";
  #};
  # linuxVariables = {};
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ff = "fastfetch";
      nix-clean = "sudo nix-env --delete-generations old && nix-env --delete-generations old && sudo  nix-collect-garbage -d && nix-collect-garbage -d";
      nix-update = "sudo ${system-rebuild} switch --flake ~/.nix-config#${hostname}";
      hm-update = "home-manager switch --flake ~/.nix-config#${userConfig.name}@${hostname} && source ~/.zshrc";
      flake-update = "nix flake update --flake ~/.nix-config";
      nix-full-update = "flake-update && nix-update && hm-update && nix-clean";
    };

    oh-my-zsh = {
      enable = true;
      plugins = ["git"];
      theme = "agnoster";
    };

    initContent = ''
      # extra lines for zsh config file
      prompt_context() {
        if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
          prompt_segment black default "%(!.%{%F{yellow}%}.) λ "
        fi
      }
    '';
  };
}
