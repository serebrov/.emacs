;;; org-download-smart.el --- Helpers to download images -*- lexical-binding: t -*-

;;; Commentary:

;; Source:
;; https://www.reddit.com/r/emacs/comments/1iuqoe1/use_orgdownload_to_download_image_links_in_an/
;;
;; my/preview-org-image for quickly previewing images.
;; my/org-download-smart for downloading images.
;;
;; If executed on an image link, it directly downloads the image corresponding
;; to that link.
;;
;; If executed outside an image link, it bulk downloads all the images linked
;; in the org file.

(defun my/preview-org-image ()
  "Preview org link image in a split window on the right."
  (interactive)
  (let* ((element (org-element-context))
         (type (org-element-type element))
         (link (org-element-property :raw-link element)))
    (when (and (eq type 'link) link)
      (let ((right-window (or (window-in-direction 'right)
                              (split-window-right))))
        (select-window right-window)
        (eww link)))))
;; (define-key org-mode-map (kbd "C-c z") 'my/preview-org-image)

(defun my/org-download-no-comment (_link)
  "Annotate without the DOWNLOADED comment."
  "")

(setq org-download-annotate-function #'my/org-download-no-comment)

(defun my/org-download-smart ()
  "Smart download function that decides action based on cursor position."
  (interactive)
  (let* ((element (org-element-context))
         (type (org-element-type element)))
    (cond
     ((eq type 'link)
      (message "Cursor is on a link, downloading single image...")
      (let* ((link (org-element-property :raw-link element))
             (begin (org-element-property :begin element))
             (end (org-element-property :end element)))
        (save-excursion
          (goto-char begin)
          (delete-region begin end)
          (org-download-image link))))
     (t
      (message "Cursor not on link, checking all images...")
      (let* ((tree (org-element-parse-buffer))
             (links (org-element-map tree 'link
                      (lambda (link)
                        (when (string-match-p "\\(\\.png\\|\\.jpg\\|\\.jpeg\\|\\.webp\\|wx_fmt=png\\)"
                                              (org-element-property :raw-link link))
                          (list (org-element-property :raw-link link)
                                (org-element-property :begin link)
                                (org-element-property :end link))))))
             (total (length links)))
        (if (= total 0)
            (message "No image links found")
          (when (y-or-n-p (format "Found %d image links. Download them? " total))
            (dolist (link-info (reverse links))
              (let ((link (nth 0 link-info))
                    (begin (nth 1 link-info))
                    (end (nth 2 link-info)))
                (save-excursion
                  (goto-char begin)
                  (delete-region begin end)
                  (org-download-image link)))))))))))

;; (define-key org-mode-map (kbd "C-c y") 'my/org-download-smart)
