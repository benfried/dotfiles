;; mailcrypt.el v3.1, mail encryption with RIPEM and PGP
;; Copyright (C) 1995  Jin Choi <jsc@mit.edu>
;;                     Patrick LoPresti <patl@lcs.mit.edu>
;; Any comments or suggestions welcome.
;; Inspired by pgp.el, by Gray Watson <gray@antaire.com>.

;; LCD Archive Entry:
;; none yet

;;{{{ Licensing
;; This file is intended to be used with GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;;}}}

;;{{{ TODO
;; * Interface for view-mode in xemacs has changed, how annoying. Must fix.
;; * Cleanup of temp files is pgp specific. Make more general.
;; * Include support for auto-decryption/verification.
;; * Support X-PGP-SIGNED header used by npgp.el.
;; Not really mailcrypt problems, but...
;; * Fix problem with mh-e not observing value of mail-header-separator.
;;}}}

;;{{{ Change Log
;;{{{ Changes from 3.0:
;; * Generate a warning if some public keys are found while others
;;   are not during encryption.
;; * Rewrite calls like (message msg) to (message "%s" msg), in case
;;   msg includes a "%".
;; * Handle case in mc-pgp-decrypt-region when signature verifies, but
;;   key has not been certified.
;; * Put save-excursion around each top-level function.
;; * Handle case in mc-pgp-decrypt-region when signature fails to verify
;;   because you don't have the necessary public key.
;; * Locally bind mc-encrypt-for-me to nil before encrypting in
;;   mc-remail.
;; * Include "+encrypttoself=off" in PGP command line flags.
;; * Include "+verbose=1" in PGP command line flags (finally).
;; * Hacked mc-rmail-verify-signatute to make sure rmailkwd is loaded
;;   before message is verified.
;; * (require 'gnus) when compiling.  Thanks to Peter Arius
;;    <arius@immd2.informatik.uni-erlangen.de>
;;}}}
;;{{{ Changes from 2.0:
;; * C-u to mc-encrypt-message now prompts for an ID to use
;;   for signing.  C-u C-u also prompts for scheme to use.
;; * Signing now uses the From line (pseudonym) to choose key.
;; * Support for multiple secret keys added.  Many internal interfaces
;;   changed.
;; * autoload remailer support for mc-remail.el and set default keybindings.
;; * mc-pgp-always-sign now has a 'never option.
;; * mc-pgp-encrypt-region returns t on success.
;; * Added mc-vm-snarf-keys, from Joe Reinhardt
;;   <jmr@everest.radiology.uiowa.edu>.
;; * Changed mc-snarf-keys to actually snarf all keys in the buffer instead
;;   of just the first one.
;; * In VM, not replacing a message puts the message into its own VM buffer
;;   so you can reply to it, forward it, etc. Thanks to Pat Lopresti
;;   <patl@lcs.mit.edu> for the suggestion.
;; * Abort edit mode in VM and RMAIL decrypt functions if no encrypted 
;;   message was found. 
;; * Added version string.
;; * Applied some new patches from stig adding autoloads and minor additions.
;; * Made check for window-system generic, and only for emacs versions > 19.
;; * Added option to mc-sign-message to disable clearsig when signing messages.
;;   From Stig <stig@hackvan.com>.
;; * Fixed extra comma bug when offering default recipients to encrypt for.
;;}}}
;;{{{ Changes from 1.6:
;; * Decrypting a signed message in RMAIL adds a verified tag to the message.
;; * mc-sign-message takes an optional argument specifying which key to use,
;;   for people who have multiple private keys.
;; * Added mc-{pre,post}-{de,en}cryption-hooks.
;; * Additions to docstrings of the major functions and `mailcrypt-*' aliases
;;   for the same.
;; * Added cleanup for possible temp files left over if a process was
;;   interrupted.
;; * Easier installation instructions.
;; * Lots of little bug fixes from all over. Too many to list
;;   individual credits, but I've tried to include all of them. Thanks
;;   to all who sent them in, especially to John T Kohl who fixed an
;;   especially trying problem.
;; * Another optional argument to mc-insert-public-key that allows the
;;   user to specify which public key to insert when called with a
;;   prefix argument.
;; * Tons of changes from Paul Furnanz <paul_furnanz@rainbow.mentorg.com>:
;; 1) Use the itimer package instead of the timer package if it exists.
;;    This makes the password deactivation code work for Lemacs as well
;;    as emacs 19.
;; 2) Fractured the code, so that there is a single function to use
;;    when calling the encryption program.  The new function is
;;    mc-process-region.  The function copies all data to a temporary
;;    buffer, and does the work there.  This way if you do an undo after
;;    an encryption or signing, your password is not visible on the
;;    screen. 
;; 3) All process output goes to the *MailCrypt* buffer.  No longer use
;;    a separate buffer for decryption, encryption, verification, ...
;;    This allows the user to always look at the *MailCrypt* buffer to
;;    see what pgp or ripem said.
;; 4) No longer call mc-temp-display.  Use display-buffer if there is a
;;    reason to show the buffer (like an error occured).
;; 5) Try to print more useful messages.
;; 6) If an error occurs on encryption, the message is left unchanged.
;;    No reason to undo.
;;}}}
;;{{{ Changes from 1.5:
;; * Changed mc-temp-display to just dump into a temp buffer, without
;;   any fancy display stuff. Pick up show-temp.el if you liked the
;;   display stuff (or uncomment the old mc-temp-buffer and remove the
;;   new version).
;; * Provided a generic read mode function to call in hooks, like the
;;   generic write mode function that was already there.
;; * Fixed bug in regexp that prevented compilation under recent
;;   versions of FSF emacs.
;; * Narrow to headers when extracting default recipients for encryption
;;   to avoid pulling in recipients of included messages.
;; * Use `fillarray' to overwrite passwords with nulls before deactivation
;;   for increased security.
;; * Load mail-extr.el to get mail-extract-address-components defined.
;; Thanks to Kevin Rodgers <kevin@traffic.den.mmc.com> for the following
;; improvements.
;; * Quoted an unquoted lambda expression that prevented optimized 
;;   compilation under emacs 18.
;; * Used `nconc' instead of `append' in various places to save on 
;;   garbage collection.
;; * Modified mc-split to run more efficiently.
;;}}}
;;{{{ Changes from 1.4:
;; * Call mail-extract-address-components on the recipients if we guessed
;;   them from the header fields.
;; * If you don't replace a message with its decrypted version, it will now
;;   pop you into a view buffer with the contents of the message.
;; * Added support for mh-e, contributed by Fritz Knabe <Fritz.Knabe@ecrc.de>
;; * Fixed bug in snarfing keys from menubar under GNUS.
;; * Fixed RIPEM verification problem, thanks to Sergey Gleizer
;;   <sgleizer@cs.nmsu.edu>.
;;}}}
;;{{{ Changes from 1.3:
;; * Temp display function does not barf on F-keys or mouse events.
;;     Thanks to Jonathan Stigelman <stig@key.amdahl.com>
;; * Lucid emacs menu support provided by William Perry <wmperry@indiana.edu>
;; * Cited signed messages would interfere with signature 
;;	verification; fixed.
;;}}}
;;{{{ Changes from 1.2:
;; * Added menu bar support for emacs 19.
;; * Added GNUS support thanks to Samuel Druker <samuel@telmar.com>.
;;}}}
;;{{{ Changes from 1.1:
;; * Added recipients field to mc-encrypt-message.
;;}}}
;;{{{ Changes from 1.0:
;; * Fixed batchmode bug in decryption, where unsigned messages would return
;;   with exit code of 1.
;;}}}
;;{{{ Changes from 0.3b:
;; * Only set PGPPASSFD when needed, so PGP won't break when used
;;   in shell mode.
;; * Use call-process-region instead of shell-command-on-region in order
;;   to detect exit codes.
;; * Changed mc-temp-display to not use the kill ring.
;; * Bug fixes.
;;}}}
;;{{{ Changes from 0.2b:
;; * Prompts for replacement in mc-rmail-decrypt-message.
;; * Bug fixes.
;;}}}
;;{{{ Changes from 0.1b:
;; * Several bug fixes.
;; Contributed by Jason Merrill <jason@cygnus.com>:
;; * VM mailreader support
;; * Support for addresses with spaces and <>'s in them
;; * Support for using an explicit path for the pgp executable
;; * Key management functions
;; * The ability to avoid some of the prompts when encrypting
;; * Assumes mc-default-scheme unless prefixed
;;}}}

;;}}}

;;{{{ Usage:

;;{{{ Installation:

;; To use, put something like the following elisp into your .emacs file.
;; You may want to set some of the user variables there as well,
;; particularly mc-default-scheme.

;; Currently supported modes are RMAIL, VM, mh-e, and gnus. Check out
;; the section on mode specific functions to see what hooks you can bind to.

;;(autoload 'mc-install-write-mode "mailcrypt" nil t)
;;(autoload 'mc-install-read-mode "mailcrypt" nil t)

;;(add-hook 'mail-mode-hook 'mc-install-write-mode)  ; for writing modes
;;(add-hook 'rmail-mode-hook 'mc-install-read-mode)  ; for reading modes


;; hooks to use:
;; PACKAGE 	READ HOOK		WRITE HOOK
;; -------	---------		----------
;; rmail: 	rmail-mode-hook		mail-mode-hook
;; vm:		vm-mode-hook		vm-mail-mode-hook
;; mh-e:	mh-folder-mode-hook	mh-letter-mode-hook
;; gnus:	gnus-summary-mode-hook	news-reply-mode-hook

;;{{{ Installation functions; you can ignore these.

(autoload 'mc-remailer-encrypt-for-chain "mc-remail" nil t)
(autoload 'mc-remailer-insert-response-block "mc-remail" nil t)
(autoload 'mc-remailer-insert-pseudonym "mc-remail" nil t)

;;;###autoload
(defun mc-install-write-mode ()
  (if (and window-system
	   (string-match "19" emacs-version))
      (mc-create-write-menu-bar))
  (local-set-key "\C-ce" 'mc-encrypt-message)
  (local-set-key "\C-cs" 'mc-sign-message)
  (local-set-key "\C-ca" 'mc-insert-public-key)
  ;; Remailer bindings.
  (local-set-key "\C-cr" 'mc-remailer-encrypt-for-chain)
  (local-set-key "\C-cb" 'mc-remailer-insert-response-block)
  (local-set-key "\C-cp" 'mc-remailer-insert-pseudonym))

;;;###autoload
(defun mc-install-read-mode ()
  (let ((decrypt (nth 0 (cdr (assoc major-mode mc-modes-alist))))
	(verify (nth 1 (cdr (assoc major-mode mc-modes-alist))))
	(snarf (nth 2 (cdr (assoc major-mode mc-modes-alist)))))
    (if (not (and decrypt verify))
	(error "Decrypt, verify functions not defined for this major mode."))
    (if (not snarf)
	(setq snarf 'mc-snarf-keys))
    (local-set-key "\C-cd" decrypt)
    (local-set-key "\C-cv" verify)
    (local-set-key "\C-ca" snarf))
  (if (and window-system
	   (string-match "19" emacs-version))
      (mc-create-read-menu-bar)))
;;}}}

;;}}}
;;{{{ Security Considerations

;; I've tried to write this with security in mind, especially in
;; regard to the passphrase used to encrypt the private key.

;; No passphrase is ever passed by command line or environment
;; variable. The passphrase may be temporarily stored into an elisp
;; variable to allow multiple encryptions/decryptions within a short
;; period of time without having to type it in each time. It will
;; deactivate automatically some time after its last use (default one
;; minute; see `mc-passwd-timeout') if you are running emacs 19. This
;; is to prevent someone from walking up to your computer while you're
;; gone and looking up your passphrase. If you are using an older
;; version of emacs, you can either set mc-passwd-timeout to nil,
;; which disables passphrase cacheing, or manually deactivate your
;; passphrase when you are done with it by typing `M-x mc-deactivate-passwd'.

;; The passphrase may still be visible shortly after entry as lossage
;; (the last 100 characters entered can be displayed by typing 
;; `C-h l'). I've taken no steps to deal with this, as I don't think
;; anything *can* be done. If you are the paranoid type, make sure you
;; type at least a hundred keys after entering your passphrase before
;; you leave your emacs unattended.

;; If you are truly security conscious, you should, of course, never
;; leave your computer unattended while you're logged in....

;;}}}
;;{{{ CAVEAT:

;; This was written under emacs v19. Its behavior under older versions
;; of emacs is untested. If something breaks under emacs 18, please
;; feel free to fix it and send me patches.
;;}}}
;;{{{ Note:
;; The funny triple braces you see are used by `folding-mode', a minor
;; mode by Jamie Lokier, available from the elisp archive.
;;}}}

;;}}}


;;{{{ Load some required packages
(require 'comint)
(require 'mail-utils)
(eval-when-compile
  (condition-case nil
      (require 'vm)
    (error nil))
  (condition-case nil
      (require 'gnus)
    (error nil)))
(require 'mail-extr)

;; Load the timer package if we're running non-Lucid emacs 19,
;; so that (featurep 'timer) returns t later on.
(if (and (string-match "^19" emacs-version)
	 (not (string-match "Lucid\\|Xemacs" emacs-version)))
    (require 'timer))

;;{{{ The PGP package.
;;; This is the mailcrypt package for PGP. It is currently the only one.

;;; ------------------------------------------------------------------------
(defvar mc-pgp-user-id (user-login-name)
  "*PGP ID of your default identity.")
(defvar mc-pgp-always-sign nil 
  "*If t, always sign encrypted PGP messages, or never sign if 'never.")
(defvar mc-pgp-path "pgp" "*The PGP executable.")

(defconst mc-pgp-msg-begin-line "-----BEGIN PGP MESSAGE-----"
  "Text for start of PGP message delimiter.")
(defconst mc-pgp-msg-end-line "-----END PGP MESSAGE-----"
  "Text for end of PGP message delimiter.")
(defconst mc-pgp-signed-begin-line "-----BEGIN PGP SIGNED MESSAGE-----"
  "Text for start of PGP signed messages.")
(defconst mc-pgp-signed-end-line "-----END PGP SIGNATURE-----"
  "Text for end of PGP signed messages.")
(defconst mc-pgp-key-begin-line "-----BEGIN PGP PUBLIC KEY BLOCK-----"
  "Text for start of PGP public key.")
(defconst mc-pgp-key-end-line "-----END PGP PUBLIC KEY BLOCK-----"
  "Text for end of PGP public key.")
(defconst mc-pgp-error-re "^\\(ERROR\\|WARNING\\):.*"
  "Regular expression matching an error from PGP")
(defconst mc-pgp-sigok-re "^.*Good signature.*"
  "Regular expression matching a PGP signature validation message")
(defconst mc-pgp-newkey-re "\\(No\\|[0-9]+\\)\\s-+new.*"
  "Regular expression matching a PGP signature snarf message")
(defconst mc-pgp-nokey-re "Cannot find the public key matching.*"
  "Regular expression matching a PGP missing-key messsage")


(defvar mc-pgp-keydir nil
  "Directory in which keyrings are stored.")

(defun mc-get-pgp-keydir ()
  (if (null mc-pgp-keydir)
      (let ((buffer (generate-new-buffer " *mailcrypt temp"))
	    (obuf (current-buffer)))
	(unwind-protect
	    (progn
	      (call-process mc-pgp-path nil buffer nil
			    "+verbose=1" "-kv" "XXXXXXXXXX")
	      (set-buffer buffer)
	      (goto-char (point-min))
	      (re-search-forward "^Key ring:\\s *'\\(.*\\)'")
	      (setq mc-pgp-keydir
		    (file-name-directory
		     (buffer-substring (match-beginning 1) (match-end 1)))))
	  (set-buffer obuf)
	  (kill-buffer buffer))))
  mc-pgp-keydir)

(defvar mc-pgp-key-cache nil
  "Association list mapping PGP IDs to canonical \"keys\".  A \"key\"
is a pair (USER-ID . KEY-ID) which identifies the canonical IDs of the
PGP ID.")

(defun mc-pgp-lookup-key (str)
  ;; Look up the string STR in the user's secret key ring.  Return a
  ;; pair of strings (USER-ID . KEY-ID) which uniquely identifies the
  ;; matching key, or nil if no key matches.
  (let ((keyring (concat (mc-get-pgp-keydir) "secring"))
	(result (cdr-safe (assoc str mc-pgp-key-cache)))
	(key-regexp
	 "^\\(pub\\|sec\\)\\s +[^/]+/\\(\\S *\\)\\s +\\S +\\s +\\(.*\\)$")
	(obuf (current-buffer))
	buffer)
    (if (null result)
	(unwind-protect
	    (progn
	      (setq buffer (generate-new-buffer " *mailcrypt temp"))
	      (call-process mc-pgp-path nil buffer nil "-kv" str keyring)
	      (set-buffer buffer)
	      (goto-char (point-min))
	      (if (re-search-forward key-regexp nil t)
		  (progn
		    (setq result
			  (cons (buffer-substring
				 (match-beginning 3) (match-end 3))
				(concat
				 "0x"
				 (buffer-substring
				  (match-beginning 2) (match-end 2)))))
		    (setq mc-pgp-key-cache (cons (cons str result)
						 mc-pgp-key-cache)))))
	  (kill-buffer buffer)
	  (set-buffer obuf)))
    (if (null result)
	(error "No PGP secret key for %s" str))
    result))

(defun mc-pgp-encrypt-region (recipients start end &optional id)
  (let ((process-environment process-environment)
	(buffer (get-buffer-create mc-buffer-name))
	(msg "Encrypting...")
	args key passwd)
    (and mc-encrypt-for-me
	 (setq recipients (cons mc-pgp-user-id recipients)))
    (setq args (list "+encrypttoself=off +verbose=1" "+batchmode" "-feat"))
    (if (and (not (eq mc-pgp-always-sign 'never))
	     (or mc-pgp-always-sign (y-or-n-p "Sign the message? ")))
	(progn
	  (setq key (mc-pgp-lookup-key (or id mc-pgp-user-id)))
	  (setq passwd
		(mc-activate-passwd
		 (format "PGP passphrase for %s (%s): " (car key) (cdr key))
		 (cdr key)))
	  (setq args
		(nconc args (list "-s" "-u" (cdr key))))
	  (setenv "PGPPASSFD" "0")
	  (setq msg (format "Encrypting+signing as %s ..." (car key)))))

    (setq args (nconc args recipients))
    
    (message "%s" msg)
    (cond ((not (mc-process-region start end passwd mc-pgp-path args
				   buffer mc-pgp-msg-begin-line t))
	   (mc-display-buffer buffer)
	   (mc-message mc-pgp-error-re buffer "Error while encrypting" t))
	  ((mc-message mc-pgp-nokey-re buffer)
	   (mc-display-buffer buffer)
	   nil)
	  (t (message "%s Done." msg) t))))


(defun mc-pgp-decrypt-region (start end &optional id)
  ;; returns a pair (SUCCEEDED . VERIFIED) where SUCCEEDED is t if
  ;; the decryption succeeded and verified is t if there was a valid signature
  (let ((process-environment process-environment)
	(buffer (get-buffer-create mc-buffer-name))
	(obuf (current-buffer))
	key new-key passwd)
    (setq key (mc-pgp-lookup-key (or id mc-pgp-user-id)))
    (setq passwd
	  (mc-activate-passwd
	   (format "PGP passphrase for %s (%s): " (car key) (cdr key))
	   (cdr key)))
    (setenv "PGPPASSFD" "0")
    (message "Decrypting...")
    (cond
     ((mc-process-region
       start end passwd mc-pgp-path '("+verbose=1" "+batchmode" "-f") buffer
       (if (null buffer-read-only)
	   '("^WARNING.*signature integrity\\.\n"
	     "^WARNING:  Because this public key.*\n.*\n.*\n"
	     "^Signature made.*\n"
	     "Just a moment\\.+"))
       nil '(1))
      (message "Decrypting... Done.")
      (if buffer-read-only
	  (pop-to-buffer buffer))
      (mc-message "^Key matching expected Key ID \\(\\S +\\) not found"
	  buffer)
      (cons t (mc-message mc-pgp-sigok-re buffer "Decrypted.")))
     ;; Decryption failed; maybe we need to use a different user-id
     ((and
       (set-buffer buffer)
       (goto-char (point-min))
       (re-search-forward
	"^Key for user ID:.*\n.*Key ID \\([0-9A-F]+\\)" nil t)
       (setq new-key
	     (mc-pgp-lookup-key
	      (concat "0x" (buffer-substring (match-beginning 1)
					     (match-end 1)))))
       (not (equal key new-key)))
      (set-buffer obuf)
      (mc-pgp-decrypt-region start end (cdr new-key)))
     (t
      (mc-display-buffer buffer)
      (mc-message mc-pgp-error-re buffer "Error decrypting buffer" t)
      (cons nil nil)))))

(defun mc-pgp-sign-region (start end &optional id unclear)
  (let ((process-environment process-environment)
	(buffer (get-buffer-create mc-buffer-name))
	passwd arglist key)
    (setq key (mc-pgp-lookup-key (or id mc-pgp-user-id)))
    (setq passwd
	  (mc-activate-passwd
	   (format "PGP passphrase for %s (%s): " (car key) (cdr key))
	   (cdr key)))
    (message "Signing as %s ..." (car key))
    (setenv "PGPPASSFD" "0")
    (setq arglist
	  (list
	   "-fast" "+verbose=1"
	    (format "+clearsig=%s" (if unclear "off" "on"))
	    "+batchmode" "-u" (cdr key)))
    (if (not (mc-process-region start end passwd mc-pgp-path arglist
				buffer mc-pgp-signed-begin-line t))
	(progn
	  (mc-display-buffer buffer)
	  (mc-message mc-pgp-error-re buffer "PGP signing failed" t)
	  nil)
      (message "Signing as %s ... Done." (car key))
      t)))


(defun mc-pgp-verify-region (start end)
  (let ((buffer (get-buffer-create mc-buffer-name)))
    (message "Verifying...")
    (if (mc-process-region start end nil mc-pgp-path
			   '("+verbose=1" "+batchmode" "-f") buffer)
	(prog1
	    t
	  (mc-message mc-pgp-sigok-re buffer "Good signature"))
      (mc-display-buffer buffer)
      (mc-message mc-pgp-error-re buffer "Error verifying PGP signature")
      nil)))

(defun mc-pgp-insert-public-key (&optional id)
  (let ((buffer (get-buffer-create mc-buffer-name)))
    (setq id (or id mc-pgp-user-id))
    (if (not (mc-process-region (point) (point) nil
				mc-pgp-path
				(list "+verbose=1" "+batchmode" "-kxaf" id)
				buffer
				mc-pgp-key-begin-line t))
	(mc-message mc-pgp-error-re buffer
		    "Error including signature")
      (mc-message "Key for user ID: .*" buffer))))


(defun mc-pgp-snarf-keys (start end)
  ;; Returns number of keys found.
  (let ((buffer (get-buffer-create mc-buffer-name))
	tmpstr)
    (message "Snarfing...")
    (if (mc-process-region start end nil
			   mc-pgp-path '("+verbose=1" "+batchmode" "-kaf")
			   buffer)
	(save-excursion
	  (set-buffer buffer)
	  (goto-char (point-min))
	  (if (re-search-forward mc-pgp-newkey-re nil t)
	      (progn
		(setq tmpstr (buffer-substring (match-beginning 1) 
					       (match-end 1)))
		(if (equal tmpstr "No")
		    0
		  (car (read-from-string tmpstr))))))
      (mc-display-buffer buffer)
      (mc-message mc-pgp-error-re buffer "Error snarfing PGP key" t)
      0)))

(defvar mc-scheme-pgp
  (list
   (cons 'encryption-func 		'mc-pgp-encrypt-region)
   (cons 'decryption-func		'mc-pgp-decrypt-region)
   (cons 'signing-func			'mc-pgp-sign-region)
   (cons 'verification-func 		'mc-pgp-verify-region)
   (cons 'key-insertion-func 		'mc-pgp-insert-public-key)
   (cons 'snarf-func			'mc-pgp-snarf-keys)
   (cons 'msg-begin-line 		mc-pgp-msg-begin-line)
   (cons 'msg-end-line 			mc-pgp-msg-end-line)
   (cons 'signed-begin-line 		mc-pgp-signed-begin-line)
   (cons 'signed-end-line 		mc-pgp-signed-end-line)
   (cons 'key-begin-line 		mc-pgp-key-begin-line)
   (cons 'key-end-line 			mc-pgp-key-end-line)
   (cons 'user-id			mc-pgp-user-id)))
;;}}}

;;}}}
;;{{{ User variables.
(defconst mc-version "3.1")
(defvar mc-default-scheme mc-scheme-pgp "*Default encryption scheme to use.")
(defvar mc-passwd-timeout 60
  "*Time to deactivate password in seconds after a use.
nil or 0 means deactivate immediately.  If the only timer package available
is the 'timer' package, then this can be a string in timer format.")

(defvar mc-ripem-user-id (or (getenv "RIPEM_USER_NAME")
			     (user-full-name) "*Your RIPEM user ID."))

(defvar mc-always-replace nil "*Decrypt messages in place without prompting.")
(defvar mc-use-default-recipients nil
  "*Assume that the message should be encoded for everyone listed in the To:
and Cc: fields.")
(defvar mc-encrypt-for-me nil
  "*Encrypt all outgoing messages with user's public key.")

(defvar mc-pre-encryption-hook nil 
  "*List of hook functions to run immediately before encrypting.")
(defvar mc-post-encryption-hook nil 
  "*List of hook functions to run after encrypting.")
(defvar mc-pre-decryption-hook nil 
  "*List of hook functions to run immediately before decrypting.")
(defvar mc-post-decryption-hook nil 
  "*List of hook functions to run after decrypting.")


;;}}}
;;{{{ Program variables and constants.

(defvar mc-timer nil "Timer object for password deactivation.")

(defvar mc-passwd-cache nil "Cache for passphrases.")

;; You might consider interposing a program such as below, which
;; refuses to let pgp get hold of a terminal; this makes it work
;; better as a slave process:
;;
;;#include <unistd.h>
;;#include <sys/types.h>
;;#include <sys/wait.h>
;;/*
;; * call setsid() in child
;; * to revoke controlling terminal, then execvp pgp with args.
;; */
;;main(int argc, char *argv[])
;;{
;;    pid_t pid;
;;    int status;
;;    pid = fork();
;;    if (pid == 0) {
;;	/* child */
;;	if (setsid() == -1)
;;	    perror("setsid");
;;	execvp("pgp", argv);
;;	perror("cannot execvp pgp");
;;	exit(1);
;;    } else if (pid > 0) {
;;	waitpid(pid, &status, 0);
;;	exit(WEXITSTATUS(status));
;;    } else {
;;	perror("fork");
;;	exit(1);
;;    }
;;}


(defconst mc-buffer-name "*MailCrypt*"
  "Name of temporary buffer for mailcrypt")

(defvar mc-schemes
  (list
   (cons "pgp" mc-scheme-pgp)))

;;}}}
;;{{{ Utility functions.

(defun mc-message-delimiter-positions (start-re end-re &optional begin)
  ;; Returns pair of integers (START . END) that delimit message marked off
  ;; by the regular expressions start-re and end-re. Optional argument BEGIN
  ;; determines where we should start looking from.
  (if (null begin)
      (setq begin (point-min)))
  (goto-char begin)
  (let (start retval bad-re)
    (catch 'notfound
      (save-excursion
	(or (re-search-forward (concat "^" start-re) nil t)
	    (throw 'notfound nil))
	(setq start (match-beginning 0))
	(or (re-search-forward (concat "^" end-re "\n") nil t)
	    (throw 'notfound nil))
	(cons start (point))))))


(defun mc-split (regexp str)
  "Splits STR into a list of elements which were separated by REGEXP,
stripping initial and trailing whitespace."
  (let ((data (match-data))
	(retval '())
	beg end)
    (unwind-protect
	(progn
	  (string-match "[ \t\n]*" str)	; Will always match at 0
	  (setq beg (match-end 0))
	  ;; This will break if there are newlines in str XXX
	  (setq end (string-match "[ \t\n]*$" str))
	  (while (string-match regexp str beg)
	    (setq retval
		  (cons (substring str beg (match-beginning 0)) 
			retval))
	    (setq beg (match-end 0)))
	  (if (not (= (length str) beg)) ; Not end
	      (setq retval (cons (substring str beg end) retval)))
	  (nreverse retval))
      (store-match-data data))))

(defun mc-temp-display (beg end &optional name)
  (let (tmp)
    (if (not name)
	(setq name mc-buffer-name))
    (if (string-match name "*ERROR*")
	(progn
	  (message "mailcrypt: An error occured!  See *ERROR* buffer.")
	  (beep)))
    (setq tmp (buffer-substring beg end))
    (delete-region beg end)
    (save-excursion
      (save-window-excursion
	(with-output-to-temp-buffer name
	  (princ tmp))))))

;;(defun mc-temp-display (beg end &optional name)
;;  (let (tmp)
;;    (if (not name)
;;	(setq name "*Mailcrypt Temp*"))
;;    (setq tmp (buffer-substring beg end))
;;    (delete-region beg end)
;;    (save-excursion
;;      (set-buffer (generate-new-buffer name))
;;      (insert tmp)
;;      (goto-char (point-min))
;;      (save-window-excursion
;;	(shrink-window-if-larger-than-buffer 
;;	 (display-buffer (current-buffer)))
;;	(message "Press any key to remove the %s window." name)
;;	(cond ((and (string-match "19\\." emacs-version)
;;		    (not (string-match "XEmacs" (emacs-version))))
;;	       (read-event))
;;	      (t
;;	       (read-char)))
;;	(kill-buffer (current-buffer))))))

(defun mc-display-buffer (buffer)
  "Like display-buffer, but always display top of the buffer."
  (save-excursion
    (set-buffer buffer)
    (goto-char (point-min))
    (display-buffer buffer)))

(defun mc-message (msg &optional buffer default iserr)
  ;; returns t if we used msg, nil if we used default
  (let ((retval t))
    (if buffer
	(setq msg
	      (save-excursion
		(set-buffer buffer)
		(goto-char (point-min))
		(if (re-search-forward msg nil t)
		    (buffer-substring (match-beginning 0) (match-end 0))
		  (setq retval nil)
		  default))))
    (prog1
	retval
      (if iserr
	  (mc-deactivate-passwd))	; in case error is bad passphrase
      (and msg (message "%s" msg)))))

(defun mc-process-region (beg end passwd program args
			      &optional buffer copy keep permit-status)
  (if (stringp copy)
      (setq copy (list copy)))
  (let ((oldbuf (current-buffer))
	mybuf result)
    (unwind-protect
	(progn
	  (setq mybuf (or buffer (generate-new-buffer " mailcrypt temp")))
	  (set-buffer mybuf)
	  (erase-buffer)
	  (buffer-disable-undo mybuf)
	  (if passwd
	      (progn
		(insert passwd "\n")
		(or mc-passwd-timeout (mc-deactivate-passwd))))
	  (insert-buffer-substring oldbuf beg end)

	  ;; Catch a quit signal so we can clean up any
	  ;; temp files lying around if the user nukes us.
	  (setq result (condition-case nil
			   (apply 'call-process-region
				  (nconc (list (point-min) (point-max)
					       program
					       t t nil)
					 args))
			 (quit
			  ;; Don't let the user interrupt the cleanup.
			  ;; This cleanup is PGP specific.
			  (let ((inhibit-quit t))
			    (shell-command "rm -f pgptemp.*")
			    (setq quit-flag nil)
			    "Stopped at user request"))))
	  ;; CRNL -> NL
	  (goto-char (point-min)) 
	  (while (search-forward "\r\n" nil t)
	    (forward-char -1)
	    (delete-char -1))
	  
	  (cond ((stringp result)	;process terminated somehow
		 (message "Mailcrypt process died abnormally: '%s'" result)
		 (sit-for 2)
		 nil)
		((or (zerop result) (memq result permit-status))
		 (prog1
		     t
		   (if copy
		       (let (start)
			 (goto-char (point-min))
			 (and (listp copy)
			      (let ((c copy))
				(while (and c
					    (null (re-search-forward (car c) 
								     nil t)))
				  (setq c (cdr c)))
				c)
			      keep (goto-char (match-beginning 0)))
			 (setq start (point))
			 (save-excursion
			   (set-buffer oldbuf)
			   (delete-region beg end)
			   (goto-char beg)
			   (insert-buffer-substring mybuf start))
			 (delete-region start (point-max))))))
		(t
		 nil)))
      (set-buffer oldbuf)
      (and mybuf (or (null result) (null buffer)) (kill-buffer mybuf)))))

;;}}}
;;{{{ Passphrase management

(defun mc-activate-passwd (prompt id)
  "Activate the passphrase matching ID, using PROMPT for a prompt.
Return the passphrase."
  (cond ((featurep 'itimer)
	 (if mc-timer (delete-itimer mc-timer))
	 (setq mc-timer (if mc-passwd-timeout
			    (start-itimer "mc-itimer"
					  'mc-deactivate-passwd
					  mc-passwd-timeout))))
	((featurep 'timer)
	 (let ((string-time (if (integerp mc-passwd-timeout)
				(format "%d sec" mc-passwd-timeout)
			      mc-passwd-timeout)))
	   (if mc-timer (cancel-timer mc-timer))
	   (setq mc-timer (if string-time
			      (run-at-time string-time 
					   nil 'mc-deactivate-passwd)
			    nil)))))
  (let ((cell (assoc id mc-passwd-cache))
	passwd)
    (setq passwd (cdr-safe cell))
    (if (not passwd)
      (setq passwd (comint-read-noecho prompt)))
    (if cell
	(setcdr cell passwd)
      (setq mc-passwd-cache (cons (cons id passwd) mc-passwd-cache)))
    passwd))

;;;###autoload
(defun mc-deactivate-passwd ()
  "*Deactivates the passphrase cache."
  (interactive)
  (and mc-timer (fboundp 'cancel-timer) (cancel-timer mc-timer))
  (mapcar
   (function
    (lambda (cell)
      (and (stringp (cdr-safe cell)) (fillarray (cdr cell) 0))
      (setcdr cell nil)))
   mc-passwd-cache)
  (message "Passphrase%s deactivated"
	   (if (> (length mc-passwd-cache) 1) "s" "")))

;;}}}
;;{{{ Encryption

(defun mc-cleanup-recipient-headers (str)
  ;; Takes a comma separated string of recipients to encrypt for and,
  ;; assuming they were possibly extracted from the headers of a reply,
  ;; returns a list of the address components.
  (mapcar (function
	   (lambda (x)
	     (car (cdr (mail-extract-address-components x)))))
	  (mc-split "\\([ \t\n]*,[ \t\n]*\\)+" str)))

(defun mc-find-headers-end ()
  (save-excursion
    (goto-char (point-min))
    (re-search-forward
     (concat "^" (regexp-quote mail-header-separator) "\n"))
    (if (looking-at "^::\n")
	(re-search-forward "^\n" nil t))
    (if (looking-at "^##\n")
	(re-search-forward "^\n" nil t))
    (point)))


;;;###autoload
(defun mc-encrypt-message (&optional recipients scheme start end query-from)
  "*Encrypt the message to RECIPIENTS using the given encryption SCHEME.
RECIPIENTS is a comma separated string. If SCHEME is nil, use the value
of `mc-default-scheme'.  Returns t on success, nil otherwise.

By default, this function is bound to `C-c e' in mail composing modes."
  (interactive
   (let ((val (prefix-numeric-value current-prefix-arg)))
     (list
      nil
      (if (>= val 16)
	  (cdr (assoc (completing-read "Encryption Scheme: "
				       mc-schemes) mc-schemes))
	nil)
      nil
      nil
      (>= val 4))))

  (save-excursion
    (run-hooks 'mc-pre-encryption-hook)
    (let ((default-recipients
	    (save-restriction
	      (goto-char (point-min))
	      (search-forward mail-header-separator)
	      (narrow-to-region (point-min) (point))
	      (mapconcat (function (lambda (n) n))
			 (delq nil		       
			       (list (mail-fetch-field "to" nil t)
				     (mail-fetch-field "bcc" nil t)
				     (mail-fetch-field "cc" nil t)))
			 ", ")))
	  (headers-end (mc-find-headers-end))
	  (mc-pgp-always-sign mc-pgp-always-sign))
      (save-restriction
	(narrow-to-region (point-min) headers-end)
	(setq from (mail-fetch-field "From")))
      
      (if query-from
	  (setq from (read-string "User ID: "
				  (if (stringp from) (cons from 1) nil))
		mc-pgp-always-sign t))
      
      (or scheme (setq scheme mc-default-scheme))
      (setq recipients
	    (cond (recipients		; given as function argument
		   (mc-split "\\([ \t\n]*,[ \t\n]*\\)+" recipients))
		  (mc-use-default-recipients
		 (mc-cleanup-recipient-headers default-recipients))
		  (t			; prompt for it
		   (mc-cleanup-recipient-headers
		    (read-from-minibuffer "Recipients: "
					  default-recipients)))))
      
      (or recipients (error "No recipients!"))
      
      (or start (setq start headers-end))
      (or end (setq end (point-max)))

      (goto-char (point-min))
      (if (mc-encrypt-region scheme recipients start end from)
	  (progn
	    (run-hooks 'mc-post-encryption-hook)
	    t)
	nil))))

(defsubst mc-encrypt-region (scheme recipients start end &optional id)
  ;; Encrypt region with SCHEME between START and END for
  ;; RECIPIENTS using BUFFER.
  (funcall (cdr (assoc 'encryption-func scheme)) recipients start end id))

;;}}}
;;{{{ Decryption

;;;###autoload
(defun mc-decrypt-message ()
  "*Decrypt whatever message is in the current buffer.
Returns a pair (SUCCEEDED . VERIFIED) where SUCCEEDED is t if the encryption
succeeded and VERIFIED is t if it had a valid signature.

By default, this function is bound to `C-c d' in reading modes."
  (interactive)
  (save-excursion
    (let ((schemes mc-schemes)
	  limits scheme)
      (while (and schemes
		  (setq scheme (car schemes))
		  (not (setq limits
			     (mc-message-delimiter-positions
			      (cdr (assoc 'msg-begin-line scheme))
			      (cdr (assoc 'msg-end-line scheme))))))
	(setq schemes (cdr schemes)))
      
      (if (null limits)
	  (error "Found no encrypted message in this buffer.")
	(run-hooks 'mc-pre-decryption-hook)
	(let ((resultval (funcall (cdr (assoc 'decryption-func scheme)) 
				  (car limits) (cdr limits))))
	  (goto-char (point-min))
	  (if (car resultval) ; decryption succeeded
	      (run-hooks 'mc-post-decryption-hook))
	  resultval)))))
;;}}}  
;;{{{ Signing

;;;###autoload
(defun mc-sign-message (&optional withkey scheme unclearsig)
  "*Clear sign the message.
With one prefix arg, prompts for private key to use, with two prefix args,
also prompts for encryption scheme to use.  With negative prefix arg,
inhibits clearsigning (pgp).

By default, this function is bound to `C-c s' in composition modes."
  (interactive
   (let (arglist)
     (cond ((eq '- current-prefix-arg)
	    (setq arglist '(nil nil t)))
	   ((not (and (listp current-prefix-arg)
		      (numberp (car current-prefix-arg))))
	    nil)
	   (t (if (>= (car current-prefix-arg) 16)
		  (setq arglist
			(cons (cdr (assoc
				    (completing-read "Encryption Scheme: "
						     mc-schemes)
				    mc-schemes))
			      arglist)))
	      (if (>= (car current-prefix-arg) 4)
		  (setq arglist (cons (read-string "User ID: ") arglist)))))
     arglist))
  (save-restriction
    (or scheme (setq scheme mc-default-scheme))
    (let (headers-end)
      (or withkey
	  (progn
	    (setq headers-end (mc-find-headers-end))
	    (save-restriction
	      (narrow-to-region (point-min) headers-end)
	      (setq withkey (mail-fetch-field "From")))))
      (funcall (cdr (assoc 'signing-func scheme))
	       headers-end (point-max) withkey unclearsig))))

;;}}}
;;{{{ Signature verification

;;{{{ mc-verify-signature

;;;###autoload
(defun mc-verify-signature ()
  "*Verify the signature of the signed message in the current buffer.
Show the result as a message in the minibuffer. Returns t if the signature
is verified.

By default, this function is bound to `C-c v' in reading modes."
  (interactive)
  (save-excursion
    (let ((schemes mc-schemes)
	  limits scheme)
      (while (and schemes
		  (setq scheme (car schemes))
		  (not (setq limits
			     (mc-message-delimiter-positions
			      (cdr (assoc 'signed-begin-line scheme))
			      (cdr (assoc 'signed-end-line scheme))))))
	(setq schemes (cdr schemes)))
      
      (if (null limits)
	  (error "Found no signed message in this buffer.")
	(funcall (cdr (assoc 'verification-func scheme))
		 (car limits) (cdr limits))))))

;;}}}

;;}}}
;;{{{ Key management

;;{{{ mc-insert-public-key

;;;###autoload
(defun mc-insert-public-key (&optional userid scheme)
  "*Insert your public key at point.
With one prefix arg, prompts for user id to use. With two prefix
args, prompts for encryption scheme."
  (interactive
   (let (arglist)
     (if (not (and (listp current-prefix-arg)
		   (numberp (car current-prefix-arg))))
	 nil
       (if (>= (car current-prefix-arg) 16)
	   (setq arglist
		 (cons (cdr (assoc (completing-read "Encryption Scheme: "
						    mc-schemes)
				   mc-schemes))
		       arglist)))
       (if (>= (car current-prefix-arg) 4)
	   (setq arglist (cons (read-string "User ID: ") arglist))))
     arglist))

  (if (< (point) (mc-find-headers-end))
      (error "Can't insert key inside message header"))
  (or scheme (setq scheme mc-default-scheme))
  (or userid (setq userid (cdr (assoc 'user-id scheme))))
    
  ;; (goto-char (point-max))
  (if (not (bolp))
      (insert "\n"))
  (funcall (cdr (assoc 'key-insertion-func scheme)) userid))

;;}}}
;;{{{ mc-snarf-keys

;;;###autoload
(defun mc-snarf-keys ()
  "*Add all public keys in the buffer to your keyring."
  (interactive)
  (let ((schemes mc-schemes)
	(start (point-min))
	(found 0)
	limits scheme)
    (save-excursion
      (catch 'done
	(while t
	  (while (and schemes
		      (setq scheme (car schemes))
		      (not (setq limits
				 (mc-message-delimiter-positions
				  (cdr (assoc 'key-begin-line scheme))
				  (cdr (assoc 'key-end-line scheme))
				  start))))
	    (setq schemes (cdr schemes)))
	  (if (null limits)
	      (throw 'done found)
	    (setq start (cdr limits))
	    (setq found (+ found (funcall (cdr (assoc 'snarf-func scheme)) 
					  (car limits) (cdr limits)))))))
      (message (format "%d new key%s found" found
		       (if (eq 1 found) "" "s"))))))
;;}}}

;;}}}
;;{{{ Mode specific functions

(defvar mc-modes-alist
  (list (cons 'rmail-mode (list 'mc-rmail-decrypt-message
				'mc-rmail-verify-signature))
	(cons 'vm-mode (list 'mc-vm-decrypt-message
			     'mc-vm-verify-signature
			     'mc-vm-snarf-keys))
	(cons 'mh-folder-mode (list 'mc-mh-decrypt-message
				    'mc-mh-verify-signature
				    'mc-mh-snarf-keys))
	(cons 'gnus-summary-mode (list 'mc-gnus-summary-decrypt-message
				       'mc-gnus-summary-verify-signature
				       'mc-gnus-summary-snarf-keys)))
  "*Association list to specify mode specific functions for reading.
Entries are of the form (MODE . (DECRYPT VERIFY SNARF)).
The SNARF is optional and defaults to `mc-snarf-keys'.")

;;{{{ RMAIL
;;;###autoload
(defun mc-rmail-verify-signature ()
  "*Verify the signature in the current message."
  (interactive)
  (if (not (equal mode-name "RMAIL"))
      (error "mc-rmail-verify-signature called in a non-RMAIL buffer"))
  ;; Hack to load rmailkwd before verifying sig
  (rmail-add-label "verified")
  (rmail-kill-label "verified")
  (if (mc-verify-signature)
      (rmail-add-label "verified")))

;;;###autoload
(defun mc-rmail-decrypt-message ()
  "*Decrypt the contents of this message"
  (interactive)
  (let ((oldbuf (current-buffer))
	noerr
	decryption-result
	condition-data)
    (if (not (equal mode-name "RMAIL"))
	(error "mc-rmail-decrypt-message called in a non-RMAIL buffer"))
    (rmail-edit-current-message)
    (cond ((not
	    (condition-case condition-data
		(progn (setq decryption-result (mc-decrypt-message))
		       (car decryption-result))
	      (error
	       (rmail-abort-edit)
	       (error (message "Decryption failed: %s"
			       (car (cdr condition-data)))))))
	   (message "Decryption failed.")
	   (rmail-abort-edit))
	  ((or mc-always-replace
	       (y-or-n-p "Replace encrypted message with decrypted? "))
	   (rmail-cease-edit)
	   (rmail-kill-label "edited")
	   (rmail-add-label "decrypted")
	   (if (cdr decryption-result)
	       (rmail-add-label "verified")))
	  (t
	   (let ((tmp (generate-new-buffer "*Mailcrypt Viewing*")))
	     (copy-to-buffer tmp (point-min) (point-max))
	     (rmail-abort-edit)
	     (switch-to-buffer tmp t)
	     (view-mode oldbuf 'kill-buffer))))))

;;}}}
;;{{{ VM
;;;###autoload
(defun mc-vm-verify-signature ()
  "*Verify the signature in the current VM message"
  (interactive)
  (if (interactive-p)
      (vm-follow-summary-cursor))
  (vm-select-folder-buffer)
  (vm-check-for-killed-summary)
  (vm-error-if-folder-empty)
  (mc-verify-signature))

;;;###autoload
(defun mc-vm-decrypt-message ()
  "*Decrypt the contents of the current VM message"
  (interactive)
  (let ((oldbuf (current-buffer))
	decryption-result
	from-line
	condition-data)
    (if (interactive-p)
	(vm-follow-summary-cursor))
    (vm-select-folder-buffer)
    (vm-check-for-killed-summary)
    (vm-error-if-folder-read-only)
    (vm-error-if-folder-empty)

    ;; store away a valid "From " line for possible later use.
    (setq from-line (vm-leading-message-separator))
    (vm-edit-message)
    (cond ((not (condition-case condition-data
		    (car (mc-decrypt-message))
		  (error
		   (vm-edit-message-abort)
		   (error (message "Decryption failed: %s" 
				   (car (cdr condition-data)))))))
           (vm-edit-message-abort)
	   (error "Decryption failed."))
	  ((or mc-always-replace
               (y-or-n-p "Replace encrypted message with decrypted? "))
           (vm-edit-message-end))
          (t
           (let ((tmp (generate-new-buffer "*Mailcrypt Viewing*")))
             (copy-to-buffer tmp (point-min) (point-max))
             (vm-edit-message-abort)
             (switch-to-buffer tmp t)
	     (goto-char (point-min))
	     (insert from-line)	     
	     (not-modified)
	     (vm-mode t))))))

;;;###autoload
(defun mc-vm-snarf-keys ()
  "*Snarf public key from the contents of the current VM message"
  (interactive)
  (if (interactive-p)
      (vm-follow-summary-cursor))
  (vm-select-folder-buffer)
  (vm-check-for-killed-summary)
  (vm-error-if-folder-empty)
  (mc-snarf-keys))

;;}}}
;;{{{ GNUS

;;;###autoload
(defun mc-gnus-summary-verify-signature ()
  (interactive)
  (gnus-summary-select-article gnus-save-all-headers gnus-save-all-headers)
  (gnus-eval-in-buffer-window gnus-article-buffer
    (save-restriction (widen) (mc-verify-signature))))

;;;###autoload
(defun mc-gnus-summary-snarf-keys ()
  (interactive)
  (gnus-summary-select-article gnus-save-all-headers gnus-save-all-headers)
  (gnus-eval-in-buffer-window gnus-article-buffer
    (save-restriction (widen) (mc-snarf-keys))))

;;;###autoload
(defun mc-gnus-summary-decrypt-message ()
  (interactive)
  (gnus-summary-select-article gnus-save-all-headers gnus-save-all-headers)
  (gnus-eval-in-buffer-window gnus-article-buffer
    (save-restriction (widen) (mc-decrypt-message))))

;;}}}		
;;{{{ MH

;;;###autoload
(defun mc-mh-decrypt-message (decrypt-on-disk)
  "*Decrypt the contents of the current MH message in the show buffer.
With prefix arg, decrypt the message on disk as well."
  (interactive "P")
  (let* ((msg (mh-get-msg-num t))
	 (msg-filename (mh-msg-filename msg))
	 (show-buffer (get-buffer mh-show-buffer))
	 decrypt-okay)
    (setq decrypt-on-disk (or mc-always-replace decrypt-on-disk))
    (if decrypt-on-disk
	(progn
	  (save-excursion
	    (set-buffer (create-file-buffer msg-filename))
	    (insert-file-contents msg-filename t)
	    (if (setq decrypt-okay (car (mc-decrypt-message)))
		(save-buffer)
	      (message "Decryption failed.")
	      (set-buffer-modified-p nil))
	    (kill-buffer nil))
	  (if decrypt-okay
	      (if (and show-buffer
		       (equal msg-filename (buffer-file-name show-buffer)))
		  (save-excursion
		    (save-window-excursion
		      (mh-invalidate-show-buffer)))))
	  (mh-show msg))
      (mh-show msg)
      (save-excursion
	(set-buffer mh-show-buffer)
	(if (setq decrypt-okay (car (mc-decrypt-message)))
	    (progn
	      (goto-char (point-min))
	      (set-buffer-modified-p nil))
	  (message "Decryption failed.")))
      (if (not decrypt-okay)
	  (progn
	    (mh-invalidate-show-buffer)
	    (mh-show msg))))))

;;;###autoload
(defun mc-mh-verify-signature ()
  "*Verify the signature in the current MH message."
  (interactive)
  (let ((msg (mh-get-msg-num t)))
    (mh-show msg)
    (save-excursion
      (set-buffer mh-show-buffer)
      (mc-verify-signature))))

;;;###autoload
(defun mc-mh-snarf-keys ()
  (interactive)
  (mh-show (mh-get-msg-num t))
  (save-excursion
    (set-buffer mh-show-buffer)
    (mc-snarf-keys)))


;;}}}

;;}}}
;;{{{ Menubar stuff

(defun mc-create-read-menu-bar ()
  ;; Create a menu bar entry for reading modes.
  (let ((decrypt (nth 0 (cdr (assoc major-mode mc-modes-alist))))
	(verify (nth 1 (cdr (assoc major-mode mc-modes-alist))))
	(snarf (nth 2 (cdr (assoc major-mode mc-modes-alist)))))
    (if (not (and decrypt verify))
	(error "Decrypt and verify functions not defined for this major mode."))
    (if (not snarf)
	(setq snarf 'mc-snarf-keys))
    (if (string-match "XEmacs" (emacs-version))
	(let ((x (list "Mailcrypt"
		       (vector "Decrypt Message" decrypt t)
		       (vector "Verify Signature" verify t)
		       (vector "Snarf Public Key" snarf t))))
	  (set-buffer-menubar current-menubar)
	  (add-menu nil "Mailcrypt" (cdr x)))
      (local-set-key [menu-bar mailcrypt]
		     (cons "Mailcrypt" (make-sparse-keymap "Mailcrypt")))
      (local-set-key [menu-bar mailcrypt decrypt]
		     (cons "Decrypt Message" decrypt))
      (local-set-key [menu-bar mailcrypt verify]
		     (cons "Verify Signature" verify))
      (local-set-key [menu-bar mailcrypt snarf]
		     (cons "Snarf Public Key" snarf)))))

(defun mc-create-write-menu-bar ()
  ;; Create a menu bar entry for writing modes.
  (if (string-match "Lucid\\|XEmacs" (emacs-version))
      (let ((x (list "Mailcrypt"
		     (vector "Encrypt Message" 'mc-encrypt-message t)
		     (vector "Sign Message" 'mc-sign-message t)
		     (vector "Insert Public Key" 'mc-insert-public-key t))))
	(set-buffer-menubar current-menubar)
	(add-menu nil "Mailcrypt" (cdr x)))
    (local-set-key [menu-bar mailcrypt]
		   (cons "Mailcrypt" (make-sparse-keymap "Mailcrypt")))
    (local-set-key [menu-bar mailcrypt encrypt]
		   (cons "Encrypt Message" 'mc-encrypt-message))
    (local-set-key [menu-bar mailcrypt sign]
		   (cons "Sign Message" 'mc-sign-message))
    (local-set-key [menu-bar mailcrypt insert]
		   (cons "Insert Public Key" 'mc-insert-public-key))))

;;}}}
;;{{{ Define several aliases so that an apropos on `mailcrypt' will
;; return something.
(fset 'mailcrypt-encrypt-message 'mc-encrypt-message)
(fset 'mailcrypt-decrypt-message 'mc-decrypt-message)
(fset 'mailcrypt-sign-message 'mc-sign-message)
(fset 'mailcrypt-verify-signature 'mc-verify-signature)
(fset 'mailcrypt-insert-public-keys 'mc-insert-public-key)
(fset 'mailcrypt-snarf-keys 'mc-snarf-keys)
;;}}}
(provide 'mailcrypt)

