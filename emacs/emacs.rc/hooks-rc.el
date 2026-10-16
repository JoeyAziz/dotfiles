;;; hooks-rc.el --- mode hooks, grouped in one place  -*- lexical-binding: t; -*-

;;; No line numbers in prose & terminal modes
(defun ja/no-line-numbers ()
  "Turn off display-line-numbers-mode for the current buffer."
  (display-line-numbers-mode -1))

(dolist (hook '(org-mode-hook
                term-mode-hook))
  (add-hook hook #'ja/no-line-numbers))

;;; LSP: auto-connect Eglot
(dolist (hook '(typescript-ts-mode-hook
                tsx-ts-mode-hook))
  (add-hook hook #'eglot-ensure))

;;; Org: Notion-style look
(add-hook 'org-mode-hook #'org-modern-mode)
