{outputs, ...}: {
  imports = [
    ../modules/alacritty.nix
    # ../modules/atuin.nix
    ../modules/bat.nix
    ../modules/btop.nix
    ../modules/fastfetch.nix
    ../modules/fzf.nix
    ../modules/git.nix
    # ../modules/gpg.nix
    ../modules/home.nix
    ../modules/krew.nix
    ../modules/lazygit.nix
    ../modules/neovim.nix
    ../modules/scripts.nix
    ../modules/spicetify.nix
    ../modules/tmux.nix
    ../modules/zsh.nix
    ../modules/vscode.nix
  ];

  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };
}
