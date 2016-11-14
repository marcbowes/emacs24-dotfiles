;; racer -- completion
(starter-kit-install-if-needed 'company)
(starter-kit-install-if-needed 'racer)
(eval-after-load "rust-mode" '(require 'racer))

;; installed things via cargo, including rustup!
(setenv "PATH" (concat (getenv "PATH") ":" (getenv "HOME") "/.cargo/bin"))
(add-to-list 'exec-path (concat (getenv "HOME") "/.cargo/bin"))

;; use rustup to configure the default toolchain
(when (executable-find "rustup")
  (starter-kit-install-if-needed 's 'dash)
  (require 's)
  (require 'dash)
  (setq rust-default-toolchain
        (car (s-split " " (-first
                           (lambda (line) (s-match "default" line)) 
                           (s-lines (shell-command-to-string "rustup toolchain list"))))))
  ;; tell racer to use the rustup-managed rust-src
  ;; rustup component add rust-src
  (setq racer-rust-src-path (concat (getenv "HOME") "/.multirust/toolchains/" rust-default-toolchain "/lib/rustlib/src/rust/src")))

(require 'rust-mode)
(add-hook 'rust-mode-hook #'racer-mode)
(add-hook 'racer-mode-hook #'eldoc-mode)
(add-hook 'racer-mode-hook #'company-mode)
(setq company-tooltip-align-annotations t)
(define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)

(starter-kit-install-if-needed 'flycheck-rust)
(add-hook 'rust-mode-hook #'flycheck-mode)
(add-hook 'flycheck-mode-hook #'flycheck-rust-setup)

(starter-kit-install-if-needed 'rustfmt)
(define-key rust-mode-map (kbd "C-c C-f") #'rustfmt-format-buffer)
