Article 365 of gnu.emacs.sources:
Path: morgan.com!uunet!bloom-beacon.mit.edu!news.kei.com!news.mathworks.com!gatech!howland.reston.ans.net!spool.mu.edu!sdd.hp.com!bone.think.com!paperboy.osf.org!melman
From: melman@osf.org (Howard Melman)
Newsgroups: gnu.emacs.sources
Subject: netscape.el
Date: 12 May 1995 16:51:45 GMT
Organization: Open Software Foundation
Lines: 161
Distribution: world
Message-ID: <MELMAN.95May12125145@absolut.osf.org>
NNTP-Posting-Host: absolut.osf.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


Here is what I use to click on URL's and have them viewed in netscape.
I only add to the many other postings about this because the html-mode.el
that I just posted can call this function.

;;; netscape.el --- Provide functions for the NETSCAPE Web Browser interface 

;; Copyright (C) 1995  Howard R. Melman <melman@osf.org>
;; url-get-url-at-point is from url.el version 1.228
;;   Copyright (c) 1993, 1994, 1995 by William M. Perry (wmperry@spry.com)
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You didn't receive a copy of the GNU General Public License along
;; with this program; so, write to the Free Software Foundation, Inc.,
;; 675 Mass Ave, Cambridge, MA 02139, USA.

;; This package has been tested with GNU Emacs 19.28 and XEmacs 19.11
;;
;;
;; HISTORY:
;;   1.00:  03 May 1995 Created by Howard R. Melman <melman@osf.org>

;;; Installation:
;;  1) place netscape.el in some directory on your lisp path
;;  2) byte compile it with M-x byte-compile-file
;;     ignore warnings about undefined functions such as event-window
;;     and event-point (in emacs19) or posn-window or posn-point 
;;     (in XEmacs).
;;  3) add to your ~/.emacs
;;        (autoload 'netscape-fetch-url-at-point "netscape" nil t)
;;  4) bind netscape-fetch-url-at-mouse to a mouse key, I recommend:
;;        (global-set-key [S-mouse-2] 'netscape-fetch-url-at-mouse)
;;  5) start netscape

;;; Commentary: 

;; This package provides commands to have a running netscape display a
;; Web Page by an identified URL.  The URL can be prompted for, or gotten
;; from context such as around point or around a mouse click.  You must
;; have netscape to make use of this package.  Use cci.el to remotely
;; control Mosaic.

;; I have borrowed one routine from William Perry's url.el that comes
;; with his w3 browser.  This file will try to find url.el but if not
;; will use a version of that function in this file.  netscape.el cannot
;; use w3 to display the URL, use w3-follow-mouse to do that.

;;; Code:

;; Try using url.el but if not found defun the one function we need 
;; with the one variable we need.
(if (fboundp 'url-get-url-at-point)
    nil
  (defvar url-nonrelative-link
    (concat "^\\("
            (mapconcat 'identity
                       '(
                         "about"
                         "file"
                         "ftp"
                         "gopher"
                         "http"
                         "https"
                         "mailserver"
                         "mailto"
                         "news"
                         "newspost"
                         "rlogin"
                         "shttp"
                         "solo"
                         "telnet"
                         "tn3270"
                         "wais"
                         "www"
                         "x-exec"
                         "x-ramp"
                         ) "\\|")
            "\\):")
    "A regular expression that will match an absolute URL.")

  (defun url-get-url-at-point (&optional pt)
    "Get the URL closest to point, but don't change your
position. Has a preference for looking backward when not
directly on a symbol."
    ;; Not at all perfect - point must be right in the name.
    (save-excursion
      (if pt (goto-char pt))
      (let ((filename-chars "%.?@a-zA-Z0-9---_/:~") start url)
        (save-excursion
          ;; first see if you're just past a filename
          (if (not (eobp))
              (if (looking-at "[] \t\n[{}()]") ; whitespace or some parens
                  (progn
                    (skip-chars-backward " \n\t\r({[]})")
                    (if (not (bobp))
                        (backward-char 1)))))
          (if (string-match (concat "[" filename-chars "]")
                            (char-to-string (following-char)))
              (progn
                (skip-chars-backward filename-chars)
                (setq start (point))
                (skip-chars-forward filename-chars))
            (message "No URL found around point!")
            (setq start (point)))
          (setq url (buffer-substring start (point))))
        (if (string-match "^URL:" url)
            (setq url (substring url 4 nil)))
        (if (not (string-match url-nonrelative-link url))
            (setq url nil))
        url))))

;;;###autoload
(defun netscape-fetch-url-at-mouse (e &optional arg)
  "Open a NETSCAPE link to a URL where mouse is clicked .
Optional PREFIX arg means to open a new window for the URL."
  (interactive "eP")
  ;; doing all this allows you to click in a non-selected window
  (let (w b p u)                        ; window buffer point url
    (if (fboundp 'event-window)         ; xemacs
        (setq w (event-window e))       ; emacs 19
      (setq w (posn-window (event-start e))))
    (setq b (window-buffer w))
    (if (fboundp 'event-point)          ; xemacs
        (setq p (event-point e))        ; emacs 19
      (setq p (posn-point (event-start e))))
    (save-excursion
      (set-buffer b)
      (netscape-fetch-url-at-point p arg))))

;;;###autoload
(defun netscape-fetch-url-at-point (&optional pt arg)
  "Open a NETSCAPE link to a URL around POINT.
Optional PREFIX arg means to open a new window for the URL."
  (interactive "dP")
  (or pt (setq pt (point)))
  (let ((u (url-get-url-at-point pt)))
    (if u
        (netscape-get-url u arg)
      (error "No URL found."))))

;;;###autoload
(defun netscape-get-url (url &optional new)
  "Open a link to a browser and open a URL.
Optional PREFIX arg means to open a new window for the URL."
  (interactive "sURL: \nP")
  (start-process "netscape" "*netscape*" "netscape" "-remote" 
                 (concat "openURL("
                         url
                         (if new ", new-window")
                         ")")))

(provide 'netscape)


Article 366 of gnu.emacs.sources:
Path: morgan.com!sanews1!pnf
From: pnf@morgan.com (Peter Fraenkel)
Newsgroups: gnu.emacs.sources
Subject: Re: netscape.el
Date: 16 May 1995 23:18:43 GMT
Organization: Morgan Stanley
Lines: 14
Distribution: world
Message-ID: <PNF.95May16191843@sait384.morgan.com>
References: <MELMAN.95May12125145@absolut.osf.org>
NNTP-Posting-Host: sait384.morgan.com
In-reply-to: melman@osf.org's message of 12 May 1995 16:51:45 GMT

>>>>> "melman" == Howard Melman <melman@osf.org> writes:
 melman> ;;; netscape.el --- Provide functions for the NETSCAPE Web Browser interface 

How about the following patch?  Where I work, the netscape likely to
be on the PATH is actually a script which sets some environment
variables and hooks up with local cache servers.

53a54,55
> (defvar netscape-executable "netscape" nil)
> 
150c152
<   (start-process "netscape" "*netscape*" "netscape" "-remote" 
---
>   (start-process "netscape" "*netscape*" netscape-executable "-remote" 


