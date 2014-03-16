; Hacked buffer menu for GNU emacs
;
; The two buffer menu type modes available in GNU emacs are
; electric-buffer-list and buffer-menu.  Of the two, buffer-menu
; is by far the cleaner (better help, no silly prompts, all
; normal EMACS motion commands available).  But the other has
; the advantage of starting on the current buffer, and making
; space act like buffer-menu's "q", so that a space as the first
; command will return you to the state you were in before you
; entered the menu.
;
; Here we define some functions to augment the buffer-menu command
; so that they have a similar functionality.  In addition, we make
; space expunge the buffers before exiting, we add "e" as a synonym
; to "x" for expunging without exiting, and we add "." to go back
; to the initially selected buffer.
;
; Edit history:
; garfield:/usr1/eppstein/gnu/buffer-menu.el, 13-Nov-1986 15:18:16 by eppstein
;   Move buffer-menu from init.el to its own file.
; garfield:/usr1/eppstein/gnu/init.el,  8-Apr-1986 15:52:05 by eppstein
;   Back to buffer-menu -- electric-buffer-list is just too ugly.
;   Also add " ", "e", and "." in buffer menu, and make it do initial ".".
; garfield:/usr1/eppstein/gnu/init.el,  7-Apr-1986 16:57:56 by eppstein
;   Use electric-buffer-list instead of buffer-menu.

(define-key Buffer-menu-mode-map " " 'Buffer-menu-exit) ;Same as "eq"
(define-key Buffer-menu-mode-map "q" 'Buffer-menu-abort) ;Exit w/o kills
(define-key Buffer-menu-mode-map "e" 'Buffer-menu-execute) ;Same as "x"
(define-key Buffer-menu-mode-map "." 'Buffer-menu-dot) ;Find curr selection

(defun buffer-menu (arg)
  "Make a menu of buffers so you can save, kill or select them.
With argument, show only buffers that are visiting files.
Type ? after invocation to get help on commands available within.

Varies from standard \\[buffer-menu] in not giving a message and
in starting at the currently selected buffer (if there is one)."
  (interactive "P")
  (list-buffers)			;Get buffer list (does all real work)
  (pop-to-buffer "*Buffer List*")	;Select it as current window
  (Buffer-menu-dot))			;Find current selection, no message.

(defun Buffer-menu-dot ()
  "Move to line for currently selected buffer.
If there is none (i.e. we were called from minibuffer) then
we leave point at the start of the buffer."
  (interactive)
  (goto-char (point-min))		;Find start of buffer
  (if (search-forward "\n." (point-max) t) ;Look for current buf marker
      (backward-char 1)))		;Back over dot to line start

(if (not (fboundp 'Buffer-menu-abort))	;If we have not already done this
    (fset 'Buffer-menu-abort (symbol-function 'Buffer-menu-select))) ;Add name

(defun Buffer-menu-exit ()
  "Like \\[Buffer-menu-execute] followed by \\[Buffer-menu-select]."
  (interactive)
  (Buffer-menu-execute)
  (Buffer-menu-select))
