(defvar *head-ui-list* "chuck, ben"
  "The list of head UI's, in a format suitable for a mail TO field")

(defun insert-date ()
  "Insert current date in abbreviated format."
  (interactive "*")
  (let* ((now (current-time-string))	;With ugly-printed timestamp
	 (firstchar (string-to-char (substring now 8 9))))
    (if (/= firstchar 32) (insert-char firstchar 1))
    (insert (substring now 9 10) " "	;Insert day of month
	    (substring now 4 7) " "	;Abbreviated name of month
	    (substring now 20 24))))	;Full year number

(defun report ()
  "Send the head UI's a progress report for the previous week."
  (interactive)
  (setq fill-prefix "\t")
  (mail)
  (mail-to)
  (insert *head-ui-list*)
  (goto-char (point-max))
  (insert "\n" "\tFrom: " (user-full-name) "\n\n")
  (insert "\tDate: ")
  (insert-date) (insert "\n\n")
  (insert "\tProject: "
	  (if (boundp '*project*)
	      *project*
	    (read-from-minibuffer "Project: "))
	  "\n\n\t"))
