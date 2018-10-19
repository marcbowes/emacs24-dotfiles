(use-package projectile
  :ensure t
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

  ;; Tell projectile about all our ws roots
  (setq projectile-project-search-path
        (remove nil (mapcar
                     (lambda (dir)
                       (when (and (file-directory-p dir)
                                  (not (member (file-name-nondirectory dir) '(".." "."))))
                         (concat dir "/src/")))
                     (directory-files "~/workplace" t))))
  (projectile-mode +1)
  
  (projectile-global-mode)
  (use-package helm-projectile
    :ensure t
    :config (helm-projectile-on)))
