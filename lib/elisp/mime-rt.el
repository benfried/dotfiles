;; 
;; Some stuff to aid in the composition of MIME richtext.  This is designed
;; to be used with mime-compose.el by Marc Andreessen (marca@ncsa.uiuc.edu).
;;
;; We create a keymap and fill it with one-letter abbreviations to insert 
;; the MIME Richtext keywords.  We bind this new keymap to C-cC-r in the 
;; mh-letter-mode, or C-r in the mail-mode (I don't use RMAIL so I don't 
;; know if this clashes with anything....)
;;
;; This allows the single sequence C-cC-rb to insert the tokens 
;; "<bold></bold>" in the current buffer at the current point, then leave
;; the point between the "><" characters.
;;
;; Not all the MIME keywords are supported; only the ones likely to be used 
;; by me.
;;
;; I use it by putting the following in my .emacs, so that mh will load it 
;; when required:
;;	(defun my-mh-letter-mode-hooks () (require 'mime-rt))
;;	(setq mh-letter-mode-hook 'my-mh-letter-mode-hooks)
;;
;; Gregory Bond, gnb@bby.com.au, 8 Feb 1993.
;; This file is in the public domain.
;;
;; The following keymap entries are made:
;;
;; C-c C-r p	mime-rt-new-page
;; C-c C-r RET	mime-rt-new-line
;; C-c C-r n	mime-rt-new-line
;; C-c C-r C-l	mime-rt-lt
;; C-c C-r <	mime-rt-lt
;; C-c C-r _	mime-rt-subscript
;; C-c C-r ^	mime-rt-superscript
;; C-c C-r c	mime-rt-center
;; C-c C-r u	mime-rt-underline
;; C-c C-r g	mime-rt-bigger
;; C-c C-r m	mime-rt-smaller
;; C-c C-r f	mime-rt-fixed
;; C-c C-r i	mime-rt-italic
;; C-c C-r b	mime-rt-bold

(require 'mime-compose "mime-compose")
(provide 'mime-rt)

(defvar mime-rt-map (make-sparse-keymap)
  "A keymap used to insert MIME richtext tokens.")

(if mime-running-mh-e
    (define-key mh-letter-mode-map "\C-c\C-r" mime-rt-map)
  ;; I don't use RMAIL, so I hope this is OK!
  ;; ben - bind to `r for me.  (normally revert buffer, meaningless in mail
  (define-key mail-mode-map "`r" mime-rt-map))
  
(defun mime-rt-insert-keyword-pair (keyword)
  "Insert a Mime Richtext keyword pair \"<KEYWORD></KEYWORD>\"."
  (interactive "sMIME Richtext Keyword: ")
  (insert (format "<%s></%s>" keyword keyword))
  (forward-word -1)
  (forward-char -2))

;
; Define a function and map a key to do a mime keyword
;
(defmacro mime-rt-make-keymap-entry (keyword letter)
  "Make a function called \"mime-rt-<KEYWORD>\" to insert the Mime richtext
keyword pairs at the current point.  Adds an entry to the mime-rt-map with 
LETTER to access that function."
  (let ((fn-name (intern (concat "mime-rt-" keyword))) ; A SYMBOL
	)
    (` (progn
	 (defun (, fn-name) ()
	   (interactive)
	   (mime-rt-insert-keyword-pair (, keyword)))
	 (define-key mime-rt-map (, letter) '(, fn-name))))))

;
; Now the actual keys
;
(mime-rt-make-keymap-entry "bold" "b")
(mime-rt-make-keymap-entry "italic" "i")
(mime-rt-make-keymap-entry "fixed" "f")
(mime-rt-make-keymap-entry "smaller" "m") ; sMaller
(mime-rt-make-keymap-entry "bigger" "g") ; biGger
(mime-rt-make-keymap-entry "underline" "u")
(mime-rt-make-keymap-entry "center" "c")
(mime-rt-make-keymap-entry "superscript" "^") ;a la TeX math mode
(mime-rt-make-keymap-entry "subscript" "_") ;a la TeX math mode

;
; These ones don't have the balancing </...> form
; They are just inserts so I can do it in the define-key
; _BUT_ then C-hC-m gives ?? as the binding for that key.  So do 
; a defun anyway.
(defun mime-rt-lt () (interactive) (insert "<lt>"))
(defun mime-rt-new-line () (interactive) (insert "<nl>"))
(defun mime-rt-new-page () (interactive) (insert "<np>"))

(define-key mime-rt-map "<" 'mime-rt-lt)
(define-key mime-rt-map "\C-l" 'mime-rt-lt) ; C-< is C-, is C-L, Easier to type!
(define-key mime-rt-map "n" 'mime-rt-new-line)
(define-key mime-rt-map "\C-m" 'mime-rt-new-line) ;Enter as well.
(define-key mime-rt-map "p" 'mime-rt-new-page)
