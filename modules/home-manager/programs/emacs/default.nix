{
  lib,
  pkgs,
  ...
}: let
  emacsPackage = pkgs.emacs;
  goPackage =
    if pkgs ? unstable && pkgs.unstable ? go
    then pkgs.unstable.go
    else pkgs.go;
  opencodePackage =
    if pkgs ? unstable && pkgs.unstable ? opencode
    then pkgs.unstable.opencode
    else pkgs.opencode;
  vtermModuleCmakeArgs =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "-DUSE_SYSTEM_LIBVTERM=Off"
    else "-DCMAKE_PREFIX_PATH=${pkgs.libvterm}";
  glibtool = pkgs.writeShellScriptBin "glibtool" ''
    exec ${pkgs.libtool}/bin/libtool "$@"
  '';

  emacsEditor = pkgs.writeShellScriptBin "emacs-editor" ''
    set -e

    if ! ${emacsPackage}/bin/emacsclient --eval '(emacs-pid)' >/dev/null 2>&1; then
      ${emacsPackage}/bin/emacs --daemon
    fi

    exec ${emacsPackage}/bin/emacsclient -t "$@"
  '';

  metalsEmacs = pkgs.writeShellScriptBin "metals-emacs" ''
    exec ${lib.getExe pkgs.metals} "$@"
  '';

  alejandraStdin = pkgs.writeShellScriptBin "alejandra-stdin" ''
    exec ${lib.getExe pkgs.alejandra} -q - "$@"
  '';

  nixTools = with pkgs; [
    alejandra
    deadnix
    nil
    nixd
    nixfmt
    nixpkgs-fmt
    statix
    treefmt
  ];

  scalaTools = with pkgs; [
    scalafmt
  ];

  javaTools = with pkgs; [
    google-java-format
  ];

  shellTools = with pkgs; [
    bash-language-server
    shellcheck
    shfmt
  ];

  dataTools = with pkgs; [
    marksman
    markdownlint-cli
    taplo
    vscode-langservers-extracted
    yaml-language-server
    yamlfmt
    yamllint
  ];

  vtermTools = with pkgs;
    [
      cmake
      git
      gnumake
      libtool
      pkg-config
      zsh
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [glibtool]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [pkgs.libvterm];
  # Create a single directory with all vterm tools to reduce PATH length
  vtermToolsWrapper = pkgs.symlinkJoin {
    name = "vterm-tools-wrapper";
    paths = vtermTools;
    postBuild = ''
      # Create a bin directory with symlinks to all tools
      mkdir -p $out/bin
      for pkg in ${lib.concatMapStringsSep " " (p: p.name) vtermTools}; do
        if [ -d "$out/$pkg/bin" ]; then
          for bin in "$out/$pkg/bin"/*; do
            ln -sf "$bin" "$out/bin/$(basename "$bin")" 2>/dev/null || true
          done
        fi
      done
    '';
  };
  vtermToolPath = "${vtermToolsWrapper}/bin";

  goTools = with pkgs; [
    goPackage
    delve
    godef
    gofumpt
    goimports-reviser
    golangci-lint
    golines
    gomodifytags
    go-outline
    gopkgs
    gopls
    gotests
    gotools
    impl
    reftools
  ];

  haskellTools = with pkgs; [
    cabal-install
    ghc
    haskell-language-server
    hlint
    fourmolu
    ormolu
    stack
    stylish-haskell
    haskellPackages.cabal-fmt
    haskellPackages.hasktags
    haskellPackages.hoogle
  ];
in {
  programs.emacs = {
    enable = true;
    package = emacsPackage;
  };

  home.packages =
    [
      emacsEditor
      metalsEmacs
      pkgs.metals
    ]
    ++ nixTools
    ++ scalaTools
    ++ javaTools
    ++ shellTools
    ++ dataTools
    ++ vtermTools
    ++ goTools
    ++ haskellTools;

  home.sessionPath = [
    "$HOME/.cabal/bin"
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ];

  home.activation.bootstrapSpacemacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    spacemacs_dir="$HOME/.emacs.d"

    if [ ! -e "$spacemacs_dir" ]; then
      echo "Bootstrapping Spacemacs into $spacemacs_dir"
      ${pkgs.git}/bin/git clone --depth 1 --branch develop https://github.com/syl20bnr/spacemacs "$spacemacs_dir"
    elif [ ! -d "$spacemacs_dir/.git" ]; then
      echo "Skipping Spacemacs bootstrap: $spacemacs_dir exists and is not a git checkout." >&2
    fi
  '';

  home.file.".spacemacs".text = ''
    ;; -*- mode: emacs-lisp; lexical-binding: t -*-
    ;; Managed by Home Manager. Edit modules/home-manager/programs/emacs/default.nix.

    (defun dotspacemacs/layers ()
      "Configure Spacemacs layers."
      (setq-default
       dotspacemacs-distribution 'spacemacs
       dotspacemacs-enable-lazy-installation 'unused
       dotspacemacs-ask-for-lazy-installation t
       dotspacemacs-configuration-layer-path '()
       dotspacemacs-configuration-layers
       '(
         better-defaults
         syntax-checking
         (lsp :variables
              lsp-enable-file-watchers nil
              lsp-headerline-breadcrumb-enable nil)
         dap
         emacs-lisp
          git
          compleseus
          treemacs
         tree-sitter
         themes-megapack
         version-control
         markdown
         toml
         llm-client
         mermaid
         multiple-cursors
         python
         spacemacs-org
         agent-shell
         (unicode-fonts :variables unicode-fonts-enable-ligatures t)
         (auto-completion :variables
                          auto-completion-enable-help-tooltip 'manual)
         (org :variables
              org-enable-verb-support t
              org-enable-roam-support t
              org-enable-roam-ui t)
         (shell-scripts :variables
                        shell-scripts-backend 'lsp
                        shell-scripts-format-on-save t)
         (yaml :variables
               yaml-enable-lsp t)
          (json :variables
                json-backend 'lsp)
         (nixos :variables
                nix-backend 'lsp
                nixos-format-on-save t)
         (scala :variables
                scala-auto-treeview t
                scala-sbt-window-position 'bottom)
         (rust :variables
               lsp-rust-analyzer-cargo-auto-reload t
               rustic-format-on-save t)
         (java :variables
               java-backend 'lsp)
         (go :variables
             go-backend 'lsp
             go-format-before-save t
             gofmt-command "goimports"
             go-use-golangci-lint t
             go-dap-mode 'dap-dlv-go)
         (shell :variables
                shell-default-height 30
                shell-default-position 'bottom
                shell-default-term-shell "${lib.getExe pkgs.zsh}"
                shell-default-shell 'vterm
                shell-close-window-with-terminal t)
         (haskell :variables
                  haskell-completion-backend 'lsp))
       dotspacemacs-additional-packages '(logview smithy-mode exec-path-from-shell)
       dotspacemacs-frozen-packages '()
       dotspacemacs-excluded-packages '()
       dotspacemacs-install-packages 'used-only))

    (defun dotspacemacs/init ()
      "Initialize Spacemacs settings."
      (setq-default
       dotspacemacs-elpa-timeout 10
       dotspacemacs-gc-cons '(20000000 0.1)
       dotspacemacs-read-process-output-max (* 1024 1024)
       dotspacemacs-use-spacelpa nil
       dotspacemacs-verify-spacelpa-archives t
       dotspacemacs-check-for-update nil
       dotspacemacs-elpa-subdirectory 'emacs-version
       dotspacemacs-editing-style 'vim
       dotspacemacs-startup-buffer-show-version t
       dotspacemacs-startup-banner 'official
       dotspacemacs-startup-lists '((recents . 5) (projects . 7))
       dotspacemacs-startup-buffer-responsive t
       dotspacemacs-new-empty-buffer-major-mode 'text-mode
       dotspacemacs-scratch-mode 'text-mode
       dotspacemacs-themes '(doom-one
                         spacemacs-dark
                         spacemacs-light
                         doom-one-light
                         madhat2r
                         naquadah)
       dotspacemacs-mode-line-theme '(doom)
       dotspacemacs-colorize-cursor-according-to-state t
       dotspacemacs-default-font '("MesloLGS Nerd Font"
                               :size 10.0
                               :weight normal
                               :width normal)
       dotspacemacs-default-icons-font 'nerd-icons
       dotspacemacs-leader-key "SPC"
       dotspacemacs-emacs-command-key "SPC"
       dotspacemacs-ex-command-key ":"
       dotspacemacs-emacs-leader-key "M-m"
       dotspacemacs-major-mode-leader-key ","
       dotspacemacs-major-mode-emacs-leader-key (if window-system "M-<return>" "C-M-m")
       dotspacemacs-large-file-size 1
       dotspacemacs-auto-save-file-location 'cache
       dotspacemacs-max-rollback-slots 5
       dotspacemacs-enable-paste-transient-state nil
       dotspacemacs-which-key-delay 0.4
       dotspacemacs-which-key-position 'bottom
       dotspacemacs-loading-progress-bar t
       dotspacemacs-maximized-at-startup t
       dotspacemacs-line-numbers 'relative
       dotspacemacs-folding-method 'evil
       dotspacemacs-enable-server nil
       dotspacemacs-persistent-server nil
       dotspacemacs-search-tools '("rg" "ag" "ack" "grep")
       dotspacemacs-undo-system 'undo-redo
       dotspacemacs-frame-title-format "%I@%S"
       dotspacemacs-show-trailing-whitespace t
       dotspacemacs-whitespace-cleanup 'trailing
       dotspacemacs-use-clean-aindent-mode t
       dotspacemacs-use-SPC-as-y nil
       dotspacemacs-byte-compile nil))

    (defun dotspacemacs/user-env ()
      "Load shell environment for Emacs."
      (spacemacs/load-spacemacs-env))

    (defun dotspacemacs/user-init ()
      "Initialize user settings before packages load."
      (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
      (setenv "PATH" (concat "${vtermToolPath}:" (or (getenv "PATH") "")))
      ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      (setenv "LIBTOOL" "${pkgs.libtool}/bin/libtool")
    ''}
      (setq vterm-always-compile-module nil
            vterm-module-cmake-args "${vtermModuleCmakeArgs}"
            nerd-icons-font-family "Symbols Nerd Font Mono")
      (when (file-exists-p custom-file)
        (load custom-file))
      ;; Disable scroll bars globally
      (scroll-bar-mode -1)
      (when (fboundp 'horizontal-scroll-bar-mode)
        (horizontal-scroll-bar-mode -1)))

    (defun dotspacemacs/user-config ()
      "Configure user settings after packages load."
      (setq-default fill-column 100)
      (setq lsp-metals-server-command "metals-emacs"
            lsp-haskell-server-path "haskell-language-server-wrapper"
            lsp-nix-nil-server-path "nil"
            lsp-nix-nil-formatter ["alejandra"]
            lsp-nix-nixd-server-path "nixd"
            lsp-nix-nixd-formatting-command ["alejandra"]
            lsp-toml-command "taplo"
            lsp-marksman-server-command "marksman")
      (with-eval-after-load 'nix-format
        (setq nix-nixfmt-bin "${lib.getExe alejandraStdin}"))
      (with-eval-after-load 'lsp-mode
        (require 'lsp-nix)
        (require 'lsp-toml)
        (require 'lsp-marksman))
      (with-eval-after-load 'nerd-icons
        (when (display-graphic-p)
          (nerd-icons-set-font)))
      (add-hook 'toml-mode-hook #'lsp-deferred)
      (add-hook 'markdown-mode-hook #'lsp-deferred)

      ;; Vterm configuration - fix cursor and keybinding issues
      (with-eval-after-load 'vterm
        ;; Enable char mode by default for better terminal interaction
        (setq vterm-max-scrollback 10000)
        (setq vterm-buffer-name-string "vterm %s")

        ;; Fix cursor display - use terminal cursor instead of evil's
        (add-hook 'vterm-mode-hook
                  (lambda ()
                    (setq-local cursor-type 'box)
                    (setq-local cursor-in-non-selected-windows 'box)))

        ;; Copy/paste integration with system clipboard
        (define-key vterm-mode-map (kbd "C-c C-y") #'vterm-yank)
        (define-key vterm-mode-map (kbd "C-c C-c") #'vterm-send-C-c)
        (define-key vterm-mode-map (kbd "C-c C-l") #'vterm-clear-scrollback))

      ;; Enable exec-path-from-shell for proper PATH in GUI Emacs
      (when (and (display-graphic-p) (fboundp 'exec-path-from-shell-initialize))
        (exec-path-from-shell-initialize)))

    ;; Custom settings live in ~/.emacs.d/custom.el so this Nix-owned file stays immutable.
  '';
}
