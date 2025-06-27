{ pkgs, hostname, userConfig, ... }:
let
  system-rebuild = if pkgs.stdenv.isDarwin
  then "darwin-rebuild"
  else "nixos-rebuild";
in
{

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
      # Synergy service management
      synergy-start = "systemctl --user start synergy-server";
      synergy-stop = "systemctl --user stop synergy-server";
      synergy-restart = "systemctl --user restart synergy-server";
      synergy-status = "systemctl --user status synergy-server";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "agnoster";
    };

    localVariables = {
      NPM_GITHUB_TOKEN =
        if pkgs.stdenv.isDarwin
        then "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"
        else "";
      JAVA_HOME="${pkgs.zulu11}/bin";
      M2_HOME="${pkgs.maven}/bin";
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
