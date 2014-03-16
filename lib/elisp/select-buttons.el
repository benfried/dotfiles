 9-Jul-92 17:25:17-GMT,6072;000000000001
Return-Path: <help-lucid-emacs-request@lucid.com>
Received: from lucid.com by banzai.cc.columbia.edu (5.59/FCB)
	id AA01678; Thu, 9 Jul 92 13:25:13 EDT
Received: by heavens-gate.lucid.com id AA04216g; Thu, 9 Jul 92 10:01:26 PDT
Received: from moebius.loria.fr by heavens-gate.lucid.com id AA04200g; Thu, 9 Jul 92 09:57:19 PDT
Received: by moebius.loria.fr id AA18487
  (5.65c+/IDA-1.4.3 for help-lucid-emacs@lucid.com); Thu, 9 Jul 92 19:05:04 +0200
Date: Thu, 9 Jul 92 19:05:04 +0200
From: Guido Bosch <Guido.Bosch%loria.fr@lucid.com>
Message-Id: <9207091705.AA18487@moebius.loria.fr>
To: help-lucid-emacs@lucid.com
Subject: select-button package for ILISP
Reply-To: Guido BOSCH <bosch%loria.fr@lucid.com>

Hi,

Here is an additional package for ILISP. It allows the plotting of
selectable buttons in an inferior lisp buffer. A Lisp form (of the
inferior Lisp) can be attached to each button, such that selecting
it will execute the form in the inferior Lisp.

Very useful to write hypertext like object browsers.

---------------------- ilisp-select-buttons.el ----------------------
;;   -*- Syntax: Emacs-Lisp; Mode: emacs-lisp -*-
;;
;; This file is not yet part of GNU Emacs.
;;
;; GNU Emacas is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;; Please send bugs and comments to the above address
;;
;;
;; <DISCLAIMER>
;; This program is still under development.  Neither the author nor
;; CRIN-INRIA accepts responsibility to anyone for the consequences of
;; using it or for whether it serves any particular purpose or works
;; at all.

;;
;; Select button package for ILISP (for Lucid Emacs 19 only)
;;
;; Copyright (c) 1992 by Guido Bosch <bosch@loria.fr>
;;
;; Installation: (in the .emacs)
;;
;; (autoload 'ilisp-install-select-buttons "ilisp-select-buttons" nil t) 
;;
;; (add-hook '<my-lisp>-hook
;;	  '(lambda ()
;;	     (add-hook 'ilisp-init-hook
;;		       'ilisp-install-select-buttons)))
;;
;;
;; To install manually, compile and load this file, start ILISP and
;; type M-x ilisp-install-select-buttons in the inferior lisp buffer.

;; Usage: 
;; The inferior lisp can plot selection buttons in the inferior lisp buffer
;; using the following  special format: 
;;
;;        ^[2"<button label>" '(sexpr to eval on middle mouse click)^]
;;
;; while "^[" and "^]" mean "\C-[" and "\C-]" (in elisp
;; representation).  <button label> will be the selectable text
;; inserted into the inferior lisp buffer, and '(sexpr to eval on middle
;; mouse click) is the form that will be evaluated in the inferior
;; lisp when you click with the middle mouse button on the select button. 
;; 
;; Here is a Common Lisp function that may be used to print select buttons:
;; 
;;    (defun print-select-button (label form)
;;      (format t "2~s~s" label form)
;;      label)
;; 
;; 
;; Use M-x remove-bridge to remove the select button handler.
;; The package bridge.el.


; Change history:
;
; $Log: ilisp-select-buttons.el,v $
; Revision 1.2  1992/07/08  15:42:10  bosch
; Installation hints added. selection buttons are now printed in bold
; face. Default middle mouse button handler added (needs enhancement).
;
; Revision 1.1  1992/07/08  12:10:38  bosch
; Additional ILISP package that defines  selectable buttons for an
; inferior Lisp.
;

;; Old binding for middle mouse button

(defvar ilisp-old-button2-binding nil)

(defvar bridge-handlers)

(add-hook 'bridge-hook
	  '(lambda ()
	     (setq bridge-source-insert nil
		   bridge-destination-insert nil)))
 

(make-variable-buffer-local 'ilisp-select-button-extents)
(defvar ilisp-select-button-extents nil)

(defun ilisp-install-select-buttons ()
  "Install the bridge handler that enables the inferior Lisp to
plot selection buttons."
  (interactive)
; Dosn't work, can't figure out why ... 
;  ;; keep old binding to be used as default
;  (setq  ilisp-old-button2-binding
;         (or ilisp-old-button2-binding
;             (lookup-key ilisp-mode-map 'button2)))
  (define-key ilisp-mode-map 'button2 'ilisp-mouse-select)
  (require 'bridge)
  (install-bridge)
  (setq bridge-handlers
	(cons '("2" . ilisp-select-button-handler) bridge-handlers)))


(defun ilisp-select-button-handler (process input)
  (if input
      (let ((item (read-from-string (substring input 1)))
	    (start (point)) extent)
	(insert (car item))
	(set-marker (process-mark process) (point))
	(setq extent (make-extent start (point)))
	(set-extent-attribute extent 'highlight)
	(set-extent-face extent ilisp-mouse-select-face)
	(setq ilisp-select-button-extents
	      (cons (cons extent (substring input (1+ (cdr item))))
		    ilisp-select-button-extents )))))


(defvar ilisp-mouse-select-face 
  (or (find-face 'ilisp-bold)
      (face-differs-from-default-p (make-face 'ilisp-bold))
      (copy-face 'bold 'ilisp-bold)))


(defun ilisp-mouse-select (event)
  "When executed on a select button, the button action is sent
to the inferior lisp process. Otherwise, the default action for button2 
is run. Should be bound to button2. Takes one Argument: EVENT"

  (interactive "@e") 
  (let* ((point (event-point event))
	 (extent (and point (extent-at point)))
	 link-ref)
    (if  extent
	(progn 
	  (setq link-ref
		(and extent (cdr (assq extent ilisp-select-button-extents))))
	  (if link-ref (ilisp-send link-ref "Button execution:" "select-button" t)
	    (message "No link found.")))
      ;; (funcall ilisp-old-button2-binding event)
      (x-set-point-and-insert-selection event))))










