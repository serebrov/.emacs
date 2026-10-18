;;; org-convert-html-link --- Various utils -*- lexical-binding: t -*-

;;; Code:

(defun convert---html-link-to-org-link (html-link)
  "Convert an HTML-LINK to an Org link.

  We expect the HTML link to be in the form of `<a href='URL'>TEXT</a>`
  and that the link is under the cursor.

  The output will be in the form of [[URL][TEXT]]."
  (let* ((url (if (string-match "href=\"\\([^\"]+\\)\"" html-link)
                  (match-string 1 html-link)
                (user-error "No URL found in the HTML link")))
         (text (if (string-match ">\\([^<]+\\)<" html-link)
                   (match-string 1 html-link)
                 (message "Found link %s" html-link)
                 (user-error "No link text found in the HTML link"))))
    (save-excursion
      (beginning-of-line)
      (when (re-search-forward "<a href=\"[^\"]+\">[^<]+</a>" (line-end-position) t)
        (replace-match (format "[[%s][%s]]" url text))))))

(defun convert-html-link-to-org-link ()
  "Convert an HTML link to an Org link.

  We expect the HTML link to be in the form of `<a href='URL'>TEXT</a>`
  and that the link is under the cursor.

  The output will be in the form of [[URL][TEXT]]."
  (interactive)
  (let* ((html-link (thing-at-point 'line t)))
    (convert---html-link-to-org-link html-link)))

(defun convert-all-html-links-to-org-links ()
  "Convert all HTML links in the current buffer to Org links."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "<a href=\"[^\"]+\">[^<]+</a>" nil t)
      (let* ((html-link (match-string 0)))
        (convert---html-link-to-org-link html-link)))))
