;;; z29 key bindings 
;;;  - ben 25 May 1987
;;; This provides the terminal-dependent (or first-level, as it is referred
;;; to in keypad.el) function-key and keypad mapping for a zenith z29 terminal
;;; in ansi mode.  To get the keypad mappings --- ?0 -- ?9 --- you must turn
;;; keypad alt on in the setup menu.

;;; Edit History:
;;; cunixc:/u1/ui/ben/glisp/z29a.el, 25-May-1987 21:08:40 by ben
;;;   created.

(require 'keypad)			;map second-level key bindings.

(defvar z29-f-map (make-keymap)
  "Prefix for z29 function keys")

(defvar z29-c-map (make-keymap)
  "Prefix for z29 cursor and keypad keys")

(setup-terminal-keymap z29-c-map
		       '(("A" . ?u)	;up arrow
			 ("B" . ?d)	;down
			 ("C" . ?r)	;right
			 ("D" . ?l)	;left
			 ("~" . ??)	;help
			 ("H" . ?h)	;home
			 ("J" . ?c)	;erase
			 ("4h" . ?I)	;shifted keypad 7 (insert char)
			 ("P" . ?D)	;shifted keypad 9 (delet char)
			 ("L" . ?A)	;shifted keypad 1 (insert line)
			 ("M" . ?L)))	;shifted keypad 3 (delete line)

(setup-terminal-keymap z29-f-map
		       '(("S" . ?\C-a)	;F1
			 ("T" . ?\C-b)	;F2
			 ("U" . ?\C-c)	;F3
			 ("V" . ?\C-d)	;F4
			 ("W" . ?\C-e)	;F5
			 ("P" . ?\C-f)	;F6
			 ("Q" . ?\C-g)	;F7
			 ("R" . ?\C-h)	;F8
			 ("X" . ?\C-i)	;F9
			 ("w" . ?7)	;alt keypad 7
			 ("x" . ?8)	;alt keypad 8
			 ("y" . ?9)	;alt keypad 9
			 ("m" . ?-)	;alt keypad -
			 ("t" . ?4)	;alt keypad 4
			 ("u" . ?5)	;alt keypad 5
			 ("v" . ?6)	;alt keypad 6
			 ("l" . ?,)	;alt keypad ,
			 ("q" . ?1)	;alt keypad 1
			 ("r" . ?2)	;alt keypad 2
			 ("s" . ?3)	;alt keypad 3
			 ("M" . ?e)	;alt keypad enter
			 ("p" . ?0)	;alt keypad 0
			 ("n" . ?.)))	;alt keypad .

(fset 'z29-f-key z29-f-map)		;link keymappings to prefixes
(fset 'z29-c-key z29-c-map)

(define-key global-map "\eO" 'z29-f-key)

(define-key global-map "\e[" 'z29-c-key)
