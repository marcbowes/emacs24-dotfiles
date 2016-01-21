;; racer -- completion
(starter-kit-install-if-needed 'company)
(starter-kit-install-if-needed 'racer)
(eval-after-load "rust-mode" '(require 'racer))

(setq racer-rust-src-path (concat (getenv "HOME") "/code/rust/rust/src"))

(require 'rust-mode)
(add-hook 'rust-mode-hook #'racer-mode)
(add-hook 'racer-mode-hook #'eldoc-mode)
(add-hook 'racer-mode-hook #'company-mode)
(setq company-tooltip-align-annotations t)
(define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)

(starter-kit-install-if-needed 'flycheck-rust)
(add-hook 'rust-mode-hook #'flycheck-mode)
(add-hook 'flycheck-mode-hook #'flycheck-rust-setup)

;; installed things on stable
(starter-kit-install-if-needed 'rustfmt)
(define-key rust-mode-map (kbd "C-c C-f") #'rustfmt-format-buffer)
(setenv "PATH" (concat (getenv "PATH") ":" (getenv "HOME") "/.multirust/toolchains/stable/cargo/bin"))
(add-to-list 'exec-path (concat (getenv "HOME") "/.multirust/toolchains/stable/cargo/bin"))
