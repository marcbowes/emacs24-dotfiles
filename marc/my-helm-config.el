;; http://tuhdo.github.io/helm-intro.html

(require 'helm-config)
(helm-mode 1)

(global-set-key (kbd "C-x C-f") 'helm-find-files)
