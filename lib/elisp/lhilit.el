;;;  lhilit v1.0 - Text highlighting package for Lucid emacs.
;;;
;;;  Copyright (C) 1992 by Mike Scheidler (c23mts@kocrsv01.delcoelect.com)
;;;
;;;  This package is adapted from the hilit.el package for epoch, Copyright
;;;  (C) 1991 by Paul Nakada (pnakada@oracle.com).
;;;
;;;  GNU Emacs is distributed in the hope that it will be useful,
;;;  but WITHOUT ANY WARRANTY.  No author or distributor
;;;  accepts responsibility to anyone for the consequences of using it
;;;  or for whether it serves any particular purpose or works at all,
;;;  unless he says so in writing.  Refer to the GNU Emacs General Public
;;;  License for full details.

;;;  Everyone is granted permission to copy, modify and redistribute
;;;  GNU Emacs, but only under the conditions described in the
;;;  GNU Emacs General Public License.   A copy of this license is
;;;  supposed to have been given to you along with GNU Emacs so you
;;;  can know your rights and responsibilities.  It should be in a
;;;  file named COPYING.  Among other things, the copyright notice
;;;  and this notice must be preserved on all copies.

;;;  How it works
;;;  ------------
;;;  Highlights regions of a file (known as 'extents') specific to a mode.
;;;  Uses variable hilit::mode-list to determine what to highlight for each
;;;  mode.  Each element of the list has the form
;;;    ("modename" ("pstart" "pend" face)
;;;                ("pstart" "pend" face)... )
;;;  pstart and pend are regular expressions denoting the starting and ending
;;;  of a portion of the buffer to be highlighted according to face.  If pend
;;;  is nil the end of line terminates the region hilited.  (See examples in
;;;  the initialization section below).
;;;
;;;  Default key bindings
;;;  --------------------
;;;  \C-c \C-h    - rehighlight the current buffer
;;;  \C-c \C-t    - toggle highlighting off/on
;;;
;;;  Customization
;;;  -------------
;;;  Note that any customizations must be done AFTER lhilit has been loaded.
;;;  To override the default color assignments, put something similar to
;;;            (set-face-foreground 'hilit0 "yellow")
;;;  in your .emacs file for each color that you want to change or,
;;;  interactively, do M-x set-face-foreground and follow the prompts.
;;;  The colors (faces) used by lhilit are named hilit0 ... hilit9 (see init
;;;  code below).  Fonts can be customized in a similar manner, e.g.
;;;            (set-face-font 'hilit0 "8x13")
;;;
;;;  To add a new mode, put something like this in your .emacs file:
;;;            (setq ada-mode-hilit
;;;               '(("--.*" nil hilit0)
;;;                 ("^[ \t]*function.*" nil hilit2)
;;;                 ("^[ \t]*procedure.*" nil hilit2)))
;;;            (hilit::mode-list-update "Ada" ada-mode-hilit)
;;;  Note that the mode name (e.g. "Ada") must exactly match the name of the
;;;  emacs mode name in order for highlighting to be performed.
;;;

;;------------------------------------------
;; Load required Common Lisp extensions.
;;------------------------------------------
(require 'cl)

(defvar hilit::init-done nil
  "Flag signifying that hilit subsystem has been initialized.")

(defvar hilit::saving nil
  "'semaphore' set while in process of saving a file.")

(defvar hilit::read-hooks nil
  "List of hooks to call after visiting a file.")

(defvar hilit::write-hooks nil
  "List of hooks to call before writing a file.")

(defvar hilit::mode-list nil
  "A-list of mode names and regexps/styles to use.")

(defvar hilit::do-hiliting t
  "T if we should highlight buffers as we find them.  Nil otherwise.")

(defvar hilit::buffer-hilited nil
  "Non-nil if the current buffer is highlighted.")

;;------------------------------------------
;; Quick access to regexp patterns.
;;------------------------------------------
(defmacro pattern-start (p) (` (nth 0 (, p))))
(defmacro pattern-end   (p) (` (nth 1 (, p))))
(defmacro pattern-attr  (p) (` (nth 2 (, p))))

;;------------------------------------------
;; Install a new set of mode regexps.
;;------------------------------------------
(defun hilit::mode-list-update (mode-name mlist)
  "Adds or updates the hiliting instructions for MODE-NAME in MLIST to the
hiliting mode list."
  (if (assoc mode-name hilit::mode-list)
      (setq hilit::mode-list
	    (delq (assoc mode-name hilit::mode-list)
		  hilit::mode-list)))
  (setq hilit::mode-list (cons (cons mode-name mlist) hilit::mode-list)))

;;------------------------------------------
;; Highlight the current buffer.
;;------------------------------------------
(defun hilit::hilit-buffer ()
  "Highlights regions of a buffer specific to the buffer's mode."
  (interactive)
  (if hilit::mode-list
      (let ((modes hilit::mode-list) (start))
        (while (setq m (car modes))
          (setq mode (car m))
          (setq patterns (cdr m))
          (while (setq p (car patterns))
            (let ((pstart (pattern-start p))
                  (pend (pattern-end p))
                  (pattr (pattern-attr p)))
              (if (string= mode mode-name)
                  (save-excursion
                    (goto-char 0)
                    (if pend
                        (while (re-search-forward pstart nil t nil)
                          (setq hilit::buffer-hilited t)
                          (goto-char (setq start (match-beginning 0)))
                          (re-search-forward pend nil t nil)
			  (set-extent-face
			   (make-extent start (match-end 0))
			   pattr))
                      (while (re-search-forward pstart nil t nil)
                        (setq hilit::buffer-hilited t)
			(set-extent-face
			 (make-extent (match-beginning 0) (match-end 0))
			 pattr)
			(goto-char (match-end 0)))
		      )))
	      (setq patterns (cdr patterns))))
	  (setq modes (cdr modes))))))

;;------------------------------------------
;; Unhighlight the current buffer.
;;------------------------------------------
(defun hilit::unhilit-buffer ()
  (interactive)
  (save-excursion
    (map-extents (function (lambda (x y) (delete-extent x)))
		 (current-buffer) (point-min) (point-max) nil)))

;;------------------------------------------
;; Reprocess the current buffer.
;;------------------------------------------
(defun re-hilit (arg)
  "Re-hilit the current buffer.  With arg, unhilit the current buffer."
  (interactive "P")
  (hilit::unhilit-buffer)
  (setq hilit::buffer-hilited nil)
  (if (not arg)
      (hilit::hilit-buffer)))

;;;(global-set-key "\C-c\C-h" 're-hilit)

;;------------------------------------------
;; Reverse state of current highlighting.
;;------------------------------------------
(defun toggle-hilit (arg)
  "Globally toggle hiliting of this and future files read.  With arg,
forces hiliting off."
  (interactive "P")
  (if arg
      (progn
        (setq hilit::buffer-hilited nil)
        (setq hilit::do-hiliting t))
    (setq hilit::buffer-hilited (not hilit::buffer-hilited))
    )
  (setq hilit::do-hiliting hilit::buffer-hilited)
  (hilit::unhilit-buffer)
  (if hilit::do-hiliting
      (hilit::hilit-buffer))
  (message (format "Hiliting is %s"
                   (if hilit::buffer-hilited
                       "on" "off"))))

;;;(global-set-key "\C-c\C-t" 'toggle-hilit)

;;------------------------------------------
;; Find/write file hooks.  They cause automatic hiliting/rehiliting when
;; files are read/written.
;;------------------------------------------
(defun hilit::unhilit-before-save ()
  "Write a hilited buffer to a file.  Useful as a write-file hook."
  (if hilit::do-hiliting
      (if hilit::saving
          nil
        (hilit::unhilit-buffer)
        (setq hilit::saving t)
        (save-buffer)
        (setq hilit::saving nil)
        (hilit::hilit-buffer)
        (set-buffer-modified-p nil)
        t)))

(defun hilit::hilit-after-find ()
  "Hilit the current buffer, without modifying it.  Useful as a find-file hook."
  (if hilit::do-hiliting
      (progn
        (hilit::hilit-buffer)
        (set-buffer-modified-p nil))))

;;------------------------------------------
;; Initialization.
;;------------------------------------------
(defun create-face-if-needed (name-of-face fg)
  "Create a new face named NAME-OF-FACE, if it does not already exist.  The
face foreground color is set to color FG."
  (if (not (assoc name-of-face global-face-data))
      (make-face name-of-face))
  (set-face-foreground name-of-face fg))

(if (not hilit::init-done)
    (progn
      (setq hilit::init-done t)

      ;;------------------------------------------
      ;; Install read/write hooks.
      ;;------------------------------------------
      (push 'hilit::hilit-after-find find-file-hooks)
      (push 'hilit::unhilit-before-save write-file-hooks)

      ;;------------------------------------------
      ;; Create several different-colored faces.
      ;;------------------------------------------
      (create-face-if-needed 'hilit0 "red")
      (create-face-if-needed 'hilit1 "magenta")
      (create-face-if-needed 'hilit2 "blue")
      (create-face-if-needed 'hilit3 "purple")
      (create-face-if-needed 'hilit4 "royalblue")
      (create-face-if-needed 'hilit5 "darkgoldenrod")
      (create-face-if-needed 'hilit6 "firebrick")
      (create-face-if-needed 'hilit7 "darkorange")
      (create-face-if-needed 'hilit8 "deeppink")
      (create-face-if-needed 'hilit9 "forestgreen")

      ;;------------------------------------------
      ;; Mode definitions.
      ;;------------------------------------------
      (setq c-mode-hilit
	    '(("/\\*" "\\*/" hilit0)
	      ("^[_a-zA-Z][^=\n]*(\\(.*;\\|[^{]*\\)" nil hilit1) ;; fn decls
	      ("^#.*" nil hilit2)
	      ("^typedef.*" nil hilit3)
	      ("^struct.*" nil hilit4)
	      ("^enum.*" nil hilit5)))
      (hilit::mode-list-update "C" c-mode-hilit)

      (setq c++-mode-hilit
	    '(("/\\*" "\\*/" hilit0)
	      ("^[_a-zA-Z][^=\n]*(\\(.*;\\|[^{]*\\)" nil hilit2) ;; fn decls
	      ("//.*" nil hilit0)
	      ("^/.*" nil hilit0)
	      ("^#.*" nil hilit9)
	      ("^typedef.*" nil hilit1)
	      ("^struct.*" nil hilit1)
	      ("^class.*" nil hilit1)
	      ("^enum.*" nil hilit1)))
      (hilit::mode-list-update "C++" c++-mode-hilit)

      (setq text-mode-hilit
	    '(("^#.*" nil hilit0)
	      ("[^$]#.*" nil hilit0)))
      (hilit::mode-list-update "Text" text-mode-hilit)

      (setq fundamental-mode-hilit
	    '(("^#.*" nil hilit0)
	      ("[^$]#.*" nil hilit0)))
      (hilit::mode-list-update "Fundamental" fundamental-mode-hilit)

      (setq compilation-mode-hilit
	    '(("^[^ \t]*:[0-9]+:.*$" nil hilit0)
	      ("^[^ \t]*:[0-9]+: warning:.*$" nil hilit2)))
      (hilit::mode-list-update "Compilation" compilation-mode-hilit)
      (hilit::mode-list-update "grep" compilation-mode-hilit)

      (setq makefile-mode-hilit
	    '(("^#.*" nil hilit0)                  ; comments
	      ("[^$]#.*" nil hilit0)               ; comments
	      ("^%.*" nil hilit1)                  ; rules
	      ("^[.][a-zA-Z][a-zA-Z]?\..*" nil hilit1) ; rules
	      ("^[_a-zA-Z0-9]+ *\+?=" nil hilit2)  ; variable definition
	      ("\$[_a-zA-Z0-9]" nil hilit2)        ; variable reference
	      ("\${[_a-zA-Z0-9]+}" nil hilit2)     ; variable reference
	      ("\$\([_a-zA-Z0-9]+\)" nil hilit2)   ; variable reference
	      ("\\( \\|:=\\)[_a-zA-Z0-9]+ *\\+=" nil hilit2) ; variable definition
	      ("^include " nil hilit9)))           ; include
      (hilit::mode-list-update "Makefile" makefile-mode-hilit)

      (setq emacs-lisp-mode-hilit
	    '(("^;.*" nil hilit0)
	      (";;.*" nil hilit0)
	      ("\(defun.*" nil hilit2)
	      ("\(defmacro.*" nil hilit7)
	      ("\(defvar.*" nil hilit1)
	      ("\(defconst.*" nil hilit5)
	      ("\(provide.*" nil hilit9)
	      ("\(require.*" nil hilit9)))
      (hilit::mode-list-update "Emacs-Lisp" emacs-lisp-mode-hilit)))

(provide 'lhilit)
