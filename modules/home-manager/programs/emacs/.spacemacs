;; -*- mode: emacs-lisp; lexical-binding: t -*-
;; Managed by Home Manager. Edit modules/home-manager/programs/emacs/.spacemacs.

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
            shell-default-term-shell (or (getenv "SPACEMACS_SHELL") (getenv "SHELL"))
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
   dotspacemacs-default-font '("MesloLGS Nerd Font Mono"
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
   dotspacemacs-scroll-bar-while-scrolling nil
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
  (when (file-exists-p custom-file)
    (load custom-file))
  (scroll-bar-mode -1)
  (when (fboundp 'horizontal-scroll-bar-mode)
    (horizontal-scroll-bar-mode -1)))

(defun dotspacemacs/user-config ()
  "Configure user settings after packages load."
  (setq-default fill-column 100)
  (setq lsp-nix-nil-formatter ["alejandra"]
        lsp-nix-nixd-formatting-command ["alejandra"]
        vterm-always-compile-module nil
        vterm-module-cmake-args (or (getenv "VTERM_MODULE_CMAKE_ARGS") "")
        nerd-icons-font-family "Symbols Nerd Font Mono")
  (with-eval-after-load 'nix-format
    (setq nix-nixfmt-bin "alejandra"))
  (with-eval-after-load 'lsp-mode
    (require 'lsp-nix)
    (require 'lsp-toml)
    (require 'lsp-marksman))
  (with-eval-after-load 'nerd-icons
    (when (display-graphic-p)
      (nerd-icons-set-font)))
  (add-hook 'toml-mode-hook #'lsp-deferred)
  (add-hook 'markdown-mode-hook #'lsp-deferred)
  (with-eval-after-load 'vterm
    (setq vterm-max-scrollback 10000
          vterm-buffer-name-string "vterm %s")
    (add-hook 'vterm-mode-hook
              (lambda ()
                (setq-local cursor-type 'box)
                (setq-local cursor-in-non-selected-windows 'box)))
    (define-key vterm-mode-map (kbd "C-c C-y") #'vterm-yank)
    (define-key vterm-mode-map (kbd "C-c C-c") #'vterm-send-C-c)
    (define-key vterm-mode-map (kbd "C-c C-l") #'vterm-clear-scrollback))
  (when (and (display-graphic-p) (fboundp 'exec-path-from-shell-initialize))
    (exec-path-from-shell-initialize)))

;; Custom settings live in ~/.emacs.d/custom.el so this file remains versioned.
