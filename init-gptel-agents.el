;;; init-gptel-agents.el --- gptel presets from files  -*- lexical-binding: t; -*-

;; Register *.md files from `my/gptel-preset-dirs' directories as gptel-agent presets
;; ("preset" is a prompt, so we create more kinds of agents this way).
;; The file format is something that `gptel-agent-read-file' can process:
;; YAML frontmatter and the system prompt as body. This is similar, for example,
;; to the Claude Code skills format.
;;
;; The `parents:' property can be used to build a preset on top of another preset.
;; Parent present can be in any of the registered directories (not necessary in the
;; same as the child preset).
;;
;; Note that presets added here are not added to the `gptel-agent-dirs', so they are not
;; shown by the `Agent' tool as sub-agents.
;;
;; The "~/.emacs.conf/gptel-agents/" is for "public" presets (my config is
;; open source). The "~/.emacs.d/gptel-agents/" is for private presets
;; (local folder, not on github).
;;
;; It can also load per-project presets from the ".gptel-agents/" in the project root.
;;
;; Projects need to be white-listed with
;;   (add-to-list 'my/gptel-preset-dirs ".gptel-agents/" t)
;;
;; This is because there are some risks of per-project directories:
;; - Code execution: the `pre:` and `post:` frontmatter keys are evaluated as Lisp when a file
;;   is parsed (`gptel-agent-parse-markdown-frontmatter` calls `eval`).
;;   So running ~M-x my/gptel-agent~ in a random repository  may be harmful (if it has
;;   the `.gptel-agents/` folder with some kind of virus in the code).
;; - Parsing is global: the `my/gptel-load-presets` parses files in all listed directories,
;;   so a malicious file in one of the projects execute its `pre:` code even when you run
;;   ~M-x my/gptel-agent~ in another project.
;;
;; The ~(add-to-list 'my/gptel-preset-dirs ".gptel-agents/" t)~ addresses this risks
;; (but make sure you don't add untrusted projects to the list).

(require 'gptel)
(require 'gptel-agent)

(defvar my/gptel-preset-dirs '("~/.emacs.conf/gptel-agents/"
                               "~/.emacs.d/gptel-agents/")
  "Directories with preset files, see the commentary of this file.
Directories listed later override earlier records.
Relative names are resolved against the project root,
for example ~.gptel-agents~."
  )

(defun my/gptel-load-presets (&optional project-dir)
  "Register a gptel preset for each file in `my/gptel-preset-dirs'.
Resolve relative directories are against the PROJECT-DIR.
Skip missing directories."
  (interactive)
  (dolist (dir my/gptel-preset-dirs)
    (setq dir (expand-file-name dir project-dir))
    (when (file-directory-p dir)
      (dolist (file (directory-files dir t "\\.\\(md\\|org\\)\\'"))
        (pcase-let ((`(,name . ,spec) (gptel-agent-read-file file)))
          (apply #'gptel-make-preset (intern name) spec))))))

(defun my/gptel-project-dir ()
  "Return the current project root.
Prefix argument shows a project prompt."
  (cond (current-prefix-arg (funcall project-prompter))
        ((project-current) (project-root (project-current)))
        (t default-directory)))

(defun my/gptel-agent (project-dir preset)
  "Start `gptel-agent' in the PROJECT-DIR with PRESET.
By default, PROJECT-DIR is the current project.
Prefix argument shows a project prompt."
  (interactive
   (let ((dir (my/gptel-project-dir)))
     (my/gptel-load-presets dir)
     (list dir (intern (completing-read
                        "Agent preset: "
                        (mapcar (lambda (p) (symbol-name (car p)))
                                gptel--known-presets)
                        nil t nil nil "base-agent")))))
  (gptel-agent project-dir preset))

;; Saving sessions:
;; * `my/gptel-agent-save' to save the agent session to a file,
;;    it uses the `my/gptel-session-dir' by default.
;;    gptel adds its metadata to the file (preset, tools, response markers)
;;    so it can later be restored.
;; * `my/gptel-agent-resume' to load the saved session.
;;
;; The minor mode `my/gptel-keep-session-mode' aguments standard save
;; commands to work correctly with gptel buffers, keeping them as
;; agent sessions (without it, buffers turn into plain markdown or org files
;; after saving). Works with ~M-x save-buffer~, ~M-x write-file~ and
;; evil's ~:w~ and ~:saveas~.
(defvar my/gptel-session-dir "~/.emacs.d/gptel-sessions/"
  "Default directory for saved agent sessions, used by `my/gptel-agent-resume'.")

(defun my/gptel-keep-session (orig-fun &rest args)
  "Call ORIG-FUN with ARGS without resetting a gptel buffer.
Around advice for `set-visited-file-name', which `write-file' and
`save-buffer' (for a buffer without a file) call.  It re-runs
`set-auto-mode', which drops `gptel-mode', the preset and the tools, and
changes `default-directory' to the file's directory, which breaks relative
paths in the agent's tools."
  (if (bound-and-true-p gptel-mode)
      (let ((dir default-directory))
        (prog1 (cl-letf (((symbol-function 'normal-mode) #'ignore)
                         ((symbol-function 'set-auto-mode) #'ignore))
                 (apply orig-fun args))
          (setq default-directory dir)))
    (apply orig-fun args)))

(defun my/gptel-save-state-last ()
  "Make `gptel--save-state' the last function in the local `before-save-hook'.
Hooks like `ws-butler' or `toc-org' change the buffer after gptel stored
the response positions, which then point past the end of the saved file
and make the restore fail."
  (remove-hook 'before-save-hook #'gptel--save-state t)
  (add-hook 'before-save-hook #'gptel--save-state 90 t))

(define-minor-mode my/gptel-keep-session-mode
  "A minor mode to keep gptel buffers in the agent session mode on save.
When enabled, `save-buffer', `write-file', and evil's `:w' and `:saveas'
work correctly in gptel buffers (and when disabled, the buffer turnes into
a plain file buffer, without the agent session state)."
  :global t
  :group 'gptel
  (cond (my/gptel-keep-session-mode
         (advice-add 'set-visited-file-name :around #'my/gptel-keep-session)
         (add-hook 'gptel-mode-hook #'my/gptel-save-state-last))
        (t
         (advice-remove 'set-visited-file-name #'my/gptel-keep-session)
         (remove-hook 'gptel-mode-hook #'my/gptel-save-state-last))))

(defun my/gptel-agent-save (file)
  "Save the current agent buffer to FILE, by default in `my/gptel-session-dir'.
The session can be restored with `my/gptel-agent-resume'."
  (interactive
   (let ((dir (file-name-as-directory (expand-file-name my/gptel-session-dir))))
     (make-directory dir t)
     (list (read-file-name "Save session to: " dir nil nil
                           (format-time-string "%Y-%m-%d-session.md")))))
  (unless (bound-and-true-p gptel-mode)
    (user-error "Not a gptel session buffer"))
  (my/gptel-save-state-last)
  (my/gptel-keep-session #'write-file file))

(defun my/gptel-agent-resume (file project-dir)
  "Open the saved session FILE as a agent session buffer in PROJECT-DIR.
Prefix argument shows a project prompt."
  (interactive
   (list (read-file-name "Resume session: " my/gptel-session-dir nil t)
         (my/gptel-project-dir)))
  (my/gptel-load-presets project-dir)
  (find-file file)
  (gptel-mode 1)
  (setq default-directory project-dir))

(my/gptel-load-presets)

(provide 'init-gptel-agents)
