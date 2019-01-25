;; Installed with homebrew
;; export EMACS=...
;; brew install mu --with-emacs --HEAD
;; (add-to-list 'load-path (expand-file-name "/usr/local/share/emacs/site-lisp/mu4e/"))
(add-to-list 'load-path "/Users/bowes/code/mu/mu4e")
                                        ; development
(require 'mu4e)
(require 'smtpmail)

;; https://w.amazon.com/index.php/Emacs/Email

(setq mu4e-maildir (concat (getenv "HOME") "/.mail"))
(setq mu4e-get-mail-command "mbsync -q amzn") ; FIXME: gmail
(setq user-mail-address "bowes@amazon.com")
(setq user-full-name "Marc Bowes")

;; http://www.djcbsoftware.nl/code/mu/mu4e/Displaying-rich_002dtext-messages.html#Displaying-rich_002dtext-messages
;; For Mac's HTML mails
;; (setq mu4e-html2text-command
;;       "textutil -stdin -format html -convert txt -stdout")
;; brew install w3m
(setq mu4e-html2text-command "w3m -T text/html")

(setq mu4e-bookmarks (list '("date:today..now flag:unread and not flag:trashed and not mime:text/calendar"       "Unread today"      ?r)
                           '("date:7d..now flag:unread and not flag:trashed and not mime:text/calendar"          "Unread last week"  ?w)
                           '("date:7d..now and not flag:trashed and not mime:text/calendar"                      "Last week"         ?m)))
;; (add-to-list 'mu4e-bookmarks
;;              '("date:today..now flag:unread"       "Unread today"      ?r)
;;              '("date:7d..now flag:unread"          "Unread last week"  ?w)
;;              ;; '("size:5M..500M"                     "Big messages"      ?h)
;;              )

; use msmtp
(setq message-send-mail-function 'message-send-mail-with-sendmail)
(setq sendmail-program "msmtp")
; tell msmtp to choose the SMTP server according to the from field in the outgoing email
(setq message-sendmail-extra-arguments '("--read-envelope-from"))
(setq message-sendmail-f-is-evil 't)

;; I really don't like this.
;; TODO: look into flow and hardlines
(add-hook 'mu4e-compose-mode-hook (lambda () (turn-off-auto-fill)))

;; Older mail conf. FIXME: consolidate.

;; ;; these must start with a "/", and must exist
;; ;; (i.e.. /home/user/Maildir/sent must exist)
;; ;; you use e.g. 'mu mkdir' to make the Maildirs if they don't
;; ;; already exist

;; ;; below are the defaults; if they do not exist yet, mu4e offers to
;; ;; create them. they can also functions; see their docstrings.
;; ;; (setq mu4e-sent-folder   "/sent")
;; ;; (setq mu4e-drafts-folder "/drafts")
;; ;; (setq mu4e-trash-folder  "/trash")

;; ;; smtp mail setting; these are the same that `gnus' uses.
;; (setq mu4e-sent-folder "/bowes@amazon.com/Sent Items"
;;       mu4e-drafts-folder "/bowes@amazon.com/Drafts"
;;       mu4e-trash-folder  "/bowes@amazon.com/Deleted Items"
;;       user-mail-address "bowes@amazon.com"
;;       smtpmail-default-smtp-server "ballard.amazon.com"
;;       smtpmail-local-domain "amazon.com"
;;       smtpmail-smtp-user "ANT\\bowes"
;;       smtpmail-smtp-server "ballard.amazon.com"
;;       smtpmail-stream-type 'starttls
;;       smtpmail-smtp-service 1587)

;; (setq mu4e-get-mail-command "mbsync -a"
;;       send-mail-function 'smtpmail-send-it
;;       ;; mu4e-update-interval 300 ;; I found updating interval is quite annoying; prefer to use "U" to do that explicitly
;;       message-kill-buffer-on-exit t)

;; ;; you can quickly switch to your Inbox -- press ja
;; (setq mu4e-maildir-shortcuts
;;       '(("/bowes@amazon.com/Inbox"               . ?a)
;;       ;; Add others if needed.
;;        ))

;; mu4e uses async processes which means it's hard to sometimes enable
;; this (e.g. with a let-binding). Because I update the index in a
;; timer task, it's better to just always have the messages hidden.
(setq mu4e-hide-index-messages t)
(setq mu4e-debug nil)

(defun marc/mu4e-update-mail-and-index ()
  "This is the same as `mu4e-hide-index-messages' but with some
better support for running it in a timer, e.g. it is quieter and
handles slow updates better (doesn't snowball)."
  (when mu4e-get-mail-command
    ;; don't update when reading mail - it's annoying
    (unless (and (buffer-live-p mu4e~update-buffer)
	         (process-live-p (get-buffer-process mu4e~update-buffer)))
      (run-hooks 'mu4e-update-pre-hook)
      (mu4e~update-mail-and-index-real t (if (get-buffer-window "*mu4e-headers*") t nil)))))

(run-with-timer 10 60 #'marc/mu4e-update-mail-and-index)

(defun marc/mu4e-open-crs ()
  "Open any CRs for all mails in the current headers view that are not marked read.

This is useful because the plaintext version of CRUX mails don't
always contain clickable links."
  (interactive)
  (unless (eq 'mu4e-headers-mode major-mode)
    (user-error "must be in headers view"))
  (let ((crs '()))
    (mu4e-headers-for-each
     (lambda (msg)
       (when (and (memq 'unread (mu4e-message-field msg :flags))
                  (string-match "\\(CR-[0-9]+\\)" (mu4e-message-field msg :subject)))
         (pushnew (match-string 1 (mu4e-message-field msg :subject)) crs))))
    (mapcar (lambda (cr) (marc/open-cr cr))
            (remove-duplicates crs :test 'string-equal))))

(defun marc/open-cr (cr)
  (browse-url (format "https://code.amazon.com/reviews/%s" cr)))

(defun marc/mu4e-open-cr-at-point ()
  (interactive)
  (let* ((msg (get-text-property (line-beginning-position) 'msg))
         (subject (mu4e-message-field msg :subject)))
    (when (string-match "\\(CR-[0-9]+\\)" subject)
      (marc/open-cr (match-string 1 subject)))))

(defun marc/mu4e-mark-mails-from-sender (sender)
  "In the current headers view, find mails sent from SENDER and mark them.

This function exists because mu-find doesn't support searching by sender - https://github.com/djcb/mu/issues/1364.
To implement, we have to read each raw mail from disk because `mu4e-message-field' does not include Sender."
  (unless (eq 'mu4e-headers-mode major-mode)
    (user-error "must be in headers view"))
  (mu4e-headers-for-each
   (lambda (msg)
     (let ((path (mu4e-message-field msg :path)))
       (if (and path (file-readable-p path))
           (when (string-match (concat "Sender: " sender)
                               (with-temp-buffer
                                 (insert-file-contents path)
                                 (buffer-string)))
             (mu4e-mark-at-point 'something nil))
         (message "Not a readable file: %S" path))))))

(defun marc/mu4e-mark-sims ()
  (interactive)
  (marc/mu4e-mark-mails-from-sender "Issues <issues@amazon.com>"))

;; notmuch

;; https://notmuchmail.org/getting-started/
;; 
;; brew install notmuch --with-emacs
;; 
;; notmuch
;; Your full name [Bowes]: Marc Bowes
;; Your primary email address [bowes@bws.(none)]: bowes@amazon.com
;; Additional email address [Press 'Enter' if none]:
;; Top-level directory of your email archive [/Users/bowes/mail]: /Users/bowes/.mail
;; Tags to apply to all new messages (separated by spaces) [unread inbox]:
;; Tags to exclude when searching messages (separated by spaces) [deleted spam]:
;;
;; notmuch new
;;
;; ... at this point I realize notmuch isn't going to work because it
;; doesn't synchronize flags back to the mailserver. Which sucks.
