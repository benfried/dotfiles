; page-menu -- page menu function for GNU emacs
; David Eppstein / Columbia University / 8 April 1986
;
; We enter a menu with one line per page, giving the number
; and first line of that page.  This menu is exited by a space,
; which returns to the buffer at the start of the given page.
;
; This menu is invoked by the function page-menu, with no arguments.
;
; Edit history:
; tom:/usr1/eppstein/gnu/page-menu.el, 14-Apr-1987 13:52:40 by eppstein
;   Kill locals when running page menu mode.
; tom:/usr1/eppstein/gnu/page-menu.el, 25-Jan-1987 17:27:48 by eppstein
;   Use with-output-to-temp-buffer; improve mode line for v18
; garfield:/usr1/eppstein/gnu/page-menu.el, 28-Nov-1986 14:54:21 by eppstein
;   Improve behavior when original buffer has been killed when we exit.
;   Change window re-use behavior on exit so any window not already
;   looking at the menu or its original buffer stays as it was.
;   Fix window so tail of previous page doesn't show.  Other minor changes.
; garfield:/usr1/eppstein/gnu/page-menu.el, 29-Apr-1986 16:46:40 by eppstein
;   Slight reformatting of strings
; garfield:/usr1/eppstein/gnu/page-menu.el, 27-Apr-1986 16:56:38 by eppstein
;   Add page sizes, column and string params, prettier formatting

(defvar page-menu-mode-map (make-sparse-keymap) "Keymap used in page menu.")
(define-key page-menu-mode-map " " 'page-menu-exit)

(defvar page-menu-prefix "Pages of " "Prefix for page menu buffer name.")
(defvar page-menu-suffix ""          "Suffix for page menu buffer name.")

(defvar page-menu-format "%4d %4d  %s\n"
  "Format for lines in menu; pnum, size, text")

(defvar page-menu-first-line "  Pg  Siz  Text\n"
  "Header that goes above the first line of the text.")

(defvar page-menu-header-length 1 "How many lines in page-menu-first-line")

(defvar page-menu-text-length 65 "Max length of page first text line abstract")

(defvar page-menu-buffer-ident '("%b")	;Need parens to get string expanded
  "What to tell v18+ mode lines for this buffer's identification")

(defvar paged-buffer nil
  "Buffer for which this is the page menu.")
;(make-variable-buffer-local 'paged-buffer)

(defvar paged-buffer-name nil
  "Name of buffer for which this is the page menu.")
;(make-variable-buffer-local 'paged-buffer-name)


; Define the mode used for page menus.  The only difference from the
; standard fundamental mode is that space runs the function which
; exits the page menu.

(defun page-menu-mode ()
  "Mode used within \\[page-menu].  Fundamental, with space exiting.
\\{page-menu-mode-map}"
  (interactive)				;Interactive use unlikely but possible
  (kill-all-local-variables)
  (setq major-mode 'page-menu-mode)
  (setq mode-name "Page Menu")
  (setq mode-line-buffer-identification page-menu-buffer-ident)
  (use-local-map page-menu-mode-map))


; Here we define the page menu function itself.
; This reads the current buffer, finding the start of each page
; and adding corresponding lines in the page menu buffer, then
; runs page-menu-mode on the buffer and leaves it selected.
; The rest will happen when the user types a space to exit.

(defun page-menu ()
  "Enter a menu of pages for the current buffer.
Exit with space on line corresponding to desired page."
  (interactive)
  (let ((menu-buffer (concat page-menu-prefix (buffer-name) page-menu-suffix))
	(home-buffer (current-buffer))	;A different name for paged-buffer
	(page-number 1)
	(page-size 0)
	(next-page-beginning -1)
	(old-point (save-excursion (end-of-line) (point))) ;after page delim
	(old-page 0)
	(line-text nil))
    (save-excursion			;But not changing pos in orig buffer
      (widen)				;Using all of it
      (goto-char (point-min))		;Beginning of buffer
      (forward-page)			;Make sure at least one page
      (if (eobp) (error "buffer only has one page"))
      (goto-char (point-min))		;Beginning of buffer again
      (with-output-to-temp-buffer menu-buffer ;Making new buf, output to there
	(princ page-menu-first-line)	;Make header line
	(while (not (eobp))		;For each page until eob
	  (save-excursion		;Stay at bop until later
	    (forward-page)		;Find start of next page
	    (setq next-page-beginning (point)))	;Remember end of page
	  (setq page-size (count-lines (point) next-page-beginning)) ;nlines
	  (re-search-forward "\\w" next-page-beginning t) ;First text line
	  (beginning-of-line)		;Find start of line
	  (princ			;Send line of info to menu buffer
	   (format page-menu-format page-number page-size
		   (buffer-substring (point) ;grab to end or far along
				     (min (+ (point) page-menu-text-length)
					  (progn (end-of-line) (point))))))
	  (goto-char next-page-beginning) ;Move on to next page
	  (setq page-number (1+ page-number)) ;Bump page counter
	  (if (<= (point) old-point)	;If old point wasn't there
	      (setq old-page (1+ old-page)))))) ;Then need to bump old page too
    (pop-to-buffer menu-buffer)	;Menu buf made and displayed, select it
    (setq paged-buffer home-buffer	;Remember home
	  paged-buffer-name (buffer-name home-buffer)) ;and its name
    (page-menu-mode)			;This is a page menu
    (goto-char (point-min))		;Back to front
    (forward-line (+ page-menu-header-length old-page)))) ;This page's line


; This function is what gets run when the user types a space from a menu.
; It makes sure the original buffer is still around and if so selects it,
; going to the appropriate page.  If it was killed, we give our own
; error message rather than letting pop-to-buffer do it for us.

(defun page-menu-exit ()
  "Return from a page menu, selecting page of current line."
  (interactive)
  (beginning-of-line)
  (if (not (looking-at "[ \t]*[0-9]+")) ;First check that we have a page number
      (error "Not pointing to a page number"))

  (if (buffer-name paged-buffer)	;Buffer-name returns nil if buf is dead

    ;; Normal case, buffer is not dead, select it and go to page.
    (let ((page-number (string-to-int (buffer-substring (point) (point-max))))
	  (orig-buf-window (get-buffer-window paged-buffer))
	  (pm-buffer (current-buffer)))
      (if (null orig-buf-window)	;If orig buffer has lost its window
	  (switch-to-buffer paged-buffer) ;use this one instead
	(select-window orig-buf-window)) ;else still has one, go there.
      (delete-windows-on pm-buffer)	;Flush any remaining menu windows
      (kill-buffer pm-buffer)		;No longer need page menu itself
      (widen)				;Use whole file
      (goto-char (point-min))		;Counting pages from file start
      (forward-page (1- page-number))	;Go to the start of the right page
      (if (and (eolp) (not (eobp)))	;If page delimiter takes up whole line
	  (forward-char 1)		;Move on to start of next line
	(beginning-of-line))		;Else move back to view delim too
      (set-window-start (selected-window) (point))) ;Fix up window for pretty

    ;; Here when our original buffer has been killed.  Clean up and abort.
    (let ((orig-buf-name paged-buffer-name) ;Need the values of these
	  (pm-buffer (current-buffer)))	;after window and buffer kills.
      (delete-windows-on pm-buffer)	;Get rid of windows on useless menu
      (kill-buffer pm-buffer)		;and the menu itself.
      (error "Buffer %s no longer exists." orig-buf-name))))
