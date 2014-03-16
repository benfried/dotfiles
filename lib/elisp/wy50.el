(require 'keypad)

(defvar wy50-f-map (make-keymap)
  "Prefix for wyse-50 function keys")

(setup-terminal-keymap wy50-f-map
		       '(("A" . ?u)	;up arrow
			 ("B" . ?d)	;down
			 ("C" . ?r)	;right
			 ("D" . ?l)	;left
			 ("P" . ?\C-@)	;F1
			 ("Q" . ?\C-a)	;F2
			 ("R" . ?\C-b)	;F3
			 ("S" . ?\C-c)	;F4
			 ("T" . ?\C-d)	;F5
			 ("U" . ?\C-e)	;F6
			 ("V" . ?\C-f)	;F7
			 ("W" . ?\C-g)  ;F8
			 ("X" . ?\C-h)	;F9
			 ("Y" . ?\C-i)	;F10
			 ("Z" . ?\C-j)	;F11
			 ("[" . ?\C-k)));F12


(fset 'wy50-f-key wy50-f-map)		;link keymappings to prefixes

(define-key global-map "\eO" 'wy50-f-key)
			 
