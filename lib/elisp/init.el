; GNU emacs init file for David Eppstein
;
; Edit history:
; tom:/usr1/eppstein/gnu/init.el,  1-May-1987 12:44:15 by eppstein
;   Fix down-comment-line when at end of buffer
; tom:/usr1/eppstein/gnu/init.el,  9-Apr-1987 13:52:39 by eppstein
;   Set rmail-last-rmail-file so rmail "O" works.
; tom:/usr1/eppstein/gnu/init.el,  4-Apr-1987 12:46:21 by eppstein
;   Change TeX mode hook to load change file
; tom:/usr1/eppstein/gnu/init.el, 24-Mar-1987 15:38:15 by eppstein
;   Add shrink-wrap
; tom:/usr1/eppstein/gnu/init.el, 14-Mar-1987 17:36:22 by eppstein
;   Make linefeed work in C mode (need to set indent-line-function)
; tom:/usr1/eppstein/gnu/init.el,  9-Mar-1987 13:37:02 by eppstein
;   Put ^Z keys rearranged for libcat back where they were (lc now uses ^C)
; tom:/usr1/eppstein/gnu/init.el,  7-Mar-1987 14:33:41 by eppstein
;   Flush indent-nested in favor of new fn indent-relative-always.
;   Add help R for regexp info.  Other cleanups.
; tom:/usr1/eppstein/gnu/init.el,  4-Mar-1987 13:11:40 by eppstein
;   Flush pre-v18 edit history; move insert-date to cat.el
; tom:/usr1/eppstein/gnu/init.el,  2-Mar-1987 13:43:26 by eppstein
;   Set up for libcat mode: add to auto list, rearrange some keys
; tom:/usr1/eppstein/gnu/init.el, 27-Feb-1987 15:02:43 by eppstein
;   Automatically run rmail on .m files; ^Z tab always completes
; tom:/usr1/eppstein/gnu/init.el, 10-Feb-1987 14:43:59 by eppstein
;   ^Z =  runs count-lines-page
; tom:/usr1/eppstein/gnu/init.el,  6-Feb-1987 14:46:19 by eppstein
;   Make ^L run redraw-display (refresh screen w/o changing windows)
; tom:/usr1/eppstein/gnu/init.el,  5-Feb-1987 13:00:30 by eppstein
;   Indent with spaces instead of tabs in TeX mode (for \begin{program})
; tom:/usr1/eppstein/gnu/init.el, 30-Jan-1987 16:58:41 by eppstein
;   Add ^Z ^D toggle debug-on-error (stolen from DG).
; tom:/usr1/eppstein/gnu/init.el, 25-Jan-1987 16:28:07 by eppstein
;   Disable message telling how to restore windows after help.
; tom:/usr1/eppstein/gnu/init.el, 22-Jan-1987 17:01:41 by eppstein
;   Still more mode line hackery (avoid ml-buf-ident in dired).
; tom:/usr1/eppstein/gnu/init.el, 21-Jan-1987 14:48:34 by eppstein
;   Better para delims; cleaner patch-out of text-mode ESC s def.
; tom:/usr1/eppstein/gnu/init.el, 19-Jan-1987 13:59:40 by eppstein
;   Give up on TeX printer stuff (I like to keep my dvi files).
;   Make info load by defining text-mode-map.  Add disassembly help.
;   Improve C colon.  More mode line improvement (use ml-buffer-ident).
;   ^C Tab also works in minibuffer.  Simplify up- and down-comment-line.
; tom:/usr1/eppstein/gnu/init.el, 18-Jan-1987 17:55:42 by eppstein
;   Changes for v18: improved mode line (w/o any hooks needed),
;   move block comment stuff in C to tab (from lf) and make tab from
;   middle of line self-insert, improve C colon algorithm to only
;   reindent for labels instead of only not doing it for comments,
;   slow search lines variable name change and move ss to screen top,
;   lisp-complete-symbol moved to ^C Tab (from Esc Tab where RMS put it,
;   which conflicts with my placement of indent nested), flush
;   disablement of narrow-to-page.  Make TeX print send to copyrm.
;   The old init file is backed up in init17.el until v18 is official.

; Various random settings of Emacs parameters.
;
(setq require-final-newline 'ask	;Ask about missing final new line
      search-slow-window-lines -3	;More slow search ctxt, top of screen
      delete-auto-save-files t		;Flush auto saves when no longer wanted
      enable-recursive-minibuffer t	;Allow minibuf commands in minibuf
      next-screen-context-lines 1	;See more of new screen and less of old
      backup-by-copying-when-linked t	;Don't fragment multiply-linked files
      load-path (list (expand-file-name "~/gnu") ;Look for libs in my dir then
		      (expand-file-name "~/gnu/lib/lisp")) ;link to usual place
      inhibit-startup-message t)	;Flush stupid copyright notice etc

(defun print-help-return-message (&optional function)
  "Called by help to say what to do to get back old windows."
  nil)					;I can work it out myself, don't say it


; Set up for editing text and the like
;
(setq-default fill-column 72)		;Widen margins (newly working in v18)
(setq text-mode-hook 'turn-on-auto-fill) ;Also applies to mail- and tex-mode
(define-key text-mode-map "\es" nil)	;Center moved to ^Z c
(define-key text-mode-map "\eS" nil)	;why is this on cap S?
(setq auto-mode-alist (append '(("^/tmp/article" . text-mode)
				("/\\.rnhead$" . mail-mode)
				("\\.m$" . babyl-mode)
				("/lib/cat$" . libcat-mode))
			      auto-mode-alist))

(autoload 'libcat-mode "cat" "Set up to edit my library catalog")

; Deal with paragraph delimiters.
; The standard ones for TeX mode don't work with formfeeds, and the
; standard ones for mail mode don't work with dashed signature delimiters.
; Here we define one for all text like modes that covers all those cases.
;
; All paragraphs both start with and are separated by:
;   A blank line
;   A formfeed or dash at the start of a line
;   A backslash at the start of a line (likely a TeX para-delimiting macro)
;   A double dollarsign (TeX display math mode, best if this is at eol)
;
; A start of a line in this context is the actual line start followed
; by any number of open angle brackets, semicolons, slashes, stars, and
; whitespace.  This covers the common netnews quoting convention and most
; forms of programming language comment.
;
; We supply a function to set the delims; its argument should be t
; if we want to set the global version of the variables.
; If the argument is omitted it defaults to nil so this can be a hook.
;
(defun fix-para-delims (&optional default)
  "Reset paragraph delimiters for losing modes that think they know how."
  (let ((pss "^[>;/\\* \t]*[-\f\n\\\\]\\|\\$\\$\n"))
    (if (not default)			;Want it for this buffer only?
	(setq paragraph-separate pss	;Yes, just set local values
	      paragraph-start pss)
      (make-local-variable 'paragraph-start) ;Global, make sure have separate
      (make-local-variable 'paragraph-separate) ;global values to set
      (set-default 'paragraph-start pss) ;setq-default compiles wrong,
      (set-default 'paragraph-separate pss)))) ;work around with set- and quote

(fix-para-delims t)			;Get it right for now
(setq emacs-lisp-mode-hook 'fix-para-delims ;But most modes seem to think they
      lisp-mode-hook 'fix-para-delims	;know how to set it themselves, and
      lisp-interaction-mode-hook 'fix-para-delims) ;need to be told otherwise.

(defun TeX-mode-hook-code ()
  (load "TeX-changes")			;First time this is run, add hacks
  (TeX-mode-hook-code))			;Then run new definition of this fn

(setq TeX-mode-hook 'TeX-mode-hook-code)


; Key setting to make Emacs lisp code files easier to recompile
; Running make doesn't seem too useful for these files...

(define-key emacs-lisp-mode-map "\ez" 'byte-compile-this-file)
(defun byte-compile-this-file ()
  (interactive)
  (save-buffer)				;Write out changes
  (byte-compile-file (buffer-file-name))) ;Then recompile the file


; Get a prettier mode line.  Uses features from v18.
;
(setq-default mode-line-format
  '("--%*%*-%[ "			;Start line, mod/RO indicator
    (dired-directory			;Dired sets ml-buf-ident badly
     dired-directory			;So use directory name itself instead
     mode-line-buffer-identification)	;Otherwise filename, info node, etc
    " "					;Some spacing before global mode
    (global-mode-string " %M")		;Time if we want it (usually not)
    " (%m"				;Major mode name
    (rmail-current-message "" "%n")	;Narrow indication except for rmail
    minor-mode-alist			;Def, Abbrev, etc
    mode-line-process			;Stuff for subprocess modes
    ")  %p %]%-"))			;Percent through file, end of string

(setq-default mode-line-buffer-identification
  '(buffer-file-name "%f" "%b"))	;File name if we have one else buffer


; Flush silly novice mode command disablement.
;
(put 'eval-expression 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)


; Abbreviate yes or no answers.
;
(fset 'yes-or-no-p (symbol-function 'y-or-n-p))

; Mail

(defun babyl-mode ()
  "Same as rmail-mode, but suitable for auto-mode-alist"
  (interactive)
  (goto-char (point-min))		;Start at beginning of file
  (if (not (looking-at "BABYL OPTIONS:")) ;Make sure file is the right format
      (error "File is not Babyl format."))
  (rmail-mode)				;Set up local variables and keybindings
  (rmail-set-message-counters)		;Set up counts of messages in file
  (rmail-show-message))			;Go to a particular message (first one)

(autoload 'mail-mode "sendmail" "Major mode for editing mail to be sent." t)
(autoload 'rmail-mode "rmail" "Set up to read mail.")

(setq mail-aliases nil			;Set up so mail-mode send will work
      rmail-last-rmail-file "~/XMAIL"	;Along with rmail "O" command
      mail-mode-hook 'fix-para-delims)

(defun rmail-fix-mode-line-format ()
  (setq mode-line-format (default-value 'mode-line-format))
  (setq mode-line-buffer-identification
	(default-value 'mode-line-buffer-identification)))

(setq rmail-mode-hook 'rmail-fix-mode-line-format)

; Various key bindings to make more like ITS or maybe HAKLIB.

(defvar ctl-z-map (make-keymap)		;Make new keymap on variable
  "Keymap for auxiliary \\[ctl-z-prefix] functions")
(fset 'ctl-z-prefix ctl-z-map)		;Give it a name as a function too
(define-key global-map "\^z" 'ctl-z-prefix) ;Set it on the prefix key

(define-key esc-map "\^z" 'exit-recursive-edit)	;C-M-Z like C-M-C, exit recurse
(define-key esc-map "z" 'compile)	;M-Z runs compile, zap is moved

(define-key global-map "\^t" 'transpose-before-point)

(define-key global-map "\^l" 'redraw-display) ;^L doesn't change windows

(define-key esc-map "n" 'down-comment-line)
(define-key esc-map "p" 'up-comment-line)
(define-key ctl-z-map ";" 'kill-comment)

(define-key ctl-x-map "c" 'reverse-capitalize-word)
(define-key ctl-x-map "l" 'reverse-downcase-word)
(define-key ctl-x-map "u" 'reverse-upcase-word)

(define-key global-map "\^w" 'copy-region-as-kill)
(define-key esc-map "\^k" 'kill-region)
(define-key esc-map "\^d" 'kill-sexp)	;I never use down-list, flush it
(define-key ctl-z-map "\177" 'reverse-kill-sexp)

(define-key esc-map "\r" 'back-to-indentation)
(define-key esc-map " " 'my-just-one-space)
(define-key esc-map "o" 'break-line)
(define-key esc-map "\t" 'indent-relative-always) ;was lisp-complete
(define-key ctl-z-map "\t" 'lisp-complete-symbol) ;which is now here

(define-key ctl-z-map "t" 'move-to-window-top)
(define-key ctl-z-map "b" 'move-to-window-bottom)
(define-key ctl-z-map "e" 'move-to-window-line)	;This was -screen-edge in ITS

(define-key ctl-z-map "c" 'center-line)	;Displaced by char search

(define-key esc-map "s" 'char-search)	;Was center in text mode, see above
(define-key esc-map "r" 'reverse-char-search)
(define-key ctl-z-map "s" 'my-zap-to-char) ;Default zap misses char itself
(define-key ctl-z-map "r" 'reverse-zap-to-char)

(define-key help-map "f" 'disassemble)	;Show definition of compiled fn
(define-key help-map "\^f" 'disassemble-key)
(define-key help-map "r" 'help-regexp)	;Go to info node describing regexps

(define-key ctl-z-map "\^d" 'toggle-debug-on-error)

(define-key ctl-x-map "\\" 'switch-to-other-buffer)
(define-key ctl-x-map "\^b" 'buffer-menu)

(define-key esc-map "\^l" 'insert-page-marker)
(define-key ctl-z-map "\^l" 'page-menu)
(define-key ctl-z-map "=" 'count-lines-page)

(define-key ctl-z-map "w" 'date-edit)
(define-key ctl-z-map "d" 'insert-date)

(define-key ctl-x-map "#" 'shrink-wrap)
(define-key ctl-x-4-map "#" 'shrink-wrap-other-window)

; Key command definitions for above bindings.

(defun shrink-wrap ()
  "Resize the current window to fit its contents"
  (interactive)
  (let ((bufsize (count-lines (point-min) (point-max)))
	(winsize (window-height (selected-window))))
    (if (and (> bufsize 0)		;Don't shrink an empty buffer
	     (< bufsize winsize))	;Only make winsize smaller
	(enlarge-window (1+ (- bufsize winsize))))))

(defun shrink-wrap-other-window (n)
  "Resize the next window to fit its contents"
  (interactive "p")
  (let ((oldwin (selected-window)))
    (unwind-protect
	(progn (other-window n)
	       (shrink-wrap))
      (select-window oldwin))))

(setq window-min-height 1)		;Allow windows to be made tiny


(defun toggle-debug-on-error ()		;Stolen from DG with minor improvements
  "Cause debugger to start up on next error, or disable if already enabled."
  (interactive)
  (message "Debug on error %s."
	   (if (setq debug-on-error (not debug-on-error))
	       "enabled" "disabled")))


(defun down-comment-line (n)
  "Go down to comment on next line, creating a new one if nothing there."  
  (interactive "*p")
  (end-of-line)				;Go to end of line
  (let ((eol (point)))			;So we can remember pos to bound search
    (beginning-of-line)			;Start search at beginning of line
    (if (re-search-forward (concat "[ \t]*" comment-start-skip "[ \t]*"
				   (regexp-quote comment-end) "[ \t]*$")
			   eol t)	;Look for empty comment at EOL
	(delete-region (match-beginning 0) eol))) ;If found, flush
  (if (and (eobp) (> n 0))		;No lines to move forward through?
      (newline n)			;Yes, make some
    (forward-line n))			;Else move down to desired line
  (indent-for-comment))			;And indent it for comment

(defun up-comment-line (n)
  "Go up to previous comment line, creating a new one if nothing there."
  (interactive "*p")
  (down-comment-line (- n)))		;Negate our argument and run main fn


(defun switch-to-other-buffer ()
  "Like \\[switch-to-buffer] <return>."
  (interactive)
  (switch-to-buffer (other-buffer)))


(defun move-to-window-top ()
  "Go to start of first displayed line of window."
  (interactive)
  (move-to-window-line 0))

(defun move-to-window-bottom ()
  "Go to start of last displayed line of window."
  (interactive)
  (move-to-window-line -1))


(defun char-search (n c)
  "Search for given character; numarg is repcount."
  (interactive "p\ncSearch for char:")
  (search-forward (char-to-string c) nil nil n))

(defun reverse-char-search (n c)
  "Search backward for given character."
  (interactive "p\ncReverse search for char:")
  (char-search (- n) c))

(defun my-zap-to-char (n c)		;Redefine to work right
  "Kill up to and including ARG'th occurrence of CHAR.
Goes backward if ARG is negative; gives error if char not found."
  (interactive "*p\ncZap to char:")
  (kill-region (point) (progn (char-search n c) (point))))

(defun reverse-zap-to-char (n c)
  "Search and destroy backward."
  (interactive "*p\ncReverse zap to char:")
  (my-zap-to-char (- n) c))


(defun my-just-one-space (n)
  "Kill spaces leaving just one, or that many if given an argument.
If put on a key command other than (something) SPC, it will insert
that other final character instead of the spaces."
  (interactive "*p")
  (delete-horizontal-space)		;Kill all spaces
  (self-insert-command n))		;Then put n of them back


(defun indent-relative-always ()
  "Indent line like the previous indented line."
  (interactive "*")
  (let ((indent 0))
    (save-excursion
      (while (and (not (bobp)) (zerop indent)) ;Until we find indentation
	(forward-line -1)		;Keep looking back a line at a time
	(setq indent (current-indentation)))) ;Looking at indent of each
    (if (zerop indent)
	(error "No previous line is indented.")) ;Nothing to line up with
    (beginning-of-line)			;Go to start of line
    (delete-horizontal-space)		;Kill space there
    (indent-to indent)))		;Indent, leaving point at text start


(defun help-regexp ()
  "Shortcut to information about regular expressions."
  (interactive)
  (Info-find-node "emacs" "Regexps"))

(autoload 'Info-find-node "info")

(defun reverse-upcase-word (n)
  "Uppercase words behind point."
  (interactive "*p")
  (upcase-word (- n)))

(defun reverse-downcase-word (n)
  "Lowercase words behind point."
  (interactive "*p")
  (downcase-word (- n)))

(defun reverse-capitalize-word (n)
  "Capitalize words behind point."
  (interactive "*p")
  (capitalize-word (- n)))


(defun reverse-kill-sexp (n)
  "Like \\[kill-sexp] with a negative argument."
  (interactive "*p")
  (kill-sexp (- n)))


(defun break-line ()			;Same as ^R Break line
  "Break current line repeatedly until it fits within fill column."
  (interactive "*")
  (save-excursion			;Not changing eventual position
    (beginning-of-line)			;Find start of line
    (let ((start (point)))		;Save it in variable for fill
      (forward-line 1)			;Move past that line
      (fill-region-as-paragraph start (point) nil)))) ;And do the fill



(defun transpose-before-point ()
  "Transpose two characters before point."
  (interactive "*")
  (backward-char 1)			;Go back between the two
  (transpose-chars 1))			;Do transpose and move past them


(defun disassemble-key (key)
  "Find binding for key sequence and disassemble associated function."
  (interactive "kDisassemble key command: ")
  (let ((defn (key-binding key)))
    (if (or (null defn) (integerp defn)) ;integerp?  copied from describe-key
	(message "%s is undefined" (key-description key))
      (disassemble defn nil 0 t))))	;Looks normal, pry it apart


(autoload 'date-edit "date-edit" "Insert new line in edit history." t)
(autoload 'insert-date "cat"  "Insert current date in abbreviated format." t)

(defun insert-page-marker ()
  "Insert a form feed surrounded by newlines."
  (interactive "*")
  (if (not (bolp)) (insert ?\n))	;Make sure we start w/ new line
  (insert ?\^l)				;Add the formfgeed
  (if (or (eobp) (not (eolp))) (insert ?\n))) ;Make sure we end w/ new line

(autoload 'page-menu "page-menu" "Menu of pages from the current buffer." t)


(fmakunbound 'buffer-menu)		;Flush so autoload works
(autoload 'buffer-menu "buffer-menu" "Enter menu of buffers." t)

; /*
; ** C language mode changes.
; **
; ** GNU emacs C mode, as with many other GNU formatting decisions,
; ** seems to have gone in for gratuitous ugliness.  Here we attempt
; ** to counteract that somewhat.
; **
; ** In particular, my programming style is approximately that of K&R with
; ** 4-column tab stops.  Also, I use block comments like the one this
; ** comment within a comment uses.  To deal with the latter, I make
; ** linefeed within such a comment start another comment line, and I hack
; ** colon not to reindent within such a comment.
; */

(setq c-indent-level 4			;Indent w.r.t open brace line beginning
      c-continued-statement-offset 4	;Indent w.r.t controlling if or while
      c-brace-offset -4			;Add to above when line starts w/ brace
      c-argdecl-indent 0		;Indent for decls of function args
      c-label-offset -4			;Add to indent for labels and case tags
      c-tab-always-indent nil		;Only indent if at start of line
      c-mode-hook 'c-mode-hook-code)	;Make changes needed after C mode runs

(defun c-mode-hook-code ()
  "Set up for C code: fix paragraph delimiters, use new winning tab."
  (fix-para-delims)
  (setq indent-line-function 'c-block-comment-indent))

(define-key c-mode-map "\t" 'c-block-comment-indent) ;Understand /* ** */
(define-key c-mode-map ":" 'c-colon)	;Colon cares about block comments, C++

(defun c-block-comment-indent ()
  "Like normal C mode indenter, but with support for /* ** */ block comments."
  (interactive "*")
  (if (not (save-excursion		;Save place while check for block cmt
	(and (progn (skip-chars-backward " \t")	;Back over indent
		    (bolp))		;Should be at line start
	     (progn (forward-line -1)	;Beginning of previous line
		    (looking-at "[ \t]*[/*]\\*\\(.?\\|.*[^*][^/]\\)$")))))
      (c-indent-command)		;Call the normal C code indenter
    (delete-horizontal-space)		;Else in block, flush spaces
    (indent-relative-maybe)		;Indent this line like the last
    (insert "** ")))			;And insert block comment continuation

(defun c-colon (howmany)
  "Re-indent for label or case label only if not in comment.
If line starts with 'case', or if we are one word from line start,
then we assume we are a case label or regular label.  If neither
is the case, we are in a comment or doing something in C++, and
the correct behavior is just to self-insert."
  (interactive "*P")			;Raw argument needed by c mode function
  (if (or (save-excursion		;Save place while checking
	    (skip-chars-backward "a-zA-Z0-9_") ;Back across one word
	    (skip-chars-backward " \t")	;Then any whitespace
	    (bolp))			;Normal label is at line start
	  (save-excursion
	    (back-to-indentation)	;Other check: start of line text
	    (looking-at "case\b")))	;Looks like case label
      (electric-c-terminator howmany)	;One of two cases worked, go electric
      (self-insert-command (prefix-numeric-value howmany)))) ;No, self insert

; Final cleanup before we go

; re-run any hooks we've defined for our major mode
(funcall major-mode)
