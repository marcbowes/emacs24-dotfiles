;; amazon
(add-to-list 'load-path "/apollo/env/EmacsAmazonLibs/share/emacs/site-lisp")
(add-to-list 'load-path (concat starter-kit-dir "vendor/EmacsAmazonLibs"))
(require 'amz-brazil-config)

(add-to-list 'auto-mode-alist '("Config$" . brazil-config-mode))
