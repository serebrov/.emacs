;;; init-claude-code --- Claude Code setup -*- lexical-binding: nil -*-

;; Alternatives
;; - Run in ghostel
;;   - Use C-c ESC to send ESC to the ghostel buffer (to switch to normal mode)
;;   - Run `claude --ax-screen-reader` to have control over scrolling
;; - https://github.com/stevemolitor/claude-code.el
;; - https://github.com/cpoile/claudemacs
;; - https://github.com/yuya373/claude-code-emacs
;;
;; claude-code-ide is current buffer-aware
;; use `M-x claude-code-ide-insert-at-mentioned` to send text to Claude Code.
(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :bind ("C-c C-'" . claude-code-ide-menu)
  ;; ("C-c c"   . claude-code-ide-insert-at-mentioned)
  ;; ("C-c C-c" . claude-code-ide-send-escape))
  :init
  (setq claude-code-ide-cli-path "~/.local/bin/claude")
  (setq claude-code-ide-terminal-backend 'ghostel)
  ;; Use standard buffer instead of the "side window".
  (setq claude-code-ide-use-side-window nil)
  :config
  (claude-code-ide-emacs-tools-setup) ; Optionally enable Emacs MCP tools
  ;; Add tools to list and read all buffers, including non-file buffers.
  ;; Note that there is `executeCode` tool and Claude Code could do the
  ;; same with elisp, but the tool is more straightforward and cheaper.
  (claude-code-ide-make-tool
   :function #'my/claude-list-buffers
   :name "emacs_list_buffers"
   :description "List the open Emacs buffers with their size and file path"
   :args nil)
  (claude-code-ide-make-tool
   :function #'my/claude-read-buffer
   :name "emacs_read_buffer"
   :description "Read the text of an open Emacs buffer, including buffers with no file such as *Code Review*, *compilation*, or magit buffers"
   :args '((:name "buffer_name"
                  :type string
                  :description "Exact buffer name, for example *Code Review*")
           (:name "start_line"
                  :type integer
                  :description "First line to return (1-based)"
                  :optional t)
           (:name "end_line"
                  :type integer
                  :description "Last line to return (1-based)"
                  :optional t))))

;; (with-eval-after-load 'evil
;;   (evil-define-key 'visual 'global (kbd "SPC c") #'claude-code-ide-insert-at-mentioned))

;; Custom command with custom script made by Claude to copy the last reply as markdown.
;; Two files, so the logic stays importable and the entry point stays thin:
;;
;; * `~/.claude/scripts/cc_last_reply.py` - reads a transcript, splits it into turns, returns the assistant markdown of each turn.
;; * `~/.claude/scripts/cc-copy` - the CLI, copies one reply to the clipboard with `pbcopy`.
;;
;; Usage, from the project directory:
;;
;; ```
;; cc-copy             # last reply to the clipboard
;; cc-copy -n 2        # the reply before the last one
;; cc-copy --print     # to stdout, for piping
;; cc-copy --dir PATH  # another project
;; ```
(defun cc-last-reply ()
  "Show the last Claude Code reply as raw markdown."
  (interactive)
  (let ((default-directory (project-root (project-current t))))
    (with-current-buffer (get-buffer-create "*claude-markdown*")
      (erase-buffer)
      (call-process "~/.claude/scripts/cc-copy" nil t nil "--print")
      (markdown-mode)
      (pop-to-buffer (current-buffer)))))

;; Buffer access for Claude Code
;; The claude-code-ide only gives access to file buffers,
;; but it is useful to have access to other buffers too,
;; such as *Code Review*, *compilation*, or magit buffers.
(defvar my/claude-buffer-deny
  '("authinfo" "\\.gpg\\'")
  "Buffer name patterns Claude must not read.")

(defun my/claude-buffer-denied-p (buf)
  (let ((name (buffer-name buf)))
    (seq-some (lambda (re) (string-match-p re name)) my/claude-buffer-deny)))

(defun my/claude-list-buffers ()
  "List readable buffers with size and file, one per line."
  (mapconcat
   (lambda (buf)
     (format "%-45s %8d  %s"
             (buffer-name buf)
             (buffer-size buf)
             (or (buffer-file-name buf) "(no file)")))
   (seq-remove #'my/claude-buffer-denied-p (buffer-list))
   "\n"))

(defun my/claude-read-buffer (buffer_name &optional start_line end_line)
  "Return text of BUFFER_NAME, from START_LINE to END_LINE if given."
  (let ((buf (get-buffer buffer_name)))
    (cond
     ((null buf) (format "No buffer named %s" buffer_name))
     ((my/claude-buffer-denied-p buf) (format "Buffer %s is not readable" buffer_name))
     (t
      (with-current-buffer buf
        (save-excursion
          (let* ((beg (progn (goto-char (point-min))
                             (forward-line (1- (or start_line 1)))
                             (point)))
                 (end (if end_line
                          (progn (goto-char (point-min))
                                 (forward-line end_line)
                                 (point))
                        (point-max))))
            (buffer-substring-no-properties beg end))))))))
