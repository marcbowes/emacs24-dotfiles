(starter-kit-load "misc-recommended")

;; remove diff-mode being activated for COMMIT_EDITMSG
;; this is not in customize-magit.el because of ordering issues.
(delq (assoc "COMMIT_EDITMSG$" auto-mode-alist) auto-mode-alist)

(starter-kit-load "org")

(starter-kit-install-if-needed 'paredit)
(require 'paredit)
(starter-kit-load "lisp")

(let ((filename "/COMMIT_EDITMSG"))
  (loop for (expr . mode) in auto-mode-alist
        when (string-match expr filename)
        collect (cons expr mode)))

(starter-kit-install-if-needed 'use-package)
