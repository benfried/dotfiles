(defun mm-yyyy () "return mm yyyy type date" 
  (let ((date (current-time-string))
	(month (substring (current-time-string) 4 7))
	(year (substring (current-time-string) 20 nil)))
    (concat
     (cond ((string= month "Jan") "1")
	   ((string= month "Feb") "2")
	   ((string= month "Mar") "3")
	   ((string= month "Apr") "4")
	   ((string= month "May") "5")
	   ((string= month "Jun") "6")
	   ((string= month "Jul") "7")
	   ((string= month "Aug") "8")
	   ((string= month "Sep") "9")
	   ((string= month "Oct") "10")
	   ((string= month "Nov") "11")
	   ((string= month "Dec") "12")) " " year)))

(defun display-calendar (date) "display a calendar in a buffer"
  (interactive (list (read-string-with-default "date" (mm-yyyy))))
  (switch-to-buffer-other-window "*cal*")
  (erase-buffer)
  (setq x date)
  (shell-command (concat "/usr/bin/cal " date) t)
  (window-to-size)
  (other-window -1))


;; Calendar window function; copyright (C) 1987, Edward M. Reingold.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY.  The author accepts no responsibility to
;; anyone for the consequences of using it or for whether it serves
;; any particular purpose or works at all.
;; Everyone is granted permission to copy, modify, and redistribute
;; this function.
;; This notice must be preserved on all copies.
;;
;; Comments, corrections, and improvements should be sent to
;;         Edward M. Reingold
;;         Department of Computer Science
;;         University of Illinois at Urbana-Champaign
;;         1304 West Springfield Avenue
;;         Urbana, Illinois 61801
;;
;;         reingold@a.cs.uiuc.edu
;;
;; Modified 11/20/87 for month offset arguments
;;  Constantine Rasmussen            Sun Microsystems, East Coast Division
;;  (617) 671-0404                   2 Federal Street;  Billerica, Ma.  01824
;;  ARPA: cdr@sun.com   USENET: {cbosgd,decvax,hplabs,seismo}!sun!suneast!cdr
;;
;;
;; This function requires the Unix programs date and cal.

(defconst month-alist
      '(("Jan" . 1) ("Feb" . 2)  ("Mar" . 3)  ("Apr" . 4)
        ("May" . 5) ("Jun" . 6)  ("Jul" . 7)  ("Aug" . 8)
        ("Sep" . 9) ("Oct" . 10) ("Nov" . 11) ("Dec" . 12))
      "association list of months/sequence numbers")

(defun calendar (&optional month-offset)
  "Display a calendar of the current month, surrounded by calendars of the
   previous and next months.  The cursor is left indicating the date.
   A prefix argument, if any, will be treated as an offset to the present
   month to find the month to display.  In this case the day will be the
   first of the month."
  (interactive "P")
  (progn
    (set-buffer (get-buffer-create "*Calendar*"))
    (message "Getting calendar...")
    (setq buffer-read-only nil)
    (erase-buffer)
    (call-process-region (point-min) (point-max) "date" t t)
    (goto-char (point-min))
    (re-search-forward
     " \\([A-Z][a-z][a-z]\\) *\\([0-9]*\\) .* \\([0-9]*\\)$" nil t)
    (let
	((day (or (and month-offset " 1") 
		  (buffer-substring (match-beginning 2) (match-end 2))))
	 (month
	  (int-to-string
	   (cdr (assoc (buffer-substring (match-beginning 1) (match-end 1))
		       month-alist))))
	 (year (buffer-substring (match-beginning 3) (match-end 3))))
      (cond (month-offset
	     (setq month-offset (+ (+ (* (string-to-int year) 12)
				      (- (string-to-int month) 1))
				   month-offset))
	     (setq month (int-to-string (+ (% month-offset 12) 1)))
	     (setq year (int-to-string (/ month-offset 12)))))
      (erase-buffer)
      (call-process-region (point-min) (point-max) "cal" nil t nil month year)
      (goto-char (point-min))
      (next-line 2)
      (search-forward day)
      (backward-char 1)
      (make-local-variable 'today)
      (setq today (dot-marker))
      (let ((last-month
	     (int-to-string
	      (if (string-equal month "1")
		  12
		(1- (string-to-int month)))))
            (last-month-year
	     (if (string-equal month "1")
		 (int-to-string (1- (string-to-int year)))
	       year)))
        (goto-char (point-min))
        (insert "                        ")
        (setq top-right (dot-marker))
        (insert "\n")
        (call-process-region (point-min) (point-min)
                             "cal" nil t nil last-month last-month-year)
        (previous-line 1)
        (setq bottom-left (dot-marker))
        (kill-rectangle (marker-position top-right)
                        (marker-position bottom-left))
        (delete-region (marker-position top-right)
                       (marker-position bottom-left))
        (yank-rectangle))
      (let ((next-month
	     (int-to-string
	      (if (string-equal month "12")
		  1
		(1+ (string-to-int month)))))
            (next-month-year
	     (if (string-equal month "12")
		 (int-to-string (1+ (string-to-int year)))
	       year)))
        (goto-char (point-min))
        (insert "                        ")
        (setq top-right (dot-marker))
        (insert "\n")
        (call-process-region (point-min) (point-min)
                             "cal" nil t nil next-month next-month-year)
        (previous-line 1)
        (setq bottom-left (dot-marker))
        (kill-rectangle (marker-position top-right)
                        (marker-position bottom-left))
        (delete-region (marker-position top-right)
		       (marker-position bottom-left))
        (goto-char (point-min))
        (next-line 1)
        (insert "                        ")
        (end-of-line)
        (yank-rectangle))
      (goto-char (point-min))
      (next-line 1)
      (delete-region (point) (point-min))
      (setq buffer-read-only t)
      (goto-char (marker-position today))
      (switch-to-buffer-other-window "*Calendar*")
      (let ((h (1- (window-height)))
            (l (count-lines (point-min) (point-max))))
        (or (one-window-p t)
            (<= h l)
            (shrink-window (- h l)))))
    (message "Hit any key to continue...")
    (read-char)
    (bury-buffer)
    (delete-window)))

