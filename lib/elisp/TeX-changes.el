; Changes to GNU emacs TeX mode
; Must be loaded after normal TeX mode stuff
;
; Edit history:
; tom:/usr1/eppstein/gnu/TeX-changes.el, 14-Apr-1987 14:07:35 by eppstein
;   Add TeX interaction mode so can talk to TeX on error
;   (like for instance get it to exit normally so we get a log file).
; tom:/usr1/eppstein/gnu/TeX-changes.el,  4-Apr-1987 12:47:59 by eppstein
;   Create this file.

(setq TeX-mode-hook 'TeX-mode-hook-code) ;In case not run after init.el

(defun TeX-mode-hook-code ()
  (setq paragraph-separate		;Better paragraph delimiter
	(setq paragraph-start "^[>;/\\* \t]*[-\f\n\\\\]\\|\\$\\$\n"))
  (setq indent-tabs-mode nil))		;Indent w/spaces for prog mode

(setq TeX-mode-map (make-sparse-keymap)) ;Start mode-specific keys from scratch
(define-key TeX-mode-map "\^ce" 'TeX-close-LaTeX-block)
(define-key TeX-mode-map "\^ck" 'TeX-kill-job)
(define-key TeX-mode-map "\^cp" 'TeX-print)
(define-key TeX-mode-map "\^cq" 'TeX-show-print-queue)
(define-key TeX-mode-map "\^ct" 'TeX-file)
(define-key TeX-mode-map "\ez" 'TeX-file)

(defvar TeX-process nil "Current TeX/print/queue process")

(defun TeX-check-process ()
  "Make sure it's safe to run a new process in the *TeX* buffer"
  (if (and TeX-process
	   (not (eq (process-status TeX-process) 'exit)))
      (error "Old TeX process still running; use ^C K to kill it.")))

(defun TeX-kill-job ()
  "Kill the currently running TeX process"
  (interactive)
  (if (null TeX-process)
      (error "No TeX process is currently running."))
  (kill-process TeX-process)
  (setq TeX-process nil))

(defun TeX-print ()
  "Send output file associated with this TeX source to the printer."
  (interactive)
  (TeX-check-process)
  (if (null buffer-file-name) (error "Buffer has no associated file name."))
  (let ((dvi-file-name
	 (concat (substring buffer-file-name 0
			    (string-match ".tex$" buffer-file-name))
		 ".dvi")))
    (if (not (file-exists-p dvi-file-name))
	(error "Output file for %s doesn't exist" buffer-file-name))
    (let ((file-mod-time (nth 5 (file-attributes buffer-file-name)))
	  (dvi-mod-time (nth 5 (file-attributes dvi-file-name))))
	(if (or (< (car dvi-mod-time) (car file-mod-time))
		(and (= (car dvi-mod-time) (car file-mod-time))
		     (< (car (cdr dvi-mod-time)) (car (cdr file-mod-time)))))
	    (error "Output file %s is older than TeX source." dvi-file-name)))
    (setq TeX-process
	  (start-process "TeX print" "*TeX*" "lpr" "-d" dvi-file-name))))

(defun TeX-check-buffer ()
  "Make sure it's safe to run a process, and set up to display its output."
  (TeX-check-process)
  (with-output-to-temp-buffer "*TeX*"))	;Make pop-up window but don't select

(defun TeX-show-print-queue ()
  "Show print queue for our TeX output"
  (interactive)
  (TeX-check-buffer)
  (setq TeX-process (start-process "TeX queue" "*TeX*" "lpq")))

(defun TeX-file ()
  "Run TeX on this file"
  (interactive)
  (TeX-check-buffer)
  (save-window-excursion
    (switch-to-buffer "*TeX*")
    (TeX-interaction-mode))		;Make possible to talk to TeX
  (save-buffer)
  (setq TeX-process (start-process "TeX" "*TeX*" "tex" buffer-file-name)))

(defun TeX-interaction-mode ()
  "Mode for talking to TeX subprocess.
\\{tex-interaction-mode-map}"
  (interactive)				;Interactive use unlikely but possible
  (kill-all-local-variables)
  (setq major-mode 'TeX-interaction-mode)
  (setq mode-name "TeX interaction")
  (use-local-map tex-interaction-mode-map))

(defvar tex-interaction-mode-map (make-sparse-keymap) "Keymap used in *TeX*.")
(define-key tex-interaction-mode-map "\r" 'tex-interact)

(defun tex-interact ()
  "Send a line of input to the TeX error process"
  (interactive "*")
  (if (or (null TeX-process)
	  (not (eq (process-status TeX-process) 'run)))	;run not distinguished
      (error "No TeX process is running")) 		;from IO wait in UNIX
  (beginning-of-line)
  (if (not (looking-at "\\?"))		;maybe we should allow other prompts?
      (error "Line does not begin with TeX error prompt"))
  (forward-char)			;if so, this move across ? needs work
  (let ((start (point)))
    (end-of-line)
    (insert "\n")
    (send-string TeX-process (buffer-substring start (point)))))

(funcall major-mode)			;Rerun TeX-mode or whatever
