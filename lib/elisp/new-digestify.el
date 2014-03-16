From steiner@topaz.rutgers.edu Tue Jun 27 17:46:20 1989
Flags: 000000000001
Received: from topaz.rutgers.edu by cunixc.cc.columbia.edu (5.54/5.10) id AA07923; Tue, 27 Jun 89 17:44:57 EDT
Received: by topaz.rutgers.edu (5.59/SMI4.0/RU1.1/3.04) 
	id AA02899; Tue, 27 Jun 89 17:19:57 EDT
Date: Tue, 27 Jun 89 17:19:57 EDT
From: steiner@topaz.rutgers.edu (Dave Steiner)
Message-Id: <8906272119.AA02899@topaz.rutgers.edu>
To: jtw@lcs.mit.edu, cross@cs2.wsu.edu, ray@gibbs.physics.purdue.edu,
        vj@cxa.daresbury.ac.uk, fmr.cwi.nl@topaz.rutgers.edu,
        mike@nexus.yorku.ca, alien@vulcan.ese.essex.ac.uk, kim@kannel.lut.fi,
        grover@potomac.ads.com, lea@compass.com, warsaw@cme.nbs.gov
Cc: luken@spot.cc.lehigh.edu, fritzson@prc.unisys.com, mlijews@nswc-wo.arpa,
        ben@cunixc.cc.columbia.edu, jsol@bu-it.bu.edu, kdw1@tank.uchicago.edu,
        gordon@hci.heriot-watt.ac.uk, mdb@silvlis.com
Subject: latest verion of my GNUEmacs RMAIL digest program
Status: RO


Here's the latest version.  Please let me know if you have any
problems or suggestions.  Someone had asked about an undigest.el; I
belive that's already in emacs.  This should work with any version
although I've been using v18.51.  -ds

 ----------------------------------------------------------------------

These are the files to run the digestifying program.  They are
digest.el, some additions to the site-init.el file, and a info file on
how to run and setup the digest program (I've replaced the control
char ^_ with the two chars ^_ so that they don't screw up Rmail;
you'll want to replace them back).  (Don't forget to compile
digest.el) The rest are patches to various files.  Besides the digest
code are some functions to make digestifying easier.  You don't have
to include these if you don't want to.

They include summary-by-{senders,subject,date,to} (written by someone
else here at Rutgers), rmail-resend, multiple delete of messages, and
multiple output of messages.  You will definitely need the patches to
mail-utils.el.

Any problems or suggestions should be sent to me.  We've been using
this at Rutgers for quite some time so most of the bugs should be out.

ds

arpa: Steiner@TOPAZ.RUTGERS.EDU
uucp: ...{ames, cbosgd, harvard, moss}!rutgers!topaz.rutgers.edu!steiner

==================================================digest.el:
;;; Digest(ify) program
;;; written by Dave Steiner (Steiner@topaz.rutgers.edu)
;;; Copyright (C) 1987,1988,1989 David K. Steiner
;;; Create Arpanet-style Digests using Rmail.  (See rfc934)

;;; Edit History: (Any edits to other files are in the normal Rutgers
;;;                edit history)
;;;
;;; 26-Jun-89  setting of mail-default-reply-to in digest-move-messages
;;;            now checks for a "@" in the digest-name and will use the
;;;            digest-to-address field if it exists.
;;; 31-Oct-88  mail-get-message-list changed to mail-get-list and a new
;;;	       argument added.
;;; 25-Oct-88  digest-get-message-list changed to mail-get-message-list
;;;	       with new arguments.
;;; 23-Mar-88  When asking about whether to ignore a long line, insert a 
;;;            pointer and highlight the line.
;;; 18-Feb-88  Fixed typo in digest-next-error.  Added #messages to message
;;;            printed when done.  Print out "(blank Subject line)" instead
;;;            of blank line in topics.  Added individual message counts to
;;;            fcn digest-char-count.
;;;  7-Feb-88  put single quotes around the END_OF_DIGEST_MARKER.
;;;  6-Feb-88  Remove call to digest-send-after since this function isn't
;;;            needed (and therefore never written).
;;;  6-Feb-88  Don't hardcode Errors-to: or digest-moderators-address 
;;;            machine names.  Add a var for digest-errors-to-address.
;;;  6-Feb-88  Add Digest-Char-Count and fixed typos in info/digest
;;; 25-Jan-88  Added after switch code.
;;; 31-Nov-87  Fixed error-list's second arg to be a marker, not just point.
;;;  3-Sep-87  insert an Errors-to: header into the digest.  Setup
;;;            mail-setup-hook depending on what the value of
;;;            digest-use-mail-setup-hook is.
;;;  2-Sep-87  Fixed digest-style-date to handle single digit days
;;;            correctly.  (eg, look for " 2", not "02").
;;; 26-Aug-87  Started adding after switch code. 
;;; 25-Aug-87  Added this library.
;;;

(require 'mail-utils)

;these are defined in site-init.el
;(defvar digest-max-characters 17000
;  "*Maximum number of characters allowed in a digest (a soft limit).")
;(defvar digest-max-line-length 75
;  "*Maximum number of characters per line allowed (a soft limit).")
;(defvar digest-remail-address nil
;  "*If non-nil, remail each message to this address.")
;(defvar digest-default-directory nil
;  "*If nil, will use the current directory as the default directory,
;otherwise will use this variable.")
;(defvar digest-mail-self-blind nil
;  "*Non-nil means insert BCC to self in digest message.  Used to override
;mail-self-blind variable.")
;(defvar digest-delete-msgs-p t
;  "*If non-nil, set each message deleted that is used in making the digest.")
;(defvar digest-use-mail-setup-hook t
;  "*If nil, don't use the mail-setup-hook, if t, use it, and if not t or
;nil, will use that as the value for mail-setup-hook.")
;(defvar digest-errors-to-address nil
;  "*If non-nil, use this address for the Errors-To: field, instead of the
;digest-moderator-address.")
;(defvar digest-to-address nil
;  "*If non-nil, use this address for the To: and Reply-To: fields, instead
;of the digest-name.")

;;; All these variables are gotten from the digest.info file.

(defvar digest-mailing-list-address ""
  "Address of the mailing list. (Ex. 'WORKS-OUTBOUND')")

(defvar digest-name ""
  "Name of the digest. (Ex. 'WORKS')")

(defvar digest-moderators-name ""
  "Name of the moderator. (Ex. 'Dave Steiner')")

(defvar digest-moderator-address ""
  "Address of the moderator. (Ex. 'WorkS-Request')")

(defvar digest-issue ""
  "Volume/Issue of this digest. (Ex. 'Volume 7 : Issue 10')")

(defvar digest-date ""
  "Date of this digest.")

(defvar digest-year ""
  "Year of this digest.  Needed to handle end of the year problems.")

;;end of vars from digest.info.

(defconst dash 45
  "Ascii value of a '-' in decimal.")

(defconst asterick 42
  "Ascii value of a '*' in decimal.")

(defconst space 32
  "Ascii value of a ' ' in decimal.")

(defvar digest-info-file-read-in-p nil
  "Non-nil if the digest.info file has be read in.  Used to make sure the
info file is not written out if it wasn't read in for some reason.")

(defvar digest-header-break (make-string digest-max-line-length dash)
  "A string of '-'s to break the headers from the messages.")

(defvar digest-message-break (make-string 30 dash)
  "A string of '-'s to break the messages from each other.")

(defvar digest-topics ""
  "String of subject lines from each message.")

(defvar digest-msgs ""
  "String form of all the digest messages.")

(defvar digest-error-list nil
  "List of all errors in messages of the form (msg# position).")

(defvar digest-after-p nil
  "If non-nil, don't call sendmail directly but have at run sendmail at
the specified time.")

(defvar digest-after-date ""
  "The date to send the digest out in 'at' format.")

(defvar digest-at-program "/usr/bin/at"
  "The default program to use with the after switch.")
 

(defun rmail-digestify (arg)
  "Turn a Rmail file into a single digest to be mailed out.  Leaves
the messages in the Rmail file but sets them deleted.  
If given a positive numeric argument, will ask for list of messages to use.
If given a numeric argument of 0, will ask for a time/date to send out 
the digest.
If given a negative numeric argument, will ask for a list of messages and 
ask for a time/date to send out the digest."
  (interactive "P")
  (let ((digest-msgs "")    ;This vars need to stay defaulted in case of errors
	(digest-topics "")
	(digest-issue "")
	(digest-date "")
	(digest-year "")
	(digest-v-no "")
	(digest-i-no "")
	(digest-after-p (and arg (<= arg 0)))
	(digest-default-directory (if (null digest-default-directory)
				      default-directory
				    digest-default-directory))
	(mail-self-blind digest-mail-self-blind)
	(mail-setup-hook (cond ((null digest-use-mail-setup-hook) nil)
			       ((eq t digest-use-mail-setup-hook)
				(if (boundp 'mail-setup-hook)
				    mail-setup-hook
				  nil))
			       (t digest-use-mail-setup-hook)))
	(messages (if (and arg (/= arg 0))
		      (mail-get-list "Input message list: "
				     rmail-total-messages
				     "No messages to digestify!"
				     t)
		    (let (msgs
			  (n 1))
		      (while (<= n rmail-total-messages)
			(setq msgs (append msgs (list n)))
			(setq n (1+ n)))
		      msgs))))
    (if (stringp messages)
	(message messages)
      (setq digest-error-list nil)  ;start fresh
      (digest-read-info-file)
      (message "Putting together %s Digest, %s." digest-name digest-issue)
      (sit-for 2 t)
      (digest-get-date)
      (if digest-after-p
	  (digest-get-after-date))
      (digest-maybe-increment-volume)
      (if (digest-check-line-length messages)
	  (if (digest-check-char-count messages)
	      (digest-move-messages messages))))))

;;; Another name for the main function
(fset 'digest 'rmail-digestify)

(defun digest-next-error ()
  "Goto the message and position of the next error from digestifying."
  (interactive)
  (let (error)
    (if (null digest-error-list)
	(message "No more errors.")
      (setq error (car digest-error-list))
      (setq digest-error-list (cdr digest-error-list))
      (rmail-show-message (car error))
      (goto-char (marker-position (cdr error))))))

(defun digest-char-count (arg)
  "Print the number of characters in the given messages.  Will request
a list of message numbers to count.  If none given, it will count all
the messages in this RMAIL file.  If given a prefix arg, will also show
the number of chars in each message."
  (interactive "P")
  (let ((messages (mail-get-list "Input message list: "
				 rmail-total-messages
				 "No messages to digestify!" t)))
    ;; Deal with special case of error message.  Just return the whole
    ;; message list instead of an error.
    (if (and (stringp messages) (string= messages "No messages to digestify!"))
	(let ((n 1))
	  (setq messages nil)
	  (while (<= n rmail-total-messages)
	    (setq messages (append messages (list n)))
	    (setq n (1+ n)))))
    (if (stringp messages)
	(message messages)
      (save-excursion
	(save-restriction
	  (widen)
	  (let ((num-msgs (length messages))
		(count 0)
		(i 0)
		indiv)
	    (while messages
	      (let ((beg (rmail-msgbeg (car messages)))
		    (end (rmail-msgend (car messages))))
		(goto-char beg)
		(search-forward "\n*** EOOH ***\n" end t)
		(setq count (+ count (- end (point))))
		(if arg
		    (setq indiv (append indiv (list (cons (car messages)
							  (- end (point)))))))
		(setq messages (cdr messages))))
	    (if arg
		(with-output-to-temp-buffer "*Digest-char-count*"
		  (save-excursion
		    (set-buffer standard-output)
		    (insert "msg#  count | msg#  count | msg#  count | msg#  count | msg#  count\n")
		    (insert "----  ----- | ----  ----- | ----  ----- | ----  ----- | ----  -----\n")
		  (while indiv
		    (princ (car (car indiv)))
		    (indent-to (+ 6 (* i 14)))
		    (princ (cdr (car indiv)))
		    (if (or (= i 4) (null (cdr indiv)))
			(progn
			  (insert "\n")
			  (setq i 0))
		      (indent-to (+ 12 (* i 14)))
		      (insert "| ")
		      (setq i (1+ i)))
		    (setq indiv (cdr indiv))))))
	    (message "There are %d chars in %d messages." count num-msgs)))))))

(defun digest-check-char-count (messages)
  "Check to see that the digest is not over the maximum digest length.
Get subject lines and messages into strings as a side effect."
  (save-excursion
    (save-restriction
      (widen)
      (let ((count 0)
	    (nummes (length messages)))
	(while messages
	  (let (msg
		(beg (rmail-msgbeg (car messages)))
		(end (rmail-msgend (car messages))))
	    ;; get rid of extra \n's at end of msg
	    (goto-char (setq end (1- end)))
	    (while (looking-at "\n")
	      (goto-char (setq end (1- end))))
	    (setq end (+ 2 end))  ; have one \n
	    (goto-char beg)
	    (search-forward "\n*** EOOH ***\n" end t)
	    (setq count (+ count (- end (point))))
	    ;; build a string of messages
	    (setq msg (re-string-replace (buffer-substring (point) end)
					 "^-" "- -"))
	    (setq digest-msgs
		  (concat digest-msgs msg "\n" digest-message-break "\n\n"))
	    ;; get subject lines for topics (get from headers in message
	    ;; part, not in headers part!)
	    (goto-char beg)
	    (search-forward "\n*** EOOH ***\n")
	    (save-restriction
	      (narrow-to-region (point)
				(progn (search-forward "\n\n") (point)))
	      (setq subject (or (mail-fetch-field "Subject" nil t)
				"(blank Subject line)"))
	      (setq subject (re-string-replace subject "\n[ \t]*" " "))
	      (setq digest-topics (concat digest-topics subject "\n")))
	    (setq messages (cdr messages))))
	(if (> count digest-max-characters)
	    (y-or-n-p
	     (format
	      "Total characters (%d) is over the maximum (%d); continue anyway?"
	      count digest-max-characters))
	  (progn
	    (message "Digest is %d characters long in %d messages."
		     count nummes)
	    (sit-for 2 t)
	    t))))))

(defun digest-check-line-length (messages)
  "Check to see that each line in each message is not longer than maximum
line length."
  (let (badp msg place)
    (save-excursion
      (save-restriction
	(widen)
	(while messages
	  (let (pos top
		(beg (rmail-msgbeg (car messages)))
		(end (rmail-msgend (car messages))))
	    (goto-char beg)
	    (search-forward "\n*** EOOH ***\n" end t)
	    (setq top (point))
	    (search-forward "\n\n" end t) ;only check text of message
	    (setq pos (point))
	    (while (< pos end)
	      (search-forward "\n" end t)
	      (if (> (- (1- (point)) pos) digest-max-line-length)
		  (save-restriction
		    (narrow-to-region top end)  ;show just message
		    (if (not
			  (digest-pointer
			    pos
			    (concat "Line "
				    (count-lines top (1- (point)))
				    " is longer than maximum ("
				    digest-max-line-length
				    "); ignore? ")))
			(progn
			  (if (not badp)  ;save position of first error
			      (setq msg (car messages)
				    place (1- (point)))
			    (setq digest-error-list
				  (append digest-error-list
					  (list (cons (car messages)
						      (prog2
							(forward-char -1)
							(point-marker)
							(forward-char 1)))))))
			  (setq badp t)))))
	      (setq pos (point)))
	    (setq messages (cdr messages))))))
    (if badp
	(progn    ;;goto the first problem message
	  (rmail-show-message msg)
	  (goto-char place)
	  (message "Line at cursor is longer than maximum (%d)."
		   digest-max-line-length)))
    (not badp)))

(defun digest-pointer (pos message)
  "Insert a 'pointer' (\"***>\") at POS, ask a y-or-n question using
MESSAGE, and then cleanup.  Return answer to question.  This code
copied from MOMENTARY-STRING-DISPLAY."
  (let ((modified (buffer-modified-p))
	insert-end
	answer)
    (unwind-protect
	(progn
	  (save-excursion
	    (goto-char pos)
	    (let ((buffer-read-only nil)
		  (inverse-video t))
	      (insert-before-markers "***>")
	      (sit-for 0))
	    (setq insert-end (point)))
	  (setq answer (y-or-n-p message)))
      (if insert-end
	  (save-excursion
	    (let ((buffer-read-only nil))
	      (delete-region pos insert-end))))
      (set-buffer-modified-p modified))))

(defun digest-move-messages (messages)
  "Move the messages into a mail buffer."
  (let ((foo messages)
	(stars (make-string (+ 14 (length digest-name)) asterick))
	(subject (concat digest-name " Digest   V"
			 digest-v-no " #" digest-i-no))
	(to (concat (or digest-to-address digest-name)
		    (if (null (string-match
				"@" (or digest-to-address digest-name)))
			(concat "@" (capitalize (system-name)))
		      "")))
	(mail-default-reply-to
	 (concat (or digest-to-address digest-name)
		 (if (null (string-match
			    "@" (or digest-to-address digest-name)))
		     (concat "@" (capitalize (system-name)))
		   ""))))
    ;; remail messages if needed.
    (if digest-remail-address
	(progn
	  (message "Remailing messages...")
	  (while foo
	    (rmail-show-message (car foo))
	    (rmail-resend digest-remail-address)
	    (setq foo (cdr foo)))
	  (message "Remailing messages...done")))
    ;; delete messages if requested
    (if digest-delete-msgs-p
	(progn
	  (message "Deleting messages...")
	  (while messages
	    (rmail-show-message (car messages))
	    (rmail-set-attribute "deleted" t)
	    (setq messages (cdr messages)))
	  (message "Deleting messages...done")))
    ;; setup the mail buffer
    (if (mail nil to subject)
	(progn
	  (goto-char (point-min))
	  (insert "From: " digest-moderators-name " (The Moderator) <"
		  digest-moderator-address
		  (if (null (string-match "@" digest-moderator-address))
		      (concat "@" (capitalize (system-name)))
		    "")
		  ">\n")
	  (insert "Errors-To: "
		  (or digest-errors-to-address digest-moderator-address)
		  (if (null (string-match
			      "@" (or digest-errors-to-address
				      digest-moderator-address)))
		      (concat "@" (capitalize (system-name)))
		    "")
		  "\n")
	  (mail-bcc)
	  (beginning-of-line)
	  (let ((case-fold-search t))
	    (re-search-forward "^BCC: "))
	  (if (not (looking-at "\n")) (progn (end-of-line) (insert ", ")))
	  (insert digest-mailing-list-address)
	  (goto-char (point-max))
	  (insert "\n")
	  (digest-insert-title)
	  (insert "\nToday's Topics:\n" digest-topics "\n"
		  digest-header-break "\n\n")
	  (insert digest-msgs)
	  (insert "End of " digest-name " Digest\n" stars "\n")
	  (search-backward "\nToday's Topics:\n")
	  (forward-line 2)
	  (digest-write-info-file)))))

(defun digest-insert-title ()
  "Insert the title of the digest at the current position in the
current buffer."
  (let* ((date digest-date)
	 (total (- digest-max-line-length (length date)))
	 (first (/ total 2))
	 (second (- total first))
	 fblanks sblanks)
    (setq first (- first (+ 7 (length digest-name))))
    (setq second (- second (length digest-issue)))
    (setq fblanks (make-string first space))
    (setq sblanks (make-string second space))
    (insert digest-name " Digest" fblanks date sblanks digest-issue "\n")))

(defun digest-read-info-file ()
  "Read in the info file."
  (let ((buffer nil)
	(obuf (current-buffer)))
    (unwind-protect
	(progn
	  (setq buffer (generate-new-buffer "*digest-info*"))
	  (buffer-flush-undo buffer)
	  (set-buffer buffer)
	  (insert-file-contents (expand-file-name "digest.info"
						  digest-default-directory))
	  (let ((pos 1))
	    (setq digest-mailing-list-address
		  (buffer-substring pos
				    (1- (progn
					  (search-forward "\n" nil t)
					  (setq pos (point))
					  (point))))
		  digest-name
		  (buffer-substring pos
				    (1- (progn
					  (search-forward "\n" nil t)
					  (setq pos (point))
					  (point))))
		  digest-moderators-name
		  (buffer-substring pos
				    (1- (progn
					  (search-forward "\n" nil t)
					  (setq pos (point))
					  (point))))
		  digest-moderator-address
		  (buffer-substring pos
				    (1- (progn
					  (search-forward "\n" nil t)
					  (setq pos (point))
					  (point))))
		  digest-issue
		  (buffer-substring pos
				    (1- (progn
					  (search-forward "\n" nil t)
					  (setq pos (point))
					  (point))))
		  digest-date
		  (buffer-substring pos
				    (1- (progn
					  (search-forward "\n" nil t)
					  (setq pos (point))
					  (point))))
		  digest-year
		  (buffer-substring pos
				    (1- (progn
					  (search-forward "\n" nil t)
					  (setq pos (point))
					  (point))))
		  digest-info-file-read-in-p t)))
      (if buffer (kill-buffer buffer))
      (set-buffer obuf))))

(defun digest-write-info-file ()
  "Write out the info file."
  (if digest-info-file-read-in-p
      (let ((buffer nil)
	    (obuf (current-buffer)))
	(unwind-protect
	    (progn
	      (setq buffer (generate-new-buffer "*digest-info*"))
	      (buffer-flush-undo buffer)
	      (set-buffer buffer)
	      (insert 
	       digest-mailing-list-address "\n"
	       digest-name "\n"
	       digest-moderators-name "\n"
	       digest-moderator-address "\n"
	       (digest-increment-issue) "\n"
	       digest-date "\n"
	       digest-year "\n")
	      (write-region (point-min) (point-max)
			    (expand-file-name "digest.info"
					      digest-default-directory)
			    nil 'nomsg))
	  (if buffer (kill-buffer buffer))
	  (set-buffer obuf)))
    (message "Info file was not read in, so it won't be written out.")
    (sit-for 2 t)))

(defun digest-get-date ()
  "Set the variable Digest-Date to the date for this digest."
  (let ((ddate (digest-internal-date digest-date))
	(todays-date (digest-internal-date))
	date)
    (setq date (digest-external-date (max ddate todays-date)))
    (if (y-or-n-p (concat "Is " date " the digest's date? "))
	(setq digest-date date)
      (if (> ddate todays-date)
	  (setq date (digest-external-date (digest-addoneday ddate)))
	(setq date (digest-external-date (digest-addoneday todays-date))))
      (if (y-or-n-p (concat "Ok, then is " date " the digest's date? "))
	  (setq digest-date date)
	(setq digest-date (digest-ask-date))))))

(defun digest-ask-date ()
  "Get a valid date from the user (of the form 24 Aug 87)."
  (let ((date (read-string "Input the digest date (eg, '24 Aug 1987'): ")))
    (while (not (digest-valid-date-p date))
      (setq date (read-string "INVALID: Try again (eg, '24 Aug 1987'): ")))
    (digest-external-date (digest-internal-date (concat "Foo, " date)))))

(defun digest-valid-date-p (date)
  "Return t if the date given is valid."
  (if (null (string-match
	     "^[0-9][0-9]? [a-zA-Z][a-zA-Z][a-zA-Z] [0-9][0-9][0-9][0-9]$"
	     date))
      nil
    (let ((day (string-to-int (substring date 0 (string-match " " date))))
	  (month (cdr (assoc (capitalize
			      (substring date
					 (match-end 0)
					 (string-match " " date
						       (match-end 0))))
			     digest-months)))
	  (year (string-to-int (substring date (match-end 0)))))
      (if (or (< year 1900) (> year 1999))
	  nil
	(if (null month)
	    nil
	  (if (digest-valid-day-p day (string-to-int month) year)
	      t
	    nil))))))

(defun digest-valid-day-p (day month year)
  "Return t if the day is a valid day of the given month and year."
  (let ((numdays (nth (1- month) digest-days-in-month)))
    (if (and (= month 2) (leap-year-p year))
	(setq numdays (1+ numdays)))
    (if (and (> day 0) (<= day numdays))
	t
      nil)))

(defun digest-get-after-date ()
  "Get a valid time/day from the user and set it to Digest-After-Date.
Must be in the 'at' program format."
  (let* ((datestring
	   (read-string "Input date to send digest (in `at' format): "))
	 (case-fold-search t)
	 (whitespace "[ \t]*")
	 (time "[0-9][0-9]?[0-9]?[0-9]?")
	 (ampm "\\([apmn]?\\|am\\|pm\\)")
	 (jan "ja.*\\>")
	 (feb "fe.*\\>")
	 (mar "mar.*\\>")
	 (apr "ap.*\\>")
	 (may "may\\>")
	 (jun "jun.?\\>")
	 (jul "jul.?\\>")
	 (aug "au.*\\>")
	 (sep "se.*\\>")
	 (oct "o.*\\>")
	 (nov "n.*\\>")
	 (dec "d.*\\>")
	 (day "\\([1-9]\\|[1-2][0-9]\\|3[0-1]\\)")
	 (mon-day (concat "\\(" jan "\\|" feb "\\|" mar "\\|" apr "\\|" may
			  "\\|" jun "\\|" jul "\\|" aug "\\|" sep "\\|" oct
			  "\\|" nov "\\|" dec "\\)" whitespace day))
	 (mon "mo.*\\>")
	 (tue "tu.*\\>")
	 (wed "w.*\\>")
	 (thu "th.*\\>")
	 (fri "fr.*\\>")
	 (sat "sa.*\\>")
	 (sun "su.*\\>")
	 (week "\\(week\\)?")
	 (daywk (concat "\\(" mon "\\|" tue "\\|" wed "\\|" thu "\\|" fri "\\|"
			sat "\\|" sun "\\)" whitespace week)))
    (while (not (string-match
		  (concat "^" whitespace time ampm whitespace
			  "\\(" mon-day "\\|" daywk "\\)?" whitespace "$")
		  datestring))
      (setq datestring (read-string "Bad syntax, try again: ")))
    (setq digest-after-date datestring)
    (setq old-send-mail-function send-mail-function)
    (setq send-mail-function 'digest-send-it-after)))

;;; based on sendmail.el:sendmail-send-it (v18.49)
(defun digest-send-it-after ()
  "Instead of sending the message via sendmail, use the `at' program to send
it at a later date."
  (let ((errbuf (generate-new-buffer " at errors"))
	(tembuf (generate-new-buffer " at temp"))
	(case-fold-search nil)
	delimline
	(mailbuf (current-buffer)))
    (unwind-protect
	(save-excursion
	  (set-buffer tembuf)
	  (erase-buffer)
	  (insert-buffer-substring mailbuf)
	  (goto-char (point-max))
	  ;; require one newline at the end.
	  (or (= (preceding-char) ?\n)
	      (insert ?\n))
	  ;; Change header-delimiter to be what sendmail expects.
	  (goto-char (point-min))
	  (re-search-forward
	    (concat "^" (regexp-quote mail-header-separator) "\n"))
	  (replace-match "\n")
	  (backward-char 1)
	  (setq delimline (point-marker))
	  (if mail-aliases
	      (expand-mail-aliases (point-min) delimline))
	  (goto-char (point-min))
	  ;; ignore any blank lines in the header
	  (while (and (re-search-forward "\n\n\n*" delimline t)
		      (< (point) delimline))
	    (replace-match "\n"))
	  (let ((case-fold-search t))
	    ;; Find and handle any FCC fields.
	    (goto-char (point-min))
	    (if (re-search-forward "^FCC:" delimline t)
		(mail-do-fcc delimline))
	    ;; If there is a From and no Sender, put it a Sender.
	    (goto-char (point-min))
	    (and (re-search-forward "^From:"  delimline t)
		 (not (save-excursion
			(goto-char (point-min))
			(re-search-forward "^Sender:" delimline t)))
		 (progn
		   (forward-line 1)
		   (insert "Sender: " (user-login-name) "\n")))
	    ;; don't send out a blank subject line
	    (goto-char (point-min))
	    (if (re-search-forward "^Subject:[ \t]*\n" delimline t)
		(replace-match ""))
	    ;; put in sendmail commands since `at' wants a file of commands
	    (goto-char (point-min))
	    (insert (concat (if (boundp 'sendmail-program)
				sendmail-program
			      "/usr/lib/sendmail")
			    " -oi -t"
			    ;; Don't say "from root" if running under su.
			    (and (equal (user-real-login-name) "root")
				 (concat " -f " (user-login-name)))
			    ;; These mean "report errors by mail"
			    ;; and "deliver in background".
			    " -oem -odb << 'END_OF_DIGEST_MARKER'\n"))
	    (goto-char (point-max))
	    (insert "'END_OF_DIGEST_MARKER'\n")
	    (save-excursion
	      (set-buffer errbuf)
	      (erase-buffer)))
	  (apply 'call-process-region
		 (append (list (point-min) (point-max)
			       (if (boundp 'digest-at-program)
				   digest-at-program
				 "/usr/bin/at")
			       nil errbuf nil
			       digest-after-date)))
	  (save-excursion
	    (set-buffer errbuf)
	    (goto-char (point-min))
	    (while (re-search-forward "\n\n* *" nil t)
	      (replace-match "; "))
	    (if (not (zerop (buffer-size)))
		(error "Sending...failed to %s"
		       (buffer-substring (point-min) (point-max))))))
      (kill-buffer tembuf)
      (kill-buffer errbuf)
      ;; reset after switch things
      (setq send-mail-function old-send-mail-function)
      (setq digest-after-date ""))))

(defun digest-increment-issue ()
  "Return the new volume/issue string.  Newyear check has already been done."
  (let* (pos
	 (volume
	  (substring digest-issue
		     (setq pos (string-match "[0-9]" digest-issue))
		     (setq pos (string-match "[^0-9]" digest-issue pos))))
	 (issue
	  (string-to-int
	   (substring digest-issue
		      (setq pos (string-match "[0-9]" digest-issue pos))
		      (setq pos (string-match "[^0-9]" digest-issue pos))))))
    (concat "Volume " volume " : Issue " (int-to-string (1+ issue)))))

(defun digest-maybe-increment-volume ()
  "Increment the volume number if it's a new year."
  (let* (pos
	 (volume
	  (string-to-int
	   (substring digest-issue
		      (setq pos (string-match "[0-9]" digest-issue))
		      (setq pos (string-match "[^0-9]" digest-issue pos)))))
	 (issue
	  (substring digest-issue
		     (setq pos (string-match "[0-9]" digest-issue pos))
		     (setq pos (string-match "[^0-9]" digest-issue pos))))
	 (year (substring digest-date -4)))
    (if (string= year digest-year)
	(setq digest-v-no (int-to-string volume)    ;; do nothing
	      digest-i-no issue)
      (message "Volume number has been incremented to %d due to new year."
	       (1+ volume))
      (sit-for 2 t)
      (setq digest-year year
	    digest-v-no (int-to-string (1+ volume))
	    digest-i-no "1"
	    digest-issue (concat
			  "Volume " (int-to-string (1+ volume))
			  " : Issue 1")))))

;;;
;;; Date twiddling code.
;;;

(defun digest-internal-date (&optional date-string)
  "Convert a digest style date string to the internal digest time format,
eg.  convert \"Tuesday, 16 Jun 1987\" to 870616."
  (let (day month year
	(date (or date-string (digest-style-date))))
    (setq date (substring date (progn (string-match ", " date)
				      (match-end 0))))
    (setq day (substring date 0 (string-match " " date))
          month (cdr (assoc (capitalize
			     (substring date
					(match-end 0)
					(string-match " " date (match-end 0))))
			    digest-months))
          year (substring date (+ 2 (match-end 0)))) ;only last 2 digits
    (if (= (length day) 1)
	(setq day (concat "0" day)))
    (string-to-int (concat year month day))))

(defun digest-external-date (date)
  "Convert the internal format date to a digest style date."
  (let* ((sdate (int-to-string date))
	 (year (concat "19" (substring sdate 0 2)))
	 (month (car (rassoc (substring sdate 2 4) digest-months)))
	 (day (int-to-string (string-to-int (substring sdate 4 6)))))
    (concat (day-of-week date) ", "
	    day " " month " " year)))

(defun digest-addoneday (date)
  "Add one day to the given date (in internal digest format)."
  (let* ((sdate (int-to-string date))
	 (year (string-to-int (substring sdate 0 2)))
	 (month (string-to-int (substring sdate 2 4)))
	 (day (string-to-int (substring sdate 4 6))))
    (if (not (digest-last-day-p day month year))
	(setq day (1+ day))
      (setq day 1)
      (if (/= month 12)
	  (setq month (1+ month))
	(setq month 1)
	(setq year (1+ year))))
    (string-to-int
     (concat (int-to-string year)
	     (if (= (length (int-to-string month)) 1) "0" "")
	     (int-to-string month)
	     (if (= (length (int-to-string day)) 1) "0" "")
	     (int-to-string day)))))

(defun digest-last-day-p (day month year)
  "Return T if this is the last day of the month."
  (let ((numdays (nth (1- month) digest-days-in-month)))
    (if (and (= month 2) (leap-year-p (+ 1900 year)))
	(setq numdays (1+ numdays)))
    (if (= day numdays) t nil)))

(defun digest-days-in-year (year)
  "Return the number of days in year YEAR."
  (if (= 0 (% year 400)) 366
    (if (= 0 (% year 100)) 365
      (if (= 0 (% year 4)) 366
	365))))

(defun leap-year-p (year)
  "Return T if year was a leap year, else return NIL."
  (interactive "nEnter year: ")
  (if (= (digest-days-in-year year) 366) t nil))

(defvar digest-days-in-month '(31 28 31 30 31 30 31 31 30 31 30 31))

(defconst digest-monthdays '(0 31 59 90 120 151 181 212 243 273 304 334 365))

(defvar digest-months '(("Jan" . "01") ("Feb" . "02") ("Mar" . "03")
			("Apr" . "04") ("May" . "05") ("Jun" . "06")
			("Jul" . "07") ("Aug" . "08") ("Sep" . "09")
			("Oct" . "10") ("Nov" . "11") ("Dec" . "12")))

(defvar digest-daysofweek '((0 . "Sunday") (1 . "Monday") (2 . "Tuesday")
			    (3 . "Wednesday") (4 . "Thursday") (5 . "Friday")
			    (6 . "Saturday")))

(defun day-of-week (&optional date)
  "Return the day of the week given the date (in digest
internal format (yymmdd))."
  (interactive "nDate in internal digest format: ")
  (setq date (int-to-string date))
  (cdr (assoc (% (+ (digest-jan1 (substring date 0 2))
		    (1- (digest-day-of-year date)))
		 7)
	      digest-daysofweek)))

(defun digest-jan1 (year)
  "Return the day of the week (0..6) of Jan 1 given the year (only for >1900)."
  (let* ((year (string-to-int (concat "19" year)))
	 (day (+ 4 year (/ (+ year 3) 4))))
    ;if (> year 1800)
    (setq day (- day (/ (- year 1701) 100)))
    (setq day (+ day (/ (- year 1601) 400)))
    ;if (> year 1752)
    (setq day (+ day 3))
    (% day 7)))

(defun digest-day-of-year (date)
  "Return the number of days into the year given internal digest date."
  (let ((day (string-to-int (substring date 4)))
	(month (string-to-int (substring date 2 4)))
	(year (string-to-int (concat "19" (substring date 0 2)))))
    (+ (nth (1- month) digest-monthdays)
       day
       (if (> month 2)
	   (if (leap-year-p year) 1 0)
	 0))))

(defun digest-current-year ()
  "Return the current year as a 4 character string."
  (substring (current-time-string) 20 24))

(defun digest-style-date (&optional date-string)
  "Return the given DATE-STRING (or current date if no argument given) in
digest style, eg. 'Tuesday, 16 Jun 1987'."
  (let* ((date (or date-string (current-time-string)))
	 (day-of-week (substring date 0 3))
	 (day (substring date 8 10))
	 (month (substring date 4 7))
	 (year (substring date 20 24)))
    (if (string= (substring day 0 1) " ")
	(setq day (substring day 1 2)))
    (setq day-of-week
	  (cond ((string= "Sun" day-of-week) "Sunday")
		((string= "Mon" day-of-week) "Monday")
		((string= "Tue" day-of-week) "Tuesday")
		((string= "Wed" day-of-week) "Wednesday")
		((string= "Thu" day-of-week) "Thursday")
		((string= "Fri" day-of-week) "Friday")
		((string= "Sat" day-of-week) "Saturday")))
    (concat day-of-week ", " day " " month " " year)))

;;;
;;; Random useful functions
;;;

(defun re-string-replace (string regexp replace)
  "Given STRING, replace the REGEXP with REPLACE."
  (let (end
	(beg 0)
	(len (length string))
	(return ""))
    (while (and (< beg len)
		(setq end (string-match regexp string beg)))
      (setq return (concat return (substring string beg end) replace))
      (setq beg (match-end 0)))
    (if (>= beg len)
	return
      (concat return (substring string beg)))))

(defun rassoc (elt list)
  "Returns non-nil if ELT is the cdr of an element of LIST.  Comparision
done with equal.
The value is actually the element of LIST whose cdr is ELT."
  (let ((tail list)
	key)
    (while (not (null tail))
      (if (consp (car tail))
	  (if (equal (cdr (car tail)) elt)
	      (setq key (car tail)
		    tail nil)
	    (setq tail (cdr tail)))
	(setq tail (cdr tail))))
    key))
==================================================site-init.el additions:
;;;
;;;used by the remail command in rmail.el
(defconst mail-self-blind-on-resend mail-self-blind "\
*Non-nil means insert ReSent-BCC to self in messages to be sent.
This is done with the message is initialized, so that you can remove
or alter the ReSent-BCC field to override the default.
See also mail-self-blind.")

;;;
;;; Variables need for lisp/digest.el

(defvar digest-max-characters 17000
  "*Maximum number of characters allowed in a digest (a soft limit).")

(defvar digest-max-line-length 75
  "*Maximum number of characters per line allowed (a soft limit).")

(defvar digest-remail-address nil
  "*If non-nil, remail each message to this address.  NOTE: if non-nil,
it should be a string!")

(defvar digest-default-directory nil
  "*If nil, will use the current directory as the default directory,
otherwise will use this variable.")

(defvar digest-mail-self-blind nil
  "*Non-nil means insert BCC to self in digest message.  Used to override
mail-self-blind variable.")

(defvar digest-delete-msgs-p t
  "*If non-nil, set each message deleted that is used in making the digest.")

(defvar digest-use-mail-setup-hook t
  "*If nil, don't use the mail-setup-hook, if t, use it, and if not t or
nil, will use that as the value for mail-setup-hook.")

(defvar digest-errors-to-address nil
  "*If non-nil, use this address for the Errors-To: field, instead of the
digest-moderator-address.  NOTE: if non-nil, it should be a string!")

(defvar digest-to-address nil
  "*If non-nil, use this address for the To: and Reply-To: fields, instead
of the digest-name.  NOTE: if non-nil, it should be a string!")
==================================================info/digest
-*- Text -*-
Info file for the digest program (lisp/digest.el), written by Dave Steiner
(steiner@topaz.rutgers.edu).

This file documents the GNU Emacs digest program.

Copyright (C) 1987, 1988 David K. Steiner
^_
File: digest		Node: Top		Up: (DIR)

This digest program is built around GNUEmacs rmail.  I've added
several commands to the rmail mode to make things easier on the
moderator.  There is now a remail command (bound to `M-r') and a
"output multiple messages" command (bound to `M-o') which will prompt
you for the message number(s) to move.  The digest program is bound to
`M-d' or can be called via `M-x Digest' or `M-x Rmail-Digestify'.

* Menu:

* Errors::	  What to do about errors (eg, lines to long, etc).
* Info File::	  What belongs in the digest.info file.
* Addresses::	  What mail addresses/aliases you should have.
* Mailing List::  The format for the mailing list.
* Variables::	  What variables you can change.

Before you run the digest program you should edit all messages.
Suggestions are to at least run `M-x Untabify', make sure all lines
are shorter than 75 characters, remove unneeded headers (the digest
program doesn't remove any headers), and any other editing you want to
do.  Remember that the editing command in rmail is `w'.

If the digest program is called without arguments, it will take all
the messages in the current RMAIL file and make a digest out of them.
If you give a positive numeric argument (eg, `M-1 M-d') the program
will ask for a list of messages to use, and will use only those
messages, in the order you gave (that way you don't have to move
messages to another file in the correct order).  If you give a numeric
argument of 0, the program will ask for a time/date to send out the
digest.  This uses the `at' program to call sendmail sometime in the
future (eg, this is used if you are around only during the day but
want to send the digests out during non-peak nighttime hours; or you
can use this to space out a number of digests, over a couple of days,
>From one session).  If you give a negative numeric argument to the
program, it will do both of the these; ask for a list of messages and
ask for a time and date.

While the digest program is running you will see the following
messages in the minibuffer (examples for digest called FuBar):

`Loading digest...'
`Putting together FuBar Digest, Volume 7 : Issue 27.'
`Is Tuesday, Sep 29, 1987 the digest's date? (y or n) '

At this point you should answer the question; the program tries two
guesses for the date of the digest and then will give up and ask you
outright for the date.  Most of the time, one of the first two guesses
will be correct.

Assuming there were no errors (*Note Errors::), you will then see, for
example

`Digest is 15345 characters long.'

and you will be put into a *mail* buffer with the digest message.

The cursor will be at the first topic line to be edited.  The topic
lines are just the unedited subject lines of the messages.  Normally
these are edited and indented somewhat.  Make sure you leave a blank
line between the last topic line and the line of dashes; this is
needed by various undigestifers.  If there were two subject lines from
a single message, they will be put on the on the same topic line
separated by a comma.  If there was no subject line, there will be a
blank topic line.  After editing these, just type `C-c C-c' to send
the digest.

Note that the way we send the digest out is to have the "to" field be
the digest address (so that any response to that address will go to
the correct place) and the "bcc" field be the actual outbound address.
This way subscribers can never find out the outbound address and
respond directly to it.  You will get a copy of the digest in your
digest mailbox though.

The digest.info file (*Note Info File::) will be automatically
updated unless an error occurs.

Send bug reports/suggestions to Dave Steiner (Steiner@topaz.rutgers.edu;
...!rutgers!topaz.rutgers.edu!steiner).

^_
File: digest,	    Node: Errors,	Up: Top,	Next: Info File

If a line is longer than the maximum line length or the number of
characters in the digest is longer than the maximum allowed, the
program will complain.

In the case when a digest is longer than the maximum characters
allowed, it will ask if you want to ignore this and actually put out a
digest that is longer than the maximum.  If you say no, it will abort
and put you back into the rmail file.  There you can either edit some
more, run the program again with fewer messages, or just go home.  If
you say yes, it will continue making the digest and put you in the
*mail* buffer.  Do not do this lightly!!  A lot of mailers can't
handle extremely large mail messages and this maximum was set so that
you will have a minimum of mailer problems.


In the case where a line is longer than the maximum, the faulty line
with be prefixed with the string "***>" and highlighted.  You will be
asked something like the following:

`Line 7 is longer than maximum (75); ignore? (y or n) '

If you type `y', the program will continue and will not consider that
line an error.  If you type `n', the program will consider that line
an error and abort (after going through the rest of the digest looking
for long lines so you can correct them all in one pass).  Only lines
that you didn't ignore will be considered as errors.  After aborting,
the cursor will be at the end of the line of the first error.  After
correcting it, you can type `C-x `' (or `M-x digest-next-error') to
get to the next error (it will say "No more errors." when finished).
Then you will have to run the digest program again.  At this point, it
will not remember which long lines were ignored the previous time.
Remember that a lot of terminals can't handle longer lines than this
maximum, so don't ignore this lightly.  I suggest only to ignore long
lines in signatures and uneditable messages (like code, etc).

^_
File: digest,  Node: Info File,  Up: Top,  Previous: Errors,  Next: Addresses

There needs to be a file called digest.info in the directory where you
do your digestifying.  This file should contain the following
information on separate lines: mailing list address, digest name,
moderator's name, moderator's address, volume/issue number, date of
last digest, and the current year.  An example of this, for a digest
called FuBar, would look like:

FuBar-outbound			<-- mailing list address
FuBar				<-- digest name
Dave Steiner			<-- moderator's name
FuBar-Request			<-- moderator's address
Volume 7 : Issue 27		<-- volume/issue number
Thursday, 3 Sep 1987		<-- date of last digest
1987				<-- current year (used to update volume#)

^_
File: digest,  Node: Addresses,  Up: Top,  Prev: Info File,  Next: Mailing List

The following addresses (ie, aliases in /usr/lib/aliases) will be
needed for the digest to work (don't forget to replace "FuBar" with
*your* digest name!):

FuBar, 
FuBar-outbound, 
owner-FuBar-outbound, and
FuBar-request.  

FuBar-outbound should point to the file which is the mailing list (ie,
use the :include: feature of sendmail) and owner-FuBar-outbound should
be the same as FuBar-request.  FuBar and FuBar-request can point to
anywhere you want; the same file, separate files, etc.  Whatever works
best for you.

^_
File: digest,  Node: Mailing List,  Up: Top,  Prev: Addresses,  Next: Variables

The mailing list is a normal sendmail mailing list.  That means that
the file contains any number of lines which contain any number of
addresses separated by commas.  Comments are between parens (just like
normal mail messages [eg, "From: Steiner@topaz.rutgers.edu (Dave
Steiner)"]).  You can use parens to comment out the whole line.  You
don't have to have a comma at the end of the line, but it won't
complain if you do.

^_
File: digest, Node: Variables, Up: Top, Prev: Mailing List, Next: Useful Hacks

The following variables are used by the digest program.  The defaults
are shown but if you feel you must change them, reset them in your
.emacs file.

digest-max-characters (default: 17000)
   Maximum number of characters allowed in a digest (a soft limit; the
   program will ask if you want to override).

digest-max-line-length (default: 75)
   Maximum number of characters per line allowed (a soft limit; the
   program will ask if you want to override on a line by line basis).

digest-remail-address (default: nil)
   If non-nil, remail each individual message to this address.  Used
   for mailing individual messages to the usenet.  NOTE: if non-nil,
   it should be a string!

digest-default-directory (default: nil)
   If nil, will use the current directory as the default directory,
   otherwise will use this variable.  See the documentation for the
   variable default-directory for more information.

digest-mail-self-blind (default: nil)
   Non-nil means insert BCC to self in digest message.  Used to override
   mail-self-blind variable.

digest-delete-msgs-p (default: t)
   If non-nil, set each message deleted that is used in making the
   digest.  Will not actually do the expunge.

digest-use-mail-setup-hook (default: t)
   If nil, don't use the mail-setup-hook; if t, use it; and if not t or
   nil, will use that as the value for mail-setup-hook.

digest-errors-to-address (default: nil)
   If non-nil, use this address for the Errors-To: field, instead of the
   digest-moderator-address.  NOTE: if non-nil, it should be a string!

digest-to-address (default: nil)
   If non-nil, use this address for the To: and Reply-To: fields, instead
   of the digest-name.  NOTE: if non-nil, it should be a string!

^_
File: digest,	Node: Useful Hacks,	Up: Top,	Previous: Variables

;;; aramis is a special case.  If emacs is started up in "~/works", 
;;; make reply-to and bcc be works-request and not steiner
(if (string= (system-name) "aramis.rutgers.edu")
    (if (string= default-directory (expand-file-name "~/works/"))
	(progn
	  (setq mail-self-blind nil)   ;no bcc to steiner
	  (add-hook 'mail-setup-hook 'my-digest-bcc) ;setup bcc correctly
	  (add-hook 'mail-mode-hook
		    '(lambda () (setq default-directory
				      (expand-file-name "~/works/"))))
	  (add-hook 'mail-mode-hook
		    '(lambda ()
		       (define-key mail-mode-map "\C-cw" 'works-signature)))
	  (add-hook 'rmail-mode-hook
		    '(lambda () (setq rmail-last-rmail-file
				      (expand-file-name "~/works/req"))))
	  (setq rmail-dont-reply-to-names
		(concat rmail-dont-reply-to-names "\\|works-request"))
	  (setq mail-default-reply-to "WorkS-Request@Aramis.Rutgers.Edu"))))

;;; don't use this hook when making a digest!
(setq digest-use-mail-setup-hook nil)

;;; Get the correct .signature file.
(defun works-signature ()
  "Sign letter with contents of ~/works/.signature file."
  (interactive)
  (save-excursion
    (goto-char (point-max))
    (insert-file-contents (expand-file-name "~/works/.signature"))))

;;; set the BCC to WorkS-Request when dealing with digests.
(defun my-digest-bcc ()
  "Setup the BCC to be WorkS-Request.  Also add in a Errors-to: field."
  (save-excursion
    (mail-bcc)
    (beginning-of-line)
    (let ((case-fold-search t))
      (re-search-forward "^BCC: "))
    (if (not (looking-at "\n")) (progn (end-of-line) (insert ", ")))
    (insert "Works-Request@Aramis.Rutgers.Edu")
    ;; now add in an Errors-to: field
    (re-search-forward "^[^ \t]" nil t)
    (beginning-of-line)
    (insert "Errors-to: Works-Request@Aramis.Rutgers.Edu\n")))

;;; explain add-hook.

==================================================patches:
diff -c mail-utils.el.ORIG mail-utils.el
*** mail-utils.el.ORIG	Tue Nov  8 17:04:30 1988
--- mail-utils.el	Mon Oct 31 17:52:00 1988
***************
*** 177,179
  		    "\\|"
  		    (substring labels (match-end 0))))))
    labels)

--- 177,309 -----
  		    "\\|"
  		    (substring labels (match-end 0))))))
    labels)
+ 
+ (defun mail-get-list (prompt maximum default-msg &optional errmsgp)
+   "Return a list of message numbers.  PROMPT will be printed before
+ reading in the numbers.  MAXIMUM is the maximum number that will be
+ allowed.
+ If DEFAULT-MSG is a string, it's an error string to be returned when
+ there are no messages; otherwise it's a default message number.
+ If list is invalid for some , return nil if optional ERRMSGP is nil;
+ if ERRMSGP is t, returns the error message string."
+   (let ((msg-list (read-string prompt)))
+     (if (string= msg-list "")
+ 	(if (stringp default-msg)
+ 	    default-msg			;error string
+ 	  (list default-msg))		;default msg number
+       (let* ((whitespace "[ \t]*")
+ 	     (number "[1-9][0-9]*")
+ 	     (range (concat number whitespace ":" whitespace number)))
+ 	(while (not (string-match
+ 		     (concat "^" whitespace
+ 			     "\\(" number "\\|" range "\\)"
+ 			     "\\("
+ 			           whitespace "," whitespace
+ 				   "\\(" number "\\|" range "\\)"
+ 			     "\\)*" whitespace "$")
+ 		     msg-list))
+ 	  (setq msg-list (read-string "Invalid number list, try again:")))
+ 	(mail-convert-number-list msg-list  maximum errmsgp)))))
+ 
+ (defun mail-convert-number-list (msg-list maximum errmsgp)
+   "Convert a string of message numbers and ranges to a list of numbers
+ without ranges.  Maximum is the maximum number that can be in the
+ msg-list.  If errmsgp is t, if there is an error, return the error
+ string.  If errmsgp is nil, just print out the error message and
+ return nil if there is an error."
+   (let ((num-list ())
+ 	bad
+ 	temp)
+     ;; remove whitespace
+     (setq msg-list (substring msg-list (string-match "[^ \t]" msg-list)))
+     ;; get first number and append to list
+     (let ((pos (string-match "[^0-9]\\|$" msg-list)))
+       (setq temp (string-to-int (substring msg-list 0 pos)))
+       (if (> temp maximum)
+ 	  (if errmsgp
+ 	      (setq bad "Number out of range.")
+ 	    (progn (setq bad t) (message "Number out of range."))))
+       (setq num-list (append num-list (list temp)))
+       (setq msg-list (substring msg-list pos)))
+     ;; if in a range, deal with it (skiping whitespace)
+     (if (> (string-match "$" msg-list) 0)
+ 	(let ((colonp (string-match "[^ \t]\\|$" msg-list)))
+ 	  (if (string= ":" (substring msg-list colonp (1+ colonp)))
+ 	      (progn
+ 		(setq msg-list (substring msg-list (1+ colonp)))
+ 		;; remove whitespace (can't be at end)
+ 		(setq msg-list (substring msg-list
+ 					  (string-match "[^ \t]" msg-list)))
+ 		;; get next number and append range of numbers to list
+ 		(let ((pos (string-match "[^0-9]\\|$" msg-list))
+ 		      temp2
+ 		      tempi)
+ 		  (setq temp2 (string-to-int (substring msg-list 0 pos)))
+ 		  (if (> temp2 maximum)
+ 		      (if errmsgp
+ 			  (setq bad "Number out of range.")
+ 			(progn (setq bad t) (message "Number out of range."))))
+  		  (setq tempi (1+ temp))
+ 		  (while (<= tempi temp2)
+ 		    (setq num-list (append num-list (list tempi)))
+ 		    (setq tempi (1+ tempi)))
+ 		  (setq msg-list (substring msg-list pos)))))))
+     (while (> (string-match "$" msg-list) 0) ;not at end of string
+       ;; remove whitespace if not at end
+       (if (> (string-match "$" msg-list) 0)
+ 	  (setq msg-list (substring msg-list
+ 				    (string-match "[^ \t]\\|$" msg-list))))
+       ;; deal with a "," if not at end
+       (if (> (string-match "$" msg-list) 0)
+ 	  (progn
+ 	    (if (not (string= "," (substring msg-list 0 1)))
+ 		(if errmsgp
+ 		    (setq bad (concat "Should have found a ',' but found a "
+ 				      (substring msg-list 0 1) "."))
+ 		  (progn (setq bad t)
+ 			 (message "Should have found a ',' but found a %s."
+ 				  (substring msg-list 0 1))))
+ 	      (progn   ; it's a ","
+ 		;; remove ","
+ 		(setq msg-list (substring msg-list 1))
+ 		;; remove whitespace (can't be at end)
+ 		(setq msg-list
+ 		      (substring msg-list
+ 				 (string-match "[^ \t]" msg-list)))
+ 		;; get next number and append to list
+ 		(let ((pos (string-match "[^0-9]\\|$" msg-list)))
+ 		  (setq temp (string-to-int (substring msg-list 0 pos)))
+ 		  (if (> temp maximum)
+ 		      (if errmsgp
+ 			  (setq bad "Number out of range.")
+ 			(progn (setq bad t) (message "Number out of range."))))
+ 		  (setq num-list (append num-list (list temp)))
+ 		  (setq msg-list (substring msg-list pos)))))
+ 	    ;; if in a range, deal with it (skiping whitespace)
+ 	    (if (> (string-match "$" msg-list) 0)
+ 		(let ((colonp (string-match "[^ \t]\\|$" msg-list)))
+ 		  (if (string= ":" (substring msg-list colonp (1+ colonp)))
+ 		      (progn
+ 			(setq msg-list (substring msg-list (1+ colonp)))
+ 			;; remove whitespace (can't be at end)
+ 			(setq msg-list
+ 			      (substring msg-list
+ 					 (string-match "[^ \t]" msg-list)))
+ 			;; get next number and append range of numbers to list
+ 			(let ((pos (string-match "[^0-9]\\|$" msg-list))
+ 			      temp2
+ 			      tempi)
+ 			  (setq temp2
+ 				(string-to-int (substring msg-list 0 pos)))
+ 			  (if (> temp2 maximum)
+ 			      (if errmsgp
+ 				  (setq bad "Number out of range.")
+ 				(progn (setq bad t)
+ 				       (message "Number out of range."))))
+ 			  (setq tempi (1+ temp))
+ 			  (while (<= tempi temp2)
+ 			    (setq num-list (append num-list (list tempi)))
+ 			    (setq tempi (1+ tempi)))
+ 			  (setq msg-list (substring msg-list pos))))))))))
+     (if (not bad) num-list
+       (if errmsgp bad nil))))
diff -c mailalias.el.ORIG mailalias.el
*** mailalias.el.ORIG	Fri Mar 25 00:28:11 1988
--- mailalias.el	Thu Mar 24 19:03:16 1988
***************
*** 23,29
  ;; only if some mail aliases are defined.
  (defun expand-mail-aliases (beg end)
    "Expand all mail aliases in suitable header fields found between BEG and END.
! Suitable header fields are To, Cc and Bcc."
    (if (eq mail-aliases t)
        (progn (setq mail-aliases nil) (build-mail-aliases)))
    (goto-char beg)

--- 23,29 -----
  ;; only if some mail aliases are defined.
  (defun expand-mail-aliases (beg end)
    "Expand all mail aliases in suitable header fields found between BEG and END.
! Suitable header fields are To, Cc, Bcc and ReSent-To."
    (if (eq mail-aliases t)
        (progn (setq mail-aliases nil) (build-mail-aliases)))
    (goto-char beg)
***************
*** 30,36
    (setq end (set-marker (make-marker) end))
    (let ((case-fold-search nil))
      (while (let ((case-fold-search t))
! 	     (re-search-forward "^\\(to\\|cc\\|bcc\\):" end t))
        (skip-chars-forward " \t")
        (let ((beg1 (point))
  	    end1 pos epos seplen

--- 30,36 -----
    (setq end (set-marker (make-marker) end))
    (let ((case-fold-search nil))
      (while (let ((case-fold-search t))
! 	     (re-search-forward "^\\(to\\|cc\\|bcc\\|resent-to\\):" end t))
        (skip-chars-forward " \t")
        (let ((beg1 (point))
  	    end1 pos epos seplen
***************
*** 104,110
  	    (end-of-line)
  	    (if (= (preceding-char) ?\\)
  		(progn (delete-char -1) (delete-char 1) (insert ?\ ))
! 	        (forward-char 1)))
  	  (goto-char (point-min))
  	  (while (re-search-forward "^a\\(lias\\|\\)[ \t]+" nil t)
  	    (re-search-forward "[^ \t]+")

--- 104,112 -----
  	    (end-of-line)
  	    (if (= (preceding-char) ?\\)
  		(progn (delete-char -1) (delete-char 1) (insert ?\ ))
! 	      (if (not (eobp)) (forward-char 1)
! 		(message "%s doesn't end in a newline.  Please fix." file)
! 		(insert ?\n))))
  	  (goto-char (point-min))
  	  (while (re-search-forward "^a\\(lias\\|\\)[ \t]+" nil t)
  	    (re-search-forward "[^ \t]+")
diff -c rmail.el.ORIG rmail.el
*** rmail.el.ORIG	Wed May 25 23:52:52 1988
--- rmail.el	Mon Nov  7 22:31:31 1988
***************
*** 200,205
    (define-key rmail-mode-map "l" 'rmail-summary-by-labels)
    (define-key rmail-mode-map "\e\C-l" 'rmail-summary-by-labels)
    (define-key rmail-mode-map "\e\C-r" 'rmail-summary-by-recipients)
    (define-key rmail-mode-map "t" 'rmail-toggle-header)
    (define-key rmail-mode-map "m" 'rmail-mail)
    (define-key rmail-mode-map "r" 'rmail-reply)

--- 203,212 -----
    (define-key rmail-mode-map "l" 'rmail-summary-by-labels)
    (define-key rmail-mode-map "\e\C-l" 'rmail-summary-by-labels)
    (define-key rmail-mode-map "\e\C-r" 'rmail-summary-by-recipients)
+   (define-key rmail-mode-map "\e\C-f" 'rmail-summary-by-senders)
+   (define-key rmail-mode-map "\e\C-s" 'rmail-summary-by-subject)
+   (define-key rmail-mode-map "\e\C-d" 'rmail-summary-by-date)
+   (define-key rmail-mode-map "\e\C-t" 'rmail-summary-by-to)
    (define-key rmail-mode-map "t" 'rmail-toggle-header)
    (define-key rmail-mode-map "m" 'rmail-mail)
    (define-key rmail-mode-map "r" 'rmail-reply-just-sender)
***************
*** 205,210
    (define-key rmail-mode-map "r" 'rmail-reply)
    (define-key rmail-mode-map "c" 'rmail-continue)
    (define-key rmail-mode-map "f" 'rmail-forward)
    (define-key rmail-mode-map "\es" 'rmail-search)
    (define-key rmail-mode-map "j" 'rmail-show-message)
    (define-key rmail-mode-map "o" 'rmail-output-to-rmail-file)

--- 212,218 -----
    (define-key rmail-mode-map "r" 'rmail-reply-just-sender)
    (define-key rmail-mode-map "c" 'rmail-continue)
    (define-key rmail-mode-map "f" 'rmail-forward)
+   (define-key rmail-mode-map "\er" 'rmail-resend)
    (define-key rmail-mode-map "\es" 'rmail-search)
    (define-key rmail-mode-map "j" 'rmail-show-message)
    (define-key rmail-mode-map "o" 'rmail-output-to-rmail-file)
***************
*** 214,220
    (define-key rmail-mode-map ">" 'rmail-last-message)
    (define-key rmail-mode-map "?" 'describe-mode)
    (define-key rmail-mode-map "w" 'rmail-edit-current-message)
!   (define-key rmail-mode-map "\C-d" 'rmail-delete-backward))
  
  ;; Rmail mode is suitable only for specially formatted data.
  (put 'rmail-mode 'mode-class 'special)

--- 222,232 -----
    (define-key rmail-mode-map ">" 'rmail-last-message)
    (define-key rmail-mode-map "?" 'describe-mode)
    (define-key rmail-mode-map "w" 'rmail-edit-current-message)
!   (define-key rmail-mode-map "\C-d" 'rmail-delete-backward)
!   (define-key rmail-mode-map "\eo" 'rmail-multiple-output-to-rmail-file)
!   (define-key rmail-mode-map "\C-x\C-d" 'rmail-multiple-delete-forward)
!   (define-key rmail-mode-map "\ed" 'rmail-digestify)
!   (define-key rmail-mode-map "\C-x`" 'digest-next-error))
  
  ;; Rmail mode is suitable only for specially formatted data.
  (put 'rmail-mode 'mode-class 'special)
***************
*** 238,243
  C-d	Delete this message, move to previous nondeleted.
  u	Undelete message.  Tries current message, then earlier messages
  	till a deleted message is found.
  e	Expunge deleted messages.
  s	Expunge and save the file.
  q       Quit Rmail: expunge, save, then switch to another buffer.

--- 250,257 -----
  C-d	Delete this message, move to previous nondeleted.
  u	Undelete message.  Tries current message, then earlier messages
  	till a deleted message is found.
+ C-x C-d	Delete multiple messages, move to next non-deleted (from the
+ 	 last one delted).
  e	Expunge deleted messages.
  s	Expunge and save the file.
  q       Quit Rmail: expunge, save, then switch to another buffer.
***************
*** 249,254
  f	Forward this message to another user.
  o       Output this message to an Rmail file (append it).
  C-o	Output this message to a Unix-format mail file (append it).
  i	Input Rmail file.  Run Rmail on that file.
  a	Add label to message.  It will be displayed in the mode line.
  k	Kill label.  Remove a label from current message.

--- 263,269 -----
  f	Forward this message to another user.
  o       Output this message to an Rmail file (append it).
  C-o	Output this message to a Unix-format mail file (append it).
+ M-o	Output multiple messages to an Rmail file (append them).
  i	Input Rmail file.  Run Rmail on that file.
  a	Add label to message.  It will be displayed in the mode line.
  k	Kill label.  Remove a label from current message.
***************
*** 254,260
  k	Kill label.  Remove a label from current message.
  C-M-n   Move to Next message with specified label
            (label defaults to last one specified).
!           Standard labels: filed, unseen, answered, forwarded, deleted.
            Any other label is present only if you add it with `a'.
  C-M-p   Move to Previous message with specified label
  C-M-h	Show headers buffer, with a one line summary of each message.

--- 269,275 -----
  k	Kill label.  Remove a label from current message.
  C-M-n   Move to Next message with specified label
            (label defaults to last one specified).
!           Standard labels: filed, unseen, answered, forwarded, resent, deleted.
            Any other label is present only if you add it with `a'.
  C-M-p   Move to Previous message with specified label
  C-M-h	Show headers buffer, with a one line summary of each message.
***************
*** 260,265
  C-M-h	Show headers buffer, with a one line summary of each message.
  C-M-l	Like h only just messages with particular label(s) are summarized.
  C-M-r   Like h only just messages with particular recipient(s) are summarized.
  t	Toggle header, show Rmail header if unformatted or vice versa.
  w	Edit the current message.  C-c C-c to return to Rmail."
    (interactive)

--- 275,284 -----
  C-M-h	Show headers buffer, with a one line summary of each message.
  C-M-l	Like h only just messages with particular label(s) are summarized.
  C-M-r   Like h only just messages with particular recipient(s) are summarized.
+ C-M-f   Like h only just messages with particular sender(s) are summarized.
+ C-M-s   Like h only just messages with particular subject(s) are summarized.
+ C-M-d   Like h only just messages with particular date(s) are summarized.
+ C-M-t   Like h only just messages with particular to(s) are summarized.
  t	Toggle header, show Rmail header if unformatted or vice versa.
  M-d	Digestify messages.
  w	Edit the current message.  C-c C-c to return to Rmail."
***************
*** 261,266
  C-M-l	Like h only just messages with particular label(s) are summarized.
  C-M-r   Like h only just messages with particular recipient(s) are summarized.
  t	Toggle header, show Rmail header if unformatted or vice versa.
  w	Edit the current message.  C-c C-c to return to Rmail."
    (interactive)
    (kill-all-local-variables)

--- 280,286 -----
  C-M-d   Like h only just messages with particular date(s) are summarized.
  C-M-t   Like h only just messages with particular to(s) are summarized.
  t	Toggle header, show Rmail header if unformatted or vice versa.
+ M-d	Digestify messages.
  w	Edit the current message.  C-c C-c to return to Rmail."
    (interactive)
    (kill-all-local-variables)
***************
*** 1075,1080
    (interactive)
    (rmail-delete-forward t))
  
  (defun rmail-expunge ()
    "Actually erase all deleted messages in the file."
    (interactive)

--- 1106,1126 -----
    (interactive)
    (rmail-delete-forward t))
  
+ (defun rmail-multiple-delete-forward (&optional msg-list)
+   "Delete the list of message and move to the next nondeleted one (from
+ the last message deleted).
+ Deleted messages stay in the file until the \\[rmail-expunge] command is given.
+ The optional MSG-LIST is a list of message numbers to move which defaults to
+ the current message.  A list of message number is either numbers of ranges
+ of numbers separated by commas.  Ranges are two numbers separated by a colon."
+   (interactive (list (mail-get-list "Input message list:"
+ 				    rmail-total-messages
+ 				    rmail-current-message nil)))
+   (while msg-list
+     (rmail-show-message (car msg-list))
+     (rmail-delete-forward)
+     (setq msg-list (cdr msg-list))))
+ 
  (defun rmail-expunge ()
    "Actually erase all deleted messages in the file."
    (interactive)
***************
*** 1276,1281
  	  (goto-char (point-max))
  	  (forward-line 1)
  	  (insert-buffer forward-buffer)))))
  
  ;;;; *** Rmail Specify Inbox Files ***
  

--- 1334,1387 -----
  	  (goto-char (point-max))
  	  (forward-line 1)
  	  (insert-buffer forward-buffer)))))
+ 
+ (defun rmail-resend (addresses)
+   "Remail the current message to other users."
+   (interactive "sEnter addresses to remail to: ")
+   ;;>> this gets set even if we abort.  Can't do anything about it, though.
+   (rmail-set-attribute "resent" t)
+   (let ((resend-buffer (current-buffer))
+ 	to subject in-reply-to cc resent-to)
+     (save-excursion
+       (save-restriction
+ 	(widen)
+ 	(goto-char (rmail-msgbeg rmail-current-message))
+ 	(forward-line 1)
+ 	(if (= (following-char) ?0)
+ 	    (narrow-to-region
+ 	     (progn (forward-line 2)
+ 		    (point))
+ 	     (progn (search-forward "\n\n" (rmail-msgend rmail-current-message)
+ 				    'move)
+ 		    (point)))
+ 	  (narrow-to-region (point)
+ 			    (progn (search-forward "\n*** EOOH ***\n")
+ 				   (beginning-of-line) (point))))
+ 	(setq to (or (mail-fetch-field "To") nil)
+ 	      subject (or (mail-fetch-field "Subject") nil)
+ 	      in-reply-to (or (mail-fetch-field "In-Reply-To") nil)
+ 	      cc (or (mail-fetch-field "CC") nil)
+ 	      resent-to (list addresses
+ 			      (or (mail-fetch-field "From") nil)
+ 			      (or (mail-fetch-field "Date") nil)
+ 			      (or (mail-fetch-field "Message-ID") nil)))))
+     ;; If only one window, use it for the mail buffer.
+     ;; Otherwise, use another window for the mail buffer
+     ;; so that the Rmail buffer remains visible
+     ;; and sending the mail will get back to it.
+     (if (if (one-window-p t)
+ 	    (mail nil to subject in-reply-to cc nil resent-to)
+ 	  (mail-other-window nil to subject in-reply-to cc nil resent-to))
+ 	(progn
+ 	  (goto-char (point-max))
+ 	  (forward-line 1)
+ 	  (let ((top (point)))
+ 	    (insert-buffer resend-buffer)
+ 	    (goto-char top)
+ 	    (if (search-forward "\n\n" (point-max) t)
+ 		(delete-region top (point))))
+ 	  (mail-send-and-exit nil)))))
+ 
  
  ;;;; *** Rmail Specify Inbox Files ***
  
***************
*** 1331,1336
   only look in the To and From fields.
  RECIPIENTS is a string of names separated by commas."
    t)
  
  ;;;; *** Rmail output messages to files ***
  

--- 1437,1465 -----
   only look in the To and From fields.
  RECIPIENTS is a string of names separated by commas."
    t)
+ 
+ (autoload 'rmail-summary-by-senders "rmailsum"
+   "Display a summary of all messages with the given SENDERS.
+ looks at the From: field.  
+ SENDERS is a string of names separated by commas."
+   t)
+ 
+ (autoload 'rmail-summary-by-subject "rmailsum"
+   "Display a summary of all messages with the given SUBJECT.
+ looks at the Subject: field.  
+ SUBJECT is a string of names separated by commas."
+   t)
+ 
+ (autoload 'rmail-summary-by-date "rmailsum"
+   "Display a summary of all messages with the given DATE.
+ Looks at the Date: field.  
+ DATE is a string of names separated by commas."
+   t)
+ 
+ (autoload 'rmail-summary-by-to "rmailsum"
+   "Display a summary of all messages with the given TO.
+ Looks at the To: field.  TO is a string of names separated by commas."
+   t)
  
  ;;;; *** Rmail output messages to files ***
  
***************
*** 1341,1346
  buffer visiting that file."
    t)
  
  (autoload 'rmail-output "rmailout"
    "Append this message to Unix mail file named FILE-NAME."
    t)

--- 1470,1485 -----
  buffer visiting that file."
    t)
  
+ (autoload 'rmail-multiple-output-to-rmail-file "rmailout"
+   "Append and delete the list of messages (defaulting to the current one) to
+ an Rmail file named FILE-NAME.  If the file does not exist, ask if it should
+ be created.  If file is being visited, the message is appended to the Emacs
+ buffer visiting that file.  The optional MSG-LIST is a list of message numbers
+ to move which defaults to the current message.  A list of message numbers is
+ either numbers or ranges of numbers separated by commas.  Ranges are two
+ numbers separated by a colon."
+   t)
+ 
  (autoload 'rmail-output "rmailout"
    "Append this message to Unix mail file named FILE-NAME."
    t)
***************
*** 1350,1353
  (autoload 'undigestify-rmail-message "undigest"
    "Break up a digest message into its constituent messages.
  Leaves original message, deleted, before the undigestified messages."
    t)

--- 1489,1522 -----
  (autoload 'undigestify-rmail-message "undigest"
    "Break up a digest message into its constituent messages.
  Leaves original message, deleted, before the undigestified messages."
+   t)
+ 
+ (autoload 'rmail-digestify "digest"
+   "Turn a Rmail file into a single digest to be mailed out.  Leaves
+ the messages in the Rmail file but sets them deleted.
+ If given a positive numeric argument, will ask for list of messages to use.
+ If given a numeric argument of 0, will ask for a time/date to send out 
+ the digest.
+ If given a negative numeric argument, will ask for a list of messages and 
+ ask for a time/date to send out the digest."
+   t)
+ 
+ (autoload 'digest "digest"
+   "Turn a Rmail file into a single digest to be mailed out.  Leaves
+ the messages in the Rmail file but sets them deleted.
+ If given a positive numeric argument, will ask for list of messages to use.
+ If given a numeric argument of 0, will ask for a time/date to send out 
+ the digest.
+ If given a negative numeric argument, will ask for a list of messages and 
+ ask for a time/date to send out the digest."
+   t)
+ 
+ (autoload 'digest-next-error "digest"
+   "Goto the message and position of the next error from digestifying."
+   t)
+ 
+ (autoload 'digest-char-count "digest"
+   "Print the number of characters in the given messages.  Will request
+ a list of message numbers to count.  If none given, it will count all
+ the messages in this RMAIL file."
    t)
diff -c rmailkwd.el.ORIG rmailkwd.el
*** rmailkwd.el.ORIG	Wed May 25 23:53:15 1988
--- rmailkwd.el	Tue May 17 18:28:34 1988
***************
*** 30,36
  (defconst rmail-attributes
    (cons 'rmail-keywords
  	(mapcar '(lambda (s) (intern s rmail-label-obarray))
! 		'("deleted" "answered" "filed" "forwarded" "unseen" "edited"))))
  
  (defconst rmail-deleted-label (intern "deleted" rmail-label-obarray))
  

--- 30,37 -----
  (defconst rmail-attributes
    (cons 'rmail-keywords
  	(mapcar '(lambda (s) (intern s rmail-label-obarray))
! 		'("deleted" "answered" "filed" "forwarded" "resent"
! 		  "unseen" "edited"))))
  
  (defconst rmail-deleted-label (intern "deleted" rmail-label-obarray))
  
diff -c rmailout.el.ORIG rmailout.el
*** rmailout.el.ORIG	Wed May 25 23:54:07 1988
--- rmailout.el	Mon Oct 31 17:42:32 1988
***************
*** 123,125
        (progn
  	(rmail-set-attribute "filed" t)
  	(and rmail-delete-after-output (rmail-delete-forward)))))

--- 123,151 -----
        (progn
  	(rmail-set-attribute "filed" t)
  	(and rmail-delete-after-output (rmail-delete-forward)))))
+ 
+ 
+ ;;; Added Rutgers stuff for doing multiple message output
+ 
+ (defun rmail-multiple-output-to-rmail-file (file-name &optional msg-list)
+   "Append and delete the list of messages (defaulting to the current one) to
+ an Rmail file named FILE-NAME.  If the file does not exist, ask if it should
+ be created.  If file is being visited, the message is appended to the Emacs
+ buffer visiting that file.  The optional MSG-LIST is a list of message numbers
+ to move which defaults to the current message.  A list of message numbers is
+ either numbers or ranges of numbers separated by commas.  Ranges are two
+ numbers separated by a colon."
+   (interactive (list (read-file-name
+ 		      (concat "Output message(s) to Rmail file: (default "
+ 			      (file-name-nondirectory rmail-last-rmail-file)
+ 			      ") ")
+ 		      (file-name-directory rmail-last-rmail-file)
+ 		      rmail-last-rmail-file)
+ 		     (mail-get-list
+ 		      "Input list of numbers separated by commas:"
+ 		      rmail-total-messages
+ 		      rmail-current-message nil)))
+   (while msg-list
+     (rmail-show-message (car msg-list))
+     (rmail-output-to-rmail-file file-name)
+     (setq msg-list (cdr msg-list))))
diff -c rmailsum.el.ORIG rmailsum.el
*** rmailsum.el.ORIG	Fri Mar 25 00:33:01 1988
--- rmailsum.el	Thu Mar 24 19:03:34 1988
***************
*** 60,65
  	(if (not primary-only)
  	    (string-match recipients (or (mail-fetch-field "Cc") ""))))))
  
  (defun rmail-new-summary (description function &rest args)
    "Create a summary of selected messages.
  DESCRIPTION makes part of the mode line of the summary buffer.

--- 60,132 -----
  	(if (not primary-only)
  	    (string-match recipients (or (mail-fetch-field "Cc") ""))))))
  
+ (defun rmail-summary-by-senders (senders &optional primary-only)
+   "Display a summary of all messages with the given SENDERS.
+ Looks at the From: field.  
+ SENDERS is a string of names separated by commas."
+   (interactive "sSenders to summarize by:  \nP")
+   (rmail-new-summary
+    (concat "Summary of " senders)
+    'rmail-message-senders-p
+    (mail-comma-list-regexp senders) primary-only))
+ 
+ (defun rmail-message-senders-p (msg senders &optional primary-only)
+   (save-restriction
+     (goto-char (rmail-msgbeg msg))
+     (search-forward "\n*** EOOH ***\n")
+     (narrow-to-region (point) (progn (search-forward "\n\n") (point)))
+     (or (string-match senders (or (mail-fetch-field "From") "")))))
+ 
+ (defun rmail-summary-by-subject (subject &optional primary-only)
+   "Display a summary of all messages with the given SUBJECT.
+ Looks at the Subject: field.  
+ SUBJECT is a string of names separated by commas."
+   (interactive "sSubject to summarize by:  \nP")
+   (rmail-new-summary
+    (concat "Summary of " subject)
+    'rmail-message-subject-p
+    (mail-comma-list-regexp subject) primary-only))
+ 
+ (defun rmail-message-subject-p (msg subject &optional primary-only)
+   (save-restriction
+     (goto-char (rmail-msgbeg msg))
+     (search-forward "\n*** EOOH ***\n")
+     (narrow-to-region (point) (progn (search-forward "\n\n") (point)))
+     (or (string-match subject (or (mail-fetch-field "Subject") "")))))
+ 
+ (defun rmail-summary-by-date (date &optional primary-only)
+   "Display a summary of all messages with the given DATE.
+ Looks at the Date: field.  
+ DATE is a string of names separated by commas."
+   (interactive "sDate to summarize by:  \nP")
+   (rmail-new-summary
+    (concat "Summary of " date)
+    'rmail-message-date-p
+    (mail-comma-list-regexp date) primary-only))
+ 
+ (defun rmail-message-date-p (msg date &optional primary-only)
+   (save-restriction
+     (goto-char (rmail-msgbeg msg))
+     (search-forward "\n*** EOOH ***\n")
+     (narrow-to-region (point) (progn (search-forward "\n\n") (point)))
+     (or (string-match date (or (mail-fetch-field "Date") "")))))
+ 
+ (defun rmail-summary-by-to (to &optional primary-only)
+   "Display a summary of all messages with the given TO.
+ Looks at the To: field.  TO is a string of names separated by commas."
+   (interactive "sTo to summarize by:  \nP")
+   (rmail-new-summary
+    (concat "Summary of " to)
+    'rmail-message-to-p
+    (mail-comma-list-regexp to) primary-only))
+ 
+ (defun rmail-message-to-p (msg to &optional primary-only)
+   (save-restriction
+     (goto-char (rmail-msgbeg msg))
+     (search-forward "\n*** EOOH ***\n")
+     (narrow-to-region (point) (progn (search-forward "\n\n") (point)))
+     (or (string-match to (or (mail-fetch-field "To") "")))))
+ 
  (defun rmail-new-summary (description function &rest args)
    "Create a summary of selected messages.
  DESCRIPTION makes part of the mode line of the summary buffer.
diff -c sendmail.el.ORIG sendmail.el
*** sendmail.el.ORIG	Wed May 25 23:56:10 1988
--- sendmail.el	Tue May 24 19:12:52 1988
***************
*** 63,69
  Suitable header fields are To, CC and BCC."
    nil)
  
! (defun mail-setup (to subject in-reply-to cc replybuffer)
    (if (eq mail-aliases t)
        (progn
  	(setq mail-aliases nil)

--- 63,69 -----
  Suitable header fields are To, CC and BCC."
    nil)
  
! (defun mail-setup (to subject in-reply-to cc replybuffer &optional resent-to)
    (if (eq mail-aliases t)
        (progn
  	(setq mail-aliases nil)
***************
*** 82,87
  	  (let ((fill-prefix "\t"))
  	    (fill-region (point-min) (point-max))))
        (newline))
      (if cc
  	(let ((opos (point))
  	      (fill-prefix "\t"))

--- 82,95 -----
  	  (let ((fill-prefix "\t"))
  	    (fill-region (point-min) (point-max))))
        (newline))
+     (if resent-to
+ 	(progn
+ 	  (if (not (null (car (cdr resent-to))))
+ 	      (insert "From: " (car (cdr resent-to)) "\n"))
+ 	  (if (not (null (car (cdr (cdr resent-to)))))
+ 	      (insert "Date: " (car (cdr (cdr resent-to))) "\n"))
+ 	  (if (not (null (car (cdr (cdr (cdr resent-to))))))
+ 	      (insert "Message-ID: " (car (cdr (cdr (cdr resent-to)))) "\n"))))
      (if cc
  	(let ((opos (point))
  	      (fill-prefix "\t"))
***************
*** 91,97
  	(insert "In-reply-to: " in-reply-to "\n"))
      (insert "Subject: " (or subject "") "\n")
      (if mail-default-reply-to
! 	(insert "Reply-to: " mail-default-reply-to "\n"))
      (if mail-self-blind
  	(insert "BCC: " (user-login-name) "\n"))
      (if mail-archive-file-name

--- 99,107 -----
  	(insert "In-reply-to: " in-reply-to "\n"))
      (insert "Subject: " (or subject "") "\n")
      (if mail-default-reply-to
! 	(if resent-to
! 	    (insert "ReSent-Reply-to: " mail-default-reply-to "\n")
! 	  (insert "Reply-to: " mail-default-reply-to "\n")))
      (if mail-self-blind
  	(if resent-to
  	    (insert "ReSent-BCC: " (user-login-name) "\n")
***************
*** 93,99
      (if mail-default-reply-to
  	(insert "Reply-to: " mail-default-reply-to "\n"))
      (if mail-self-blind
! 	(insert "BCC: " (user-login-name) "\n"))
      (if mail-archive-file-name
  	(insert "FCC: " mail-archive-file-name "\n"))
      (insert mail-header-separator "\n"))

--- 103,111 -----
  	    (insert "ReSent-Reply-to: " mail-default-reply-to "\n")
  	  (insert "Reply-to: " mail-default-reply-to "\n")))
      (if mail-self-blind
! 	(if resent-to
! 	    (insert "ReSent-BCC: " (user-login-name) "\n")
! 	  (insert "BCC: " (user-login-name) "\n")))
      (if mail-archive-file-name
  	(insert "FCC: " mail-archive-file-name "\n"))
      (if resent-to
***************
*** 96,101
  	(insert "BCC: " (user-login-name) "\n"))
      (if mail-archive-file-name
  	(insert "FCC: " mail-archive-file-name "\n"))
      (insert mail-header-separator "\n"))
    (if to (goto-char (point-max)))
    (or to subject in-reply-to

--- 108,118 -----
  	  (insert "BCC: " (user-login-name) "\n")))
      (if mail-archive-file-name
  	(insert "FCC: " mail-archive-file-name "\n"))
+     (if resent-to
+ 	(progn
+ 	  (if (not (null (car resent-to)))
+ 	      (insert "ReSent-To: " (car resent-to) "\n"))
+ 	  (insert "ReSent-Date: " (resent-date) "\n")))
      (insert mail-header-separator "\n"))
    (if to (goto-char (point-max)))
    (or to subject in-reply-to
***************
*** 218,223
  		 (progn
  		   (forward-line 1)
  		   (insert "Sender: " (user-login-name) "\n")))
  	    ;; don't send out a blank subject line
  	    (goto-char (point-min))
  	    (if (re-search-forward "^Subject:[ \t]*\n" delimline t)

--- 235,244 -----
  		 (progn
  		   (forward-line 1)
  		   (insert "Sender: " (user-login-name) "\n")))
+ 	    ;; complain about a Newsgroups header
+ 	    (goto-char (point-min))
+ 	    (if (re-search-forward "^Newsgroups:" delimline t)
+ 		(error "Sendmail can't handle 'Newsgroups:' headers.  Please remove and send again."))
  	    ;; don't send out a blank subject line
  	    (goto-char (point-min))
  	    (if (re-search-forward "^Subject:[ \t]*\n" delimline t)
***************
*** 387,392
  			   (progn (re-search-forward "\n[^ \t]")
  				  (forward-char -1)
  				  (point))))))))
  
  ;; Put these last, to reduce chance of lossage from quitting in middle of loading the file.
  

--- 408,434 -----
  			   (progn (re-search-forward "\n[^ \t]")
  				  (forward-char -1)
  				  (point))))))))
+ 
+ (defun resent-date ()
+   "Return the current date and time for the resent-date field."
+   (let ((date (current-time-string)))
+     (concat (substring date 0 3)  ;"Tue"
+ 	    ", "
+ 	    (substring date 4 11)  ;11 Aug
+ 	    (substring date 22 24) ;87
+ 	    (substring date 10 20)
+ 	    (timezone))))
+ 
+ (defun mail-add-header (header)
+   "Add HEADER to the headers of the mail message being composed.  Generally
+ will be run from mail-setup-hook."
+   (interactive "sHeader: ")
+   (save-excursion
+     (let ((case-fold-search t))
+       (goto-char (point-min))
+       (search-forward (concat "\n" mail-header-separator "\n"))
+       (forward-line -1)
+       (insert (concat header "\n")))))
  
  ;; Put these last, to reduce chance of lossage from quitting in middle of loading the file.
  
***************
*** 390,396
  
  ;; Put these last, to reduce chance of lossage from quitting in middle of loading the file.
  
! (defun mail (&optional noerase to subject in-reply-to cc replybuffer)
    "Edit a message to be sent.  Argument means resume editing (don't erase).
  Returns with message buffer seleted; value t if message freshly initialized.
  While editing message, type C-c C-c to send the message and exit.

--- 432,438 -----
  
  ;; Put these last, to reduce chance of lossage from quitting in middle of loading the file.
  
! (defun mail (&optional noerase to subject in-reply-to cc replybuffer resent-to)
    "Edit a message to be sent.  Argument means resume editing (don't erase).
  Returns with message buffer seleted; value t if message freshly initialized.
  While editing message, type C-c C-c to send the message and exit.
***************
*** 416,422
   the initial contents of those header fields.
   These arguments should not have final newlines.
  The sixth argument REPLYBUFFER is a buffer whose contents
!  should be yanked if the user types C-c C-y."
    (interactive "P")
    (switch-to-buffer "*mail*")
    (setq default-directory (expand-file-name "~/"))

--- 458,466 -----
   the initial contents of those header fields.
   These arguments should not have final newlines.
  The sixth argument REPLYBUFFER is a buffer whose contents
!  should be yanked if the user types C-c C-y.
! The seventh argument RESENT-TO, if non-nil specifies the contents of the
!  ReSent-To: header."
    (interactive "P")
    (switch-to-buffer "*mail*")
    (setq default-directory (expand-file-name "~/"))
***************
*** 426,432
         (or (not (buffer-modified-p))
  	   (y-or-n-p "Unsent message being composed; erase it? "))
         (progn (erase-buffer)
! 	      (mail-setup to subject in-reply-to cc replybuffer)
  	      t)))
  
  (defun mail-other-window (&optional noerase to subject in-reply-to cc replybuffer)

--- 470,476 -----
         (or (not (buffer-modified-p))
  	   (y-or-n-p "Unsent message being composed; erase it? "))
         (progn (erase-buffer)
! 	      (mail-setup to subject in-reply-to cc replybuffer resent-to)
  	      t)))
  
  (defun mail-other-window (&optional noerase to subject in-reply-to cc replybuffer resent-to)
***************
*** 429,435
  	      (mail-setup to subject in-reply-to cc replybuffer)
  	      t)))
  
! (defun mail-other-window (&optional noerase to subject in-reply-to cc replybuffer)
    "Like \"mail\" command, but display mail buffer in another window."
    (interactive "P")
    (let ((pop-up-windows t))

--- 473,479 -----
  	      (mail-setup to subject in-reply-to cc replybuffer resent-to)
  	      t)))
  
! (defun mail-other-window (&optional noerase to subject in-reply-to cc replybuffer resent-to)
    "Like \"mail\" command, but display mail buffer in another window."
    (interactive "P")
    (let ((pop-up-windows t))
***************
*** 434,439
    (interactive "P")
    (let ((pop-up-windows t))
      (pop-to-buffer "*mail*"))
!   (mail noerase to subject in-reply-to cc replybuffer))
  
  ;;; Do not add anything but external entries on this page.

--- 478,483 -----
    (interactive "P")
    (let ((pop-up-windows t))
      (pop-to-buffer "*mail*"))
!   (mail noerase to subject in-reply-to cc replybuffer resent-to))
  
  ;;; Do not add anything but external entries on this page.

==================================================End of files.


arpa: Steiner@TOPAZ.RUTGERS.EDU
uucp: ...{ames, cbosgd, harvard, moss}!rutgers!topaz.rutgers.edu!steiner

