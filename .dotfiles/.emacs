(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#073642" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#657b83"])
 '(compilation-message-face 'default)
 '(cua-global-mark-cursor-color "#2aa198")
 '(cua-normal-cursor-color "#839496")
 '(cua-overwrite-cursor-color "#b58900")
 '(cua-read-only-cursor-color "#859900")
 '(custom-enabled-themes '(shrek\.1))
 '(custom-safe-themes
   '("fee7287586b17efbfda432f05539b58e86e059e78006ce9237b8732fde991b4c" "2809bcb77ad21312897b541134981282dc455ccd7c14d74cc333b6e549b824f3" "0598c6a29e13e7112cfbc2f523e31927ab7dce56ebb2016b567e1eff6dc1fd4f" "8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "fc5fcb6f1f1c1bc01305694c59a1a861b008c534cae8d0e48e4d5e81ad718bc6" "b4272df32c348aac1d3d47d57017df115e3e3cb15c55549adc12899b18c07432" "f0443a2e0956a410f6551282a9171a4fee2d4d4fe764fefb095824046981bde2" default))
 '(desktop-save 'ask)
 '(electric-indent-mode t)
 '(elpy-syntax-check-command "/opt/local/bin/pyflakes")
 '(fci-rule-color "#073642")
 '(gnutls-algorithm-priority "normal:-vers-tls1.3")
 '(highlight-changes-colors '("#d33682" "#6c71c4"))
 '(highlight-symbol-colors
   (--map
    (solarized-color-blend it "#002b36" 0.25)
    '("#b58900" "#2aa198" "#dc322f" "#6c71c4" "#859900" "#cb4b16" "#268bd2")))
 '(highlight-symbol-foreground-color "#93a1a1")
 '(highlight-tail-colors
   '(("#073642" . 0)
     ("#546E00" . 20)
     ("#00736F" . 30)
     ("#00629D" . 50)
     ("#7B6000" . 60)
     ("#8B2C02" . 70)
     ("#93115C" . 85)
     ("#073642" . 100)))
 '(hl-bg-colors
   '("#7B6000" "#8B2C02" "#990A1B" "#93115C" "#3F4D91" "#00629D" "#00736F" "#546E00"))
 '(hl-fg-colors
   '("#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36"))
 '(hl-paren-colors '("#2aa198" "#b58900" "#268bd2" "#6c71c4" "#859900"))
 '(magit-diff-use-overlays nil)
 '(magit-use-overlays nil)
 '(maxima-command "/opt/local/bin/maxima")
 '(nrepl-message-colors
   '("#dc322f" "#cb4b16" "#b58900" "#546E00" "#B4C342" "#00629D" "#2aa198" "#d33682" "#6c71c4"))
 '(org-agenda-files '("~/Google Drive/notes/notes.org"))
 '(package-selected-packages
   '(ivy-hydra company-emoji company forge org-bullets ac-geiser geiser-mit elpy xwwp xwwp-follow-link-helm osx-plist lsp-mode lsp-python lsp-ui ac-slime async auto-complete cider concurrent ctable dart-mode dash-at-point deferred edit-server ein f fuzzy git-commit gmail-message-mode go-autocomplete go-eldoc go-mode ivy jedi jedi-core magit magit-popup oauth2 ox-clip projectile python-environment rainbow-delimiters request slime smartparens solarized-theme web-mode websocket with-editor yasnippet))
 '(paren-match-face 'highlight)
 '(paren-sexp-mode t)
 '(pos-tip-background-color "#073642")
 '(pos-tip-foreground-color "#93a1a1")
 '(python-shell-completion-native-disabled-interpreters '("pypy" "ipython" "jupyter" "jupyter-3.7"))
 '(python-shell-interpreter "/opt/local/bin/jupyter-3.7 ")
 '(python-shell-interpreter-args "console --simple-prompt")
 '(safe-local-variable-values
   '((eval font-lock-add-keywords nil
	   `((,(concat "("
		       (regexp-opt
			'("sp-do-move-op" "sp-do-move-cl" "sp-do-put-op" "sp-do-put-cl" "sp-do-del-op" "sp-do-del-cl")
			t)
		       "\\_>")
	      1 'font-lock-variable-name-face)))
     (Syntax . ANSI-Common-Lisp)
     (Base . 10)
     (eval c-make-noise-macro-regexps)
     (c-noise-macro-with-parens-names "IF_LINT")
     (encoding . utf-8)
     (Package . GUI)
     (Syntax . Common-Lisp)
     (eval fold-set-marks "# {{{" "# }}}")
     (major-mode . makefile-mode)
     (folded-file . t)))
 '(scroll-bar-mode 'right)
 '(show-paren-mode t)
 '(smartrep-mode-line-active-bg (solarized-color-blend "#859900" "#073642" 0.2))
 '(term-default-bg-color "#002b36")
 '(term-default-fg-color "#839496")
 '(tool-bar-mode nil)
 '(vc-annotate-background nil)
 '(vc-annotate-background-mode nil)
 '(vc-annotate-color-map
   '((20 . "#dc322f")
     (40 . "#c9485ddd1797")
     (60 . "#bf7e73b30bcb")
     (80 . "#b58900")
     (100 . "#a5a58ee30000")
     (120 . "#9d9d91910000")
     (140 . "#9595943e0000")
     (160 . "#8d8d96eb0000")
     (180 . "#859900")
     (200 . "#67119c4632dd")
     (220 . "#57d79d9d4c4c")
     (240 . "#489d9ef365ba")
     (260 . "#3963a04a7f29")
     (280 . "#2aa198")
     (300 . "#288e98cbafe2")
     (320 . "#27c19460bb87")
     (340 . "#26f38ff5c72c")
     (360 . "#268bd2")))
 '(vc-annotate-very-old-color nil)
 '(warning-suppress-types '((comp)))
 '(weechat-color-list
   '(unspecified "#002b36" "#073642" "#990A1B" "#dc322f" "#546E00" "#859900" "#7B6000" "#b58900" "#00629D" "#268bd2" "#93115C" "#d33682" "#00736F" "#2aa198" "#839496" "#657b83"))
 '(xterm-color-names
   ["#073642" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#eee8d5"])
 '(xterm-color-names-bright
   ["#002b36" "#cb4b16" "#586e75" "#657b83" "#839496" "#6c71c4" "#93a1a1" "#fdf6e3"]))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "Black" :foreground "White" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 160 :width normal :foundry "apple" :family "Hack"))))
 '(cursor ((t (:background "yellow"))))
 '(highlight ((((class color) (min-colors 89)) (:background "#073642"))))
 '(mode-line-buffer-id ((t (:foreground "blue" :background "firebrick" :slant italic :weight bold))))
 '(org-done ((t (:foreground "yellow1" :weight bold))))
 '(org-level-1 ((t (:inherit default :foreground "#cb4b16" :height 1.3))))
 '(org-level-2 ((t (:inherit default :foreground "#859900" :height 1.2))))
 '(org-level-3 ((t (:inherit default :foreground "#268bd2" :height 1.15))))
 '(org-level-4 ((t (:inherit default :foreground "#b58900" :height 1.1))))
 '(org-level-5 ((t (:inherit default :foreground "#2aa198"))))
 '(org-level-6 ((t (:inherit default :foreground "#859900"))))
 '(org-level-7 ((t (:inherit default :foreground "#dc322f"))))
 '(org-level-8 ((t (:inherit default :foreground "#268bd2"))))
 '(sp-pair-overlay-face ((t (:background "#073642" :inverse-video t)))))

;;; how to colorize mode line?

(require 'package)
;(add-to-list 'package-archives
;	     '("marmalade" . "https://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
;(add-to-list 'package-archives
;	     '("org" . "https://orgmode.org/elpa/") t)


(setq package-archive-priorities
      '(;("org" . 3)
	("melpa" . 2)
;	("marmalade" . 1)
	("gnu" . 0)))

;(setq package-selected-packages
;   '(ac-slime async auto-complete cider concurrent ctable dart-mode dash-at-point deferred edit-server ein f fuzzy git-commit gmail-message-mode go-autocomplete go-eldoc go-mode go-snippets jedi jedi-core magit magit-popup oauth2 ox-clip projectile python-environment rainbow-delimiters request slime smartparens solarized-theme web-mode websocket with-editor yasnippet yasnippet-snippets))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;;; make package subsystem install all selected but uninstalled packages
(unless (package-installed-p (car package-selected-packages))
  (package-install-selected-packages))

(if (version< "27.0" emacs-version)
    (set-fontset-font
     "fontset-default" 'unicode "Apple Color Emoji" nil 'prepend)
  (set-fontset-font
   t 'symbol (font-spec :family "Apple Color Emoji") nil 'prepend))

(global-company-mode)
(setq company-backends
      '(company-emoji
	company-capf
	company-clang
	company-files
	(company-dabbrev-code company-gtags company-etags company-keywords) company-yasnippet company-dabbrev))

;;; however, for packages that are distributed with emacs but for which there's a newer version in one of the archives,
;;; what we really want to do is force download of the newer version. Org is the case I'm most concerned about.
;;; however, one hitch: it looks like the pkg-desc struct in package-alist is not initialized with the full ino like repo it
;;; was loaded from: the package-desc looks like 
;;; #s(package-desc org (20190218) "Outline-based notes management and organizer" nil nil nil "/Users/bf/.emacs.d/elpa/org-20190218" nil nil)
;;; so not sure what to do, and will have to resort to manual installs of org for the time being

;(let ((orgs (cdr (assoc 'org package-archive-contents))) ; all version of org
;      (current-org (cadr (assq 'org package-alist))))	 ; pkg-desc of the version of org that's installed now
;  (unless (equal (package-desc-archive current-org) "org"))) ; *** TODO *** can't figure this out now


(setq-default mode-line-buffer-identification (propertized-buffer-identification "%b"))

(message "set mode-line-buffer-identification to %s" mode-line-buffer-identification)

(defface mode-line-emacs-id
  '((default :inherit mode-line-buffer-id :weight bold))
  "Face for emacs' name"
  :group 'mode-line-faces
  :group 'basic-faces)

(setq default-mode-line-format
      (cond ((string-match "XEmacs" emacs-version)
	     (list "%[b's "
		   (cons modeline-buffer-id-left-extent "EMACS")
		   " ("
		   (cons modeline-minor-mode-extent
			 (list "" 'mode-name 'minor-mode-alist))
		   (cons modeline-narrowed-extent "%n")
		   "; %M"
		   (list 'mode-line-process 'mode-line-process)
		   ") "
		   (cons modeline-buffer-id-extent "%b:")
		   (list 'line-number-mode "%l " " ")
		   (cons modeline-modified-extent "%*")
		   " %f %p%]"))
	    (t
	     '("%[b's EMACS (" 
	       mode-name minor-mode-alist "; %n"
	       ") " mode-line-buffer-identification ": %* %f %p %12l%]"))))

(setq-default mode-line-format default-mode-line-format
	      display-time-display-time-foreground "yellow"
	      homedir (getenv "HOME"))


;;; (insert "mode line...")


;;; turn off novice stuff
(put 'eval-expression 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)

(fset 'yes-or-no-p (symbol-function 'y-or-n-p))
(fset 'non-saved-text-mode (symbol-function 'text-mode))

(setq version-control t			;file generations under unix - big win!
      kept-new-versions 50		;I want lots of versions
      kept-old-versions 20
      comment-column 40
      default-fill-column 72
      rmail-dont-reply-to-names "mailer daemon\\|ben\\|ben.fried@morganstanley.com"
      rmail-file-name "~/mail/RMAIL"
      rmail-delete-after-output t
      rmail-last-rmail-file "~/mail/RMAIL"
      require-final-newline t		;add newline when missing silently
      mail-archive-file-name "~/mail/outgoing.txt"
      scribe-electric-quote t		;turn on quotes like `` and ''
      c-indent-level 4			
      c-continued-statement-offset 4
      c-brace-offset -4			; -4
      c-label-offset -4
      c-argdecl-indent 4
      c++-access-specifier-offset -4
      c++-empty-arglist-indent 4
      c++-friend-offset 0
      jit-lock-defer-time 0.05  
      font-lock-maximum-decoration t	;go for the gaudy
      inhibit-local-variables t		;disallow the trojan horse
      window-min-height 2		;1-line windows
      window-min-width 1		;1-column windows
      sentence-end-double-space nil	;in the 21st century, a single space can end a sentence.
      auto-mode-alist (append '(("\\.c4$" . c-mode) ("\\.c4~$" . c-mode)
				("\\.h4$" . c-mode) ("\\.h4~$" . c-mode)
				("\\.H$" . c++-mode)
				("\\.C$" . c++-mode)
				("\\.S$" . scheme-mode)
				("\\.otl$" . outline-mode)
				("\\.outline$" . outline-mode)
				("\\.ps$" . postscript-mode)
				("wid\\..*$" . wid-mode))
			      auto-mode-alist)
      load-path (append (list (concat homedir "/lib/elisp"))
			(list (concat homedir "/lib/elisp/org/lisp"))
			(list (concat homedir "/lib/elisp/dmacro"))
			(list "/opt/local/share/maxima/5.39.0/emacs")
			load-path)
      ms-old-style-kill t
      ispell-program-name "/opt/local/bin/aspell"
      ispell-extra-args '("--sug-mode=ultra")
      completion-ignored-extensions
      (append completion-ignored-extensions '(".ln3" ".dvi")))

(require 'cu-funcs)

(set-face-foreground 'mode-line "yellow")
(set-face-background 'mode-line "firebrick")
(set-face-foreground 'mode-line-buffer-id "blue")
(set-face-background 'mode-line-buffer-id "firebrick")
(set-face-foreground 'mode-line-inactive "firebrick")
(set-face-background 'mode-line-inactive "yellow")
(set-face-font 'mode-line-active (face-font 'mode-line))
; was "-*-Hack-medium-normal-normal-*-*-*-*-*-m-0-iso10646-1"

;(require 'maxima-font-lock)
;(require 'maxima)

(setq frame-title-format (list "emacs\@" (get-hostname) ":%b"))
(font-lock-mode t)
(require 'filladapt)
(setq-default filladapt-mode t)

(require 'cl)
(transient-mark-mode t)
(setq-default comment-column 40)
(require 'server)
(require 'crypt++)
(require 'dmacro)
(autoload 'postscript-mode "postscript.el" "" t)
(autoload 'sc-cite-original "supercite" t)
;(dmacro-load (expand-file-name "~/lib/elisp/dmacro/ben.dm"))
;(dmacro-load (expand-file-name "~/lib/elisp/dmacro/demo.dm"))
;(setq auto-dmacro-alist
;      '(("\\.[cly]$" . ctemplate)
;	("\\.h$" . htemplate)
;	("\\.cc$\\|\\.C$" . cctemplate)
;	("\\.H$" . hhtemplate)))
;(defun dmik-prompter (prompt format)
;    (let ((answer (read-string prompt)))
;      (if (string= answer "")
;	  answer
;	(format format answer))))

(setq sc-load-hook '(lambda () (sc-setup-filladapt)
		      (require 'sc-register)
		      (setq sc-auto-fill-region-p nil
			    sc-preferred-attribution-list
			    (cons "registered"
				  sc-preferred-attribution-list))))
(setq sc-auto-fill-region-p nil)
(setq sc-citation-leader "    ")



;;; prefix characters -- you just can't get too many, can you?

(defvar control-meta-map (make-keymap)
  "Variable that holds the key bindings for control-meta functions")
(fset 'control-meta-prefix control-meta-map)		;link these two
(define-key global-map "\^c" 'control-meta-prefix)	;define it

(define-key global-map "\^j" 'newline-and-indent)

(defvar backquote-map (make-keymap)
  "Variable to hold backquote-prefix key mappings")
(fset 'backquote-prefix backquote-map)
(define-key global-map "\`" 'backquote-prefix)


;;;(insert "new prefixes...")

;;; Define a complete C-M prefix command set.
;;; Note C-M is bound to C-C.

(define-key control-meta-map "\^b" 'deselect-other-window)
(define-key control-meta-map "\^k" 'kill-rectangle)
(define-key control-meta-map "\^y" 'yank-rectangle)
(define-key control-meta-map "\^z" 'exit-recursive-edit)
(define-key control-meta-map "\" 'self-insert-command)
(define-key control-meta-map "\^c" 'delete-other-windows)
(define-key control-meta-map "\=" 'compare-windows)
(define-key control-meta-map "[" 'eval-expression)
(define-key control-meta-map "," 'find-tag)
(define-key control-meta-map "." 'insert-date-and-time)
(define-key control-meta-map "?" 'kill-region)
(define-key control-meta-map "!" 'shell)
(define-key control-meta-map "a" 'beginning-of-defun)
(define-key control-meta-map "b" 'backward-sexp)
(define-key control-meta-map "c" 'exit-recursive-edit)
(define-key control-meta-map "d" 'down-list)
(define-key control-meta-map "e" 'end-of-defun)
(define-key control-meta-map "f" 'forward-sexp)
(define-key control-meta-map "h" 'mark-defun)
(define-key control-meta-map "j" 'indent-new-comment-line)
(define-key control-meta-map "k" 'kill-sexp)
(define-key control-meta-map "n" 'forward-list)
(define-key control-meta-map "o" 'split-line)
(define-key control-meta-map "p" 'backward-list)
(define-key control-meta-map "q" 'indent-sexp)
(define-key control-meta-map "s" 'isearch-forward-regexp)
(define-key control-meta-map "t" 'transpose-sexps)
(define-key control-meta-map "u" 'backward-up-list)
(define-key control-meta-map "v" 'my-scroll-other-window)
(define-key control-meta-map "\^v" 'my-scroll-other-window)
(define-key control-meta-map "w" 'what-line)
(define-key control-meta-map "x" 'eval-defun)
(define-key control-meta-map "z" 'suspend-emacs)
(define-key control-meta-map "\;" 'kill-comment)
(define-key control-meta-map "\^d" 'insert-date)
(define-key control-meta-map [backspace] 'append-next-kill)
(global-set-key [C-M-backspace] 'append-next-kill)

(define-key global-map "\M-/" 'hippie-expand)
(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
	try-complete-file-name-partially
	try-complete-file-name
	try-expand-all-abbrevs
	try-expand-list
	try-expand-line
	try-expand-dabbrev-all-buffers
	try-expand-dabbrev-from-kill
	try-complete-lisp-symbol-partially
	try-complete-lisp-symbol))
;;;(insert "c-m bindings...")

;;; backquote-key mappings

(define-key backquote-map "\`" 'self-insert-command)
(define-key backquote-map "\^h" 'date-edit)
(define-key backquote-map "u" 'upcase-word)
(define-key backquote-map "\^b" 'electric-command-history)
(define-key backquote-map "b" 'bbook)
(define-key backquote-map "c" 'capitalize-word)
(define-key backquote-map "d" 'insert-dmacro)
(define-key backquote-map "p" 'lpr-buffer)
(define-key backquote-map "l" 'downcase-word)
(define-key backquote-map "e" 'enscript-buffer)
(define-key backquote-map "g" 'line-goto)
(define-key backquote-map "r" 'revert-buffer)
(define-key backquote-map "v" 'view-buffer)
(define-key backquote-map "w" 'count-words)
(define-key backquote-map "f" 'finger)
(define-key backquote-map "h" 'manual-entry)
(define-key backquote-map "x" 'eval-region)
(define-key backquote-map "\;" 'comment-out-lines)
(define-key backquote-map "'" 'uncomment-out-lines)

;;; (insert "backquote bindings...")


;;; some other (re) mappings

(define-key global-map "\^h" 'backward-delete-char-untabify)
(define-key global-map "\^_" 'help-command) ;the REAL help character
(define-key global-map "\^w" 'backward-kill-word) ;like in the shell

(define-key esc-map "\" 'kill-region)
(define-key esc-map "n" 'down-comment-lines)
(define-key esc-map "p" 'up-comment-lines)
;(define-key esc-map "q" 'fill-paragraph-and-align)
(define-key esc-map "u" 'backward-uppercase-word)
(define-key esc-map "l" 'backward-lowercase-word)
(define-key esc-map "c" 'backward-capitalize-word)
(define-key esc-map "m" 'mycompile)
(define-key esc-map "\?" 'describe-key)	;fine, eh, hoser?
(define-key esc-map "`" 'date-edit)
(define-key esc-map "\," 'move-to-window-top)
(define-key esc-map "\." 'move-to-window-bottom)
(define-key esc-map "]" 'forward-paragraph)
(define-key esc-map "[" 'backward-paragraph)

(define-key ctl-x-map "\^b" 'electric-buffer-list) ;very fine, like in Daffy
(define-key ctl-x-map "\^k" 'kill-some-buffers)	;from cck

;;; (insert "other bindings...")

(setq month-vals
     '(("Jan" 1) ("Feb" 2) ("Mar" 3) ("Apr" 4) ("May" 5) ("Jun" 6)
       ("Jul" 7) ("Aug" 8) ("Sep" 9) ("Oct" 10) ("Nov" 11) ("Dec" 12)))

(defun insert-date (arg)
  "Insert current date in abbreviated format."
  (interactive "*p")
  (let* ((now (current-time-string))	;With ugly-printed timestamp
	 (firstchar (string-to-char (substring now 8 9)))
	 (month (substring now 4 7)))
    (cond ((equal arg 1)
	   (insert (substring now 0 3) " ")
	   (if (/= firstchar 32) (insert-char firstchar 1))
	   (insert (substring now 9 10) " "	  ;Insert day of month
		   (substring now 4 7) " "	  ;Abbreviated name of month
		   (substring now 20 24)))
	  (t
	   (insert (int-to-string (cadr (assoc month month-vals))) "/")
	   (if (/= firstchar 32) (insert-char firstchar 1))
	   (insert (substring now 9 10) "/"
		   (substring now 22 24))))))	  ;Full year number
	    


;;; (insert "insert-date...")
;;; (insert "date-edit...")


(defun my-scroll-other-window (n)
  "Scroll Other Window fixed by ben"
  (interactive "p")
  (let ((tem n))
    (if (equal n 0) (setq tem 1))
    (setq tem (* tem (- (check-size-other-window 1) 1)))
    (scroll-other-window tem)))

;;; (insert "my-scroll-other-window...")

(defun check-size-other-window (n)
  "check the size of the next window, improved by ben" 
  (other-window n)
  (let ((tem (- (window-height) 1)))
       (other-window (- 0 n))
       tem))

;;; (insert "check-size-other-window...")

(defun exchange-dot-and-mark () (exchange-point-and-mark))

(defun enscript-buffer ()
  "Print this buffer nicely on the laserwriter."
  (interactive)
  (save-excursion
    (message "Spooling to the LaserWriter.  Hold your horses...")
    (if (/= tab-width 8)
	(let ((oldbuf (current-buffer)))
	  (set-buffer (get-buffer-create " *spool PStemp*"))
	  (widen) (erase-buffer)
	  (insert-buffer-substring oldbuf)
	  (call-process-region (dot-min) (dot-max) "/usr/ucb/expand"
			       t t nil
			       (format1 "-%d" tab-width))))
    (apply 'call-process-region
	   (nconc (list (dot-min) (dot-max) "/usr/local/bin/enscript"
			nil nil nil
			"-J" (concat "b's Emacs " (buffer-name))
			"-b" (concat "b's Emacs " (buffer-name)))))
    (message "Finished")))

;;; (insert "enscript-buffer...")
(defun line-goto (arg) "goto a given line"
  (interactive "P")
  (goto-line arg))

(defun my-compile ()
  (interactive)
  (save-some-buffers t)			; save & don't ask.  won't save "*"'s.
  (compile "make -k"))			; compile explicitly.  don't ask.

(defun set-compile-command () ""
  (interactive)
  (cond ((eq compile-command nil)
	 (setq compile-command
	       (concat "make -k -f " default-directory "Makefile ")))
	(t compile-command)))

(defun mycompile (command)		;point to my compile1!!!
  "Compile the program including the current buffer.  Default: run make.
Runs COMMAND, a shell command, in a separate process asynchronously
with output going to the buffer *compilation*.
You can then use the command  next-error  to find the next error message
and move to the source code that caused it."
  (interactive (list (read-from-minibuffer "Compile command: " (set-compile-command))))
  (setq compile-command command)
  (compile compile-command))

;;; (insert "mycompile...")

;;; (insert "mycompile...")

(defun set-comment-column (col) "set the comment column.
Set to arg.  If no arg, set to current column."
  (interactive "P")
  (cond ((eq col nil) (setq comment-column (current-column)))
	(t (setq comment-column col)))
  (indent-for-comment)
  (princ "Comment Column is ")
  (princ comment-column))

;;; (insert "set-comment-column...")

;;;Set up a LaTeX begin/end pair
(defun latex-setup-begin-end (env)
  "Set up a begin/end pair for a LaTeX command.  You give it the name of the
Environment"
  (interactive "sEnvironment Name: ")
  (insert-string "\n\\begin{")
  (insert-string env)
  (insert-string "}\n\n\\end{") (insert-string env) (insert-string "}\n")
  (previous-line 2))

;;; My own c-comment-indent -- if we're at beginning of line, then don't 
;;; do anything.
(defun c-comment-indent ()
  (cond ((bolp) 0)
	((looking-at "^/\\*") 0)	;Existing comment at bol stays there.
	(t 
	 (save-excursion
	   (skip-chars-backward " \t")
	   (max (1+ (current-column))	;Else indent at comment column
		comment-column)))))	; except leave at least one space.

;;; (insert "c-comment-indent...")


(defun sort-phone-book () 
  "sort paragraphs, by last word on first line"
  (interactive)
  (save-excursion
    (sort-pages nil
		(point-min)
		(point-max))))

(defvar bbook-default-name "")
(defun bbook (name) "look up a bbook entry"
  (interactive
   (list 
    (read-string 
     (concat "name: " (if (not (string= bbook-default-name ""))
			  (concat "(default " bbook-default-name ") "))))))
  (if (string= name "") 
      (setq name bbook-default-name)
    (setq bbook-default-name name));
  (pop-to-buffer "*BBOOK*")
  (if (zerop (buffer-size))
      (progn
	(insert-file "~/.bbook")
	(not-modified)
        (toggle-read-only)))
  (widen)
  (goto-char (point-min))
  (if (null (search-forward name (point-max) 'move))
      (progn
	(delete-window)
	(message "Not found"))
    (progn
      (re-search-forward "\^j\^l\^j" (point-max) 'move)
      (skip-chars-backward "\^j\^l\^j" (point-min))
      (setq eobb (point))
      (re-search-backward "\^j\^l\^j" (point-min) 'move)
      (skip-chars-forward "\^j\^l\^j" (point-max))
      (narrow-to-region (point) eobb)
      (if (< 3 (count-lines (point-min) (point-max)))
	  (window-to-size))
      (other-window -1))))

;;; (insert "bbook stuff...")
(defun egrep (command)
  "Run egrep, with user-specified args, and collect output in a buffer.
While egrep runs asynchronously, you can use the \\[next-error] command
to find the text that egrep hits refer to."
  (interactive "sRun egrep (with args): ")
  (compile1 (concat "egrep -n " command " /dev/null")
	    "No more bm hits" "egrep"))


(defun bf-run-lisp ()
  "Run an inferior Lisp process, input and output via buffer *lisp*."
  (interactive)
  (switch-to-buffer (make-shell "lisp" "cl"))
  (inferior-lisp-mode))

(setq inferior-lisp-program "/opt/local/bin/sbcl") ; your Lisp system
;; (add-to-list 'load-path "~/src/slime/")  ; your SLIME directory
;(require 'auto-complete)
;(require 'slime)

(setq slime-lisp-implementations
      '((sbcl ("/opt/local/bin/sbcl") :init slime-init-command)
	(mit-scheme ("mit-scheme") :init mit-scheme-init)))

(setq *using-slime-mit-scheme-swank* nil)

(defun mit-scheme-init (file encoding)
  (if *using-slime-mit-scheme-swank*
      (format "%S\n\n"
	      `(begin
		(load-option 'format)
		(load-option 'sos)
 		(eval 
 		 '(create-package-from-description
 		   (make-package-description '(swank) (list (list))
 					     (vector) (vector) (vector) false))
 		 (->environment '(package)))
		(load "/Users/bf/src/swank-mit-scheme.scm")
		(eval '(start-swank ,file) (->environment '(swank)))))
    (format "%S\n\n"
	    `(begin
	      (load-option 'format)
	      (load-option 'sos)
	      (load "/Users/bf/src/mit-scheme-swank/swank.scm")
	      (->environment '(runtime swank))
	      (trace read-packet)
	      (trace decode-message)
	      (trace process-one-message)
	      (trace serve)
	      (trace start-swank)
	      (trace main-loop)
	      (trace with-keyboard-interrupt-handler)
	      (start-swank ,file)))))
    

(defun mit-scheme ()
  (interactive)
  ;;  (slime 'mit-scheme)
  (run-geiser 'mit))

(defun find-mit-scheme-package ()
  (save-excursion
    (let ((case-fold-search t))
      (and (re-search-backward "^[;]+ package: \\((.+)\\).*$" nil t)
	   (match-string-no-properties 1)))))

;(setq slime-find-buffer-package-function 'find-mit-scheme-package)
; (add-hook 'scheme-mode-hook (lambda () (slime-mode 1)))

(slime-setup '(slime-fancy slime-banner))
(require 'hyperspec)
(setq common-lisp-hyperspec-root "file:/Users/bf/src/HyperSpec/"
      common-lisp-hyperspec-symbol-table "/Users/bf/src/HyperSpec/Data/Map_Sym.txt")

(setq geiser-active-implementations '(mit)
      geiser-mit-source-directory "/Users/bf/src/mit-scheme-11.2/src")


(defun idl-mode ()
"Cuspy mode for writing Idl specs"
  (interactive)
  (text-mode)
  (setq comment-start "-- "
	comment-start-skip "--[.	]*"
	comment-end ""
	major-mode "idl-mode"
	tab-stop-list 	'(4 9 14 19 24 29 34 39 44 49 54 59 64 69 74 79)
	mode-name "Idl"))

(defun ce-mode () "Editing mode for Concurrent Euclid---not trivial"
  (interactive)
  (fundamental-mode)
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'indent-relative)
  (setq comment-start "{ ")
  (setq comment-start-skip "{ *")
  (setq comment-end " }")
  (setq comment-column 40)
  (setq major-mode "concurrent-euclid-mode")
  (setq mode-name "CE")
  (message "Concurrent Euclid not trivial"))

(add-hook 'find-file-not-found-functions
	  '(lambda nil
             (if (or (file-readable-p (format "%s,v" buffer-file-name))
		     (file-readable-p
		      (format "%sRCS/%s,v"
			      (or (file-name-directory buffer-file-name) "")
			      (file-name-nondirectory buffer-file-name))))
		 (save-excursion
		   (message "Checking out %s" buffer-file-name)
		   (call-process "sh"	;run the shell
				 nil	;no input
				 t	;output to current buffer
				 nil	;don't update display
				 "-c"	;shell command
				 (format "co -p %s 2>/dev/null" buffer-file-name))
		   (set-buffer-modified-p nil)
		   (set-buffer-auto-saved)
		   (setq buffer-read-only t))
	       t)))

(defun shell-mode-hook-code ()
  (ansi-color-for-comint-mode-on)
  (setq mode-line-format default-mode-line-format))

(defun electric-buffer-menu-mode-hook-code () ;spiffy up the modeline
  (define-key electric-buffer-menu-mode-map "q" 'Electric-buffer-menu-select)
  (define-key electric-buffer-menu-mode-map "x" 'Electric-buffer-menu-select)
  (setq mode-line-format '("Electric Buffer Menu  %[%M%] %3p")))
(defun outline-mode-hook-code ()
  "Fix up things in outline mode"
  (setq ; outline-regexp "[ \t]*[*]+"
	tab-stop-list 	'(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72
			    76)
	comment-start	"# "
	comment-start-skip	"#[ 	]*"
	comment-end		""))

(defun lisp-mode-hook-code ()
  (setq comment-column 40)		; normal comment column
  (slime-mode t)
  (setq comment-start "\;"))		; and a real comment character

(defun fundamental-mode-hook-code ()	;just so i'll have a comment char.
  (setq comment-column 40
	comment-start "\;"))
  
(defun mail-mode-hook-code ()
  (auto-save-mode nil)			; but i don't like to save copies
  (auto-fill-mode 1)			; i like to auto fill my mail
  (setq fill-column 72))

(add-hook 'mail-setup-hook 'mail-mode-hook-code)

(defun mail-setup-hook-code ()
  (mail-mode-hook-code))
  
(defun text-mode-hook-code ()
  (auto-fill-mode 1)
  (setq fill-column 72))		; i like to auto fill my text

(defun tex-mode-hook-code ()
  (auto-fill-mode 1)
  (setq comment-column 55))	;tex comments all the way to the right.

(defun c++-mode-hook-code ()
  (cond ((string-match "Lucid" emacs-version)
	 (font-lock-mode)))
  (setq comment-column 40 fill-column 79)) ; nothing fancy

(defun c-mode-hook-code ()		; mode hook just sets local var
  (cond ((string-match "Lucid" emacs-version)
	 (font-lock-mode)))
  (setq comment-column 40		;  which is comment-column
	fill-column 79)			;  and the fill-column.  I hate having
  (modify-syntax-entry ?\_ "w")		; underscore is a word constituent!
  (c-set-offset 'block-open 0)
  (setq comment-start-skip "/\\* *")
  (define-key c-mode-map "\e\C-h" 'mark-c-function)
  (define-key c-mode-map "\C-c\C-h" 'mark-c-function))

(defun my-c-mode-common-hook ()
  (c-set-offset 'topmost-intro 4 t)
  (c-set-offset 'ansi-funcdecl-cont 4 t)
  (c-set-style "Stroustrup"))

(defun dired-load-hook-code ()
  (defun dired-insert-headerline (dir)
    (save-excursion
      (cond ((string-match "^/ms" dir)
	     (shell-command (concat "fs la " dir) t))
	    (t (insert "  " (directory-file-name dir) ":\n"))))))

(require 'python)

(defun bf-python-hideshow-forward-sexp-function (arg)
  "Python specific `forward-sexp' function for `hs-minor-mode'.
Argument ARG is ignored."
  arg  ; Shut up, byte compiler.
  (python-nav-end-of-block))

(defun python-mode-hook-code ()
  (auto-complete-mode)
  (add-to-list 'hs-special-modes-alist
	       (list 'python-mode
		     (python-rx block-start)
		     ""
		     "#"
		     'bf-python-hideshow-forward-sexp-function nil))
  (hs-minor-mode)
  (define-key python-mode-map "\C-c\t" 'hs-toggle-hiding)
  (setq python-shell-interpreter
	(cond ((string-equal system-type "darwin") "/opt/local/bin/ipython3")
	      (t "/usr/bin/ipython3"))
	python-shell-interpreter-args ""
	python-shell-prompt-regexp "In \\[[0-9]+\\]: "
	python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
	python-shell-completion-setup-code
	"from IPython.core.completerlib import module_completion"
	python-shell-completion-module-string-code
	"';'.join(module_completion('''%s'''))\n"
	python-shell-completion-string-code
	"';'.join(get_ipython().Completer.all_completions('''%s'''))\n")
  (jedi:ac-setup))

;;; Sun Aug 30 13:48:58 EDT 2020
;;; beginning to convert to elpy
(elpy-enable)

(add-hook 'dired-load-hook 'dired-load-hook-code) 
(add-hook 'text-mode-hook 'text-mode-hook-code)

(add-hook 'mail-setup-hook  'mail-setup-hook-code)
(add-hook 'mail-mode-hook '(mail-mode-hook-code))
(add-hook 'fundamental-mode-hook 'fundamental-mode-hook-code)
(add-hook 'c-mode-hook  'c-mode-hook-code)
(add-hook 'c++-mode-hook 'c++-mode-hook-code)
(add-hook 'shell-mode-hook 'shell-mode-hook-code)
(add-hook 'lisp-mode-hook   'lisp-mode-hook-code)
(add-hook 'outline-mode-hook 'outline-mode-hook-code)
(add-hook 'text-mode-hook   'text-mode-hook-code)
(add-hook 'tex-mode-hook    'tex-mode-hook-code)
(add-hook 'rmail-mode-hook 'rmail-mode-hook-code)
(add-hook 'mh-folder-mode-hook 'mh-folder-mode-hook-code)
(add-hook 'electric-buffer-menu-mode-hook 'electric-buffer-menu-mode-hook-code)
;(add-hook 'font-lock-mode-hook 'font-lock-mode-hook-code)
(add-hook 'python-mode-hook 'python-mode-hook-code)
(setq compile-command nil)

(defun indent-with (start end with)
  "Prefix all lines starting in the region with the string WITH.
Called from a program, takes three arguments, START, END, and WITH."
  (interactive "r\nsString to prevfix with:
")
  (save-excursion
    (goto-char end)
    (setq end (point-marker))
    (goto-char start)
    (or (bolp) (forward-line 1))
    (while (< (point) end)
      (let ((indent (current-indentation)))
	(delete-region (point) (progn (skip-chars-forward " \t") (point)))
	(or (eolp)
	    (insert with)))
      (forward-line 1))
    (move-marker end nil)))


(defun unboldface-buffer ()
  "Remove all boldfacing (overstruck characters) in the region.
Called from program, takes two arguments START and END
which specify the range to operate on."
  (interactive)
  (save-excursion
    (replace-regexp "\\(.\\)\\1\\1" "\\1")))

(setq-default teach-extended-commands-p t)
(setq-default teach-extended-commands-timeout 2)
(setq-default debug-on-error nil)
(setq-default debug-on-quit nil)
(setq-default suggest-key-bindings 2)
(setq suggest-key-bindings 2)
(setq-default buffers-menu-max-size 20)


(setq-default case-replace t
	      zmacs-regions t
	      truncate-lines nil
	      mouse-yank-at-point nil
	      auto-save-interval 1000
	      auto-save-timeout 300
	      font-lock-auto-fontify t
	      font-lock-use-fonts '(or (mono) (grayscale))
	      font-lock-use-colors '(color)
	      font-lock-maximum-decoration t
	      font-lock-maximum-size 256000
	      font-lock-mode-enable-list nil
	      font-lock-mode-disable-list nil
	      org-special-ctrl-a/e t)

(require 'org)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(global-set-key "\C-c\C-l" 'org-store-link)
(global-set-key "\C-c\C-a" 'org-agenda)
(global-set-key "\C-c\C-s" 'org-iswitchb)
(org-defkey org-mode-map "\C-c\C-a" 'org-agenda)
(org-defkey org-mode-map  "\C-c\C-l" 'org-store-link)
(org-defkey org-mode-map "\C-c\C-s" 'org-iswitchb)
(global-font-lock-mode 1)
(defun org-hooks ()
  "hooks for org mode"
  (org-bullets-mode 1)
  (global-set-key "\C-c\C-l" 'org-store-link)
  (global-set-key "\C-c\C-a" 'org-agenda)
  (global-set-key "\C-c\C-s" 'org-iswitchb))

(add-hook 'org-mode-hook 'turn-on-font-lock)  ; Org buffers only
(add-hook 'org-mode-hook 'org-indent-mode)
(add-hook 'org-mode-hook 'org-hooks)
(require 'ox-odt)
(require 'remember)

(setq org-remember-templates
      '(("Todo" ?t "* TODO %?\n    %i\n    %a" "~/Documents/todo.org")
        ("Note" ?n "* %? %T\n    %i" "~/Documents/notes.org")
	("AppleScript remember" ?y "* %:shortdesc\n  %:initial\n   Source: %u, %c\n\n  %?"
	 (concat org-directory "inbox.org") "Remember")
	("AppleScript note" ?z "* %?\n\n  Date: %u\n" (concat org-directory "inbox.org") "Notes")))

(if (equal window-system 'ns) (require 'org-mac-protocol))

;(org-remember-insinuate)
(setq org-directory "~/Google Drive/notes/"
      org-log-done 'time
      org-todo-keywords '((sequence "TODO" "DONE"))
      ;; turns out I use org mostly for personal stuff so there's not a lot of delegation.
      ;; next state for TODO tasks should be DONE, and the rare exception will go to WAIT.
      org-todo-keywords '((sequence "TODO" "DONE" "WAIT(@)"))
      org-archive-location "::* Archived Tasks"
      org-archive-location "~/Google Drive/notes/notes-archive.org::"
      org-export-headline-levels 0	; no headlines, just export as lists
      org-export-with-toc nil		; no table of contents please.
      org-export-with-section-numbers nil
      org-ascii-headline-spacing nil
      org-use-speed-commands t
      org-default-notes-file (concat org-directory "notes.org"))
(define-key global-map "\C-c\C-\\" 'org-remember)

(setq auto-dmacro-alist
      '(("\\.[cly]$" . ctemplate)
	("\\.h$" . htemplate)
	("\\.cc$\\|\\.C$" . cctemplate)
	("\\.H$" . hhtemplate)))

(define-key global-map [?\C-h] 'help-command)
(setq org-tag-alist '(("@jen" . ?j)
		      ("@dhenrich" . ?h)
		      ("@kankotecha" . ?k)
		      ("@heatherberson" . ?b)
		      ("@jonsaxe" . ?s)
		      ("@arvindkc" ?c)
		      ("@colm" ?B)
		      ("@jordyn" ?j)
		      ("@kirachapelle" ?C)
		      ("@nyc" . ?n)))

(require 're-builder)
(setq reb-re-syntax 'string)

(desktop-save-mode t)

(server-start)

(require 'edit-server)
(edit-server-start)
(setenv "GOROOT" (concat homedir "/go"))
(setenv "GOPATH" (concat (getenv "HOME") "/src/gocode"))
(setenv "PATH"
	(concat "/opt/local/bin:"
		(getenv "PATH") ":"
		(concat (getenv "GOPATH") "/bin") ":"
		(concat (getenv "GOROOT") "/bin")))

(setq exec-path (append exec-path (list "/opt/local/bin"
					"/usr/local/bin"
					(expand-file-name "~/go/bin")
					(expand-file-name "~/src/gocode/bin"))))

(if (file-directory-p (expand-file-name "~/homebrew/bin"))
    (setq exec-path (cons (expand-file-name "~/homebrew/bin") exec-path)))

(autoload 'go-mode "go-mode" "\
Major mode for editing Go source text.

This provides basic syntax highlighting for keywords, built-ins,
functions, and some types.  It also provides indentation that is
\(almost) identical to gofmt.

\(fn)" t nil)

(add-to-list 'auto-mode-alist (cons "\\.go$" #'go-mode))

(autoload 'gofmt "go-mode" "\
Pipe the current buffer through the external tool `gofmt`.
Replace the current buffer on success; display errors on failure.

\(fn)" t nil)

(autoload 'gofmt-before-save "go-mode" "\
Add this to .emacs to run gofmt on the current buffer when saving:
 (add-hook 'before-save-hook #'gofmt-before-save)

\(fn)" t nil)

(add-hook 'before-save-hook #'gofmt-before-save)
 
(require 'yasnippet)
(yas-global-mode 1)

(require 'go-autocomplete)
(require 'auto-complete-config)
; (add-to-list 'ac-dictionary-directories "/Applications/Emacs.app/Contents/Resources/site-lisp/ac-dict")
(ac-config-default)
(add-hook 'go-mode-hook 'go-eldoc-setup)

(defun eval-and-replace (value)
  "Evaluate the sexp at point and replace it with its value"
  (interactive (list (eval-last-sexp nil)))
  (kill-sexp -1)
  (insert (format "%S" value)))

(define-key global-map "\C-c\C-e" 'eval-and-replace)

(require 'linum)
(setq frame-background-mode 'dark)
(load-theme 'solarized-dark t)
;;; to swap backquote and escape:
;;; (aset keyboard-translate-table ?\` ?\e)
;;; (aset keyboard-translate-table ?\e ?\`)
;;; to swap ctrl-h and del:
;;; (aset keyboard-translate-table ?\d ?\C-h)
;;; (aset keyboard-translate-table ?\C-h ?\d)
(require 'rainbow-delimiters)
(require 'smartparens-config)
(show-smartparens-global-mode +1)
(setq sp-lisp-modes (cons 'repl sp-lisp-modes)
      sp-smartparens-bindings
      '(("C-M-f" . sp-forward-sexp)
	("C-M-b" . sp-backward-sexp)
	("C-M-d" . sp-down-sexp)
	("C-M-a" . sp-backward-down-sexp)
	("C-S-d" . sp-beginning-of-sexp)
	("C-S-a" . sp-end-of-sexp)
	("C-M-e" . sp-up-sexp)
	("C-M-u" . sp-backward-up-sexp)
	("C-M-n" . sp-next-sexp)
	("C-M-p" . sp-previous-sexp)
	("C-M-k" . sp-kill-sexp)
	("C-M-w" . sp-copy-sexp)
	("C-<delete>" . sp-unwrap-sexp)
	("C-<backspace>" . sp-backward-unwrap-sexp)
	("C-<right>" . sp-forward-slurp-sexp)
	("C-<left>" . sp-forward-barf-sexp)
	("C-M-<left>" . sp-backward-slurp-sexp)
	("C-M-<right>" . sp-backward-barf-sexp)
	("M-D" . sp-splice-sexp)
	("C-M-<delete>" . sp-splice-sexp-killing-forward)
	("C-M-<backspace>" . sp-splice-sexp-killing-backward)
	("C-S-<backspace>" . sp-splice-sexp-killing-around)
	("C-]" . sp-select-next-thing-exchange)
	("C-M-]" . sp-select-next-thing)
	("C-M-SPC" . sp-mark-sexp)
	("M-F" . sp-forward-symbol)
	("M-B" . sp-backward-symbol)))

(sp-use-smartparens-bindings)

(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

(require 'slime)
(add-hook 'slime-mode-hook 'set-up-slime-ac)
(add-hook 'slime-repl-mode-hook 'set-up-slime-ac)

;(unless (and (fboundp 'play-sound-internal)
;             (subrp (symbol-function 'play-sound-internal)))
;  (require 'play-sound))

;;; for ivy, which really screws up on find-file, won't allow creating a new file if there's a fuzzy match!
(setq read-file-name-function
  (lambda (&rest args)
    (let ((completing-read-function #'completing-read-default))
      (apply #'read-file-name-default args))))

(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")


(provide '.emacs)
