;; -*- mode: emacs-lisp; lexical-binding: t -*-
;; Managed by Home Manager. Edit modules/home-manager/programming/editors/emacs/.spacemacs.

(defun dotspacemacs/layers ()
  "Configure Spacemacs layers."
  (setq-default
   dotspacemacs-distribution 'spacemacs
   dotspacemacs-enable-lazy-installation 'unused
   dotspacemacs-ask-for-lazy-installation t
   dotspacemacs-configuration-layer-path '()
   dotspacemacs-configuration-layers
   '((typescript :variables
                 typescript-backend 'lsp)
     (javascript :variables
                 javascript-backend 'lsp)
     better-defaults
     syntax-checking
     (lsp :variables
          ;; Avoid loading every bundled language client on the first LSP
          ;; buffer: native library loading blocks the macOS GUI thread.
          lsp-client-packages '(lsp-bash lsp-css lsp-eslint lsp-go lsp-golangci-lint
                                lsp-javascript lsp-json lsp-marksman lsp-metals
                                lsp-nix lsp-pylsp lsp-pyright lsp-python-ty
                                lsp-rust lsp-toml lsp-yaml)
          lsp-enable-file-watchers nil
          ;; Nix supplies language servers. The built-in downloader uses Lisp
          ;; threads and can deadlock Cocoa while fetching a missing server.
          lsp-enable-suggest-server-download nil
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
     (python :variables python-lsp-server 'pylsp)
     spacemacs-org
     agent-shell
     restclient
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
     (go :variables
         go-backend 'lsp
         go-format-before-save t
         gofmt-command "gofumpt"
         go-use-golangci-lint t
         go-dap-mode 'dap-dlv-go)
     (shell :variables
            shell-default-term-shell (or (getenv "SPACEMACS_SHELL") (getenv "SHELL"))
            shell-default-shell 'vterm))
   dotspacemacs-additional-packages '(envrc logview smithy-mode exec-path-from-shell popper)
   dotspacemacs-frozen-packages '()
   dotspacemacs-excluded-packages '()
   dotspacemacs-install-packages 'used-only)
  (nh/emacs-apply-nix-package-policy))

(defun dotspacemacs/init ()
  "Initialize Spacemacs settings."
  (setq-default
   dotspacemacs-elpa-timeout 10
   dotspacemacs-gc-cons '(20000000 0.1)
   dotspacemacs-read-process-output-max (* 256 1024)
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
   dotspacemacs-themes '(doom-one spacemacs-dark spacemacs-light doom-one-light madhat2r naquadah)
   dotspacemacs-mode-line-theme '(doom)
   dotspacemacs-colorize-cursor-according-to-state t
   dotspacemacs-default-font '("MesloLGS Nerd Font Mono" :size 10.0 :weight normal :width normal)
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
  "Global environment is established before envrc in user-config."
  nil)

(defun dotspacemacs/user-init ()
  "Initialize user settings before packages load."
  (load (expand-file-name "nix-packages.el" user-emacs-directory) nil t)
  (load (expand-file-name "nix-lsp.el" user-emacs-directory) nil t)
  (when (eq system-type 'darwin)
    ;; The default uses half the CPU cores; package loading otherwise starts
    ;; several native-compilation workers at once, including when opening files.
    (setq native-comp-async-jobs-number 1)
    ;; A login shell supplies the Nix PATH without interactive Zsh plugins,
    ;; completion initialization, and gpg-agent startup blocking the GUI.
    (setq exec-path-from-shell-arguments '("-l")))
  (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
  (when (file-exists-p custom-file)
    (load custom-file))
  (scroll-bar-mode -1)
  (when (fboundp 'horizontal-scroll-bar-mode)
    (horizontal-scroll-bar-mode -1)))

(defvar exec-path-from-shell-arguments)
(defvar exec-path-from-shell-shell-name)

(defun nh/emacs-initialize-environment ()
  "Import a global GUI environment without overwriting project-local values."
  (when (display-graphic-p)
    (require 'exec-path-from-shell)
    (let* ((process-environment (default-value 'process-environment))
           (exec-path (default-value 'exec-path))
           (exec-path-from-shell-arguments '("-l"))
           (exec-path-from-shell-shell-name (getenv "SPACEMACS_SHELL")))
      (exec-path-from-shell-initialize)
      (setq-default process-environment process-environment exec-path exec-path))))

(defvar-local nh/emacs-go-diagnostics-state nil)

(defun nh/emacs-go-lint-availability ()
  "Use golangci-lint only when the current project's environment supplies it."
  (setq-local go-use-golangci-lint (and (executable-find "golangci-lint") t))
  (when (eq (bound-and-true-p go-backend) 'lsp)
    (require 'lsp-diagnostics)
    (let ((previous lsp-diagnostics-provider))
      (cond
       (go-use-golangci-lint
        (unless nh/emacs-go-diagnostics-state
          (setq-local nh/emacs-go-diagnostics-state
                      (cons (local-variable-p 'lsp-diagnostics-provider)
                            lsp-diagnostics-provider)))
        (setq-local lsp-diagnostics-provider :none))
       (nh/emacs-go-diagnostics-state
        (if (car nh/emacs-go-diagnostics-state)
            (setq-local lsp-diagnostics-provider (cdr nh/emacs-go-diagnostics-state))
          (kill-local-variable 'lsp-diagnostics-provider))
        (setq-local nh/emacs-go-diagnostics-state nil)))
      (when (and (not (eq previous lsp-diagnostics-provider))
                 (bound-and-true-p lsp-diagnostics-mode))
        (lsp-diagnostics-mode -1)
        (lsp-diagnostics-mode +1)))))

(defun nh/emacs-envrc-updated (buffer _result)
  "Recheck Go tooling after envrc applies or removes a buffer's environment."
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (when (derived-mode-p 'go-mode)
        (nh/emacs-go-lint-availability)))))

(defun dotspacemacs/user-config ()
  "Configure user settings after packages load."
  (nh/emacs-initialize-environment)
  (setq-default fill-column 100)
  (setq lsp-nix-nil-formatter ["alejandra-stdin"]
        lsp-nix-nil-auto-eval-inputs nil
        lsp-nix-nil-max-mem 4096
        nerd-icons-font-family "Symbols Nerd Font Mono")
  (with-eval-after-load 'nix-format
    (setq nix-nixfmt-bin "alejandra-stdin"))
  (with-eval-after-load 'lsp-mode
    (require 'lsp-nix nil t)
    (setq lsp-disabled-clients (cons 'nixd-lsp (remove 'nixd-lsp lsp-disabled-clients)))
    (require 'lsp-toml)
    (require 'lsp-marksman))
  (use-package envrc
    :demand t
    :config
    (advice-add 'envrc--apply :after #'nh/emacs-envrc-updated)
    (envrc-global-mode +1))
  (with-eval-after-load 'scala-mode
    (remove-hook 'scala-mode-hook #'lsp)
    (add-hook 'scala-mode-hook #'lsp-deferred t))
  (with-eval-after-load 'nerd-icons
    (when (display-graphic-p)
      (nerd-icons-set-font)))
  (add-hook 'toml-mode-hook #'lsp-deferred)
  (add-hook 'markdown-mode-hook #'lsp-deferred)
  (add-hook 'go-mode-local-vars-hook #'nh/emacs-go-lint-availability)
  (with-eval-after-load 'vterm
    (setq vterm-max-scrollback 10000
          vterm-buffer-name-string "vterm %s")
    (add-hook 'vterm-mode-hook
              (lambda ()
                (setq-local cursor-type 'box)
                (setq-local cursor-in-non-selected-windows 'box)))
    (define-key vterm-mode-map (kbd "C-c C-y") #'vterm-yank)
    (define-key vterm-mode-map (kbd "C-c C-c") #'vterm-send-C-c)
    (define-key vterm-mode-map (kbd "C-c C-l") #'vterm-clear-scrollback)))
