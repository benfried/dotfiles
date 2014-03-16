20-May-92 16:33:32-GMT,4287;000000000001
Return-Path: <ben>
Received: by banzai.cc.columbia.edu (5.59/FCB)
	id AA25053; Wed, 20 May 92 12:33:30 EDT
Date: Wed, 20 May 92 12:33:30 EDT
From: Ben Fried <ben>
Message-Id: <9205201633.AA25053@banzai.cc.columbia.edu>
To: ben

Path: cunixf.cc.columbia.edu!sol.ctr.columbia.edu!spool.mu.edu!olivea!hal.com!hal!brennan
From: brennan@hal.com (Dave Brennan)
Newsgroups: gnu.emacs.sources
Subject: speak.el: Make Emacs speak on Sun Sparc
Message-ID: <BRENNAN.92May17150034@yosemite.hal.com>
Date: 17 May 92 21:00:34 GMT
Article-I.D.: yosemite.BRENNAN.92May17150034
Sender: news@hal.com
Organization: HaL Computer Systems, Austin, TX
Lines: 100

Here is a simple little chunk of code I threw together to have some fun
with the "speak" package from Brown University.  It doesn't sound all that
great, but it is somewhat interesting.  This code could easily be used with
any other program that accepts text from stdin an speaks it.  If anyone
uses it with another such program on any machine, please let me know.

;; LCD Archive Entry:
;; speak|Dave Brennan|brennan@hal.com|
;; Make Emacs speak on Sun Sparc (requires Brown U. speak package)|
;; 92-02-13|1.0|~/misc/speak.el|

;; Copyright 1992, David J. Brennan
;; GNU Copyleft applies.

;; This is a simple interface to the speak package from Brown University.
;; Speak can be ftped from the machine wilma.cs.brown.edu.

;; Interesting functions:

;; M-x speak             Prompt for a string and speak it
;; M-x speak-region      Speak the current region
;; M-x speak-buffer      Speak the current buffer

;; The next three variables are interesting:

;; Make sure scat is in your path or set this to the full path in your .emacs.
(defvar speak-program "scat"
  "*Name of the speak executable.")

(defvar speak-phoneme-directory nil
  "*Directory to look for phonemes.  nil mean use default directory.")

(defvar speak-volume nil
  "*Speech volume from 0.0 to 1.0.  Changes to this variable will (currently)
not change the speech volume after the speech process has started.  nil
means use the default volume of speak-program.")

;; Casual users probably don't care about anything below this.

(defvar speak-phoneme-dir-flag "-d"
  "Option flag used to set the phoneme directory.")

(defvar speak-volume-flag "-v"
  "Option flag used to set the speech volume.")

(defvar speak-process nil
  "Process of the speak-program.")

(defun speak (string)
  (interactive "sSpeak: ")
  "Speak STRING.  When used interactively prompts for string."
  (speak-start-process)
  (process-send-string speak-process (concat string "\n")))

(defun speak-region (start end)
  (interactive "r")
  "Speak the text in region.
When called from a program takes two arguments: START and END."
  (speak-start-process)
  (process-send-region speak-process start end)
  (process-send-string speak-process "\n"))

(defun speak-buffer (&optional buffer)
  (interactive)
  "Speak the text in the current buffer.
When called from a program takes optional arg BUFFER."
  (if buffer
      (save-excursion
	(set-buffer buffer)
	(speak-region (point-min) (point-max)))))

(defun speak-start-process ()
  "Start the speak process if it isn't already running."
  (if (or (eq speak-process nil)
	  (not (eq (process-status speak-process) 'run)))
      (if (file-exists-p speak-program)
	  (let ((args (list speak-program)))
	    ;; Compute arguments
	    (message "Starting the speak process...")
	    (if speak-phoneme-directory
		(setq args (append args (list speak-phoneme-dir-flag
					      speak-phoneme-directory))))
	    (if speak-volume
		(setq args (append (args (list speak-volume-flag
					       speak-volume)))))
	    (setq speak-process (apply 'start-process "speak" nil args))
	    (setq process-sentinel speak-process speak-process-sentinel)
	    (message "Starting the speak process...done."))
	(error "Can't find speak executable: %s." speak-program))))

(defun speak-process-sentinel (proc status)
  "Reset the speak-process variable if the state changes."
  (message "Speak process exited with status %s" status)
  (setq speak-process nil))

--
Dave Brennan                                      HaL Computer Systems
brennan@hal.com                                         (512) 794-2855

Visit the Emacs Lisp Archive: archive.cis.ohio-state.edu:pub/gnu/emacs

