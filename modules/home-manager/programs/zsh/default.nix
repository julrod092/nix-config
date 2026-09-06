{
  pkgs,
  hostname,
  ...
}: let
  systemRebuild =
    if pkgs.stdenv.isDarwin
    then "sudo darwin-rebuild switch --flake ~/.nix-config#${hostname}"
    else "sudo nixos-rebuild switch --flake ~/.nix-config#${hostname}";
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ff = "fastfetch";
      nix-clean = "sudo nix-env --delete-generations old && nix-env --delete-generations old && sudo  nix-collect-garbage -d && nix-collect-garbage -d";
      nix-update = systemRebuild;
      flake-update = "nix flake update --flake ~/.nix-config";
      nix-full-update = "flake-update && nix-update && nix-clean";
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
