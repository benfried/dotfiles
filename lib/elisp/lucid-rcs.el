 6-Aug-92  8:46:09-GMT,36883;000000000001
Return-Path: <help-lucid-emacs-request@lucid.com>
Received: from lucid.com by banzai.cc.columbia.edu (5.59/FCB)
	id AA10047; Thu, 6 Aug 92 04:46:01 EDT
Received: from rodan.UU.NET by heavens-gate.lucid.com id AA22128g; Thu, 6 Aug 92 01:18:20 PDT
Received: from help-lucid-emacs@lucid.com (list exploder) by rodan.UU.NET 
	(5.61/UUNET-mail-drop) id AA16047; Thu, 6 Aug 92 04:28:25 -0400
Received: from news.UU.NET by rodan.UU.NET with SMTP 
	(5.61/UUNET-mail-drop) id AA16038; Thu, 6 Aug 92 04:28:21 -0400
Received: from USENET (alt.lucid-emacs.help) by news.UU.NET with InterNetNews 
	(5.61/UUNET-mail-leaf) id AA28240; Thu, 6 Aug 92 04:28:44 -0400
Path: uunet!mcsun!corton!loria!news.loria.fr!bosch
From: bosch%loria.fr@lucid.com (Guido Bosch)
Newsgroups: alt.lucid-emacs.help
Subject: Re: reading changed files
Message-Id: <BOSCH.92Aug6101637@moebius.loria.fr>
Date: 6 Aug 92 08:16:37 GMT
References: <9208050749.AA14527@amil.co.il>
Organization: INRIA-Lorraine / CRIN, Nancy, France
In-Reply-To: danny@amil.co.il's message of 5 Aug 92 13:11:01 GMT
Sender: help-lucid-emacs-request@lucid.com
To: help-lucid-emacs@lucid.com

In article <9208050749.AA14527@amil.co.il> danny@amil.co.il (Danny Bar-Dov) writes:
 >
 >
 >   We use RCS for version control.
 >
 >   ... 
 >
 >   Is there some lisp code which supports RCS ? maybe some
 >   dired mode which shows locked/unlocked files and allows
 >   to perform rcs operatpions ?
 >


There are a lot of rcs-modes for GNU Emacs out there (too many, after
my opinion). I played around with most of them and found the one of
Sebastian Kremer most satisfactory for my needs (not to big, the command
key bindings are not interferring with other modes)


Here is it, together with the corresponding part of my .emacs and an
rcs-log-mode package extracted from Edward V. Simpson's rcs.el. 

Enjoy,

	Guido



------------------------------- .emacs -------------------------------
;; RCS 
;; author: Sebastian Kremer 

;; This makes load up rcs at the first file access. A better solution
;; would be to seperate the postprocessor stuff from the rest of
;; rcs.el.  In this case, rcs-postprocessor.el should define autoloads
;; for rcs commands.

(autoload 'rcs-load-postprocessor "rcs" nil t)
(add-hook 'find-file-hooks  'rcs-load-postprocessor)

;; use my own rcs log stuff
(setq rcs-read-log-function 'rcs-get-log-string)
(autoload 'rcs-get-log-string "rcs-log-mode")
(setq rcsdiff-switches '("-c")))

;; end RCS

----------------------------- rcs-sk.el -----------------------------
;;;; rcs.el - RCS interface for GNU Emacs.

;; Originally written by James J. Elliott <elliott@cs.wisc.edu>
;; Rewritten by Sebastian Kremer <sk@thp.uni-koeln.de>.

;; Copyright (C) 1990 James J. Elliott
;; Copyright (C) 1991 Sebastian Kremer

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 1, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;; LISPDIR ENTRY for the Elisp Archive ===============================
;;    LCD Archive Entry:
;;    rcs|Sebastian Kremer|sk@thp.uni-koeln.de
;;    |RCS interface for GNU Emacs
;;    |$Date: 1992/02/10 10:29:26 $|$Revision: 1.55 $|

;; INSTALLATION ======================================================
;;
;; Put this file into your load-path and the following in your ~/.emacs:
;;
;;   (load "rcs")

;; USAGE =============================================================

;; C-x C-q to make an RCS-controlled file writable by checking it out locked
;; C-c I   * check in
;; C-c O   * check out without locking, C-u C-c O checkout locked
;; C-c U   unlock (revert to last checked-in version, flushing changes)
;; C-c D   * rcsdiff
;; C-c L   * rlog
;; C-c S   * show or set rcs status
;; C-c W   rcswho (list of lockers of all files in a directory)
;;
;; C-x C-f on a non-existent working file will offer to check it out from RCS

;; Prefix arg to commands marked with * lets you edit the switches,
;; making it very flexible (e.g. to check in new branches or with
;; specified revision numbers [-uREV, -lREV], or even in case the file
;; didn't change [-f]).

;; Read the manual for more info.

(defconst rcs-version  (substring "$Revision: 1.55 $" 11 -2)
  "$Id: rcs.el,v 1.55 1992/02/10 10:29:26 sk Exp $

Report bugs to: Sebastian Kremer <sk@thp.uni-koeln.de>

Available for anonymous FTP from
     ftp.cs.buffalo.edu:pub/Emacs/rcs.tar.Z
and
     ftp.uni-koeln.de:/pub/gnu/emacs/rcs.tar.Z")


;; Customization variables

(defvar rcs-bind-keys t
  "If nil, rcs.el will not bind any keys.
Has to be set before rcs.el is loaded.")

(defvar rcs-active t
  "*If non-nil, RCS controlled files are treated specially by Emacs.")

(defvar rcs-ange-ftp-ignore t
  "*If non-nil, remote ange-ftp files are never considered RCS controlled.
This saves a lot of time for slow connections.")

(defvar rcsdiff-switches nil
  "*If non-nil, a string specifying switches to be be passed to rcsdiff.
A list of strings (or nil) means that the commandline can be edited
after inserting those strings.")

(defvar rcs-default-co-switches nil
  "List of switches (strings) for co(1) to use on every `rcs-check-out'.")

(defvar rcs-default-ci-switches nil
  "List of switches (strings) for ci(1) to use on every `rcs-check-in'.
You can use the `-f' switch to force new revision with RCS 5.6 even if
the file did not change.")

(defvar rcs-default-rlog-switches nil
  "List of switches (strings) for rlog(1) to use on every `rcs-log'.")
 
(defvar rcs-read-log-function nil
  "*If non-nil, function of zero args to read an RCS log message.
If nil, log messages are read from the minibuffer.
Possible value: 'rcs-read-log-string-with-recursive-edit.")

;; End of customization variables

;; Buffer-local modeline variables, and hooking into Emacs.

(defvar rcs-mode nil
  "If non-nil, the current buffer's file is RCS-controlled:

If the emptry string, it is unlocked, and the modeline display the
head revision number.

Else it is a string of lockers as returned by function `rcs-status',
which is displayed in the modeline, in the format LOCKER:REV.")

(defvar rcs-mode-string nil)		; for use in modeline

;; In case you are using Joe Well's kill-fix.el, available from the
;; Elisp archive archive.cis.ohio-state.edu:pub/gnu/emacs/elisp-archive/,
;; this will prevent killing rcs modeline variables in a major mode change:
(put 'rcs-mode 'preserved t)
(put 'rcs-mode-string 'preserved t)

;; Tell Emacs about this new kind of minor mode
(if (not (assoc 'rcs-mode minor-mode-alist))
    (progn
      (setq minor-mode-alist (cons '(rcs-mode rcs-mode-string)
				   minor-mode-alist))
      ;; make-variable-buffer-local also initializes to nil (in 18.55),
      ;; but we better don't rely on this since it is not documented.
      (set-default (make-variable-buffer-local 'rcs-mode) nil)
      (set-default (make-variable-buffer-local 'rcs-mode-string) nil)))

(defun rcs-file-not-found ()
  ;; If current buffer's file is RCS controlled, check it out.
  ;; Called when find-file has not been able to find the specified file.
  ;; Return t if found, nil else for use as hook.
  (and rcs-active
       (rcs-status buffer-file-name)
       ;; No good asking user here since he shouldn't create a
       ;; new empty file when there is actually an RCS file for it.
       (rcs-check-out
	buffer-file-name
	(and (y-or-n-p "Check out writable and locked for editing? ")
	     '("-l")))
       ;; Indicate if file was found so that other not-found hooks
       ;; aren't run in that case
       t))

;; Install the above routine, making it the first hook
(or (memq 'rcs-file-not-found find-file-not-found-hooks)
      (setq find-file-not-found-hooks
            (cons 'rcs-file-not-found find-file-not-found-hooks)))

(defun rcs-status (fname &optional switches)
  "Returns the locker and version of this file if it is locked, an empty
string if it is not locked, and nil if it is not an RCS controlled file.
If several lockers, they are returned as one string, separated by SPC.

With a prefix arg, set the status instead of querying it.  This works
by passing the prompted-for SWITCHES to the `rcs' program."
  (interactive
   (list (rcs-read-file-name (concat (if current-prefix-arg "Set" "Query")
				     " RCS status of: "))
	 (and current-prefix-arg
	      (rcs-read-switches "Switches for rcs: "))))
  (setq fname (expand-file-name fname))
  (if switches
      (let ((output-buffer (rcs-get-output-buffer fname)))
	(save-excursion
	  (set-buffer output-buffer)
	  (apply 'call-process "rcs" nil t nil
		 (append switches (list "-q" fname)))
	  (if (> (buffer-size) 0)
	      (rcs-error "rcs" fname output-buffer))))
    (let (rname status head)
      (if (and rcs-ange-ftp-ignore
	       (fboundp 'ange-ftp-ftp-path)
	       (ange-ftp-ftp-path fname))
	  (setq status nil)		; remote file not considered for RCS
	(setq rname (rcs-data-file fname))
	(if rname
	    ;; parse contents of the RCS (`,v') file
	    (save-excursion
	      (set-buffer (rcs-get-output-buffer rname " *RCS-temp*"))
	      (insert-file-contents rname nil)
	      (goto-char (point-min))
	      (setq status
		    (if (re-search-forward "^locks[ \t\n\r\f]+\\([^;]*\\)" nil t)
			(save-restriction ;; ^J in `rcs-mode-string' looks ugly
			  (narrow-to-region (match-beginning 1) (match-end 1))
			  (goto-char (point-min))
			  (while (re-search-forward "[ \t\n\r\f]+" nil t)
			    (replace-match " " t t))
			  (buffer-string))
		      ""))
	      (goto-char (point-min))
	      (if (re-search-forward "^head[ \t\n\r\f]+\\([0-9.]+\\)")
		  (setq head (buffer-substring (match-beginning 1)
					       (match-end 1))))
	      ;; more useful information could be gleaned here
	      (erase-buffer)))
	(if (interactive-p)
	    (cond ((null status)
		   (message "Not an RCS-controlled file: %s" fname))
		  ((equal "" status)
		   (message "No current locker for %s" fname))
		  (t
		   (message "%s -- %s" fname status)))))
      ;; See if the STATUS we just computed so hard can be used to
      ;; update a buffer's modeline:
      (let ((buffer (get-file-buffer fname)))
	(and buffer
	     (save-excursion
	       (set-buffer buffer)
	       (rcs-set-modeline status head))))
      status)))

(defun rcs-we-locked (fname &optional status)
  ;; Return non-nil if current user has a lock on the specified file.
  ;; Value returned is the revision level that is locked (as string).
  ;; Optional 2nd arg STATUS precomputed value of (rcs-status FNAME)
  ;; can be passed for efficiency.
  (or status (setq status (rcs-status fname)))
  (and status;; STATUS is "" or string of lockers
       (string-match (concat (regexp-quote (user-login-name))
			     ":[ \t\n]*\\([0-9.]+\\)")
		     status)
       (substring status (match-beginning 1) (match-end 1))))

(defun rcs-load-postprocessor ()
  "Peeks at files after they are loaded to see if they merit special
treatment by virtue of being active RCS files.

You can also call this interactively to refresh the modeline, e.g.
after a major mode change that killed all local variables."
  (interactive)
  ;; If rcs-active is nil, the buffer local variables below stay nil.
  (and rcs-active
       buffer-file-name
       ;; this will also set the modeline:
       (rcs-status buffer-file-name)))

(defun rcs-set-modeline (status &optional head)
  ;; Set modeline of current buffer according to STATUS (see `rcs-status').
  ;; If non-nil, HEAD is the head revision to be displayed in case of
  ;; an unlocked file.  If HEAD is not given, just "RCS" is displayed.
  (setq rcs-mode status
	rcs-mode-string (and status
			     (if (equal "" status);; unlocked but under RCS
				 (if head
				     ;;(concat " RCS " head)
				     (concat " " head)
				   " RCS")
			       (concat " " status)))))

;; Install above routine
(or (memq 'rcs-load-postprocessor find-file-hooks)
      (setq find-file-hooks
            (cons 'rcs-load-postprocessor find-file-hooks)))


;; RCS utility functions

(defun rcs-read-switches (prompt &optional default)
  ;; Read a list of switches (strings), prompting with PROMPT.
  ;; User enters a single string, a space-separated list of switches.
  ;; Split on whitespace and return list of strings.
  ;; So it would not be possible to include whitespace in a switch
  ;; unless we hadn't added the escape to line mode if just a single
  ;; SPC is entered.
  (let ((answer (read-string prompt default))
	(beg 0)
	end result switch)
    (if (equal " " answer)
	(rcs-read-switches-allowing-space prompt default)
      (while (setq end (string-match "[ \t]+" answer beg))
	(setq switch (substring answer beg end)
	      beg (match-end 0))
	(or (equal "" switch)
	    (setq result (cons switch result))))
      (setq switch (substring answer beg))
      (or (equal "" switch)
	  (setq result (cons switch result)))
      (nreverse result))))

(defun rcs-read-switches-allowing-space (prompt &optional default)
  ;; Read switches, each separately, thus allowing whitespace.
  ;; DEFAULT is ignored.
  (let (answer result done (count 0))
    (while (not done)
      (setq answer (read-string
		    (concat prompt
			    "(#"
			    (int-to-string (setq count (1+ count)))
			    ", just RET for last) "))
	    done (equal "" answer))
      (or done (setq result (cons answer result))))
    (nreverse result)))

(defun rcs-read-file-name (prompt)
  ;; Read a file name prompting with PROMPT.
  ;; Default is current buffer's file, if any.
  (if buffer-file-name
      (let ((dir (file-name-nondirectory buffer-file-name)))
	(read-file-name (format (concat prompt "(default %s) ") dir)
			nil
			dir))
    (read-file-name prompt)))

(defun rcs-read-log-string (prompt)
  (if rcs-read-log-function
      (funcall rcs-read-log-function)
    (read-string prompt)))

(defun rcs-read-log-string-with-recursive-edit ()
  "Useful as value of `rcs-read-log-function'."
  (let ((buffer (get-buffer-create "*RCS log message*")))
    (save-window-excursion
      (switch-to-buffer buffer)
      ;;?(erase-buffer)
      (with-output-to-temp-buffer "*Help*"
	(princ (substitute-command-keys
		"\
Enter the RCS log message.
Type \\[mark-whole-buffer] \\[kill-region] to kill old entry.
Type \\[exit-recursive-edit] when finished editing or \\[abort-recursive-edit] to abort.")))
      (recursive-edit)
      (buffer-string))))

(defun rcs-revert-buffer (&optional arg no-confirm)
  ;; Revert buffer, try to keep point where user expects it in spite
  ;; of changes because of expanded RCS key words.
  ;; This is quite important since otherwise typeahead won't work as expected.
  (interactive "P")
  (widen)
  (let* ((opoint (point))
	 (osize (buffer-size))
	 (obobp (bobp))
	 diff
	 (context 100)
	 (ostring (buffer-substring (point)
				    (min (point-max)
					 (+ (point) context))))
	 (l (length ostring)))
    (revert-buffer arg no-confirm)
    (setq diff (- osize (buffer-size)))
    (if (< diff 0) (setq diff (- diff)))
    (goto-char opoint)
    (cond (obobp
	   (goto-char (point-min)))
	  ((equal "" ostring)		; i.e., originally at eob
	   (goto-char  (point-max)))
	  ((or (search-forward ostring nil t)
	       ;; Can't use search-backward since the match may continue
	       ;; after point.
	       (progn (goto-char (- (point) diff l))
		      ;; goto-char doesn't signal an error at
		      ;; beginning of buffer like backward-char would
		      (search-forward ostring nil t)))
	   ;; to beginning of OSTRING
	   (backward-char l)))))

(defun rcs-refresh-buffer (filename)
  ;; Revert FILENAME's buffer from disk.
  (let ((output-buffer (get-file-buffer filename))
	(obuf (current-buffer)))
    (if output-buffer
	;; Can't use save-excursion here, want to move point inside
	;; rcs-revert-buffer
	(unwind-protect
	    (progn
	      (set-buffer output-buffer)
	      (rcs-revert-buffer t t))
	  (set-buffer obuf)))))

(defun rcs-get-output-buffer (file &optional name)
  ;; Get a buffer for RCS output for FILE, make it writable and clean it up.
  ;; Optional NAME is name to use instead of `*RCS-output*'.
  (let* ((default-major-mode 'fundamental-mode);; no frills!
	 (buf (get-buffer-create (or name "*RCS-output*"))))
    (save-excursion
      (set-buffer buf)
      (setq buffer-read-only nil
	    default-directory (file-name-directory (expand-file-name file)))
      (erase-buffer))
    buf))

(defun rcs-error (program fname buffer)
  ;; Display BUFFER (contains output from failed commmand) and signal
  ;; an RCS error.
  (display-buffer buffer)
  (error "RCS command `%s' failed on %s" program fname))


;; Functions that know about RCS working and data files.
;; If the `,v' extension etc. ever changes, here is the place to fix it.

(defun rcs-data-file (filename)
  "Return the name of the RCS data file for FILENAME, or nil."
  (setq filename (expand-file-name filename))
  ;; Try first `RCS/FILENAME,v', then `FILENAME,v'.
  ;; In RCS 5.6 should also try `RCS/FILENAME' as last possibility, or look
  ;; at the rcs -x extension option or RCSINIT environment variable.
  (let ((rname (concat (file-name-directory filename) "RCS/"
		       (file-name-nondirectory filename) ",v")))
    (or (file-readable-p rname)
	(setq rname (concat filename ",v")))
    (and (file-readable-p rname)
	 rname)))

;; here unused, but other packages need it (e.g dired-rcs.el)
(defun rcs-working-file (filename)
  "Convert an RCS file name to a working file name.
That is, convert `...foo,v' and `...RCS/foo,v' to `...foo'.
If FILENAME doesn't end in `,v' it is returned unchanged."
  (if (not (string-match ",v$" filename))
      filename
    (setq filename (substring filename 0 -2))
    (let ((dir (file-name-directory filename)))
      (if (null dir)
	  filename
	(let ((dir-file (directory-file-name dir)))
	  (if (equal "RCS" (file-name-nondirectory dir-file))
	      ;; Working file for ./RCS/foo,v is ./foo.
	      ;; Don't use expand-file-name as this converts "" -> pwd
	      ;; and thus forces a relative FILENAME to be relative to
	      ;; the current value of default-directory, which may not
	      ;; what the caller wants.  Besides, we want to change
	      ;; FILENAME only as much as necessary.
	      (concat (file-name-directory dir-file)
		      (file-name-nondirectory filename))
	    filename))))))

(defun rcs-files (directory)
  "Return list of RCS data files for all RCS controlled files in DIRECTORY."
  (setq directory (file-name-as-directory directory))
  (let ((rcs-dir (file-name-as-directory (expand-file-name "RCS" directory)))
	(rcs-files (directory-files directory t ",v$")))
    (if (file-directory-p rcs-dir)
	(setq rcs-files
	      (append (directory-files rcs-dir t ",v$")
		      rcs-files)))
    rcs-files))

;; here unused, but other packages need it (e.g dired-rcs.el)
(defun rcs-locked-files (directory)
  "Return list of RCS data file names of all RCS-locked files in DIRECTORY."
  (let ((output-buffer (rcs-get-output-buffer directory))
	(rcs-files (rcs-files directory))
	result)
    (and rcs-files
	 (save-excursion
	   (set-buffer output-buffer)
	   (apply (function call-process) "rlog" nil t nil "-L" "-R" rcs-files)
	   (goto-char (point-min))
	   (while (not (eobp))
	     (setq result (cons (buffer-substring (point)
						  (progn (forward-line 1)
							 (1- (point))))
				result)))
	   result))))


;; Operations on RCS-controlled files (check in, check out, logs, etc.)

(defun rcs-check-out (filename &optional switches)
  "Attempt to check the specified file out using RCS.
If a prefix argument is supplied, will let you edit the `co' switches
used, defaulting to \"-l\" to check out locked.
Use \"-rREV\" or \"-lREV\" to check out specific revisions."
  ;; Returns non-nil for success, signals an error else.
  (interactive (list (rcs-read-file-name "Check out file: ")
		     (and current-prefix-arg
			  (rcs-read-switches "Switches for co: " "-l"))))
  (message "Working...")
  (setq filename (expand-file-name filename))
  (let ((output-buffer (rcs-get-output-buffer filename)))
    (delete-windows-on output-buffer)
    (save-excursion
      (set-buffer output-buffer)
      (apply 'call-process "co" nil t nil
	     ;; -q: quiet (no diagnostics)
	     (append switches rcs-default-co-switches (list "-q" filename)))
      (if (or (not (file-readable-p filename))
	      (> (buffer-size) 0))
	  (rcs-error "co" filename output-buffer)))
    (rcs-refresh-buffer filename))
  (message ""))

(defun rcs-check-in (filename switches log)
  "Attempt to check the specified file back in using RCS.
If a prefix argument is supplied, will let you edit the `ci' switches used,
with default \"-l\" switch to keep file locked.
Use \"-uREV\" or \"-lREV\" to check in as specific revision."
  (interactive (list (rcs-read-file-name "Check in file: ")
		     (and current-prefix-arg
			  (rcs-read-switches "Switches for ci: " "-l"))
		     (rcs-read-log-string "Log message: ")))
  (setq filename (expand-file-name filename))
  (setq switches (cons "-u" switches))
  ;; A "-l" in SWITCHES will override this "-u", so we can
  ;; unconditionally prepend it to SWITCHES.  We always need an
  ;; existing working file, to have something to put in the buffer
  ;; afterwards.
  (let* ((output-buffer (rcs-get-output-buffer filename))
	 (f-buffer (get-file-buffer filename)))
    (and (interactive-p)
	 f-buffer
	 (buffer-modified-p f-buffer)
	 (not (and (y-or-n-p "Save buffer first? ")
		   (save-excursion
		     (set-buffer f-buffer)
		     (save-buffer)
		     t)))
	 (not (y-or-n-p "Check in despite unsaved changes to file? "))
	 (error "Check-in aborted"))
    (message "Working...")
    (delete-windows-on output-buffer)
    (save-excursion
      (set-buffer output-buffer)
      (setq log (concat "-m" log))	; -m: log message, -q: quiet
      (apply 'call-process "ci" nil t nil
	     (append switches rcs-default-ci-switches (list log "-q" filename)))
      (if (> (buffer-size) 0)
	  (rcs-error "ci" filename output-buffer)))
    (rcs-refresh-buffer filename))
  (message ""))

(defun rcs-unlock (filename)
  "Attempt to remove your RCS lock on the specified file.
Requires confirmation if there are changes since the last checkin."
  (interactive (list (rcs-read-file-name "Unlock RCS file: ")))
  (setq filename (expand-file-name filename))
  (if (not (rcs-we-locked filename))
      (error "File was not locked to begin with"))
  (let* ((output-buffer (rcs-get-output-buffer filename))
	 (f-buffer (get-file-buffer filename))
	 (modified nil))
    ;;See if they've made any changes to the file. If so, double-check that
    ;;they want to discard them.
    (setq modified (and f-buffer (buffer-modified-p f-buffer)))
    (delete-windows-on output-buffer)
    (save-excursion
      (set-buffer output-buffer)
      (message "Examining file...")
      (call-process "rcsdiff" nil t nil filename)
      (goto-char (point-min))
      (re-search-forward "^diff +-r.*$")
      (forward-char 1)			;Skip past command itself
      (delete-region (point-min) (point)) ;Get rid of all but results
      (if modified			;There are changes to the buffer itself too.
	  (progn
	    (goto-char (point-max))
	    (insert "\nThere are unsaved changes to the buffer itself!\n"))
	(setq modified (< (point) (point-max))))
      (message "")
      (if modified
	  (display-buffer output-buffer))
      (if (and modified (not (yes-or-no-p;; not y-or-n-p since this
			      ;; gives a chance to use M-C-v to look at
			      ;; the diffs.  Also, it is safer.
			      "Discard changes made since file locked? ")))
	  (error "Unlock aborted"))
      (erase-buffer)			; clean up output buffer
      ;; -u: unlock, -q: quiet
      (call-process "rcs" nil t nil "-u" "-q" filename)
      (if (> (buffer-size) 0)
	  (rcs-error "rcs" filename output-buffer))))
  ;; Finally, check out a current copy.
  ;; -f: overwrite working file, even if it is writable (as it probably is)
  (rcs-check-out filename '("-f")))

(defun rcs-toggle-read-only ()
  "If the buffer is read-only and under RCS, adjust RCS status.
That is, make buffer writable and check file out locked for editing."
  (interactive)
  (if (and rcs-active
	   rcs-mode
	   buffer-read-only
	   buffer-file-name
	   (not (rcs-we-locked buffer-file-name rcs-mode)))
      (if (y-or-n-p "Check buffer out from RCS for edit? ")
	  (if (and (file-exists-p buffer-file-name)
		   (file-writable-p buffer-file-name))
	      (if (yes-or-no-p "\
Illegally writable copy of RCS controlled file - force checkout anyway? ")
		  (rcs-check-out buffer-file-name '("-f" "-l"))
		(error "Illegally writable copy of RCS controlled file %s"
		       buffer-file-name))
	    ;; Try to get a locked version. May error.
	    (rcs-check-out buffer-file-name '("-l")))
	(if (y-or-n-p
	     "File is RCS controlled - make buffer writable anyway? ")
	    (toggle-read-only)		; this also updates the modeline
	  (barf-if-buffer-read-only)))
    (toggle-read-only))
  (message ""))

(defun rcs-log (fname &optional switches)
  "Show the RCS log of changes for the specified file.
With an arg you can pass additional switches to the `rlog' program."
  (interactive (list (rcs-read-file-name "Show RCS log of: ")
		     (and current-prefix-arg
			  (rcs-read-switches "Switches for rlog: "))))
  (setq fname (expand-file-name fname))
  (if (not (rcs-status fname))
      (error "File is not under RCS control"))
  (save-excursion
    (let ((output-buffer (rcs-get-output-buffer fname)))
      (set-buffer output-buffer)
      (message "Requesting log...")
      (apply 'call-process "rlog" nil t nil
	     (append switches rcs-default-rlog-switches (list fname)))
      (goto-char (point-min))
      (message "")
      (display-buffer output-buffer))))

(defun rcs-diff (fname &optional switches)
  "Show the differences between current file and the last revision checked in.
With prefix arg, edit the `rcsdiff' commandline.
See also variable `rcsdiff-switches'."
  (interactive
   (list (rcs-read-file-name "Show RCS diffs for: ")
	 (if (or current-prefix-arg (listp rcsdiff-switches))
	     (rcs-read-switches "Switches for rcsdiff: "
				(if (stringp rcsdiff-switches)
				    rcsdiff-switches
				  (if (listp rcsdiff-switches)
				      (mapconcat 'identity rcsdiff-switches " ")
				    ""))))))
  (setq fname (expand-file-name fname))
  (if (not (rcs-status fname))
      (error "File is not under RCS control"))
  (or switches
      (setq switches (if (listp rcsdiff-switches)
			 rcsdiff-switches
		       (list rcsdiff-switches))))
  (let ((output-buffer (rcs-get-output-buffer fname))
	(f-buffer (get-file-buffer fname)))
    (if (and (interactive-p)
	     f-buffer
	     (buffer-modified-p f-buffer)
	     (y-or-n-p "Save file before comparing? "))
	(save-buffer))
    (save-excursion
    (set-buffer output-buffer)
    (message "Comparing files...")
    (apply 'call-process "rcsdiff" nil t nil
	   (append switches (list fname)))
    (message "Comparing files...done")
    (goto-char (point-max))		; shell-command does not drag point
    (insert (make-string 67 ?=) "\n")
    (goto-char (point-min))
    (display-buffer output-buffer))))

(defun rcs-who (directory)
  "Display list of RCS-locked files and their lockers in DIRECTORY."
  (interactive "DRcswho (directory): ")
  (or directory (setq directory default-directory))
  (setq directory (expand-file-name directory))
  (setq directory (file-name-as-directory directory))
  (let ((rcs-files (rcs-files directory)))
    (if (null rcs-files)
	(message "No RCS controlled files in %s" directory)
      (rcs-who-1 directory rcs-files))))

(defun rcs-who-1 (directory rcs-files)
  ;; Parse `rlog -L -h' output for `Working file:' and
  ;; `locks:' fields, flush the other fields.  The remaining rlog
  ;; output is presented to the user.
  ;; The -R and -L options are also understood by RCS 3 and 4, though
  ;; the output format is slightly different.  This code parses both
  ;; formats, but the output is slightly different in the case of
  ;; several lockers per file:  in V5, each locker gets a separate line.
  (save-excursion
    (let ((output-buffer (rcs-get-output-buffer directory "*RCS-who*")))
      ;; Name OUTPUT-BUFFER different from the usual RCS output buffers
      ;; since user may want to keep it around a while.  Else each RCS
      ;; command would flush it.
      (set-buffer output-buffer)
      (message "rcs-who %s..." directory)
      (apply 'call-process "rlog" nil t nil
	     "-L" "-h"			; -L: locked only, -h: head only
	     ;;"-V3" ; use this to test the code for older RCS versions
	     rcs-files)
      (goto-char (point-min))
      (if (and (not (zerop (buffer-size)))
	       (not (search-forward "Working file" nil t)))
	  (progn
	    (display-buffer output-buffer)
	    (error "Rlog error")))
      (goto-char (point-min))
      (let ((pos (point)))
	(while (re-search-forward "Working file: *" nil t)
	  (delete-region pos (point))	; flush anything before filename
	  (end-of-line 1)
	  (insert "\t")
	  (setq pos (point))
	  (if (re-search-forward "locks:[ \t\n]*\\(strict[ \t\n]*\\)?" nil t)
	      (progn
		(delete-region pos (point)))
	    (display-buffer output-buffer)
	    (error "Cannot parse this rlog format"))
	  ;; Now skip over the list of lockers.  In V5 this will be one
	  ;; line per locker, in V3 and V4 all lockers will be on the
	  ;; same line.
	  ;; In V5 the (optional) `strict' token comes before the list
	  ;; of lockers (we have already skipped over it and use the
	  ;; `access list' token as delimiter).
	  ;; In V3,4 the `strict' token comes after the list of lockers
	  ;; (skip over it now, if present).
	  ;; In any case, the `access list' terminates the lockers.
	  (re-search-forward ";[ \t\n]*strict\\|\naccess list:")
	  (goto-char (match-beginning 0))
	  (insert "\n")
	  ;; set POS so that next iteration will flush from here on
	  (setq pos (point)))
	(delete-region pos (point-max)))
      (message "")
      (if (/= 0 (buffer-size))
	  (display-buffer output-buffer)
	(message "No files locked in %s" directory)))))

;; Parsing RCS data files directly is too slow and too hard on Emacs' memory
;; usage.  A single invocation of rcs-status is OK, but not on a whole
;; directory.

;; (defun rcs-who-1-slow (directory rcs-files)
;;   (let ((output-buffer (rcs-get-output-buffer directory))
;; 	file status)
;;     (save-excursion
;;       (set-buffer output-buffer)
;;       (let (buffer-read-only)
;; 	(while rcs-files
;; 	  (setq file (car rcs-files)
;; 		rcs-files (cdr rcs-files)
;; 		status (rcs-status file))
;; 	  (if (> (length status) 0)
;; 	      (insert file
;; 		      "\t"
;; 		      status
;; 		      "\n"))))
;;       (display-buffer output-buffer))))

(if (null rcs-bind-keys)
    nil
  ;; Local maps will override this, since C-c is usually a local prefix.
  (global-set-key "\C-cD" 'rcs-diff)
  (global-set-key "\C-cI" 'rcs-check-in)
  (global-set-key "\C-cL" 'rcs-log)
  (global-set-key "\C-cO" 'rcs-check-out)
  (global-set-key "\C-cS" 'rcs-status)
  (global-set-key "\C-cU" 'rcs-unlock)
  (global-set-key "\C-cW" 'rcs-who)
  (global-set-key "\C-x\C-q" 'rcs-toggle-read-only))

(provide 'rcs)
(provide 'rcs-sk)			; there are so many RCS packages...

-------------------------- rcs-log-mode.el --------------------------
;;;   -*- Syntax: Emacs-Lisp; Mode: emacs-lisp -*-  	          	  ;;;
;;;									  ;;;

;; Stuff picket form Edward V. Simpson's rcs.el to get a nice
;; rcs-log-mode. Made stand alone to be usable with other rcs packages 
;; by Guido Bosch, 1991


(defvar rcs-log-ring " RCS Log Ring")
(defvar rcs-log-buffer "*RCS log message*")

(defvar rcs-log-other-window t
  "If t switch to other window for editing a log string.")

(defvar rcs-max-log-size 1500
  "*Maximum allowable size (chars) + 1 of an rcs log message.")



(defun rcs-get-log-string ()
  "Switch to the buffer \"*RCS log message*\" and let edit a Log string."
  (let ((buffer (get-buffer-create rcs-log-buffer)))
    (save-window-excursion
      (if rcs-log-other-window
	  (switch-to-buffer-other-window buffer)
	(switch-to-buffer buffer))
      (erase-buffer)
      (with-output-to-temp-buffer "*Help*"
	(princ (substitute-command-keys
		"\\<rcs-log-mode-map>
Enter the RCS log message.
Type \\[rcs-exit] when finished editing or \\[rcs-abort] to abort.
To step through the log message histotry, first type \\[rcs-insert-log],
then \\[rcs-next-log] and \\[rcs-previous-log] to move back and forth.")))
      (rcs-log-mode)
      (recursive-edit)
      (buffer-string))))


(defvar rcs-log-mode-map nil)
(if rcs-log-mode-map
    nil
  (setq rcs-log-mode-map (copy-keymap text-mode-map))
  (define-key rcs-log-mode-map "\C-c?" 	'describe-mode)
  (define-key rcs-log-mode-map "\C-x\e" 'rcs-insert-log)
  (define-key rcs-log-mode-map "\en" 	'rcs-next-log)
  (define-key rcs-log-mode-map "\ep" 	'rcs-previous-log)
  (define-key rcs-log-mode-map "\C-c\C-g" 'rcs-abort)
  (define-key rcs-log-mode-map "\C-c\C-c" 'rcs-exit)
  (define-key rcs-log-mode-map "\C-x\C-s" 'rcs-exit)
  (save-excursion			; initialize log ring
    (set-buffer (get-buffer-create rcs-log-ring))
    (erase-buffer)
    (make-local-variable 'page-delimiter)
    (setq page-delimiter "\f")))

(defun rcs-log-mode ()
  "Major mode for editing RCS logs (to do an rcs check-in).
Calls the value of text-mode-hook then rcs-log-mode-hook.
Like Text Mode but with these additional comands:
\\{rcs-log-mode-map}

Every time a check-in is attempted the current log message is appended to
the \"log ring.\"

Global user options:
	rcs-max-log-size	specifies the maximum allowable size
				of a log message plus one."
  (interactive)
  (use-local-map rcs-log-mode-map)
  (setq major-mode 'rcs-log-mode)
  (setq mode-name "RCS Log")
  (run-hooks 'text-mode-hook 'rcs-log-mode-hook))

 

(defun rcs-abort ()
  "Abort the recursive edit of an rcs log message."
  (interactive)
  (if (y-or-n-p "Do you really want to abort RCS logging? ")
      (abort-recursive-edit)
    (message "Continuing.")))



(defun rcs-exit ()
  "Leave the recursive edit of an rcs log message.
Append the log message to the end of the rcs log ring."
  (interactive)
  (if (< (buffer-size) rcs-max-log-size)
      (let ((min (point-min))
	    (max (point-max))
	    (rcs-log-hist (get-buffer-create rcs-log-ring)))
	(set-buffer rcs-log-hist)
	(goto-char (point-max))
	(insert-buffer-substring rcs-log-buffer min max)
	(insert-string "\f")
	(mark-page)
	(set-buffer rcs-log-buffer)
	(exit-recursive-edit)
	(bury-buffer))
    (goto-char rcs-max-log-size)
    (error
     "Log must be less than %d characters. Point is now at character %d."
     rcs-max-log-size rcs-max-log-size)))


(defun rcs-insert-log ()
  "Insert a log message from the rcs log ring at point."
  (interactive)
  (let (min max)
    (save-excursion
      (set-buffer rcs-log-ring)
      (if (= 0 (buffer-size))
	  (error "Log ring is empty.")
	(setq min (region-beginning))
	(setq max (- (region-end) 1))))
    (push-mark)
    (insert-buffer-substring rcs-log-ring min max))
)

(defun rcs-next-log ()
  "Replace the inserted log message with the next message in the log ring.
The last command must have been `rcs-insert-log,'
`rcs-next-log,' or `rcs-previous-log.'"
  (interactive)
  (if (not (equal last-command 'rcs-insert-log))
      (error "Last command was not `rcs-insert-log.'")
    (delete-region (region-beginning) (region-end))
    (set-buffer rcs-log-ring)
    (forward-page)
    (if (= (point) (point-max))
	(goto-char (point-min)))
    (mark-page)
    (set-buffer rcs-log-buffer)
    (rcs-insert-log)
    (setq this-command 'rcs-insert-log)))

(defun rcs-previous-log ()
  "Replace the inserted log message with the previous message in the log ring.
The last command must have been `rcs-insert-log,'
`rcs-next-log,' or `rcs-previous-log.'"
  (interactive)
  (if (not (equal last-command 'rcs-insert-log))
      (error "Last command was not `rcs-insert-log.'")
    (delete-region (region-beginning) (region-end))
    (set-buffer rcs-log-ring)
    (if (= (point) (point-min))
	(goto-char (point-max)))
    (backward-page)
    (mark-page)
    (set-buffer rcs-log-buffer)
    (rcs-insert-log)
    (setq this-command 'rcs-insert-log)))

--
Guido BOSCH, INRIA-Lorraine/CRIN
Institut National de Recherche en Informatique et en Automatique (INRIA)
Centre de Recherche en Informatique de Nancy (CRIN)
Campus scientifique, B.P. 239            
54506 Vandoeuvre-les-Nancy CEDEX       	
Tel.: (+33) 83.91.24.24
Fax.: (+33) 83.41.30.79                	
email: bosch@loria.fr             	

 6-Aug-92 10:24:44-GMT,5247;000000000001
Return-Path: <help-lucid-emacs-request@lucid.com>
Received: from lucid.com by banzai.cc.columbia.edu (5.59/FCB)
	id AA10102; Thu, 6 Aug 92 06:24:42 EDT
Received: from rodan.UU.NET by heavens-gate.lucid.com id AA22337g; Thu, 6 Aug 92 03:02:56 PDT
Received: from help-lucid-emacs@lucid.com (list exploder) by rodan.UU.NET 
	(5.61/UUNET-mail-drop) id AA05430; Thu, 6 Aug 92 06:12:56 -0400
Received: from news.UU.NET by rodan.UU.NET with SMTP 
	(5.61/UUNET-mail-drop) id AA05424; Thu, 6 Aug 92 06:12:54 -0400
Received: from USENET (alt.lucid-emacs.help) by news.UU.NET with InterNetNews 
	(5.61/UUNET-mail-leaf) id AA29847; Thu, 6 Aug 92 06:13:33 -0400
Path: uunet!mcsun!corton!loria!news.loria.fr!bosch
From: bosch%loria.fr@lucid.com (Guido Bosch)
Newsgroups: alt.lucid-emacs.help
Subject: enhancement for rcs-diff
Message-Id: <BOSCH.92Aug6120447@moebius.loria.fr>
Date: 6 Aug 92 10:04:47 GMT
References: <9208050749.AA14527@amil.co.il> <BOSCH.92Aug6101637@moebius.loria.fr>
Reply-To: Guido BOSCH <bosch%loria.fr@lucid.com>
Organization: INRIA-Lorraine / CRIN, Nancy, France
In-Reply-To: bosch@loria.fr's message of 6 Aug 92 08:16:37 GMT
Sender: help-lucid-emacs-request@lucid.com
To: help-lucid-emacs@lucid.com

Hi,

Here is a small enhancement of the rcs package I posted today. It
contains two patches: one for rcs.el and one for diff.el. It makes
that the output of an rcs-diff command is automatically vieved in diff
mode.

To make it work, the function `diff-mode' must be made autoloadable.

	Guido


------------------------- rcs-diff-patch -------------------------
*** rcs.el.orig		Wed Jun  3 16:35:48 1992
--- rcs.el		Thu Aug  6 11:05:37 1992
***************
*** 649,655 ****
      (goto-char (point-max))		; shell-command does not drag point
      (insert (make-string 67 ?=) "\n")
      (goto-char (point-min))
!     (display-buffer output-buffer))))
  
  (defun rcs-who (directory)
    "Display list of RCS-locked files and their lockers in DIRECTORY."
--- 649,656 ----
      (goto-char (point-max))		; shell-command does not drag point
      (insert (make-string 67 ?=) "\n")
      (goto-char (point-min))
!     (display-buffer output-buffer)
!     (if (fboundp 'diff-mode) (diff-mode)))))
  
  (defun rcs-who (directory)
    "Display list of RCS-locked files and their lockers in DIRECTORY."





-------------------------- diff-mode-patch --------------------------
*** diff.el.orig	Thu Aug  6 11:01:28 1992
--- diff.el		Thu Aug  6 11:18:06 1992
***************
*** 18,23 ****
--- 18,29 ----
  ;; along with GNU Emacs; see the file COPYING.  If not, write to
  ;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
  
+ ;; The function `diff-mode' can be used to examin diff output in a buffer
+ ;; (patches, e.g.). 
+ ;; To do this, put 
+ ;; 	(autoload 'diff-mode "diff" "Major mode to view diff output." t)
+ ;; in your .emacs or default.el. 
+ 
  ;; todo: diff-switches flexibility:
  ;; (defconst diff-switches-function
  ;;   '(lambda (file)
***************
*** 91,104 ****
  	  ;; strip leading filenames from context diffs
  	  (progn (forward-line 2) (delete-region (point-min) (point))))
        (setq sw (cdr sw))))
!   (diff-mode)
!   (if (string= "0" diff-total-differences)
!       (insert (message "There are no differences."))
!     (narrow-to-region (point) (progn
! 				(forward-line 1)
! 				(re-search-forward diff-search-pattern nil)
! 				(goto-char (match-beginning 0))))
!     (setq diff-current-difference "1")))
  
  ;; Take a buffer full of Unix diff output and go into a mode to easily 
  ;; see the next and previous difference
--- 97,103 ----
  	  ;; strip leading filenames from context diffs
  	  (progn (forward-line 2) (delete-region (point-min) (point))))
        (setq sw (cdr sw))))
!   (diff-mode))
  
  ;; Take a buffer full of Unix diff output and go into a mode to easily 
  ;; see the next and previous difference
***************
*** 123,129 ****
  	'(" " diff-current-difference "/" diff-total-differences))
    (make-local-variable 'diff-current-difference)
    (set (make-local-variable 'diff-total-differences)
!        (int-to-string (diff-count-differences))))
  
  (defun diff-next-difference (n)
    "In diff-mode go the the beginning of the next difference as delimited
--- 122,135 ----
  	'(" " diff-current-difference "/" diff-total-differences))
    (make-local-variable 'diff-current-difference)
    (set (make-local-variable 'diff-total-differences)
!        (int-to-string (diff-count-differences)))
!   (if (string= "0" diff-total-differences)
!       (insert (message "There are no differences."))
!     (narrow-to-region (point) (progn
! 				(forward-line 1)
! 				(re-search-forward diff-search-pattern nil)
! 				(goto-char (match-beginning 0))))
!     (setq diff-current-difference "1")))
  
  (defun diff-next-difference (n)
    "In diff-mode go the the beginning of the next difference as delimited




--
Guido BOSCH, INRIA-Lorraine/CRIN
Institut National de Recherche en Informatique et en Automatique (INRIA)
Centre de Recherche en Informatique de Nancy (CRIN)
Campus scientifique, B.P. 239            
54506 Vandoeuvre-les-Nancy CEDEX       	
Tel.: (+33) 83.91.24.24
Fax.: (+33) 83.41.30.79                	
email: bosch@loria.fr             	

 6-Aug-92 10:48:06-GMT,2744;000000000001
Return-Path: <help-lucid-emacs-request@lucid.com>
Received: from lucid.com by banzai.cc.columbia.edu (5.59/FCB)
	id AA10110; Thu, 6 Aug 92 06:47:35 EDT
Received: from rodan.UU.NET by heavens-gate.lucid.com id AA22365g; Thu, 6 Aug 92 03:18:43 PDT
Received: from help-lucid-emacs@lucid.com (list exploder) by rodan.UU.NET 
	(5.61/UUNET-mail-drop) id AA08449; Thu, 6 Aug 92 06:28:39 -0400
Received: from news.UU.NET by rodan.UU.NET with SMTP 
	(5.61/UUNET-mail-drop) id AA07906; Thu, 6 Aug 92 06:25:37 -0400
Received: from USENET (alt.lucid-emacs.help) by news.UU.NET with InterNetNews 
	(5.61/UUNET-mail-leaf) id AA00167; Thu, 6 Aug 92 06:26:14 -0400
Path: uunet!mcsun!uknet!edcastle!dltest
From: dltest@castle.ed.ac.uk (Kevin Davidson)
Newsgroups: alt.lucid-emacs.help
Subject: Newer rcs-sk.el (was Re: reading changed files)
Message-Id: <24582@castle.ed.ac.uk>
Date: 6 Aug 92 10:18:46 GMT
References: <9208050749.AA14527@amil.co.il> <BOSCH.92Aug6101637@moebius.loria.fr>
Organization: Edinburgh University
Sender: help-lucid-emacs-request@lucid.com
To: help-lucid-emacs@lucid.com

In article <BOSCH.92Aug6101637@moebius.loria.fr> bosch@loria.fr (Guido Bosch) writes:
|In article <9208050749.AA14527@amil.co.il> danny@amil.co.il (Danny Bar-Dov) writes:
| > [looking for rcs-mode]
|
|There are a lot of rcs-modes for GNU Emacs out there (too many, after
|my opinion). I played around with most of them and found the one of
|Sebastian Kremer most satisfactory for my needs (not to big, the command
|key bindings are not interferring with other modes)
|

|;; LISPDIR ENTRY for the Elisp Archive ===============================
|;;    LCD Archive Entry:
|;;    rcs|Sebastian Kremer|sk@thp.uni-koeln.de
|;;    |RCS interface for GNU Emacs
|;;    |$Date: 1992/02/10 10:29:26 $|$Revision: 1.55 $|
|
.....
|
|(defconst rcs-version  (substring "$Revision: 1.55 $" 11 -2)
|  "$Id: rcs.el,v 1.55 1992/02/10 10:29:26 sk Exp $
|

Is it wise to post this ? The version I have is:

;; LISPDIR ENTRY for the Elisp Archive ===============================
;;    LCD Archive Entry:
;;    rcs|Sebastian Kremer|sk@thp.uni-koeln.de
;;    |Simple yet flexible RCS interface for GNU Emacs
;;    |$Date: 1992/05/15 14:09:27 $|$Revision: 1.67 $|

...
(defconst rcs-version  (substring "$Revision: 1.67 $" 11 -2)
  "$Id: rcs.el,v 1.67 1992/05/15 14:09:27 sk Exp $
...

  Perhaps someone else can say what's changed.

|--
|Guido BOSCH, INRIA-Lorraine/CRIN
|Institut National de Recherche en Informatique et en Automatique (INRIA)
|Centre de Recherche en Informatique de Nancy (CRIN)
|Campus scientifique, B.P. 239            
|54506 Vandoeuvre-les-Nancy CEDEX       	
|Tel.: (+33) 83.91.24.24
|Fax.: (+33) 83.41.30.79                	
|email: bosch@loria.fr             	

