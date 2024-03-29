;;; $Header: rcs.el,v 1.2 86/12/14 21:35:37 evs Exp $
;;; 
;;; $Log:	rcs.el,v $
;;; Revision 1.2  86/12/14  21:35:37  evs
;;; 	Added an rcs mode map and several new functions.
;;; 	Tries to figure out new revision level by examining the
;;; 	output of an  rlog -h.  Shows type of checkin in mode line.
;;; 
;;; Revision 1.1  86/12/04  12:38:19  evs
;;; Initial revision
;;; 

;; Copyright (C) 1986 Edward V. Simpson

;; This file is part of GNU Emacs.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY.  No author or distributor
;; accepts responsibility to anyone for the consequences of using it
;; or for whether it serves any particular purpose or works at all,
;; unless he says so in writing.  Refer to the GNU Emacs General Public
;; License for full details.

;; Everyone is granted permission to copy, modify and redistribute
;; GNU Emacs, but only under the conditions described in the
;; GNU Emacs General Public License.   A copy of this license is
;; supposed to have been given to you along with GNU Emacs so you
;; can know your rights and responsibilities.  It should be in a
;; file named COPYING.  Among other things, the copyright notice
;; and this notice must be preserved on all copies.

;;; Originally written by: 
;;; 		Ed Simpson
;;; 		P. O. Box 3140
;;; 		Duke University Medical Center
;;; 		Durham, NC, USA  27710
;;;		{decvax, seismo}!mcnc!duke!dukecdu!evs

;;; User options

(defvar rcs-max-log-size 510
  "*Maximum allowable size (chars) + 1 of an rcs log message.")
(defvar rcs-verbose nil
  "*If non-nil then rcs will ask questions before you edit the log message.")

;;; Vars the user doesn't need to know about.

(defvar rcs-mode-map nil)

;;; The stuff.

(defun rcs ()
"Performs an RCS check in of the file associated with the current buffer.
Pops up a buffer for creation of a log message then
does a \"ci -u file\", a \"ci -l file\", or a \"ci file\".
You MUST have an RCS directory in the same directory as the
file being checked in."
  (interactive)
  (if (buffer-file-name)
      (rcs-ci-co)
    (error "There is no file associated with buffer %s" (buffer-name)))
)

(defun rcs-ci-co ()
  "Edits an rcs log message and supervises a check in."
  (let
      (rcs-file do-ci do-update r
		(file (buffer-file-name))
		(lock "u")
		(force nil)
		(rcs-buf (get-buffer-create "*RCS*"))
		(rcs-log-buf (get-buffer-create "*RCS-Log*"))
		(scratch-stuff (get-buffer-create "*Scratch-Stuff*"))
		(err-msg nil))

    (save-excursion			; construct RCS file name
      (set-buffer scratch-stuff)
      (erase-buffer)
      (insert-string file)
      (search-backward "/")
      (insert-string "/RCS")
      (end-of-line)
      (insert-string ",v")
      (setq rcs-file (buffer-substring (point-min) (point)))
					; get revision level and increment
      (erase-buffer)
      (call-process "rlog" nil t nil "-h" file)
      (goto-char (point-min))
      (if (looking-at "rlog error:")
	  (setq r "1.1")
	(if (not (setq r (rcs-parse-revision-level
			  (concat
			  "^locks:.*" (user-login-name) ":[ \t]*"))))
	    (if (string-equal "n"
			      (rcs-answer-question
			       (format "%s has no lock set for %s. Try anyway?"
				       (user-login-name)
				       (file-name-nondirectory file))
			       "n" "y" nil))
		(error "rcs aborted")
	      (goto-char (point-min))
	      (if (not (setq r (rcs-parse-revision-level "^head:[ \t]*")))
		  (error "can not find head revision"))))))

    (if (buffer-modified-p)
	(if (equal "y"
		   (rcs-answer-question
		    (format
		     "%s has been modified. Should I write it out?"
		     (buffer-name)) "y" "n" nil))
	    (save-buffer)))

    (if rcs-verbose
	(progn
	  (setq lock (rcs-answer-question
		      "Check out new version unlocked, locked, or not at all?"
		      "u" "l" "n"))
	  (if (equal "y" (rcs-answer-question
			  (format "Rev: %s  Change revision level?" r) "n" "y" nil))
	      (setq r (read-string "Enter new revision level: ")))))

    (save-window-excursion
      (pop-to-buffer rcs-buf)
      (erase-buffer)
      (set-buffer-modified-p nil)
      (setq do-ci t)
      (rcs-mode)
      (rcs-mode-line rcs-file r lock force)
      (message 
       "Enter log message. Type C-c C-c when done, C-c ? for help.")
      (recursive-edit)
      (if do-ci
	  (rcs-do-ci file r lock force rcs-file))
      (bury-buffer rcs-buf))

    (kill-buffer scratch-stuff)

    (if do-ci
	(if err-msg
	    (error "%s  Buffer not updated." err-msg)
	  (if do-update
	      (if (buffer-modified-p)
		  (error
		   "Warning: checked out version of file does not match buffer!")
		(revert-buffer)))))
  )
)


(defun rcs-do-ci (filename rev lockval forceval rcsfilename)
  "Does the actual work of an rcs check in.
Check in the file specified by FILENAME.  REV is a string specifying the
new revision level, if it is the empty string, increment the current level.
LOCKVAL is a string containing the lock option letter passed to ci or is \"n\"
for no check out after the ci.  If FORCEVAL is non-nil then force the ci.
Use the rcs file specified by RCSFILENAME."
  (message "Checking in file %s ..." filename)
  (sit-for 0)
  (goto-char (point-max))
  (if (not (bolp)) (newline))
  (newline)
  (if  (string-equal "n" lockval)
      (progn
	(call-process-region (point-min) (1- (point)) "ci" nil t t
			     (format "-%s%s" (if forceval "f" "r") rev)
			     filename rcsfilename)
	(setq do-update nil))
    (call-process-region (point-min) (1- (point)) "ci" nil t t
			 (format "-%s%s" (if forceval "f" "r") rev)
			 (format "-%s" lockval)
			 filename rcsfilename)
    (setq do-update t))
  (goto-char (point-max))
  (previous-line 1)
  (if (not (looking-at "done"))		; make sure rcs did check-in OK
      (setq err-msg "Rcs error."))
  (read-string "Hit return to continue ...")
)


(defun rcs-abort ()
  "Abort an rcs command."
  (interactive)
  (if (equal "y" (rcs-answer-question "Do you really want to abort rcs?"
				      "y" "n" nil))
	 (progn
	   (setq do-ci nil)
	   (exit-recursive-edit))
	 (error "Turkey!"))
)


(defun rcs-exit ()
  "Leave the recursive edit of an rcs log message."
  (interactive)
  (if (< (buffer-size) rcs-max-log-size)
	 (progn
	   (copy-to-buffer rcs-log-buf (point-min) (point-max))
	   (exit-recursive-edit))
	 (progn
	   (goto-char rcs-max-log-size)
	   (error
	    "Log must be less than %d characters. Point is now at character %d."
	    rcs-max-log-size rcs-max-log-size)))
)


(defun rcs-insert-last-log ()
  "Insert the log message of the last rcs check in at point."
  (interactive)
  (insert-buffer rcs-log-buf)
)

(defun rcs-toggle-lock ()
  "Toggle the rcs ci lock variable."
  (interactive)
  (cond
   ((string-equal lock "u") (setq lock "l"))
   ((string-equal lock "l") (setq lock "n"))
   (t (setq lock "u")))
  (rcs-mode-line rcs-file r lock force)
)

(defun rcs-toggle-force ()
  "Toggle the rcs ci force variable."
  (interactive)
  (if force (setq force nil) (setq force t))
  (rcs-mode-line rcs-file r lock force)
)

(defun rcs-set-revision-level ()
  "Ask the user for a new revision level for an rcs ci."
  (interactive)
  (setq r (read-string "Enter new revision level: "))
  (rcs-mode-line rcs-file r lock force)
)

(defun rcs-answer-question (question defopt opt1 opt2)
  "Asks the user a question and prompts with legal answers.
The question string is specified by QUESTION.  The string DEFOPT specifies
the default answer.  OPT1 specifies the alternative answer. If OPT2 is
non-nil then it specifies a second alternative.
Returns the answer given by the user.  If the user just hits the return key
the default answer is returned."
  (let
      (val s done
       (prompt (format "%s [%s,%s%s] " question defopt opt1
		       (if opt2 (format ",%s" opt2) ""))))
    (setq done nil)
    (while (not done)
      (setq s (read-string prompt))
      (if (equal s "")
	  (progn (setq val defopt) (setq done t))
	(if (or (equal s defopt) (equal s opt1) (equal s opt2))
	    (progn (setq val s) (setq done t)))))
    val)
)

(defun rcs-parse-revision-level (regexp)
  "Tries to parse out a revision level at the end of REGEXP.
If successful increments the revision level and returns it as a string,
otherwise returns nil."
  (let
      (beg end tmp)
    (if (re-search-forward regexp (point-max) t)
	(progn
	  (setq beg (match-end 0))
	  (if (re-search-forward "[0-9.]*" (point-max) t)
	      (progn
		(setq end (match-end 0))
		(goto-char beg)
		(if (re-search-forward "\\([0-9]+\\.\\)+" (point-max) t)
		    (progn
		      (setq tmp (string-to-int (buffer-substring (point) end)))
		      (delete-region (point) end)
		      (insert-string (1+ tmp))
		      (re-search-forward "[0-9]*" (point-max) t)
		      (buffer-substring beg (point)))))))))
)

(defun rcs-mode-line (filename rev lockval forceval)
  "Set the mode line for an rcs buffer.
FILENAME is the filename string to put in the modeline,
the string REV is the new revision level, and
the string LOCKVAL is the lock char for the ci.
If FORCEVAL is non-nil then the modeline will indicate that the ci will
be forced."
  (let
      ((lock-str (cond
		  ((string-equal lockval "u") " unlock")
		  ((string-equal lockval "l") " lock")
		  (t " no co")))
       (force-str (if forceval " force" "")))
    (setq mode-line-format
	  (concat "--%1*%1*-Emacs: %b  "
		  (format "[%s%s%s] %s" rev lock-str force-str
			  (file-name-nondirectory filename))
		  "  %M %[(%m)%]--%3p-%-"))
					; force update of screen
    (save-excursion (set-buffer (other-buffer)))
    (sit-for 0))
)

(defun rcs-mode ()
  "Major mode for doing an rcs check in.
Calls the value of text-mode-hook then rcs-mode-hook.
Like Text Mode but with these additional comands:
C-c C-c		proceed with check in
C-x C-s		same as C-c C-c
C-c i		insert log message from last check in
C-c l		toggle the \"lock variable\"
C-c r		set a new revision level
C-c f		toggle the \"force variable\"
C-c a		abort this check in
C-c ?		show this message

The \"lock variable\" determines what type of check out to do after a
successful check in.  Possible values are:
	lock		check out new version locked
	unlock		check out new version unlocked
	no co		do not check out new version

If the \"force variable\" is set then the check in will be forced even if
this version is not different from the previous version.

Global user options:
	rcs-max-log-size	specifies the maximum allowable size
				of a log message plus one.
	rcs-verbose		if non-nil then ask questions before
				editing log message."
  (interactive)
  (set-syntax-table text-mode-syntax-table)
  (use-local-map rcs-mode-map)
  (setq local-abbrev-table text-mode-abbrev-table)
  (setq major-mode 'rcs-mode)
  (setq mode-name "RCS")
  (run-hooks 'text-mode-hook 'rcs-mode-hook)
)

(if rcs-mode-map
    nil
  (setq rcs-mode-map (make-sparse-keymap))
  (define-key rcs-mode-map "\C-c?" 'describe-mode)
  (define-key rcs-mode-map "\C-ci" 'rcs-insert-last-log)
  (define-key rcs-mode-map "\C-cl" 'rcs-toggle-lock)
  (define-key rcs-mode-map "\C-cr" 'rcs-set-revision-level)
  (define-key rcs-mode-map "\C-cf" 'rcs-toggle-force)
  (define-key rcs-mode-map "\C-ca" 'rcs-abort)
  (define-key rcs-mode-map "\C-c\C-c" 'rcs-exit)
  (define-key rcs-mode-map "\C-x\C-s" 'rcs-exit)
)
