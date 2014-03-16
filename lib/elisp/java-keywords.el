;;; To automatically use the definitions in this module you need to
;;; "plug in" the java font-lock keywords when entering
;;; font-lock mode in an java-mode buffer.  Here's how:
;;;       (add-hook 'font-lock-mode-hook
;;;                 (function
;;;                  (lambda ()
;;;                    (if (eq major-mode 'java-mode)
;;;                        (setq font-lock-keywords java-font-lock-keywords)))))

;;; This is done for you at the end of this module.  If you don't
;;; want this behavior, just comment out the relevant code.

(defconst java-font-lock-keywords-1 nil
 "For consideration as a value of `java-font-lock-keywords'.
This does fairly subdued highlighting.")

(defconst java-font-lock-keywords-2 nil
 "For consideration as a value of `java-font-lock-keywords'.
This does a lot more highlighting.")

(let ((storage (concat "static\\|abstract\\|const\\|final\\|"
		       "synchronized\\|threadsafe\\|transient\\|persistent"))
      (prefixes "short\\|long")
      (types (concat
	      "class\\|boolean\\|int\\|char\\|byte\\|float\\|double\\|void"))
      (reserved-words
       '("private" "protected" "public" "break" "byvalue"
	 "case" "catch" "class"
	 "continue" "default" "do" "else if"
	 "else" "extends" "false" "finally"
	 "for" "if" "implements" "import"
	 "instanceof" "interface"
	 "new" "null" "package" "return"
	 "super" "switch"
	 "this" "throw"
	 "true" "try" "while"))

      (ctoken "[a-zA-Z0-9_:~*]+")
      )
  (setq java-font-lock-keywords-1
   (list
    ;;
    ;; fontify C++-style comments as comments.
    '("//.*" . font-lock-comment-face)
    ;;
    ;; fontify the names of functions being defined.
    (list (concat
	   "^\\(" ctoken "[ \t]+\\)?"	; type specs; there can be no
	   "\\(" ctoken "[ \t]+\\)?"	; more than 3 tokens, right?
	   "\\(" ctoken "[ \t]+\\)?"
	   "\\([*&]+[ \t]*\\)?"		; pointer
	   "\\(" ctoken "\\)[ \t]*(")		; name
	  5 'font-lock-function-name-face)
    ;;
    ;; fontify the (first word of) names of methods being defined.
    (list (concat
	   "^[+-][ \t]+"
	   "\\(("                          ;; typecasts are inside parens
	   "\\(" ctoken "[ \t]+\\)?"       ;; as above, <= 3, right?
	   "\\(" ctoken "[ \t]+\\)?"
	   "\\(" ctoken "[ \t]*\\)?"
	   "\\(\*+[ \t]*\\)?"              ;; pointer
	   ")[ \t]*\\)?"                   ;; end of typecast
	   "\\(" ctoken "\\):?[ \t]*")
	  6 'font-lock-function-name-face)
    ;;
    ;; Fontify case clauses.  This is fast because its anchored on the left.
    '("case[ \t]+\\(\\(\\sw\\|\\s_\\)+\\):". 1)
    '("\\<\\(default\\):". 1)
    ))

  (setq java-font-lock-keywords-2
   (append java-font-lock-keywords-1
    (list
     ;;
     ;; fontify all storage classes and type specifiers
     (cons (concat "\\<\\(" storage "\\)\\>") 'font-lock-type-face)
     (cons (concat "\\<\\(" types "\\)\\>") 'font-lock-type-face)
     (cons (concat "\\<\\(" prefixes "[ \t]+" types "\\)\\>")
	   'font-lock-type-face)
     
     ;;
     ;; fontify all builtin tokens
	    (cons (concat
		   "[ \t]\\("
		   (mapconcat 'identity reserved-words "\\|")
		   "\\)[ \t\n(){};,]")
		  1)
	    (cons (concat
		   "^\\("
		   (mapconcat 'identity reserved-words "\\|")
		   "\\)[ \t\n(){};,]")
		  1)
	    )))
  )

; default to the gaudier variety:
(defvar java-font-lock-keywords java-font-lock-keywords-2
  "Additional expressions to highlight in Java mode.")


(provide 'java-keywords)

