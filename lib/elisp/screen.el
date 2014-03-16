Article 737 of gnu.emacs.vm.bug:
Newsgroups: gnu.emacs.vm.bug
Sender: bug-vm-request@uunet.uu.net
Date: Sun, 1 Mar 92 23:57:48 -0500
From: kyle@uunet.UU.NET (Kyle Jones)
Message-ID: <9203020457.AA20975@rodan.UU.NET>
Subject: screen.el
Path: cunixf.cc.columbia.edu!sol.ctr.columbia.edu!zaphod.mps.ohio-state.edu!usc!wupost!uunet!wendy-fate.uu.net!bug-vm
Lines: 271

You need this in order to use window configurations under VM
5.32.  Like the timer package, this is a separate package from
VM.

#!/bin/sh
# shar:	Shell Archiver  (v1.22)
#
#	Run the following text with /bin/sh to create:
#	  screen.el
#
sed 's/^X//' << 'SHAR_EOF' > screen.el &&
X;;; Tools to configure your GNU Emacs windows
X;;; Copyright (C) 1991 Kyle E. Jones 
X;;;
X;;; This program is free software; you can redistribute it and/or modify
X;;; it under the terms of the GNU General Public License as published by
X;;; the Free Software Foundation; either version 1, or (at your option)
X;;; any later version.
X;;;
X;;; This program is distributed in the hope that it will be useful,
X;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
X;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
X;;; GNU General Public License for more details.
X;;;
X;;; A copy of the GNU General Public License can be obtained from this
X;;; program's author (send electronic mail to kyle@uunet.uu.net) or from
X;;; the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA
X;;; 02139, USA.
X;;;
X;;; Send bug reports to kyle@uunet.uu.net.
X
X(provide 'screen)
X
X(defun screen-map ()
X  "Returns a list containing complete information about the current
Xconfiguration of windows and buffers.  Call the function
Xset-screen-map with this list to restore the current
Xwindow/buffer configuration.
X
XThis is much like the function window-configuration except that
Xthe informatoin is returned in a form that can be saved and
Xrestored across multiple Emacs sessions."
X  (list (window-map) (buffer-map) (position-map)))
X
X(defun set-screen-map (map)
X  "Restore the window/buffer configuration described by MAP,
Xwhich should be a list previously returned by a call to
Xscreen-map."
X  (set-window-map (nth 0 map))
X  (set-buffer-map (nth 1 map))
X  (set-position-map (nth 2 map)))
X
X(defun window-map ()
X  (let (w maps map0 map1 map0-edges map1-edges x-unchanged y-unchanged)
X    (setq maps (mapcar 'window-edges (screen-window-list)))
X    (while (cdr maps)
X      (setq map0 maps)
X      (while (cdr map0)
X	(setq map1 (cdr map0)
X	      map0-edges (screen-find-window-map-edges (car map0))
X	      map1-edges (screen-find-window-map-edges (car map1))
X	      x-unchanged (and (= (car map0-edges) (car map1-edges))
X			       (= (nth 2 map0-edges) (nth 2 map1-edges)))
X	      y-unchanged (and (= (nth 1 map0-edges) (nth 1 map1-edges))
X			       (= (nth 3 map0-edges) (nth 3 map1-edges))))
X	(cond ((and (not x-unchanged) (not y-unchanged))
X	       (setq map0 (cdr map0)))
X	      ((or (and x-unchanged (eq (car (car map0)) '-))
X		   (and y-unchanged (eq (car (car map0)) '|)))
X	       (nconc (car map0) (list (car map1)))
X	       (setcdr map0 (cdr map1)))
X	      (t
X	       (setcar map0 (list (if x-unchanged '- '|)
X				  (car map0)
X				  (car map1)))
X	       (setcdr map0 (cdr map1))))))
X    (car maps)))
X
X(defun set-window-map (map)
X  (if (eq (selected-window) (minibuffer-window))
X      (delete-other-windows (next-window (minibuffer-window)))
X    (delete-other-windows))
X  (let (map-width map-height)
X    (setq map-width (screen-compute-map-width map)
X	  map-height (screen-compute-map-height map))
X    (screen-apply-window-map map (next-window (minibuffer-window)))))
X
X(defun buffer-map ()
X  (let ((w-list (screen-window-list))
X	b list)
X    (while w-list
X      (setq b (window-buffer (car w-list))
X	    list (cons (list (buffer-file-name b)
X			     (buffer-name b))
X		       list)
X	    w-list (cdr w-list)))
X    (nreverse list)))
X
X(defun set-buffer-map (buffer-map)
X  (let ((w-list (screen-window-list)) wb)
X    (while (and w-list buffer-map)
X      (setq wb (car buffer-map))
X      (set-window-buffer
X       (car w-list)
X       (if (car wb)
X	   (or (get-file-buffer (car wb))
X	       (find-file-noselect (car wb)))
X	 (get-buffer-create (nth 1 wb))))
X      (setq w-list (cdr w-list)
X	    buffer-map (cdr buffer-map)))))
X
X(defun position-map ()
X  (let ((sw (selected-window))
X	(w-list (screen-window-list))
X	list)
X    (while w-list
X      (setq list (cons (list (window-start (car w-list))
X			     (window-point (car w-list))
X			     (window-hscroll (car w-list))
X			     (eq (car w-list) sw))
X		       list)
X	    w-list (cdr w-list)))
X    (nreverse list)))
X
X(defun set-position-map (position-map)
X  (let ((w-list (screen-window-list)) (osw (selected-window)) sw p)
X    ;; select a window we don't care about so that when we select
X    ;; another window its buffer will be moved up in the buffer
X    ;; list.
X    (select-window (minibuffer-window))
X    (while (and w-list position-map)
X      (setq p (car position-map))
X      (and (car p) (set-window-start (car w-list) (car p)))
X      (and (nth 1 p) (set-window-point (car w-list) (nth 1 p)))
X      (and (nth 2 p) (set-window-hscroll (car w-list) (nth 2 p)))
X      (and (nth 3 p) (setq sw (car w-list)))
X      ;; move this buffer up in the buffer-list
X      (select-window (car w-list))
X      (setq w-list (cdr w-list)
X	    position-map (cdr position-map)))
X    (select-window (or sw osw))))
X
X(defun screen-window-list (&optional mini)
X  "Returns a list of Lisp window objects for all Emacs windows.
XOptional first arg MINIBUF t means include the minibuffer window
Xin the list, even if it is not active.  If MINIBUF is neither t
Xnor nil it means to not count the minibuffer window even if it is active."
X  (let* ((first-window (next-window (minibuffer-window)))
X	 (windows (cons first-window nil))
X	 (current-cons windows)
X	 (w (next-window first-window mini)))
X    (while (not (eq w first-window))
X      (setq current-cons (setcdr current-cons (cons w nil)))
X      (setq w (next-window w mini)))
X    windows))
X
X(defun screen-apply-window-map (map)
X  (let (horizontal)
X    (while map
X      (cond
X       ((numberp (car map)) (setq map nil))
X       ((eq (car map) '-) (split-window-vertically))
X       ((eq (car map) '|) (split-window-horizontally) (setq horizontal t))
X       (t
X	(if (cdr map)
X	    (enlarge-window
X	     (if horizontal
X		 (- (/ (* (screen-compute-map-width (car map)) (screen-width))
X		       map-width)
X		    (1+ (window-width))) ;; 1+ cuz | is part of window
X	       (- (/ (* (screen-compute-map-height (car map))
X			(1- (screen-height)))
X		     map-height)
X		  (window-height)))
X	     horizontal))
X	(if (not (numberp (car (car map))))
X	    (screen-apply-window-map (car map)))
X	(and (cdr map) (select-window (next-window)))
X	(and (cdr (cdr map)) (split-window nil nil horizontal))))
X      (setq map (cdr map)))))
X
X(defun screen-apply-window-map (map current-window)
X  (let (horizontal)
X    (while map
X      (cond
X       ((numberp (car map)) (setq map nil))
X       ((eq (car map) '-))
X       ((eq (car map) '|) (setq horizontal t))
X       (t
X	(if (cdr map)
X	    (split-window
X	     current-window
X	     (if horizontal
X		 (1- (/ (* (screen-compute-map-width (car map)) (screen-width))
X		       map-width))
X	       (/ (* (screen-compute-map-height (car map))
X		     (- (screen-height) (window-height (minibuffer-window))))
X		  map-height))
X	     horizontal))
X	(if (not (numberp (car (car map))))
X	    (setq current-window
X		  (screen-apply-window-map (car map) current-window)))
X	(and (cdr map) (setq current-window (next-window current-window)))))
X      (setq map (cdr map)))
X    current-window ))
X
X(defun screen-find-window-map-edges (map)
X  (let (nw-edges se-edges)
X    (setq nw-edges map)
X    (while (and (consp nw-edges) (not (numberp (car nw-edges))))
X      (setq nw-edges (car (cdr nw-edges))))
X    (setq se-edges map)
X    (while (and (consp se-edges) (not (numberp (car se-edges))))
X      (while (cdr se-edges)
X	(setq se-edges (cdr se-edges)))
X      (setq se-edges (car se-edges)))
X    (if (eq nw-edges se-edges)
X	nw-edges
X      (setq nw-edges (copy-sequence nw-edges))
X      (setcdr (nthcdr 1 nw-edges) (nthcdr 2 se-edges))
X      nw-edges )))
X
X(defun screen-compute-map-width (map)
X  (let ((edges (screen-find-window-map-edges map)))
X    (- (nth 2 edges) (car edges))))
X
X(defun screen-compute-map-height (map)
X  (let ((edges (screen-find-window-map-edges map)))
X    (- (nth 3 edges) (nth 1 edges))))
X
X(defun screen-nullify-map-elements (map &optional buffer-file-name buffer-name
X					window-start window-point
X					window-hscroll selected-window)
X  (let (p)
X    (setq p (nth 1 map))
X    (while p
X      (and buffer-file-name (setcar (car p) nil))
X      (and buffer-name (setcar (cdr (car p)) nil))
X      (setq p (cdr p)))
X    (setq p (nth 2 map))
X    (while p
X      (and window-start (setcar (car p) nil))
X      (and window-point (setcar (cdr (car p)) nil))
X      (and window-hscroll (setcar (nthcdr 2 (car p)) nil))
X      (and selected-window (setcar (nthcdr 3 (car p)) nil))
X      (setq p (cdr p)))))
X
X(defun screen-replace-map-element (map what function)
X  (let (mapi mapj p old new)
X    (cond ((eq what 'buffer-file-name)
X	   (setq mapi 1 mapj 0))
X	   ((eq what 'buffer-name)
X	    (setq mapi 1 mapj 1))
X	   ((eq what 'window-start)
X	    (setq mapi 2 mapj 0))
X	   ((eq what 'window-point)
X	    (setq mapi 2 mapj 1))
X	   ((eq what 'window-hscroll)
X	    (setq mapi 2 mapj 2))
X	   ((eq what 'selected-window)
X	    (setq mapi 2 mapj 3)))
X    (setq p (nth mapi map))
X    (while p
X      (setq old (nth mapj (car p))
X	    new (funcall function old))
X      (if (not (equal old new))
X	  (setcar (nthcdr mapj (car p)) new))
X      (setq p (cdr p)))))
SHAR_EOF
chmod 0664 screen.el || echo "restore of screen.el fails"
exit 0


