;;; org-rc.el --- Org: capture, projects, journal, agenda, git sync  -*- lexical-binding: t; -*-

;;; NOTION LOOK (kept from before)
(set-face-attribute 'variable-pitch nil :family "Georgia")
(setq org-hide-emphasis-markers t)

(use-package org-modern
  :custom
  (org-modern-star nil)          ; no fold/replacement symbols on headings
  (org-modern-hide-stars t))     ; hide the stars completely

(setq org-ellipsis " ▾")         ; clean fold indicator (glyph is widely covered)

;;; FILE LAYOUT
;; inbox.org     — raw capture staging; refile out of it (C-c C-w)
;; tasks.org     — standalone tasks (related to nothing)
;; projects.org  — projects (:project: tag) and their sub-tasks
;; journal.org   — datetree daily log
(setq org-directory (expand-file-name "~/org"))
(setq org-agenda-files
      (mapcar (lambda (f) (expand-file-name f org-directory))
              '("inbox.org" "tasks.org" "projects.org" "journal.org")))

;;; TODO STATES (fast keys: C-c C-t then the letter)
;; TODO -> IN-PROGRESS -> WAITING / QA / NOT-ON-PROD -> DONE / CANCELLED
;; Projects use the SAME states; a project is just a headline tagged :project:.
(setq org-todo-keywords
      '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAITING(w@/!)" "QA(q)" "NOT-ON-PROD(n)"
                  "|" "DONE(d!)" "CANCELLED(c!)")))

(setq org-log-done 'time)                   ; CLOSED stamp when marked DONE
(setq org-log-into-drawer t)                ; state-change notes go in LOGBOOK

;; The project tag stays on the headline it was set on — sub-tasks of a
;; project must NOT inherit it, or agenda filters would leak both ways.
(setq org-tags-exclude-from-inheritance '("project"))

;; Progress cookies ([2/5]) on projects count ALL descendant tasks, not just
;; direct children (projects have Tasks grouped under a "Tasks" heading).
(setq org-hierarchical-todo-statistics nil)

;;; UPDATED STAMPS — the visibility mechanism
;; Every TODO headline carries an *active* timestamp right under the drawer:
;;
;;   UPDATED: <2026-11-04 Wed 16:20>
;;
;; The calendar timeline shows events: journals (on their day) and project
;; headlines (on the day they or their tasks last progressed).  Sub-tasks
;; don't appear in the calendar themselves — the project's [n/m] progress
;; cookie carries their status.  Stamps are maintained automatically below.
(defun ja/org-updated-stamp ()
  "Return an `UPDATED:' line with the current active timestamp."
  (format-time-string "UPDATED: <%Y-%m-%d %a %H:%M>"))

(defun ja/org-refresh-stamp ()
  "Insert or refresh the active UPDATED stamp on the headline at point."
  (org-back-to-heading t)
  (org-end-of-meta-data)        ; past property drawer / planning line
  (if (looking-at "UPDATED: +<[^>\n]*>")
      (replace-match (ja/org-updated-stamp) t t)
    (insert (ja/org-updated-stamp) "\n")))

(defun ja/org-touch-entry ()
  "Refresh the UPDATED stamp on the entry at point and on its project."
  (save-excursion
    (when (org-entry-get (point) "TODO")
      (ja/org-refresh-stamp)               ; the changed entry itself
      (catch 'found                        ; and its :project: ancestor, so
        (while (org-up-heading-safe)       ; the project shows on active days
          (when (member "project" (org-get-tags))
            (ja/org-refresh-stamp)
            (throw 'found nil)))))))

(add-hook 'org-after-todo-state-change-hook #'ja/org-touch-entry)

;;; CAPTURE (C-c c, then t / i / p / j / n)
(setq org-capture-templates
      '(("t" "Task (standalone)" entry
         (file+headline "tasks.org" "Tasks")
         "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\nUPDATED: <%<%Y-%m-%d %a %H:%M>>\n")
        ("i" "Inbox item (unprocessed)" entry
         (file+headline "inbox.org" "Inbox")
         "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\nUPDATED: <%<%Y-%m-%d %a %H:%M>>\n")
        ("p" "Project plan" entry
         (file "projects.org")
         "* TODO %^{Project title} [/] :project:\n:PROPERTIES:\n:CREATED: %U\n:END:\nUPDATED: <%<%Y-%m-%d %a %H:%M>>\n\n*Problem:* %^{Problem statement}\n\n** Goals\n- %^{First goal}\n- \n\n** Milestones\n*** TODO %^{First milestone}\n\n** Tasks\n*** TODO %?\n")
        ("j" "Journal / daily log" entry
         (file+datetree "journal.org")
         "* %?\n<%<%Y-%m-%d %a %H:%M>>\n")
        ("n" "Note" entry
         (file+headline "notes.org" "Notes")
         "** %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")))

;;; RELATIONS
;; parent-child headline = "belongs to this project".
;; loose relations = org-id links: C-c l on a headline, C-c C-l to insert
;; [[id:...][title]] anywhere (tasks <-> tasks, task <-> project, ...).
(require 'org-id)
(setq org-id-link-to-org-use-id t)          ; C-c l on a headline -> stable id link
(global-set-key (kbd "C-c l") #'org-store-link)

;;; REFILING (C-c C-w from inbox -> project headlines)
(setq org-refile-targets '((org-agenda-files :maxlevel . 3)))
(setq org-refile-use-outline-path 'file)    ; shows "projects.org > Manual Release > ..."
(setq org-outline-path-complete-in-steps t)

;;; ARCHIVING (C-c C-x a on done items)
(setq org-archive-location "~/org/archive/%s_archive::")

;;; AGENDA LINE PREFIXES
(defun ja/org-entry-date (prop)
  "Return the YYYY-MM-DD part of property PROP (a timestamp), or empty."
  (let ((v (org-entry-get (point) prop)))
    (if (and v (string-match "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}" v))
        (match-string 0 v)
      "")))

(defun ja/org-body-updated ()
  "Return the YYYY-MM-DD of the UPDATED stamp in this entry's own body."
  (save-excursion
    (org-back-to-heading t)
    (let ((end (save-excursion (outline-next-heading) (point))))
      (if (re-search-forward "^UPDATED: <\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)"
                             end t)
          (match-string 1)
        ""))))

(defun ja/agenda-dates ()
  "Agenda prefix: created date + done (CLOSED) or last-updated date."
  (let ((closed (ja/org-entry-date "CLOSED")))
    (format "%-11s %-11s "
            (ja/org-entry-date "CREATED")
            (if (> (length closed) 0) closed (ja/org-body-updated)))))

(defun ja/agenda-task-prefix ()
  "Prefix for task lines: parent project title, else the file category."
  (save-excursion
    (let (title)
      (while (and (not title) (org-up-heading-safe))
        (when (member "project" (org-get-tags))
          ;; title without the [n/m] progress cookie
          (setq title (replace-regexp-in-string "\\[[0-9/%]*\\]" ""
                                                (org-get-heading t t t t)))))
      (format "%-16s " (or title (org-get-category))))))

;;; CUSTOM AGENDA VIEWS
(defconst ja/org-open-states "TODO\\|IN-PROGRESS\\|WAITING\\|QA\\|NOT-ON-PROD")
(defconst ja/org-active-states "IN-PROGRESS\\|WAITING\\|QA\\|NOT-ON-PROD")

;; The calendar timeline is an EVENTS view: journals on their day, project
;; headlines on the day they last progressed.  Plain tasks (standalone and
;; project sub-tasks) don't belong there — they live in the state blocks.
;; Explicit SCHEDULED/DEADLINE dates still show: you asked for that day.
(defun ja/skip-tasks-in-agenda ()
  "Skip non-project TODO entries in the calendar timeline."
  (when (and (org-entry-get (point) "TODO")
             (not (member "project" (org-get-tags)))
             (not (or (org-entry-get (point) "SCHEDULED")
                      (org-entry-get (point) "DEADLINE"))))
    (save-excursion (org-end-of-subtree t) (point))))

(defun ja/project-block (matcher header)
  "Return an agenda block listing projects matching MATCHER."
  `(tags-todo ,matcher
              ((org-agenda-overriding-header ,header)
               (org-agenda-prefix-format " %(ja/agenda-dates) %-14:c"))))

(defun ja/project-status-blocks ()
  "Blocks: open / in-progress / done projects, with created + done dates."
  (list (ja/project-block "+project/TODO" "Projects — open (not started)")
        (ja/project-block (concat "+project/" ja/org-active-states)
                          "Projects — in progress")
        (ja/project-block "+project/DONE\\|CANCELLED" "Projects — done")))

(setq org-agenda-custom-commands
      `(("d" "Dashboard — month calendar (events) + projects"
         ((agenda "" ((org-agenda-span 'month)
                      ;; start on the 1st of the current month (calendar-like)
                      (org-agenda-start-day (format-time-string "%Y-%m-01"))
                      (org-agenda-skip-function #'ja/skip-tasks-in-agenda)))
          ,@(ja/project-status-blocks)))
        ("w" "Week/day review — events above, tasks below (v d / v w toggles span)"
         ((agenda "" ((org-agenda-span 'week)
                      (org-agenda-skip-function #'ja/skip-tasks-in-agenda)))
          (tags-todo "-project/IN-PROGRESS"
                     ((org-agenda-overriding-header "Tasks — in progress")
                      (org-agenda-prefix-format " %(ja/agenda-task-prefix)")))
          (tags-todo "-project/WAITING"
                     ((org-agenda-overriding-header "Tasks — waiting")
                      (org-agenda-prefix-format " %(ja/agenda-task-prefix)")))
          (tags-todo "-project/TODO"
                     ((org-agenda-overriding-header "Tasks — todo")
                      (org-agenda-prefix-format " %(ja/agenda-task-prefix)")))))
        ("p" "Projects — open / in progress / done"
         ,(ja/project-status-blocks))))

;; ad-hoc queries: C-c a m then a matcher, e.g.
;;   +project          all projects
;;   +project/TODO     projects not started
;;   -project/TODO     all open tasks (standalone + sub-tasks)

(setq org-stuck-projects
      '("+project/TODO\\|IN-PROGRESS\\|WAITING\\|QA\\|NOT-ON-PROD"
        ("TODO" "IN-PROGRESS" "WAITING" "QA" "NOT-ON-PROD") nil ""))

(setq org-agenda-span 'week)                ; plain C-c a a also shows a week

;;; DATES: display DD/MM/YYYY (stored text stays ISO)
(setq calendar-date-style 'european)        ; date prompts parse day-first (5/10 = 5 Oct)
(setq org-timestamp-custom-formats
      '("<%d/%m/%Y>" . "<%d/%m/%Y %H:%M>")) ; date-only / date+time stamps
(setq org-display-custom-times t)           ; switch the custom display on everywhere

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
