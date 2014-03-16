; cat.el - emacs commands for editing my library catalog
; David Eppstein / Columbia University / 2 Mar 1987
;
; Edit history:
; tom:/usr1/eppstein/gnu/cat.el, 12-Mar-1987 16:18:12 by eppstein
;   Fix bug in insert-date (wna for insert-char)
; tom:/usr1/eppstein/gnu/cat.el,  4-Mar-1987 13:13:06 by eppstein
;   Move insert-date here from init (but leave keydef in init).
;   Change mode-specific keys to ^C not ^Z.  Improve lib entry start search.
; tom:/usr1/eppstein/gnu/cat.el,  2-Mar-1987 13:35:06 by eppstein
;   Create this file.
; tom:/usr1/eppstein/gnu/init.el, 18-Feb-1987 14:14:59 by eppstein
;   ^Z d  inserts current date, like so: 18 Feb 1987

(defun insert-date ()
  "Insert current date in abbreviated format."
  (interactive "*")
  (let* ((now (current-time-string))	;With ugly-printed timestamp
	 (firstchar (string-to-char (substring now 8 9))))
    (if (/= firstchar 32) (insert-char firstchar 1))
    (insert (substring now 9 10) " "	;Insert day of month
	    (substring now 4 7) " "	;Abbreviated name of month
	    (substring now 20 24))))	;Full year number

(defun libcat-mode ()
  "Set up to edit my library catalog.
\\{libcat-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (use-local-map libcat-mode-map)
  (setq mode-name "LibCat")
  (setq major-mode 'libcat-mode))	;No hooks for now

(defvar libcat-mode-map (make-sparse-keymap)
  "Command bindings for editing my library catalog")

(defun lib-location (place)
  (eval					;Want a defun, have to cons it up, sigh
    (list 'defun
	  (intern (concat "lib-location-" place))
	  '()
	  (concat "Set location of catalog entry to " place ".")
	  '(interactive "*")
	  (list 'set-lib-location place))))

(defun set-lib-location (place)
  "Set location of catalog entry to given place name."
  (interactive "*sLocation:")
  (re-search-backward "\\`\\|\^l\\|\n\n") ;Entry start: blank line, ffd, bob
  (let ((start (match-end 0)))
    (goto-char start)			;Skip past formfeed or newline
    (forward-char)
    (re-search-forward "\\'\\|\^l\\|^$") ;Find other end of entry
    (goto-char (match-beginning 0))
    (if (not (bolp)) (insert "\n"))	;Terminate final line if necessary
    (let ((end (point)))
      (skip-chars-backward "^@" start)	;Find atsign in entry if any
      (if (/= (point) start)		;Was there one?
	  (let ((here (point)))
	    (end-of-line)
	    (delete-region here (point))) ;Kill old entry
	(goto-char end)
	(insert-before-markers "@\n")	;Add new entry
	(backward-char))
      (insert " " place ", ")		;Add place name with punctuation
      (insert-date)))			;Together with today's date
    (re-search-forward "\\'\\|\^l\\|^$") ;Go to end of entry
    (goto-char (match-beginning 0)))

(define-key libcat-mode-map "\^cc" (lib-location "Columbia"))
(define-key libcat-mode-map "\^cm" (lib-location "Morningside"))
(define-key libcat-mode-map "\^cr" (lib-location "Ramona"))
