;;; backups-rc.el --- backups & auto-save (keep working/git dirs clean)  -*- lexical-binding: t; -*-

(setq backup-directory-alist '(("." . "~/.config/emacs/backups/")))
(setq auto-save-file-name-transforms
      '((".*" "~/.config/emacs/auto-save/" t)))
(make-directory "~/.config/emacs/backups/" t)
(make-directory "~/.config/emacs/auto-save/" t)
