;;; appearance-rc.el --- fonts, UI, and theme (alabaster + C-c t toggle)  -*- lexical-binding: t; -*-
;;; Commentary:
;; All visual setup: fonts, chrome, and the dark/light theme toggle.

;;; FONTS & UI
(set-face-attribute 'default nil :height 190)            ; 190 = 19pt
(set-face-attribute 'mode-line nil :height 190)
(set-face-attribute 'mode-line-inactive nil :height 190)

(tool-bar-mode -1)                        ; hide the graphical toolbar
(scroll-bar-mode -1)                      ; hide the scrollbars
(global-eldoc-mode -1)                    ; no auto type-info in the bottom line
(column-number-mode 1)                    ; show column in mode line
(global-display-line-numbers-mode 1)      ; line numbers everywhere
(global-auto-revert-mode 1)               ; reload files changed outside Emacs
(recentf-mode 1)                          ; recent files
(global-set-key (kbd "M-g i") #'imenu)    ; jump to function/section
(show-paren-mode 1)                       ; match parenthesis
(ido-mode 1)                              ; show files in C-x C-f

;;; THEME (alabaster dark-mono + C-c t toggle)
(use-package alabaster-themes
  :config
  (setq alabaster-themes-no-bold t)
  (setq alabaster-themes-dark-mono-palette-overrides
        '((bg-region "#CD974B")   ; amber selection, same as cursor
          (fg-region "#0E1415"))) ; near-black text on amber
  (mapc #'disable-theme custom-enabled-themes) ; wipe any stacked themes
  (load-theme 'alabaster-themes-dark-mono t))

(defvar ja/dark-theme  'alabaster-themes-dark-mono "Coding theme.")
(defvar ja/light-theme 'alabaster-themes-light    "Writing theme.")
(defvar ja/current-theme ja/dark-theme "Currently active theme.")

(defun ja/toggle-theme ()
  "Switch between the dark (coding) and light (writing) themes."
  (interactive)
  (disable-theme ja/current-theme)
  (setq ja/current-theme
        (if (eq ja/current-theme ja/dark-theme) ja/light-theme ja/dark-theme))
  (load-theme ja/current-theme t)
  (message "Theme: %s" ja/current-theme))
(global-set-key (kbd "C-c t") #'ja/toggle-theme)
