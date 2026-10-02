;;; find-stale-code --- Find functions modified on the disc, but not in memory  -*- lexical-binding: nil -*-
;;
;; Use it as: (my/stale-functions "code-review")
;; where "code-review" is the prefix of the functions you want to check.
;;
;; To produce a better report, use (my/stale-report "code-review")
;; this will show stale functions with links to the source and the messages
;; produced during the scan.
(require 'cl-lib)
(require 'find-func)

(require 'seq)
(require 'compile)

(defun my/canon (form)
  "Replace uninterned symbols in FORM with stable placeholders."
  (let ((seen (make-hash-table :test 'eq)) (n 0))
    (letrec ((walk (lambda (x)
                     (cond ((consp x) (cons (funcall walk (car x))
                                            (funcall walk (cdr x))))
                           ((and (symbolp x) x
                                 (not (eq x (intern-soft (symbol-name x)))))
                            (or (gethash x seen)
                                (puthash x (make-symbol (format "g%d" (cl-incf n)))
                                         seen)))
                           (t x)))))
      (funcall walk form))))

(defun my/live-body (sym)
  "Body of SYM as it runs now, or nil when SYM is byte-compiled."
  (let ((f (indirect-function sym)))
    (and (interpreted-function-p f) (append (aref f 1) nil))))

(defun my/source-body (sym)
  "Body of SYM as written in its source, macro-expanded.
Returns nil unless the source form is a plain `defun'."
  (let ((loc (ignore-errors (find-function-noselect sym t))))
    (when (and (car loc) (integer-or-marker-p (cdr loc)))
      (with-current-buffer (car loc)
        (save-excursion
          (goto-char (cdr loc))
          (let ((form (ignore-errors (read (current-buffer)))))
            (when (eq (car-safe form) 'defun)
              (let ((body (cdddr form)))
                (when (and (stringp (car body)) (cdr body)) (setq body (cdr body)))
                (when (eq (car-safe (car body)) 'declare)     (setq body (cdr body)))
                (when (eq (car-safe (car body)) 'interactive) (setq body (cdr body)))
                (cdr (ignore-errors (macroexpand-all (cons 'progn body))))))))))))

(defun my/stale-p (sym)
  "Non-nil when the live definition of SYM differs from its source."
  (let ((live (my/live-body sym)))
    (and live
         (let ((src (my/source-body sym)))
           (and src
                (let ((print-gensym t) (print-circle t))
                  (not (equal (format "%S" (my/canon live))
                              (format "%S" (my/canon src))))))))))

(defun my/stale-functions (prefix)
  "List functions under PREFIX whose live code differs from their source."
  (let (out)
    (mapatoms (lambda (s)
                (when (and (fboundp s) (string-prefix-p prefix (symbol-name s))
                           (my/stale-p s))
                  (push s out))))
    (sort out #'string<)))

(defvar my/stale-report-buffer "*stale code*")

(defun my/function-location (sym)
  "Return (FILE . LINE) for the source definition of SYM, or nil."
  (let ((loc (ignore-errors (find-function-noselect sym t))))
    (when (and (car loc) (integer-or-marker-p (cdr loc)))
      (with-current-buffer (car loc)
        (cons (or buffer-file-name (buffer-name))
              (line-number-at-pos (cdr loc)))))))

(defun my/messages-since (mark)
  "Return the text added to the *Messages* buffer since MARK."
  (with-current-buffer (messages-buffer)
    (buffer-substring-no-properties (min mark (point-max)) (point-max))))

(defun my/clean-log-lines (log)
  "Split LOG into unique lines, dropping Emacs repeat markers."
  (seq-remove (lambda (l) (string-match-p "\\`\\[[0-9]+ times\\]\\'" l))
              (delete-dups (split-string log "\n" t "[ \t]+"))))

(defun my/stale-report (prefix)
  "Report functions under PREFIX whose live code differs from their source.
Collect the messages and warnings that each single check produces."
  (interactive "sFunction prefix: ")
  (let ((scanned 0) stale notes)
    (let ((inhibit-message t))
      (mapatoms
       (lambda (s)
         (when (and (fboundp s)
                    (string-prefix-p prefix (symbol-name s))
                    (my/live-body s))
           (setq scanned (1+ scanned))
           (let* ((mark (with-current-buffer (messages-buffer) (point-max)))
                  (bad (my/stale-p s))
                  (lines (my/clean-log-lines (my/messages-since mark))))
             (when bad (push s stale))
             (when lines (push (cons s lines) notes)))))))
    (setq stale (sort stale #'string<))
    (setq notes (sort notes (lambda (a b) (string< (car a) (car b)))))
    (with-current-buffer (get-buffer-create my/stale-report-buffer)
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert (format "Stale functions with prefix %S\n" prefix))
        (insert (format "%s -- %d of %d interpreted functions differ from their source.\n\n"
                        (format-time-string "%F %T") (length stale) scanned))
        (if (null stale)
            (insert "Nothing is stale.  Every definition matches its source.\n")
          (dolist (s stale)
            (let ((loc (my/function-location s)))
              (insert (if loc
                          (format "%s:%d: %s\n" (car loc) (cdr loc) s)
                        (format "unknown location: %s\n" s))))))
        (when notes
          (insert (format "\nMessages during the scan (%d functions)\n" (length notes)))
          (insert (make-string 64 ?-) "\n")
          (pcase-dolist (`(,sym . ,lines) notes)
            (insert (format "%s\n" sym))
            (dolist (l lines) (insert "    " l "\n"))))
        (goto-char (point-min)))
      (special-mode)
      (compilation-minor-mode 1)
      (pop-to-buffer (current-buffer)))
    stale))

;; This is separate from the above, can be used to inspect the live definition
;; of one function.
;; (my/show-live-definition 'code-review-github-errback)
(defun my/show-live-definition (sym)
  "Pretty-print the live definition of SYM into a buffer."
  (interactive (list (function-called-at-point)))
  (with-current-buffer (get-buffer-create (format "*live: %s*" sym))
    (erase-buffer)
    (emacs-lisp-mode)
    (pp (indirect-function sym) (current-buffer))
    (pop-to-buffer (current-buffer))))
