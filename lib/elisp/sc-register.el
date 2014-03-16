;; -*- Emacs-Lisp -*-
;;
;; File: sc-register.el
;; version 3.0
;;
(defconst sc-register-RCS-id
  "$Id: sc-register.el,v 1.16 1993/09/28 06:56:08 yoichi Exp $"
  "*Current RCS-id of sc-register")

;;; Copyright (C) 1990-1993  Yoichi HIROSE.
;;;
;;; Author: Yoichi HIROSE (yoichi@esasd.ksp.fujixerox.co.jp)
;;;
;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 1, or (at your option)
;;; any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

(provide 'sc-register)

(defvar sc-registered-name-alist nil
  "*Alist of the pair of mail addresses and registered citation strings.")

(defvar sc-registered-name-alist-modified nil
  "*Non-nil if sc-registered-name-alist has changed in the current emacs
session and not saved yet.")

(defvar sc-registered-name-alist-file (expand-file-name "~/.scrc.el")
  "*The file name to save the registered addresses and the citation string.
The data will be stored in a lisp form sorted by the mail address to make it
easy to edit by hand.")

(if (file-exists-p sc-registered-name-alist-file) (load sc-registered-name-alist-file))

(if (not (fboundp 'sc-register-original-kill-emacs))
    (fset 'sc-register-original-kill-emacs (symbol-function 'kill-emacs)))

(defun kill-emacs (&optional arg)
  "sc-register has overwritten kill-emacs.
Plese refer to sc-register-kill-emacs."
  (interactive "P")
  (sc-register-save-registered-name-alist)
  (sc-register-original-kill-emacs arg))

(defun sc-register-new-name (name)
  "Register NAME associated with the current sc-mail-info's
\"sc-from-address\" if required."
  (let* ((from (cdr (assoc "sc-from-address" sc-mail-info)))
	 (registered (assoc from sc-registered-name-alist)))
    (if registered
	(if (not (string= name (cdr registered)))
	    (if (y-or-n-p "override previous registration? ")
		(and (setcdr registered name)
		     (setq sc-registered-name-alist-modified t))))
      (if (y-or-n-p "register new name? ")
	  (setq sc-registered-name-alist
		(cons (cons from name) sc-registered-name-alist)
		sc-registered-name-alist-modified t)))))

(defun sc-register-save-registered-name-alist ()
  "Save sc-registered-name-alist into a file specified by
sc-registered-name-alist-file if needed."
  (interactive)
  (if sc-registered-name-alist-modified
      (progn
	(set-buffer (get-buffer-create "*sc-alist*"))
	(message "Saving %s..." sc-registered-name-alist-file)
	(erase-buffer)
	(mapcar '(lambda (l)
		   (insert (prin1-to-string l) "\n"))
		sc-registered-name-alist)
	(sort-lines nil (point-min) (point-max))
	(goto-char (point-min))
	(insert "(setq sc-registered-name-alist '(\n")
	(goto-char (point-max))
	(insert "))\n")
	(write-file sc-registered-name-alist-file)
	(kill-buffer (current-buffer))
	(message "Saving %s... Done" sc-registered-name-alist-file)
	(setq sc-registered-name-alist-modified nil))
    (message "No changes to be saved")))

(defun sc-select-attribution ()
  "Select an attribution from `sc-attributions'.

Variables involved in selection process include:
     `sc-preferred-attribution-list'
     `sc-use-only-preference-p'
     `sc-confirm-always-p'
     `sc-default-attribution'
     `sc-attrib-selection-list'.

Runs the hook `sc-attribs-preselect-hook' before selecting an
attribution and the hook `sc-attribs-postselect-hook' after making the
selection but before querying is performed.  During
`sc-attribs-postselect-hook' the variable `citation' is bound to the
auto-selected citation string and the variable `attribution' is bound
to the auto-selected attribution string.

This function is modified for sc-register."
  (run-hooks 'sc-attribs-preselect-hook)
  (let ((query-p sc-confirm-always-p)
	attribution citation
	(attriblist sc-preferred-attribution-list))

    ;; first cruise through sc-preferred-attribution-list looking for
    ;; a match in either sc-attributions or sc-mail-info.  if the
    ;; element is "sc-consult", then we have to do the alist
    ;; consultation phase
    (while attriblist
      (let* ((preferred (car attriblist)))
	(cond
	 ((string= preferred "sc-consult")
	  ;; we've been told to consult the attribution vs. mail
	  ;; header key alist.  we do this until we find a match in
	  ;; the sc-attrib-selection-list.  if we do not find a match,
	  ;; we continue scanning attriblist
	  (let ((attrib (sc-scan-info-alist sc-attrib-selection-list)))
	    (cond
	     ((not attrib)
	      (setq attriblist (cdr attriblist)))
	     ((stringp attrib)
	      (setq attribution attrib
		    attriblist nil))
	     ((listp attrib)
	      (setq attribution (eval attrib)
		    attriblist nil))
	     (t (error "%s did not evaluate to a string or list!"
		       "sc-attrib-selection-list"))
	     )))
	 ((setq attribution (cdr (assoc preferred sc-attributions)))
	  (setq attriblist nil))
	 (t
	  (setq attriblist (cdr attriblist)))
	 )))

    ;; if preference was not found, we may use a secondary method to
    ;; find a valid attribution
    (if (and (not attribution)
	     (not sc-use-only-preference-p))
	;; secondary method tries to find a preference in this order
	;; 1. sc-lastchoice
	;; 2. x-attribution
	;; 3. firstname
	;; 4. lastname
	;; 5. initials
	;; 6. first non-empty attribution in alist
	(setq attribution
	      (or (cdr (assoc "sc-lastchoice" sc-attributions))
		  (cdr (assoc "x-attribution" sc-attributions))
		  (cdr (assoc "firstname" sc-attributions))
		  (cdr (assoc "lastname" sc-attributions))
		  (cdr (assoc "initials" sc-attributions))
		  (cdr (car sc-attributions)))))

    ;; still couldn't find an attribution. we're now limited to using
    ;; the default attribution, but we'll force a query when this happens
    (if (not attribution)
	(setq attribution sc-default-attribution
	      query-p t))

    ;; create the attribution prefix
    (setq citation (sc-make-citation attribution))

    ;; run the post selection hook before querying the user
    (run-hooks 'sc-attribs-postselect-hook)

    ;; query for confirmation
    (if query-p
	(let* ((query-alist (mapcar (function (lambda (entry)
						(list (cdr entry))))
				    sc-attributions))
	       (minibuffer-local-completion-map
		sc-minibuffer-local-completion-map)
	       (minibuffer-local-map sc-minibuffer-local-map)
	       (initial attribution)
	       (completer-disable t)	; in case completer.el is used
	       choice)
	  (setq sc-attrib-or-cite nil)	; nil==attribution, t==citation
	  (while
	      (catch 'sc-reconfirm
		(string= "" (setq choice
				  (if sc-attrib-or-cite
				      (sc-read-string
				       "Enter citation prefix: "
				       citation
				       'sc-citation-confirmation-history)
				    (sc-completing-read
				     "Complete attribution name: "
				     query-alist nil nil
				     (cons initial 0)
				     'sc-attribution-confirmation-history)
				    )))))
	  ; added by Y.Hirose for sc-register
	  (if (not (assoc choice query-alist))
	      (sc-register-new-name choice))
	  ; end addition
	  (if sc-attrib-or-cite
	      ;; since the citation was chosen, we have to guess at
	      ;; the attribution
	      (setq citation choice
		    attribution (or (sc-guess-attribution citation)
				    citation))
	    
	    (setq citation (sc-make-citation choice)
		  attribution choice))
	  ))

    ;; its possible that the user wants to downcase the citation and
    ;; attribution
    (if sc-downcase-p
	(setq citation (downcase citation)
	      attribution (downcase attribution)))

    ;; set up mail info alist
    (let* ((ckey "sc-citation")
	   (akey "sc-attribution")
	   (ckeyval (assoc ckey sc-mail-info))
	   (akeyval (assoc akey sc-mail-info)))
      (if ckeyval
	  (setcdr ckeyval citation)
	(setq sc-mail-info
	      (append (list (cons ckey citation)) sc-mail-info)))
      (if akeyval
	  (setcdr akeyval attribution)
	(setq sc-mail-info
	      (append (list (cons akey attribution)) sc-mail-info))))

    ;; set the sc-lastchoice attribution
    (let* ((lkey "sc-lastchoice")
	   (lastchoice (assoc lkey sc-attributions)))
      (if lastchoice
	  (setcdr lastchoice attribution)
	(setq sc-attributions
	      (cons (cons lkey attribution) sc-attributions))))
    ))

(defun sc-attribs-chop-address (from)
  "Extract attribution information from FROM.
This populates the `sc-attributions' with the list of possible attributions.

This function is modified for sc-register"
  (if (and (stringp from)
	   (< 0 (length from)))
      (let* ((sc-mail-mumble "")	     
	     (namestring (sc-attribs-extract-namestring from))
	     (namelist   (sc-attribs-filter-namelist
			  (sc-attribs-chop-namestring namestring)))
	     (revnames   (reverse (cdr namelist)))
	     (firstname  (car namelist))
	     (midnames   (reverse (cdr revnames)))
	     (lastname   (car revnames))
	     (initials   (sc-attribs-strip-initials namelist))
	     (emailname  (sc-attribs-emailname from))
	     (n 1)
	     author middlenames)
    
	;; put basic information
	(setq
	 ;; put middle names and build sc-author entry
	 middlenames (mapconcat
		      (function
		       (lambda (midname)
			 (let ((key-attribs (format "middlename-%d" n))
			       (key-mail    (format "sc-middlename-%d" n)))
			   (setq
			    sc-attributions (cons (cons key-attribs midname)
						  sc-attributions)
			    sc-mail-info (cons (cons key-mail midname)
					       sc-mail-info)
			    n (1+ n))
			   midname)))
		      midnames " ")

	 author (concat firstname " " middlenames (and midnames " ") lastname)

	 sc-attributions (append
			  (list
			   (cons "firstname"   firstname)
			   (cons "lastname"    lastname)
			   (cons "emailname"   emailname)
			   (cons "initials"    initials))
			  sc-attributions)
	 sc-mail-info (append
		       (list
			(cons "sc-firstname"   firstname)
			(cons "sc-middlenames" middlenames)
			(cons "sc-lastname"    lastname)
			(cons "sc-emailname"   emailname)
			(cons "sc-initials"    initials)
			(cons "sc-author"      author)
			(cons "sc-from-address" (sc-get-address
						 (sc-mail-field "from")
						 namestring))
			(cons "sc-reply-address" (sc-get-address
						  (sc-mail-field "reply-to")
						  namestring))
			(cons "sc-sender-address" (sc-get-address
						   (sc-mail-field "sender")
						   namestring))
			)
		       sc-mail-info)
	 ; added by Y.Hirose for sc-register
	 )
	(let ((registered (cdr (assoc (cdr (assoc "sc-from-address" sc-mail-info))
				      sc-registered-name-alist))))
	  (if registered
	      (setq sc-attributions (cons (cons "registered" registered) sc-attributions)
		    sc-mail-info (cons (cons "sc-registered" registered) sc-mail-info))))
	; addition end
	)
    ;; from string is empty
    (setq sc-mail-info (cons (cons "sc-author" sc-default-author-name)
			     sc-mail-info))))

