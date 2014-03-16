Article 277 of comp.emacs:
Relay-Version: version B 2.10.3 4.3bsd-beta 6/6/85; site cucca.UUCP
Path: cucca!columbia!seismo!gatech!cuae2!ihnp4!inuxc!pur-ee!yoder
From: yoder@pur-ee.UUCP (Mark A. Yoder)
Newsgroups: comp.emacs
Subject: Re: rcs.el for GNU Emacs 17.64
Message-ID: <5217@pur-ee.UUCP>
Date: 9 Jan 87 20:11:03 GMT
Date-Received: 10 Jan 87 14:19:03 GMT
References: <9023@duke.duke.UUCP>
Reply-To: yoder@pur-ee.UUCP (Mark A. Yoder)
Organization: Electrical Engineering Department , Purdue University
Lines: 61


Ed Simpson's emacs/RCS provides a nice method for checking files into RCS
from emacs.  The following function complements his routines
nicely in that it provides a nice way to automatically checkout files.

These is function uses the find-file-not-found-hooks in version 18
(or find-file-not-found-hook in version 17).  When (find-file) cannot
find a given file the (my-RCS-file) function will look to see if there is
an RCS version of the file.  If so, it will ask if it should be checked
and if it should be locked.  If is is not locked, the file will be checked
out and read into a buffer and then deleted.  

This works nicely with TAGS if you run etags on all your files before checking
them in.

Put the following in your .emacs file:

(setq find-file-not-found-hooks '(my-RCS-file))

The load the following into emacs:

;;;
;;; The following uses the find-file-not-found-hook to look for a file
;;; in the RCS directory.  If a file isn't found, RCS/filename,v is
;;; first checked, and then filename,v is checked to see if the file
;;; checked into RCS.  If it is not found, my-RCS-file does nothing.
;;; If it is found, the user is asked if they want to check the file out,
;;; and if they want it locked.

(defun my-RCS-file ()
        ;; Set dir to the directory the file is to be in.
  (let ((dir  (substring filename 0 (my-string-match "[^/]*$" filename)))
	;; Set file to the filename name of the file excluding the path.
	(file (substring filename (my-string-match "[^/]*$" filename))))
    ;; Look for the RCS file
    (if (or
	 (file-exists-p (concat dir "RCS/" file ",v"))
	 (file-exists-p (concat filename ",v")))
	;; if found, ask the user if they want it checked out.
      (if (y-or-n-p (message "Can't find \"%s\", shall I check it out? "
			     file))
	  ;; If it is to be check out, ask about locking it.
	  (progn
	    (if (y-or-n-p "Shall I lock it? ")
		;; Check the file out, but don't send input to "co", or
		;; read the output from co.  This could cause problems
		;; if "co" couldn't check the file out.
		(call-process "co" nil nil nil "-l" filename)
	      (call-process "co" nil nil nil filename))
	    ;; If the file is now there, read it in
	    (if (file-exists-p filename)
		(progn
		  (insert-file-contents filename t)
		  (setq error nil))))))))

;;; This is a hack so that if there are no /'s in the filename, 0 is returned
(defun my-string-match (pattern str)
  (let ((index (string-match pattern str)))
    (if index
	index
      0)))


