(starter-kit-install-if-needed 'haml-mode)
(require 'haml-mode)
(add-to-list 'auto-mode-alist '("\\.haml$" . haml-mode))

(starter-kit-install-if-needed 'flymake-haml)
(require 'flymake-haml)
(add-hook 'haml-mode-hook 'flymake-haml-load)
