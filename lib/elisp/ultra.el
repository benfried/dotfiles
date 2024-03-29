Article 2512 of comp.emacs:
Path: cunixc!columbia!rutgers!mcnc!rti!talos!kjones
From: kjones@talos.UUCP (Kyle Jones)
Newsgroups: comp.emacs
Subject: ultra.el revisited
Message-ID: <215@talos.UUCP>
Date: 5 Jul 88 18:44:19 GMT
Lines: 274

[ For the uninitiated: "ultra" is a package of Emacs Lisp functions that
  allow Emacs to save and restore window and buffer configurations
  between Emacs sessions.  This duplicates a feature found in
  Gosling's Emacs. ]

This is a repost of the "ultra" context save package that has been
enhanced to support saving the context of all existing file buffers.
The new feature is enabled by setting the value of the Lisp variable
`save-buffer-context' non-nil.  To get just the Gosling Emacs functionality
without the enhancement, leave `save-buffer-context' set to nil and
set `auto-save-and-recover-context' non-nil.  By default both variables
are set to nil; see the documentation of these variable for more
information.

This package works transparently when loaded from the site-init.el file
and dumped with Emacs.  But by adding a few lines to your .emacs file you can
make it work as an externally loaded library, and avoid the recompile.

To install the package as a pre-loaded library:

1) Save the package in a file called "ultra.el" in the Emacs lisp
   directory.
2) Use emacs to byte-compile the ultra.el file.
3) Add the following line to site-init.el
   (load "ultra")
4) Edit src/config.h and increase PURESIZE by about 5000 bytes.
5) Compile and dump a new Emacs

To use the package as an autoload library:

1) Save the package in a file called ultra.el in a directory that
   Emacs will search for lisp libraries.
2) Use emacs to byte-compile the ultra.el file.
3) Put these lines at the end of your .emacs file:
     (autoload 'kill-emacs "ultra" "" t)
     (autoload 'save-context "ultra" "" t)
     (autoload 'recover-context "ultra" "" t)
     (if (and auto-save-and-recover-context
	      (not (fboundp 'save-context))
	      (null (cdr command-line-args)))
	(recover-context))

Avoid spikes,

kyle jones  <kyle@odu.edu>
---------------------------- le axe ---------------------------------------
;;; Save Emacs buffer and window configuration between editing sessions.
;;; Copyright (C) 1987, 1988 Kyle E. Jones
;;;
;;; This software may be redistributed provided this notice appears unchanged
;;; on all copies and that the further free redistribution of this software is
;;; not restricted in any way.
;;;
;;; This software is distributed 'as is', without warranties of any kind.

(defconst save-context-version "Norma Jean"
  "A unique string which is placed at the beginning of every saved context
file.  If the string at the beginning of the context file doesn't match the
value of this variable the `recover-context' command will ignore the file's
contents.")

(defvar auto-save-and-recover-context nil
  "*If non-nil the `save-context' command will always be run before Emacs is
exited.  Also upon Emacs startup, if this variable is non-nil and Emacs is
passed no command line arguments, `recover-context' will be run.")

(defvar save-buffer-context nil
  "*If non-nil the `save-context' command will save the context
of buffers that are visiting files, as well as the contexts of buffers
that have windows.")

(defvar save-context-predicate
  (function (lambda (w)
	      (and (buffer-file-name (window-buffer w))
		   (not (string-match "^\\(/usr\\)?/tmp/"
				      (buffer-file-name (window-buffer w)))))))
  "*Value is a predicate function which determines which windows' contexts
are saved.  When the `save-context' command is invoked, this function will
be called once for each existing Emacs window.  The function should accept
one argument which will be a window object, and should return non-nil if
the window's context should be saved.")


;; kill-emacs' function definition must be saved
(if (not (fboundp 'just-kill-emacs))
    (fset 'just-kill-emacs (symbol-function 'kill-emacs)))

;; Change top-level to (recover-context) if appropriate
(setq top-level
      (list 'prog1 top-level
	    '(if (and auto-save-and-recover-context
		      (null (cdr command-line-args))) (recover-context))))

(defun kill-emacs (&optional query)
  "End this Emacs session.
Prefix ARG or optional first ARG non-nil means exit with no questions asked,
even if there are unsaved buffers.  If Emacs is running non-interactively
and ARG is an integer, then Emacs exits with ARG as its exit code.

If the variable `auto-save-and-restore-context' is non-nil,
the function save-context will be called first."
  (interactive "P")
  ;; check the purify flag.  try to save only if this is a dumped Emacs.
  ;; saving context from a undumped Emacs caused a NULL pointer to be
  ;; referenced through.  I'm not sure why.
  (if (and auto-save-and-recover-context (not purify-flag))
      (save-context))
  (just-kill-emacs query))

(defun save-context ()
  "Save context of all Emacs windows (files visited and position of point).
The information goes into a file called .emacs_<username> in the directory
where the Emacs session was started.  The context can be recovered with the
`recover-context' command, provided you are in the same directory where
the context was saved.

If the variable `save-buffer-context' is non-nil, the context of all buffers
visiting files will be saved as well.

Window sizes and shapes are not saved, since these may not be recoverable
on terminals with a different number of rows and columns."
  (interactive)
  (condition-case error-data
      (let (context-buffer mark save-file-name)
	(setq save-file-name (concat (original-working-directory)
				     ".emacs_" (user-login-name)))
	(if (not (file-writable-p save-file-name))
	    (if (file-writable-p (original-working-directory))
		(error "context is write-protected, " save-file-name)
	      (error "can't access directory, "
		     (original-working-directory))))
	;;
	;; set up a buffer for the saved context information
	;; Note that we can't set the visited file yet, because by
	;; giving the buffer a file to visit we are making it
	;; eligible to have it's context saved.
	;;
	(setq context-buffer (get-buffer-create " *Context Info*"))
	(set-buffer context-buffer)
	(erase-buffer)
	(set-buffer-modified-p nil)
	;;
	;; record the context information
	;;
	(mapcar
	 (function
	  (lambda (w)
	    (cond ((funcall save-context-predicate w)
		   (prin1 (buffer-file-name (window-buffer w)) context-buffer)
		   (princ " " context-buffer)
		   (prin1 (window-point w) context-buffer)
		   (princ "\n" context-buffer)))))
	 (window-list))
	
	;;
	;; nil is the data sentinel.  We will insert it later if we
	;; need it but for now just remember where the last line of
	;; window context ended.
	;;
	(setq mark (point))

	;;
	;; If `save-buffer-context' is non-nil we save buffer contexts.
	;;
	(if save-buffer-context
	    (mapcar
	     (function
	      (lambda (b)
		(set-buffer b)
		(cond (buffer-file-name
		       (prin1 buffer-file-name context-buffer)
		       (princ " " context-buffer)
		       (prin1 (point) context-buffer)
		       (princ "\n" context-buffer)))))
	     (buffer-list)))

	;;
	;; If the context-buffer contains information, we add the version
	;;   string and sentinels, and write out the saved context.
	;; If the context-buffer is empty, we don't create a file at all.
	;; If there's an old saved context in this directory we attempt
	;;   to delete it.
	;;
	(cond ((buffer-modified-p context-buffer)
	       (set-buffer context-buffer)
	       (setq buffer-offer-save nil)
	       ;; sentinel for EOF
	       (insert "nil\n")
	       ;; sentinel for end of window contexts
	       (goto-char mark)
	       (insert "nil\n")
	       ;; version string
	       (goto-char (point-min))
	       (prin1 save-context-version context-buffer)
	       (insert "\n\n")
	       ;; so kill-buffer won't need confirmation later
	       (set-buffer-modified-p nil)
	       ;; save it
	       (write-region (point-min) (point-max) save-file-name
			     nil 'quiet))
	      (t (condition-case data
		     (delete-file save-file-name) (error nil))))

	(kill-buffer context-buffer))
    (error nil)))

(defun recover-context ()
  "Recover an Emacs context saved by `save-context' command.
Files that were visible in windows when the context was saved are visited and
point is set in each window to what is was when the context was saved."
  (interactive)
  ;;
  ;; Set up some local variables.
  ;;
  (condition-case error-data
      (let (sexpr context-buffer recover-file-name)
	(setq recover-file-name (concat (original-working-directory)
					".emacs_" (user-login-name)))
	(if (not (file-readable-p recover-file-name))
	    (error "can't access context, " recover-file-name))
	;;
	;; create a temp buffer and copy the saved context into it.
	;;
	(setq context-buffer (get-buffer-create " *Recovered Context*"))
	(set-buffer context-buffer)
	(erase-buffer)
	(insert-file-contents recover-file-name nil)
	;; so kill-buffer won't need confirmation later
	(set-buffer-modified-p nil)
	;;
	;; If it's empty forget it.
	;;
	(if (zerop (buffer-size))
	    (error "context file is empty, " recover-file-name))
	;;
	;; check the version and make sure it matches ours
	;;
	(setq sexpr (read context-buffer))
	(if (not (equal sexpr save-context-version))
	    (error "version string incorrect, " sexpr))
	;;
	;; Recover the window contexts
	;;
	(while (setq sexpr (read context-buffer))
	  (select-window (get-largest-window))
	  (if (buffer-file-name)
	      (split-window))
	  (other-window 1)
	  (find-file sexpr)
	  (goto-char (read context-buffer)))
	;;
	;; Recover buffer contexts, if any.
	;;
	(while (setq sexpr (read context-buffer))
	  (set-buffer (find-file-noselect sexpr))
	  (goto-char (read context-buffer)))
	(bury-buffer "*scratch*")
	(kill-buffer context-buffer))
    (error nil)))
	 
(defun original-working-directory ()
  (save-excursion
    (set-buffer (get-buffer-create "*scratch*"))
    default-directory))

(defun window-list ()
  (let (first-window windows w)
    (setq first-window (selected-window))
    (setq windows (cons first-window nil))
    (setq w (next-window first-window))
    (while (not (equal w first-window))
      (setq windows (cons w windows))
      (setq w (next-window w)))
    windows))


