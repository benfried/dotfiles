;; mc-remail.el --- Remailer support for mailcrypt

;; Copyright (C) 1995 Patrick LoPresti <patl@lcs.mit.edu>

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
;;{{{ Load required packages

(require 'mail-utils)
(require 'mailcrypt)
(condition-case nil
    (require 'mailalias)
  (error nil))

;;}}}
;;{{{ Functions dealing with remailer structures

(defsubst mc-remailer-create (addr id prop pre-encr post-encr)
  "Create a remailer structure.

ADDR is the remailer's Email address, a string.

ID is the remailer's public key ID (a string) or nil if the same as
ADDR.

PROP is a list of properties, as strings.

PRE-ENCR is a list of pre-encryption functions.  Its elements will be
called with the remailer structure itself as argument.

POST-ENCR is similar, but for post-encryption functions."
(list 'remailer addr id prop pre-encr post-encr))

(defsubst mc-remailerp (remailer)
  "Test whether REMAILER is a valid remailer struct."
  (and (listp remailer) (eq 'remailer (car-safe remailer))))

(defsubst mc-remailer-address (remailer)
  "Return the Email address of REMAILER."
  (nth 1 remailer))

(defsubst mc-remailer-userid (remailer)
  "Return the userid with which to look up the public key for REMAILER."
  (or (nth 2 remailer)
      (car (cdr (mail-extract-address-components
		 (mc-remailer-address remailer))))))

(defsubst mc-remailer-properties (remailer)
  "Return the property list for REMAILER"
  (nth 3 remailer))

(defsubst mc-remailer-pre-encrypt-hooks (remailer)
  "Return the list of pre-encryption hooks for REMAILER."
  (nth 4 remailer))

(defsubst mc-remailer-post-encrypt-hooks (remailer)
  "Return the list of post-encryption hooks for REMAILER."
  (nth 5 remailer))

;;}}}
;;{{{ Functions for handling Levien format remailer lists

(defun mc-parse-levien-buffer ()
  ;; Parse a buffer in Levien format.
  (goto-char (point-min))
  (let (chains remailer remailer-name)
    (while
	(re-search-forward
	 "^\\$remailer{\"\\(.+\\)\"}[ \t]*=[ \t]*\"\\(.*\\)\";"
	 nil t)
      (let ((name (buffer-substring (match-beginning 1) (match-end 1)))
	    property-list address
	    (value-start (match-beginning 2))
	    (value-end (match-end 2)))
	(goto-char value-start)
	(while (re-search-forward "[^ \t]+" value-end 'no-error)
	  (setq property-list
		(append
		 property-list
		 (list (buffer-substring (match-beginning 0) (match-end 0))))))
	(setq address (car property-list)
	      property-list (cdr property-list)
	      remailer-name name)
	(if (not
	     (and (or (member "pgp" property-list)
		      (member "pgp." property-list))
		  (or (member "cpunk" property-list) ; hurm...
		      (member "eric" property-list)))) ; fixme?
	    (setq remailer nil)
	  (setq remailer
		(mc-remailer-create
		 address		; Address
		 (if (member "pgp." property-list)
		     name)		; User ID
		 property-list
		 '(mc-generic-pre-encrypt-function) ; Pre-encrypt hooks
		 '(mc-generic-post-encrypt-function) ; Post-encrypt hooks
		 ))))
      (if (not (null remailer))
	  (setq chains (cons (list remailer-name remailer) chains))))
    chains))

(defun mc-read-levien-file ()
  "Read the Levien format file specified in `mc-levien-file-name'.
Return an alist of length-1 chains, one for each remailer, named
after the remailer.  Only include remailers supporting PGP
encryption."
  (save-excursion
    (if (file-readable-p mc-levien-file-name)
	(prog2
	    (find-file-read-only mc-levien-file-name)
	    (mc-parse-levien-buffer)
	  (bury-buffer)))))

(defun mc-reread-levien-file ()
  "Read the Levien format file specified in `mc-levien-file-name'.

Place result in `mc-remailer-internal-chains'.

See the documentation for the variable `mc-levien-file-name' for
a description of Levien file format."
  (interactive)
  (setq mc-remailer-internal-chains (mc-read-levien-file)))

;;}}}
;;{{{ User variables

(defvar mc-response-block-included-headers
  '("From" "To" "Newsgroups")
  "List of header fields to include in response blocks.

These will be copied into the deepest layer of the response block to
help you identify it when it is used to Email you.")


(defvar mc-remailer-tag "(*REMAILER*)"
  "A string which marks an Email address as belonging to a remailer.")

(defvar mc-levien-file-name "~/.remailers"
  "The file containing a Levien format list of remailers.

The file is read by `mc-read-levien-file' and `mc-reread-levien-file'.

The file should include lines of the following form (other lines
are ignored):

$remailer{\"NAME\"} = \"<EMAIL ADDRESS> PROPERTIES\";

PROPERTIES is a space-separated set of strings.

This format is named after Raphael Levien, who maintains a list of
active remailers.  Do \"finger remailer-list@kiwi.cs.berkeley.edu\"
for the latest copy of his list.")

(defvar mc-remailer-user-chains nil
  "An alist of remailer chains defined by the user.

Format is

((NAME . REMAILER-LIST)
 (NAME . REMAILER-LIST)
 ...)

NAME must be a string.

REMAILER-LIST may be an arbitrary sequence, not just a list.  Its
elements may be any of the following:

1) A remailer structure created by `mc-remailer-create'.  This is
   the base case.

2) A string naming another remailer chain to be spliced in
   at this point.

3) An arbitrary Lisp form to be evaluated, which should
   return another REMAILER-LIST to be recursively processed and
   spliced in at this point.

The complete alist of chains is given by the union of the two lists
`mc-remailer-internal-chains' and `mc-remailer-user-chains'.")

(defvar mc-remailer-internal-chains (mc-read-levien-file)
  "List of \"internal\" remailer chains.

This variable is normally generated automatically from a human-readable
list of remailers; see, for example, the function `mc-reread-levien-file'.

To define your own chains, you probably want to use the variable
`mc-remailer-user-chains'.  See that variable's documentation for
format information.")

(defvar mc-remailer-user-response-block
  (function
   (lambda (addr lines block)
     (concat
      ";;;\n"
      (format
       "To reply to this message, take the following %d-line block, remove\n"
       lines)
      "leading \"- \" constructs (if any), and place it at the top of a\n"
      (format "message to %s :\n" addr)
      block)))
  "A function called to generate response block text.

Value should be a function taking three arguments (ADDR LINES BLOCK).
ADDR is the address to which the response should be sent.
LINES is the number of lines in the encrypted response block.
BLOCK is the response block itself.
Function should return a string to be inserted into the buffer
by mc-remailer-insert-response-block.")

(defvar mc-remailer-pseudonyms nil
  "*A list of your pseudonyms.

This is a list of strings.  Completion against it will be available
when you are prompted for your pseudonym.")

(defvar mc-remailer-preserved-headers
  '("References" "Followup-to" "In-reply-to")
  "*Header fields which are preserved as hashmark headers when rewriting.

This is a list of strings naming the preserved headers.  Note that
\"Subject\", \"Newsgroups\", and \"To\" are handled specially and
should not be included in this list.")

;;}}}
;;{{{ Canonicalization function

(defun mc-remailer-canonicalize-elmt (elmt chains-alist)
  (cond
   ((mc-remailerp elmt) (list elmt))
   ((stringp elmt)
    (mc-remailer-canonicalize-chain (cdr (assoc elmt chains-alist))
				    chains-alist))
   (t (mc-remailer-canonicalize-chain (eval elmt) chains-alist))))

(defun mc-remailer-canonicalize-chain (chain chains-alist)
  ;; Canonicalize a remailer chain with respect to CHAINS-ALIST.
  ;; That is, use CHAINS-ALIST to resolve strings.
  ;; Here is where we implement the functionality described in
  ;; the documentation for the variable `mc-remailer-user-chains'.
  (cond
   ((null chain) nil)
   ;; Handle case where chain is actually a string or a single
   ;; remailer.
   ((or (stringp chain) (mc-remailerp chain))
    (mc-remailer-canonicalize-elmt chain chains-alist))
   (t
    (let ((first (elt chain 0))
	  (rest (cdr (append chain nil))))
      (append
       (mc-remailer-canonicalize-elmt first chains-alist)
       (mc-remailer-canonicalize-chain rest chains-alist))))))

;;}}}
;;{{{ Pre-encryption and post-encryption hook defaults

(defun mc-generic-post-encrypt-function (remailer)
  (let ((main-header (mc-find-main-header))
	(colon-header (mc-find-colon-header t)))
    (mc-replace-field "Encrypted" "PGP" colon-header)
    (mc-replace-field
     "To"
     (concat (mc-remailer-address remailer) " " mc-remailer-tag)
     main-header)))

(defun mc-generic-pre-encrypt-function (remailer)
  (let ((addr (mc-remailer-address remailer))
	(props (mc-remailer-properties remailer))
	(main-header (mc-find-main-header))
	(colon-header (mc-find-colon-header t))
	to to-field header hash-header)
    (mapcar
     (function
      (lambda (s)
	(and (mc-find-field s main-header)
	     (null hash-header)
	     (setq hash-header (mc-find-hash-header t)))
	(mc-migrate-field s main-header hash-header)))
     mc-remailer-preserved-headers)
    (if (and (mc-find-hash-header) (not (member "hash" props)))
	(error "Remailer %s does not support hashmarks" addr))
    (if (mc-find-field "Newsgroups" main-header)
	(cond ((not (member "post" props))
	       (error "Remailer %s does not support posting" addr))
	      ((not (member "hash" props))
	       (error "Remailer %s does not support hashmarks" addr))
	      (t (mc-rewrite-news-to-mail remailer)))
      (and (featurep 'mailalias)
	   mail-aliases
	   (expand-mail-aliases (car main-header) (cdr main-header)))
      (narrow-to-region (car main-header) (cdr main-header))
      (setq to (or (mail-fetch-field "To" nil t) ""))
      (widen)
      (if (string-match "," to)
	  (error "Remailer %s does not support multiple recipients." addr))
      (setq to-field
	    (if (mc-find-field "From" colon-header)
		"Send-To"
	      (cond
	       ((member "eric" props) "Anon-Send-To")
	       (t "Request-Remailing-To"))))
      (mc-replace-field to-field to colon-header)
      (mc-nuke-field "Reply-to" main-header))))
	
;;}}}
;;{{{ Auxiliaries for mail header munging

(defun mc-find-field (field &optional bounds)
  ;; Find a header field matching regexp FIELD in the current
  ;; buffer; return as a pair, (FIELD-START . FIELD-END).
  ;; Optional argument BOUNDS is a pair of integers or markers
  ;; which bound the search.
  ;; Default is to search whole visible region.
  ;; The "field" goes from immediately after the colon to
  ;; immediately after the final newline.
  (let (field-start
	field-end
	(case-fold-search t)
	(search-start (or (car-safe bounds) (point-min)))
	(search-end (or (cdr-safe bounds) (point-max))))
    (save-excursion
      (goto-char search-start)
      (if (re-search-forward (concat "^" (regexp-quote field) ":")
			     search-end t)
	  (progn
	    (setq field-start (point))
	    (if (re-search-forward "^[^ \t]" search-end 'move)
		(forward-char -1))
	    (setq field-end (point))
	    (cons field-start field-end))))))

(defun mc-nuke-field (field &optional bounds)
  ;; Delete all fields matching regexp FIELD from header,
  ;; bounded by BOUNDS.  Default is entire visible region of buffer.
  (save-excursion
    (let (region
	  (start (or (car-safe bounds) (point-min)))
	  (end (or (cdr-safe bounds) (point-max))))
      (setq bounds (cons (copy-marker start) (copy-marker end)))
      (while (setq region (mc-find-field field bounds))
	(goto-char (car region))
	(beginning-of-line)
	(delete-region (point) (cdr region)))
      (set-marker (car bounds) nil)
      (set-marker (cdr bounds) nil))))

(defun mc-find-main-header (&optional ignored)
  ;; Find the main header of the mail message; return as a pair of
  ;; markers (START . END).
  (save-excursion
    (goto-char (point-min))
    (re-search-forward
     (concat "^" (regexp-quote mail-header-separator) "\n"))
    (forward-line -1)
    (cons (copy-marker (point-min)) (copy-marker (point)))))
		
(defun mc-find-colon-header (&optional insert)
  ;; Find the header with a "::" immediately after the
  ;; mail-header-separator.  Return region enclosing header.  Optional
  ;; arg INSERT means insert the header if it does not exist already.
  (save-excursion
    (goto-char (point-min))
    (re-search-forward
     (concat "^" (regexp-quote mail-header-separator) "\n"))
    (if (or (and (looking-at "::\n") (forward-line 1))
	    (and insert
		 (progn
		   (insert-before-markers "::\n\n")
		   (forward-line -1))))
	(let ((start (point)))
	  (re-search-forward "^$" nil 'move)
	  (cons (copy-marker start) (copy-marker (point)))))))

(defun mc-find-hash-header (&optional insert)
  (save-excursion
    (goto-char (point-min))
    (re-search-forward
     (concat "^" (regexp-quote mail-header-separator) "\n"))
    (if (or (and (looking-at "##\n") (forward-line 1))
	    (and (looking-at "::\n")
		 (re-search-forward "^\n" nil 'move)
		 (looking-at "##\n")
		 (forward-line 1))
	    (and insert
		 (progn
		   (insert-before-markers "##\n\n")
		   (forward-line -1))))
	(let ((start (point)))
	  (re-search-forward "^$" nil 'move)
	  (cons (copy-marker start) (copy-marker (point)))))))

(defun mc-replace-field (field replacement header)
  (save-excursion
    (let ((region (mc-find-field field header)))
      (if (not (string-match "^[ \t]" replacement))
	  (setq replacement (concat " " replacement)))
      (if (not (string-match "\n$" replacement))
	  (setq replacement (concat replacement "\n")))
      (if (not region)
	  (progn
	    (goto-char (car header))
	    (insert field ":" replacement))
	(mc-nuke-field field (cons (cdr region) (cdr header)))
	(delete-region (car region) (cdr region))
	(goto-char (car region))
	(insert replacement)))))


(defsubst mc-replace-main-field (field replacement)
  (mc-replace-field field replacement (mc-find-main-header t)))

(defsubst mc-replace-hash-field (field replacement)
  (mc-replace-field field replacement (mc-find-hash-header t)))

(defsubst mc-replace-colon-field (field replacement)
  (mc-replace-field field replacement (mc-find-colon-header t)))

(defun mc-recipient-is-remailerp ()
  (let ((region (mc-find-field "To" (mc-find-main-header))))
    (if region
	(string-match (regexp-quote mc-remailer-tag)
		      (buffer-substring (car region) (cdr region))))))

(defun mc-migrate-field (field from-header to-header)
  ;; Move the field FIELD from one header to another.
  ;; FROM-HEADER and TO-HEADER are pairs defining the bounds
  ;; of the respective headers.
  (let ((region (mc-find-field field from-header)))
    (if region
	(progn
	  (mc-replace-field field
			    (buffer-substring (car region) (cdr region))
			    to-header)
	  (mc-nuke-field field from-header)))))

;;}}}
;;{{{ High level message rewriting

(defun mc-rewrite-news-to-mail (remailer)
  (let (region
	(main-header (mc-find-main-header)))
    (setq region (mc-find-field "Newsgroups" main-header))
    (mc-replace-colon-field
     "Post-To" (buffer-substring (car region) (cdr region)))
    (mail-mode)))

(defun mc-rewrite-for-remailer (remailer &optional pause)
  ;; Rewrite the current mail buffer for a single remailer.  This
  ;; includes running the pre-encryption hooks, modifying the To:
  ;; field, encrypting with the remailer's public key, and running the
  ;; post-encryption hooks.
  (let ((addr (mc-remailer-address remailer))
	(main-header (mc-find-main-header)))
    (setq body-start (point))
    ;; If recipient is already a remailer, make sure the "::" and "##"
    ;; headers get to it
    (if (mc-recipient-is-remailerp)
	(progn
	  (goto-char (cdr main-header))
	  (forward-line 1)
	  (insert "::\n\n")))
    (mapcar
     (function (lambda (hook) (funcall hook remailer)))
     (mc-remailer-pre-encrypt-hooks remailer))
    (mc-migrate-field "Subject" main-header (mc-find-colon-header t))
    (mc-nuke-field "CC" main-header)
    (if pause
	(let ((cursor-in-echo-area t))
	  (message "SPC to encrypt for %s : " addr)
	  (read-char-exclusive)))
    (setq main-header (mc-find-main-header))
    (goto-char (cdr main-header))
    (forward-line 1)
    (if (let ((mc-pgp-always-sign 'never)
	      (mc-encrypt-to-me nil))
	  (mc-encrypt-message (mc-remailer-userid remailer) nil (point)))
	(mapcar
	 (function (lambda (hook) (funcall hook remailer)))
	 (mc-remailer-post-encrypt-hooks remailer))
      (error "Unable to encrypt message to %s"
	     (mc-remailer-userid remailer)))))

(defun mc-rewrite-for-chain (chain &optional pause)
  ;; Rewrite the current buffer for a chain of remailers.
  ;; CHAIN must be in canonical form.
  (if (null chain)
      nil
    (mc-rewrite-for-chain (cdr chain) pause)
    (mc-rewrite-for-remailer (car chain) pause)))

(defun mc-unparse-chain (chain)
  ;; Unparse CHAIN into a string suitable for printing.
  (if (null chain)
      nil
    (concat (mc-remailer-address (car chain)) "\n"
	    (mc-unparse-chain (cdr chain)))))

(defun mc-disallow-field (field &optional header)
  (let (region)
    (if (null header)
	(setq header (mc-find-main-header)))
    (if (setq region (mc-find-field field header))
	(progn
	  (goto-char (car region))
	  (beginning-of-line)
	  (error "Cannot use a %s field." field)))))

(defun mc-remailer-encrypt-for-chain (&optional pause)
  "Encrypt message for a remailer chain, prompting for chain to use.

With \\[universal-argument], pause before each encryption."
  (interactive "P")
  (let ((chains (mc-remailer-make-chains-alist))
	(buffer (get-buffer-create mc-buffer-name))
	chain-name chain temp)
    (mc-disallow-field "CC")
    (mc-disallow-field "FCC")
    (mc-disallow-field "BCC")
    (setq chain-name
	  (completing-read
	   "Choose a remailer or chain: " chains nil 'strict-match))
    (setq chain
	  (mc-remailer-canonicalize-chain
	   (cdr (assoc chain-name chains))
	   chains))
    (mc-rewrite-for-chain chain pause)
    (if chain
	(save-excursion
	  (set-buffer buffer)
	  (erase-buffer)
	  (insert "Rewritten for chain `" chain-name "':\n\n"
		  (mc-unparse-chain chain))
	  (message "Done.  See %s buffer for details." mc-buffer-name)))))

;;}}}
;;{{{ Response block generation

(defun mc-remailer-insert-response-block (&optional arg)
  "Insert response block at point, prompting for chain to use.

With \\[universal-argument], enter a recursive edit of the innermost
layer of the block before encrypting it."
  (interactive "p")
  (let (buf main-header to-field addr block lines)
    (save-excursion
      (setq buf
	    (mc-remailer-make-response-block (if (> arg 1) t)))
      (set-buffer buf)
      (setq main-header (mc-find-main-header))
      (setq to-field (mc-find-field "To" main-header))
      (narrow-to-region (car to-field) (cdr to-field))
      (setq
       addr
       (concat "<" (nth 1 (mail-extract-address-components buf)) ">"))
      (widen)
      (goto-char (cdr main-header))
      (forward-line 1)
      (setq block (buffer-substring (point) (point-max))
	    lines (count-lines (point) (point-max)))
      (kill-buffer buf))
    (let ((opoint (point)))
      (insert (funcall mc-remailer-user-response-block
		       addr lines block))
      (goto-char opoint))
    (mc-nuke-field "Reply-to" (mc-find-main-header))
    (mc-replace-hash-field "Reply-to" addr)))

(defun mc-remailer-make-response-block (&optional recurse)
  ;; Return a buffer which contains a response block
  ;; for the user, and a To: header for the remailer to use.
  (let ((buf (generate-new-buffer " *Remailer Response Block*"))
	(original-buf (current-buffer))
	all-headers region)
    (setq all-headers (mc-find-main-header))
    (setcdr all-headers
	    (max
	     (cdr all-headers)
	     (or (cdr-safe (mc-find-colon-header)) 0)
	     (or (cdr-safe (mc-find-hash-header)) 0)))
    (save-excursion
      (set-buffer buf)
      (insert "To: " (mc-user-mail-address) "\n"
	      mail-header-separator "\n")
      (insert ";; Response block created " (current-time-string) "\n")
      (mapcar
       (function
	(lambda (str)
	  (set-buffer original-buf)
	  (if (setq region (mc-find-field str all-headers))
	      (progn
		(goto-char (car region))
		(beginning-of-line)
		(setcar region (point))
		(set-buffer buf)
		(insert "; ")
		(insert-buffer-substring
		 original-buf (car region) (cdr region))))))
       mc-response-block-included-headers)
      (if recurse
	  (progn
	    (switch-to-buffer buf)
	    (message "Editing response block ; %s when done."
		     (substitute-command-keys "\\[exit-recursive-edit]"))
	    (recursive-edit)))
      (set-buffer buf)
      (mc-remailer-encrypt-for-chain)
      (switch-to-buffer original-buf))
    buf))

;;}}}
;;{{{ Misc. random

(defun mc-user-mail-address ()
  "Figure out the user's Email address as best we can."
  (cond ((not (null mail-default-reply-to))
	 mail-default-reply-to)
	((boundp 'user-mail-address) user-mail-address)
	(t (concat (user-login-name) "@" (system-name)))))

(defsubst mc-remailer-make-chains-alist ()
  (append mc-remailer-internal-chains mc-remailer-user-chains))

(defun mc-remailer-insert-pseudonym ()
  "Insert pseudonym as a From field in the hash-mark header.

See the documentation for the variable `mc-remailer-pseudonyms' for
more information."
  (interactive)
  (let ((pseudonym
	 (cond ((null mc-remailer-pseudonyms)
		(read-from-minibuffer "Pseudonym: "))
	       (t
		(completing-read "Pseudonym: "
			    (mapcar 'list mc-remailer-pseudonyms))))))
    (if (not (string-match "\\S +@\\S +" pseudonym))
	(setq pseudonym (concat pseudonym " <x@x.x>")))
    (mc-replace-colon-field "From" pseudonym)))

;;}}}
