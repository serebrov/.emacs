;;; ...  -*- lexical-binding: nil -*-

;; (autoload 'fennel-mode "~/web/fennel-mode-recent/fennel-mode" nil t)
(autoload 'fennel-mode "~/web/fennel-mode-head/fennel-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.fnl\\'" . fennel-mode))

;; Increase Font size (the number is 1/10, 150 is 15px)
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
(add-hook 'emacs-lisp-mode-hook #'flymake-mode)

;; Structural editing that prevents unbalanced parens:
;;  1. In strict mode, you can't delete a paren without its match.
;; (use-package smartparens
;;   :hook (emacs-lisp-mode . smartparens-strict-mode))
;;
;;  2. Check parens on save:
;; (add-hook 'emacs-lisp-mode-hook
;;           (lambda ()
;;             (add-hook 'before-save-hook #'check-parens nil t)))
;; This will error and prevent saving if parens are unbalanced.
;;
;; 3. aggressive-indent-mode - Auto-reindents as you type, making unbalanced
;; parens visually obvious (code suddenly indents wrong):
(use-package aggressive-indent
  :hook (emacs-lisp-mode . aggressive-indent-mode))

(defun buf--window-state-buffer-names (state)
  "Recursively extract buffer names from a window STATE tree."
  (let (names)
    (dolist (item state names)
      (when (listp item)
        (cond
         ((eq (car item) 'buffer)
          (push (cadr item) names))
         ((memq (car item) '(leaf vc hc))
          (setq names (nconc names
                             (buf--window-state-buffer-names item)))))))))

;;  Alternatively, there's a built-in approach using ibuffer:
;;  1. M-x ibuffer (or SPC d i with your config)
;;  2. * u to mark all unsaved buffers, or * m to mark by mode
;;  3. / g to filter by content/name
;;  4. D to delete marked buffers
;;
;; Helper to close/kill all buffers that are not displayed in any frames and
;; windows, including inactive tabs.
(defun buf-only-visible ()
  "Kill all buffers not displayed in any window, tab, or frame."
  (interactive)
  (let ((kept (make-hash-table :test #'equal)))
    ;; 1. Buffers in live windows on any frame (including iconified).
    (dolist (frame (frame-list))
      (dolist (win (window-list frame 'no-minibuf))
        (puthash (buffer-name (window-buffer win)) t kept))
      ;; 2. Buffers saved in inactive tab-bar tabs.
      (when (fboundp 'tab-bar-tabs)
        (dolist (tab (tab-bar-tabs frame))
          (dolist (name (buf--window-state-buffer-names
                         (alist-get 'ws tab)))
            (puthash name t kept)))))
    (dolist (buf (buffer-list))
      (unless (gethash (buffer-name buf) kept)
        ;; (message "buf-only-visible: would kill %s" (buffer-name buf)))))
        (kill-buffer buf)))))

;; This kills too many:
;; (defun buf-only-visible ()
;;   "Kill all buffers not currently shown in a window somewhere."
;;   (interactive)
;;   (dolist (buf (buffer-list))
;;     (unless (get-buffer-window buf 'visible) (kill-buffer buf))))

;; ---
;; Emacs often replaces existing buffers unexpectedly which is quite different
;; from how this usually works in Vim:
;; - New buffer creates a split (left/bottom by default).
;; - Or new buffer replaces the curent buffer (when, I for example, do ':e new_file.txt`')
;;
;; I think this is mostly it and there are no situations when I open something and
;; get one of the existing buffers replaced unexpectedly.
;;
;; It may be a matter of getting used to Emacs way, where service buffers (like help)
;; may popup and take over some of the existing buffers. The idea is probably that
;; the takeover is temporary and it is usually easy to close the top buffer with q
;; and get back to the previous one.
;;
;; This is different from vim where if I close the buffer, it would also always
;; remove the window where the buffer is displayed, it would not go back automatically
;; to display the previous buffer.
;;
;; Note: M-x tab-line-mode toggles on tabs inside the window, visualize what is
;; hidden. Another useful tool is the `winner-mode` with `M-x winner-undo'
;; and `M-x winner redo` to revert window layout changes.
;;
;; Related discussions:
;; https://www.reddit.com/r/emacs/comments/rybkbw/how_can_i_stop_emacs_from_reusing_existing_windows/
;; https://www.reddit.com/r/emacs/comments/ksbedp/how_can_i_prevent_window_buffers_from_getting/
;; https://www.masteringemacs.org/article/demystifying-emacs-window-manager
;; https://emacsninja.com/posts/design-is-hard.html
;;
;; Recipe to improve defaults:
;; https://github.com/nex3/perspective-el?tab=readme-ov-file#some-musings-on-emacs-window-layouts
;;
;; This seems to work closer to vim: "popup" occurs in the same window, so
;; if I expect something to open, I can split the window first, then open.
;;
;; These settings do the following:
;;
;; 1. Tell display-buffer to reuse existing windows as much as possible,
;; including in other frames. For example, if there is already a *compilation*
;; buffer in a visible window, switch to that window.
;; This means that Emacs will usually switch windows in a "do what I mean" manner
;; for a warmed-up workflow (one with, say, a couple of source windows,
;; a compilation output window, and a Magit window).
;; 2. Prevent splits by telling display-buffer to switch to the target buffer
;; in the current window. For example, if there is no *compilation* buffer visible,
;; then the buffer in whichever window was current when compile was run will be
;; replaced with *compilation*. This may seem intrusive, since it changes out the
;; current buffer, but keep in mind that most buffers popped up in this manner are
;; easy to dismiss, either with a dedicated keybinding (often q) or the
;; universally-applicable kill-buffer. This is easier than restoring window
;; arrangements. It is also easier to handle for pre-arranged window layouts,
;; since the appropriate command can simply be run in a window prepared for it in
;; advance. (If this is a step too far, then replace
;; display-buffer-same-window with display-buffer-pop-up-window.)
(customize-set-variable 'display-buffer-base-action
                        '((display-buffer-reuse-window display-buffer-same-window)
                          (reusable-frames . t)))

(customize-set-variable 'even-window-sizes nil)     ; avoid resizing

;; This is similar to the Vim `didyoumean` plugin: it asks to open an existing
;; file when the requested file does not exist.
;; For example: `:e ~/.emacs.conf/.em` suggests `~/.emacs.conf/.emacs`.
(use-package didyoumean
  :vc (:url "https://gitlab.com/kisaragi-hiu/didyoumean.el")
  :custom
  ;; Unlike the Vim plugin, this package asks for the confirmation even if the
  ;; requested file exists (which is very annoying because when I re-open emacs
  ;; and it reopens the `~/.emacs.conf/.emacs`, it asks for the confirmation because
  ;; the `~/.emacs.conf/.emacs.desktop` file exists).
  ;; The `didyoumean-custom-ignore-function` fixes this.
  (didyoumean-custom-ignore-function #'file-exists-p)
  :config
  (didyoumean-mode 1))

;; Note: an alternative fix is to use the advice (code below).
;; This may be useful in case didyoumean author fixes the code (that now looks like
;; the intention is to apply the `didyoumena-custom-ignore-function` to candidate
;; files, but it is instead applied to the requested file, which is what I want,
;; but can be "broken" with a fix).
;; The related code in didyoumean.el is: `(defun didyoumean--matching-files (file)`.
;; (use-package didyoumean
;;   :vc (:url "https://gitlab.com/kisaragi-hiu/didyoumean.el")
;;   :config
;;   (define-advice didyoumean (:before-while () only-for-new-files)
;;     "Ask only when the visited file does not exist yet."
;;     (and buffer-file-name (not (file-exists-p buffer-file-name))))
;;   (didyoumean-mode 1))

;; Provides M-x browse-at-remote to open the current file in the browser
;; at the corresponding GitHub/GitLab/Bitbucket page.
;; Note: `magit`'s `forge` also has `forge-browse`, but I was not able to
;; get it to work, see the note in the `init.el` file.
;; `:rev :newest' is required: the last "release" commit (Jan 2023) calls
;; `vc-git--call' with the pre-Emacs-31 signature and fails with
;; "Wrong type argument: stringp, t". The fix is only on master.
(use-package browse-at-remote
  :vc (:url "https://github.com/rmuslimov/browse-at-remote.git"
            :rev :newest))

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

;; (use-package vterm
;;   :ensure t)

;; https://dakra.github.io/ghostel/#eshell-integration
(use-package ghostel
  :bind (("C-x m" . ghostel)
         :map ghostel-semi-char-mode-map
         ("C-s"  . consult-line)
         ("M-<backspace>" . ghostel-backward-kill-word)
         ;; ;; I'm used to go up/down the shell history with M-n/p from eshell
         ;; ;; Simulate this behavior in ghostel by sending C-p and C-n
         ("M-p" . (lambda () (interactive) (ghostel-send-key "p" "ctrl")))
         ("M-n" . (lambda () (interactive) (ghostel-send-key "n" "ctrl")))
         :map project-prefix-map
         ("m" . ghostel-project)
         ("M" . ghostel-project-list-buffers))
  :config
  (defun ghostel-send-C-k-and-kill ()
    "Send `C-k' to ghostel.
Like normal Emacs `C-k'.  Kill to end of line and put content in kill-ring."
    (interactive)
    (kill-ring-save (point) (line-end-position))
    (ghostel-send-key "k" "ctrl"))

  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands '(ghostel-project-list-buffers "Ghostel buffers") t)
  (add-to-list 'ghostel-eval-cmds '("magit-status-setup-buffer" magit-status-setup-buffer)))

(use-package ghostel-eshell
  :hook (eshell-load . ghostel-eshell-visual-command-mode))

(use-package ghostel-compile
  :hook (after-init . ghostel-compile-global-mode))

(use-package ghostel-comint
  :hook (after-init . ghostel-comint-global-mode))

(use-package evil-ghostel
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

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

;; debugging
(add-variable-watcher
 'display-buffer-alist
 (lambda (sym val op where)
   (message "display-buffer-alist %s to %S in %S" op val where)))

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

;; debugging
(message "After jinx = %S" display-buffer-alist)

;; Declutter Dired, from
;; https://www.n16f.net/blog/decluttering-dired-for-peace-of-mind/
(progn
  (setq g-dired-minimal-view t)
  ;; When copying/moving files, if there is a dired buffer open in the target directory,
  ;; use it as the target for the operation instead of opening a new buffer.
  ;; For example:
  ;; 1. Open dired in ~/projects and another dired in ~/downloads
  ;; 2. In the ~/downloads dired, select files
  ;; 3. Press R to rename (move) or C to copy
  ;; 4. The minibufer will open with the ~/project directory preselected as a target
  ;;
  ;; Note: also M-n would work without setting dired-dwim-target
  ;; It selects a "future" iten (M-p selects a "past" item) and, in case we just
  ;; started (and there is no future item yet), it selects the  default value
  ;; (which is the same as if dired-dwim-target was set to t).
  ;; See also: https://engineering.collbox.co/post/working-faster-in-emacs-by-reading-the-future/
  (setq dired-dwim-target t)

  (defun g-dired-setup-view ()
    (dired-hide-details-mode (if g-dired-minimal-view 1 -1)))

  (defun g-dired-switch-view ()
    (interactive)
    (setq g-dired-minimal-view (not g-dired-minimal-view))
    (g-dired-setup-view))

  (use-package dired
    ;; dired is core, does not need to be uninstalled
    ;; because of the `use-package-always-ensure' in init.el we need
    ;; to explicitly disable the installation.
    :ensure nil
    :config
    (setq dired-hide-details-hide-symlink-targets nil)

    :hook
    ((dired-mode-hook . g-dired-setup-view))

    :bind
    (:map dired-mode-map
          ("<tab>" . g-dired-switch-view)))

  (message "Inside dired = %S" g-dired-minimal-view)
  )

(defun g-dired-two-pane ()
  "Open dired in two panes side by side."
  (interactive)
  (let ((dir1 (read-directory-name "Directory 1: "))
        (dir2 (read-directory-name "Directory 2: ")))
    (tab-new)
    (delete-other-windows)
    (split-window-right)
    (dired dir1)
    (other-window 1)
    (dired dir2)))

;; debugging
(message "After dired = %S" g-dired-minimal-view)

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

;; SQL-mode configuration
;; 1. Connect to a named connection:
;; M-x sql-connect RET local-postgres RET
;; 2. Quick connect (prompts for details):
;; M-x sql-postgres    ;; for PostgreSQL
;; M-x sql-mysql       ;; for MySQL
;; 3. From a SQL buffer, send queries to the connection:
;; - C-c C-c - Send current paragraph
;; - C-c C-r - Send region
;; - C-c C-b - Send entire buffer
(use-package sql
  :ensure nil  ;; built-in
  :custom
  ;; Default clients (adjust paths if needed)
  (sql-postgres-program "/Applications/Postgres.app/Contents/Versions/16/bin/psql")
  (sql-mysql-program "mysql")

  :config
  ;; Define your database connections
  (setq sql-connection-alist
        '((local-postgres-postgres
           (sql-product 'postgres)
           (sql-server "localhost")
           (sql-port 5432)
           (sql-database "postgres")
           (sql-user "pguser"))))

  ;; Don't save passwords in history
  (setq sql-password-wallet nil))

;; Adds formatting rules for align command.
;; Select the region with SQL and
;; M-x indent-region RET  ;; formats the block, same with `=` in evil mode or `TAB`
;; M-x align RET          ;; aligns spaces inside the line
(use-package sql-indent
  :ensure t
  :defer t
  :hook ((sql-mode . sqlind-minor-mode)))

;;EMMS
(use-package emms
  :ensure t :defer t
  :config
  (progn
    (require 'emms-player-simple)
    (require 'emms-source-file)
    (require 'emms-source-playlist)
    (require 'emms-player-mplayer)
    ;; Requires `brew install mplayer`
    (setq emms-player-list '(emms-player-mplayer))
    ;; Suppress the album-art window mplayer pops up for audio files.
    ;; -novideo skips the video stream; -vo null ensures no window opens.
    (setq emms-player-mplayer-parameters
          (append emms-player-mplayer-parameters '("-novideo" "-vo" "null")))
    ;; macOS ships BSD find; EMMS's find-based scanner sends GNU syntax
    ;; and silently returns no files. Use the pure-elisp scanner instead.
    (setq emms-source-file-directory-tree-function
          'emms-source-file-directory-tree-internal)
    (setq emms-source-file-default-directory "~/Music/Music_My/QobuzMusic/")
    (emms-add-directory-tree "~/Music/Music_My/QobuzMusic/")))

;; This has closer experience to what dbext.vim provides:
;; The output buffer only displays the last command output.
;; I am not sure if I like the sql-mode behavior more or
;; want it to be dbext.vim-like, so keeping this just in case
;; For now I have "s e" bound (in init.el) to `sql-send-region`.
(defun my-sql-send-region-to-result ()
  "Send paragraph and show result in a dedicated buffer."
  (interactive)
  (when (and (boundp 'sql-buffer)
             sql-buffer
             (get-buffer sql-buffer))
    (with-current-buffer sql-buffer
      (comint-clear-buffer)))
  (sql-send-region (region-beginning) (region-end)))

;; There is a problem with postgresql, the output in the psql buffer looks like this:
;;   mydb=> mydb=> mydb-> mydb-> mydb->     a     |      b       |   c
;;   ----------+--------------+-------
;;   1 | 2015-01-05   | 59120
;;
;; The snippet below "fixes" it by asking PostgreSQL to print queries back
;; that also solves the problem with the lack of new line.
;; Overall looks like a bug in sql-mode.
;; Related:
;; - https://www.emacswiki.org/emacs/SqlMode#h5o-5
;; - https://emacs.stackexchange.com/questions/13315/sql-send-paragraph-results-in-mis-aligned-headers/18403#18403
;; - https://www.reddit.com/r/emacs/comments/579lvs/work_around_newline_issue_in_sqlpostgres/
(add-hook 'sql-login-hook 'my-sql-login-hook)
(defun my-sql-login-hook ()
  "Custom SQL log-in behaviours. See `sql-login-hook'."
  ;; n.b. If you are looking for a response and need to parse the
  ;; response, use `sql-redirect-value' instead of `comint-send-string'.
  (when (eq sql-product 'postgres)
    (let ((proc (get-buffer-process (current-buffer))))
      ;; Output each query before executing it. (n.b. this also avoids
      ;; the psql prompt breaking the alignment of query results.)
      (comint-send-string proc "\\set ECHO queries\n"))))

;; Load project-local config from .git/.emacs.local if it exists
;; This way we can, for example, define sql-mode configurations per project:
;;
;; in the project's .git/.emacs.local:
;; (setq sql-connection-alist
;;       '((project-db
;;          (sql-product 'postgres)
;;          (sql-server "localhost")
;;          (sql-port 5533)
;;          (sql-database "remote_db")
;;          (sql-user "remote_user"))))
(defun my-load-local-config ()
  "Load .git/.emacs.local from current project root."
  (let* ((root (or (when-let* ((proj (project-current nil)))
                     (project-root proj))
                   default-directory))
         (local-config (expand-file-name ".git/.emacs.local.el" root)))
    (when (file-exists-p local-config)
      (load local-config))))

(add-hook 'find-file-hook #'my-load-local-config)

;; Emacs comes with a built-in world clock: M-x world-clock
;; To customize displayed timezones, use:

;; ("America/Los_Angeles" "Los Angeles")
;; ("Europe/London" "London")
;; ("Europe/Kyiv" "Kyiv")
;; ("Asia/Tokyo" "Tokyo")))

;; see https://xenodium.com/emacs-time-zones-mode
;; Toggle help with the "?" key add cities with the "+" key.
;; Shifting time is possible via the "f" / "b" keys,
;; in addition to a other features available via the "?" help menu.
(use-package time-zones :ensure t)

;; unofficial github copilot client
;; https://github.com/copilot-emacs/copilot.el
;; - Setup copilot.el as described in the next section.
;; - Install the copilot server by M-x copilot-install-server.
;; - Login to Copilot by M-x copilot-login.
;; You can also check the status by running M-x copilot-diagnose
;; (NotAuthorized means you don't have a valid subscription).
(use-package copilot
  :vc (:url "https://github.com/copilot-emacs/copilot.el"
            :rev :newest
            :branch "main"))
(add-hook 'prog-mode-hook 'copilot-mode)
;; Use tab to accept completions (you may also want to bind copilot-accept-completion-by-word to some key):
;; (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
;; (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion)
(define-key copilot-completion-map (kbd "C-j") 'copilot-accept-completion)

;; By default, Emacs uses the same *info* buffer for all info pages, so when you open a new info page,
;; it replaces the content of the existing *info* buffer.
;; To have independent *info* buffers for each window, we advise the `Info` function to create a new buffer
;; with a unique name each time it's called.
;; (add-hook 'Info-mode-hook #'rename-uniquely)
;; Also this is useful:
;; - `M-n` creates a new Info window with the same node (duplicate the current window)
(advice-add 'info :before
            (lambda (&rest _)
              (let ((buf (get-buffer "*info*")))
                (when buf
                  (with-current-buffer buf
                    (rename-uniquely))))))

;; ## added by OPAM user-setup for emacs / base ## 56ab50dc8996d2bb95e7856a6eddb17b ## you can edit, but keep this line
(require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
;; ## end of OPAM user-setup addition for emacs / base ## keep this line
