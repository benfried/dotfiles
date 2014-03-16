;;; rolo.el
;;; An e-lisp version of Ron Hitchins rolo program
;;; Paul Davis <davis%scr@sdr.slb.com> Feb & Apr 1989

;;;-----------------------------------------------------------------
;;; This file is subject to the same copyright conditions as
;;; GNU Emacs.

;;; To do:
;;;
;;; make rolo a bit more elegantly tolerant of wierd end of file
;;; conditions - basically ignore everything after the last
;;; occurence of rolo-card-delimiter, as if eobp were true
;;; there.
;;; ----------------------------------------------------------------

(defvar rolo-card-delimiter ""
  "Regexp used to delimit cards in a Rolo buffer")

(defvar rolo-card-delimiter-regexp (concat "^" rolo-card-delimiter)
  "Regexp used to locate start and end of cards in a Rolo buffer")

(defvar rolo-card-total nil
  "Total number of rolo cards in current rolo-mode buffer")

(defun rolo (&optional rolofile)
  "
Visit ROLOFILE and display as a series of sequential `rolodex' type cards.
Numerous functions are available for locating, searching and indexing
the cards, as well as creating new ones. By default, visit a
file \".rolo\" in the current directory.

The ROLOFILE format is compatible with the program `rolo', and
consists of each card terminated by the character rolo-card-delimiter
(^L by default). Each card MUST be terminated in this way, and extra
white space after the last occurence of rolo-card-delimiter may
confuse poor rolo-mode. If you stick to using \[rolo-create-card] and
\[rolo-delete-card] to add and remove cards, you'll be fine.

\{rolo-mode-map}"
  (interactive
   (list (read-file-name "Rolo file: " default-directory ".rolo")))
  (find-file (expand-file-name rolofile))
  (rolo-mode))

;; Rolo mode itself

(defun rolo-mode ()
  "A mode for viewing rolo-compatible files within Emacs.
Note that by default, searching in this mode is case-insensitive. If
you wish to alter this, add a rolo-mode-hook to your .emacs file.

\\{rolo-mode-map}"

  (interactive)
  (widen)
  (setq major-mode 'rolo-mode)
  (setq mode-name "Rolo")
  (use-local-map rolo-mode-map)
  (set-syntax-table text-mode-syntax-table)
; (setq mode-line-format '("" mode-line-modified 
;			   mode-line-buffer-identification 
;			   "   " global-mode-string "   %[(" 
;			   mode-name "%n" mode-line-process 
;			   ")%]" "-%-"))
  (setq case-fold-search t)
  (setq rolo-card-total (rolo-count-cards-to (point-max)))
  (if (> (buffer-size) 0)
      (rolo-show-card 1)
    (rolo-create-card)
    (rolo-update-mode-line))
  (run-hooks 'rolo-mode-hook))

;; 
;; Keymaps

(defvar rolo-mode-map (copy-keymap text-mode-map)
  "Keymap for rolo-mode")

(define-key rolo-mode-map "\C-cc" 'rolo-create-card)
(define-key rolo-mode-map "\C-cd" 'rolo-delete-card)
(define-key rolo-mode-map "\C-c\C-d" 'rolo-delete-card)
(define-key rolo-mode-map "\C-ci" 'rolo-index)
(define-key rolo-mode-map "\C-c\C-i" 'rolo-index)
(define-key rolo-mode-map "\C-cn" 'rolo-next-card)
(define-key rolo-mode-map "\C-c\C-n" 'rolo-next-card)
(define-key rolo-mode-map "\C-cp" 'rolo-previous-card)
(define-key rolo-mode-map "\C-c\C-p" 'rolo-previous-card)
(define-key rolo-mode-map "\C-cr" 'rolo)
(define-key rolo-mode-map "\C-cs" 'rolo-search)
(define-key rolo-mode-map "\C-cg" 'rolo-show-card)
(define-key rolo-mode-map "\C-x\C-s" 'rolo-save-buffer)

;; 
;; Displaying the cards

(defun rolo-show-card (&optional n)
  "
Display the current card, (that which point is currently within), 
or the Nth card if N is non-null."
  (interactive "pn")
  (if (null n)
      (rolo-intern-display-this-card)
    (let ((here (point)))
      (widen)
      (goto-char (point-min))
      (if (null (re-search-forward rolo-card-delimiter-regexp 
				   (point-max) t n))
	  (progn
	    (goto-char here)
	    (rolo-show-card)
	    (ding)
	    (message "no such card")))
      (previous-line 1)
      (rolo-intern-display-this-card))))

(defun rolo-intern-display-this-card ()
  (narrow-to-region (rolo-card-beg)
		    (max 1 (1- (rolo-card-end))))
  (rolo-update-mode-line))

(defun rolo-update-mode-line ()
  "Make sure mode-line in the current buffer reflects all changes."
  (setq mode-line-process
	(concat " " (rolo-count-cards-to (point)) "/" rolo-card-total))
  (set-buffer-modified-p (buffer-modified-p))
  (sit-for 0))

(defun rolo-count-cards-to (position)
  (let ((n 0))
    (save-restriction
      (widen)
      (goto-char (point-min))
      (while (re-search-forward rolo-card-delimiter-regexp position t)
	(setq n (1+ n))
	(forward-line 1)))
    (max 1 n)))

;; motion control

(defun rolo-next-card (&optional n)
  "
Show the next card, or the Nth-next card if N is non-null."
  (interactive "pn")
  (rolo-forward-card n)
  (rolo-show-card))


(defun rolo-previous-card (&optional n)
  "
Show the previous card, or the Nth-previous card if N is non-null."
  (interactive "pn")
  (rolo-backward-card n)
  (rolo-show-card))

(defun rolo-forward-card (&optional n)
  "
Move to next rolo card, or N cards forward if N is non-null."
  (let ((here (point)))
    (widen)
    (if (or (null (re-search-forward rolo-card-delimiter-regexp 
				     (point-max) t n))
	    (eobp))
	(progn
	  (ding)
	  (message "no such card")
	  (goto-char here))
      (forward-line 1))))

(defun rolo-backward-card (&optional n)
  "
Move to previous rolo card, or Nth previous if N is non-null."
  (let ((here (point)))
    (widen)
  (if (null (re-search-backward rolo-card-delimiter-regexp 
				(point-min) t n))
      (progn
	(ding)
	(message "no such card")
	(goto-char here))
    (previous-line 1))))
    
;; 
;; Searching

(defvar rolo-search-regexp nil
  "Last regexp used by rolo-search")
(make-variable-buffer-local 'rolo-search-regexp)

(defun rolo-search (regexp)
  (interactive 
   (list (read-string (concat "Rolo Search for" 
				  (if rolo-search-regexp
				   (concat " ("
					   rolo-search-regexp
					   ")"))
				  ":"))))
  (if (equal "" regexp)
      (setq regexp rolo-search-regexp
	    repeat t)
    (setq repeat nil))
  (let ((start (point-min))
	(end (point-max))
	(here (point)))
    (rolo-forward-card)
    (widen)
    (if repeat
	(forward-char 1))
    (if (null (re-search-forward regexp (point-max) t))
	(progn
	  (narrow-to-region start end)
	  (goto-char here)
	  (message (concat "\"" regexp "\" not found.")))
      (save-excursion
	(rolo-show-card)))
    (setq rolo-search-regexp regexp)))

(defun rolo-card-beg ()
  "
Return the beginning of the current card as point."
  (save-excursion
    (if (null (re-search-backward
	       rolo-card-delimiter-regexp (point-min) t))
	(point-min)
      (+ 2 (point)))))

(defun rolo-card-end ()
  "
Return the end of the current card as point."
  (save-excursion
    (if (null (re-search-forward
	       rolo-card-delimiter-regexp (point-max) t))
	(point-max)
      (point))))

;;
;; miscelleania

(defvar rolo-occur-buffer nil)
(defvar rolo-occur-nlines nil)
(defvar rolo-occur-pos-list nil)

(defun rolo-index ()
  (interactive)
  (let ((start (point-min))
	(end (point-max))
	(card-count 0))
    (setq rolo-occur-buffer (current-buffer))
    (progn
      (widen)
      (goto-char (point-min))
      (with-output-to-temp-buffer "*Rolo Index*"
	(rolo-make-index-entry)
	(while (re-search-forward rolo-card-delimiter-regexp (point-max) t)
	  (forward-line 1)
	  (rolo-make-index-entry))
	(narrow-to-region start end)
	(set-buffer standard-output)
	(goto-char (point-min))
	(rolo-occur-mode)))))


(defun rolo-make-index-entry ()
  (setq card-count (1+ card-count))
  (if (not (eobp))
      (princ (concat card-count ": "
		     (buffer-substring (point) (eol)) "\n"))))

(defun rolo-create-card ()
  (interactive)
  (widen)
  (goto-char (point-max))
  (if (= (point) 1)
      (insert "\n" rolo-card-delimiter)
    (insert "\n" "\n" rolo-card-delimiter))
  (backward-char 2)
  (narrow-to-region (point) (point))
  (setq rolo-card-total (1+ rolo-card-total)))

(defun rolo-delete-card ()
  (interactive)
  (widen)
  (kill-region (rolo-card-beg) (rolo-card-end))
  (if (looking-at "\n")
      (delete-char 1))
  (setq rolo-card-total (1- rolo-card-total))
  (rolo-show-card))

(defun rolo-save-buffer ()
"Save a rolo-mode buffer, ensuring that there is an occurence of
rolo-delimiter-regexp at the end before actually writing back to the file."
  (interactive)
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-max))
      (backward-char 1)
      (if (not (looking-at rolo-card-delimiter))
	  (progn
	    (backward-char 1)
	    (if (looking-at rolo-card-delimiter)
		(progn
		  (forward-char 1)
		  (delete-char 1)))))
      (save-buffer))))

;; utility functions (who hasn't written these ?)

(defun eol ()
  "Return the value point at the end of the current line."
  (save-excursion
    (end-of-line)
    (point)))

(defvar rolo-index-mode-map ())
(if rolo-index-mode-map
    ()
  (setq rolo-index-mode-map (make-sparse-keymap))
  (define-key rolo-index-mode-map "\C-c\C-c" 'rolo-occur-mode-goto-occurrence))


(defun rolo-occur-mode ()
  "Major mode for output from \\[rolo-index].
Move point to one of the occurrences in this buffer,
then use \\[rolo-index-mode-goto] to go to the same occurrence
in the buffer that the occurrences were found in.
\\{rolo-index-mode-map}"
  (kill-all-local-variables)
  (use-local-map rolo-index-mode-map)
  (setq major-mode 'rolo-occur-mode)
  (setq mode-name "Rolo-Occur")
  (make-local-variable 'occur-buffer))


(defun rolo-occur-mode-goto-occurrence ()
  "Go to the card this occurrence was found in, in the buffer it was found in."
  (interactive)
  (if (or (null rolo-occur-buffer)
	  (null (buffer-name rolo-occur-buffer)))
      (progn
	(setq rolo-occur-buffer nil)
	(error "Buffer in which occurences were found is deleted.")))
  (beginning-of-line)
  (if (looking-at "[0-9]*")
      (let ((start (match-beginning 0))
	    (end (match-end 0)))
	(setq cardnum (string-to-int (buffer-substring start end))))
    (error "You've been deleting things!"))
  (pop-to-buffer rolo-occur-buffer)
  (rolo-show-card cardnum)
  (pop-to-buffer "*Rolo Index*"))

