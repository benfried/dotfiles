(cl:in-package #:eclector.base)

(defun %reader-error (stream datum
                      &rest arguments
                      &key
                      (stream-position (ignore-errors (file-position stream)))
                      &allow-other-keys)
  (apply #'error datum :stream stream :stream-position stream-position
         (alexandria:remove-from-plist arguments :stream-position)))

(defgeneric recovery-description (strategy &key language)
  (:method ((strategy t) &key (language (acclimation:language
                                         acclimation:*locale*)))
    (recovery-description-using-language strategy language)))

(defgeneric recovery-description-using-language (strategy language))

(defun format-recovery-report (stream strategy &rest args)
  (labels ((resolve (report)
             (etypecase report
               (symbol (resolve (recovery-description strategy)))
               (string (apply #'format stream report args))
               (function (apply report stream args)))))
    (resolve strategy)))

(defun %recoverable-reader-error (stream datum &rest arguments
                                               &key report &allow-other-keys)
  (restart-case
      (apply #'%reader-error stream datum
             (alexandria:remove-from-plist arguments :report))
    (recover ()
      :report (lambda (stream)
                (format-recovery-report stream report))
      (values))))

(defun recover (&optional condition)
  (alexandria:when-let ((restart (find-restart 'recover condition)))
    (invoke-restart restart)))

(define-condition stream-position-condition (condition)
  ((%stream-position :initarg :stream-position
                     :reader stream-position)))

(define-condition stream-position-reader-error (acclimation:condition
                                                stream-position-condition
                                                reader-error)
  ())

;;; Adds a stream position to CL:END-OF-FILE.
(define-condition end-of-file (acclimation:condition
                               stream-position-condition
                               cl:end-of-file)
  ())

(define-condition incomplete-construct (stream-position-reader-error)
  ())

(define-condition missing-delimiter (end-of-file incomplete-construct)
  ((%delimiter :initarg :delimiter :reader delimiter)))
