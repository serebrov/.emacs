;;; init-org-mode --- Org mode setup -*- lexical-binding: nil -*-

(use-package org
  :ensure nil
  :custom
  (org-edit-src-content-indentation 4) ;; Set src block automatic indent to 4 instead of 2.
  (org-return-follows-link t)   ;; Sets RETURN key in org-mode to follow links
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

(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode))

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

(use-package org-web-tools
  :ensure t
  :config
  (load "~/.emacs.conf/lisp/org-web-capture"))

(use-package htmlize
  :ensure t
  :defer t)
