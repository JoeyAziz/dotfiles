;;; org-rc.el --- Org mode to Notion look  -*- lexical-binding: t; -*-

(set-face-attribute 'variable-pitch nil :family "Georgia")
(setq org-hide-emphasis-markers t)   ; hide *bold* / =code= markers, Notion-style

;; org-modern-mode is enabled in hooks-rc.el with the other mode hooks
(use-package org-modern)
