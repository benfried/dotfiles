(defvar *helpdesk-no-auto-helpdesk-header* nil
  "*If non-nil, automatically put a Helpdesk: header in each outgoing message.")

(defun mail-helpdesk ()
  "Move point to end of helpdesk-field.  Create a helpdesk field if none."
  (interactive)
  (expand-abbrev)
  (or (mail-position-on-field "helpdesk" t)
      (progn (mail-position-on-field "to")
	     (insert "\nHelpdesk: "))))

(defun insert-date ()
  "Insert current date in abbreviated format."
  (interactive "*")
  (let* ((now (current-time-string))	;With ugly-printed timestamp
	 (firstchar (string-to-char (substring now 8 9))))
    (if (/= firstchar 32) (insert-char firstchar 1))
    (insert (substring now 9 10) " "	;Insert day of month
	    (substring now 4 7) " "	;Abbreviated name of month
	    (substring now 20 24))))	;Full year number

(defun helpdesk-question ()
  "Send a referral question, CCing the helpdesk"
  (interactive)
  (mail)
  (mail-cc)
  (insert "helpdesk@cunixc")
  (mail-helpdesk)
  (insert "question")
  (goto-char (point-max))
  (insert "\n\tUser Name: \n\tPhone Number: \n\tEmail Address: \n\t")
  (insert "Best Time to Reach User: \n\n"))
  
(defun helpdesk-mail-setup-hook ()
  (mail-helpdesk)
  (goto-char (point-max)))

(if (null *helpdesk-no-auto-helpdesk-header*)
    (cond ((null mail-setup-hook)
	   (setq mail-setup-hook 'helpdesk-mail-setup-hook))
	  ((listp mail-setup-hook)
	   (setq mail-setup-hook
		 (cons 'helpdesk-mail-setup-hook mail-setup-hook)))
	  (t
	   (setq mail-setup-hook
		 (list mail-setup-hook 'helpdesk-mail-setup-hook)))))

(define-key ctl-x-map "q" 'helpdesk-question)

(defun mail-send ()
  "Send the message in the current buffer.
If  mail-interactive  is non-nil, wait for success indication
or error messages, and inform user.
Otherwise any failure is reported in a message back to
the user from the mailer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (if (re-search-forward "^Helpdesk:" (point-max) t)
	(progn
	  (goto-char (point-min))
	  (cond ((not (re-search-forward "^Helpdesk:[ \t]*[A-Za-z]+"
					 (point-max)
					 t))
		 (mail-helpdesk)
		 (insert (read-from-minibuffer "Helpdesk: ")))))))
  (message "Sending...")
  (funcall send-mail-function)
  (set-buffer-modified-p nil)
  (delete-auto-save-file-if-necessary)
  (message "Sending...done"))
