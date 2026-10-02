;;; init-org-mode --- Org mode setup -*- lexical-binding: nil -*-

;; Org mode is a markup language and a set of related tools
;; to create and manage notes, capture information, manage TODO lists,
;; track time on tasks, schedule tasks, and more.
;; Capturing notes:
;; - `M-x org-capture` (C-c c) captures a note, asks for a template (configured below)
;; Saving and inserting links:
;; - `M-x org-store-link` (C-c l) stores a link to the current location
;; - `M-x org-insert-link` (C-c C-l) inserts a link to the current location
;; Images (in both cases the image is safed in the data folder near the org file):
;; - Drag and drop an image into an org file to insert a link to it.
;; - `M-x yank-media` to insert a link.
;; See also: ./demo.org
(use-package org
  :ensure nil
  :custom
  (org-edit-src-content-indentation 4) ;; Set src block automatic indent to 4 instead of 2.
  (org-return-follows-link t)   ;; Sets RETURN key in org-mode to follow links
  ;; org starts with truncation by default, because:
  ;; This is useful since some lines containing links can be very long and
  ;; uninteresting.  Also tables look terrible when wrapped.
  (org-startup-truncated t)
  ;; Open links in the same buffer (default is find-file-other-window)
  (org-link-frame-setup '((file . find-file)))
  (org-capture-templates
   '(("w" "🌎 Webpage As File" entry
      ;; Fetches the first URL in the clipboard or kill ring into
      ;; a new file YYYY-MM-DD-hh-mm-webpage-title.org.
      (file (lambda () (org-web-capture-file "~/web/org/webpages")))
      "%(org-capture-get :web-entry)"
      )
     ("e" "🌎 Webpage As Entry" entry
      (file "~/web/org/webpages/web.org")
      ;; Fetches the first URL in the clipboard or kill ring.
      "%(org-web-tools--url-as-readable-org)"
      :prepend t
      :empty-lines-after 2
      )
     ("l" "🌐 Link" entry
      (file "~/web/org/notes/links.org")
      ;; Link to the first URL in the clipboard or kill ring, with the page title.
      "* %(org-web-tools--org-link-for-url) %^g\n %?\n %T\n %i"
      :prepend t
      :empty-lines-after 2
      )
     ("r" "🌐 Reading Inbox" entry
      (file "~/web/org/notes/inbox.org")
      ;; Link to the first URL in the clipboard or kill ring, with the page title.
      "* %(org-web-tools--org-link-for-url) %^g\n %?\n %T\n %i"
      :prepend t
      :empty-lines-after 2
      )
     ("t" "✔ To-Do-Item" entry
      (file "~/web/org/notes/todo.org")
      "* TODO %?\n  %i\n  %a"
      :prepend t
      :empty-lines-after 2
      )
     ("n" "📖 Note" entry
      (file+headline "~/web/org/notes/notes.org" "Notes")
      "* Note %? %^g \n%T"
      :prepend t
      :empty-lines-after 2
      )
     ))
  :hook
  (org-mode . org-indent-mode) ;; Indent text
  ;; The following prevents <> from auto-pairing when electric-pair-mode is on.
  ;; Otherwise, org-tempo is broken when you try to <s TAB...
  (org-mode . (lambda ()
                (setq-local electric-pair-inhibit-predicate
                            `(lambda (c)
                               (if (char-equal c ?<) t (,electric-pair-inhibit-predicate c))))))
  )

;; When enabled, replaces :TOC: tag with a table of contents in org-mode on file save.
;; Also works in markdown-mode.
(use-package toc-org
  :commands toc-org-enable
  :hook (org-mode . toc-org-mode))

;; Display pretty bullets in org-mode.
(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode))

;; Enable the <s TAB> and <e TAB> shortcuts for inserting source blocks in org-mode.
;; Shortcuts for source blocks:
;; <s + TAB - insert a source block
;; <e + TAB - insert an example block
;; <q + TAB - insert a quote block
;; <v + TAB - insert a verse block
(use-package org-tempo
  :ensure nil
  :after org)

;; (use-package jupyter
;;   :demand t
;;   :after (:all org python))

(setq org-babel-python-command "python3")
;; Enable python and bash support in org-babel, so that we can run code blocks in org-mode.
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   ;; (jupyter . t)
   (shell . t)))

;; Displays the current org heading in the header line.
(use-package org-sticky-header
  :after org
  :hook (org-mode . org-sticky-header-mode))

;; Org <-> OPML export and import.
;; Useful for WorkFlowy.
;; OPML files are converted on-the-fly and displayed as org-mode files.
;; Points to my fort with the fix for nodes with properties:
;; https://github.com/serebrov/org-opml
(setq org-opml-src "~/web/emacs/org-opml-v2/")
(use-package ox-opml
  :ensure t
  :load-path org-opml-src)
(use-package org-opml
  :ensure t
  :load-path org-opml-src)

;; Capture webpages and links.
(use-package org-web-tools
  :ensure t
  :config
  (load "~/.emacs.conf/lisp/org-web-capture"))

;; Download images.
;; Put the cursor on a link, copy it (can do viy if on an org link)
;; then run `org-download-yank` to download the image and insert a
;; local link into the org file.
(use-package org-download
  :ensure t
  :config
  (setq-default org-download-image-dir "~/web/org/images")
  ;; Keep all images in `org-download-image-dir'. The default puts them
  ;; in a subdirectory named after the top heading, which is a link in
  ;; captured web pages.
  (setq-default org-download-heading-lvl nil)
  ;; Drag-and-drop to `dired`
  (add-hook 'dired-mode-hook 'org-download-enable))

;; Highlight and annotate in org-mode.
;; org-remark-mark to add a mark
;; org-remark-open to open related notes
(use-package org-remark-global-tracking
  ;; It is recommended that `org-remark-global-tracking-mode' be
  ;; enabled when Emacs initializes. You can set it in
  ;; `after-init-hook'.
  :hook after-init
  :config
  ;; (setq org-remark-default-feature-modes
  ;;       '(org-remark-info-mode org-remark-eww-mode org-remark-nov-mode))
  (defun my/org-remark-notes-file ()
    (concat "~/web/org/remark-notes/"
            (file-name-base (org-remark-notes-file-name-function))
            ".org"))

  (setq org-remark-notes-file-name
        #'my/org-remark-notes-file)

  ;; Selectively keep or comment out the following if you want to use
  ;; extensions for Info-mode, EWW, and NOV.el (EPUB) respectively.
  (use-package org-remark-info :after info :config (org-remark-info-mode +1))
  (use-package org-remark-eww  :after eww  :config (org-remark-eww-mode +1))
  (use-package org-remark-nov  :after nov  :config (org-remark-nov-mode +1)))

(use-package org-remark
  :bind (;; :bind keyword also implicitly defers org-remark itself.
         ;; Keybindings before :map is set for global-map. Adjust the keybinds
         ;; as you see fit.
         ("C-c n m" . org-remark-mark)
         ("C-c n l" . org-remark-mark-line)
         :map org-remark-mode-map
         ("C-c n o" . org-remark-open)
         ("C-c n ]" . org-remark-view-next)
         ("C-c n [" . org-remark-view-prev)
         ("C-c n r" . org-remark-remove)
         ("C-c n d" . org-remark-delete)))

;; Export org to HTML with syntax highlighting for code blocks.
(use-package htmlize
  :ensure t
  :defer t)
