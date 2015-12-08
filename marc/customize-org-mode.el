(require 'package)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

(add-to-list 'load-path (concat starter-kit-dir "vendor/orgmode-mediawiki"))
(require 'ox-mediawiki)

;; babel

(org-babel-do-load-languages
 'org-babel-load-languages
 '(
   (sh . t)
   (ruby . t)
   (dot . t)
   (perl . t)
   ))

;; its fine, trust me

(setq org-confirm-babel-evaluate nil)
