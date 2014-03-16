;;;Date: Mon, 14 Dec 1992 09:51:47 EST
;;;From: ex594bw@pts.mot.com (Bob Weiner)
;;;Message-ID: <9212141451.AA01671@mars.pts.mot.com>
;;;Subject: Re: Filling without removing tabs from 1st line of a paragraph.
;;;Reply-To: bob_weiner@pts.mot.com
;;;Newsgroups: alt.lucid-emacs.help
;;;Path: tcsi.com!uunet!wendy-fate.uu.net!help-lucid-emacs

;;;> In article <1gao29INNiek@transfer.stratus.com> wayne@sw.stratus.com (Wayne Newberry) writes:
;;;> 
;;;>    I currently turn on auto-fill and I'd prefer to have
;;;>    Lucid Emacs fill using only spaces, rather than a 
;;;>    combination of tabs and spaces.  Is there any way to
;;;>    make this happen?
;;;> 
;;;> 
;;;> I have almost the exact opposite problem.  I have paragraphs that look
;;;> like:
;;;> 
;;;> 14 Dec 92 1.23 me	Some text that goes on for multiple lines, with each
;;;> 			continuation line starting with 3 tabs.  The first
;;;> 			line of the paragraph has one tab to make the text
;;;> 			line up with the continuation lines.
;;;> 
;;;> In emacs 18.58, I could set the fill-prefix to be three tabs and then use
;;;> M-q to fill such a paragraph and it would preserve the tab in the first
;;;> line of the paragraph.  Lucid Emacs 19.3, however, turns that tab into a
;;;> single space, destroying the format.
;;;> 			
;;;> 14 Dec 92 1.23 me Some text that goes on for multiple lines, with each
;;;> 			continuation line starting with 3 tabs.  The first
;;;> 			line of the paragraph has one tab to make the text
;;;> 			line up with the continuation lines.
;;;> 
;;;> Is this a bug or a (mis)feature?  Is there a variable I can change to get
;;;> the old functionality back?
;;;
;;;Use the following "par-align.el" package which is expected to be a part of
;;;GNU Emacs V19; it will solve your problem and works under Lucid or regular
;;;GNU Emacs.  I've used it for years as my exclusive paragraph and region fill
;;;code, so if you like, you can bind it to {M-q}.  I use {M-j} myself for ease
;;;of typing.

;;!emacs
;;
;; FILE:         par-align.el
;; SUMMARY:      Improved paragraph fill, left-align and justify functions
;; USAGE:        GNU Emacs Lisp Library
;;
;; AUTHOR:       Bob Weiner, Applied Research, Motorola, Inc.
;; E-MAIL:       weiner@mot.com
;; ORIG-DATE:    14-Apr-89
;; LAST-MOD:      2-Nov-92 at 11:13:54 by Bob Weiner
;;
;; Copyright (C) 1989, 1992    Free Software Foundation, Inc.
;; Available for use and distribution under the same terms as GNU Emacs.
;;
;; This file is not yet part of GNU Emacs.
;;
;; MODS:
;;
;;   18-Dec-90  (bw)  Added support for TeX and LaTeX modes.
;;   15-Sep-92  (bw)  Added support for mail and news edit modes.
;;                    Fixed so only one undo-boundary per fill operation.
;;   02-Nov-92  (bw)  Fixed so last line of last buffer paragraph is filled
;;                    properly if doesn't have a trailing newline.
;;
;; END-MODS.
;;
;; DESCRIPTION:  
;;
;;   This package allows GNU Emacs paragraph commands to deal more
;;   reasonably with indented text and embedded comments.  It lets you
;;   realign and set the fill prefix on one line of a paragraph, e.g. the
;;   first, and then have all the other lines match up when you fill the
;;   paragraph.
;;   
;;   An auto-justify minor mode similar to auto-fill from jka@hpfcso.HP.COM
;;   (Jay Adams) is also included.  Use the 'auto-justify-mode' command to
;;   toggle it on and off.
;;
;;
;;   I think the 'fill-paragraph-and-align' command eliminates the need for
;;   Kyle Jones, 'C Comment Edit' package.  Additionally, there is no need
;;   to edit in a special buffer.
;;   
;;   If you set the fill-prefix to some value, then set it to nil (set it at
;;   the beginning of a line) and then fill the paragraph, the old
;;   fill-prefix will be stripped off and the paragraph will be filled
;;   properly with no prefix.  Then just add the new fill-prefix, if any,
;;   that you want and refill again.
;;   
;;   If you have ever tried to fill Emacs Lisp documentation strings or
;;   embedded comments, you know that all you get is an ugly mess.  You end
;;   up having to fill after putting blank lines at the beginning and end.
;;   Now you can fill properly without making any inline changes.  The fill
;;   routines do not fill the first line of documentation strings since it is
;;   used by the apropos commands and may intentionally be short.
;;   
;;   The fill and movement commands also recognize multiple paragraphs
;;   within a single comment stretch, just like the ones you see in this
;;   description text.  Just remember to set the fill prefix properly, just
;;   as you normally would for the fill-paragraph command.
;;   
;;   When filling a region, fill-prefix-prev (old fill prefix) can be
;;   replaced by fill-prefix throughout the entire region before each
;;   paragraph is filled.  Simply call the 'fill-region-and-align-all'
;;   command.
;;   
;;   Always fill with point before some of the text to be filled.  If you
;;   try to fill when point is on a line following all of the text to be
;;   filled, the next paragraph may be filled by mistake, e.g. when filling
;;   with point near the end of a comment string.
;;
;;   C comments of the form (with any number of '*' chars):
;;   /*
;;    * <text>
;;    * <text>
;;    */
;;   are filled well.
;;
;;   Multiple line C comments of the form:
;;   /*        */
;;   /*        */
;;   are not filled well, so don't use them.  If you have some already, you
;;   can convert them to the kind above with the
;;   'c-comment-make-prefix-only' command found in this package.
;;
;;   Comments in UNIX shell scripts of the form (with any number of '#' chars):
;;   #
;;   # <text>
;;   # <text>
;;   #
;;   are filled well if the first line of the file begins with a pattern that
;;   matches the regular expression "^#!/bin/[ck]?sh" as shell scripts should.
;;
;;   Fortran comments of the form:
;;   C
;;   C <text>
;;   C <text>
;;   C
;;   are filled well.
;;
;;   The commands bound immediately below do all of this work.
;;
;; DESCRIP-END.


;; Suggested key bindings
;;
;(global-set-key "\M-j" 'fill-paragraph-and-align)
;(global-set-key "\C-x\C-j" 'fill-region-and-align-all)
(define-key text-mode-map "\C-x\C-j" 'fill-region-and-align)
(define-key indented-text-mode-map "\C-x\C-j" 'fill-region-and-align)
;(if (fboundp 'outline-level)
;    nil
;  (load "outline")
;  (provide 'outline))
;(define-key outline-mode-map "\C-x\C-j" 'fill-region-and-align)

;; The next two functions are suitable as replacements for the standard
;; paragraph movement commands if you want them to recognize paragraph
;; boundaries the way the fill functions below do.
;;
;; Suggested key bindings
;;
;;(global-set-key "\M-n" 'forward-para)
;;(global-set-key "\M-p" 'backward-para)

(defun forward-para (&optional arg)
  "Move forward to end of paragraph.  With ARG, do it arg times.
A line which  paragraph-start  matches either separates paragraphs,
if  paragraph-separate  matches it also, or is the first line of a paragraph.
A paragraph end is the beginning of a line which is not part of the paragraph
to which the end of the previous line belongs, or the end of the buffer."
  (interactive "p")
  (paragraph-filter 'forward-paragraph arg))

(defun backward-para (&optional arg)
  "Move backward to start of paragraph.  With ARG, do it arg times.
A paragraph start is the beginning of a line which is a first-line-of-paragraph
or which is ordinary text and follows a paragraph-separating line, except
if the first real line of a paragraph is preceded by a blank line,
the paragraph starts at that blank line.
See forward-paragraph for more information."
  (interactive "p")
  (or arg (setq arg 1))
  (paragraph-filter 'forward-paragraph (- arg)))


(defconst fill-prefix-prev nil
  "Previous string inserted at front of new line during filling, or nil for none.
Setting this variable automatically makes it local to the current buffer.")
(make-variable-buffer-local 'fill-prefix-prev)

;; Redefine this function so that it sets 'fill-prefix-prev' also.
(defun set-fill-prefix ()
  "Set the fill-prefix to the current line up to point.
Also sets fill-prefix-prev to previous value of fill-prefix.
Filling expects lines to start with the fill prefix and reinserts the fill
prefix in each resulting line."
  (interactive)
  (setq fill-prefix-prev fill-prefix
	fill-prefix (buffer-substring
		      (save-excursion (beginning-of-line) (point))
		      (point)))
  (if (equal fill-prefix-prev "")
      (setq fill-prefix-prev nil))
  (if (equal fill-prefix "")
      (setq fill-prefix nil))
  (if fill-prefix
      (message "fill-prefix: \"%s\"" fill-prefix)
    (message "fill-prefix cancelled")))

(defun fill-paragraph-and-align (justify-flag)
  "Fill current paragraph.  Prefix arg JUSTIFY-FLAG means justify as well.
Does not alter fill prefix on first line of paragraph.  Any whitespace
separated version of the fill-prefix, or fill-prefix-prev when fill-prefix is
nil, at the beginning of lines is deleted before the fill is performed.  This
aligns all lines in a paragraph properly after the fill-prefix is changed.
Works well within text, singly delimited C comments, Lisp comments and
documentation strings, and Fortran comments."
  (interactive "P")
  (paragraph-filter 'fill-para-align justify-flag))

(defun fill-region-and-align-all (justify-flag)
  "Fill each line in region.  Prefix arg JUSTIFY-FLAG means justify as well.
Replace any whitespace separated version of fill-prefix-prev with fill-prefix
in all lines of region.  This aligns all lines throughout the region properly
after the fill-prefix is changed.  Works well within text, singly delimited C
comments, UNIX shell scripts, Lisp comments and documentation strings, and
Fortran comments.
See also documentation for fill-region-and-align."
  (interactive "P")
  (paragraph-filter 'fill-region-align justify-flag t))

(defun fill-region-and-align (justify-flag &optional align-all)
  "Fill each line in region.  Prefix arg JUSTIFY-FLAG means justify as well.
Optional ALIGN-ALL non-nil means replace fill-prefix-prev with fill-prefix in
all lines of region, otherwise, does not alter prefix in paragraph separator
lines and first lines of paragraphs.
Any whitespace separated version of fill-prefix, or fill-prefix-prev when
fill-prefix is nil, at the beginning of appropriate lines is removed before the
fill is performed.  This aligns all lines in a paragraph properly after the
fill-prefix is changed.  Works well within text, singly delimited C comments,
UNIX shell scripts, Lisp comments and documentation strings, and Fortran comments."
  (interactive "P")
  (paragraph-filter 'fill-region-align justify-flag align-all))

(defun paragraph-filter (func arg1 &optional arg2)
  ;;                      LISP          C/C++        Fortran        Eiffel
  ;;                      --------------------------------------------------
  ;; comment-start        ";"           "/*\\|//"    nil (^[Cc*])   "--"     
  ;; comment-start-skip   ";+ *"        "/\\*+ *"    "![ \t]*"      "--+[ \t]*"
  ;; comment-end          "" ([^J^L])   " */\\|$"    "" (^J)        "" (^J)
  ;;
  (let* ((*C* (memq major-mode '(c-mode c++-mode)))
	 (*lsp*  (memq major-mode
		       '(emacs-lisp-mode lisp-interaction-mode scheme-mode
			 lisp-mode)))
	 (*mail* (memq major-mode '(mail-mode rmail-edit-mode
				    news-reply-mode)))
	 (*txt*  (memq major-mode
		       '(text-mode indented-text-mode texinfo-mode
			 para-mode LaTeX-mode latex-mode TeX-mode 
			 tex-mode scribe-mode outline-mode picture-mode)))
	 (extra-para-sep
	   (concat "^"
		   ;; Don't change the '?' in the following lines to a '+', it
		   ;; will break certain fill boundary conditions.
		   (if (eq major-mode 'fortran-mode) "[cC*]?")
		   "[ \t]*\\("
		   (cond ((and (< (point-min) 2) (> (point-max) 10)
			       (string-match "^#!/bin/[ck]?sh"
				       (buffer-substring 1 11)))
			  "#*")
			 ;; Don't change the '?' in the following lines to a
			 ;; '+', it will break certain fill boundary
			 ;; conditions.
			 (comment-start-skip
			   (concat "\\(" comment-start-skip "\\)?")))
		   (if *C* "\\|\*+/?\\|//.*")
		   (if *mail* (concat "\\|" mail-header-separator "\\|^[!$%&|<> \t]+"))
		   "\\)[ \t]*$"
		   (if *lsp* "\\|^[ \t]*\\([[(]\\|\"\\)")
		   ;; For Interleaf TPS, texinfo and Scribe markup documents
		   (if *txt* "\\|^[@\\<]")
		   ))
	 (paragraph-separate
	   (concat paragraph-separate "\\|" extra-para-sep))
	 (paragraph-start
	   (concat paragraph-start "\\|" extra-para-sep)))
    (if arg2
	(funcall func arg1 arg2)
      (funcall func arg1))))

(defun fill-region-align (justify-flag &optional align-all)
  (if align-all
      (replace-fill-str fill-prefix-prev fill-prefix))
  (save-excursion
    (let ((end (max (point) (mark))))
      (goto-char (min (point) (mark)))
      (while (and (not (eobp)) (< (point) end))
	(fill-para-align justify-flag align-all)
	(forward-paragraph)
	;; Forward to real paragraph end if not in lisp mode
	(or *lsp* (re-search-forward (concat "\\'\\|" paragraph-separate)))))))

(defun fill-para-align (justify-flag &optional leave-prefix)
  (save-excursion
    (end-of-line)
    ;; Backward to para begin
    (re-search-backward (concat "\\`\\|" paragraph-separate))
    (forward-line (if (looking-at extra-para-sep) 2 1))
    (let ((region-start (point)))
      (forward-line -1)
      (let ((from (point)))
	(forward-paragraph)
	;; Forward to real paragraph end if not in lisp mode
	(or *lsp* (re-search-forward (concat "\\'\\|" paragraph-separate)))
	(or (= (point) (point-max)) (beginning-of-line))
	(or leave-prefix
	    (replace-fill-str
	      (or fill-prefix fill-prefix-prev)
	      "" nil region-start (point)))
	(fill-region-as-paragraph from (point) justify-flag)))))

(defun replace-fill-str (fill-str-prev fill-str &optional suffix start end)
  "Replace whitespace separated FILL-STR-PREV with FILL-STR.
Optional SUFFIX non-nil means replace at ends of lines, default is beginnings.
Optional arguments START and END specify the replace region, default is the
current region."
  (if fill-str-prev
      (progn (if (not start) (setq start (min (point) (mark))))
	     (if (not end)   (setq end   (max (point) (mark))))
	     (if (not fill-str) (setq fill-str ""))
	     (save-excursion
	       (save-restriction
		 (narrow-to-region start end)
		 (goto-char (point-min))
		 (let ((prefix
			 (concat
			   (if suffix nil "^")
			   "[ \t]*"
			   (regexp-quote
			     ;; Get non-whitespace separated fill-str-prev
			     (substring
			       fill-str-prev
			       (or (string-match "[^ \t]" fill-str-prev) 0)
			       (if (string-match
				     "[ \t]*\\(.*[^ \t]\\)[ \t]*$"
				     fill-str-prev)
				   (match-end 1))))
			   "[ \t]*"
			   (if suffix "$"))))
		   (while (re-search-forward prefix nil t)
		     (replace-match fill-str nil t))))))))

(defun c-comment-make-prefix-only ()
  "Make multiply-delimited C comments in region singly delimited.
Converts comments of form:
/*  <text>  */      to    /*
/*  <text>  */             * <text>
                           * <text>
                           */"
  (interactive)
  (replace-fill-str "/*" " * ")
  (replace-fill-str "*/" "" t)
  (save-excursion
    (goto-char (min (point) (mark)))
    (insert "/*\n"))
  (save-excursion
    (goto-char (max (point) (mark)))
    (insert (if (bolp) " */\n" "\n */"))))

;;; Auto-justify minor mode
;;
;; From: jka@hpfcso.HP.COM (Jay Adams)
;; Newsgroups: comp.emacs
;; Subject:  auto-justify
;; Date: 7 Sep 89 01:30:18 GMT
;; Organization: Hewlett-Packard, Fort Collins, CO, USA

(defvar auto-justify-mode '()
  "Non-nil if auto-justifying minor mode is on.")

(or (assoc 'auto-justify-mode minor-mode-alist)
    (setq minor-mode-alist
          (cons '(auto-justify-mode " Justify")
                minor-mode-alist)))
           
(defun auto-justify-mode ()
  "Toggle auto-justify minor mode."
  (interactive)
  (if (eq auto-fill-hook 'do-auto-fill-justify)
      (setq auto-fill-hook 'do-auto-fill auto-justify-mode nil)
    (setq auto-fill-hook 'do-auto-fill-justify
          auto-justify-mode t)))

(defun do-auto-fill-justify ()
  "Same as do-auto-fill but justifies current line."
  (do-auto-fill)
  (save-excursion
    (forward-line -1)
    (justify-current-line)))

(provide 'par-align)
