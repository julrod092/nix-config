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
   '(typescript
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
   dotspacemacs-install-packages 'used-only))

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

(defvar-local julrod/vterm-project-root nil)
(defvar-local julrod/vterm-owner-frame nil)

(defun julrod/vterm-parent-frame (&optional frame)
  "Return the top-level parent of FRAME."
  (let ((frame (or frame (selected-frame))))
    (while (frame-parent frame)
      (setq frame (frame-parent frame)))
    frame))

(defun julrod/vterm-project-root ()
  "Return the current project root, or the home directory."
  (file-truename
   (or (when-let* ((project (project-current nil)))
         (project-root project))
       (expand-file-name "~"))))

(defun julrod/vterm-project-name (root)
  "Return a short display name for project ROOT."
  (if (equal root (file-truename (expand-file-name "~")))
      "~"
    (file-name-nondirectory (directory-file-name root))))

(defun julrod/vterm-managed-p (buffer)
  "Return non-nil when BUFFER is a managed floating VTerm."
  (and (buffer-live-p buffer)
       (buffer-local-value 'julrod/vterm-project-root buffer)
       (frame-live-p (buffer-local-value 'julrod/vterm-owner-frame buffer))))

(defun julrod/vterm-buffers-for-frame (&optional frame)
  "Return managed VTerms owned by top-level FRAME."
  (let ((owner (julrod/vterm-parent-frame frame)))
    (seq-filter
     (lambda (buffer)
       (and (julrod/vterm-managed-p buffer)
            (eq (buffer-local-value 'julrod/vterm-owner-frame buffer) owner)))
     (buffer-list))))

(defun julrod/vterm-buffer-for-project (root &optional frame)
  "Return the managed VTerm for ROOT and top-level FRAME."
  (seq-find
   (lambda (buffer)
     (equal (buffer-local-value 'julrod/vterm-project-root buffer) root))
   (julrod/vterm-buffers-for-frame frame)))

(defun julrod/vterm-current-directory (buffer)
  "Return BUFFER's tracked directory, falling back to its project root."
  (with-current-buffer buffer
    (or (and (stringp default-directory) default-directory)
        julrod/vterm-project-root)))

(defun julrod/vterm-frame-title (buffer)
  "Return the child-frame title for managed VTerm BUFFER."
  (format "VTerm: %s - %s"
          (julrod/vterm-project-name
           (buffer-local-value 'julrod/vterm-project-root buffer))
          (abbreviate-file-name (julrod/vterm-current-directory buffer))))

(defun julrod/vterm-update-frame-title (&optional buffer)
  "Update the visible child-frame title for BUFFER."
  (let* ((buffer (or buffer (current-buffer)))
         (window (get-buffer-window buffer t))
         (frame (and window (window-frame window))))
    (when (and frame (frame-parent frame))
      (set-frame-parameter frame 'name (julrod/vterm-frame-title buffer)))))

(defun julrod/vterm-display (buffer &optional alist)
  "Display managed VTerm BUFFER in a centered child frame.
ALIST is the display action alist supplied by Popper."
  (let* ((parent (julrod/vterm-parent-frame))
         (parent-width (frame-pixel-width parent))
         (parent-height (frame-pixel-height parent))
         (width (floor (* parent-width 0.8)))
         (height (floor (* parent-height 0.7)))
         (parameters `((parent-frame . ,parent)
                       (julrod/vterm-frame . t)
                       (minibuffer . nil)
                       (unsplittable . t)
                       (no-other-frame . t)
                       (undecorated . nil)
                       (accept-focus . t)
                       (width . (text-pixels . ,width))
                       (height . (text-pixels . ,height))
                       (left . ,(floor (/ (- parent-width width) 2)))
                       (top . ,(floor (/ (- parent-height height) 2)))
                       (name . ,(julrod/vterm-frame-title buffer))))
         (window (display-buffer-in-child-frame
                  buffer (append alist `((child-frame-parameters . ,parameters))))))
    (when (window-live-p window)
      (with-selected-frame (window-frame window)
        (select-window window)
        (delete-other-windows window)
        (set-window-dedicated-p window t))
      (select-frame-set-input-focus (window-frame window))
      (select-window window))
    window))

(defun julrod/vterm-visible-window (&optional frame)
  "Return the visible managed VTerm window owned by FRAME."
  (seq-some
   (lambda (buffer)
     (get-buffer-window buffer t))
   (julrod/vterm-buffers-for-frame frame)))

(defun julrod/vterm-remember-editor ()
  "Remember where focus should return after hiding the VTerm."
  (let ((frame (julrod/vterm-parent-frame)))
    (set-frame-parameter frame 'julrod/vterm-return-frame frame)
    (set-frame-parameter frame 'julrod/vterm-return-window (selected-window))
    (set-frame-parameter frame 'julrod/vterm-return-buffer (current-buffer))))

(defun julrod/vterm-restore-editor (&optional frame)
  "Restore the editor focus recorded for FRAME."
  (let* ((frame (julrod/vterm-parent-frame frame))
         (window (frame-parameter frame 'julrod/vterm-return-window))
         (buffer (frame-parameter frame 'julrod/vterm-return-buffer)))
    (when (frame-live-p frame)
      (cond
       ((window-live-p window)
        (select-frame frame)
        (select-window window))
       ((buffer-live-p buffer)
        (select-frame frame)
        (switch-to-buffer buffer)))
      ;; Let the window system finish deleting the child frame before
      ;; transferring keyboard focus back to its parent.
      (run-at-time
       0 nil
       (lambda (target-frame target-window)
         (when (frame-live-p target-frame)
           (select-frame-set-input-focus target-frame)
           (when (window-live-p target-window)
             (select-window target-window))))
       frame window))))

(defun julrod/vterm-get-or-create (root frame)
  "Return the managed VTerm for ROOT and FRAME, creating it if needed."
  (require 'vterm)
  (or (julrod/vterm-buffer-for-project root frame)
      (let* ((default-directory root)
             (name (format "*vterm:%s*" (julrod/vterm-project-name root)))
             (buffer (generate-new-buffer name)))
        (with-current-buffer buffer
          (vterm-mode)
          (setq-local julrod/vterm-project-root root
                      julrod/vterm-owner-frame frame
                      popper-popup-status 'popup))
        buffer)))

(defun julrod/vterm-show (buffer)
  "Show managed VTerm BUFFER and enter Evil insert state."
  (julrod/vterm-display buffer)
  (when-let* ((window (get-buffer-window buffer t)))
    (select-frame-set-input-focus (window-frame window))
    (select-window window)
    (julrod/vterm-update-frame-title buffer)
    (when (fboundp 'evil-insert-state)
      (evil-insert-state))))

(defun julrod/vterm-hide ()
  "Hide the floating VTerm without killing its buffer or process."
  (interactive)
  (when-let* ((child (and (frame-parent) (selected-frame)))
              (parent (frame-parent child)))
    (delete-frame child)
    (julrod/vterm-restore-editor parent)))

(defun julrod/vterm-toggle (&optional _prefix)
  "Toggle the current project's persistent floating VTerm."
  (interactive "P")
  (when (display-graphic-p)
    (let* ((parent (julrod/vterm-parent-frame))
           (visible (julrod/vterm-visible-window parent)))
      (if visible
          (with-selected-window visible
            (julrod/vterm-hide))
        (let ((root (julrod/vterm-project-root)))
          (julrod/vterm-remember-editor)
          (julrod/vterm-show (julrod/vterm-get-or-create root parent)))))))

(defun julrod/vterm-cycle (step)
  "Cycle STEP positions through VTerms owned by the current parent frame."
  (let* ((buffers (julrod/vterm-buffers-for-frame))
         (count (length buffers)))
    (when (> count 0)
      (let* ((current (current-buffer))
             (index (or (seq-position buffers current) 0))
             (next (nth (mod (+ index step) count) buffers)))
        (set-window-dedicated-p (selected-window) nil)
        (set-window-buffer (selected-window) next)
        (set-window-dedicated-p (selected-window) t)
        (julrod/vterm-update-frame-title next)
        (when (fboundp 'evil-insert-state)
          (evil-insert-state))))))

(defun julrod/vterm-next ()
  "Show the next managed VTerm for this parent frame."
  (interactive)
  (julrod/vterm-cycle 1))

(defun julrod/vterm-previous ()
  "Show the previous managed VTerm for this parent frame."
  (interactive)
  (julrod/vterm-cycle -1))

(defun julrod/vterm-kill ()
  "Kill the current managed VTerm and show the next one, if any."
  (interactive)
  (let* ((child (selected-frame))
         (parent (julrod/vterm-parent-frame child))
         (current (current-buffer))
         (buffers (julrod/vterm-buffers-for-frame parent))
         (index (or (seq-position buffers current) 0))
         (remaining (delq current (copy-sequence buffers))))
    (if remaining
        (let ((next (nth (mod index (length remaining)) remaining)))
          (set-window-dedicated-p (selected-window) nil)
          (set-window-buffer (selected-window) next)
          (set-window-dedicated-p (selected-window) t)
          (kill-buffer current)
          (julrod/vterm-update-frame-title next)
          (when (fboundp 'evil-insert-state)
            (evil-insert-state)))
      (kill-buffer current)
      (when (and (frame-live-p child) (frame-parent child))
        (delete-frame child))
      (julrod/vterm-restore-editor parent))))

(defun dotspacemacs/user-config ()
  "Configure user settings after packages load."
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
    (envrc-global-mode +1))
  (with-eval-after-load 'scala-mode
    (remove-hook 'scala-mode-hook #'lsp)
    (add-hook 'scala-mode-hook #'lsp-deferred t))
  (with-eval-after-load 'nerd-icons
    (when (display-graphic-p)
      (nerd-icons-set-font)))
  (add-hook 'toml-mode-hook #'lsp-deferred)
  (add-hook 'markdown-mode-hook #'lsp-deferred)
  (with-eval-after-load 'vterm
    (setq vterm-max-scrollback 10000
          vterm-buffer-name-string nil)
    (add-hook 'vterm-mode-hook
              (lambda ()
                (setq-local cursor-type 'box)
                (setq-local cursor-in-non-selected-windows 'box)))
    (define-key vterm-mode-map (kbd "C-c C-y") #'vterm-yank)
    (define-key vterm-mode-map (kbd "C-c C-c") #'vterm-send-C-c)
    (define-key vterm-mode-map (kbd "C-c C-l") #'vterm-clear-scrollback)
    (evil-define-key 'normal vterm-mode-map
      (kbd "q") #'julrod/vterm-hide
      (kbd "K") #'julrod/vterm-kill
      (kbd "]") #'julrod/vterm-next
      (kbd "[") #'julrod/vterm-previous))
  (use-package popper
    :demand t
    :init
    (setq popper-reference-buffers (list #'julrod/vterm-managed-p)
          popper-display-control t
          popper-display-function #'julrod/vterm-display
          popper-mode-line nil)
    :config
    (popper-mode +1))
  (spacemacs/set-leader-keys "'" #'julrod/vterm-toggle)
  (when (and (display-graphic-p) (fboundp 'exec-path-from-shell-initialize))
    (exec-path-from-shell-initialize)))
