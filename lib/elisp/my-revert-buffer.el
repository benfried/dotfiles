
;;; normal revert buffer won't restore dot if a find-file-hook exists.
;;; also uses verbose yes-or-no-p instead of winning y-or-n-p in one
;;; place.  and even worse, it worries about auto-save files (yech).
;;; this is a 'fixed' version.

(defun my-revert-buffer (arg)
  "Replace the buffer text with the text of the visited file on disk.
This undoes all changes since the file was visited or saved."
  (interactive "P")
  (let* ((odot (point))
	 (file-name buffer-file-name))
    (cond ((null file-name)
	   (error "Buffer does not seem to be associated with any file"))
	  ((not (file-exists-p file-name))
	   (error "File %s no longer exists!" file-name))
	  ((y-or-n-p (format "Revert buffer from file %s? " file-name))
	   (and buffer-read-only
		(not (y-or-n-p "Buffer is read-only. Revert anyway? "))
		(signal 'buffer-read-only nil))
	   (let ((buffer-read-only nil))
	     (erase-buffer)
	     (insert-file-contents file-name t))
	   (after-find-file t)
	   (goto-char (min odot (dot-max)))
	   (message "")))))
