;;; init.el --- entry point: bootstrap + load rc modules  -*- lexical-binding: t; -*-
;;; Commentary:
;; JoeyAziz's Emacs configuration entry point.
;; Bootstrap lives here; the rest is split into topic modules

;;; PACKAGE MANAGEMENT
(require 'package)

;; Keep Customize's auto-saved settings OUT of init.el:
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(require 'use-package)
(setq use-package-always-ensure t)       ; use-package blocks auto-install

;;; LOAD RC MODULES (order matters: UI before theme)
(dolist (module '("mac-rc"
                  "appearance-rc"
                  "backups-rc"
                  "completion-rc"
                  "org-rc"
                  "editing-rc"
                  "magit-rc"
                  "dired-rc"
                  "hooks-rc"))
  (load (expand-file-name (concat "emacs.rc/" module ".el")
                          user-emacs-directory)))
