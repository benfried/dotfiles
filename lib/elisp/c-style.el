; Definitions for buffer specific c-mode indentation style.
; Written by Daniel LaLiberte (liberte@a.cs.uiuc.edu)
; while at Gould.  This is free.

; There are several ways to call set-c-style.
;
; 1. Set the c-style variable in the local variables list 
;    with "c-style: GNU" or whatever you like and
;    call set-c-style without argument in c-mode-hook.
;
; 2. Call set-c-style with style argument in c-mode-hook.
;    This will set the style for every c file the same.
;
; 3. Put "eval: (set-c-style 'GNU)" in the local variables list.
; 
; 4. Call set-c-style interactively.  It prompts for the style name.

; The default value of c-style is default-c-style.
; I put (autoload 'set-c-style "c-style.el" nil t) in my .emacs.

;;; $Header: $
;;;
;;; $Log: $
;;;

;; Predefined styles
(defvar c-style-alist '(
  (GNU (c-indent-level . 2)
       (c-continued-statement-offset . 2)
       (c-brace-offset . 0)
       (c-argdecl-indent . 5)
       (c-label-offset . -2))
  (BSD (c-indent-level . 8)
       (c-continued-statement-offset . 8)
       (c-brace-offset . -8)
       (c-argdecl-indent . 8)
       (c-label-offset . -8))
  (K&R (c-indent-level . 5)
       (c-continued-statement-offset . 5)
       (c-brace-offset . -5)
       (c-argdecl-indent . 0)
       (c-label-offset . -5))
  (C++ (c-indent-level . 4)
       (c-continued-statement-offset . 4)
       (c-brace-offset . -4)
       (c-argdecl-indent . 4)
       (c-label-offset . -4))
  ))
   
(defvar default-c-style 'GNU
  "*The default value of c-style")
(defvar c-style default-c-style
  "*The buffer specific c indentation style.")



(defun set-c-style (&optional style)
  "Set up the c-mode style variables from the c-style variable or if
  STYLE argument is given, use that.  It makes the c indentation style 
  variables buffer local."

  (interactive)

  (let ((c-styles (mapcar 'car c-style-alist)))
	
    (if (interactive-p)
	(setq style
	      (let ((style-string ; get style name with completion
		     (completing-read
		      (format "Set c mode indentation style to (default %s): "
			      default-c-style)
		      (vconcat c-styles)
		      (function (lambda (arg) (memq arg c-styles)))
		      )))
		(if (string-equal "" style-string)
		    default-c-style
		  (intern style-string))
		)))
    
    (setq style (or style c-style)) ; use c-style if style is nil
    
    (make-local-variable 'c-style)
    (if (memq style c-styles)
	(setq c-style style)
      (error (concat "Bad c style: " style))
      )
    (message "c-style: %s" c-style)
      
    ; finally, set the indentation style variables making each one local
    (mapcar (function (lambda (c-style-pair)
			(make-local-variable (car c-style-pair))
			(set (car c-style-pair)
			     (cdr c-style-pair))))
	    (cdr (assq c-style c-style-alist)))
    c-style
    )
  )

