;; TCL code editing commands for Emacs - adapted from C Mode by SNL@CS.CMU.EDU
;; Copyright (C) 1985, 1986, 1987 Free Software Foundation, Inc.

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


(defvar tcl-mode-abbrev-table nil
  "Abbrev table in use in TCL-mode buffers.")
(define-abbrev-table 'tcl-mode-abbrev-table ())

(defvar tcl-mode-map ()
  "Keymap used in TCL mode.")
(if tcl-mode-map
    ()
  (setq tcl-mode-map (make-sparse-keymap))
  (define-key tcl-mode-map "{" 'electric-tcl-brace)
  (define-key tcl-mode-map "}" 'electric-tcl-brace)
  (define-key tcl-mode-map ";" 'electric-tcl-semi)
  (define-key tcl-mode-map ":" 'electric-tcl-terminator)
  (define-key tcl-mode-map "\e\C-h" 'mark-tcl-function)
  (define-key tcl-mode-map "\e\C-q" 'indent-tcl-exp)
  (define-key tcl-mode-map "\177" 'backward-delete-char-untabify)
  (define-key tcl-mode-map "\t" 'tcl-indent-command))

;(autoload 'tcl-macro-expand "cmacexp"
;  "Display the result of expanding all TCL macros occurring in the region.
;The expansion is entirely correct because it uses the C preprocessor."
;  t)

(defvar tcl-mode-syntax-table nil
  "Syntax table in use in TCL-mode buffers.")

(if tcl-mode-syntax-table
    ()
  (setq tcl-mode-syntax-table (make-syntax-table))
  (modify-syntax-entry ?\\ "\\" tcl-mode-syntax-table)
  (modify-syntax-entry ?/ ". 14" tcl-mode-syntax-table)
  (modify-syntax-entry ?* ". 23" tcl-mode-syntax-table)
  (modify-syntax-entry ?+ "." tcl-mode-syntax-table)
  (modify-syntax-entry ?- "." tcl-mode-syntax-table)
  (modify-syntax-entry ?= "." tcl-mode-syntax-table)
  (modify-syntax-entry ?% "." tcl-mode-syntax-table)
  (modify-syntax-entry ?< "." tcl-mode-syntax-table)
  (modify-syntax-entry ?> "." tcl-mode-syntax-table)
  (modify-syntax-entry ?& "." tcl-mode-syntax-table)
  (modify-syntax-entry ?| "." tcl-mode-syntax-table)
  (modify-syntax-entry ?\' "\"" tcl-mode-syntax-table))

(defconst tcl-indent-level 2
  "*Indentation of TCL statements with respect to containing block.")
(defconst tcl-brace-imaginary-offset 0
  "*Imagined indentation of a TCL open brace that actually follows a statement.")
(defconst tcl-brace-offset 0
  "*Extra indentation for braces, compared with other text in same context.")
(defconst tcl-argdecl-indent 5
  "*Indentation level of declarations of TCL function arguments.")
(defconst tcl-label-offset -2
  "*Offset of TCL label lines and case statements relative to usual indentation.")
(defconst tcl-continued-statement-offset 2
  "*Extra indent for lines not starting new statements.")
(defconst tcl-continued-brace-offset 0
  "*Extra indent for substatements that start with open-braces.
This is in addition to tcl-continued-statement-offset.")

(defconst tcl-auto-newline nil
  "*Non-nil means automatically newline before and after braces,
and after colons and semicolons, inserted in TCL code.")

(defconst tcl-tab-always-indent t
  "*Non-nil means TAB in TCL mode should always reindent the current line,
regardless of where in the line point is when the TAB command is used.")

(defun tcl-mode ()
  "Major mode for editing TCL code.
Expression and list commands understand all TCL brackets.
Tab indents for TCL code.
Comments are delimited with /* ... */.
Paragraphs are separated by blank lines only.
Delete converts tabs to spaces as it moves back.
\\{tcl-mode-map}
Variables controlling indentation style:
 tcl-tab-always-indent
    Non-nil means TAB in TCL mode should always reindent the current line,
    regardless of where in the line point is when the TAB command is used.
 tcl-auto-newline
    Non-nil means automatically newline before and after braces,
    and after colons and semicolons, inserted in TCL code.
 tcl-indent-level
    Indentation of TCL statements within surrounding block.
    The surrounding block's indentation is the indentation
    of the line on which the open-brace appears.
 tcl-continued-statement-offset
    Extra indentation given to a substatement, such as the
    then-clause of an if or body of a while.
 tcl-continued-brace-offset
    Extra indentation given to a brace that starts a substatement.
    This is in addition to tcl-continued-statement-offset.
 tcl-brace-offset
    Extra indentation for line if it starts with an open brace.
 tcl-brace-imaginary-offset
    An open brace following other text is treated as if it were
    this far to the right of the start of its line.
 tcl-argdecl-indent
    Indentation level of declarations of TCL function arguments.
 tcl-label-offset
    Extra indentation for line that is a label, or case or default.

Settings for K&R and BSD indentation styles are
  tcl-indent-level                5    8
  tcl-continued-statement-offset  5    8
  tcl-brace-offset               -5   -8
  tcl-argdecl-indent              0    8
  tcl-label-offset               -5   -8

Turning on TCL mode calls the value of the variable tcl-mode-hook with no args,
if that value is non-nil."
  (interactive)
  (kill-all-local-variables)
  (use-local-map tcl-mode-map)
  (setq major-mode 'tcl-mode)
  (setq mode-name "TCL")
  (setq local-abbrev-table tcl-mode-abbrev-table)
  (set-syntax-table tcl-mode-syntax-table)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start (concat "^$\\|" page-delimiter))
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'paragraph-ignore-fill-prefix)
  (setq paragraph-ignore-fill-prefix t)
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'tcl-indent-line)
  (make-local-variable 'require-final-newline)
  (setq require-final-newline t)
  (make-local-variable 'comment-start)
  (setq comment-start "/* ")
  (make-local-variable 'comment-end)
  (setq comment-end " */")
  (make-local-variable 'comment-column)
  (setq comment-column 32)
  (make-local-variable 'comment-start-skip)
  (setq comment-start-skip "/\\*+ *")
  (make-local-variable 'comment-indent-hook)
  (setq comment-indent-hook 'tcl-comment-indent)
  (make-local-variable 'parse-sexp-ignore-comments)
  (setq parse-sexp-ignore-comments t)
  (run-hooks 'tcl-mode-hook))

;; This is used by indent-for-comment
;; to decide how much to indent a comment in TCL code
;; based on its context.
(defun tcl-comment-indent ()
  (if (looking-at "^/\\*")
      0				;Existing comment at bol stays there.
    (save-excursion
      (skip-chars-backward " \t")
      (max (1+ (current-column))	;Else indent at comment column
	   comment-column))))	; except leave at least one space.

(defun electric-tcl-brace (arg)
  "Insert character and correct line's indentation."
  (interactive "P")
  (let (insertpos)
    (if (and (not arg)
	     (eolp)
	     (or (save-excursion
		   (skip-chars-backward " \t")
		   (bolp))
		 (if tcl-auto-newline (progn (tcl-indent-line) (newline) t) nil)))
	(progn
	  (insert last-command-char)
	  (tcl-indent-line)
	  (if tcl-auto-newline
	      (progn
		(newline)
		;; (newline) may have done auto-fill
		(setq insertpos (- (point) 2))
		(tcl-indent-line)))
	  (save-excursion
	    (if insertpos (goto-char (1+ insertpos)))
	    (delete-char -1))))
    (if insertpos
	(save-excursion
	  (goto-char insertpos)
	  (self-insert-command (prefix-numeric-value arg)))
      (self-insert-command (prefix-numeric-value arg)))))

(defun electric-tcl-semi (arg)
  "Insert character and correct line's indentation."
  (interactive "P")
  (if tcl-auto-newline
      (electric-tcl-terminator arg)
    (self-insert-command (prefix-numeric-value arg))))

(defun electric-tcl-terminator (arg)
  "Insert character and correct line's indentation."
  (interactive "P")
  (let (insertpos (end (point)))
    (if (and (not arg) (eolp)
	     (not (save-excursion
		    (beginning-of-line)
		    (skip-chars-forward " \t")
		    (or (= (following-char) ?#)
			;; Colon is special only after a label, or case ....
			;; So quickly rule out most other uses of colon
			;; and do no indentation for them.
			(and (eq last-command-char ?:)
			     (not (looking-at "case[ \t]"))
			     (save-excursion
			       (forward-word 1)
			       (skip-chars-forward " \t")
			       (< (point) end)))
			(progn
			  (beginning-of-defun)
			  (let ((pps (parse-partial-sexp (point) end)))
			    (or (nth 3 pps) (nth 4 pps) (nth 5 pps))))))))
	(progn
	  (insert last-command-char)
	  (tcl-indent-line)
	  (and tcl-auto-newline
	       (not (tcl-inside-parens-p))
	       (progn
		 (newline)
		 (setq insertpos (- (point) 2))
		 (tcl-indent-line)))
	  (save-excursion
	    (if insertpos (goto-char (1+ insertpos)))
	    (delete-char -1))))
    (if insertpos
	(save-excursion
	  (goto-char insertpos)
	  (self-insert-command (prefix-numeric-value arg)))
      (self-insert-command (prefix-numeric-value arg)))))

(defun tcl-inside-parens-p ()
  (condition-case ()
      (save-excursion
	(save-restriction
	  (narrow-to-region (point)
			    (progn (beginning-of-defun) (point)))
	  (goto-char (point-max))
	  (= (char-after (or (scan-lists (point) -1 1) (point-min))) ?\()))
    (error nil)))

(defun tcl-indent-command (&optional whole-exp)
  (interactive "P")
  "Indent current line as TCL code, or in some cases insert a tab character.
If tcl-tab-always-indent is non-nil (the default), always indent current line.
Otherwise, indent the current line only if point is at the left margin
or in the line's indentation; otherwise insert a tab.

A numeric argument, regardless of its value,
means indent rigidly all the lines of the expression starting after point
so that this line becomes properly indented.
The relative indentation among the lines of the expression are preserved."
  (if whole-exp
      ;; If arg, always indent this line as C
      ;; and shift remaining lines of expression the same amount.
      (let ((shift-amt (tcl-indent-line))
	    beg end)
	(save-excursion
	  (if tcl-tab-always-indent
	      (beginning-of-line))
	  (setq beg (point))
	  (forward-sexp 1)
	  (setq end (point))
	  (goto-char beg)
	  (forward-line 1)
	  (setq beg (point)))
	(if (> end beg)
	    (indent-code-rigidly beg end shift-amt "#")))
    (if (and (not tcl-tab-always-indent)
	     (save-excursion
	       (skip-chars-backward " \t")
	       (not (bolp))))
	(insert-tab)
      (tcl-indent-line))))

(defun tcl-indent-line ()
  "Indent current line as TCL code.
Return the amount the indentation changed by."
  (let ((indent (calculate-tcl-indent nil))
	beg shift-amt
	(case-fold-search nil)
	(pos (- (point-max) (point))))
    (beginning-of-line)
    (setq beg (point))
    (cond ((eq indent nil)
	   (setq indent (current-indentation)))
	  ((eq indent t)
	   (setq indent (calculate-tcl-indent-within-comment)))
	  ((looking-at "[ \t]*#")
	   (setq indent 0))
	  (t
	   (skip-chars-forward " \t")
	   (if (listp indent) (setq indent (car indent)))
	   (cond ((or (looking-at "case[ \t]")
		      (and (looking-at "[A-Za-z]")
			   (save-excursion
			     (forward-sexp 1)
			     (looking-at ":"))))
		  (setq indent (max 1 (+ indent tcl-label-offset))))
		 ((and (looking-at "else\\b")
		       (not (looking-at "else\\s_")))
		  (setq indent (save-excursion
				 (tcl-backward-to-start-of-if)
				 (current-indentation))))
		 ((= (following-char) ?})
		  (setq indent (- indent tcl-indent-level)))
		 ((= (following-char) ?{)
		  (setq indent (+ indent tcl-brace-offset))))))
    (skip-chars-forward " \t")
    (setq shift-amt (- indent (current-column)))
    (if (zerop shift-amt)
	(if (> (- (point-max) pos) (point))
	    (goto-char (- (point-max) pos)))
      (delete-region beg (point))
      (indent-to indent)
      ;; If initial point was within line's indentation,
      ;; position after the indentation.  Else stay at same point in text.
      (if (> (- (point-max) pos) (point))
	  (goto-char (- (point-max) pos))))
    shift-amt))

(defun calculate-tcl-indent (&optional parse-start)
  "Return appropriate indentation for current line as TCL code.
In usual case returns an integer: the column to indent to.
Returns nil if line starts inside a string, t if in a comment."
  (save-excursion
    (beginning-of-line)
    (let ((indent-point (point))
	  (case-fold-search nil)
	  state
	  containing-sexp)
      (if parse-start
	  (goto-char parse-start)
	(beginning-of-defun))
      (while (< (point) indent-point)
	(setq parse-start (point))
	(setq state (parse-partial-sexp (point) indent-point 0))
	(setq containing-sexp (car (cdr state))))
      (cond ((or (nth 3 state) (nth 4 state))
	     ;; return nil or t if should not change this line
	     (nth 4 state))
	    ((null containing-sexp)
	     ;; Line is at top level.  May be data or function definition,
	     ;; or may be function argument declaration.
	     ;; Indent like the previous top level line
	     ;; unless that ends in a closeparen without semicolon,
	     ;; in which case this line is the first argument decl.
	     (goto-char indent-point)
	     (skip-chars-forward " \t")
	     (if (= (following-char) ?{)
		 0   ; Unless it starts a function body
	       (tcl-backward-to-noncomment (or parse-start (point-min)))
	       ;; Look at previous line that's at column 0
	       ;; to determine whether we are in top-level decls
	       ;; or function's arg decls.  Set basic-indent accordinglu.
	       (let ((basic-indent
		      (save-excursion
			(re-search-backward "^[^ \^L\t\n#]" nil 'move)
			(if (and (looking-at "\\sw\\|\\s_")
				 (looking-at ".*(")
				 (progn
				   (goto-char (1- (match-end 0)))
				   (forward-sexp 1)
				   (and (< (point) indent-point)
					(not (memq (following-char)
						   '(?\, ?\;))))))
			    tcl-argdecl-indent 0))))
		 ;; Now add a little if this is a continuation line.
		 (+ basic-indent (if (or (bobp)
					 (memq (preceding-char) '(?\) ?\; ?\})))
				     0 tcl-continued-statement-offset)))))
	    ((/= (char-after containing-sexp) ?{)
	     ;; line is expression, not statement:
	     ;; indent to just after the surrounding open.
	     (goto-char (1+ containing-sexp))
	     (current-column))
	    (t
	     ;; Statement level.  Is it a continuation or a new statement?
	     ;; Find previous non-comment character.
	     (goto-char indent-point)
	     (tcl-backward-to-noncomment containing-sexp)
	     ;; Back up over label lines, since they don't
	     ;; affect whether our line is a continuation.
	     (while (or (eq (preceding-char) ?\,)
			(and (eq (preceding-char) ?:)
			     (or (eq (char-after (- (point) 2)) ?\')
				 (memq (char-syntax (char-after (- (point) 2)))
				       '(?w ?_)))))
	       (if (eq (preceding-char) ?\,)
		   (tcl-backward-to-start-of-continued-exp containing-sexp))
	       (beginning-of-line)
	       (tcl-backward-to-noncomment containing-sexp))
	     ;; Now we get the answer.
	     (if (not (memq (preceding-char) '(nil ?\, ?\; ?\} ?\{)))
		 ;; This line is continuation of preceding line's statement;
		 ;; indent  tcl-continued-statement-offset  more than the
		 ;; previous line of the statement.
		 (progn
		   (tcl-backward-to-start-of-continued-exp containing-sexp)
		   (+ tcl-continued-statement-offset (current-column)
		      (if (save-excursion (goto-char indent-point)
					  (skip-chars-forward " \t")
					  (eq (following-char) ?{))
			  tcl-continued-brace-offset 0)))
	       ;; This line starts a new statement.
	       ;; Position following last unclosed open.
	       (goto-char containing-sexp)
	       ;; Is line first statement after an open-brace?
	       (or
		 ;; If no, find that first statement and indent like it.
		 (save-excursion
		   (forward-char 1)
		   (let ((colon-line-end 0))
		     (while (progn (skip-chars-forward " \t\n")
				   (looking-at "#\\|/\\*\\|case[ \t\n].*:\\|[a-zA-Z0-9_$]*:"))
		       ;; Skip over comments and labels following openbrace.
		       (cond ((= (following-char) ?\#)
			      (forward-line 1))
			     ((= (following-char) ?\/)
			      (forward-char 2)
			      (search-forward "*/" nil 'move))
			     ;; case or label:
			     (t
			      (save-excursion (end-of-line)
					      (setq colon-line-end (point)))
			      (search-forward ":"))))
		     ;; The first following code counts
		     ;; if it is before the line we want to indent.
		     (and (< (point) indent-point)
			  (if (> colon-line-end (point))
			      (- (current-indentation) tcl-label-offset)
			    (current-column)))))
		 ;; If no previous statement,
		 ;; indent it relative to line brace is on.
		 ;; For open brace in column zero, don't let statement
		 ;; start there too.  If tcl-indent-level is zero,
		 ;; use tcl-brace-offset + tcl-continued-statement-offset instead.
		 ;; For open-braces not the first thing in a line,
		 ;; add in tcl-brace-imaginary-offset.
		 (+ (if (and (bolp) (zerop tcl-indent-level))
			(+ tcl-brace-offset tcl-continued-statement-offset)
		      tcl-indent-level)
		    ;; Move back over whitespace before the openbrace.
		    ;; If openbrace is not first nonwhite thing on the line,
		    ;; add the tcl-brace-imaginary-offset.
		    (progn (skip-chars-backward " \t")
			   (if (bolp) 0 tcl-brace-imaginary-offset))
		    ;; If the openbrace is preceded by a parenthesized exp,
		    ;; move to the beginning of that;
		    ;; possibly a different line
		    (progn
		      (if (eq (preceding-char) ?\))
			  (forward-sexp -1))
		      ;; Get initial indentation of the line we are on.
		      (current-indentation))))))))))

(defun calculate-tcl-indent-within-comment ()
  "Return the indentation amount for line, assuming that
the current line is to be regarded as part of a block comment."
  (let (end star-start)
    (save-excursion
      (beginning-of-line)
      (skip-chars-forward " \t")
      (setq star-start (= (following-char) ?\*))
      (skip-chars-backward " \t\n")
      (setq end (point))
      (beginning-of-line)
      (skip-chars-forward " \t")
      (and (re-search-forward "/\\*[ \t]*" end t)
	   star-start
	   (goto-char (1+ (match-beginning 0))))
      (current-column))))


(defun tcl-backward-to-noncomment (lim)
  (let (opoint stop)
    (while (not stop)
      (skip-chars-backward " \t\n\f" lim)
      (setq opoint (point))
      (if (and (>= (point) (+ 2 lim))
	       (save-excursion
		 (forward-char -2)
		 (looking-at "\\*/")))
	  (search-backward "/*" lim 'move)
	(beginning-of-line)
	(skip-chars-forward " \t")
	(setq stop (or (not (looking-at "#")) (<= (point) lim)))
	(if stop (goto-char opoint)
	  (beginning-of-line))))))

(defun tcl-backward-to-start-of-continued-exp (lim)
  (if (= (preceding-char) ?\))
      (forward-sexp -1))
  (beginning-of-line)
  (if (<= (point) lim)
      (goto-char (1+ lim)))
  (skip-chars-forward " \t"))

(defun tcl-backward-to-start-of-if (&optional limit)
  "Move to the start of the last ``unbalanced'' if."
  (or limit (setq limit (save-excursion (beginning-of-defun) (point))))
  (let ((if-level 1)
	(case-fold-search nil))
    (while (not (zerop if-level))
      (backward-sexp 1)
      (cond ((looking-at "else\\b")
	     (setq if-level (1+ if-level)))
	    ((looking-at "if\\b")
	     (setq if-level (1- if-level)))
	    ((< (point) limit)
	     (setq if-level 0)
	     (goto-char limit))))))


(defun mark-tcl-function ()
  "Put mark at end of TCL function, point at beginning."
  (interactive)
  (push-mark (point))
  (end-of-defun)
  (push-mark (point))
  (beginning-of-defun)
  (backward-paragraph))

(defun indent-tcl-exp ()
  "Indent each line of the TCL grouping following point."
  (interactive)
  (let ((indent-stack (list nil))
	(contain-stack (list (point)))
	(case-fold-search nil)
	restart outer-loop-done inner-loop-done state ostate
	this-indent last-sexp
	at-else at-brace
	(opoint (point))
	(next-depth 0))
    (save-excursion
      (forward-sexp 1))
    (save-excursion
      (setq outer-loop-done nil)
      (while (and (not (eobp)) (not outer-loop-done))
	(setq last-depth next-depth)
	;; Compute how depth changes over this line
	;; plus enough other lines to get to one that
	;; does not end inside a comment or string.
	;; Meanwhile, do appropriate indentation on comment lines.
	(setq innerloop-done nil)
	(while (and (not innerloop-done)
		    (not (and (eobp) (setq outer-loop-done t))))
	  (setq ostate state)
	  (setq state (parse-partial-sexp (point) (progn (end-of-line) (point))
					  nil nil state))
	  (setq next-depth (car state))
	  (if (and (car (cdr (cdr state)))
		   (>= (car (cdr (cdr state))) 0))
	      (setq last-sexp (car (cdr (cdr state)))))
	  (if (or (nth 4 ostate))
	      (tcl-indent-line))
	  (if (or (nth 3 state))
	      (forward-line 1)
	    (setq innerloop-done t)))
	(if (<= next-depth 0)
	    (setq outer-loop-done t))
	(if outer-loop-done
	    nil
	  ;; If this line had ..))) (((.. in it, pop out of the levels
	  ;; that ended anywhere in this line, even if the final depth
	  ;; doesn't indicate that they ended.
	  (while (> last-depth (nth 6 state))
	    (setq indent-stack (cdr indent-stack)
		  contain-stack (cdr contain-stack)
		  last-depth (1- last-depth)))
	  (if (/= last-depth next-depth)
	      (setq last-sexp nil))
	  ;; Add levels for any parens that were started in this line.
	  (while (< last-depth next-depth)
	    (setq indent-stack (cons nil indent-stack)
		  contain-stack (cons nil contain-stack)
		  last-depth (1+ last-depth)))
	  (if (null (car contain-stack))
	      (setcar contain-stack (or (car (cdr state))
					(save-excursion (forward-sexp -1)
							(point)))))
	  (forward-line 1)
	  (skip-chars-forward " \t")
	  (if (eolp)
	      nil
	    (if (and (car indent-stack)
		     (>= (car indent-stack) 0))
		;; Line is on an existing nesting level.
		;; Lines inside parens are handled specially.
		(if (/= (char-after (car contain-stack)) ?{)
		    (setq this-indent (car indent-stack))
		  ;; Line is at statement level.
		  ;; Is it a new statement?  Is it an else?
		  ;; Find last non-comment character before this line
		  (save-excursion
		    (setq at-else (looking-at "else\\W"))
		    (setq at-brace (= (following-char) ?{))
		    (tcl-backward-to-noncomment opoint)
		    (if (not (memq (preceding-char) '(nil ?\, ?\; ?} ?: ?{)))
			;; Preceding line did not end in comma or semi;
			;; indent this line  tcl-continued-statement-offset
			;; more than previous.
			(progn
			  (tcl-backward-to-start-of-continued-exp (car contain-stack))
			  (setq this-indent
				(+ tcl-continued-statement-offset (current-column)
				   (if at-brace tcl-continued-brace-offset 0))))
		      ;; Preceding line ended in comma or semi;
		      ;; use the standard indent for this level.
		      (if at-else
			  (progn (tcl-backward-to-start-of-if opoint)
				 (setq this-indent (current-indentation)))
			(setq this-indent (car indent-stack))))))
	      ;; Just started a new nesting level.
	      ;; Compute the standard indent for this level.
	      (let ((val (calculate-tcl-indent
			   (if (car indent-stack)
			       (- (car indent-stack))))))
		(setcar indent-stack
			(setq this-indent val))))
	    ;; Adjust line indentation according to its contents
	    (if (or (looking-at "case[ \t]")
		    (and (looking-at "[A-Za-z]")
			 (save-excursion
			   (forward-sexp 1)
			   (looking-at ":"))))
		(setq this-indent (max 1 (+ this-indent tcl-label-offset))))
	    (if (= (following-char) ?})
		(setq this-indent (- this-indent tcl-indent-level)))
	    (if (= (following-char) ?{)
		(setq this-indent (+ this-indent tcl-brace-offset)))
	    ;; Put chosen indentation into effect.
	    (or (= (current-column) this-indent)
		(= (following-char) ?\#)
		(progn
		  (delete-region (point) (progn (beginning-of-line) (point)))
		  (indent-to this-indent)))
	    ;; Indent any comment following the text.
	    (or (looking-at comment-start-skip)
		(if (re-search-forward comment-start-skip (save-excursion (end-of-line) (point)) t)
		    (progn (indent-for-comment) (beginning-of-line)))))))))
; (message "Indenting TCL expression...done")
  )
