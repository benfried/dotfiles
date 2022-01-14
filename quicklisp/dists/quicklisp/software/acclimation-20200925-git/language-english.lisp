(cl:in-package #:acclimation)

(defclass english (language)
  ())

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Methods on LONG-DAY-NAME.

(defmethod long-day-name ((day (eql 1)) (language english))
  "Monday")

(defmethod long-day-name ((day (eql 2)) (language english))
  "Tuesday")

(defmethod long-day-name ((day (eql 3)) (language english))
  "Wednesday")

(defmethod long-day-name ((day (eql 4)) (language english))
  "Thursday")

(defmethod long-day-name ((day (eql 5)) (language english))
  "Friday")

(defmethod long-day-name ((day (eql 6)) (language english))
  "Saturday")

(defmethod long-day-name ((day (eql 7)) (language english))
  "Sunday")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Methods on SHORT-DAY-NAME.

(defmethod short-day-name ((day (eql 1)) (language english))
  "Mon")

(defmethod short-day-name ((day (eql 2)) (language english))
  "Tue")

(defmethod short-day-name ((day (eql 3)) (language english))
  "Wed")

(defmethod short-day-name ((day (eql 4)) (language english))
  "Thu")

(defmethod short-day-name ((day (eql 5)) (language english))
  "Fri")

(defmethod short-day-name ((day (eql 6)) (language english))
  "Sat")

(defmethod short-day-name ((day (eql 7)) (language english))
  "Sun")
