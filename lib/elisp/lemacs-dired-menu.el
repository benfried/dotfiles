13-Aug-92 15:19:47-GMT,5968;000000000001
Return-Path: <help-lucid-emacs-request@lucid.com>
Received: from lucid.com by banzai.cc.columbia.edu (5.59/FCB)
	id AA18871; Thu, 13 Aug 92 11:19:44 EDT
Received: from rodan.UU.NET by heavens-gate.lucid.com id AA19828g; Thu, 13 Aug 92 08:03:44 PDT
Received: from help-lucid-emacs@lucid.com (list exploder) by rodan.UU.NET 
	(5.61/UUNET-mail-drop) id AA22336; Thu, 13 Aug 92 11:14:03 -0400
Received: from news.UU.NET by rodan.UU.NET with SMTP 
	(5.61/UUNET-mail-drop) id AA22332; Thu, 13 Aug 92 11:13:58 -0400
Path: uunet!mcsun!corton!loria!news.loria.fr!bosch
From: bosch%loria.fr@lucid.com (Guido Bosch)
Newsgroups: alt.lucid-emacs.help
Subject: Re: Could someone send an example of a nested menu (submenu)?
Message-Id: <BOSCH.92Aug13170300@moebius.loria.fr>
Date: 13 Aug 92 15:03:00 GMT
References: <9208122109.AA11807@pts4.pts.mot.com>
Organization: INRIA-Lorraine / CRIN, Nancy, France
Lines: 151
In-Reply-To: ex594bw@pts.mot.com's message of 12 Aug 92 21:09:34 GMT
Sender: help-lucid-emacs-request@lucid.com
To: help-lucid-emacs@lucid.com

In article <9208122109.AA11807@pts4.pts.mot.com> ex594bw@pts.mot.com ( BOB WEINER X2087 P7489) writes:

 > The doc I've seen says one can nest menus but does not show
 > the precise syntax.  The 'add-menu-item' code doc does not help either.
 > A basic example would get me going.

Try this: It's the beginning of a dired mode menu I'm currently
experiencing with. But I don't find it perfect yet.
Maybe sombody wants to improve it ... 


(defun dired-menu (e)
  (interactive "@e")
  (popup-menu dired-menu))

(define-key dired-mode-map 'button3 'dired-menu)

(setq dired-menu
      '("Dired"
	["Next Line" dired-next-line t]
	["Previous Line" dired-previous-line t]


	("Listing Files"
	 ["Sort Toggle Or Edit" dired-sort-toggle-or-edit t]
	 ["Redisplay" dired-do-redisplay t]
	 ["Revert Buffer" revert-buffer t]
	 ["Kill Line Or Subdir" dired-kill-line-or-subdir t]
	 ["Kill" dired-do-kill t]
	 )

	("Marking Files"
	 ["Mark Subdir Or File" dired-mark-subdir-or-file t]
	 ["Unmark Subdir Or File" dired-unmark-subdir-or-file t]
	 ["Backup Unflag" dired-backup-unflag t]
	 ["Unflag All Files" dired-unflag-all-files t]
	 ["Mark Executables" dired-mark-executables t]
	 ["Mark Symlinks" dired-mark-symlinks t]
	 ["Mark Directories" dired-mark-directories t]
	 ["Mark Rcs Files" dired-mark-rcs-files t]
	 ["Mark Sexp" dired-mark-sexp t]
	 ["Mark Files Regexp" dired-mark-files-regexp t]
	 ["Next Marked File" dired-next-marked-file t]
	 ["Prev Marked File" dired-prev-marked-file t]
	 )

	("Deleting Files With Dired"
	 ["Flag File Deleted" dired-flag-file-deleted t]
	 ["Flag Regexp Files" dired-flag-regexp-files t]
	 ["Do Deletions" dired-do-deletions t]
	 ["Do Delete" dired-do-delete t]
	 ["Flag Auto Save Files" dired-flag-auto-save-files t]
	 ["Flag Backup Files" dired-flag-backup-files t]
	 ["Clean Directory" dired-clean-directory t])

	("Dired Shell Commands"
	 
	 ["Shell Command" dired-do-shell-command t]
	 ["Do Background Shell Command" dired-do-background-shell-command t]
	 ["Compress" dired-do-compress t]
	 ["Uncompress" dired-do-uncompress t]
	 "----"
	 ["Chmod" dired-do-chmod t]
	 ["Chgrp" dired-do-chgrp t]
	 ["Chown" dired-do-chown t]
	 "----"
	 ["Load" dired-do-load t]
	 ["Do Byte Compile" dired-do-byte-compile t]
	 ["Byte Compile And Load" dired-do-byte-compile-and-load t]
	 "----"
	 ["Print" dired-do-print t])

	("Mark-using Commands"
	 "Copy and Move Into a Directory"
	 ["Copy Regexp" dired-do-copy-regexp t]
	 ["Move" dired-do-move t]
	 ["Hardlink Regexp" dired-do-hardlink-regexp t]
	 ["Symlink Regexp" dired-do-symlink-regexp t]
	 "-----"
	 "Renaming and More With Regexps"
	 ["Rename Regexp" dired-do-rename-regexp t]
	 "----"
	 "Other File Creating Commands"
	 ["Upcase" dired-upcase t]
	 ["Downcase" dired-downcase t])

	("Commands That Do Not Use Marks"
	 ["Find File" dired-find-file t]
	 ["Advertised Find File" dired-advertised-find-file t]
	 ["Find File Other Window" dired-find-file-other-window t]
	 ["View File" dired-view-file t]
	 ["Diff" dired-diff t]
	 ["Backup Diff" dired-backup-diff t]
	 ["Create Directory" dired-create-directory t]
	 ["Why" dired-why t])

	("Subdirectories in Dired"
	 ["Insert Subdir" dired-do-insert-subdir t]
	 ["Insert Subdir Inline" dired-insert-subdir-inline t]
	 ["Maybe Insert Subdir" dired-maybe-insert-subdir t]
	 ["Next Subdir" dired-next-subdir t]
	 ["Prev Subdir" dired-prev-subdir t]
	 ["Goto Subdir" dired-goto-subdir t]
	 ["Prev Dirline" dired-prev-dirline t]
	 ["Next Dirline" dired-next-dirline t]
	 ["Up Directory" dired-up-directory t]
	 )

	("Hiding Directories in Dired"
	 ["Hide Subdir" dired-hide-subdir t]
	 ["Hide All" dired-hide-all t])

	["Undo" dired-undo t]
	["Quit" dired-quit t]
	))



; Commands not yet inserted.
; 
;["Do Relsymlink Regexp" dired-do-relsymlink-regexp t]
;["Set Marker Char" dired-set-marker-char t]
;["Restore Marker Char" dired-restore-marker-char t]
;["Summary" dired-summary t]
;["Do Find File" dired-do-find-file t]
;["Do Hardlink" dired-do-hardlink t]
;["Do Relsymlink" dired-do-relsymlink t]
;["Do Toggle" dired-do-toggle t]
;["Vm" dired-vm t]
;["Do Symlink" dired-do-symlink t]
;["Mark With This Char" dired-mark-with-this-char t]
;["Do Copy" dired-do-copy t]
;["Describe Mode" describe-mode t]
;["Copy Filename As Kill" dired-copy-filename-as-kill t]
;["Smart Shell Command" dired-smart-shell-command t]
;["Tree Up" dired-tree-up t]
;["Tree Down" dired-tree-down t]
;["Goto File" dired-goto-file t]
;["Do Unmark" dired-do-unmark t]
;["Smart Background Shell Command" dired-smart-background-shell-command t]
;["Omit Toggle" dired-omit-toggle t]
;
--
Guido BOSCH, INRIA-Lorraine/CRIN
Institut National de Recherche en Informatique et en Automatique (INRIA)
Centre de Recherche en Informatique de Nancy (CRIN)
Campus scientifique, B.P. 239            
54506 Vandoeuvre-les-Nancy CEDEX       	
Tel.: (+33) 83.91.24.24
Fax.: (+33) 83.41.30.79                	
email: bosch@loria.fr             	

