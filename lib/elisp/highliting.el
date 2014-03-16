 3-Aug-92 23:01:54-GMT,6689;000000000001
Return-Path: <help-lucid-emacs-request@lucid.com>
Received: from lucid.com by banzai.cc.columbia.edu (5.59/FCB)
	id AA06802; Mon, 3 Aug 92 19:01:45 EDT
Received: from rodan.UU.NET by heavens-gate.lucid.com id AA11000g; Mon, 3 Aug 92 15:36:20 PDT
Received: from help-lucid-emacs@lucid.com (list exploder) by rodan.UU.NET 
	(5.61/UUNET-mail-drop) id AA15091; Mon, 3 Aug 92 18:46:18 -0400
Received: from news.UU.NET by rodan.UU.NET with SMTP 
	(5.61/UUNET-mail-drop) id AA12546; Mon, 3 Aug 92 18:40:14 -0400
Received: from USENET (alt.lucid-emacs.help) by news.UU.NET with InterNetNews 
	(5.61/UUNET-mail-leaf) id AA16590; Mon, 3 Aug 92 18:40:21 -0400
Path: uunet!mcsun!uknet!edcastle!edcogsci!cogsci!rjc
From: rjc@cogsci.ed.ac.uk (Richard Caley)
Newsgroups: alt.lucid-emacs.help
Subject: Highlight lisp code
Message-Id: <RJC.92Aug3191718@daiches.cogsci.ed.ac.uk>
Date: 3 Aug 92 18:17:18 GMT
Distribution: alt
Organization: Human Communication Research Center
Sender: help-lucid-emacs-request@lucid.com
To: help-lucid-emacs@lucid.com
Status: O


Here is a different aproach to highlighting lisp code. It hooks into
the indentation functions of (emacs-)lisp-mode and so will highlight
code as it is typed in, so long as you indent it. It doesn't notice
forms which are entirely on one line though.

highlight-lisp-buffer is something to put into emacs-lisp-mode-hook to
do the highlighting on the entire buffer when you start.

 --- 8< --- 8< --- 8< --- CUT HERE  --- 8< --- 8< --- 8< ---

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;                                                                  ;;
 ;; Code to make lisp and elisp modes highlight special forms.       ;;
 ;;                                                                  ;;
 ;;                 R.Caley@ed.ac.uk                                 ;;
 ;;                                                                  ;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; 
 ;; $Log: highlight-lisp.el,v $
 ;; Revision 1.1  1992/08/03  18:10:10  rjc
 ;; Initial revision
 ;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(put 'defun 'lisp-face 'bold)
(put 'lambda 'lisp-face 'bold)
(put 'progn 'lisp-face 'bold)
(put 'prog1 'lisp-face 'bold)
(put 'prog2 'lisp-face 'bold)
(put 'save-excursion 'lisp-face 'bold)
(put 'save-window-excursion 'lisp-face 'bold)
(put 'save-restriction 'lisp-face 'bold)
(put 'let 'lisp-face 'bold)
(put 'let* 'lisp-face 'bold)
(put 'while 'lisp-face 'bold)
(put 'if 'lisp-face 'bold)
(put 'catch 'lisp-face 'bold)
(put 'condition-case 'lisp-face 'bold)
(put 'unwind-protect 'lisp-face 'bold)
(put 'with-output-to-temp-buffer 'lisp-face 'bold)
(put 'comment 'lisp-face 'italic)

;; the following is a version of lisp-indent-fucntion from
;; lisp-mode.el which looks to see if the form we are indenting
;; is a special form with a face defined as above.

(defun lisp-highlighting-indent-function (indent-point state &optional dont)
  (let ((normal-indent (current-column)))
    (goto-char (1+ (elt state 1)))
    (parse-partial-sexp (point) last-sexp 0 t)
    (if (and (elt state 2)
             (not (looking-at "\\sw\\|\\s_")))
        ;; car of form doesn't seem to be a a symbol
        (progn
          (if (not (> (save-excursion (forward-line 1) (point))
                      last-sexp))
              (progn (goto-char last-sexp)
                     (beginning-of-line)
                     (parse-partial-sexp (point) last-sexp 0 t)))
	  ;; Indent under the list or under the first sexp on the
          ;; same line as last-sexp.  Note that first thing on that
          ;; line has to be complete sexp since we are inside the
          ;; innermost containing sexp.
          (backward-prefix-chars)
          (current-column))
      (let* ((start (point))
	     (end   (progn (forward-sexp 1) (point)))
	     (function (buffer-substring start end))
	     method face)
	(setq method (get (intern-soft function) 'lisp-indent-function))
	(setq face (get (intern-soft function) 'lisp-face))
	(if face
	    (let ((extent (extent-at start)))
	      (if (not (and extent 
			    (eq (extent-start-position extent) start)
			    (eq (extent-end-position extent) end)
			    ))
		  (setq extent (make-extent start end))
		)
	      (set-extent-face extent face)
	      )
	  )
	(if (not dont)
	    (cond ((or (eq method 'defun)
		   (and (null method)
			(> (length function) 3)
			(string-match "\\`def" function)))
	       (lisp-indent-defform state indent-point))
	      ((integerp method)
	       (lisp-indent-specform method state
				     indent-point normal-indent))
	      (method
	       (funcall method state indent-point)))
	  )
	))))


(defun lisp-indent-line (&optional whole-exp)
  "Indent current line as Lisp code.
With argument, indent any additional lines of the same expression
rigidly along with this one."
  (interactive "P")
  (let ((indent (calculate-lisp-indent)) shift-amt beg end
	(pos (- (point-max) (point))))
    (beginning-of-line)
    (setq beg (point))
    (skip-chars-forward " \t")
    (if (looking-at "\\s<\\s<\\s<")
	;; Don't alter indentation of a ;;; comment line.
	nil
      (if (looking-at "\\s<")
	  ;; comment lines should be indented as comment lines
	  (progn (indent-for-comment) (forward-char -1))
	(if (listp indent) (setq indent (car indent)))
	(setq shift-amt (- indent (current-column)))
	(if (zerop shift-amt)
	    nil
	  (delete-region beg (point))
	  (indent-to indent)))
      ;; If initial point was within line's indentation,
      ;; position after the indentation.  Else stay at same point in text.
      (if (> (- (point-max) pos) (point))
	  (goto-char (- (point-max) pos)))
      ;; If desired, shift remaining lines of expression the same amount.
      (and whole-exp (not (zerop shift-amt))
	   (save-excursion
	     (goto-char beg)
	     (forward-sexp 1)
	     (setq end (point))
	     (goto-char beg)
	     (forward-line 1)
	     (setq beg (point))
	     (> end beg))
	   (indent-code-rigidly beg end shift-amt)))))
  

(defun highlight-lisp-buffer ()

  (interactive)

  (message "Highlighting")
  (save-excursion
    (let (line state (last-sexp 0 ))
      (beginning-of-buffer)
      (while (not (eobp))
	(setq line (save-excursion (next-line 1) (beginning-of-line) (point)))
	(setq state (parse-partial-sexp (point) line nil nil state))
	(setq last-sexp (nth 2 state))
	(if (and last-sexp (nth 1 state))
	    (lisp-highlighting-indent-function line state t)
	  )
	)
      )
    )
  (message "... done")
  )


 --- 8< --- 8< --- 8< --- CUT HERE  --- 8< --- 8< --- 8< ---

