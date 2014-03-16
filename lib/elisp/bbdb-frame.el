;;
;; Author: Michael D. Carney 
;; Module: bbdb-frame.el
;; Version: 2.0
;; Created: Jan 19, 1995
;; Modified:
;;     Michael D. Carney  27th July 1995
;;         Changed everything from screens to frames, and added a quit option to
;;	   just delete the frame.
;; Description:
;;     Puts the *BBDB* buffer into a separate frame and uses that frame to
;;     display the *BBDB* buffer whenever it needs to.
;;

(require 'advice)

(defvar bbdb-frame-parameter-alist nil
 "*Alist of frame parameters used for creating the BBDB frame.")

(defvar bbdb-frame nil)

(defvar bbdb-frame-name "BBDB"
  "Used to name the frame that holds the *BBDB* buffer")

(defun bbdb-resolve (var arg)
 (if (or (and (symbolp var) (fboundp var))
	 (and (listp var) (eq (car var) 'lambda)))
     (funcall var arg)
   var))

(defvar bbdb-separate-frame t
  "If true, then put the *BBDB* buffer in its own frame")

(defun bbdb-toggle-separate-frame (&optional onoff)
  "Toggle the separate frame functionality."
  (interactive "P")
  (setq bbdb-separate-frame (if onoff
				 (> (if (numberp onoff) onoff
				      (prefix-numeric-value onoff))
				    0)
			       (not bbdb-separate-frame)))
  (if bbdb-separate-frame
      (progn
	(define-key bbdb-mode-map "q" 'bbdb-quit-frame))
    (if bbdb-frame
	(progn
	  (delete-frame bbdb-frame)
	  (setq bbdb-frame nil)))
    (define-key bbdb-mode-map "q" 'bbdb-bury-buffer)))

(defun bbdb-select-frame ()
 "Create and/or select and raise the BBDB frame for the *BBDB* buffer."
 (interactive)
 (if bbdb-separate-frame
     (let* ((fname (expand-file-name bbdb-file))
	    (new-frame (not (frame-live-p bbdb-frame))))
       (if new-frame
	   (setq bbdb-frame (make-frame
			      (append (bbdb-resolve bbdb-frame-parameter-alist
						    (file-name-nondirectory fname))
				      (list (cons 'name bbdb-frame-name))))))
       (select-frame bbdb-frame)
       (make-frame-visible bbdb-frame)
       (switch-to-buffer bbdb-buffer-name)
       (delete-other-windows)
       (raise-frame bbdb-frame)
       )))

(defadvice bbdb-display-records-1 (before
				   frame-bbdb-activate
				   first
				   activate)
  "BBDB is started inside its own frame (bbdb-frame)."
  (bbdb-select-frame))

(defun bbdb-iconify ()
  "Saves the current folder and iconifies the current frame."
  (interactive)
  (bbdb-save-db)
  (and (frame-live-p (selected-frame))
       (iconify-frame (selected-frame))))

(defun bbdb-quit-frame ()
  "Saves the current folder and iconifies the current frame."
  (interactive)
  (bbdb-save-db)
  (and (frame-live-p (selected-frame))
       (delete-frame (selected-frame))))

(setq bbdb-frame-parameter-alist '((width . 80)
				    (height . 20)
				    (left . 100)
				    (top . 100)))


(define-key bbdb-mode-map "T" 'bbdb-toggle-separate-frame)
(define-key bbdb-mode-map "i" 'bbdb-iconify)
(define-key bbdb-mode-map "q" 'bbdb-quit-frame)

(bbdb-toggle-separate-frame 1)

(provide 'bbdb-frame)
;; end bbdb-frame.el
