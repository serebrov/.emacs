;;; find-stale-code --- Find functions modified on the disc, but not in memory  -*- lexical-binding: nil -*-
;;
;; Use it as: (my/stale-functions "code-review")
;; where "code-review" is the prefix of the functions you want to check.
(require 'cl-lib)
(require 'find-func)

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
