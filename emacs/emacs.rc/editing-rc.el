;;; editing-rc.el --- multiple cursors + expand-region  -*- lexical-binding: t; -*-

(use-package multiple-cursors
  :bind (("C->"     . mc/mark-next-like-this)        ; select next match (1st press selects word at point)
         ("C-<"     . mc/mark-previous-like-this)    ; select previous match
         ("C-c C->" . mc/mark-all-like-this)         ; cursor on ALL matches
         ("C-c m e" . mc/edit-lines)                 ; cursor on every line in region
         ("C-c m s" . mc/skip-to-next-like-this)     ; skip match under cursor
         ("C-c m r" . mc/skip-to-previous-like-this) ; skip backwards
         ("C-c m n" . mc/cycle-forward)              ; jump to next selected match
         ("C-c m p" . mc/cycle-backward)             ; jump to previous selected match
         ("C-S-<mouse-1>" . mc/add-cursor-on-click))) ; extra cursor where you click

(use-package expand-region
  :bind (("C-=" . er/expand-region)       ; grow selection: word -> "string" -> (sexp) -> ...
         ("C--" . er/contract-region)))   ; shrink back

(use-package move-text
  :ensure t
  :config
  (move-text-default-bindings))  ; M-<up> / M-<down>

(defun ja/duplicate-line ()
  "Duplicate current line"
  (interactive)
  (let ((column (- (point) (point-at-bol)))
        (line (let ((s (thing-at-point 'line t)))
                (if s (string-remove-suffix "\n" s) ""))))
    (move-end-of-line 1)
    (newline)
    (insert line)
    (move-beginning-of-line 1)
    (forward-char column)))
(global-set-key (kbd "C-,") 'ja/duplicate-line)
