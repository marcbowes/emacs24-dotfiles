(starter-kit-load "ruby")
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))

;; Setting rbenv path
(setq rbenv-installation-dir (concat (getenv "HOME") ".rbenv"))
(require 'rbenv)
(global-rbenv-mode)

;; And for things that rbenv.el doesn't handle, we fix exec-path too
(setenv "PATH" (concat (getenv "HOME") "/.rbenv/shims:" (getenv "HOME") "/.rbenv/versions/2.1.5/bin" (getenv "PATH")))
(setq exec-path (cons (concat (getenv "HOME") "/.rbenv/shims") (cons (concat (getenv "HOME") "/.rbenv/versions/2.1.5/bin") exec-path)))

;; flymake-ruby
(setq flymake-ruby-executable (concat (getenv "HOME") "/.rbenv/shims/ruby"))
(require 'flymake-ruby)
;; I have no idea why this is required, but it is if you want it to
;; work properly with rbenv..
(add-hook 'ruby-mode-hook 'flymake-ruby-load)

;; https://github.com/JoshCheek/rcodetools/blob/master/README.emacs
;; You need to do this: gem install rcodetools fastri
(add-to-list 'load-path (concat starter-kit-dir "vendor/rcodetools"))
(require 'rcodetools)

;; Stolen from https://github.com/avdi/.emacs24.d/blob/master/init.d/ruby.el
(eval-after-load 'ruby-mode
  '(progn 
     (require 'rcodetools)
     ;; FIXME: How to use the exec-path to find a bin?
     ;; FIXME: Or use the value of flymake-ruby-executable
     (setq xmpfilter-command-name (concat (getenv "HOME") "/.rbenv/shims/ruby" " -S xmpfilter --dev --fork --detect-rbtest"))
     (define-key ruby-mode-map (kbd "C-c C-c") 'xmp)))
