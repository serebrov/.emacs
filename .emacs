(autoload 'fennel-mode "~/web/fennel-mode-recent/fennel-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.fnl\\'" . fennel-mode))

;; increase font size (the number is 1/10, 150 is 15px)
(set-face-attribute 'default nil :height 150)

; don't use tabs for indent
(setq-default indent-tabs-mode nil)

;; https://www.shaneikennedy.xyz/blog/emacs-intro

;; Load kickstart (some settings + evil mode)
(load "~/.emacs.conf/init")

;; Note: the below triggers an error on launch, saying
;; that there is no "init" function.
;; This still triggers the config loading because
;; the autoload statement tells Emacs: "When someone calls the
;; function init, load the file ~/.config/emacs/init.el and
;; expect to find a function named init defined there."
;; (autoload 'init "~/.config/emacs/init" nil t)
;; (init)

;; (eval '(load "~/.config/emacs/init"))

;; Evaluate below to see which files are loaded during startup
;; (mapconcat 'car (reverse load-history) "\n")

;; Run lisp with prompt:
;; M-x my-run-lisp-with-prompt
(defun my-run-lisp-with-prompt ()
  "Always prompt for which Lisp to run."
  (interactive)
  (run-lisp t))

;; Auto-save and restore the session
;; How it works:
;;  - Emacs automatically saves your session when you quit
;;  - Automatically restores it when you start Emacs
;;  - Saves to ~/.emacs.d/.emacs.desktop by default
;;
(desktop-save-mode 1)
;; Disable startup screen so desktop can restore properly
(setq inhibit-startup-screen t)
;; Customize what gets saved
(setq desktop-restore-frames t)        ;; Restore window configuration
(setq desktop-restore-in-current-display t)
(setq desktop-restore-forces-onscreen t)
;;
;;  Manual save/restore:
;;  M-x desktop-save RET ~/my-project/ RET    ;; Save session to directory
;;  M-x desktop-change-dir RET ~/my-project/ RET  ;; Load session from directory
;; M-x desktop-read RET ;; Load session from last saved location
;;
;;  To restore a specific session on startup:
;;  emacs --eval "(desktop-change-dir \"~/my-project/\")"

;; With projectile (installed via kickstart config)
;; M-x projectile-save-project-buffers    ;; Save
;; M-x projectile-switch-project          ;; Restores last session when switching

;; Problem (solved): when the kickstart config is uncommented and I
;; run the C-u M-x run-lisp in the fennel file,
;; it does not ask me which lisp to run anymore
;; and just starts fennel repl (I want to be able to replace it
;; with ~/love .)
;;
;; This is because we have C-u re-map'ed by evil mode to scroll
;; in the ~/.config/emacs/init.el there is this:
;;
;;  (evil-want-C-u-scroll t)      ;; Set C-u to scroll up
;;
;; As a result C-u M-x run lisp turns into "M-x run-lisp"
;; and it just starts "fennel --repl" without a prompt.
;;
;; The C-u is bind to the emacs `(universal-argument)` prefix
;; that modifies the behavior of the next command.
;; The modified behavior depends on the command being invoked
;; and in the case of M-x it is to show the prompt before executing
;; the requested command.
;;   For example:
;;   - M-x save-buffer - saves the buffer
;;   - C-u M-x save-buffer - asks which file to save to
;;
;; The `run-lisp` command accepts any argument (if it has an any argument then
;; it shows the prompt), so we can also use other prefixes instead of C-u
;; and the following commands will also work:
;;
;; M-1 M-x run-lisp
;; C-1 M-x run-lisp
;; 
;; One more method: temporarily disable evil-mode - Press C-z to
;; switch to Emacs state, then use C-u M-x run-lisp
;;
;; One more method: call `run-lisp` as lisp expression:
;; M-: (run-lisp "~/love .")
;;
;; Note: prefixes system works like this
;; For example for `forward-char` command (move cursor forward)
;;
;;- C-f or M-x forward-char → moves forward 1 character
;;- M-5 C-f → moves forward 5 characters
;;- C-u 10 C-f → moves forward 10 characters
;;- C-u C-f → moves forward 4 characters (C-u alone defaults to 4)
;;
;; The run-lisp function's code basically does this:
;;  (defun run-lisp (arg)
;;    (interactive "P")  ;; "P" means "accept a prefix argument"
;;    (if arg
;;        ;; If ANY argument was passed, prompt user
;;        (read-string "Run lisp: " inferior-lisp-program)
;;      ;; Otherwise use default
;;      inferior-lisp-program))
;;
;; Functions can use the argument like this:
;;  (defun my-command (arg)
;;    (interactive "P")
;;    (cond
;;     ((null arg) (message "No argument"))
;;     ((= arg 1) (message "You passed 1!"))
;;     ((= arg 2) (message "You passed 2!"))
;;     ((= arg 4) (message "You pressed C-u"))
;;     (t (message "You passed: %d" arg))))
;;
;; Functions can also have multiple agruments.
;; The prefix argument (M-6, C-u, etc.) is special - it's
;; captured before the command runs and is separate from other
;; arguments. All other arguments are gathered by prompting the
;; user through the minibuffer.
;;
;; So when you do:
;; M-5 M-x replace-string RET foo RET bar RET
;;
;; - M-5 sets a prefix argument (which replace-string might use
;; to limit replacements, depending on the command)
;; - Then it prompts for "foo"
;; - Then it prompts for "bar"
;;
;; To pass a negative argument use `C--5 ...` or `M--5 ...`
;; `C-- ...` works as `-1` (same for `M-- ...`).
;; Also can use `C-u -5 ...` and `C-u - ...`.
;;
;; For example the evil-state-emacs needs a negative argument to be
;; disabled: `C-u - C-z` (C-z in evil is bound to evil-state-emacs).

;; Problem: ESC closes other windows
;; I hit ESC often when I am trying to get rid of something and
;; end up having all other splits (windows) closed
;;
;; We can see how it wors with C-h k ESC (in Emacs mode, not in evil)
;; It shows help for keyboard-escape-quit
;; keyboard-escape-quit is an interactive and byte-compiled function
;; defined in simple.el.gz.
;; The function, besides other things has
;;	((not (one-window-p t))
;;	 (delete-other-windows))
;; Which is the problem. Redefine it:
(defun keyboard-escape-quit-safe ()
  (interactive)
  (cond ((eq last-command 'mode-exited) nil)
	((region-active-p)
	 (deactivate-mark))
	((> (minibuffer-depth) 0)
	 (abort-recursive-edit))
	(current-prefix-arg
	 nil)
	((> (recursion-depth) 0)
	 (exit-recursive-edit))
	(buffer-quit-function
	 (funcall buffer-quit-function))
	;; ((not (one-window-p t))
	;;  (delete-other-windows))
	((string-match "^ \\*" (buffer-name (current-buffer)))
	 (bury-buffer))))
(global-set-key (kbd "<escape>") 'keyboard-escape-quit-safe)
;; Note that a better approach is to use advice (I use the above because
;; it is more straighforward for now)
;; see https://www.reddit.com/r/emacs/comments/10l40yi/comment/j5usr8i/
;; (defun +keyboard-escape-quit-adv (fun)
;;   "Around advice for `keyboard-escape-quit' FUN.
;; Preserve window configuration when pressing ESC."
;;   (let ((buffer-quit-function (or buffer-quit-function #'ignore)))
;;     (funcall fun)))
;; (advice-add #'keyboard-escape-quit :around #'+keyboard-escape-quit-adv)

;; enable winner mode by default
(setq winner-dont-bind-my-keys t)
(winner-mode)

(elisp-slime-nav-mode)

;; Alternative for pdf-tools:
;; https://www.reddit.com/r/emacs/comments/1pgliu9/a_new_pdf_reader_for_emacs/
;; https://codeberg.org/divyaranjan/emacs-reader
;; (setq package-vc-allow-build-commands t)
;; (use-package reader
;;   :vc (:url "https://codeberg.org/divyaranjan/emacs-reader"
;;        :make "all"))

;; From https://www.reddit.com/r/emacs/comments/1kpjuha/comment/msyqk50/
(use-package pdf-tools
  :defer t
  :magic ("%PDF" . pdf-view-mode) ;; ensure DocView is not used
  :config
  (pdf-tools-install :no-query)
  (setq-default pdf-view-display-size 'fit-width)
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward)
  :custom
  (pdf-annot-activate-created-annotations t "automatically annotate highlights"))

;; (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
;;       TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view))
;;       TeX-source-correlate-start-server t)

;; (add-hook 'TeX-after-compilation-finished-functions
;;   #'TeX-revert-document-buffer)
