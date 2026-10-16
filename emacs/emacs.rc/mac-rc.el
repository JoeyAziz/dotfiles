;;; mac-rc.el --- Mac keys + CUA + Mac-style shortcuts  -*- lexical-binding: t; -*-
;;; Commentary:
;; Left Cmd = super, Right Cmd = Meta, clipboard-style shortcuts.

(setq mac-command-modifier 'super)        ; Left Cmd = the s- modifier
(setq mac-right-command-modifier 'meta)   ; Right Cmd = Meta (M-)
(cua-mode 1)                              ; Ctrl+C/X/V/Z clipboard shortcuts

;; Mac-style shortcuts (Left Cmd = s-):
(global-set-key (kbd "s-c") #'kill-ring-save)     ; Cmd+C copy
(global-set-key (kbd "s-x") #'kill-region)        ; Cmd+X cut
(global-set-key (kbd "s-v") #'yank)               ; Cmd+V paste
(global-set-key (kbd "s-z") #'undo)               ; Cmd+Z undo
(global-set-key (kbd "s-Z") #'undo-redo)          ; Cmd+Shift+Z redo
(global-set-key (kbd "s-s") #'save-buffer)        ; Cmd+S save
(global-set-key (kbd "s-a") #'mark-whole-buffer)  ; Cmd+A select all
