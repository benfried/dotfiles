Article 812 of gnu.emacs.sources:
Path: cunixf.cc.columbia.edu!sol.ctr.columbia.edu!usc!zaphod.mps.ohio-state.edu!pitt.edu!drycas.club.cc.cmu.edu!cantaloupe.srv.cs.cmu.edu!crabapple.srv.cs.cmu.edu!spot
From: spot@CS.CMU.EDU (Scott Draves)
Newsgroups: gnu.emacs.sources
Subject: webster.el
Message-ID: <SPOT.92Apr5064703@HOPELESS.MESS.CS.CMU.EDU>
Date: 5 Apr 92 11:47:03 GMT
Distribution: gnu
Organization: School of Computer Science, Carnegie Mellon University
Lines: 262
Nntp-Posting-Host: hopeless.mess.cs.cmu.edu
Originator: spot@HOPELESS.MESS.CS.CMU.EDU

;;; webster.el  connect to a webster server
;;; Copyright (C) 1992 Scott Draves (spot@cs.cmu.edu)
;;;
;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


;;; a webster client that avoids telnet, has a mode for hypertext-like
;;; browsing.  handles later release of server.
;;;
;;; i am always interested in bug reports and improvements to this
;;; code.


(require 'tq)

(defvar webster-tq nil
  "The webster transaction queue.")

(defvar webster-connection-name "webster"
  "Name to attach to the connection to the webster sever.")

(defvar webster-host-list nil
  "List of host-port pairs to use for connections")

(defconst webster-end-of-record-re
  "\\(\200\\|\\(WILD\\|SPELLING\\|MATCHS\\) 0\015\n\\)"
  "regexp to signal end of record from the server")

;;; found a host (finally!!), add it to the list.
;;; add to end so that we search in forward order.
;;; ignore 0 length host names; they happen with blank lines.
(defun webster-add-host (host port)
  (if (< 0 (length host))
      (setq webster-host-list (append webster-host-list
				      (cons (cons host (string-to-int port))
					    nil)))))

;;; parse a string formatted "port@host" or just "host"
(defun webster-parse-one-host (s)
  (cond ((string-match "@" s)
	 (webster-add-host (substring s (match-end 0) (length s))
			   (substring s 0 (match-beginning 0))))
	(t (webster-add-host s "2627"))))

;;; Parse into host/port pairs separated by : or \n.
(defun webster-parse-host-string (s)
  (if (string-match "\\(:\\|\n\\)" s)
    (let ((begin (match-beginning 0))
	  (end   (match-end 0)))
      (webster-parse-one-host (substring s 0 begin))
      (webster-parse-host-string (substring s end (length s))))
    (webster-parse-one-host s)))
			    
  

;;; get from the WEBSTER_PATH envar or ~/.webster file a list of hosts.
(defun webster-set-host-list ()
  (set-buffer (generate-new-buffer " webster-temp"))
  (cond ((getenv "WEBSTER_PATH")
	 (insert (getenv "WEBSTER_PATH")))
	((file-readable-p "~/.webster")
	 (insert-file "~/.webster"))
	(t
	 (insert "hamlet.weh.andrew")))
  (goto-char (point-min))
  (replace-regexp "#.*\n" "\n" nil) ; remove comments
  (goto-char (point-min))
  (replace-regexp " " "" nil)
  (goto-char (point-min))
  (replace-regexp "\t" "" nil)
  (webster-parse-host-string (buffer-string))
  (kill-buffer " webster-temp"))
  

(defun webster (arg)
"Look up a word in the Webster's dictionary.
Open a network connection to a webster host if necessary.
Communication with host is recorded in a buffer *webster*."
  (interactive "sLook up word in webster: ")
  (webster-send-request "dictionary" "DEFINE" arg))

;;; run index/cmd on the word surrounding point.
(defun webster-index-word (index cmd)
  ;; Move backward for word if not already on one.
  (if (not (looking-at "\\w"))
      (re-search-backward "\\w" (dot-min) 'stay))
  ;; Move to start of word
  (re-search-backward "\\W" (dot-min) 'stay)
  ;; Find start and end of word
  (or (re-search-forward "\\w+" nil t)
      (error "No word to check."))
  (let* ((start (match-beginning 0))
	 (end (match-end 0))
	 (word (buffer-substring start end)))
    (webster-send-request index cmd word)))
  
(defun webster-define-word ()
  "Define a word.  The word is taken from before point. The definition
is put in the buffer *webster*."
  (interactive)
  (webster-index-word "dictionary" "DEFINE"))

(defun webster-thesaurus-word ()
  "Find synonyms and antonyms of a word.  The word is taken from
before point. The found words are put in the buffer *webster*."
  (interactive)
  (webster-index-word "thesaurus" "DEFINE"))

(defun webster-spell-word ()
  "Find alternative spellings to a word.  The word is taken from before
point. The spellings are put in the buffer *webster*."
  (interactive)
  (webster-index-word "dictionary" "SPELL"))

(defun webster-references-word ()
  "Find all references to a word in Webster's Dictionary.  The word is
taken from before point. The references are put in the buffer *webster*."
  (interactive)
  (webster-index-word "dictionary-full" "DEFINE"))

(defun webster-complete-word ()
  "Determine if a word is complete. The word is taken from before point.
The answer is put in the buffer *webster*."
  (interactive)
  (webster-index-word "dictionary" "COMPLETE"))

(defun webster-endings-word ()
  "Look up endings to a word.  The word is taken from before point.  The
endings are put in the buffer *webster*."
  (interactive)
  (webster-index-word "dictionary" "ENDINGS"))

;;; survives errors
(defun webster-open-network-stream (name buf host port)
  (condition-case err
      (open-network-stream name buf host port)
    (error nil)))

;;; open a connection to the webster host.  search the hosts/ports
;;; listed in webster-host-list for a live server.
(defun webster-connect ()
  (pop-to-buffer (get-buffer-create "*webster*"))
  (if (not (eq major-mode 'webster))
      (webster-mode))
  (if (null webster-host-list)
      (progn
	(message "Reading host list...")
	(webster-set-host-list)))
  (while (and (or (not webster-tq)
		  (not (eq (process-status (tq-process webster-tq)) 'open)))
	      (not (null webster-host-list)))
    (let ((host (car (car webster-host-list)))
	  (port (cdr (car webster-host-list))))
      (message (concat "Attempting to connect to " host "..."))
      (let ((process (webster-open-network-stream
		      webster-connection-name
		      nil host port)))
	(setq webster-host-list (cdr webster-host-list))
	(if (null process)
	    (progn
	      (message (concat "Attempting to connect to " host "... Failed!"))
	      (sleep-for 1))
	  (message (concat "Attempting to connect to " host "... done"))
	  (setq webster-tq (tq-create process)))))))

;;; close the current connection
(defun webster-close ()
  "Close the current webster connection.  Not much use in real life."
  (interactive)
  (if (null webster-tq)
      (error "webster not running"))
  (tq-close webster-tq)
  (setq webster-tq nil))

;;; KIND is one of the commands the webster server recognizes, eg
;;; "DEFINE", "SPELL".  WORD is the string to look for.  Make sure the
;;; connection is open and good, and send the word.
(defun webster-send-request (index kind word)
  (if (or (not webster-tq)
	  (not (eq (process-status (tq-process webster-tq)) 'open)))
      (webster-connect))
  (let ((question (concat "INDEX " index "\n" kind " " word "\n")))
    (tq-enqueue webster-tq
		question webster-end-of-record-re
		question 'webster-buffer-insert)))

(defun webster-ignore (closure answer) nil)

;;; this is called with records from the server.  CLOSURE is our inital
;;; request.  ANSWER is what the server replied with.  dump it into the
;;; webster buffer and clean it up.
(defun webster-buffer-insert (closure answer)
  (set-buffer "*webster*")
  (goto-char (point-max))
  (let ((now (point)))
    (insert closure) ; the request
    (insert answer)  ; the answer
    (goto-char now)
    (replace-regexp "\C-m" "")
    (replace-regexp webster-end-of-record-re "END\n")
    (goto-char now)))






;;;;;;;;;;;;;
;;; webster-mode from here on down

;;; create my syntax table
(progn
  (setq webster-mode-syntax-table (copy-syntax-table
				   text-mode-syntax-table))
  (modify-syntax-entry ?* "w" webster-mode-syntax-table)
  (modify-syntax-entry ?% "w" webster-mode-syntax-table))

;;; create my mode map
(progn
  (setq webster-mode-map (make-sparse-keymap))
  (define-key webster-mode-map "\C-i" 'webster-endings-word)
  (define-key webster-mode-map "\C-j" 'webster-define-word)
  (define-key webster-mode-map "\C-c\C-c" 'webster-define-word)
  (define-key webster-mode-map "\C-c\C-r" 'webster-references-word)
  (define-key webster-mode-map "\C-c\C-t" 'webster-thesaurus-word)
  (define-key webster-mode-map "\C-c\C-d" 'webster-define-word)
  (define-key webster-mode-map "\C-c\C-e" 'webster-complete-word)
  (define-key webster-mode-map "\C-c\C-s" 'webster-spell-word))


(defun webster-mode ()
  "Major mode for interacting with on-line Webster's dictionary.
* and % may be used as wildcards in words.  * can be replaced by any
number of letters, and % by exactly one letter.
\\{webster-mode-map}
Use webster-mode-hook for customization."
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'webster-mode)
  (setq mode-name "Webster")
  (use-local-map webster-mode-map)
  (set-syntax-table webster-mode-syntax-table)
  (run-hooks 'webster-mode-hook))


-- 

			original
scott draves		cheddar
spot@cs.cmu.edu		ranch


