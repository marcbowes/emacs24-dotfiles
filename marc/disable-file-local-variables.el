;; Turn off file variables
;; 1. I never use this
;; 2. It can run arbitrary code
;; 3. It messes with things like auto-mode-alist
;; See: http://www.gnu.org/software/emacs/manual/html_node/emacs/Safe-File-Variables.html#Safe-File-Variables
(setq enable-local-variables nil
      enable-local-eval nil)
