;;; toolbar.el --- fake a toolbar in XEmacs

;; Copyright 1994 (C) Andy Piper <ajp@eng.cam.ac.uk>

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;;
;; toolbar.el v1.2:
;;
;; Defines toolbar accelerations for frequently used commands.
;; M-x toolbar activates it.
;;
;; Only works in XEmacs (aka Lucid) 19.10+

(require 'annotations)
(if (not (featurep 'xpm))
    (error "Sorry, can't have toolbars without xpm!"))

(defvar toolbar-lit-colour "Gray90"
  "Highlight colour for a toolbar icon.")

(defvar toolbar-shade-colour "Gray40"
  "Shade colour for a toolbar icon.")

(defvar toolbar-background-colour "Gray75"
  "Background colour for a toolbar icon.")

(defvar toolbar-default-toolbar
  '([toolbar-file-icon		find-file	t]
    [toolbar-folder-icon	dired		t]
    [toolbar-disk-icon		save-buffer	t]
    [toolbar-printer-icon	print-buffer	t]
    [toolbar-cut-icon		kill-region	t]
    [toolbar-copy-icon		copy-region-as-kill t]
    [toolbar-paste-icon		yank		t]
    [toolbar-undo-icon		undo		t]
    [toolbar-spell-icon		ispell-buffer	t]
    [toolbar-replace-icon	query-replace	t]
    [toolbar-mail-icon		vm		t]
    [toolbar-info-icon		info		t]
    [toolbar-about-icon		toolbar-about	t])
  "The default toolbar for a buffer.")

(defvar toolbar-vertical-p nil
  "If t then current toolbar is displayed vertically.")
(make-variable-buffer-local 'toolbar-vertical-p)

(defvar current-toolbar "*toolbar*"
  "The current buffer's toolbar.")
(make-variable-buffer-local 'current-toolbar)

(defvar current-toolbar-annotations nil
  "The current buffer's toolbar's annotations, (because extent-at is broken).")
(make-variable-buffer-local 'current-toolbar-annotations)

(defvar current-toolbar-window nil
  "The window that the current toolbar is in.")

(defun toolbar (&optional vert action)
"Toggle a toolbar for the current buffer.
With prefix arg toggle a vertical toolbar.
With optional ACTION, 1 turns the toolbar on, 0 turns the toolbar off."
  (interactive "P")
  (let ((b (current-buffer))
	(tool current-toolbar))
    ;; clean up wrong oriented toolbars
    (if (not (and (get-buffer tool)
		  (not (eq (if vert t nil) toolbar-vertical-p)))) nil
      (delete-windows-on (get-buffer tool))
      (kill-buffer (get-buffer tool)))
    (setq toolbar-vertical-p (if vert t nil))
    ;; check for toolbar window
    (if (not (window-live-p current-toolbar-window))
	(if (not (eq action 0))
	    ;; split window if we didn't find one
	    (let ((s 1))
	      ;; hardcoded uggh - how do I set these to pixel values ?
	      (setq window-min-width 6)
	      (setq window-min-height 4)
	      (while 
		  (not (condition-case nil
			   (split-window (selected-window) s 
					 toolbar-vertical-p)
			 (error nil)))
		(setq s (+ s 1)))
	      ;; ... or create it.
	      (if (not (get-buffer tool))
		  (add-toolbar toolbar-default-toolbar))
	      (switch-to-buffer tool)
	      (setq current-toolbar-window (selected-window))
	      (set-window-buffer-dedicated (selected-window) "*toolbar*")
	      (select-window (get-buffer-window b))))

      (if (not (eq action 1))
	  ;; delete the window ...
	  (progn
	    (delete-window current-toolbar-window)
	    (setq current-toolbar-window nil))))
    ;; make sure we can split the remaining window
    (setq split-height-threshold (window-height))))

(defun window-live-p (window)
  "Return non-nil if window has not been deleted."
  (memq window (toolbar-window-list)))

;; pinched from saveconf
(defun toolbar-window-list (&optional mini)
  "Returns a list of Lisp window objects for all Emacs windows.
Optional first arg MINIBUF t means include the minibuffer window
in the list, even if it is not active.  If MINIBUF is neither t
nor nil it means to not count the minibuffer window even if it is active."
  (let* ((first-window (next-window (previous-window (selected-window)) mini))
         (windows (cons first-window nil))
         (current-cons windows)
         (w (next-window first-window mini)))
    (while (not (eq w first-window))
      (setq current-cons (setcdr current-cons (cons w nil)))
      (setq w (next-window w mini)))
    windows))

(defun add-toolbar (tool-spec)
  "Attach a toolbar with TOOL-SPEC to current-buffer."
  (save-excursion
    (set-buffer (get-buffer-create current-toolbar)))
  (setq current-toolbar-annotations nil)
  (mapcar '(lambda (x) 
	     (add-toolbar-item (symbol-value (aref x 0))
			       (aref x 1) (aref x 2)))
	  (reverse tool-spec)))

(defun add-toolbar-item (glyph-pair fun enabled-p)
  "Add a toolbar item to the current toolbar. 
GLYPH-PAIR are the glyphs to use, FUN is the function to perform."
  (if (not (get-buffer current-toolbar))
      (error "There is no toolbar attached to this buffer."))

  (let ((anot nil)
	(vert toolbar-vertical-p))
    (save-excursion
      (set-buffer current-toolbar)
      (setq buffer-read-only nil)
      ;; add new lines for vertical toolbars
      (if (not vert) nil
	(goto-char (point-min))
	(newline)
	(goto-char (point-min)))
      (setq anot (make-annotation (car glyph-pair) (point) 'text nil t 
				  (nth 1 glyph-pair)))
      (set-annotation-data anot (list fun enabled-p))
      (set-annotation-action anot 'toolbar-click)
      (setq buffer-read-only t))
    (setq current-toolbar-annotations 
	  (cons anot current-toolbar-annotations))))

(defun delete-toolbar-item (glyph-pair)
  "Delete a toolbar item from the current toolbar. 
GLYPH-PAIR are the glyphs to search for."
  (save-excursion
    (let ((annots current-toolbar-annotations))
      (mapcar '(lambda (x) 
		 (if (eq (annotation-glyph x) (car glyph-pair))
		     (progn
		       (if (not toolbar-vertical-p) nil
			 (set-buffer current-toolbar)
			 (setq buffer-read-only nil)
			 (goto-char (extent-start-position x))
			 (kill-line)
			 (setq buffer-read-only t))
		       (delete-annotation x))))
	      annots))))

(defun toolbar-click (data ext)
  "Function to be called when a toolbar item is clicked on."
  (if (and (nth 1 data)
 	   (eval (nth 1 data)))
      (call-interactively (car data))))

(defun toolbar-make-pixmap-pair (s)
  "Make an xpm pixmap and its mask from a string."
  (let ((s1 s)
	(s2 s))
    (setq s1 (concat (substring s 0 (string-match "red" s))
		     toolbar-lit-colour
		     (substring s (match-end 0))))
    (setq s1 (concat (substring s1 0 (string-match "green" s1))
		     toolbar-shade-colour
		     (substring s1 (match-end 0))))
    (setq s1 (make-pixmap (concat (substring s1 0 (string-match "Gray75" s1))
				  toolbar-background-colour
				  (substring s1 (match-end 0)))))
    (setq s2 (concat (substring s 0 (string-match "red" s))
		     toolbar-shade-colour
		     (substring s (match-end 0))))
    (setq s2 (concat (substring s2 0 (string-match "green" s2))
		     toolbar-lit-colour
		     (substring s2 (match-end 0))))
    (setq s2 (make-pixmap (concat (substring s2 0 (string-match "Gray75" s2))
				  toolbar-background-colour
				  (substring s2 (match-end 0)))))
    (set-pixmap-contributes-to-line-height s1 t)
    (set-pixmap-contributes-to-line-height s2 t)
    (list s1 s2)))

(defun toolbar-about ()
  (interactive)
  (message "This toolbar brought to you by andy piper, ;-)."))

(defvar toolbar-file-icon
  (toolbar-make-pixmap-pair
   "/* XPM */
static char * file[] = {
\"32 32 6 1\",
\" 	c red\",
\".	c green\",
\"X	c Gray75\",
\"o	c black\",
\"O	c white\",
\"+	c Gray60\",
\"                                \",
\"                               .\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXooooooooooXXXXXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOooXXXXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOo+oXXXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOo++oXXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOoooooXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXXXXXXooooooooooooooXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  ..............................\",
\" ...............................\"};")
   "A file icon pair.")

(defvar toolbar-folder-icon
  (toolbar-make-pixmap-pair "/* XPM */
static char * folder[] = {
\"32 32 6 1\",
\" 	c red\",
\".	c green\",
\"X	c Gray75\",
\"o	c black\",
\"O	c white\",
\"+	c Gray60\",
\"                                \",
\"                               .\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXooooooXXXXXXXXXXXXXXXXXX..\",
\"  XXXoOOOOOOoXXXXXXXXXXXXXXXXX..\",
\"  XXXoOOOOOOooooooooooXXXXXXXX..\",
\"  XXXoOOOOOOOOOOOOOOOoXXXXXXXX..\",
\"  XXXoOOOOOOOOOOOOOOOoXXXXXXXX..\",
\"  XXXoOOOOOOOOOOOOOOOoXXXXXXXX..\",
\"  XXXoOOOOOOOOOOOOOOOoXXXXXXXX..\",
\"  XXXoOOOOOOooooooooooooooooXX..\",
\"  XXXoOOOOOoo+++++++++++++ooXX..\",
\"  XXXoOOOOoo+++++++++++++ooXXX..\",
\"  XXXoOOOoo++oooooo+++++ooXXXX..\",
\"  XXXoOOoo+++++++++++++ooXXXXX..\",
\"  XXXoOoo++ooo++++++++ooXXXXXX..\",
\"  XXXooo+++++++++++++ooXXXXXXX..\",
\"  XXXoooooooooooooooooXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  ..............................\",
\" ...............................\"};")
  "A folder icon pair")

(defvar toolbar-disk-icon
  (toolbar-make-pixmap-pair
   "/* XPM */
static char * disk[] = {
\"32 32 7 1\",
\" 	c red\",
\".	c green\",
\"X	c Gray75\",
\"o	c black\",
\"O	c Gray60\",
\"+	c Gray90\",
\"@	c Gray40\",
\"                                \",
\"                               .\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXooooooooooooooooooXXXXX..\",
\"  XXXXXoOOo++++++++++oOOoXXXXX..\",
\"  XXXXXoOOo++++++++++oOOoXXXXX..\",
\"  XXXXXoOOo++++++++++oOooXXXXX..\",
\"  XXXXXoOOo++++++++++oOOoXXXXX..\",
\"  XXXXXoOOo++++++++++oOOoXXXXX..\",
\"  XXXXXoOOo++++++++++oOOoXXXXX..\",
\"  XXXXXoOOo++++++++++oOOoXXXXX..\",
\"  XXXXXoOOo++++++++++oOOoXXXXX..\",
\"  XXXXXoOOooooooooooooOOoXXXXX..\",
\"  XXXXXoOOOOOOOOOOOOOOOOoXXXXX..\",
\"  XXXXXoOOOOOOOOOOOOOOOOoXXXXX..\",
\"  XXXXXoOOooooooooooooOOoXXXXX..\",
\"  XXXXXoOOo@@@@@@@o++oOOoXXXXX..\",
\"  XXXXXoOOo@@@@@@@o++oOOoXXXXX..\",
\"  XXXXXoOOo@@@@@@@o++oOOoXXXXX..\",
\"  XXXXXXoOo@@@@@@@o++oOOoXXXXX..\",
\"  XXXXXXXooooooooooooooooXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  ..............................\",
\" ...............................\"};")
  "A disk icon pair.")

(defvar toolbar-printer-icon
  (toolbar-make-pixmap-pair
   "/* XPM */
static char * printer[] = {
\"32 32 8 1\",
\" 	c red\",
\".	c green\",
\"X	c Gray75\",
\"o	c black\",
\"O	c white\",
\"+	c Gray60\",
\"@	c Gray90\",
\"#	c Gray40\",
\"                                \",
\"                               .\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXoooooooooXXXXXXXXXXXXX..\",
\"  XXXXXXoOOOOOOOooXXXXXXXXXXXX..\",
\"  XXXXXXoOooooOOoXoXXXXXXXXXXX..\",
\"  XXXXXXoOOOOOOOoooooooXXXXXXX..\",
\"  XXXXXXoOoooOOOOOOoXo+ooXXXXX..\",
\"  XXXXXXoOOOOOOOOOOoo++++oXXXX..\",
\"  XXXXXXoooooooooooo++++ooXXXX..\",
\"  XXXXXo@@@@@@@@@@@o+++o+oXXXX..\",
\"  XXXXo@@@@@@@@@@@@@o+o++oXXXX..\",
\"  XXXooooooooooooooooo+++oXXXX..\",
\"  XXXo@@@@@@@@@@@@@@@o+++oXXXX..\",
\"  XXXo@@@@@@@@@@@@@@@o++ooXXXX..\",
\"  XXXo@@@@@@@@@@@@@@@o+ooXXXXX..\",
\"  XXXo@@@@@@@@@@@@@@@oo#oXXXXX..\",
\"  XXXooooooooooooooooo#oXXXXXX..\",
\"  XXXXoXXXXXXXXXXXXXo#oXXXXXXX..\",
\"  XXXXXoXXXXXXXXXXXo#oXXXXXXXX..\",
\"  XXXXXoXXXXXXXXXXXooXXXXXXXXX..\",
\"  XXXXXXooooooooooooXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  ..............................\",
\" ...............................\"};")
  "A printer icon pair.")

(defvar toolbar-cut-icon
  (toolbar-make-pixmap-pair
   "/* XPM */
static char * cut[] = {
\"32 32 6 1\",
\" 	c red\",
\".	c green\",
\"X	c Gray75\",
\"o	c black\",
\"O	c Gray90\",
\"+	c white\",
\"                                \",
\"                               .\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXoooooXXXXXXXXXXXXXXXXXX..\",
\"  XXXXooXXXooXXXXXXXXXXXXXXXXX..\",
\"  XXXooXXXXXooXXXXXXXXXXoooXXX..\",
\"  XXXoXXXXXXXoXXXXXXXXooOOooXX..\",
\"  XXXooXXXXXoooXXXXXooOOooXXXX..\",
\"  XXXXooXXXoooooXXXoooooXXXXXX..\",
\"  XXXXXoooooXXXooooooXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXo+oXXXXXXXXXXX..\",
\"  XXXXXoooooXXXooooooXXXXXXXXX..\",
\"  XXXXooXXXoooooXXXoooooXXXXXX..\",
\"  XXXooXXXXXoooXXXXXooOOooXXXX..\",
\"  XXXoXXXXXXXoXXXXXXXXooOOooXX..\",
\"  XXXooXXXXXooXXXXXXXXXXoooXXX..\",
\"  XXXXooXXXooXXXXXXXXXXXXXXXXX..\",
\"  XXXXXoooooXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  ..............................\",
\" ...............................\"};")
  "A cut icon pair.")

(defvar toolbar-copy-icon
  (toolbar-make-pixmap-pair
   "/* XPM */
static char * copy[] = {
\"32 32 6 1\",
\" 	c red\",
\".	c green\",
\"X	c Gray75\",
\"o	c black\",
\"O	c white\",
\"+	c Gray60\",
\"                                \",
\"                               .\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXoooooooooXXXXXXXXXXXXXX..\",
\"  XXXXXoOOOOOOOooXXXXXXXXXXXXX..\",
\"  XXXXXoOOOOOOOo+oXXXXXXXXXXXX..\",
\"  XXXXXoOoooooOooooXXXXXXXXXXX..\",
\"  XXXXXoOOOOOOOOOOoXXXXXXXXXXX..\",
\"  XXXXXoOooooOOOOOoXXXXXXXXXXX..\",
\"  XXXXXoOOOOOOOOOOoXXXXXXXXXXX..\",
\"  XXXXXoOOOOOoooooooooXXXXXXXX..\",
\"  XXXXXoOooOOoOOOOOOOooXXXXXXX..\",
\"  XXXXXoOOOOOoOOOOOOOo+oXXXXXX..\",
\"  XXXXXoOOOOOoOoooooOooooXXXXX..\",
\"  XXXXXoOOOOOoOOOOOOOOOOoXXXXX..\",
\"  XXXXXoOOOOOoOooooOOOOOoXXXXX..\",
\"  XXXXXoooooooOOOOOOOOOOoXXXXX..\",
\"  XXXXXXXXXXXoOOOOOOOOOOoXXXXX..\",
\"  XXXXXXXXXXXoOoooooooOOoXXXXX..\",
\"  XXXXXXXXXXXoOOOOOOOOOOoXXXXX..\",
\"  XXXXXXXXXXXoOOOOOOOOOOoXXXXX..\",
\"  XXXXXXXXXXXoOOOOOOOOOOoXXXXX..\",
\"  XXXXXXXXXXXoOOOOOOOOOOoXXXXX..\",
\"  XXXXXXXXXXXooooooooooooXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  ..............................\",
\" ...............................\"};")
  "A copy icon pair.")

(defvar toolbar-paste-icon
  (toolbar-make-pixmap-pair
   "/* XPM */
static char * paste[] = {
\"32 32 7 1\",
\" 	c red\",
\".	c green\",
\"X	c Gray75\",
\"o	c black\",
\"O	c Gray90\",
\"+	c Gray60\",
\"@	c white\",
\"                                \",
\"                               .\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXooXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXoOOoXXXXXXXXXXXX..\",
\"  XXXXXXooooooOooOooooooXXXXXX..\",
\"  XXXXXo++++oOOOOOOo++++oXXXXX..\",
\"  XXXXXo+++oooooooooo+++oXXXXX..\",
\"  XXXXXo++++++++++++++++oXXXXX..\",
\"  XXXXXo++++++++++++++++oXXXXX..\",
\"  XXXXXo++++++++++++++++oXXXXX..\",
\"  XXXXXo++++++++++++++++oXXXXX..\",
\"  XXXXXo++++++++++++++++oXXXXX..\",
\"  XXXXXo++++++oooooooooooXXXXX..\",
\"  XXXXXo++++++o@@@@@@@@ooXXXXX..\",
\"  XXXXXo++++++o@@@@@@@@o+oXXXX..\",
\"  XXXXXo++++++o@oooooo@ooooXXX..\",
\"  XXXXXo++++++o@@@@@@@@@@@oXXX..\",
\"  XXXXXo++++++o@oooo@@@@@@oXXX..\",
\"  XXXXXo++++++o@@@@@@@@@@@oXXX..\",
\"  XXXXXo++++++o@@@@@@@@@@@oXXX..\",
\"  XXXXXo++++++o@oooooooo@@oXXX..\",
\"  XXXXXoooooooo@@@@@@@@@@@oXXX..\",
\"  XXXXXXXXXXXXo@@@@@@@@@@@oXXX..\",
\"  XXXXXXXXXXXXo@@@@@@@@@@@oXXX..\",
\"  XXXXXXXXXXXXoooooooooooooXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  ..............................\",
\" ...............................\"};")
  "A paste icon pair.")

(defvar toolbar-undo-icon
  (toolbar-make-pixmap-pair
   "/* XPM */
static char * undo[] = {
\"32 32 7 1\",
\" 	c red\",
\".	c green\",
\"X	c Gray75\",
\"o	c black\",
\"O	c Gray60\",
\"+	c Gray90\",
\"@	c white\",
\"                                \",
\"                               .\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXooXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXooOOooooXXX..\",
\"  XXXXXXXXXXXXXXXooOOOOOOOOooX..\",
\"  XXXXXXXXXXXXXooOOOOOOOOOooXX..\",
\"  XXXXXXXXXXXoo++ooooOOOooOoXX..\",
\"  XXXXXXXXXoo++++++++oooOOoXXX..\",
\"  XXXXXXXoo+++++++++oooOOOoXXX..\",
\"  XXXXXoo+++++++++oo++oOOoXXXX..\",
\"  XXXXoo++++++++oo+++oOooXXXXX..\",
\"  XXXo++oooo++oo+++++ooXXXXXXX..\",
\"  XXXo++++++oo+++++ooXXXXXXXXX..\",
\"  XXo+++++++o++++ooXXXXXXXXXXX..\",
\"  XXo+++++++o++ooXXXXXXXXXXXXX..\",
\"  Xoo++++++o+ooXXXXXXXXXXXXXXX..\",
\"  X@@oooo++ooXXXXXXXXXXXXXXXXX..\",
\"  X@@@@@@ooXXXXXXXXXXXXXXXXXXX..\",
\"  X@@@@@@XXXXXXXXXXXXXXXXXXXXX..\",
\"  X@@@@XXXXXXXXXXXXXXXXXXXXXXX..\",
\"  X@@@XXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  X@XXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  ..............................\",
\" ...............................\"};")
  "An undo icon pair.")

(defvar toolbar-spell-icon
  (toolbar-make-pixmap-pair
   "/* XPM */
static char * spell[] = {
\"32 32 4 1\",
\" 	c red\",
\".	c green\",
\"X	c Gray75\",
\"o	c black\",
\"                                \",
\"                               .\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXooXXXXooooXXXXooooXXXX..\",
\"  XXXXXXooXXXXooXXoXXooXXXoXXX..\",
\"  XXXXXoXooXXXooXXoXXooXXXXXXX..\",
\"  XXXXXoXooXXXoooooXXooXXXXXXX..\",
\"  XXXXoXXXooXXooXXXoXooXXXXXXX..\",
\"  XXXXooooooXXooXXXoXooXXXXXXX..\",
\"  XXXoXXXXXooXooXXXoXooXXXoXXX..\",
\"  XXXoXXXXXooXoooooXXXooooXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXoooXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXoooXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXooooXXXXXX..\",
\"  XXXXoXXXXXXXXXXXooooXXXXXXXX..\",
\"  XXXoooXXXXXXXXooooXXXXXXXXXX..\",
\"  XXooooXXXXXXXooooXXXXXXXXXXX..\",
\"  XXXooooXXXXooooXXXXXXXXXXXXX..\",
\"  XXXXooooXXooooXXXXXXXXXXXXXX..\",
\"  XXXXXooooooooXXXXXXXXXXXXXXX..\",
\"  XXXXXXooooooXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXooooXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXooXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  ..............................\",
\" ...............................\"};")
  "A spell icon pair.")

(defvar toolbar-replace-icon
  (toolbar-make-pixmap-pair
   "/* XPM */
static char * replace[] = {
\"32 32 4 1\",
\" 	c red\",
\".	c green\",
\"X	c Gray75\",
\"o	c black\",
\"                                \",
\"                               .\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXooXXXXooooXXXXXXXXXXXX..\",
\"  XXXXXXooXXXXooXXoXXXXXXXXXXX..\",
\"  XXXXXoXooXXXooXXoXXXXXXXXXXX..\",
\"  XXXXXoXooXXXoooooXXXXXXXXXXX..\",
\"  XXXXoXXXooXXooXXXoXXoooXXXXX..\",
\"  XXXXooooooXXooXXXoXXooXXXXXX..\",
\"  XXXoXXXXXooXooXXXoXXoXoXXXXX..\",
\"  XXXoXXXXXooXoooooXXXXXXoXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXoXXXX..\",
\"  XXXXXXXXXXXXoXXXXXXXXXXoXXXX..\",
\"  XXXXXXXXXXXoXXXXXXXXXXXoXXXX..\",
\"  XXXXXXXXXXXoXXXXXXXXXXoXXXXX..\",
\"  XXXXXXXXXXoXXXXXXXXXXoXXXXXX..\",
\"  XXXXXXXXXoXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXoXXXXXXooooXXXXXXXX..\",
\"  XXXXXXXXoXXXXXXooXXXoXXXXXXX..\",
\"  XXXXXoXoXXXXXXXooXXXXXXXXXXX..\",
\"  XXXXXooXXXXXXXXooXXXXXXXXXXX..\",
\"  XXXXXooooXXXXXXooXXXXXXXXXXX..\",
\"  XXXXXooXXXXXXXXooXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXooXXXoXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXooooXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  ..............................\",
\" ...............................\"};")
  "A replace icon pair.")

(defvar toolbar-mail-icon
  (toolbar-make-pixmap-pair
   "/* XPM */
static char * mail[] = {
\"32 32 7 1\",
\" 	c red\",
\".	c green\",
\"X	c Gray75\",
\"o	c black\",
\"O	c Gray90\",
\"+	c Gray60\",
\"@	c white\",
\"                                \",
\"                               .\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXoooooooooooXXXXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOooXXXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOo+oXXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOooooXXXXXXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXooooooooooooooooooooooooXX..\",
\"  XXo@@@@@@@@@@@@@@@@@@@@@@oXX..\",
\"  XXo@oo@@@@@@@@@@@@@@@ooo@oXX..\",
\"  XXo@@@@@@@@@@@@@@@@@@o+o@oXX..\",
\"  XXo@@@@@@@@@@@@@@@@@@o+o@oXX..\",
\"  XXo@@@@@ooooooooo@@@@ooo@oXX..\",
\"  XXo@@@@@@@@@@@@@@@@@@@@@@oXX..\",
\"  XXo@@@@@ooooooo@@@@@@@@@@oXX..\",
\"  XXo@@@@@@@@@@@@@@@@@@@@@@oXX..\",
\"  XXo@@@@@ooooo@@@@@@@@@@@@oXX..\",
\"  XXo@@@@@@@@@@@@@@@@@@@@@@oXX..\",
\"  XXo@@@@@@@@@@@@@@@@@@@@@@oXX..\",
\"  XXo@@@@@@@@@@@@@@@@@@@@@@oXX..\",
\"  XXooooooooooooooooooooooooXX..\",
\"  XXXXXXXoOOOOOOOOOOOOoXXXXXXX..\",
\"  XXXXXXXooooooooooooooXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  ..............................\",
\" ...............................\"};")
  "A mail icon pair.")

(defvar toolbar-info-icon
  (toolbar-make-pixmap-pair
   "/* XPM */
static char * info[] = {
\"32 32 4 1\",
\" 	c red\",
\".	c green\",
\"X	c Gray75\",
\"o	c black\",
\"                                \",
\"                               .\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXoXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXoooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXoooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXoooooooXXXXXXXXXXX..\",
\"  XXXXXXXXXXXoooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXoooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXoXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXooooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXoooooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXoooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXoooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXoooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXoooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXoooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXoooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXoooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXoooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXoooooXXXXXXXXXXXX..\",
\"  XXXXXXXXXXoooooooXXXXXXXXXXX..\",
\"  XXXXXXXXXoooooooooXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  ..............................\",
\" ...............................\"};")
  "An info icon pair.")

(defvar toolbar-about-icon
      (list (make-pixmap (concat "/* XPM */
static char * ajp[] = {
\"32 32 5 1\",
\" 	c " toolbar-lit-colour "\",
\".	c " toolbar-shade-colour "\",
\"X	c " toolbar-background-colour "\",
\"o	c black\",
\"O	c white\",
\"                                \",
\"                               .\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXooooooooooooooooooooooXXX..\",
\"  XXXoOOOOOOOOOOOOOOOOOOOOoXXX..\",
\"  XXXoOOOOOOOOOOOOOOOOOOOOoXXX..\",
\"  XXXoOOOOOooOOOOOOOOOOOOOoXXX..\",
\"  XXXoOOOOOooOOOOOOOOOOOOOoXXX..\",
\"  XXXoOOOOoOooOOOOOOOOOOOOoXXX..\",
\"  XXXoOOOOoOooOOOOOOOOOOOOoXXX..\",
\"  XXXoOOOoOOOooOOOOOOOOOOOoXXX..\",
\"  XXXoOOOooooooOOOOOOOOOOOoXXX..\",
\"  XXXoOOoOOOOOooOOooOOooOOoXXX..\",
\"  XXXoOOoOOOOOooOOooOOooOOoXXX..\",
\"  XXXoOOOOOOOOOOOOOOOOOOOOoXXX..\",
\"  XXXoOOOOOOOOOOOOOOOOOOOOoXXX..\",
\"  XXXooooooooooooooooooooooXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  XXXXXXXXXXXXXXXXXXXXXXXXXXXX..\",
\"  ..............................\",
\" ...............................\"};"))

(make-pixmap "/* XPM */
static char *noname[] = {
/* width height ncolors chars_per_pixel */
\"32 32 16 1\",
/* colors */
\"` c #9F9F9F\",
\"a c #8D8D8D\",
\"b c #494949\",
\"c c #C6C6C6\",
\"d c #C4C4C4\",
\"e c #C2C2C2\",
\"f c #ACACAC\",
\"g c #7A7A7A\",
\"h c #6E6E6E\",
\"i c #646464\",
\"j c #585858\",
\"k c #CBCBCB\",
\"l c #C7C7C7\",
\"m c #C5C5C5\",
\"n c #BFBFBF\",
\"o c #B9B9B9\",
/* pixels */
\"eemdmmlllllllllldcmlllllllllclmm\",
\"eedmdmmllllclldeoeelllllllllllcd\",
\"edmdlcllllleggaggaflellllllllllm\",
\"dmdcclllllahiigjjjh`fffnllllllnc\",
\"dmcclllleagghhjbijjiigafklkllneo\",
\"dmcclll`gggiihghhiiijgg`nlllloom\",
\"mmclcllijjjjjijjjjjjjiggolmeofg`\",
\"mdllclgbbjjijijjjjjjghgifeofgiaf\",
\"dccmllbbbjjjbbjbbjihhhgo`aaijjf`\",
\"cclcl`jbb`ahiiiiihgaajofagolcjgg\",
\"mmlclgbbfenf`gggaaa`aoahjflllcmj\",
\"dclclgbinnnof``aa````gibbglllcce\",
\"dmcllij`oooofffffffaajbbbacclcdc\",
\"mmcccijffonnofoooo`aagbbbfccccme\",
\"mmmcljj`fonoooof`a``agjbbamlmded\",
\"mcllchj`fof`````hjbbjghbbjjmmmmd\",
\"mmclc`j`ahbbjgagbbbjihgbjgjmmdde\",
\"dmmcldhafhjbjjo`bbbhggajbjhmddee\",
\"mmmcclm`fgaah`ofgijigaahjjhnhgfn\",
\"mecmlmoaoahhofffa```f`agjh`eajha\",
\"eddcmmnnnomo`fffaa```aaiageeeenj\",
\"edemmmekkfofa`fnagigaggjgneeeeen\",
\"eemddcmkk``gh`f`ghhjiggneeeeeeen\",
\"eeddddmmffaja`ijjhgiihheeeeennnn\",
\"eeeeeedddf`ig`ahijbhahheeeenennn\",
\"neeeeedemo`gaiaihjhgghineennnnno\",
\"nnnenneeee`a`ff`ghgghiiennnnnnno\",
\"nnnnneneenna`f`ghhgiijhnnnnnnooo\",
\"onnnnenneee`afff`aahjiibgnnooooo\",
\"oonnnnnneneka`offahjjiibbbhooofo\",
\"oooonnnnnojkcaghijbjiihbbjjbfoff\",
\"ooooonnniibkkfajjbbjihhbbbbbbgff\"};"))
  "An about icon.")

(provide 'toolbar)


