;; The default is 800 kilobytes. Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; The init.org does not work for me, maybe because of the way I load
;; init.el out of the ~/.emacs config?
(defun start/org-babel-tangle-config ()
  "Automatically tangle our init.org config file and refresh package-quickstart when we save it. Credit to Emacs From Scratch for this one!"
  (interactive)
  (when (string-equal (file-name-directory (buffer-file-name))
					  (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
	  (org-babel-tangle)
	  (package-quickstart-refresh)
	  )
    ))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'start/org-babel-tangle-config)))

(defun start/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
					(time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'start/display-startup-time)

(require 'use-package-ensure) ;; Load use-package-always-ensure
(setq use-package-always-ensure t) ;; Always ensures that a package is installed

(setq package-archives '(("melpa" . "https://melpa.org/packages/") ;; Sets default package repositories
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/"))) ;; For Eat Terminal

(setq package-quickstart t) ;; For blazingly fast startup times, this line makes startup miles faster

(use-package emacs
  :custom
  (menu-bar-mode nil)         ;; Disable the menu bar
  (scroll-bar-mode nil)       ;; Disable the scroll bar
  (tool-bar-mode nil)         ;; Disable the tool bar
  ;;(inhibit-startup-screen t)  ;; Disable welcome screen

  (delete-selection-mode t)   ;; Select text and delete it by typing.
  (electric-indent-mode nil)  ;; Turn off the weird indenting that Emacs does by default.
  (electric-pair-mode t)      ;; Turns on automatic parens pairing

  (blink-cursor-mode nil)     ;; Don't blink cursor
  (global-auto-revert-mode t) ;; Automatically reload file and show changes if the file has changed

  ;;(dired-kill-when-opening-new-dired-buffer t) ;; Dired don't create new buffer
  ;;(recentf-mode t) ;; Enable recent file mode

  (add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))
  ;; something for consult
  ;; https://github.com/minad/consult/discussions/853
  ;; (defun display-line-numbers--turn-on ()
  ;;   "Turn on `display-line-numbers-mode'."
  ;;   (unless (or (minibufferp) (eq major-mode 'pdf-view-mode))
  ;;     (display-line-numbers-mode)))

  ;;(global-visual-line-mode t)           ;; Enable truncated lines
  ;;(display-line-numbers-type 'relative) ;; Relative line numbers
  (global-display-line-numbers-mode t)  ;; Display line numbers

  (mouse-wheel-progressive-speed nil) ;; Disable progressive speed when scrolling
  (scroll-conservatively 10) ;; Smooth scrolling
  ;;(scroll-margin 8)

  (tab-width 4)

  (make-backup-files nil) ;; Stop creating ~ backup files
  (auto-save-default nil) ;; Stop creating # auto save files
  (auto-save-visited-mode t) ;; Automatically save files (different from auto-save that creates backup)

  :hook
  (prog-mode . (lambda () (hs-minor-mode t))) ;; Enable folding hide/show globally
  :config
  ;; Move customization variables to a separate file and load it, avoid filling up init.el with unnecessary variables
  (setq custom-file (locate-user-emacs-file "custom-vars.el"))
  (load custom-file 'noerror 'nomessage)
  :bind (
         ([escape] . keyboard-escape-quit) ;; Makes Escape quit prompts (Minibuffer Escape)
         ;; Zooming In/Out
         ("C-+" . text-scale-increase)
         ("C--" . text-scale-decrease)
         ("<C-wheel-up>" . text-scale-increase)
         ("<C-wheel-down>" . text-scale-decrease)
         )
  )

  (use-package evil
    :init
    (evil-mode)
    :config
    (evil-set-initial-state 'eat-mode 'insert) ;; Set initial state in eat terminal to insert mode
    ;; (evil-set-initial-state 'deadgrep-mode 'emacs)
    ;; (evil-set-initial-state 'wgrep-mode 'emacs) ;; Use emacs state for wgrep editing
    ;; (evil-set-initial-state 'grep-mode 'emacs)  ;; Use emacs state for grep buffers
    :custom
    (evil-want-keybinding nil)    ;; Disable evil bindings in other modes (It's not consistent and not good)
    (evil-want-C-u-scroll t)      ;; Set C-u to scroll up
    (evil-want-C-i-jump t)        ;; Enables C-i jump (not sure why it is disabled,
                                  ;; C-i does not seem to do anything)
    (evil-undo-system 'undo-redo) ;; C-r to redo
    ;; Unmap keys in 'evil-maps. If not done, org-return-follows-link will not work
    :bind (:map evil-motion-state-map
                ("SPC" . nil)
                ("RET" . nil)
                ("TAB" . nil)))
  (use-package evil-collection
    :after (evil wgrep)
    :config
    ;; Setting where to use evil-collection
    (setq evil-collection-mode-list '(dired ibuffer magit corfu vertico consult info grep wgrep deadgrep))
    (evil-collection-init))

(use-package general
  :config
  (general-evil-setup) ;; <- evil
  ;; Set up 'C-SPC' as the leader key
  (general-create-definer start/leader-keys
    :states '(normal insert visual motion emacs) ;; <- evil
    :keymaps 'override
    ;; :prefix "C-SPC"
    :prefix "SPC"
    :global-prefix "C-SPC") ;; Set global leader key so we can access our keybindings from any state

  (start/leader-keys
    "." '(find-file :wk "Find file")
    "TAB" '(comment-line :wk "Comment lines")
    "q" '(flymake-show-buffer-diagnostics :wk "Flymake buffer diagnostic")
	; the "c" is needed for "SPC c f" (CtrlSF-like search)
	; eat can be opened with "SPC g t" (see the binding below)
    ; "c" '(eat :wk "Eat terminal")
    "p" '(projectile-command-map :wk "Projectile")
    "s p" '(projectile-discover-projects-in-search-path :wk "Search for projects"))

  (start/leader-keys
    "s" '(:ignore t :wk "Search")
    "s c" '((lambda () (interactive) (find-file "~/.config/emacs/init.org")) :wk "Find emacs Config")
    "s r" '(consult-recent-file :wk "Search recent files")
    "s f" '(consult-fd :wk "Search files with fd")
    "s g" '(deadgrep :wk "Search with deadgrep")
    "s G" '(consult-ripgrep :wk "Search with consult-ripgrep")
    "s l" '(consult-line :wk "Search line")
    "s i" '(consult-imenu :wk "Search Imenu buffer locations")) ;; This one is really cool

  (start/leader-keys
    "d" '(:ignore t :wk "Buffers & Dired")
    "d s" '(consult-buffer :wk "Switch buffer")
    "d k" '(kill-current-buffer :wk "Kill current buffer")
    "d i" '(ibuffer :wk "Ibuffer")
    "d n" '(next-buffer :wk "Next buffer")
    "d p" '(previous-buffer :wk "Previous buffer")
    "d r" '(revert-buffer :wk "Reload buffer")
    "d v" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current"))

  (start/leader-keys
    "e" '(:ignore t :wk "Languages")
    "e e" '(eglot-reconnect :wk "Eglot Reconnect")
    "e d" '(eldoc-doc-buffer :wk "Eldoc Buffer")
    "e f" '(eglot-format :wk "Eglot Format")
    "e l" '(consult-flymake :wk "Consult Flymake")
    "e r" '(eglot-rename :wk "Eglot Rename")
    "e i" '(xref-find-definitions :wk "Find definition")
    "e v" '(:ignore t :wk "Elisp")
    "e v b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e v r" '(eval-region :wk "Evaluate elisp in region"))

  (start/leader-keys
    "g" '(:ignore t :wk "Git")
    "g s" '(magit-status :wk "Magit status"))

  (start/leader-keys
    "h" '(:ignore t :wk "Help") ;; To get more help use C-h commands (describe variable, function, etc.)
    "h q" '(save-buffers-kill-emacs :wk "Quit Emacs and Daemon")
    "h r" '((lambda () (interactive)
              (load-file "~/.config/emacs/init.el"))
            :wk "Reload Emacs config"))

  (start/leader-keys
    "t" '(:ignore t :wk "Toggle")
	;; related: M-x toggle-truncate-lines (should be similar to :set nowrap in vim)
    "t t" '(visual-line-mode :wk "Toggle truncated lines (wrap)")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers"))
  )

  ;; (with-current-buffer " *load*"
  ;;  (goto-char (point-max)))

  (start/leader-keys
    ; "c" '(:ignore :wk "Parent c for c f")
    "c f" '(deadgrep :wk "Search with deadgrep")
    "f" '(projectile-find-file :wk "Search for file with projectile")
    "t n" '(tab-new :wk "New tab"))

  (start/leader-keys
    "g" '(:ignore g :wk "Global commands")
	;; gt is to switch tabs, but I have this binded to left/right arrows.
    "g t" '(eat :wk "Eat terminal"))

  ;; gc to comment/uncomment lines
  (define-key evil-normal-state-map (kbd "g c") 'comment-line)
  (define-key evil-visual-state-map (kbd "g c") 'comment-line)

  ;; Vinegar-style: "-" opens dired in current file's directory
  (define-key evil-normal-state-map (kbd "-") 'dired-jump)

  (start/leader-keys
    "q" '(evil-quit :wk "Close buffer or window"))

  (start/leader-keys
    "w" '(evil-write :wk "Write this buffer"))

  ;; This will cause windmove functions to create new windows if necessary
  (setq windmove-create-window t)
  ;; C-h is the help key
  (define-key evil-normal-state-map (kbd "C-h") 'windmove-left)
  (define-key evil-normal-state-map (kbd "C-l") 'windmove-right)
  (define-key evil-normal-state-map (kbd "C-j") 'windmove-down)
  (define-key evil-normal-state-map (kbd "C-k") 'windmove-up)

  ;; left and right switch tabs
  (define-key evil-normal-state-map (kbd "<left>") 'tab-previous)
  (define-key evil-normal-state-map (kbd "<right>") 'tab-next)

  ;; (start/leader-keys
  ;;   "g c" '(comment-line :wk "Comment lines"))
  ;; (define-key evil-normal-state-map (kbd "g c") 'tab-next)

  ;; There is a problem with editing, I am suddently getting into the
  ;; "Buffer is read-only" state.
  ;; After doing M-x read-only-mode to switch it off, I am also getting
  ;; the "Text is read-only" state and then need to also do
  ;; M-: (let ((inhibit-read-only t)) (set-text-properties (point-min) (point-max) ()))
  ;; Not sure what cases it, maybe I'am triggering some keybinding accidentally.

  ;; For debugging problems it may be useful to enable stacktrace:
  ;; M-x toggle-debug-on-error

  ;; Some problems with evil and my setup:
  ;; - shortcuts to move windows SPC + Ctrl + hjkl to move
  ;; - emacs hijacks windows (testing popper as a solution)
  ;;   - Example: Ctrl-h i to open help then h to get help for help - replaces all windows
  ;;   - Example: Ctrl-h i to open help then M-n to duplicate it - replaces one of the existing windows
  ;;   - Workaround: M-x winner-mode adds `M-x winner-mode-undo' (and redo) to undo these changes
  ;; - Autocompletion uses Enter, so I cannot create a new line without selecting an option
  ;;   - reconfigure to TAB? or Ctrl-n?
  ;; - vim surround bingings?
  ;; - which text objects are available?
  ;; - System C-SPC conflict with emacs C-SPC (like C-SPC to start selection and
  ;;   C-x C-SPC to go back to previous mark)
  ;; - jumplist does not work as well as in Vim (also plain Emacs does not have a jumplist)
  ;;   - check https://github.com/gilbertw1/better-jumper
  ;;   - also: https://github.com/ganmacs/jumplist/tree/master
  ;;   - related: https://help-gnu-emacs.gnu.narkive.com/G4oeM1kY/vim-s-jumplist-equivalent-in-emacs
  ;;   - also: https://www.reddit.com/r/emacs/comments/3srwz6/idelike_go_back/
  ;; - Some useful Emacs bindings are overwritten
  ;;   - For example, I use C-hjkl to move between windows, but C-j executes Lisp
  ;; - LSP does not work in python code
  ;; - persistent undo history (to be able to undo or g; after you restart emacs)
  ;; - autosave files on focus lost?

  ;; deadgrep vs CtrlSF
  ;; - how to limit the search to a subfolder when searching with deadgrep?
  ;;   - in the search results window I can enter new directory at the top
  ;;   - is there a way to limit the search to subdirectory initally? (not critical,
  ;;     but would be nice)
  ;; - CtrlSF edit mode works like dired: does not save anything right about
  ;;   (deadgrep edits files live)
  ;; - deadgrep edit mode needs to be explicitely enabled with M-x deadgrep-edit-mode
  ;;   while CtrlSF naturally starts in vim normal mode and "i" starts editing
  ;; - CtrlSF opens files by default in a split, deadgrep opens the file by default
  ;;   (not a problem, deadgrep has the deadgrep-vist-result-other-window command)
  ;;
  ;; Related: https://www.reddit.com/r/emacs/comments/1pglgou/finally_i_have_my_beloved_quickfix_list_in_emacs/
  ;; In Emacs, **wgrep** (Writable Grep) brings this experience
  ;; * Run a search with `M-x grep-find` or something like this
  ;; * Results appear in a grep buffer — similar to Vim’s quickfix window
  ;; * Press `i` (in Evil’s Normal mode) to enter wgrep edit mode — the buffer becomes writable
  ;; * Edit the results directly. You can even run commands like `:%s/old/new/g` across all matches
  ;; * Save with `ZZ` or `:w`, and wgrep applies all changes back to the original source files automatically

  ;; Solved
  ;; - how to do `:set nowrap`?
  ;;   - use `M-x toggle-truncate-lines`
  ;; - need some fzf-like file finder
  ;;   - there is SPC-. but it does not search for files recursively
  ;;   - solved: SPC p f calls projectile-find-file and it does fuzzy recursive search
  ;; - how to run second "eat"? C-u M-x eat
  ;; - "eat" produced some garbage output when entering and then deleting text
  ;;   - M-x eat-compile-terminfo helped
  ;; - C-R commands do not work (for example, C-R C-W in command mode should insert word under cursor)
  ;;   - solved in this setup probably by evil-collection
  ;;   - solved before with https://github.com/tarao/evil-plugins
  ;; - vinegar behavior (- opens dired in the same window)
  ;;   - solved with `dired-jump' mapping
  ;;     Vinegar-style: "-" opens dired in current file's directory
  ;;     (define-key evil-normal-state-map (kbd "-") 'dired-jump)
  ;; - comment/uncomment with gc?
  ;;   (define-key evil-normal-state-map (kbd "g c") 'comment-line)
  ;;   (define-key evil-visual-state-map (kbd "g c") 'comment-line)
  ;; - How to save sessions?
  ;;   This seems to work:
  ;;   - M-x desktop-write, M-x desktop-read
  ;;   - M-x desktop-clear
  ;;   But maybe also projectile- and project- have something similar.
  ;; - C-F in command line mode / search mode to show command buffer (same as shown with q: and q/)
  ;;   - works in this setup, maybe evil-collection or evil itself

;; Fix general.el leader key not working instantly in messages buffer with evil mode
;; (use-package emacs
;;   :ghook ('after-init-hook
;;           (lambda (&rest _)
;;             (when-let ((messages-buffer (get-buffer "*Messages*")))
;;               (with-current-buffer messages-buffer
;;                 (evil-normalize-keymaps))))
;;           nil nil t)
;;   )

(use-package gruvbox-theme
  :config
  ;; (setq gruvbox-bold-constructs t)
  ;; (load-theme 'gruvbox-dark-medium t)) ;; We need to add t to trust this package
  ;; (load-theme 'lueven t))
  ;; (load-theme 'whiteboard t))
  (load-theme 'modus-operandi t)) ;; We need to add t to trust this package

(add-to-list 'default-frame-alist '(alpha-background . 90)) ;; For all new frames henceforth

(set-face-attribute 'default nil
                    ;; :font "JetBrains Mono" ;; Set your favorite type of font or download JetBrains Mono
                    :height 150
                    :weight 'medium)
;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.

;;(add-to-list 'default-frame-alist '(font . "JetBrains Mono")) ;; Set your favorite font
(setq-default line-spacing 0.12)

(use-package doom-modeline
  :custom
  (doom-modeline-height 25) ;; Set modeline height
  :hook (after-init . doom-modeline-mode))

(use-package nerd-icons
  :if (display-graphic-p))

(use-package nerd-icons-dired
  :hook (dired-mode . (lambda () (nerd-icons-dired-mode t))))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package projectile
  :config
  (projectile-mode)
  :custom
  ;; (projectile-auto-discover nil) ;; Disable auto search for better startup times ;; Search with a keybind
  (projectile-run-use-comint-mode t) ;; Interactive run dialog when running projects inside emacs (like giving input)
  (projectile-switch-project-action #'projectile-dired) ;; Open dired when switching to a project
  (projectile-project-search-path '("~/projects/" "~/work/" ("~/github" . 1)))) ;; . 1 means only search the first subdirectory level for projects

(use-package eglot
  :ensure nil ;; Don't install eglot because it's now built-in
  :hook ((c-mode c++-mode ;; Autostart lsp servers for a given mode
                 lua-mode) ;; Lua-mode needs to be installed
         . eglot-ensure)
  :custom
  ;; Good default
  (eglot-events-buffer-size 0) ;; No event buffers (LSP server logs)
  (eglot-autoshutdown t);; Shutdown unused servers.
  (eglot-report-progress nil) ;; Disable LSP server logs (Don't show lsp messages at the bottom, java)
  ;; Manual lsp servers
  ;;:config
  ;;(add-to-list 'eglot-server-programs
  ;;             `(lua-mode . ("PATH_TO_THE_LSP_FOLDER/bin/lua-language-server" "-lsp"))) ;; Adds our lua lsp server to eglot's server list
  )

(use-package sideline-flymake
  :hook (flymake-mode . sideline-mode)
  :custom
  (sideline-flymake-display-mode 'line) ;; Show errors on the current line
  (sideline-backends-right '(sideline-flymake)))

(use-package yasnippet-snippets
  :hook (prog-mode . yas-minor-mode))

(use-package org
  :ensure nil
  :custom
  (org-edit-src-content-indentation 4) ;; Set src block automatic indent to 4 instead of 2.
  (org-return-follows-link t)   ;; Sets RETURN key in org-mode to follow links
  :hook
  (org-mode . org-indent-mode) ;; Indent text
  ;; The following prevents <> from auto-pairing when electric-pair-mode is on.
  ;; Otherwise, org-tempo is broken when you try to <s TAB...
  ;;(org-mode . (lambda ()
  ;;              (setq-local electric-pair-inhibit-predicate
  ;;                          `(lambda (c)
  ;;                             (if (char-equal c ?<) t (,electric-pair-inhibit-predicate c))))))
  )

(use-package toc-org
  :commands toc-org-enable
  :hook (org-mode . toc-org-mode))

(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode))

(use-package org-tempo
  :ensure nil
  :after org)

(use-package eat
  :hook ('eshell-load-hook #'eat-eshell-mode))

;; This supposed to solve "emacs is hijacking my windows problem"
;; testing...
;; Popper - manage popup windows like vim
;; Popups open in a dedicated area and can be dismissed with q
(use-package popper
  :bind (("C-`"   . popper-toggle)        ;; Toggle last popup
         ("M-`"   . popper-cycle)          ;; Cycle through popups
         ("C-M-`" . popper-toggle-type))   ;; Convert popup <-> regular window
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "\\*Warnings\\*"
          "\\*Compile-Log\\*"
          "\\*Backtrace\\*"
          "\\*evil-registers\\*"
          "\\*Apropos\\*"
          "\\*Help\\*"
          "\\*helpful"
          "\\*info\\*"
          "\\*Info\\*"
          compilation-mode
          help-mode
          helpful-mode
          Info-mode))
  (popper-mode +1))

;; Enable pasting in term-mode with C-c C-y
;; is there better way? shouldn't this work by default?
(with-eval-after-load 'term
  (define-key term-raw-map (kbd "C-c C-y") 'term-paste))
;; Interesting: seems like after adding this, C-v also works in eat?
;; It used to show "buffer is read-only"
(with-eval-after-load 'eat
  (define-key eat-mode-map (kbd "C-c C-y") 'eat-yank))

;; (add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; (require 'start-multiFileExample)

;; (start/hello)

(use-package magit
  :defer
  :custom (magit-diff-refine-hunk (quote all)) ;; Shows inline diff
  :config (define-key transient-map (kbd "<escape>") 'transient-quit-one) ;; Make escape quit magit prompts
  )

(use-package diff-hl
  :hook ((dired-mode         . diff-hl-dired-mode-unless-remote)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :init (global-diff-hl-mode))

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-auto-prefix 2)          ;; Minimum length of prefix for auto completion.
  (corfu-popupinfo-mode t)       ;; Enable popup information
  (corfu-popupinfo-delay 0.5)    ;; Lower popup info delay to 0.5 seconds from 2 seconds
  (corfu-separator ?\s)          ;; Orderless field separator, Use M-SPC to enter separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin
  (completion-ignore-case t)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  (corfu-preview-current nil) ;; Don't insert completion without confirmation
  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode))

(use-package nerd-icons-corfu
  :after corfu
  :init (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package cape
  :after corfu
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.

  ;; The functions that are added later will be the first in the list
  (add-hook 'completion-at-point-functions #'cape-dabbrev) ;; Complete word from current buffers
  (add-hook 'completion-at-point-functions #'cape-dict) ;; Dictionary completion
  (add-hook 'completion-at-point-functions #'cape-file) ;; Path completion
  (add-hook 'completion-at-point-functions #'cape-elisp-block) ;; Complete elisp in Org or Markdown mode
  (add-hook 'completion-at-point-functions #'cape-keyword) ;; Keyword completion

  ;;(add-hook 'completion-at-point-functions #'cape-abbrev) ;; Complete abbreviation
  ;;(add-hook 'completion-at-point-functions #'cape-history) ;; Complete from Eshell, Comint or minibuffer history
  ;;(add-hook 'completion-at-point-functions #'cape-line) ;; Complete entire line from current buffer
  ;;(add-hook 'completion-at-point-functions #'cape-elisp-symbol) ;; Complete Elisp symbol
  ;;(add-hook 'completion-at-point-functions #'cape-tex) ;; Complete Unicode char from TeX command, e.g. \hbar
  ;;(add-hook 'completion-at-point-functions #'cape-sgml) ;; Complete Unicode char from SGML entity, e.g., &alpha
  ;;(add-hook 'completion-at-point-functions #'cape-rfc1345) ;; Complete Unicode char using RFC 1345 mnemonics
  )

(use-package orderless
  :custom
  ;; flex is fuzzy search
  ;; orderless style allows patterns like *
  ;; basic is the fallback
  (completion-styles '(flex orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Useful to reinstal the package:
;; (progn
;;   (car package-alist)
;; )
;; (assq 'yasnippet-snippets package-alist)

;; (package-get-descriptor 'vertico)
;; (package-recompile 'vertico)
;; (package-delete (package-get-descriptor 'vertico))
;; (package-delete (package-get-descriptor 'reader))

(use-package vertico
  :init
  (vertico-mode))

(savehist-mode) ;; Enables save history mode

(use-package marginalia
  :after vertico
  :init
  (marginalia-mode))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  :hook
  ('marginalia-mode-hook . 'nerd-icons-completion-marginalia-setup))

(use-package consult
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))

  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  ;; (consult-customize
  ;; consult-theme :preview-key '(:debounce 0.2 any)
  ;; consult-ripgrep consult-git-grep consult-grep
  ;; consult-bookmark consult-recent-file consult-xref
  ;; consult--source-bookmark consult--source-file-register
  ;; consult--source-recent-file consult--source-project-recent-file
  ;; :preview-key "M-."
  ;; :preview-key '(:debounce 0.4 any))

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
   ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
   ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
   ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
   ;;;; 4. projectile.el (projectile-project-root)
  (autoload 'projectile-project-root "projectile")
  (setq consult-project-function (lambda (_) (projectile-project-root)))
   ;;;; 5. No project support
  ;; (setq consult-project-function nil)

  ;; Add context lines to ripgrep results (like CtrlSF in vim)
  ;; -C 3 shows 3 lines before and after each match
  (setq consult-ripgrep-args
        "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --with-filename --line-number -C 3")
  )

(use-package helpful
  :bind
  ;; Note that the built-in `describe-function' includes both functions
  ;; and macros. `helpful-function' is functions only, so we provide
  ;; `helpful-callable' as a drop-in replacement.
  ("C-h f" . helpful-callable)
  ("C-h v" . helpful-variable)
  ("C-h k" . helpful-key)
  ("C-h x" . helpful-command)
  )

(use-package diminish)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :ensure nil ;; Don't install which-key because it's now built-in
  :init
  (which-key-mode 1)
  :diminish
  :custom
  (which-key-side-window-location 'bottom)
  (which-key-sort-order #'which-key-key-order-alpha) ;; Same as default, except single characters are sorted alphabetically
  (which-key-sort-uppercase-first nil)
  (which-key-add-column-padding 1) ;; Number of spaces to add to the left of each column
  (which-key-min-display-lines 6)  ;; Increase the minimum lines to display because the default is only 1
  (which-key-idle-delay 0.8)       ;; Set the time delay (in seconds) for the which-key popup to appear
  (which-key-max-description-length 25)
  (which-key-allow-imprecise-window-fit nil)) ;; Fixes which-key window slipping out in Emacs Daemon

(use-package ws-butler
  :init (ws-butler-global-mode))

;; Similar to CtrlSF
;; - SPC s g to search with deadgrep
;; In the results buffer:
;; - n/p to navigate results
;; - TAB to go to the result
;; - o to open result in a split
;;   - or M-x deadgrep-vist-result-other-window
;; - M-x deadgrep-edit-mode to switch to edit mode
;; The keybindings above work in emacs mode (not in evil).
;;
;; May consider re-enabling to get the keybingings (see above):
;; (evil-set-initial-state 'deadgrep-mode 'emacs)
;; or maybe adding more custom keybindings.
;;
(use-package deadgrep
  :custom
  (deadgrep-display-buffer-function 'switch-to-buffer)  ;; Open in same window
  :config
  ;; Add context lines (like CtrlSF)
  (setq deadgrep-extra-arguments '("--follow" "-C3")))

;; Note: setup below may still be useful, but I added deadgrep plugin above instead
;; as it is closer to CtrlSF (nicer presentation of the search results)
;;
;; Embark+consult+wgrep is like CtrlSF:
;; - embark can export consult grep results into a full buffer
;; - wgrep can edit the results buffer directly
;; 1. Run SPC s g (consult-ripgrep)
;; 2. Type your search query
;; 3. Press C-c C-e to export results to a grep buffer

;; In the grep buffer:
;; - Navigate results with n/p (next/previous)
;; - Press RET to jump to a result
;; - Use C-x 4 RET to open in a split

;; Making edits (wgrep):
;; 1. In the grep buffer, press C-c C-p (or e with evil) to enter wgrep
;; edit mode
;; 2. Edit the text directly in the buffer
;; 3. Press C-c C-c to apply changes to all files
;; 4. Press C-c C-k to abort

;; Bonus embark bindings:
;; - C-. (embark-act) - Context menu on any target (file, symbol, etc.)
;; - C-; (embark-dwim) - "Do what I mean" action

(use-package embark
  :bind
  (("C-." . embark-act)         ;; Context actions on target at point
   ("C-;" . embark-dwim)        ;; "Do what I mean" on target
   :map minibuffer-local-map
   ("C-c C-e" . embark-export)  ;; Export results to a buffer
   ("C-c C-c" . embark-collect))) ;; Collect results in a buffer

(use-package embark-consult
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package wgrep
  :demand t
  :custom
  (wgrep-auto-save-buffer t)  ;; Auto-save changed buffers
  :config
  ;; Make wgrep buffer editable with evil - switch to insert state when entering wgrep
  (advice-add 'wgrep-change-to-wgrep-mode :after
              (lambda () (evil-insert-state))))

;; Note: this should be working, evil-collection mentions wgrep in the readme:
;; > For buffers where insert-state doesn’t make sense but buffer can be edited,
;; > (e.g. wdired or wgrep), pressing i will change into editable state.
;; But there is either a bug or a version mismatch, the mapping below fixes it:

;; "i" in grep buffer enters wgrep edit mode
;; Bind in both normal and motion states (evil-collection may use motion state)
;; Use a wrapper that checks we're actually in grep-mode (not deadgrep which inherits from it)
(with-eval-after-load 'grep
  (evil-define-key '(normal motion) 'grep-mode-map "i"
    (lambda () (interactive)
      (if (eq major-mode 'grep-mode)
          (wgrep-change-to-wgrep-mode)
        (evil-insert 1)))))

;; Old version (causes issues with deadgrep which inherits from grep-mode):
;; (with-eval-after-load 'grep
;;   (evil-define-key '(normal motion) 'grep-mode-map "i" 'wgrep-change-to-wgrep-mode))

;; something awesome for elisp navigation
;; https://nathantypanski.com/blog/2014-08-03-a-vim-like-emacs-config.html
;; https://github.com/purcell/elisp-slime-nav
;; With elisp-slime-nav-mode we can see information about current symbol in the
;; minibuffer (move cursor to the symbol, see the info at the bottom).
;;
;; It also provides M-. and M-, to navigate to the symbol at the point and back.
;; Something similar to gd and then Ctrl-o.
;;
;; Note: slime (https://slime.common-lisp.dev/) is another package, providing
;; extra features to develop Lisp in emacs (debugger, REPL, etc).
(use-package elisp-slime-nav
  :init
  (defun my-lisp-hook ()
	(elisp-slime-nav-mode)
	(turn-on-eldoc-mode))

  (add-hook 'emacs-lisp-mode-hook 'my-lisp-hook)

  ;; K to display help for elisp symbols
  (evil-define-key 'normal emacs-lisp-mode-map (kbd "K")
	'elisp-slime-nav-describe-elisp-thing-at-point)

  ;; add key for the orginal M-. command
  ;; the M-, is originally mapped to `pop-tag-mark`, not needed as
  ;; `C-o` works fine.
  (evil-define-key 'normal emacs-lisp-mode-map (kbd "gd")
    'elisp-slime-nav-find-elisp-thing-at-point)
)

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
;; Increase the amount of data which Emacs reads from the process
(setq read-process-output-max (* 1024 1024)) ;; 1mb
