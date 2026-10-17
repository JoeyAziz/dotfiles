;;; org-rc.el --- Org: capture, projects, journal, agenda, git sync  -*- lexical-binding: t; -*-

;;; NOTION LOOK (kept from before)
(set-face-attribute 'variable-pitch nil :family "Georgia")
(setq org-hide-emphasis-markers t)

;; org-modern-mode is enabled in hooks-rc.el with the other mode hooks
(use-package org-modern)

;;; FILE LAYOUT
(setq org-directory (expand-file-name "~/org"))
(setq org-agenda-files
      (mapcar (lambda (f) (expand-file-name f org-directory))
              '("inbox.org" "projects.org" "journal.org")))

;;; TODO STATES (fast keys in parens: C-c C-t then the letter)
(setq org-todo-keywords
      '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAITING(w@/!)" "|" "DONE(d!)" "CANCELLED(c)")
        (sequence "PROJ(p)" "|")))

(setq org-log-done 'time)                   ; stamp time when marked DONE
(setq org-log-into-drawer t)                ; state-change notes go in LOGBOOK

;;; DATES: display DD/MM/YYYY (stored text stays ISO)
(setq calendar-date-style 'european)        ; date prompts parse day-first (5/10 = 5 Oct)
(setq org-timestamp-custom-formats
      '("<%d/%m/%Y>" . "<%d/%m/%Y %H:%M>")) ; date-only / date+time stamps
(setq org-display-custom-times t)           ; switch the custom display on everywhere

;;; CAPTURE TEMPLATES (C-c c, then t/p/j/n)
(setq org-capture-templates
      `(("t" "Task" entry
         (file+headline "inbox.org" "Inbox")
         "** TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
        ("p" "Project" entry
         (file "projects.org")
         "* PROJ %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n** TODO break it down\n")
        ("j" "Journal / daily log" entry
         (file+datetree "journal.org")
         "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
        ("n" "Note" entry
         (file+headline "notes.org" "Notes")
         "** %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")))

;;; REFILING (C-c C-w from inbox -> project headlines)
(setq org-refile-targets '((org-agenda-files :maxlevel . 3)))
(setq org-refile-use-outline-path 'file)    ; shows "projects.org > Manual Release > ..."
(setq org-outline-path-complete-in-steps t)

;;; ARCHIVING (C-c C-x a on done items)
(setq org-archive-location "~/org/archive/%s_archive::")

;;; CUSTOM AGENDA VIEWS
(setq org-agenda-custom-commands
      '(("w" "Week review"
         ((agenda "" ((org-agenda-span 'week)))
          (todo "IN-PROGRESS")
          (todo "WAITING")
          (todo "TODO")))
        ("p" "Active projects"
         ((stuck "")                        ; projects with no open sub-tasks
          (todo "PROJ")))))

(setq org-stuck-projects
      '("TODO=\"PROJ\"" ("TODO" "IN-PROGRESS" "WAITING") nil ""))

(setq org-agenda-span 'week)                ; plain C-c a a also shows a week

;;; GLOBAL KEYS (the Org-recommended bindings)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c a") #'org-agenda)

;;; GIT SYNC (C-c s) — pull, commit everything, push. Soft-fails offline.
(defun ja/org-sync ()
  "Sync ~/org: git pull --rebase, add+commit all, push."
  (interactive)
  (let ((default-directory org-directory)
        (buf (get-buffer-create "*org-sync*"))
        (msg (format "sync from %s — %s"
                     (system-name)
                     (format-time-string "%Y-%m-%d %H:%M"))))
    (unless (file-exists-p ".git")
      (user-error "~/org is not a git repo yet"))
    (dolist (args `(("pull" "--rebase" "--autostash")
                    ("add" "-A")
                    ("commit" "-m" ,msg)
                    ("push")))
      (with-current-buffer buf (erase-buffer))
      (let ((ok (zerop (apply #'call-process "git" nil buf nil args))))
        (unless (or ok
                    (and (equal (car args) "commit")
                         (with-current-buffer buf
                           (goto-char (point-min))
                           (re-search-forward
                            "nothing to commit\\|no changes" nil t))))
          (pop-to-buffer buf)
          (user-error "org sync failed at: git %s" (car args)))))
    (message "org sync: done")))
(global-set-key (kbd "C-c s") #'ja/org-sync)
