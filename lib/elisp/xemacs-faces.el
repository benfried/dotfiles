(defvar list-faces-sample-text "The quick brown fox jumps over the lazy dog.")

(defun list-faces-display ()
  "List all faces, using the same sample text in each.
The sample text is a string that comes from the variable
`list-faces-sample-text'.
 
It is possible to give faces different appearances in different frames.  This
command shows the appearance in the selected frame."
  (interactive)
  (let ((faces (sort (list-faces) (function string-lessp)))
        (face nil)
        (frame (selected-screen))
        disp-frame window)
    (with-output-to-temp-buffer "*Faces*"
      (save-excursion
        (set-buffer standard-output)
        (setq truncate-lines t)
        (while faces
          (setq face (car faces))
          (setq faces (cdr faces))
          (insert (format "%25s " (symbol-name face)))
          (let ((beg (point)))
            (insert list-faces-sample-text)
            (insert "\n")
            (set-extent-face (make-extent beg (1- (point))) face)))
        (goto-char (point-min))))
    ;; If the *Faces* buffer appears in a different frame,
    ;; copy all the face definitions from FRAME,
    ;; so that the display will reflect the selected frame.
    (setq window (get-buffer-window (get-buffer "*Faces*") t))
    (setq disp-frame (if window (window-screen window)
                       (car (frame-list))))
    (or (eq frame disp-frame)
        (let ((faces (list-faces)))
          (while faces
            (copy-face (car faces) (car faces) disp-frame)
            (setq faces (cdr faces)))))))
(provide 'xemacs-faces)
