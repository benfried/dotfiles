(cl:in-package #:acclimation)

;;; DAY is the ISO8601 day number where the days are numbered from 1
;;; starting on Monday. 
(defgeneric long-day-name (day language))

(defgeneric short-day-name (day language))
