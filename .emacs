(autoload 'fennel-mode "~/web/fennel-mode-recent/fennel-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.fnl\\'" . fennel-mode))

;; increase font size (the number is 1/10, 150 is 15px)
(set-face-attribute 'default nil :height 150)

; don't use tabs for indent
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

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
;; Note: this does not work the same way as autosave in my vim config
;; where everything is saved when I go from the insert mode to normal or
;; when vim looses focus. In Emacs saving seems to be on timer.
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
;; (moved to README.md)

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

;;  Alternatively, there's a built-in approach using ibuffer:
;;  1. M-x ibuffer (or SPC d i with your config)
;;  2. * u to mark all unsaved buffers, or * m to mark by mode
;;  3. / g to filter by content/name
;;  4. D to delete marked buffers
(defun buf-only-visible ()
  "Kill all buffers not currently shown in a window somewhere."
  (interactive)
  (dolist (buf  (buffer-list))
    (unless (get-buffer-window buf 'visible) (kill-buffer buf))))
    ;; This should also skip special buffers like *Minibuf-0*
    ;; (unless (or (get-buffer-window buf 'visible)
    ;;             (string-prefix-p " " (buffer-name buf)))

(use-package didyoumean
  :vc (:url "https://gitlab.com/kisaragi-hiu/didyoumean.el"))
(didyoumean-mode 1)

;; Display tabs, trailing spaces
(use-package whitespace
  :ensure nil
  :custom
  (whitespace-style '(face tabs tab-mark trailing space-before-tab))
  (whitespace-display-mappings
   ;; '((tab-mark ?\t [?▸ ?\ ] [?» ?\ ])    ;; tabs: ▸ or »
   '((tab-mark ?\t [?» ?\ ])    ;; tabs: »
     ;; (space-mark ?\  [?·] [?.])          ;; spaces (if enabled): ·
     (newline-mark ?\n [?¬ ?\n] [?$ ?\n]) ;; newlines (if enabled): ¬
     ))
  :init
  (global-whitespace-mode 1))

;; Clear trailing space
;; M-x delete-trailing-whitespace

;; Replace tabs with spaces
;; M-x untabify

;; The wrapped line indicator (showbreak in vim)
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
;; or for non-visual-line mode:
(set-display-table-slot standard-display-table 'wrap ?↪)

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

;;  External packages:
;;  - markdown-mode — The most popular option, available via MELPA. Provides syntax highlighting, preview, export, and editing commands.
;;
;;  To install markdown-mode, add to your config:
;;
(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . markdown-mode))
;;
;;  Or install interactively with M-x package-install RET markdown-mode RET.
;;
;;  Useful commands in markdown-mode:
;;  - C-c C-c p — Preview in browser
;;  - C-c C-c l — Live preview
;;  - C-c C-s b — Bold
;;  - C-c C-s i — Italic
;;  - C-c C-s c — Code
;;  - TAB on headings — Cycle visibility (like org-mode)
;;
;;  Built-in (Emacs 29+):
;;  - markdown-ts-mode — Tree-sitter based markdown mode (requires tree-sitter grammar installed)
;;
;;   1. Install the tree-sitter grammar:
;;   M-x treesit-install-language-grammar RET markdown RET
;;   It will prompt for the grammar source — use the default or specify:
;;   https://github.com/tree-sitter-grammars/tree-sitter-markdown
;;
;;   2. Associate the mode with .md files:
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-ts-mode))
;;
;;   3. Verify tree-sitter is available:
;;   M-: (treesit-available-p) RET
;;   Should return t.
;;
;;   Note: The built-in markdown-ts-mode is quite basic compared to the external markdown-mode package — it mainly provides tree-sitter-based syntax highlighting and indentation. If you want features like preview, export, or editing commands, the external markdown-mode package is more full-featured.
;;
;;   You can check if the grammar is installed with:
;;   M-: (treesit-language-available-p 'markdown) RET

;; Spell checking
;; Note: emacs has standard support for ispell/aspell (needs to be installed with
;; homebrew, brew install aspell) and `flyspell-mode' that highlights misspelt words.
;; Note: aspell seems to be newer/better than ispell.
;; But it still does not see some errors like "the the something".
;; - update: jinx did not help with this (but neovim highlights that error,
;;   so maybe check how my neovim setup does this and see how I can get this
;;   in emacs)
;; https://github.com/minad/jinx
;; Requires brew install enchant
(use-package jinx
  :hook (emacs-startup . global-jinx-mode)
  ;; M-$ triggers correction for the misspelled word before point.
  ;; C-u M-$ or M-x jinx-correct-all spell-checks the entire buffer.
  ;; C-u C-u M-$ or M-x jinx-correct-word forces correction of the word at point,
  ;; even if it is not misspelled.
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages))
)

;;  Try
;;  1. writegood-mode (simple, catches repeated words)
;;
;;  This is lightweight and specifically detects duplicate words like "the the":
;;
;;  (use-package writegood-mode
;;    :hook ((text-mode . writegood-mode)
;;           (org-mode . writegood-mode)
;;           (markdown-mode . writegood-mode)))
;;
;;  2. langtool (comprehensive grammar checking)
;;
;;  Uses LanguageTool for full grammar checking including repeated words, passive voice, etc.:
;;
;;  ;; Requires: brew install languagetool
;;  ;; GitHub: https://github.com/languagetool-org/languagetool
;;  ;; Note: their site (languagetool.org) is confusing, seems that it sells an AI tool.
;;  ;; the information about it being open source is hidden, but present
;;  ;; https://languagetool.org/dev
;;  (use-package langtool
;;    :config
;;    (setq langtool-language-tool-jar "/opt/homebrew/opt/languagetool/libexec/languagetool-commandline.jar")
;;    (setq langtool-default-language "en-US")
;;    :bind (("C-x 4 w" . langtool-check)
;;           ("C-x 4 W" . langtool-check-done)
;;           ("C-x 4 n" . langtool-goto-next-error)
;;           ("C-x 4 p" . langtool-goto-previous-error)))
