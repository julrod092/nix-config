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
    prettier
    prettierd
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
  vtermToolPath = lib.makeBinPath vtermTools;

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
         helm
         prettier
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
               json-backend 'lsp
               json-fmt-tool 'prettier
               json-fmt-on-save t)
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
       dotspacemacs-additional-packages '(beacon tmr logview smithy-mode exec-path-from-shell)
       dotspacemacs-frozen-packages '()
       dotspacemacs-excluded-packages '()
       dotspacemacs-install-packages 'used-only))

    (defun dotspacemacs/init ()
      "Initialize Spacemacs settings."
      (setq-default
       dotspacemacs-elpa-timeout 10
       dotspacemacs-gc-cons '(100000000 0.1)
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
                               :size 12.0
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
      (setq vterm-always-compile-module t
            vterm-module-cmake-args "${vtermModuleCmakeArgs}"
            nerd-icons-font-family "Symbols Nerd Font Mono")
      (when (file-exists-p custom-file)
        (load custom-file)))

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
      (defun julian/opencode--project-root ()
        "Return the current project root, falling back to `default-directory'."
        (require 'project)
        (file-name-as-directory
         (expand-file-name
          (or (when-let ((project (project-current nil)))
                (project-root project))
              (locate-dominating-file default-directory ".git")
              default-directory))))

      (defun julian/opencode--buffer-name (root)
        "Return the opencode buffer name for ROOT."
        (let ((project-name (file-name-nondirectory (directory-file-name root))))
          (format "*opencode:%s*"
                  (if (string= project-name "") "root" project-name))))

      (defun julian/opencode--right-window ()
        "Return a normal right-side window for opencode."
        (or (window-in-direction 'right)
            (condition-case nil
                (split-window (selected-window)
                              (- (max 40 (floor (* (window-total-width) 0.38))))
                              'right)
              (error (condition-case nil
                         (split-window-right)
                       (error (selected-window)))))))

      (defun julian/opencode--show-buffer (buffer)
        "Show BUFFER in a right-side vertical window and select it."
        (let ((window (or (get-buffer-window buffer)
                          (julian/opencode--right-window))))
          (select-window window)
          (switch-to-buffer buffer)))

      (defun julian/opencode-vterm ()
        "Open opencode in a project-scoped right-side vterm buffer."
        (interactive)
        (require 'vterm)
        (let* ((root (julian/opencode--project-root))
               (buffer-name (julian/opencode--buffer-name root))
               (buffer (get-buffer buffer-name)))
          (if (and buffer (buffer-live-p buffer))
              (julian/opencode--show-buffer buffer)
            (select-window (julian/opencode--right-window))
            (let ((default-directory root))
              (vterm buffer-name)
              (vterm-send-string "${lib.getExe opencodePackage}")
              (vterm-send-return)))))

      (defun julian/opencode-vterm-maximize ()
        "Open opencode and toggle maximizing its window."
        (interactive)
        (julian/opencode-vterm)
        (spacemacs/toggle-maximize-window))

      (spacemacs/set-leader-keys
        "ao" #'julian/opencode-vterm
        "aO" #'julian/opencode-vterm-maximize
        "bi" #'ibuffer))

    ;; Custom settings live in ~/.emacs.d/custom.el so this Nix-owned file stays immutable.
  '';
}
