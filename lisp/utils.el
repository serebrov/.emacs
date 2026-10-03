(defun convert-html-link-to-org-link ()
  "Convert an HTML link to an Org link.

  We expect the HTML link to be in the form of `<a href='URL'>TEXT</a>`
  and that the link is under the cursor.

  The output will be in the form of [[URL][TEXT]]."
  (interactive)
  (let* ((html-link (thing-at-point 'line t))
         (url (if (string-match "href=\"\\([^\"]+\\)\"" html-link)
                  (match-string 1 html-link)
                (user-error "No URL found in the HTML link")))
         (text (if (string-match ">\\([^<]+\\)<" html-link)
                   (match-string 1 html-link)
                 (message "Found link %s" html-link)
                 (user-error "No link text found in the HTML link"))))
    (kill-new (format "[[%s][%s]]" url text))
    (message "Converted to Org link: [[%s][%s]]" url text)
    ;; Replace the HTML link with the Org link in the buffer
    (save-excursion
      (beginning-of-line)
      (when (re-search-forward "<a href=\"[^\"]+\">[^<]+</a>" (line-end-position) t)
        (replace-match (format "[[%s][%s]]" url text))))))
