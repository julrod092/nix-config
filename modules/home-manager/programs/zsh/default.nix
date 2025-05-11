{ pkgs, ... }: {

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ff = "fastfetch";
      updatex =
      if pkgs.stdenv.isDarwin
      then "darwin-rebuild switch --flake ~/.nix-config#julrod-mac && home-manager switch --flake ~/.nix-config#julrod@julrod-mac && source ~/.zshrc"
      else "sudo nixos-rebuild switch --flake ~/.nix-config#nix-desktop && home-manager switch --flake ~/.nix-config#julrod@nix-desktop && source ~/.zshrc";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "agnoster";
    };

    localVariables = {
      NPM_GITHUB_TOKEN="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";
      JAVA_HOME="${pkgs.stable.zulu11}/bin";
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
