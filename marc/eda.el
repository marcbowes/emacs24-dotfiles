(require 'ansi-color)

(defgroup eda nil
  "Eda group."
  :prefix "eda-"
  :group 'tools)

(defvar eda-minor-mode-map (make-keymap) "Eda-mode keymap.")
(defvar eda-minor-mode nil)

;;;###autoload
(define-minor-mode eda-minor-mode
  "Eda minor mode. Used to hold keybindings for eda-mode"
  nil " eda" eda-minor-mode-map)

(define-key eda-minor-mode-map (kbd "C-c e") 'helm-eda)
(define-key eda-minor-mode-map (kbd "C-c C-e l") 'eda-process-ls)

(provide 'eda)

(defgroup eda-process nil
  "Eda Process group."
  :prefix "eda-process-"
  :group 'eda)

(defun eda-process-ls ()
  (interactive)
  (eda-process--run-command "ls"))

(defun eda-process--run-command (command)
  "Run the given eda COMMAND"
  (interactive "Mcommand: ")
  (let ((buffer "*Eda*")
        (command (concat "eda " command)))
    (compilation-start command 'eda-process-mode (lambda(_) buffer))))

(defvar eda-process-mode-map
  (nconc (make-sparse-keymap) compilation-mode-map)
  "Keymap for Eda major mode.")

(define-derived-mode eda-process-mode compilation-mode "Eda-Process."
  "Major mode for the Eda process buffer."
  (use-local-map eda-process-mode-map)
  (setq major-mode 'eda-process-mode)
  (setq mode-name "Eda-Process")
  (setq-local truncate-lines t)
  (run-hooks 'eda-process-mode-hook)
  ;; (add-hook 'compilation-filter-hook #'cargo-process--add-errno-buttons)
  ;; (font-lock-add-keywords nil cargo-process-font-lock-keywords)
  )

(provide 'eda-process)

(require 'helm)

(defgroup helm-eda nil
  "Eda for helm."
  :group 'helm)

(defvar helm-eda--commands
  '("ls" "rebase"))

(defun helm-eda--init ()
  (helm-init-candidates-in-buffer 'global helm-eda--commands))

(defvar helm-source-eda-commands
  (helm-build-in-buffer-source "Eda commands"
    :init #'helm-eda--init
    :persistent-action #'ignore
    :filtered-candidate-transformer
    (lambda (candidates _source)
      (sort candidates #'helm-generic-sort-fn))
    :action '(("Run Eda command" . eda-process--run-command))
    :group 'helm-eda))

(defun helm-eda (arg)
  "`helm' for Eda."
  (interactive "P")
  (when arg (setq helm-eda--commands nil))
  (helm :sources 'helm-source-eda-commands
        :buffer "*helm eda*"))

(provide 'helm-eda)
