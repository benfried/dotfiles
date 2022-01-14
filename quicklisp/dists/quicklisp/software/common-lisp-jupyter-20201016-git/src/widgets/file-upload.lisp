(in-package #:jupyter-widgets)


(defclass file-upload (description-widget button-style-slot disabled-slot icon-slot)
  ((accept
     :initarg :accept
     :initform ""
     :accessor widget-accept
     :documentation "If set, ensure value is in options. Implies continuous_update=False.	File types to accept, empty string for all."
     :trait :unicode)
   (data
     :initarg :data
     :initform nil
     :accessor widget-data
     :documentation "List of file content (bytes)"
     :trait :byte-list)
   (error
     :initarg :error
     :initform ""
     :accessor widget-error
     :documentation "Error message"
     :trait :unicode)
   (metadata
     :initarg :metadata
     :initform nil
     :accessor widget-metadata
     :documentation "List of file metadata"
     :trait :alist-list)
   (multiple
     :initarg :multiple
     :initform nil
     :accessor widget-multiple
     :documentation "If True, allow for multiple files upload"
     :trait :bool))
  (:metaclass trait-metaclass)
  (:default-initargs
    :%model-name "FileUploadModel"
    :%view-name "FileUploadView"))

(register-widget file-upload)


(defmethod widget-value ((instance file-upload))
  (mapcar (lambda (content metadata)
            (acons "content" content (copy-alist metadata)))
          (widget-data instance) (widget-metadata instance)))


(defun file-upload-value-notify (instance)
  (when (and (slot-boundp instance 'data)
             (slot-boundp instance 'metadata)
             (= (length (widget-data instance)) (length (widget-metadata instance)))
             (every (lambda (content metadata)
                      (= (length content) (cdr (assoc "size" metadata :test #'equal))))
                    (widget-data instance) (widget-metadata instance)))
    (jupyter::enqueue *trait-notifications*
                      (list instance :any :value nil (widget-value instance) nil))))


(defmethod on-trait-change :after ((instance file-upload) type (name (eql :data)) old-value new-value source)
  (declare (ignore type name old-value new-value source))
  (file-upload-value-notify instance))


(defmethod on-trait-change :after ((instance file-upload) type (name (eql :metadata)) old-value new-value source)
  (declare (ignore type name old-value new-value source))
  (file-upload-value-notify instance))

