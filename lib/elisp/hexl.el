;; -*-Lisp-*-
;; hexl-mode -- Edit a file in a hex dump format.
;; Copyright (C) 1989 Free Software Foundation, Inc.

;; This file is part of GNU Emacs.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY.  No author or distributor
;; accepts responsibility to anyone for the consequences of using it
;; or for whether it serves any particular purpose or works at all,
;; unless he says so in writing.  Refer to the GNU Emacs General Public
;; License for full details.

;; Everyone is granted permission to copy, modify and redistribute
;; GNU Emacs, but only under the conditions described in the
;; GNU Emacs General Public License.   A copy of this license is
;; supposed to have been given to you along with GNU Emacs so you
;; can know your rights and responsibilities.  It should be in a
;; file named COPYING.  Among other things, the copyright notice
;; and this notice must be preserved on all copies.

;;
;; By: Keith Gabryelski (ag@wheaties.ai.mit.edu)
;;
;; This may be useful in your .emacs:
;;
;;	(autoload 'hexl-find-file "hexl"
;;	  "Edit file FILENAME in hexl-mode." t)
;;	
;;	(define-key global-map "\C-c\C-h" 'hexl-find-file)
;;
;; This code is so much faster when byte compiled.  You can see the
;; difference.  You can feel the difference.
;;

;; vars here

(defvar hexl-current-address 0
  "Current offset into hexl buffer.

This variable holds the hexl address that `point' is at.  All hexl
commands that access `point' actually use this variable to do their
work.")

(defvar hexl-max-address 0
  "Maximum offset into hexl buffer.")

(defvar hexl-mark nil
  "Current mark in hexl buffer.")

(defvar hexl-mode-map nil)

;; routines

(defun hexl-mode ()
  "A major mode for editting binary files in hex dump format.

This function automatically converts the buffer to the hexl format
using the function `hexlify-buffer'.  Each line in the buffer has an
`address' (in hexadecimal) representing the offset into the file that
the characters on this line are at, 16 characters from the file in
displayed as their ascii values in hexadecimal grouped every 16 bits,
and (the same) 16 characters displayed as ascii characters.  If any of
the characters (displayed as ascii characters) are unprintable
(control or meta characters) they will be replaced as periods.

A sample format:

  HEX ADDR: 0001 0203 0405 0607 0809 0a0b 0c0d 0e0f     ASCII-TEXT
  --------  ---- ---- ---- ---- ---- ---- ---- ----  ----------------
  00000000: 5468 6973 2069 7320 6865 786c 206d 6f64  This is hexl mod
  00000010: 652e 2020 4561 6368 206c 696e 6520 7265  e.  Each line re
  00000020: 7072 6573 656e 7420 3136 2063 6861 7261  present 16 chara
  00000030: 6374 6572 7320 6173 2068 6578 6164 6563  cters as hexadec
  00000040: 696d 616c 0a61 7363 6969 2061 6e64 2070  imal.ascii and p
  00000050: 7269 6e74 6162 6c65 2061 7363 6969 2063  rintable ascii c
  00000060: 6861 7261 6374 6572 732e 2020 416e 7920  haracters.  Any 
  00000070: 636f 6e74 726f 6c20 6368 6172 6163 7465  control characte
  00000080: 7273 2061 7265 0a64 6973 706c 6179 6564  rs are.displayed
  00000090: 2061 7320 7065 7269 6f64 7320 696e 2074   as periods in t
  000000a0: 6865 2070 7269 6e74 6162 6c65 2063 6861  he printable cha
  000000b0: 7261 6374 6572 2063 6f6c 756d 6e73 2e0a  racter columns..

The mode line displays the address the cursor is on and the number of
characters that are in the buffer; Both numbers are in hex.

Movement is as simple as movement in a normal emacs text buffer.  Most
cursor movement bindings are the same (ie. Use C-b, C-f, C-n, and C-p
to move the cursor left, right, down, and up).

Advanced cursor movement commands (ala C-a, C-e, C-<, and C->) are
also supported.

There are several ways to change text in hexl mode:

    char	ASCII characters (between space (0x20) and
	        tilde (0x7E) are bound to self-insert so you can
		simply type the character and it will insert itself
		(actually overstrike) into the buffer.

    C-q		Followed by another keystroke allows you to insert
    		the key even if it isn't bound to self-insert.
		An octal number can be supplied in place of another
		key to insert the octal number's ASCII representation.

    M-C-x	Will insert a given hexadecimal value (if it is between
		0x0 and 0xFF) into the buffer.

    M-C-o	Will insert a given octal value (if it is between
		0 and 0377) into the buffer.

    M-C-d	Will insert a given decimal value (if it is between
		0 and 255) into the buffer.

C-xC-s will save the buffer in is binary format.

Note: C-xC-w with write the file out as a HEXL FORMAT.

You can use:

    M-x hexl-find-file

to visit a file in hexl-mode.

    M-x describe-bindings

for advanced commands.
"
  (interactive)
  (let ((modified (buffer-modified-p))
	(read-only buffer-read-only))
    (kill-all-local-variables)
    (setq major-mode 'hexl-mode)
    (setq mode-name "Hexl")
    (if read-only
	(toggle-read-only))
    (setq hexl-max-address (1- (buffer-size)))
    (hexlify-buffer)
    (set-buffer-modified-p modified)
    (if read-only
	(toggle-read-only))
    (hexl-goto-address 0)
    (use-local-map hexl-mode-map)))
  
(defun hexl-save-buffer ()
  "Save a hexl format buffer as binary in visited file if modified.."
  (interactive)
  (set-buffer-modified-p (if (buffer-modified-p)
			     (save-excursion
			       (let ((buf (generate-new-buffer " hexl"))
				     (name (buffer-name))
				     (file-name (buffer-file-name))
				     (start (point-min))
				     (end (point-max))
				     modified)
				 (set-buffer buf)
				 (insert-buffer-substring name start end)
				 (set-buffer name)
				 (dehexlify-buffer)
				 (save-buffer)
				 (setq modified (buffer-modified-p))
				 (delete-region (point-min) (point-max))
				 (insert-buffer-substring buf start end)
				 (kill-buffer buf)
				 modified))
			   (message "(No changes need to be saved)")
			   nil))
  (hexl-goto-address hexl-current-address))

;; Bug here.  If you hexl-find-file a file that is currently being
;; visited in hexl mode, it will go into meta-hexl-mode.  Yuk!

(defun hexl-find-file (filename)
  "Edit file FILENAME in hexl-mode.

Switch to a buffer cisiting file FILENAME, creating one in no exists."
  (interactive "fFilename: ")
  (find-file filename)
  (hexl-mode))

(defun hexl-goto-address (address)
  "Goto hexl-mode (decimal) address ADDRESS.

Signal error if ADDRESS out of range."
  (interactive "nAddress: ")
  (if (or (< address 0) (> address hexl-max-address))
      (progn
	  (setq address hexl-current-address)
	  (error "Out of hexl region.")))
  (goto-line (+ (/ address 16) 1))
  (forward-char (+ 10 (* (% address 16) 2) (/ (% address 16) 2)))
  (setq hexl-current-address address)
  (hexl-reset-mode-line))

(defun hexl-goto-hex-address (hex-address)
  "Goto hexl-mode address (hex string) HEX-ADDRESS.

Signal error if HEX-ADDRESS is out of range."
  (interactive "sHex Address: ")
  (hexl-goto-address (hex-string-to-integer hex-address)))

(defun hex-string-to-integer (hex-string)
  "Return decimal integer for HEX-STRING."
  (interactive "sHex number: ")
  (let ((hex-num 0))
    (while (not (equal hex-string ""))
      (setq hex-num (+ (* hex-num 16)
		       (hex-char-to-integer (string-to-char hex-string))))
      (setq hex-string (substring hex-string 1)))
    hex-num))

(defun octal-string-to-integer (octal-string)
  "Return decimal integer for OCTAL-STRING."
  (interactive "sOctal number: ")
  (let ((oct-num 0))
    (while (not (equal octal-string ""))
      (setq oct-num (+ (* oct-num 8)
		       (oct-char-to-integer (string-to-char octal-string))))
      (setq octal-string (substring octal-string 1)))
    oct-num))

;; move point functions

(defun hexl-backward-char (arg)
  "Move to left ARG bytes (right if ARG negative) in hexl-mode."
  (interactive "p")
  (hexl-goto-address (- hexl-current-address arg)))

(defun hexl-forward-char (arg)
  "Move right ARG bytes (left if ARG negative) in hexl-mode."
  (interactive "p")
  (hexl-goto-address (+ hexl-current-address arg)))

(defun hexl-backward-short (arg)
  "Move to left ARG shorts (right if ARG negative) in hexl-mode."
  (interactive "p")
  (hexl-goto-address (let ((address hexl-current-address))
		       (if (< arg 0)
			   (progn
			     (setq arg (- arg))
			     (while (> arg 0)
			       (if (not (equal address (logior address 3)))
				   (if (> address hexl-max-address)
				       (progn
					 (message "End of buffer.")
					 (setq address hexl-max-address))
				     (setq address (logior address 3)))
				 (if (> address hexl-max-address)
				     (progn
				       (message "End of buffer.")
				       (setq address hexl-max-address))
				   (setq address (+ address 4))))
			       (setq arg (1- arg)))
			     (if (> address hexl-max-address)
				 (progn
				   (message "End of buffer.")
				   (setq address hexl-max-address))
			       (setq address (logior address 3))))
			 (while (> arg 0)
			   (if (not (equal address (logand address -4)))
			       (setq address (logand address -4))
			     (if (not (equal address 0))
				 (setq address (- address 4))
			       (message "Beginning of buffer.")))
			   (setq arg (1- arg))))
		       address)))

(defun hexl-forward-short (arg)
  "Move right ARG shorts (left if ARG negative) in hexl-mode."
  (interactive "p")
  (hexl-backward-short (- arg)))

(defun hexl-backward-word (arg)
  "Move to left ARG words (right if ARG negative) in hexl-mode."
  (interactive "p")
  (hexl-goto-address (let ((address hexl-current-address))
		       (if (< arg 0)
			   (progn
			     (setq arg (- arg))
			     (while (> arg 0)
			       (if (not (equal address (logior address 7)))
				   (if (> address hexl-max-address)
				       (progn
					 (message "End of buffer.")
					 (setq address hexl-max-address))
				     (setq address (logior address 7)))
				 (if (> address hexl-max-address)
				     (progn
				       (message "End of buffer.")
				       (setq address hexl-max-address))
				   (setq address (+ address 8))))
			       (setq arg (1- arg)))
			     (if (> address hexl-max-address)
				 (progn
				   (message "End of buffer.")
				   (setq address hexl-max-address))
			       (setq address (logior address 7))))
			 (while (> arg 0)
			   (if (not (equal address (logand address -8)))
			       (setq address (logand address -8))
			     (if (not (equal address 0))
				 (setq address (- address 8))
			       (message "Beginning of buffer.")))
			   (setq arg (1- arg))))
		       address)))

(defun hexl-forward-word (arg)
  "Move right ARG words (left if ARG negative) in hexl-mode."
  (interactive "p")
  (hexl-backward-word (- arg)))

(defun hexl-previous-line (arg)
  "Move vertically up ARG lines [16 bytes] (down if ARG negative) in
hexl-mode.

If there is byte at the target address move to the last byte in that
line."
  (interactive "p")
  (hexl-next-line (- arg)))

(defun hexl-next-line (arg)
  "Move vertically down ARG lines [16 bytes] (up if ARG negative) in
hexl-mode.

If there is no byte at the target address move to the last byte in that
line."
  (interactive "p")
  (hexl-goto-address (let ((address (+ hexl-current-address (* arg 16)) t))
		       (if (and (< arg 0) (< address 0))
				(progn (message "Out of hexl region.")
				       (setq address
					     (% hexl-current-address 16)))
			 (if (and (> address hexl-max-address)
				  (< (% hexl-max-address 16) (% address 16)))
			     (setq address hexl-max-address)
			   (if (> address hexl-max-address)
			       (progn (message "Out of hexl region.")
				      (setq
				       address
				       (+ (logand hexl-max-address -16)
					  (% hexl-current-address 16)))))))
		       address)))

(defun hexl-beginning-of-buffer (arg)
  "Move to the beginning of the hexl buffer; leave hexl-mark at previous
posistion.

With arg N, put point N bytes of the way from the true beginning."
  (interactive "p")
  (hexl-goto-address (+ 0 (1- arg))))

(defun hexl-end-of-buffer (arg)
  "Goto hexl-max-address - ARG."
  (interactive "p")
  (hexl-goto-address (- hexl-max-address (1- arg))))

(defun hexl-beginning-of-line ()
  "Goto beginning of line in hexl mode."
  (interactive)
  (hexl-goto-address (logand hexl-current-address -16)))

(defun hexl-end-of-line ()
  "Goto end of line in hexl mode."
  (interactive)
  (hexl-goto-address (let ((address (logior hexl-current-address 15)))
		       (if (> address hexl-max-address)
			   (setq address hexl-max-address))
		       address)))

(defun hexl-reset-mode-line ()
  "Set up mode line."
  (setq mode-line-process
	(format " %02x/%02x" hexl-current-address hexl-max-address)))

(defun hexl-scroll-down (arg)
  "Scroll hexl buffer window upward (moving hexl-current-address) ARG lines;
or near full window if no ARG."
  (interactive "P")
  (if (not arg)
      (setq arg (1- (window-height))))
  (hexl-scroll-up (- arg)))

(defun hexl-scroll-up (arg)
  "Scroll hexl buffer window upward (moving hexl-current-address) ARG lines;
or near full window if no ARG."
  (interactive "P")
  (if (not arg)
      (setq arg (1- (window-height))))
  (let ((movement (* arg 16)))
    (if (or (> (+ hexl-current-address movement) hexl-max-address)
	    (< (+ hexl-current-address movement) 0))
	(message "Out of hexl region.")
      (hexl-goto-address (+ hexl-current-address movement))
      (recenter 0))))

(defun hexl-beginning-of-1k-page ()
  "Goto to beginning of 1k boundry."
  (interactive)
  (hexl-goto-address (logand hexl-current-address -1024)))

(defun hexl-end-of-1k-page ()
  "Goto to end of 1k boundry."
  (interactive)
  (hexl-goto-address (let ((address (logior hexl-current-address 1023)))
		       (if (> address hexl-max-address)
			   (setq address hexl-max-address))
		       address)))

(defun hexl-beginning-of-512b-page ()
  "Goto to beginning of 512 byte boundry."
  (interactive)
  (hexl-goto-address (logand hexl-current-address -512)))

(defun hexl-end-of-512b-page ()
  "Goto to end of 512 byte boundry."
  (interactive)
  (hexl-goto-address (let ((address (logior hexl-current-address 511)))
		       (if (> address hexl-max-address)
			   (setq address hexl-max-address))
		       address)))

(defun hexl-quoted-insert (arg)
  "Read next input character and insert it.
Useful for inserting control characters.
You may also type up to 3 octal digits, to insert a character with that code"
  (interactive "p")
  (hexl-insert-char (read-quoted-char) arg))

;00000000: 0011 2233 4455 6677 8899 aabb ccdd eeff  0123456789ABCDEF

(defun hexlify-buffer ()
  "Convert a binary buffer to hexl format"
  (interactive)
  (goto-char (point-min))
  (let ((address 0))
    (while (not (eobp))
      (insert (format "%08x: " address))
      (setq ascii-line "")
      (let ((i (min (- (point-max) (point)) 16)))
	(setq characters-on-this-line i)
	(setq increment (- 16 i))
	(setq number-of-spaces
	      (+ (* increment 2) (/ increment 2) (% increment 2) 1))
	(while (> i 0)
	  (setq ch (char-after (point)))
	  (delete-char 1)
	  (setq ascii-line (concat ascii-line (printable-character ch)))
	  (insert (format "%02x" ch))
	  (if (eq (% (- characters-on-this-line i) 2) 1)
	      (insert " "))
	  (setq i (1- i))))
      (insert-char 32 number-of-spaces)
      (insert ascii-line "\n")
      (setq address (+ address 16)))))

(defun dehexlify-buffer ()
  "Convert a hexl format buffer to binary."
  (interactive)
  (goto-char (point-min))
  (while (not (eobp))
    (let ((beg (point)))
      (search-forward ": " (point-max) 'move)
      (delete-region beg (point)))
    (let ((i 16))
      (while (> i 0)
	(setq lh (char-after (point)))
	(delete-char 1)
	(setq rh (char-after (point)))
	(delete-char 1)
	(if (eq lh 32)
	    (let ((beg (point)))
	      (goto-char (point-max))
	      (delete-region beg (point))
	      (setq i 1))
	  (insert-char (htoi lh rh) 1)
	  (if (eq (% i 2) 1)
	      (delete-char 1)))
	(setq i (1- i))))
    (let ((beg (point)))
      (search-forward "\n" (point-max) 'move)
      (delete-region beg (point)))))

(defun hexl-char-after-point ()
  "Return char for ascii hex digits at point."
  (setq lh (char-after (point)))
  (setq rh (char-after (1+ (point))))
  (htoi lh rh))

(defun htoi (lh rh)
  "Hex (char) LH (char) RH to integer."
    (+ (* (hex-char-to-integer lh) 16)
       (hex-char-to-integer rh)))

(defun hex-char-to-integer (character)
  "Take a char and return its value as if it was a hex digit."
  (if (and (>= character ?0) (<= character ?9))
      (- character ?0)
    (let ((ch (logior character 32)))
      (if (and (>= ch ?a) (<= ch ?f))
	  (- ch (- ?a 10))
	(error (format "Invalid hex digit `%c'." ch))))))

(defun oct-char-to-integer (character)
  "Take a char and return its value as if it was a octal digit."
  (if (and (>= character ?0) (<= character ?7))
      (- character ?0)
    (error (format "Invalid octal digit `%c'." character))))

(defun printable-character (ch)
  "Return a displayable string for character CH."
  (format "%c" (if (< ch 32)
		   46
		 (if (>= ch 127)
		     46
		   ch))))

(defun hexl-self-insert-command (arg)
  "Insert this character."
  (interactive "p")
  (hexl-insert-char last-command-char arg))

(defun hexl-insert-char (ch num)
  "Insert a character in a hexl buffer."
  (while (> num 0)
    (delete-char 2)
    (insert (format "%02x" ch))
    (goto-line (1+ (/ hexl-current-address 16)))
    (forward-char (+ 51 (% hexl-current-address 16)))
    (delete-char 1)
    (insert (printable-character ch))
    (hexl-forward-char 1)
    (setq num (1- num))))

;; markings and such

(defun hexl-exchange-point-and-mark ()
  "Move to mark leaving new mark at current point."
  (interactive)
  (let ((address hexl-current-address))
    (hexl-goto-address hexl-mark)
    (setq hexl-mark address)))

(defun hexl-set-mark-command ()
  "Set mark in hexl buffer at point."
  (interactive)
  (setq hexl-mark hexl-current-address)
  (message "Mark set."))

(defun hexl-mark-short ()
  "Set mark in hexl buffer before short."
  (interactive)
  (setq hexl-mark (logand hexl-current-address -4))
  (message "Mark set."))

(defun hexl-mark-word ()
  "set mark in hexl buffer at point."
  (interactive)
  (setq hexl-mark (longand hexl-current-address -8))
  (message "Mark set."))

;; transpose commands

(defun hexl-transpose-bytes ()
  "Transpose bytes around point."
  (interactive)
  (if (eq hexl-current-address 0)
      (error "Beginning of buffer.")
    (let ((ch1 (hexl-char-after-point)))
      (hexl-backward-char 1)
      (setq ch2 (hexl-char-after-point))
      (hexl-insert-char ch1 1)
      (hexl-insert-char ch2 1))))

(defun hexl-transpose-shorts ()
  "Transpose shorts around point."
  (interactive)
  (let ((address (logand hexl-current-address -4))
	ch1 ch2 ch3 ch4 ch5 ch6 ch7 ch8)
    (if (eq address 0)
	(error "Beginning of buffer.")
      (hexl-goto-address address)
      (setq ch1 (hexl-char-after-point))
      (hexl-forward-char 1)
      (setq ch2 (hexl-char-after-point))
      (hexl-forward-char 1)
      (setq ch3 (hexl-char-after-point))
      (hexl-forward-char 1)
      (setq ch4 (hexl-char-after-point))
      (hexl-backward-char 7)
      (setq ch5 (hexl-char-after-point))
      (hexl-insert-char ch1 1)
      (setq ch6 (hexl-char-after-point))
      (hexl-insert-char ch2 1)
      (setq ch7 (hexl-char-after-point))
      (hexl-insert-char ch3 1)
      (setq ch8 (hexl-char-after-point))
      (hexl-insert-char ch4 1)
      (hexl-insert-char ch5 1)
      (hexl-insert-char ch6 1)
      (hexl-insert-char ch7 1)
      (hexl-insert-char ch8 1))))

(defun hexl-transpose-words ()
  "Transpose words around point."
  (interactive)
  (let ((address (logand hexl-current-address -8))
	ch1 ch2 ch3 ch4 ch5 ch6 ch7 ch8 ch9 cha chb chc chd che chf ch0)
    (if (eq address 0)
	(error "Beginning of buffer.")
      (hexl-goto-address address)
      (setq ch1 (hexl-char-after-point))
      (hexl-forward-char 1)
      (setq ch2 (hexl-char-after-point))
      (hexl-forward-char 1)
      (setq ch3 (hexl-char-after-point))
      (hexl-forward-char 1)
      (setq ch4 (hexl-char-after-point))
      (hexl-forward-char 1)
      (setq ch5 (hexl-char-after-point))
      (hexl-forward-char 1)
      (setq ch6 (hexl-char-after-point))
      (hexl-forward-char 1)
      (setq ch7 (hexl-char-after-point))
      (hexl-forward-char 1)
      (setq ch8 (hexl-char-after-point))
      (hexl-backward-char 15)
      (setq ch9 (hexl-char-after-point))
      (hexl-insert-char ch1 1)
      (setq cha (hexl-char-after-point))
      (hexl-insert-char ch2 1)
      (setq chb (hexl-char-after-point))
      (hexl-insert-char ch3 1)
      (setq chc (hexl-char-after-point))
      (hexl-insert-char ch4 1)
      (setq chd (hexl-char-after-point))
      (hexl-insert-char ch5 1)
      (setq che (hexl-char-after-point))
      (hexl-insert-char ch6 1)
      (setq chf (hexl-char-after-point))
      (hexl-insert-char ch7 1)
      (setq ch0 (hexl-char-after-point))
      (hexl-insert-char ch8 1)
      (hexl-insert-char ch9 1)
      (hexl-insert-char cha 1)
      (hexl-insert-char chb 1)
      (hexl-insert-char chc 1)
      (hexl-insert-char chd 1)
      (hexl-insert-char che 1)
      (hexl-insert-char chf 1)
      (hexl-insert-char ch0 1))))

;; hex conversion

(defun hexl-insert-hex-char (arg)
  "Insert a ascii char ARG times at point for a given hexadecimal number."
  (interactive "p")
  (let ((num (hex-string-to-integer (read-string "Hex number: "))))
    (if (or (> num 255) (< num 0))
	(error "Hex number out of range.")
      (hexl-insert-char num arg))))

(defun hexl-insert-decimal-char (arg)
  "Insert a ascii char ARG times at point for a given decimal number."
  (interactive "p")
  (let ((num (string-to-int (read-string "Decimal Number: "))))
    (if (or (> num 255) (< num 0))
	(error "Decimal number out of range.")
      (hexl-insert-char num arg))))

(defun hexl-insert-octal-char (arg)
  "Insert a ascii char ARG times at point for a given octal number."
  (interactive "p")
  (let ((num (octal-string-to-integer (read-string "Octal Number: "))))
    (if (or (> num 255) (< num 0))
	(error "Decimal number out of range.")
      (hexl-insert-char num arg))))

;; startup stuff.

(if hexl-mode-map
    nil
    (setq hexl-mode-map (make-sparse-keymap))
    (define-key hexl-mode-map "\C-@" 'hexl-set-mark-command)
    (define-key hexl-mode-map "\C-a" 'hexl-beginning-of-line)
    (define-key hexl-mode-map "\C-b" 'hexl-backward-char)
    (define-key hexl-mode-map "\C-d" 'undefined)
    (define-key hexl-mode-map "\C-e" 'hexl-end-of-line)
    (define-key hexl-mode-map "\C-f" 'hexl-forward-char)

    (if (not (eq (key-binding "\C-h") 'help-command))
	(define-key hexl-mode-map "\C-h" 'undefined))

    (define-key hexl-mode-map "\C-i" 'hexl-self-insert-command)
    (define-key hexl-mode-map "\C-j" 'hexl-self-insert-command)
    (define-key hexl-mode-map "\C-k" 'undefined)
    (define-key hexl-mode-map "\C-m" 'hexl-self-insert-command)
    (define-key hexl-mode-map "\C-n" 'hexl-next-line)
    (define-key hexl-mode-map "\C-o" 'undefined)
    (define-key hexl-mode-map "\C-p" 'hexl-previous-line)
    (define-key hexl-mode-map "\C-q" 'hexl-quoted-insert)
    (define-key hexl-mode-map "\C-t" 'hexl-transpose-bytes)
    (define-key hexl-mode-map "\C-v" 'hexl-scroll-up)
    (define-key hexl-mode-map "\C-w" 'undefined)
    (define-key hexl-mode-map "\C-y" 'undefined)

    (let ((ch 32))
      (while (< ch 127)
	(define-key hexl-mode-map (format "%c" ch) 'hexl-self-insert-command)
	(setq ch (1+ ch))))

    (define-key hexl-mode-map "\e\C-@" 'hexl-mark-short)
    (define-key hexl-mode-map "\e\C-a" 'hexl-beginning-of-512b-page)
    (define-key hexl-mode-map "\e\C-b" 'hexl-backward-short)
    (define-key hexl-mode-map "\e\C-c" 'undefined)
    (define-key hexl-mode-map "\e\C-d" 'hexl-insert-decimal-char)
    (define-key hexl-mode-map "\e\C-e" 'hexl-end-of-512b-page)
    (define-key hexl-mode-map "\e\C-f" 'hexl-forward-short)
    (define-key hexl-mode-map "\e\C-g" 'undefined)
    (define-key hexl-mode-map "\e\C-h" 'undefined)
    (define-key hexl-mode-map "\e\C-i" 'undefined)
    (define-key hexl-mode-map "\e\C-j" 'undefined)
    (define-key hexl-mode-map "\e\C-k" 'undefined)
    (define-key hexl-mode-map "\e\C-l" 'undefined)
    (define-key hexl-mode-map "\e\C-m" 'undefined)
    (define-key hexl-mode-map "\e\C-n" 'undefined)
    (define-key hexl-mode-map "\e\C-o" 'hexl-insert-octal-char)
    (define-key hexl-mode-map "\e\C-p" 'undefined)
    (define-key hexl-mode-map "\e\C-q" 'undefined)
    (define-key hexl-mode-map "\e\C-r" 'undefined)
    (define-key hexl-mode-map "\e\C-s" 'undefined)
    (define-key hexl-mode-map "\e\C-t" 'hexl-transpose-shorts)
    (define-key hexl-mode-map "\e\C-u" 'undefined)
;;  (define-key hexl-mode-map "\e\C-v" 'undefined)
    (define-key hexl-mode-map "\e\C-w" 'undefined)
    (define-key hexl-mode-map "\e\C-x" 'hexl-insert-hex-char)
    (define-key hexl-mode-map "\e\C-y" 'undefined)
;;  (define-key hexl-mode-map "\e\C-z" 'undefined)

    (define-key hexl-mode-map "\e@" 'hexl-mark-word)
    (define-key hexl-mode-map "\ea" 'hexl-beginning-of-1k-page)
    (define-key hexl-mode-map "\eb" 'hexl-backward-word)
    (define-key hexl-mode-map "\ec" 'undefined)
    (define-key hexl-mode-map "\ed" 'undefined)
    (define-key hexl-mode-map "\ee" 'hexl-end-of-1k-page)
    (define-key hexl-mode-map "\ef" 'hexl-forward-word)
    (define-key hexl-mode-map "\eg" 'hexl-goto-hex-address)
    (define-key hexl-mode-map "\eh" 'undefined)
    (define-key hexl-mode-map "\ei" 'undefined)
    (define-key hexl-mode-map "\ej" 'hexl-goto-address)
    (define-key hexl-mode-map "\ek" 'undefined)
    (define-key hexl-mode-map "\el" 'undefined)
    (define-key hexl-mode-map "\em" 'undefined)
    (define-key hexl-mode-map "\en" 'undefined)
    (define-key hexl-mode-map "\eo" 'undefined)
    (define-key hexl-mode-map "\ep" 'undefined)
    (define-key hexl-mode-map "\eq" 'undefined)
    (define-key hexl-mode-map "\er" 'undefined)
    (define-key hexl-mode-map "\es" 'undefined)
    (define-key hexl-mode-map "\et" 'hexl-transpose-words)
    (define-key hexl-mode-map "\eu" 'undefined)
    (define-key hexl-mode-map "\ev" 'hexl-scroll-down)
    (define-key hexl-mode-map "\ey" 'undefined)
    (define-key hexl-mode-map "\ez" 'undefined)
    (define-key hexl-mode-map "\e<" 'hexl-beginning-of-buffer)
    (define-key hexl-mode-map "\e>" 'hexl-end-of-buffer)

    (define-key hexl-mode-map "\C-x\C-p" 'undefined)
    (define-key hexl-mode-map "\C-x\C-s" 'hexl-save-buffer)
    (define-key hexl-mode-map "\C-x\C-t" 'undefined)
    (define-key hexl-mode-map "\C-x\C-x" 'hexl-exchange-point-and-mark))

;; The End.
