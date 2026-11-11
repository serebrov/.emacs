;;; org-convert-html-link --- Various utils -*- lexical-binding: t -*-

;;; Code:
(require 'org)

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

;; Convert org entry with :_note: property into a link
;; If the org entry has ~: something~ or ~| something~ at the end, this part
;; becomes the link.
;; Otherwise, the whole enntry becomes the link.
;; For example:
;; * Files, BOM and instructions are uploaded! : r/ErgoMechKeyboards
;;   :PROPERTIES:
;;   :_note: https://www.reddit.com/r/ErgoMechKeyboards/comments/1s1kzhx
;;   :END:
;; Becomes:
;; * Files, BOM and instructions are uploaded! : [[https://www.reddit.com/r/ErgoMechKeyboards/comments/1s1kzhx][r/ErgoMechKeyboards]]
;; And
;; * How to rig elections [video] | Hacker News
;; :PROPERTIES:
;; :_note: https://news.ycombinator.com/item?id=44899415
;; :END:
;; Becomes:
;; * How to rig elections [video] | [[https://news.ycombinator.com/item?id=44899415][Hacker News]]
(defun my/org-note-to-link ()
  "Convert the current org entry's `_note' property into a link in the heading.
If the heading ends with \": something\" or \"| something\", only that
part becomes the link text.  Otherwise the whole heading becomes the link."
  (interactive)
  (let ((url (org-entry-get nil "_note")))
    (unless (and url (not (string-empty-p (string-trim url))))
      (user-error "No _note property in this entry"))
    (setq url (string-trim url))
    ;; sometimes the :note: is the org link [[link][link]],
    ;; in that case, we want to extract the link from it
    (when (string-match "\\[\\[\\([^]]+\\)\\]\\[\\([^]]+\\)\\]\\]" url)
      (setq url (match-string 1 url)))
    (save-excursion
      (org-back-to-heading t)
      (unless (and (looking-at org-complex-heading-regexp)
                   (match-beginning 4))
        (user-error "Cannot find heading text"))
      (let* ((title-beg (match-beginning 4))
             (title-end (match-end 4))
             (title (match-string-no-properties 4))
             (start title-beg)
             (text title))
        (when (string-match "[:|][ \t]+\\([^:|]+?\\)[ \t]*\\'" title)
          (setq start (+ title-beg (match-beginning 1))
                text (match-string 1 title)))
        (delete-region start title-end)
        (goto-char start)
        (insert (format "[[%s][%s]]" url text))
        (org-back-to-heading t)
        (org-entry-delete nil "_note")))))

;; Helper to convert all entries in the buffer with :_note: property into links
(defun my/org-note-to-link-all ()
  "Convert every entry in the buffer having a `_note' property into a link.
Each entry is processed with `my/org-note-to-link'.  Entries that
cannot be converted are skipped and reported at the end."
  (interactive)
  (unless (derived-mode-p 'org-mode)
    (user-error "Not in an org-mode buffer"))
  (let ((markers nil)
        (converted 0)
        (failed 0))
    (save-excursion
      (save-restriction
        (widen)
        ;; Collect markers first, since converting modifies the buffer.
        (setq markers
              (delq nil
                    (org-map-entries
                     (lambda ()
                       (let ((url (org-entry-get nil "_note")))
                         (when (and url
                                    (not (string-empty-p (string-trim url))))
                           (point-marker))))
                     nil nil)))
        (dolist (marker markers)
          (goto-char marker)
          (condition-case err
              (progn
                (my/org-note-to-link)
                (setq converted (1+ converted)))
            (error
             (setq failed (1+ failed))
             (message "Skipped entry at line %d: %s"
                      (line-number-at-pos)
                      (error-message-string err))))
          (set-marker marker nil))))
    (message "Converted %d entr%s%s"
             converted
             (if (= converted 1) "y" "ies")
             (if (> failed 0) (format ", skipped %d" failed) ""))))
