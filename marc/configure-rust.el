;; racer -- completion
(starter-kit-install-if-needed 'company)
(starter-kit-install-if-needed 'racer)
(eval-after-load "rust-mode" '(require 'racer))

(setq racer-rust-src-path (concat (getenv "HOME") "/code/rust/rust/src"))

(require 'rust-mode)
(add-hook 'rust-mode-hook #'racer-activate)
(define-key rust-mode-map (kbd "TAB") #'racer-complete-or-indent)
(define-key rust-mode-map (kbd "M-.") #'racer-find-definition)

;; installed things on stable
(starter-kit-install-if-needed 'rustfmt)
(define-key rust-mode-map (kbd "C-c C-f") #'rustfmt-format-buffer)
(setenv "PATH" (concat (getenv "PATH") ":" (getenv "HOME") "/.multirust/toolchains/stable/cargo/bin"))
(add-to-list 'exec-path (concat (getenv "HOME") "/.multirust/toolchains/stable/cargo/bin"))
