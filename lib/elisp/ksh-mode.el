;;;
;;;  -*-Lisp-*-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  @(#)ksh-mode.el	1.7 92/06/23
;;;
;;;   Title:  ksh-mode.el
;;;  Author:  G. F. Ellison
;;;           AT&T Bell Laboratories
;;;           Rm 1B-374
;;;           6200 East Broad Street
;;;           Columbus, Ohio 43213
;;;           gfe@cblpf.att.com
;;;    Date:  6/23/92
;;;     Mod:  
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Overview:
;;;   ksh-mode for emacs: usual mode modifying behaviour for writing
;;;   shell scripts in korn shell (and sh).
;;; 
;;; Installation:
;;;   Put ksh-mode.el in some directory in your load-path.
;;;   Put the following forms in your .emacs file.
;;;
;;; (autoload 'ksh-mode "ksh-mode" "Major mode for editing ksh Scripts." t)
;;;
;;; (setq auto-mode-alist
;;;      (append auto-mode-alist
;;;	      (list
;;;	       '("\\.sh$" . ksh-mode)
;;;	       '("\\.ksh$" . ksh-mode))))
;;;
;;; (setq ksh-mode-hook
;;;      (function (lambda ()
;;;		  (setq ksh-indent 8)
;;;		  (setq ksh-case-indent 8)
;;;		  )))
;;;
;;; Limitations:
;;;   The handling of case statements is much too rigid.
;;;
;;; 
;;;================================================================

(defconst ksh-SPACE 32
  "The space character")

(defconst ksh-default-indent 4
  "Supplied indentation level as extra for keywords")

(defconst ksh-default-case-indent 4
  "Supplied indentation level as extra for case items")

(defconst ksh-match-and-tell t
  "*Non-nil means tell user about which keyword matches the current
one when closing constructs")

;; unindenting
(defconst ksh-match-do-regexp          "^[ \|\t]*\\(do\\|{\\)[ \|\t\|\n]"
  "*Regexp used to match keyword: do")

(defconst ksh-match-then-regexp           "^[ \|\t]*then[ \|\t\|\n]"
  "*Regexp used to match keyword: then")

(defconst ksh-match-else-regexp           "^[ \|\t]*else[ \|\t\|\n]"
  "*Regexp used to match keyword: else")

(defconst ksh-match-elif-regexp           "^[ \|\t]*elif[ \|\t\|\n]"
  "*Regexp used to match keyword: elif")

(defconst ksh-match-case-item-end-regexp           ".*;;[ \|\t\|\n]"
  "*Regexp used to match case item end symbol: ;;")

;; structure starting
(defconst ksh-match-if-regexp         "^[ \|\t]*if[ \|\t\|\n]"
  "*Regexp used to match keyword: if")

(defconst ksh-match-while-regexp          "^[ \|\t]*while[ \|\t]"
  "*Regexp used to match keyword: while")

(defconst ksh-match-until-regexp          "^[ \|\t]*until[ \|\t]"
  "*Regexp used to match keyword: until")

(defconst ksh-match-case-regexp           "^[ \|\t]*case[ \|\t]"
  "*Regexp used to match keyword: case")

(defconst ksh-match-for-regexp         "^[ \|\t]*for[ \|\t]"
  "*Regexp used to match keyword: for")

(defconst ksh-match-select-regexp        "^[ \|\t]*select[ \|\t]"
  "*Regexp used to match keyword: select")

;; indenting
(defconst ksh-match-case-item-regexp           "^[ \|\t]*.*)[ \|\t\|\n]"
  "*Regexp used to match keyword symbol: )")

;; structure ending
(defconst ksh-match-fi-regexp            "^[ \|\t]*fi[ \|\t\|\n]"
  "*Regexp used to match keyword: fi")

(defconst ksh-match-esac-regexp          "^[ \|\t]*esac[ \|\t\|\n]"
  "*Regexp used to match keyword: esac")

(defconst ksh-match-done-regexp          "^[ \|\t]*\\(done\\|}\\)[ \|\t\|\n]"
  "*Regexp used to match keyword: done")

;; matching patterns for constructs

(defconst ksh-match-wufs-regexp 
  "^[ \\|\\t]*\\(until\\|while\\|for\\|select\\)[ \|\t\|\n]"
  "*Match one of keywords: until, while, for, select")

(defconst ksh-match-elif-or-if-regexp "^[ \\|\\t]*\\(elif\\|if\\)[ \|\t\|\n]"
  "*Match one of keywords: elif, if")

(defconst ksh-match-elif-or-fi-regexp "^[ \\|\\t]*\\(elif\\|fi\\)[ \|\t\|\n]"
  "*Match one of keywords: elif, fi")

(defconst ksh-match-else-elif-or-if-regexp 
  "^[ \\|\\t]*\\(else\\|elif\\|if\\)[ \|\t\|\n]"
  "*Match one of keywords: else, elif, if")

(defconst ksh-match-case-item-or-case-regexp 
  "^[ \\|\\t]*.*\\()\\|case\\)[ \|\t\|\n]"
  "*Regexp used to match symbol or keyword: ) case")

;;
;; Create mode specific tables
(defvar ksh-mode-syntax-table nil
  "Syntax tabel used while in ksh mode.")
(if ksh-mode-syntax-table
    ()
  (setq ksh-mode-syntax-table (make-syntax-table))
  (set-syntax-table ksh-mode-syntax-table)
  )

(defvar ksh-mode-abbrev-table nil
  "Abbrev table used while in ksh mode.")
(define-abbrev-table 'ksh-mode-abbrev-table ())

(defvar ksh-mode-map nil 
  "Keymap used in ksh mode")

(if ksh-mode-map
    ()
  (setq ksh-mode-map (make-sparse-keymap))
  (define-key ksh-mode-map "\C-i"    'ksh-indent-line-function)
  (define-key ksh-mode-map "\177"    'backward-delete-char-untabify)
  (define-key ksh-mode-map "\C-m"    'ksh-match-structure-and-return)
  )

(defun ksh-mode ()
  "Major mode for editing korn shell scripts.
Special key bindings and commands:
\\{ksh-mode-map}
"
  (interactive)
  (kill-all-local-variables)
  (use-local-map ksh-mode-map)
  (setq major-mode 'ksh-mode)
  (setq mode-name "Ksh-Script")
  (setq local-abbrev-table ksh-mode-abbrev-table)
  (set-syntax-table ksh-mode-syntax-table)
  (make-local-variable 'ksh-indent)
  (setq ksh-indent ksh-default-indent)
  (make-local-variable 'ksh-case-indent)
  (setq ksh-case-indent ksh-default-case-indent)
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'ksh-indent-line-function)
  (make-local-variable 'comment-start)
  (setq comment-start "# ")
  (make-local-variable 'comment-end)
  (setq comment-end "")
  (make-local-variable 'comment-column)
  (setq comment-column 32)
  (make-local-variable 'comment-start-skip)
  (setq comment-start-skip "#+ *")
  (run-hooks 'ksh-mode-hook)
  ) ;; defun

(defun indentation-on-this-line ()
  "Return current indentation level (no. of columns) that this line is
indented"
  (interactive)
  (save-excursion
    (beginning-of-line)
    (let
        (
         (pos-at-bol (point))
         (pos-at-ind (progn
                       (back-to-indentation)
                       (point)))
         )
         (compute-line-indent pos-at-bol pos-at-ind)
      ) ;; let
    ) ;; excursion
  ) ;; defun

(defun compute-line-indent (from to)
  "Given two points, add up the number of characters between from and
to. Do the proper things for tabs"
  (if (equal from to)
      0
    (+ (cond ((equal (char-to-string (char-after from)) "\t")
              tab-width)
             (t 1)
             ) ;; cond
       (compute-line-indent (+ 1 from) to))
    ) ;; if
  ) ;; defun

(defun is-looking-at-unindenter ()
  "Return true if current line contains an unindenting keyword"
  (or 
   (looking-at ksh-match-elif-regexp)
   (looking-at ksh-match-else-regexp)
   ) ;; or
  ) ;; defun

(defun is-looking-at-indenter ()
  "Return true if current line contains an indenting keyword"
  (or 
   (looking-at ksh-match-if-regexp)
   (looking-at ksh-match-while-regexp)
   (looking-at ksh-match-select-regexp)
   (looking-at ksh-match-until-regexp)
   (looking-at ksh-match-for-regexp)
   (looking-at ksh-match-case-regexp)
   (looking-at ksh-match-case-item-regexp)
   ) ;; or
  ) ;; defun

(defun is-looking-at-compound-list ()
  "Return true if current line contains an indenting keyword"
  (or 
   (looking-at ksh-match-do-regexp)
   (looking-at ksh-match-then-regexp)
   ) ;; or
  ) ;; defun

(defun current-line ()
  "Return the vertical position of point in the buffer.
Top line is 1."
  (+ (count-lines (point-min) (point))
     (if (= (current-column) 0) 1 0))
  )

(defun get-nest-level ()
  "Return a 2 element list (nest-level nest-line) descibing where the
current line should nest."
  (let (
    	(level)
    	) ;; bind
      (save-excursion
	(forward-line -1)
	(while (null level)
	  (if (not (eolp))
	      (setq level (cons (indentation-on-this-line) (current-line)))
	    (forward-line -1)
	    ) ;; if
	  ) ;; while
	) ;; excursion
      level) ;; let
  ) ;; defun

(defun get-additional-indentation (nest-line)
  "Determine of current lines nesting level needs refining WRT nest-line and
syntax of this line. Returns extra indentation."
  (save-excursion
    (let (
	 (this-line (current-line))
	 )
      (goto-line nest-line)
      (let (
	    (extra (cond ((is-looking-at-unindenter)
			  ksh-indent)
			 ((is-looking-at-indenter)
			  ksh-indent)
			 ((is-looking-at-compound-list)
			  ksh-indent)
			 ((looking-at ksh-match-case-item-end-regexp)
			  (- 0 ksh-case-indent))
			 (t 0)
			 ) ;; cond
		   )) ;; bindings
	(goto-line this-line)
	(cond ((is-looking-at-compound-list)
	       0)
	      ((and (looking-at ksh-match-case-item-regexp) (> extra 0))
	       ksh-case-indent)
	      (t extra))
	)) ;; lets
    ) ;; excursion
  ) ;; defun

(defun ksh-indent-line-function ()
  "Indent current line as far as it should go according
to the syntax/context"
  (interactive)
  (save-excursion
    (beginning-of-line)
    (if (bobp)
        nil
      ;;
      ;; Align this line to current nesting level
      (let*
          (
	   (level-list (get-nest-level))
           (last-line-level (car level-list))
           (this-line-level (indentation-on-this-line))
           (level-diff (- this-line-level last-line-level))
           )
        (cond ((> level-diff 0)
	       (indent-to last-line-level)
	       (let ((beg (point)))
		 (back-to-indentation)
		 (delete-region beg (point)))
	       )
              ((< level-diff 0)
               (insert-char ksh-SPACE (- 0 level-diff)))
	      (t nil)
              ) ;; cond
	;;
	;; At this point this line is aligned with last line
	;; So given context of last line indent or leave alone
        (let
            (
             (extra (get-additional-indentation (cdr level-list)))
	     )
	  (cond ((> extra 0)
                 (insert-char ksh-SPACE extra))
		((< extra 0)
		 (indent-to (+ extra last-line-level))
		 (let ((beg (point)))
		   (back-to-indentation)
		   (delete-region beg (point)))
		 )
                (t nil)
                ) ;; cond
          ) ;; let
	;;
	;; Now unindent if need be
        (if ksh-match-and-tell
            (ksh-match-structure-and-return t) ;; indicate match but no newline
          nil) ;; if
        ) ;; let*
      ) ;; if
    ) ;; excursion
  ;;
  ;; Position point on this line
  (let*
      (
       (this-line-level (indentation-on-this-line))
       (this-bol (save-excursion
                   (beginning-of-line)
                   (point)))
       (this-point (- (point) this-bol))
       )
    (cond ((> this-line-level this-point) ;; point in initial white space
           (back-to-indentation))
           (t nil)
           ) ;; cond
    ) ;; let*
  ) ;; defun

(defun ksh-match-structure-and-return (&optional arg)
  "If the current line matches one of the indenting keywords
or one of the control structure ending keywords then indicate
where it matches if ksh-match-and-tell is non-nil. Add newline
if argument present"
  (interactive)
  (if ksh-match-and-tell
      (save-excursion
        (beginning-of-line)
        (cond ((looking-at ksh-match-else-regexp)
	       (ksh-match-indent-level 
		ksh-match-elif-or-if-regexp ksh-match-elif-or-fi-regexp))
              ((looking-at ksh-match-elif-regexp)
	       (ksh-match-indent-level 
		ksh-match-elif-or-if-regexp ksh-match-elif-or-fi-regexp))
	      ((looking-at ksh-match-fi-regexp)
	       (ksh-match-indent-level
		ksh-match-else-elif-or-if-regexp ksh-match-elif-or-fi-regexp))
              ((looking-at ksh-match-done-regexp)
	       (ksh-match-indent-level 
		ksh-match-wufs-regexp ksh-match-done-regexp))
	      ((looking-at ksh-match-esac-regexp)
	       (ksh-match-indent-level 
		ksh-match-case-regexp ksh-match-esac-regexp))
	      ;;
	      ;; Indent separators and match their strucure
	      ((looking-at ksh-match-then-regexp)
               (ksh-grep-and-reindent ksh-match-elif-or-if-regexp))
              ((looking-at ksh-match-do-regexp)
               (ksh-grep-and-reindent ksh-match-wufs-regexp))
	      ((looking-at ksh-match-case-item-regexp)
               (ksh-grep-and-reindent ksh-match-case-regexp))
	      (t nil)
              ) ;; cond
        ) ;; excursion
    nil
    ) ;; if
  (if arg
      nil
    (newline 1)
    ) ;; if
  ) ;; defun

(defun ksh-match-indent-level (begin-regexp end-regexp)
  "Match the compound command and indent"
  (interactive)
  (let* (
	 (nest-list (save-excursion
		      (get-compound-level begin-regexp end-regexp (point))))
	 ) ;; bindings
    (if (null nest-list)
	(message "No matching compound command")
      (progn
	(let* (
	       (nest-level (car nest-list))
	       (match-line (cdr nest-list))
	       (diff-level (- (indentation-on-this-line) nest-level))
	       ) ;; bindings
	  (save-excursion
	    (goto-line match-line)
	    (message (format "Matched ... %s" (line-to-string)))
	    ) ;; excursion
	  (save-excursion
	    (beginning-of-line)
	    (cond ((> diff-level 0)
		   (indent-to nest-level)
		   (let ((beg (point)))
		     (back-to-indentation)
		     (delete-region beg (point)))
		   )
		  ((< diff-level 0)
		   (insert-char ksh-SPACE (- 0 diff-level)))
		  (t nil)
		  ) ;; cond
	    ) ;; excursion
	  ) ;; let* match-line
	) ;; progn
      ) ;; if
    ) ;; let* nest-list
  ) ;; defun

(defun get-compound-level (begin-regexp end-regexp anchor-point)
  "Determine how much to indent this structure. Return a list (level line) 
of the matching compound command or nil if no match found."
  (let* (
	 (end-count 0)
	 ;; Locate the deepest compound starting keyword by looking for 
	 ;; the first one backward
	 (begin-point
	  (if (re-search-backward begin-regexp (point-min) t)
	      (point)
	    0) ;; if
	  ) ;; bind
	 ) ;; bindings
    (cond ((zerop begin-point)
	   nil) ;; graceful exit
	  (t 
	   ;;
	   ;; Now count the number of compound ending keywords (exclusive)
	   ;; forward from matching start keyword
	   (while (re-search-forward end-regexp anchor-point t)
	     (setq end-count (+ end-count 1)))
	   (if (zerop end-count)
	       (progn
		 (cons (indentation-on-this-line) (current-line)))
	     (progn
	       ;;
	       ;; Now search backward end-count times to bypass compound
	       ;; matches (we don`t need no stinking matches;-)
	       (if (re-search-backward begin-regexp (point-min) t end-count)
		   (get-compound-level begin-regexp end-regexp (point))
		 nil) ;; graceful exit
	       )) ;; progn if
	   )) ;; cond
    ) ;; let*
  ) ;; defun


(defun ksh-grep-and-reindent (pat)
  "Try to match PAT and then indent accordingly"
  (interactive)
  (let*
      (
       (last-level (save-excursion
                     (if (re-search-backward pat (point-min) t)
                         (indentation-on-this-line)
                       0) ;; if
                     ) ;; excursion
                   ) ;; bind
       (diff-level (- (indentation-on-this-line) last-level))
       ) ;; b-list
     (save-excursion
      (beginning-of-line)
      (cond ((> diff-level 0)
	       (indent-to last-level)
	       (let ((beg (point)))
		 (back-to-indentation)
		 (delete-region beg (point)))
	       )
            ((< diff-level 0)
             (insert-char ksh-SPACE (- 0 diff-level)))
            (t nil)
            ) ;; cond
      ) ;; excursion
    ) ;; let*
  (structure-match pat)
  ) ;; defun


(defun structure-match (pat)
  "Match against the pattern in PAT and print
out the matched text. If none then indicate no match and say so in
minibuffer"
  (interactive)
  (let
      (
       (result (found-a-match-in pat))
       )
    (message "%s" (cond ((null result)
                         "No matching open")
                        (t
                         result)
                        ) ;; cond
             ) ;; message
    ) ;; let
  ) ;; defun

(defun found-a-match-in (pat)
  "Go back and search for PAT. Text if successful, nil otherwise"
  (save-excursion
    (beginning-of-line)
    (if (re-search-backward pat (point-min) t)
        (format "Matched ... %s" (line-to-string))
      nil)
    ) ;; excursion
  ) ;; defun

(defun line-to-string ()
  "From point, construct a string from all characters on
current line"
  (setq answer "")
  (while (equal (char-after (point)) ksh-SPACE)            ;; skip white space
    (forward-char 1)
    ) ;; while
  (while (not (eolp))
    (setq answer (concat answer (char-to-string (char-after (point)))))
    (forward-char 1)
    ) ;; while
  answer
  ) ;; defun

;;; Gary Ellison, AT&T Bell Labs., gfe@cblpf.att.com, 614/860-2378
;;; "What we have here is a failure to communicate." Struther Martin



