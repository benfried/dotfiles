25-Aug-92 16:12:38-GMT,3936;000000000001
Return-Path: <help-lucid-emacs-request@lucid.com>
Received: from lucid.com by banzai.cc.columbia.edu (5.59/FCB)
	id AA08152; Tue, 25 Aug 92 12:12:31 EDT
Received: from rodan.UU.NET by heavens-gate.lucid.com id AA25099g; Tue, 25 Aug 92 08:51:39 PDT
Received: from help-lucid-emacs@lucid.com (list exploder) by rodan.UU.NET 
	(5.61/UUNET-mail-drop) id AA07704; Tue, 25 Aug 92 12:02:22 -0400
Received: from news.UU.NET by rodan.UU.NET with SMTP 
	(5.61/UUNET-mail-drop) id AA07699; Tue, 25 Aug 92 12:02:19 -0400
Newsgroups: alt.lucid-emacs.help
Path: uunet!boulder!news!grunwald
From: grunwald@mumble.cs.colorado.edu (Dirk Grunwald)
Subject: TeX-mode hacks for Lucid
Message-Id: <GRUNWALD.92Aug25094350@mumble.cs.colorado.edu>
Nntp-Posting-Host: mumble.cs.colorado.edu
Reply-To: grunwald@foobar.cs.colorado.edu
Organization: University of Colorado at Boulder
Date: 25 Aug 92 09:43:50
Lines: 107
Sender: help-lucid-emacs-request@lucid.com
To: help-lucid-emacs@lucid.com


put something like this in your .emacs....

(defun dirk::lucid-tex-mode-hook ()
  (require 'tex-lucid)
  )
(add-hook 'tex-mode-hook 'dirk::lucid-tex-mode-hook)


and then put the file tex-lucid.el (see below) somewhere in your EMACSPATH.

You select text with normal mouse buttons.
mouse button3 pops up a menu.
You can then e.g., centerline the highlighted region, or
put it in $...$.

Ideally, I should also make it spell the region, but haven't needed it yet.

;;
;; Extensions to VorTeX mode for Lucid Emacs
;;

(setq TeX::zone-menu
  '("TeX Zone Coniptions"
    ["\\begin{center}" tex-latex-center t]
    ["\\begin{itemize}" tex-latex-itemize t]
    ["\\begin{tabular}" tex-latex-tabular t]
    ["\\begin{quote}" tex-latex-quote t]
    ["\\begin{verbatim}" tex-latex-verbatim t]
    ["\\begin{singlespace}" tex-latex-singlespace t]
    ["\\begin{figure}" tex-latex-figure t]
    ["\\begin{slide}" tex-latex-slide t]
    ["\\begin{code}" tex-latex-code t]
    ["\\begin{answer}" tex-latex-answer t]
    "--"
    ["\\bf" tex-zone-bf t]
    ["\\tt" tex-zone-tt t]
    ["\\it" tex-zone-it t]
    ["\\rm" tex-zone-rm t]
    ["\\sl" tex-zone-sl t]
    "--"
    ["$..$" tex-zone-math t]
    ["$$..$$" tex-zone-display-math t]
    ["'...'" tex-zone-single-quote t]
    ["\"...\"" tex-zone-single-quote t]
    ["\\centerline" tex-zone-centerline t]
    ["\\hbox" tex-zone-hbox t]
    ["\\vbox" tex-zone-vbox t]
    )
  )

;;
;; Replacement version that uses the zone stuff for compatiblity with menus
;;
(defun tex-latex-putenv (n env &optional arg)
  (let* ((col (current-column))
	 (n (+ (if n (if (< n 0) 0 n) tex-latex-indentation) col))
	 (env (concat "{" env "}"))
	 (arg (if arg (read-string (concat "Arguments to environment " env ": ")) ""))
	 (begin-string (concat "\\begin" env arg "\n"))
	 (end-string (concat "\\end" env"\n"))
	 (zone-mark (if tex-zone-marker-stack
			(car tex-zone-marker-stack)))
	 (beginning (if (markerp zone-mark) (marker-position zone-mark)))
	 (end (point))
	 (first (min beginning end))
	 (second (max beginning end))
	 )
    (save-excursion
     (goto-char first)
     (if (not (bolp))
	 (setq begin-string (concat "\n" begin-string)))
     (goto-char second)
     (if (not (bolp))
	 (setq end-string (concat "\n" end-string)))
     )
    (tex-zone begin-string end-string)
    )
)

(defun TeX::popup-wrapper (e)
  (interactive "e")
  (let (here there)
    (save-excursion
      (if (and (x-selection-owner-p) primary-selection-extent)
	  (progn
	    (set-buffer (extent-buffer primary-selection-extent))
	    (setq here (extent-start-position primary-selection-extent))
	    (setq there (extent-end-position primary-selection-extent))
	    )
	(progn
	  (mouse-set-point e)
	  (setq here (point))
	  (setq there (point))
	  )
	)
      (goto-char here)
      (tex-zone-open)
      (goto-char there)
      (popup-menu TeX::zone-menu)
      )
    )
  )
    
(define-key tex-mode-map 'button3 'TeX::popup-wrapper)

(provide 'tex-lucid)

