Article 1008 of net.emacs:
Relay-Version: version B 2.10.3 4.3bsd-beta 6/6/85; site garfield.columbia.edu
Path: garfield!columbia!seismo!gatech!akgua!whuxlm!whuxl!houxm!ihnp4!gargoyle!oddjob!matt
From: matt@oddjob.UUCP (Matt Crawford)
Newsgroups: net.emacs
Subject: tvi950.el for GNU emacs
Message-ID: <1233@oddjob.UUCP>
Date: 14 Mar 86 03:37:28 GMT
Date-Received: 17 Mar 86 09:17:10 GMT
Reply-To: matt@oddjob.UUCP (Matt Crawford)
Organization: U. Chicago, Astronomy & Astrophysics
Lines: 151

;; tvi950 package for GNU emacs
;; January 1986; Matt Crawford

;; This file makes the FUNCT key act like a meta key, moving
;; the old binding of C-A to the nearby BACK TAB key.  It also
;; provides setup-for-f-keys, bind-f-key, and show-{f,F}-labels.
;; If tvi-arrows is bound and non-nil then the key bindings are
;; scrambled to accomodate the arrow keys (down up left right
;; are C-V C-K C-H C-L respectively.)

(defun funct-key ()
  "Make the TVI's FUNCT key act like a META key"
  (interactive)
  (let ((save-key (read-char)))
    (if (/= (read-char) ?\^M)
	(error "bad C-A or FUNCT key usage")
      (setq prefix-arg current-prefix-arg
	    unread-command-char (logior save-key 128)))))

;; move the old function of C-A
(define-key esc-map "I" (key-binding "\^A")) ; BACK TAB
(define-key global-map "\^A" 'funct-key)

(defvar f-key-map nil "Keymap for tvi950 F-keys") ;May not need to make one
(defvar f-labels
"1      2      3      4      5      6      7      8      9      10      11     "
	"*Labels for unshifted f-keys")
(defvar F-labels f-labels "*Labels for shifted F-keys")

(defun setup-for-f-keys (pref-string f1-char F1-char)
  "Bind the tvi950 F-keys thru a keymap on PREF-STRING.
Keys begin at f1-CHAR within the keymap, shifted keys at F1-CHAR.
If PREF-STRING is already a keymap, use it, else create one."
  (let ((keydef (lookup-key global-map pref-string)))
    (cond ((numberp keydef) (error "key sequence %s is too long" pref-string))
	  ((keymapp keydef) (setq f-key-map keydef))
	  (t
	   (setq f-key-map (make-keymap))
	   (fset 'f-key-prefix f-key-map)
	   (define-key global-map pref-string 'f-key-prefix) ;This works!
	   )))
  ;; save the following for later reference ...
  (setq f-key-prefix pref-string	; now its boundp AND fboundp
	first-f-key f1-char
	first-F-key F1-char)
  (load-f-keys))

;; The next defun is so ugly that only its author could love it ...
(defun bind-f-key (key command label)
  "Bind TVI f-key NUMBER to COMMAND and give it the 5 character LABEL
on the 25th line.  Shifted f-keys are NUMBERed 12 thru 22"
  (interactive "nKey number: \nCCommand: \nsLabel: ")
  (let (shift)
    (and (> key 11) (setq shift t key (- key 11))
	 (or (> key 11) (< key 1)) (error "Key number out of range!"))
    (define-key f-key-map
      (char-to-string (+ key -1 (if shift first-F-key first-f-key)))
      command)
    (apply
     '(lambda (s n) (set s (concat (substring (eval s) 0 n)
				   (substring (concat label "     ") 0 5)
				   (substring (eval s) (+ n 5)))))
     (list (if shift 'F-labels 'f-labels)
	   (+ (* 7 key) -6 (/ key 10) (/ key 11)) )) ))

(defun P-quote (string)
  "Quote control chars in STRING with ^P, for TVI terminal"
  (let ((result ""))
    (while (> (length string) 0)
      (setq result (concat result
			   (and (or (< (string-to-char string) 32)
				    (= (string-to-char string) 127))
				"\^P")
			   (substring string 0 1)))
      (setq string (substring string 1)))
    result))

(defun load-f-keys ()
  "Program the TVI950 f-keys.  Call only from or after setup-for-f-keys."
  (interactive)
  (let ((ps (P-quote f-key-prefix))
	(key 0))
    (while (< key 11)
      (send-string-to-terminal
       (concat "\e|"
	       (char-to-string (+ key ?1))
	       "1"
	       ps
	       (char-to-string (+ key first-f-key))
	       "\^Y\e|"
	       (char-to-string (+ key ?<))
	       "1"
	       ps
	       (char-to-string (+ key first-F-key))
	       "\^Y"
	       )
       )
      (setq key (1+ key)))))

;;; always want green on black for labels so that underlining is clear
(setq f-label-heads (if (string-match "rv" (getenv "TERM"))
			   '("\^[f\^[G4" . "\^[f\^[G<")
			   '("\^[f\^[G0" . "\^[f\^[G8") ))

(defun show-f-labels ()
  "Display labels for unshifted f-keys"
  (interactive)
  (send-string-to-terminal (concat (car f-label-heads) f-labels "\^M"))
  (fset 'toggle-f-labels 'show-F-labels))

(defun show-F-labels ()
  "Display labels for shifted F-keys"
  (interactive)
  (send-string-to-terminal (concat (cdr f-label-heads) F-labels "\^M"))
  (fset 'toggle-f-labels 'show-f-labels))

;; two functions for those who choose to have arrow keys ---
(defun previous-window (&optional arg)
  "Move to the ARG'th previous window."
  (interactive "p")
  (other-window (- arg)))

(defun scroll-other-window-down (&optional arg)
  "Scroll text of next window downward ARG lines"
  (interactive "P")
  (scroll-other-window (cond ((null arg) '-)
			     ((eq arg '-) nil)
			     (t (- (prefix-numeric-value arg))))))

(if (and (boundp 'tvi-arrows) tvi-arrows)
    (progn
      ;; make the arrow keys act in the intuitive fashion
      (define-key global-map "\^v" 'next-line)		;down arrow
      (define-key global-map "\^k" 'previous-line)	;up arrow
      (define-key global-map "\^h" 'backward-char)	;left arrow
      (define-key global-map "\^l" 'forward-char)	;right arrow
      ;; move the old functions of the above
      (define-key global-map "\^n" 'scroll-up)
      (define-key global-map "\^_" 'help-command) (setq help-char ?\^_)
      ;; for consistency with arrows and C-N ...
      (define-key esc-map "\^v" 'other-window)       	;M-down
      (define-key esc-map "\^k" 'previous-window)	;M-up
      (define-key esc-map "\^h" 'backward-word)		;M-left
      (define-key esc-map "\^l" 'forward-word)		;M-right
      (define-key global-map "\^p" 'scroll-down)
      (define-key esc-map "n" 'scroll-other-window)
      (define-key esc-map "p" 'scroll-other-window-down)))

;; These don't hurt, and you can add more ---
(define-key esc-map "T" 'kill-line)	;LINE ERASE
(define-key esc-map "Y" 'recenter)	;PAGE ERASE


