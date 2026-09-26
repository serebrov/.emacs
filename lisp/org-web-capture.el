;;; org-web-capture.el --- Capture a web page into a new Org file -*- lexical-binding: t -*-

;;; Commentary:

;; Org capture target for web pages.  `org-web-capture-file' fetches
;; the first URL in the clipboard or kill ring, keeps the Org entry in
;; the capture property list as `:web-entry', and returns a new file
;; name of the form YYYY-MM-DD-hh-mm-webpage-title.org.
;;
;; Org sets the target before it fills the template, so the template
;; can read the entry with "%(org-capture-get :web-entry)".
;;
;; Org calls a function as a file target, but does not evaluate a
;; form, so wrap the call in a lambda:
;;   (file (lambda () (org-web-capture-file "~/web/org/webpages")))

;;; Code:

(require 'org-capture)
(require 'org-web-tools)

(defconst org-web-capture--max-slug-length 80
  "Maximum number of characters of the title part of the file name.")

(defun org-web-capture--slug (title)
  "Return TITLE in lower case, with hyphens between the words."
  (let ((slug (string-trim (replace-regexp-in-string
                            "[^[:alnum:]]+" "-" (downcase title))
                           "-" "-")))
    (if (string-empty-p slug)
        "untitled"
      (truncate-string-to-width slug org-web-capture--max-slug-length))))

(defun org-web-capture--title (entry)
  "Return the link description in the first heading of ENTRY."
  (when (string-match org-link-bracket-re entry)
    (or (match-string 2 entry) "")))

(defun org-web-capture-file (dir)
  "Fetch the page in the clipboard and return a new Org file name in DIR.
Keep the Org entry of the page as `:web-entry' in the capture plist."
  (let* ((url (or (org-web-tools--get-first-url)
                  (user-error "No URL in the clipboard or kill ring")))
         (entry (org-web-tools--url-as-readable-org url)))
    (org-capture-put :web-entry entry)
    (expand-file-name
     (format "%s-%s.org"
             (format-time-string "%Y-%m-%d-%H-%M")
             (org-web-capture--slug (or (org-web-capture--title entry) "")))
     dir)))

(provide 'org-web-capture)
;;; org-web-capture.el ends here
