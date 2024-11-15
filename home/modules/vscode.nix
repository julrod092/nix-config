{pkgs, ...}: {
  # Install VSCode with expected extensions
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-azuretools.vscode-docker
      vscode-infra.image-viewer
      bbenoist.Nix
      christian-kohler.path-intellisense
    ];
  };
}
