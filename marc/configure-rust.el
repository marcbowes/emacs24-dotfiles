;; racer -- completion
;; (starter-kit-install-if-needed 'company)
;; (starter-kit-install-if-needed 'racer)
;; (eval-after-load "rust-mode" '(require 'racer))

;; installed things via cargo, including rustup!
(setenv "PATH" (concat (getenv "PATH") ":" (getenv "HOME") "/.cargo/bin"))
(add-to-list 'exec-path (concat (getenv "HOME") "/.cargo/bin"))

(defun configure-rust/setup-env ()
  "RLS requires some environment variables to be setup. We use rustup to get the values."
  
  (when (executable-find "rustup")
    (require 's)
    (require 'dash)
    (setq rust-default-toolchain
          (car (s-split " " (-first
                             (lambda (line) (s-match "default" line))
                             (s-lines (shell-command-to-string "rustup toolchain list"))))))
    ;; tell racer to use the rustup-managed rust-src
    ;; rustup component add rust-src
    (setq rust-src-path (concat (getenv "HOME") "/.multirust/toolchains/" rust-default-toolchain "/lib/rustlib/src/rust/src"))
    (setq rust-bin-path (concat (getenv "HOME") "/.multirust/toolchains/" rust-default-toolchain "/bin"))
    (setq racer-rust-src-path rust-src-path)
    (setenv "RUST_SRC_PATH" rust-src-path)
    (setenv "RUSTC" (concat rust-bin-path "/rustc"))
    (setenv "CARGO_INCREMENTAL" "1")))

(configure-rust/setup-env)

(use-package racer
        :ensure t
        :after company)

(setq configure-rust-use-lsp nil)

(if configure-rust-use-lsp
    ;; I tried to get the RLS working but could not get
    ;; xref-find-definitions working ("no result").
    (progn
      (use-package lsp-mode)

      (use-package lsp-flycheck
        :after flycheck)

      (use-package company-lsp)

      (use-package rust-mode
        :mode "\\.rs\\'" ;; this is already done by rust-mode
        :after (lsp-rust lsp-flycheck company-lsp)
        :config
        (add-hook 'rust-mode-hook #'lsp-rust-enable)
        (add-hook 'rust-mode-hook #'flycheck-enable))
      
      (use-package lsp-rust
        :after lsp-mode
        :config
        (setq lsp-rust-rls-command '("rustup" "run" "nightly" "rls"))))

  ;; Not using RLS
  (use-package rustfmt)
  
  (use-package rust-mode
    :after rustfmt
    :config
    (add-hook 'rust-mode-hook #'racer-mode)
    (add-hook 'racer-mode-hook #'eldoc-mode)
    (add-hook 'racer-mode-hook #'company-mode)
    (setq company-tooltip-align-annotations t)

    :bind (("TAB". company-indent-or-complete-common)
           ("C-c C-f" . rustfmt-format-buffer)))
  
  (use-package flycheck-rust
    :config
    (add-hook 'rust-mode-hook #'flycheck-mode)
    (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)))
