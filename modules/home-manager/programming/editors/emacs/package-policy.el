;;; package-policy.el --- Nix/Spacemacs ownership boundary -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'package)

(defun nh/emacs-apply-nix-package-policy ()
  "Keep the generated Nix package closure externally owned by Spacemacs."
  (add-to-list 'package-directory-list nh-emacs-nix-package-directory)
  (setq dotspacemacs-additional-packages
        (append (mapcar (lambda (name) (list name :location 'site))
                        nh-emacs-nix-package-names)
                (cl-remove-if
                 (lambda (spec)
                   (memq (if (consp spec) (car spec) spec) nh-emacs-nix-package-names))
                 dotspacemacs-additional-packages))
        dotspacemacs-frozen-packages
        (delete-dups (append nh-emacs-nix-package-names dotspacemacs-frozen-packages))
        package-pinned-packages
        (append (mapcar (lambda (name) (cons name "nix-managed"))
                        nh-emacs-nix-package-names)
                (cl-remove-if (lambda (pin) (memq (car pin) nh-emacs-nix-package-names))
                              package-pinned-packages))
        ;; Synchronizing an existing session may already have cached archives.
        package-archive-contents
        (cl-remove-if (lambda (entry) (memq (car entry) nh-emacs-nix-package-names))
                      package-archive-contents)))

;; "nix-managed" is deliberately NOT an entry in package-archives. Installed
;; site descriptors remain available; archive replacements and newer dependency
;; downloads are unavailable. Update the Nix package set when a requirement fails.
