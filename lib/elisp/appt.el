Article 78 of gnu.emacs.sources:
Path: cunixf.cc.columbia.edu!rutgers!tut.cis.ohio-state.edu!JULIET.LL.MIT.EDU!neilm
From: neilm@JULIET.LL.MIT.EDU
Newsgroups: gnu.emacs.sources
Subject: appt.el v2.1
Message-ID: <9011301704.AA00953@horatio>
Date: 30 Nov 90 17:04:35 GMT
Sender: daemon@tut.cis.ohio-state.edu
Distribution: gnu
Organization: Source only  Discussion and requests in gnu.emacs.help.
Lines: 552




        This  is the latest   version  of  appt.el.  It  has  been
        modified  to  work with  Reingold's latest  calendar/diary
        release.  This  version   will ONLY work  with the  latest
        calendar/diary package. So make  sure  you have the latest
        versions of both packages.
        

        There is one significant change you MUST make. Instead of
        setting list-diary-entries-hook to include appt-make-list,
        you should set diary-display-hook. So include the following
        line (or a variation) in your .emacs file:

(setq diary-display-hook (list 'appt-make-list 'fancy-diary-display))

        Another  change   is   the  addition  of   the    variable
        appt-display-diary.   If it is non-nil,   then at midnight
        when the daily  appointments list  gets updated to the new
        day's list, the diary will be displayed in a buffer.



        Neil Mager

==========================
Net                     <neilm@juliet.ll.mit.edu>
Voice                   (617) 981-4803
MIT Lincoln Labs        Lexington, MA



;; Appointment notification functions.
;; Copyright (C) 1989, 1990 Free Software Foundation, Inc.

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 1, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;
;; appt.el - visible and/or audible notification of
;;           appointments from ~/diary file generated from
;;           Edward M. Reingold's calendar.el.
;;
;; Version 2.1
;;
;; Comments, corrections, and improvements should be sent to
;; Neil M. Mager
;; Net                     <neilm@juliet.ll.mit.edu>
;; Voice                   (617) 981-4803
;;;
;;; Thanks to  Edward M. Reingold for much help and many suggestions, 
;;; And to many others for bug fixes and suggestions.
;;;
;;;
;;; This functions in this file will alert the user of a 
;;; pending appointment based on their diary file.
;;;
;;;
;;; ******* It is necessary to invoke 'display-time' ********
;;; *******  and 'diary' for this to work properly.  ********
;;; 
;;; A message will be displayed in the mode line of the emacs buffer
;;; and (if the user desires) the terminal will beep and display a message
;;; from the diary in the mini-buffer, or the user may select to 
;;; have a message displayed in a new buffer.
;;;
;;; The variable 'appt-message-warning-time' allows the
;;; user to specify how much notice they want before the appointment. The 
;;; variable 'appt-issue-message' specifies whether the user wants
;;; to to be notified of a pending appointment.
;;; 
;;; In order to use, the following should be in your .emacs file in addition to
;;; creating a diary file and invoking calendar:
;;;
;;;    Set some options
;;; (setq view-diary-entries-initially t)
;;; (setq appt-issue-message t)
;;;
;;;   The following three lines are required:
;;; (display-time)
;;; (autoload 'appt-make-list "appt.el" nil t)
;;; (setq diary-display-hook 
;;;     (list 'appt-make-list 'prepare-fancy-diary-buffer))
;;;
;;; 
;;;  This is an example of what can be in your diary file:
;;; Monday
;;;   9:30am Coffee break
;;;  12:00pm Lunch        
;;; 
;;; Based upon the above lines in your .emacs and diary files, 
;;; the calendar and diary will be displayed when you enter
;;; emacs and your appointments list will automatically be created.
;;; You will then be reminded at 9:20am about your coffee break
;;; and at 11:50am to go to lunch. 
;;;
;;; Use describe-function on appt-check for a description of other variables
;;; that can be used to personalize the notification system.
;;;
;;;  In order to add or delete items from todays list, use appt-add
;;;  and appt-delete.
;;;
;;;  Additionally, the appointments list is recreated automatically
;;;  at 12:01am for those who do not logout every day or are programming
;;;  late.
;;;
;;; Brief internal description - Skip this if your not interested!
;;;
;;; The function appt-check is run from the 'loadst' process which is started
;;; by invoking (display-time). A temporary function below modifies
;;; display-time-filter 
;;; (from original time.el) to include a hook which will invoke appt-check.
;;; This will not be necessary in the next version of gnuemacs.
;;;
;;;
;;; The function appt-make-list creates the appointments list which appt-check
;;; reads. This is all done automatically.
;;; It is invoked from the function list-diary-entries.
;;;
(defvar appt-issue-message t
  "*Non-nil means check for appointments in the diary buffer.
To be detected, the diary entry must have the time
as the first thing on a line.")

(defvar appt-message-warning-time 10
  "*Time in minutes before an appointment that the warning begins.")

(defvar appt-audible t
  "*Non-nil means beep to indicate appointment.")

(defvar appt-visible t
  "*Non-nil means display appointment message in echo area.")

(defvar appt-display-mode-line t
  "*Non-nil means display minutes to appointment and time on the mode line.")

(defvar appt-msg-window t
  "*Non-nil means display appointment message in another window.")

(defvar appt-display-duration 5
  "*The number of seconds an appointment message is displayed.")

(defvar appt-display-diary t
  "*Non-nil means to display the next days diary on the screen. 
This will occur at midnight when the appointment list is updated.")

(defvar appt-time-msg-list nil
  "The list of appointments for today.
Use `appt-add' and `appt-delete' to add and delete appointments from list.
The original list is generated from the today's `diary-entries-list'.
The number before each time/message is the time in minutes from midnight.")

(defconst max-time 1439
  "11:59pm in minutes - number of minutes in a day minus 1.")

(defun appt-check ()
  "Check for an appointment and update the mode line.
Note: the time must be the first thing in the line in the diary
for a warning to be issued.

The format of the time can be either 24 hour or am/pm.
Example: 

               02/23/89
                 18:00 Dinner
            
              Thursday
                11:45am Lunch meeting.

The following variables control the action of the notification:

appt-issue-message
        If T, the diary buffer is checked for appointments.

appt-message-warning-time
       Variable used to determine if appointment message
        should be displayed.

appt-audible
        Variable used to determine if appointment is audible.
        Default is t.

appt-visible
        Variable used to determine if appointment message should be
        displayed in the mini-buffer. Default is t.

appt-msg-window
       Variable used to determine if appointment message
       should temporarily appear in another window. Mutually exclusive
       to appt-visible.

appt-display-duration
      The number of seconds an appointment message
      is displayed in another window.

This function is run from the loadst process for display time.
Therefore, you need to have (display-time) in your .emacs file."


  (let ((min-to-app -1)
        (new-time ""))
    (save-excursion
      
      ;; Get the current time and convert it to minutes
      ;; from midnight. ie. 12:01am = 1, midnight = 0.
      
      (let* ((cur-hour(string-to-int 
                       (substring (current-time-string) 11 13)))
             (cur-min (string-to-int 
                       (substring (current-time-string) 14 16)))
             (cur-comp-time (+ (* cur-hour 60) cur-min)))
        
        ;; If the time is 12:01am, we should update our 
        ;; appointments to todays list.

        (if (= cur-comp-time 1)
            (if (and view-diary-entries-initially appt-display-diary)
                (diary)
              (let ((diary-display-hook 'appt-make-list))
                (diary))))
        
        ;; If there are entries in the list, and the
        ;; user wants a message issued
        ;; get the first time off of the list
        ;; and calculate the number of minutes until
        ;; the appointment.
        
        (if (and appt-issue-message appt-time-msg-list)
            (let ((appt-comp-time (car (car (car appt-time-msg-list)))))
              (setq min-to-app (- appt-comp-time cur-comp-time))
              
              (while (and appt-time-msg-list 
                          (< appt-comp-time cur-comp-time))
                (setq appt-time-msg-list (cdr appt-time-msg-list)) 
                (if appt-time-msg-list
                    (setq appt-comp-time 
                          (car (car (car appt-time-msg-list))))))
              
              ;; If we have an appointment between midnight and
              ;; 'appt-message-warning-time' minutes after midnight,
              ;; we must begin to issue a message before midnight.
              ;; Midnight is considered 0 minutes and 11:59pm is
              ;; 1439 minutes. Therefore we must recalculate the minutes
              ;; to appointment variable. It is equal to the number of 
              ;; minutes before midnight plus the number of 
              ;; minutes after midnight our appointment is.
              
              (if (and (< appt-comp-time appt-message-warning-time)
                       (> (+ cur-comp-time appt-message-warning-time)
                          max-time))
                  (setq min-to-app (+ (- (1+ max-time) cur-comp-time))
                        appt-comp-time))
              
              ;; issue warning if the appointment time is 
              ;; within appt-message-warning time
              
              (if (and (<= min-to-app appt-message-warning-time)
                       (>= min-to-app 0))
                  (progn
                    (if appt-msg-window
                        (progn
                          (string-match
                           "[0-9]?[0-9]:[0-9][0-9]\\(am\\|pm\\)?" 
                           display-time-string)
                          
                          (setq new-time (substring display-time-string 
                                                    (match-beginning 0)
                                                    (match-end 0)))
                          (appt-disp-window min-to-app new-time
                                            (car (cdr (car appt-time-msg-list)))))
                      ;;; else
                      
                      (if appt-visible
                          (message "%s" 
                                   (car (cdr (car appt-time-msg-list)))))
                      
                      (if appt-audible
                          (beep 1)))
                    
                    (if appt-display-mode-line
                        (progn
                          (string-match
                           "[0-9]?[0-9]:[0-9][0-9]\\(am\\|pm\\)?" 
                           display-time-string)
                          
                          (setq new-time (substring display-time-string 
                                                    (match-beginning 0)
                                                    (match-end 0)))
                          (setq display-time-string
                                (concat  "App't in "
                                         min-to-app " min. " new-time " "))
                          
                          ;; force mode line updates - from time.el
                          
                          (save-excursion (set-buffer (other-buffer)))
                          (set-buffer-modified-p (buffer-modified-p))
                          (sit-for 0)))
                    
                    (if (= min-to-app 0)
                        (setq appt-time-msg-list
                              (cdr appt-time-msg-list)))))))))))


;; Display appointment message in a separate buffer.
(defun appt-disp-window (min-to-app new-time appt-msg)
  (require 'electric)
  (save-window-excursion

    ;; Make sure we're not in the minibuffer
    ;; before splitting the window.

    (if (= (screen-height)
           (nth 3 (window-edges (selected-window))))
        nil
      (appt-select-lowest-window)
      (split-window))

    (let* ((this-buffer (current-buffer))
           (appt-disp-buf (set-buffer (get-buffer-create "appt-buf"))))
      (setq mode-line-format 
            (concat "-------------------- Appointment in "
                    min-to-app " minutes. " new-time " %-"))
      (pop-to-buffer appt-disp-buf)
      (insert-string appt-msg)
      (shrink-window-if-larger-than-buffer (get-buffer-window appt-disp-buf))
      (set-buffer-modified-p nil)
      (if appt-audible
          (beep 1))
      (sit-for appt-display-duration)
      (if appt-audible
          (beep 1))
      (kill-buffer appt-disp-buf))))

;; Select the lowest window on the screen.
(defun appt-select-lowest-window ()
  (setq lowest-window (selected-window))
  (let* ((bottom-edge (car (cdr (cdr (cdr (window-edges))))))
         (last-window (previous-window))
         (window-search t))
    (while window-search
      (let* ((this-window (next-window))
             (next-bottom-edge (car (cdr (cdr (cdr 
                                               (window-edges this-window)))))))
        (if (< bottom-edge next-bottom-edge)
            (progn
              (setq bottom-edge next-bottom-edge)
              (setq lowest-window this-window)))

        (select-window this-window)
        (if (eq last-window this-window)
            (progn
              (select-window lowest-window)
              (setq window-search nil)))))))


(defun appt-add (new-appt-time new-appt-msg)
  "Add an appointment for the day at TIME and issue MESSAGE.
The time should be in either 24 hour format or am/pm format."

  (interactive "sTime (hh:mm[am/pm]): \nsMessage: ")
  (if (string-match "[0-9]?[0-9]:[0-9][0-9]\\(am\\|pm\\)?" new-appt-time)
      nil
    (error "Unacceptable time-string"))
  
  (let* ((appt-time-string (concat new-appt-time " " new-appt-msg))
         (appt-time (list (appt-convert-time new-appt-time)))
         (time-msg (cons appt-time (list appt-time-string))))
    (setq appt-time-msg-list (append appt-time-msg-list
                                     (list time-msg)))
    (setq appt-time-msg-list (appt-sort-list appt-time-msg-list)))) 


(defun appt-delete ()
  "Delete an appointment from the list of appointments."
  (interactive)
  (let* ((tmp-msg-list appt-time-msg-list))
    (while tmp-msg-list
      (let* ((element (car tmp-msg-list))
             (prompt-string (concat "Delete " 
                                    (prin1-to-string (car (cdr element))) 
                                    " from list? "))
             (test-input (y-or-n-p prompt-string)))
        (setq tmp-msg-list (cdr tmp-msg-list))
        (if test-input
            (setq appt-time-msg-list (delq element appt-time-msg-list)))
        (setq tmp-appt-msg-list nil)))
    (message "")))
                 

;; Create the appointments list from todays diary buffer.
;; The time must be at the beginning of a line for it to be
;; put in the appointments list.
;;                02/23/89
;;                  12:00pm lunch
;;                 Wednesday
;;                   10:00am group meeting"

(defun appt-make-list ()
  (setq appt-time-msg-list nil)

  (save-excursion
    (fix-time)
    (if diary-entries-list

        ;; Cycle through the entry-list (diary-entries-list)
        ;; looking for entries beginning with a time. If 
        ;; the entry begins with a time, add it to the
        ;; appt-time-msg-list. Then sort the list.
        
        (let ((entry-list diary-entries-list)
              (new-time-string ""))
          (while (and entry-list 
                      (calendar-date-equal 
                       (calendar-current-date) (car (car entry-list))))
            (let ((time-string (substring (prin1-to-string 
                                           (cdr (car entry-list))) 2 -2)))
              
              (while (string-match
                      "[0-9]?[0-9]:[0-9][0-9]\\(am\\|pm\\)?.*" 
                      time-string)
                (let* ((appt-time-string (substring time-string
                                                    (match-beginning 0)
                                                    (match-end 0))))

                  (if (< (match-end 0) (length time-string))
                      (setq new-time-string (substring time-string 
                                                       (+ (match-end 0) 1)
                                                       nil))
                    (setq new-time-string ""))
                  
                  (string-match "[0-9]?[0-9]:[0-9][0-9]\\(am\\|pm\\)?"
                                time-string)
                    
                  (let* ((appt-time (list (appt-convert-time 
                                           (substring time-string
                                                      (match-beginning 0)
                                                      (match-end 0)))))
                         (time-msg (cons appt-time
                                         (list appt-time-string))))
                    (setq time-string new-time-string)
                    (setq appt-time-msg-list (append appt-time-msg-list
                                                     (list time-msg)))))))
            (setq entry-list (cdr entry-list)))))
  (setq appt-time-msg-list (appt-sort-list appt-time-msg-list))

  ;; Get the current time and convert it to minutes
  ;; from midnight. ie. 12:01am = 1, midnight = 0,
  ;; so that the elements in the list
  ;; that are earlier than the present time can
  ;; be removed.
  
  (let* ((cur-hour(string-to-int 
                   (substring (current-time-string) 11 13)))
         (cur-min (string-to-int 
                   (substring (current-time-string) 14 16)))
         (cur-comp-time (+ (* cur-hour 60) cur-min))
         (appt-comp-time (car (car (car appt-time-msg-list)))))

    (while (and appt-time-msg-list (< appt-comp-time cur-comp-time))
      (setq appt-time-msg-list (cdr appt-time-msg-list)) 
      (if appt-time-msg-list
          (setq appt-comp-time (car (car (car appt-time-msg-list)))))))))
  

;;Simple sort to put the appointments list in order.
;;Scan the list for the smallest element left in the list.
;;Append the smallest element left into the new list, and remove
;;it from the original list.
(defun appt-sort-list (appt-list)
  (let ((order-list nil))
    (while appt-list
      (let* ((element (car appt-list))
             (element-time (car (car element)))
             (tmp-list (cdr appt-list)))
        (while tmp-list
          (if (< element-time (car (car (car tmp-list))))
              nil
            (setq element (car tmp-list))
            (setq element-time (car (car element))))
          (setq tmp-list (cdr tmp-list)))
        (setq order-list (append order-list (list element)))
        (setq appt-list (delq element appt-list))))
    order-list))


(defun appt-convert-time (time2conv)
  "Convert hour:min[am/pm] format to minutes from midnight."

  (let ((conv-time 0)
        (hr 0)
        (min 0))

    (string-match ":[0-9][0-9]" time2conv)
    (setq min (string-to-int 
               (substring time2conv 
                          (+ (match-beginning 0) 1) (match-end 0))))
  
    (string-match "[0-9]?[0-9]:" time2conv)
    (setq hr (string-to-int 
              (substring time2conv 
                         (match-beginning 0)
                         (match-end 0))))
  
    ;; convert the time appointment time into 24 hour time
  
    (if (and (string-match  "[p][m]" time2conv) (< hr 12))
        (progn
          (string-match "[0-9]?[0-9]:" time2conv)
          (setq hr (+ 12 hr))))
  
    ;; convert the actual time
    ;; into minutes for comparison
    ;; against the actual time.
  
    (setq conv-time (+ (* hr 60) min))
    conv-time))


(defvar display-time-hook nil
  "* List of functions to be called when the time is updated on the 
mode line.")

(setq display-time-hook 'appt-check)

(defvar display-time-filter-initialized nil)

(defun fix-time()
  (if display-time-filter-initialized;; only do this stuff once!
      nil
      (fset 'old-display-time-filter;; we're about to redefine it...
	    (symbol-function 'display-time-filter))
      (setq display-time-filter-initialized t)
      (fset 'display-time-filter
	    (function
	     (lambda (proc string);; ...here's the revised definition
	       "Revised version of the original function: this version calls a hook."
	       (old-display-time-filter proc string)
	       (run-hooks 'display-time-hook))))))


