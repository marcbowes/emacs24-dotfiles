;; racer -- completion
(starter-kit-install-if-needed 'company)
(setq racer-rust-src-path (concat (getenv "HOME") "/code/rust/rust/src"))
(setq racer-cmd (concat (getenv "HOME") "/code/rust/racer/target/release/racer"))
(add-to-list 'load-path (concat (getenv "HOME") "/code/rust/racer/editors/emacs"))
(eval-after-load "rust-mode" '(require 'racer))
(require 'racer)
(add-hook 'rust-mode-hook #'racer-activate)
(define-key rust-mode-map (kbd "TAB") #'racer-complete-or-indent)
(define-key rust-mode-map (kbd "M-.") #'racer-find-definition)

;; installed things on nightly
(starter-kit-install-if-needed 'rustfmt)
(define-key rust-mode-map (kbd "C-c C-f") #'rustfmt-format-buffer)
(setenv "PATH" (concat (getenv "PATH") ":" (getenv "HOME") "/.multirust/toolchains/nightly/cargo/bin"))
(add-to-list 'exec-path (concat (getenv "HOME") "/.multirust/toolchains/nightly/cargo/bin"))
