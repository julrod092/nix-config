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
  agentShellLayer = pkgs.applyPatches {
    name = "spacemacs-agent-shell-layer";
    src = agentShellSource;
    patches = [./agent-shell-package-list.patch];
  };
  spacemacsRevision = "a34310ecbbb85fa9a125caee8fba227af1f94fcf";
  packagePolicy = pkgs.runCommand "emacs-nix-package-policy" {} ''
    mkdir -p "$out"
    ${lib.getExe config.programs.emacs.finalPackage} -Q --batch \
      --script ${./generate-package-policy.el} \
      ${config.programs.emacs.finalPackage.deps}/share/emacs/site-lisp/elpa \
      ${./package-policy.el} "$out"
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

    home.activation.bootstrapSpacemacs = lib.hm.dag.entryBetween ["linkGeneration"] ["writeBoundary"] ''
      spacemacs_dir="$HOME/.emacs.d"

      if [ ! -e "$spacemacs_dir" ] && [ ! -L "$spacemacs_dir" ]; then
        (
          bootstrap_dir=""
          cleanup_bootstrap() {
            if [ -n "$bootstrap_dir" ] && [ -z "''${DRY_RUN:-}" ]; then
              ${pkgs.coreutils}/bin/rm -rf -- "$bootstrap_dir"
            fi
          }
          trap cleanup_bootstrap EXIT
          if [ -n "''${DRY_RUN:-}" ]; then
            bootstrap_dir="$HOME/.spacemacs-bootstrap.DRY-RUN"
          else
            bootstrap_dir="$(${pkgs.coreutils}/bin/mktemp -d "$HOME/.spacemacs-bootstrap.XXXXXX")"
          fi
          run ${pkgs.git}/bin/git -C "$bootstrap_dir" init
          run ${pkgs.git}/bin/git -C "$bootstrap_dir" remote add origin https://github.com/syl20bnr/spacemacs
          run ${pkgs.git}/bin/git -C "$bootstrap_dir" fetch --depth 1 origin ${spacemacsRevision}
          run ${pkgs.git}/bin/git -C "$bootstrap_dir" checkout --detach FETCH_HEAD
          run ${pkgs.coreutils}/bin/mv -T -- "$bootstrap_dir" "$spacemacs_dir"
          bootstrap_dir=""
        )
      elif [ ! -e "$spacemacs_dir/.git" ] || [ ! -f "$spacemacs_dir/init.el" ] || [ ! -f "$spacemacs_dir/early-init.el" ]; then
        echo "Spacemacs bootstrap skipped: $spacemacs_dir is not a complete Git checkout. Inspect it before moving it aside and reactivating Home Manager." >&2
      fi
    '';

    home.file = {
      ".spacemacs".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix-config/modules/home-manager/programming/editors/emacs/.spacemacs";
      ".emacs.d/private/agent-shell".source = agentShellLayer;
      ".emacs.d/nix-packages.el".source = "${packagePolicy}/nix-packages.el";
      ".emacs.d/nix-packages.json".source = "${packagePolicy}/packages.json";
      ".emacs.d/nix-lsp.el".text =
        ''
          ;; Managed by Home Manager: establish the global baseline before envrc.
          (let ((process-environment (default-value 'process-environment)))
            (setenv "SPACEMACS_SHELL" "${lib.getExe pkgs.zsh}")
            (setenv "JAVA_HOME" "${pkgs.zulu21}")
            (setq-default process-environment process-environment))
          (with-eval-after-load 'lsp-pylsp
            (setq lsp-pylsp-server-command '("${lib.getExe' pkgs.python3Packages.python-lsp-server "pylsp"}")))
        ''
        + lib.optionalString cfg.languages.scala.enable ''
          ;; Keep Metals independent of buffer-local PATH and its own installer.
          (with-eval-after-load 'lsp-metals
            (setq lsp-metals-server-command "${lib.getExe pkgs.metals}")
            (lsp-dependency 'metals '(:system "${lib.getExe pkgs.metals}")))
        '';
    };
  };
}
