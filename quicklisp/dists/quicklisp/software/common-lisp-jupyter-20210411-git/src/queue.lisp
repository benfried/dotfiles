(in-package #:jupyter)

(defclass queue ()
  ((head-cons
     :initform nil)
   (tail-cons
     :initform nil)
   (access-lock
     :initform (bordeaux-threads:make-lock (make-uuid)))
   (not-empty-condition
     :initform (bordeaux-threads:make-condition-variable :name (make-uuid)))))

(defun enqueue (queue item &key high-priority)
  (with-slots (head-cons tail-cons access-lock not-empty-condition) queue
    (bordeaux-threads:with-lock-held (access-lock)
      (if high-priority
        (progn
          (push item head-cons)
          (unless tail-cons
            (setf tail-cons head-cons)
            (bordeaux-threads:condition-notify not-empty-condition)))
        (let ((old-tail-cons tail-cons))
          (setf tail-cons (list item))
          (if old-tail-cons
            (rplacd old-tail-cons tail-cons)
            (progn
              (setf head-cons tail-cons)
              (bordeaux-threads:condition-notify not-empty-condition))))))))

(defun dequeue (queue)
  (with-slots (head-cons tail-cons access-lock not-empty-condition) queue
    (bordeaux-threads:with-lock-held (access-lock)
      (prog1
        (do ()
            (head-cons (pop head-cons))
          (bordeaux-threads:condition-wait not-empty-condition access-lock))
        (unless head-cons
          (setf tail-cons nil))))))

(defun queue-empty-p (queue)
  (with-slots (head-cons access-lock) queue
    (bordeaux-threads:with-lock-held (access-lock)
      (null head-cons))))

