;;; completion-rc.el --- autocomplete / LSP (Eglot + Corfu, popup on demand)  -*- lexical-binding: t; -*-

(use-package corfu
  :init (global-corfu-mode 1))   ; no auto-popup: summon on demand

(setq tab-always-indent 'complete) ; TAB indents; already indented -> completes
