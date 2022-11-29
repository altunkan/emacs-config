;; anil altunkan emacs setup
;; constants
(defconst regexp-file-ext "^[a-z0-9A-Z]?+\\.%s$")

;; arch
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/"))
(package-initialize)

;; requires
(require 'package)
(require 'ido)
(require 'org)
(require 'calc-ext)
(require 'compile)
(require 'cc-mode)

;; defadvices
(defadvice set-mark-command (after no-bloody-t-m-m activate)
  (if transient-mark-mode (setq transient-mark-mode nil)))
(defadvice ibuffer
    (around ibuffer-point-to-most-recent) ()
    "Open ibuffer with cursor pointed to most recent buffer name."
    (let ((recent-buffer-name (buffer-name)))
      ad-do-it
      (ibuffer-jump-to-buffer recent-buffer-name)))

;; common variables
(setq ring-bell-function 'ignore
      undo-limit 20000000
      undo-strong-limit 40000000
      use-dialog-box nil
      help-window-select t
      history-length 25
      enable-local-variables nil
      display-time-day-and-date 1
      ido-auto-merge-work-directories-length -1
      use-short-answers t
      confirm-nonexistent-file-or-buffer nil
      ido-create-new-buffer 'always
      frame-title-format "%b (%f)"
      dired-kill-when-opening-new-dired-buffer t
      aa-notes-file-path "~/thd/thd_doc/aa_notes.org"
      aa-todo-file-path "~/thd/thd_doc/aa_todo.org"
      aa-thd-file-path "~/thd/thd_doc/aa_thd.org"
      aa-journal-file-path "~/thd/thd_doc/aa_journal.org"
      yas-snippet-dirs '("~/.emacs.d/aa-snippets")
      kill-buffer-query-functions (remq 'process-kill-buffer-query-function kill-buffer-query-functions))

;; global modes
(ido-mode t)
(recentf-mode 1)
(global-hl-line-mode 1)
(global-auto-revert-mode 1) 
(savehist-mode 1)
(scroll-bar-mode -1)
(tool-bar-mode 0)
(save-place-mode 1)
(global-display-line-numbers-mode 1)
(display-time)
(split-window-horizontally)
(column-number-mode 1)
(put 'erase-buffer 'disabled nil)
(ad-activate 'ibuffer)
(put 'dired-find-alternate-file 'disabled nil)
(yas-global-mode 1)
(yas-reload-all)

;; functions
(defun post-load-stuff ()
  (interactive)
  (menu-bar-mode -1)
  (toggle-frame-fullscreen))
(defun org-copy-src-block ()
  (interactive)
  (search-backward "#+begin_src")
  (forward-line)
  (push-mark)
  (search-forward "#+end_src")
  (forward-line -1)
  (move-end-of-line 1)
  (copy-region-as-kill (mark) (point)))
(defun previous-blank-line ()
  (interactive)
  (search-backward-regexp "^[ \t]*\n" nil 1))
(defun next-blank-line ()
  (interactive)
  (forward-line)
  (search-forward-regexp "^[ \t]*\n" nil 1)
  (forward-line -1))
(defun recentf-open-files-other-window ()
  (interactive)
  (other-window 1)
  (recentf-open-files))
(defun append-as-kill ()
  (interactive)
  (append-next-kill) 
  (copy-region-as-kill (mark) (point)))
(defun gcloud-login ()
  (interactive)
  (compile "$AA_SHELL/gcloud_login.sh"))
(defun eshell-other-window ()
  (interactive)
  (other-window 1)
  (eshell))
(defun instant-switch-to-buffer ()
  (interactive)
  (switch-to-buffer (other-buffer)))
(defun jump-to-other-window-end-of-buffer ()
  (interactive)
  (other-window 1)
  (end-of-buffer))
(defun duplicate-line ()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank))
(defun copy-region-without-kill ()
  (interactive)
  (save-excursion
    (move-beginning-of-line 1)
    (push-mark)
    (move-end-of-line 1)
    (copy-region-as-kill (mark) (point))))
(defun copy-region-without-kill-from-point ()
  (interactive)
  (save-excursion
    (push-mark)
    (move-end-of-line 1)
    (copy-region-as-kill (mark) (point))))
(defun aa-go-mode-hook ()
  (add-hook 'before-save-hook 'gofmt-before-save)
  (setq tab-width 2 indent-tabs-mode 1))
(defun aa-c++-mode-hook ()
  (hs-minor-mode))
(defun aa-compile-c++ ()
  (interactive)
  (save-buffer)
  (unless (file-exists-p "Makefile")
    (let* ((compiler "clang++")
	   (compiler-version "c++17")
	   (src (file-name-nondirectory (buffer-file-name)))
	   (cc (string-join (directory-files "." nil (format regexp-file-ext "cc")) " "))
	   (cpp (string-join (directory-files "." nil (format regexp-file-ext "cpp")) " "))
	   (obj (file-name-sans-extension src)))
      (compile (format "%s -std=%s -Wall -pedantic-errors %s %s -o %s && ./%s" compiler compiler-version cc cpp obj obj) t))))
(defun aa-compile-shell ()
  (interactive)
  (save-buffer)
  (let ((src (file-name-nondirectory (buffer-file-name))))
    (compile (format "sh %s" src)) t))
(defun aa-compile ()
  (interactive)
  (save-buffer)
  (cond
   ((eq major-mode 'c++-mode) (aa-compile-c++))
   ((eq major-mode 'sh-mode) (aa-compile-shell)))
  )
(defun empty-buffer ()
  (interactive)
  (switch-to-buffer (generate-new-buffer "Untitled")))
(defun copy-whole-buffer ()
  (interactive)
  (clipboard-kill-ring-save (point-min) (point-max)))
(defun kill-compilation-buffer ()
  (interactive)
  (kill-buffer "*compilation*"))
(defun kill-other-buffer ()
  (interactive)
  (other-window 1)
  (kill-this-buffer)
  (other-window 1))
(defun toggle-selective-display (column)
  (interactive "P")
  (set-selective-display
   (or column
       (unless selective-display
         (1+ (current-column))))))
(defun toggle-hiding (column)
  (interactive "P")
  (if hs-minor-mode
      (if (condition-case nil
              (hs-toggle-hiding)
            (error t))
          (hs-show-all))
    (toggle-selective-display column)))
(defun kill-other-buffers ()
  (interactive)
  (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))
(defun which-active-modes ()
  (interactive)
  (let ((active-modes))
    (mapc (lambda (mode) (condition-case nil
                             (if (and (symbolp mode) (symbol-value mode))
                                 (add-to-list 'active-modes mode))
                           (error nil) ))
          minor-mode-list)
    (message "Active modes are %s" active-modes)))

;; org mode variables
(setq org-agenda-start-with-log-mode t)
(setq org-log-done 'time)
(setq org-log-into-drawer t)
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline aa-todo-file-path "Tasks") "* TODO %?\n")
	("h" "Todo Headline" entry (file+headline aa-todo-file-path "Tasks") "* TODO %?\n %i %a")
        ("j" "Journal" entry (file+datetree aa-journal-file-path) "* %?\nEntered on %U\n  %i\n  %a")))
(setq org-agenda-files `(,aa-notes-file-path ,aa-todo-file-path ,aa-journal-file-path))

;; visuals + modus-vivendi
(setq modus-themes-mode-line '(accented borderless padded)
      modus-themes-region '(accented no-extend)
      modus-themes-completions 'opinionated
      modus-themes-bold-constructs t
      modus-themes-italic-constructs t
      modus-themes-paren-match '(bold intense)
      modus-themes-org-blocks 'tinted-background
      modus-themes-hl-line '(intense accented)
      modus-themes-subtle-line-numbers t
      modus-themes-syntax '(alt-syntax yellow-comments)
      modus-themes-mixed-fonts t
      modus-themes-links '(faint)
      modus-themes-paren-match '(bold intense)
      modus-themes-org-blocks 'gray-background
      modus-themes-headings
      '((1 . (overline variable-pitch 1.5))
        (2 . (overline rainbow 1.3))
        (3 . (overline 1.1))
        (t . (monochrome))))

(set-face-attribute 'default nil :family "Fira Code" :height 160)
(load-theme 'modus-vivendi t)

;; meta global bindings
(define-key global-map "\e " 'set-mark-command)
(define-key global-map (kbd "M-s") 'save-buffer)
(define-key global-map (kbd "M-r") 'revert-buffer)
(define-key global-map (kbd "M-k") 'kill-this-buffer)
(define-key global-map (kbd "M-K") 'kill-other-buffer)
(define-key global-map (kbd "M-w") 'other-window)
(define-key global-map (kbd "M-0") 'delete-window)
(define-key global-map (kbd "M-b") 'ido-switch-buffer)
(define-key global-map (kbd "M-B") 'ido-switch-buffer-other-window)
(define-key global-map (kbd "M-f") 'find-file)
(define-key global-map (kbd "M-F") 'find-file-other-window)
(define-key global-map (kbd "M-[") 'copy-region-without-kill)
(define-key global-map (kbd "M-]") 'copy-region-without-kill-from-point)
(define-key global-map (kbd "M-;") 'exchange-point-and-mark)
(define-key global-map (kbd "M-g") 'goto-line)
(define-key global-map (kbd "M-`") 'eshell)
(define-key global-map (kbd "M-~") 'eshell-other-window)
(define-key global-map (kbd "M-!") 'eshell-command)
(define-key global-map (kbd "M-@") 'gcloud-login)
(define-key global-map (kbd "M-1") 'delete-other-windows)
(define-key global-map (kbd "M-2") 'split-window-right)
(define-key global-map (kbd "M-3") 'split-window-below)
(define-key global-map (kbd "M-o") 'instant-switch-to-buffer)
(define-key global-map (kbd "M-u") 'undo)
(define-key global-map (kbd "M-8") 'upcase-word)
(define-key global-map (kbd "M-*") 'capitalize-word)
(define-key global-map (kbd "M-p") 'recentf-open-files)
(define-key global-map (kbd "M-P") 'recentf-open-files-other-window)
(define-key global-map (kbd "M-n") 'copy-whole-buffer)
(define-key global-map (kbd "M-.") 'jump-to-other-window-end-of-buffer)
(define-key global-map (kbd "M-z") 'kill-other-buffers)
(define-key global-map (kbd "<M-return>") 'empty-buffer)
(define-key global-map (kbd "<M-up>") 'previous-blank-line)
(define-key global-map (kbd "<M-down>") 'next-blank-line)
(define-key global-map (kbd "M-4") (lambda () (interactive) (find-file aa-notes-file-path)))
(define-key global-map (kbd "M-$") (lambda () (interactive) (find-file-other-window aa-notes-file-path)))
(define-key global-map (kbd "M-5") (lambda () (interactive) (find-file aa-todo-file-path)))
(define-key global-map (kbd "M-%") (lambda () (interactive) (find-file-other-window aa-todo-file-path)))
(define-key global-map (kbd "M-6") (lambda () (interactive) (find-file aa-journal-file-path)))
(define-key global-map (kbd "M-^") (lambda () (interactive) (find-file-other-window aa-journal-file-path)))
(define-key global-map (kbd "M-7") (lambda () (interactive) (find-file aa-thd-file-path)))
(define-key global-map (kbd "M-&") (lambda () (interactive) (find-file-other-window aa-thd-file-path)))

;; Meta Org Bindings
(define-key org-mode-map (kbd "<M-up>") nil)
(define-key org-mode-map (kbd "<M-down>") nil)
(define-key org-mode-map (kbd "<M-left>") nil)
(define-key org-mode-map (kbd "<M-right>") nil)
(define-key org-mode-map (kbd "<M-S-left>") nil)
(define-key org-mode-map (kbd "<M-S-right>") nil)
(define-key org-mode-map (kbd "<M-S-up>") nil)
(define-key org-mode-map (kbd "<M-S-down>") nil)
(define-key org-mode-map (kbd "C-M-q") 'org-copy-src-block)

;; ctrl global bindings
(define-key global-map (kbd "C-q") 'copy-region-as-kill)
(define-key global-map (kbd "C-f") 'yank)
(define-key global-map (kbd "C-y") 'rotate-yank-pointer)
(define-key global-map (kbd "C-t") 'duplicate-line)
(define-key global-map (kbd "C-c l") 'org-agenda-list)
(define-key global-map (kbd "C-c a") 'org-agenda)
(define-key global-map (kbd "C-c c") 'org-capture)
(define-key global-map (kbd "<C-return>") 'hs-toggle-hiding)
(define-key global-map (kbd "C-=") 'hs-hide-all)
(define-key global-map (kbd "C-+") 'hs-show-all)
(define-key global-map (kbd "M-c") 'aa-compile)
(define-key global-map (kbd "M-C") 'kill-compilation-buffer)
(define-key global-map (kbd "C-x C-b") 'ibuffer)
;; (define-key global-map (kbd "<C-return>") 'toggle-hiding)
;; (define-key global-map (kbd "<C-S-return>") 'toggle-selective-display)
;; (define-key global-map (kbd "<C-return>") 'hs-hide-block)
;; (define-key global-map (kbd "<C-S-return>") 'hs-show-block)

;; generic global bindings
(define-key global-map (kbd "<f5>") 'modus-themes-toggle)

;; hooks
(add-hook 'window-setup-hook 'post-load-stuff t)
(add-hook 'dired-mode-hook 'auto-revert-mode)
(add-hook 'go-mode-hook 'aa-go-mode-hook)
(add-hook 'json-mode-hook 'hs-minor-mode)
(add-hook 'c++-mode-hook 'aa-c++-mode-hook)

(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessaege)
