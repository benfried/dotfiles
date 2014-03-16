 1-Sep-92  4:58:30-GMT,18233;000000000001
Return-Path: <help-lucid-emacs-request@lucid.com>
Received: from lucid.com by banzai.cc.columbia.edu (5.59/FCB)
	id AA05950; Tue, 1 Sep 92 00:58:25 EDT
Received: by heavens-gate.lucid.com id AA12313g; Mon, 31 Aug 92 21:41:05 PDT
Received: from thalidomide.lucid ([192.31.212.116]) by heavens-gate.lucid.com id AA12309g; Mon, 31 Aug 92 21:40:47 PDT
Received: by thalidomide.lucid (4.1/SMI-4.1)
	id AA24434; Mon, 31 Aug 92 21:50:25 PDT
Date: Mon, 31 Aug 92 21:50:25 PDT
Message-Id: <9209010450.AA24434@thalidomide.lucid>
X-Windows: The joke that kills.
From: Jamie Zawinski <jwz@lucid.com>
Sender: jwz%thalidomide@lucid.com
To: help-lucid-emacs@lucid.com
Subject: electric font lock mode

Here's a little something I hacked up last night.  It's really way too slow
to use, but if most of it were ported to C, it would probably be acceptably
fast.  (Imagine using an emacs-lisp implementation of forward-sexp...)

Doing M-x font-lock-fontify-buffer on a 35k file of C code takes about a
minute on a Sparc2.  Do M-x electric-font-lock-mode to make it auto-fontify
what you type.  This can *almost* keep up with my typing, but not quite.

Also I think that the fontification of keywords that it does by default is
really gaudy, but I wanted to see how fast that would be.

	-- Jamie

---------- slice 'n' dice --------------------------------- file: font-lock.el
;; Electric Font Lock Mode.  Yow.
;; Copyright (C) 1992 Free Software Foundation, Inc.

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;; Electric-font-lock-mode is a minor mode that causes your comments to
;; be displayed in one font, strings in another, reserved words in another,
;; etc.  Actually, it works with any display attributes, not just fonts, 
;; but the name is what it is for historical continuity...

;; Comments will be displayed in `font-lock-comment-face'.
;; Strings will be displayed in `font-lock-string-face'.
;; Function and variable names in their defining forms will be displayed
;;  in `font-lock-function-name-face'.
;; Reserved words will be displayed in `font-lock-keyword-face'.
;;
;; To initially fontify the buffer, use M-x font-lock-fontify-buffer.
;; The fonts of the current line will be updated with every insertion or
;; deletion.
;;
;; To make the text you type be fontified, use M-x electric-font-lock-mode.
;;
;; To define new reserved words or other patterns to highlight, use the
;; `font-lock-keywords' variable.

(or (find-face 'font-lock-comment-face)
    (make-face 'font-lock-comment-face))
(or (face-differs-from-default-p 'font-lock-comment-face)
    (copy-face 'italic 'font-lock-comment-face))

(or (find-face 'font-lock-string-face)
    (make-face 'font-lock-string-face))
(or (face-differs-from-default-p 'font-lock-string-face)
    (copy-face 'italic 'font-lock-string-face))

(or (find-face 'font-lock-doc-string-face)
    (make-face 'font-lock-doc-string-face))
(or (face-differs-from-default-p 'font-lock-doc-string-face)
    (copy-face 'bold-italic 'font-lock-doc-string-face))

(or (find-face 'font-lock-function-name-face)
    (make-face 'font-lock-function-name-face))
(or (face-differs-from-default-p 'font-lock-function-name-face)
    (copy-face 'bold-italic 'font-lock-function-name-face))

(or (find-face 'font-lock-keyword-face)
    (make-face 'font-lock-keyword-face))
(or (face-differs-from-default-p 'font-lock-keyword-face)
    (copy-face 'bold 'font-lock-keyword-face))


(defvar font-lock-keywords nil
  "*The keywords to highlight.
If this is a list, then elements may be of the forms:
  \"string\"			 ; a regexp to highlight in the 
				 ;  `font-lock-keyword-face'.
  (\"string\" . integer)	 ; match N of the regexp will be highlighted
  (\"string\" . face-name)	 ; use the named face
  (\"string\" integer face-name) ; both of the above")

(defvar font-lock-keywords-case-fold-search nil
  "*Whether the strings in `font-lock-keywords' should be case-folded.")


;;; These variables are the cache (and outputs) of font-lock-find-context.
;;; The last point computed is held in the cache, as well as the last
;;; point at the beginning of a line that was computed.  This makes there
;;; be little penalty for moving left-to-right on a line a character at a 
;;; time; makes starting over on a line be cheap; and makes random-accessing
;;; within a line relatively cheap.  
;;;
;;; When we move to a different line farther down in the file (but within the
;;; current top-level form) we simply continue computing forward.  If we move
;;; backward more than a line, or move beyond the end of the current tlf, or
;;; do a deletion, then we call `beginning-of-defun' and start over from there.
;;;
;;; To fontify the whole buffer, we just go through it a character at a time,
;;; and create new extents when necessary (the extents we create span lines.)
;;;
;;; Each time a modification happens to a line, we remove all of the extents
;;; on that line (splitting line-spanning extents as necessary) and recompute
;;; the contexts for every character on the line.  This means that, as the
;;; user types, we repeatedly go back to the begnning of the line, doing more
;;; work the longer the line gets.  
;;;
;;; We redo the whole line because that's a lot easier than dealing with the
;;; hair of modifying possibly-overlapping extents, and extents whose 
;;; endpoints were moved by the insertion we are reacting to.
;;;
;;; Extents as they now exist are not a good fit for this project, because
;;; extents talk about properties of *regions*, when what we want to talk
;;; about here are properties of *characters*.  
;;;
;;; This is way too slow, but is a decent prototype; if this were 
;;; reimplemented in C, I think it could be usably fast.

(defvar font-lock-context nil)
(defvar font-lock-context-start-marker nil)
(defvar font-lock-context-end nil)
(defvar font-lock-context-depth nil)
(defvar font-lock-backslash-p nil)
(defvar font-lock-comment-context nil)
(defvar font-lock-string-context nil)

(defvar font-lock-bol-context nil)
(defvar font-lock-bol-context-start-marker nil)
(defvar font-lock-bol-context-end nil)
(defvar font-lock-bol-context-depth nil)
(defvar font-lock-bol-backslash-p nil)
(defvar font-lock-bol-comment-context nil)
(defvar font-lock-bol-string-context nil)

(defun font-lock-flush-cache ()
  (if font-lock-context-start-marker
      (progn
	(set-marker font-lock-context-start-marker nil)
	(set-marker font-lock-bol-context-start-marker nil)
	(setq font-lock-context-start-marker nil
	      font-lock-bol-context-start-marker nil))))


(defsubst font-lock-char-syntax-code (char)
  (ash (aref (syntax-table) char) -16))
(defsubst font-lock-comment-start1-p (code) (/= 0 (logand 1 code)))
(defsubst font-lock-comment-start2-p (code) (/= 0 (logand 2 code)))
(defsubst font-lock-comment-end1-p (code) (/= 0 (logand 4 code)))
(defsubst font-lock-comment-end2-p (code) (/= 0 (logand 8 code)))

(defun font-lock-find-context ()
  (let ((target (point))
	(do-bod (or (null font-lock-context-start-marker)
		    (> (point) font-lock-context-end)
		    (not (eq (current-buffer)
			     (marker-buffer
			      font-lock-context-start-marker)))))
	syntax)
    (if (or do-bod (< (point) font-lock-context-start-marker))
	(if (or do-bod (< (point) font-lock-bol-context-start-marker))
	    ;; we need to start over at the current defun.
	    (progn
	      (beginning-of-defun)
	      (if font-lock-context-start-marker
		  (move-marker font-lock-context-start-marker (point))
		(setq font-lock-context-start-marker (point-marker)
		      font-lock-bol-context-start-marker (point-marker)
		      ))
	      (setq font-lock-context-end (save-excursion
					    (re-search-forward "\n\\s("
							       nil 'move)
					    (point))
		    font-lock-context nil
		    font-lock-context-depth 0
		    font-lock-backslash-p
		      (= (char-syntax (preceding-char)) ?\\)
		      font-lock-comment-context nil
		      font-lock-string-context nil
		    ))
	  ;; we can restart at the cached beginning-of-line
	  (setq font-lock-context font-lock-bol-context
		font-lock-context-end font-lock-bol-context-end
		font-lock-context-depth font-lock-bol-context-depth
		font-lock-backslash-p font-lock-bol-backslash-p
		font-lock-comment-context font-lock-bol-comment-context
		font-lock-string-context font-lock-bol-string-context)
	  (move-marker font-lock-context-start-marker
		       font-lock-bol-context-start-marker)))
    (goto-char font-lock-context-start-marker)
    (while (< (point) target)
      (setq syntax (char-syntax (following-char)))
      (cond (font-lock-backslash-p
	     (setq font-lock-backslash-p nil))
	    ((= syntax ?\\)
	     (or font-lock-backslash-p (setq font-lock-backslash-p t)))
	    ((= syntax ?\()
	     (or font-lock-context
		 (setq font-lock-context-depth
		       (1+ font-lock-context-depth))))
	    ((= syntax ?\))
	     (or font-lock-context
		 (setq font-lock-context-depth
		       (1- font-lock-context-depth))))
	    ((= syntax ?\<)
	     (or font-lock-context
		 (setq font-lock-context 'comment)))
	    ((= syntax ?\>)
	     (if (and (eq font-lock-context 'comment)
		      (not font-lock-comment-context))
		 (setq font-lock-context nil)))
	    ((= syntax ?\")
	     (cond ((and (eq font-lock-context 'string)
			 (eq font-lock-string-context (following-char)))
		    (setq font-lock-context nil
			  font-lock-string-context nil))
		   ((null font-lock-context)
		    (setq font-lock-context 'string
			  font-lock-string-context (following-char)))))
	    ;;
	    ;; Check for multi-char comment characters.
	    ;; We do this last because `char-syntax' is byte-coded.
	    ;;
	    ((= syntax ?.) ; not necessarily correct, but fast.
	     (let ((code (font-lock-char-syntax-code (following-char))))
	       (cond ((and (font-lock-comment-start1-p code)
			   (or (null font-lock-comment-context)
			       (eq font-lock-comment-context 'start1)))
		      (setq font-lock-comment-context 'start1))
		     ((and (font-lock-comment-start2-p code)
			   (eq font-lock-comment-context 'start1))
		      (setq font-lock-comment-context 'start2))
		     ((and (font-lock-comment-end1-p code)
			   (or (eq font-lock-comment-context 'start2)
			       (eq font-lock-comment-context 'end1)))
		      (setq font-lock-comment-context 'end1))
		     ((and (font-lock-comment-end2-p code)
			   (eq font-lock-comment-context 'end1))
		      (setq font-lock-comment-context 'end2)))))
	    )
      (cond ((and font-lock-context
		  (not (eq font-lock-context 'comment2)))
	     (setq font-lock-comment-context nil))
	    ((eq font-lock-comment-context 'start2)
	     (setq font-lock-context 'comment2))
	    ((eq font-lock-comment-context 'end2)
	     (setq font-lock-context nil
		   font-lock-comment-context nil)))
      (if (= (preceding-char) ?\n)
	  (progn
	    (setq font-lock-bol-context font-lock-context
		  font-lock-bol-context-end font-lock-context-end
		  font-lock-bol-context-depth font-lock-context-depth
		  font-lock-bol-backslash-p font-lock-backslash-p
		  font-lock-bol-comment-context font-lock-comment-context
		  font-lock-bol-string-context font-lock-string-context)
	    (move-marker font-lock-bol-context-start-marker
			 font-lock-context-start-marker)))
      (forward-char 1))
    (move-marker font-lock-context-start-marker (point)))
  font-lock-context)


(defsubst font-lock-context-face ()
  (cond ((eq font-lock-context 'comment) 'font-lock-comment-face)
	((eq font-lock-context 'comment2) 'font-lock-comment-face)
	((eq font-lock-context 'string)
	 (if (= font-lock-context-depth 1)
	     ;; rally we should only use this if in position 3 depth 1, but
	     ;; that's too expensive to compute.
	     'font-lock-doc-string-face
	   'font-lock-string-face))
	(t nil)))


(defsubst font-lock-any-extents-p (start end)
  (let ((result nil))
    (map-extents (function (lambda (ignore ignore) (setq result t)))
		 (current-buffer) start end nil)
    result))

(defun font-lock-hack-keywords (start end)
  (goto-char start)
  (let ((case-fold-search font-lock-keywords-case-fold-search)
	(rest font-lock-keywords)
	str match face s e)
    (while rest
      (goto-char start)
      (cond ((consp (car rest))
	     (setq str (car (car rest)))
	     (cond ((consp (cdr (car rest)))
		    (setq match (car (cdr (car rest)))
			  face (car (cdr (cdr (car rest))))))
		   ((symbolp (cdr (car rest)))
		    (setq match 0 face (cdr (car rest))))
		   (t
		    (setq match (cdr (car rest))
			  face 'font-lock-keyword-face))))
	    (t
	     (setq str (car rest)
		   match 0
		   face 'font-lock-keyword-face)))
      (while (re-search-forward str end t)
	(setq s (match-beginning match)
	      e (match-end match))
	;; don't fontify this keyword if we're already in some other context.
	(or (font-lock-any-extents-p s e)
	    (set-extent-face (make-extent s e) face)))
      (setq rest (cdr rest)))))


(defun font-lock-fontify-buffer ()
  "Fontify the current buffer the way electric-font-lock-mode would."
  (interactive)
  (map-extents (function (lambda (x y) (delete-extent x)))
	       (current-buffer) (point-min) (point-max) nil)
  (font-lock-flush-cache)
  (save-excursion
    (goto-char (point-min))
    (let ((face nil)
	  (last-face nil)
	  (extent nil))
      (while (not (eobp))
	(setq last-face face)
	(font-lock-find-context)
	(setq face (font-lock-context-face))
	(cond ((null face)
	       (setq extent nil))
	      ((eq face last-face)
	       (if extent
		   (set-extent-endpoints
		    extent (extent-start-position extent) (point))))
	      (t
	       (setq extent (make-extent (point) (point)))
	       (set-extent-face extent face)))
	(forward-char 1)))
    (font-lock-hack-keywords (point-min) (point-max))
    ))



(defun font-lock-refontify-line ()
  (let (bol eol s e)
    (save-excursion
      (end-of-line)
      (setq eol (point))
      (beginning-of-line)
      (setq bol (point))
      ;;
      ;; First delete all extents on this line.
      ;; If extents span the line, divide them first so that
      ;; previous and following lines are unaffected.
      (map-extents (function
		    (lambda (extent ignore)
		      (setq s (extent-start-position extent)
			    e (extent-end-position extent))
		      (cond ((< s bol)	; starts before line
			     (set-extent-endpoints extent s (1- bol))
			     (if (> e (1+ eol)) ; ...and ends after line
				 (set-extent-face
				  (make-extent (1+ eol) e)
				  (extent-face extent))))
			    ((> e (1+ eol))	; starts on line and ends after
			     (set-extent-endpoints extent (1+ eol) e))
			    (t		; contained on line
			     (delete-extent extent)))))
		   (current-buffer) bol eol nil)
      ;;
      ;; Now fontify this line.
      ;;
      (let (extent face new-face
	    e-start)
	(while (<= (point) eol)
	  (font-lock-find-context)
	  (setq new-face (font-lock-context-face))
	  (cond ((and face (eq face new-face))
		 (set-extent-endpoints extent e-start (1+ (point))))
		(new-face
		 (setq extent (make-extent (setq e-start (point))
					   (1+ (point))))
		 (set-extent-face extent new-face)))
	  (setq face new-face)
	  (forward-char 1)))
      )))


(defun font-lock-after-change-function (beg end old-len)
  (if (> old-len 0) ; deletions mean the cache is invalid
      (font-lock-flush-cache))
  (save-excursion
    (goto-char beg)
    (beginning-of-line)
    (setq beg (point))
    (while (<= (point) end)
      (font-lock-refontify-line)
      (forward-line 1))
    (font-lock-hack-keywords beg (point))))


(defvar electric-font-lock-mode-hook nil
  "*Function or functions to run on entry to electric-font-lock-mode.")

(defun electric-font-lock-mode (&optional arg)
  "Toggle Electric Font Lock Mode.
With arg, turn font-lock mode on if and only if arg is positive.
In font-lock mode, text is fontified as you type it."
  (interactive "P")
  (set (make-local-variable 'after-change-function)
       (if (if (null arg)
	       (not after-change-function)
	     (> (prefix-numeric-value arg) 0))
	   'font-lock-after-change-function
	 nil))
  (if (interactive-p)
      (message "Electric Font Lock Mode is now %s."
	       (if after-change-function "on" "off")))
  (if after-change-function
      (run-hooks 'electric-font-lock-mode-hook)))


;;; Lisp and C mode interface

(defvar lisp-font-lock-keywords
 '(("^(def[-a-z]+\\s +\\(\\S +\\)" 1 font-lock-function-name-face)
   ("(\\(cond\\|if\\|when\\|unless\\|[ec]?\\(type\\)?case\\)[ \t\n]" . 1)
   ("(\\(while\\|do\\|let*?\\|flet\\|labels\\|prog[nv12*]?\\)[ \t\n]" . 1)
   ("\\s :\\(\\sw\\|\\s_\\)+\\>" . 1)
   ))

(defconst c-font-lock-keywords
  (let ((storage "auto\\|extern\\|register\\|static\\|volatile")
	(prefixes "unsigned\\|short\\|long")
	(types (concat "int\\|char\\|float\\|double\\|void\\|struct\\|"
		       "union\\|enum\\|typedef")))
    (list storage
	  (list (concat "\\(" storage "\\)?\\s *"
			"\\(" prefixes "\\)?\\s *"
			"\\(" types "\\)\\s +"
			"\\(\\(\\sw\\|\\s_\\|[*&]\\)+\\)")
		4 'font-lock-function-name-face)
	  (cons (concat
		 "[ \t]\\("
		 "for\\|while\\|do\\|return\\|goto\\|switch\\|case\\|break"
		 "\\)[ \t\n(){};,]")
		1)
	  "\\(\\sw\\|\\s_\\)+:"
	  '("^#[ \t]*[a-z]+" . font-lock-comment-face)
	  '("^#[ \t]*include[ \t]+<\\([^>\n]+\\)>" 1 font-lock-string-face)
	  )))


(defun dummy-electric-font-lock-mode-hook ()
  (cond ((memq major-mode '(lisp-mode emacs-lisp-mode))
	 (set (make-local-variable 'font-lock-keywords)
	      lisp-font-lock-keywords))
	((memq major-mode '(c-mode c++-mode))
	 (set (make-local-variable 'font-lock-keywords)
	      c-font-lock-keywords))
	))

(add-hook 'electric-font-lock-mode-hook
	  'dummy-electric-font-lock-mode-hook)

