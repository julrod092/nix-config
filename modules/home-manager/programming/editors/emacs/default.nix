{
  config,
  lib,
  pkgs,
  agentShellSource,
  ...
}: let
  cfg = config.nh.programming;
  emacsPackage =
    if pkgs.stdenv.hostPlatform.isLinux
    then pkgs.emacs-pgtk
    else pkgs.emacs;
  alejandraStdin = pkgs.writeShellScriptBin "alejandra-stdin" ''
    exec ${lib.getExe pkgs.alejandra} --quiet - "$@"
  '';
in {
  config = lib.mkIf (cfg.enable && cfg.editors.emacs.enable) {
    programs.emacs = {
      enable = true;
      package = emacsPackage;
      extraPackages = epkgs: [
        epkgs.envrc
        epkgs.lsp-mode
        epkgs.vterm
      ];
    };

    home.packages = [
      alejandraStdin
      pkgs.typescript-language-server
    ];

    home.sessionVariables.SPACEMACS_SHELL = lib.getExe pkgs.zsh;

    home.activation.bootstrapSpacemacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      spacemacs_dir="$HOME/.emacs.d"

      if [ ! -e "$spacemacs_dir" ]; then
        echo "Bootstrapping Spacemacs into $spacemacs_dir"
        ${pkgs.git}/bin/git clone --depth 1 --branch develop https://github.com/syl20bnr/spacemacs "$spacemacs_dir"
      elif [ ! -d "$spacemacs_dir/.git" ]; then
        echo "Skipping Spacemacs bootstrap: $spacemacs_dir exists and is not a git checkout." >&2
      fi
    '';

    home.file = {
      ".spacemacs".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix-config/modules/home-manager/programming/editors/emacs/.spacemacs";
      ".emacs.d/private/agent-shell".source = agentShellSource;
    };
  };
}
