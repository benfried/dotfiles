(in-package #:jupyter)

#|

# Representation and manipulation of kernel messages #

|#

#|

## IPython messages ##

|#

(defclass message ()
  ((header
     :initarg :header
     :initform (make-hash-table :test #'equal)
     :accessor message-header)
   (parent-header
     :initarg :parent-header
     :initform (make-hash-table :test #'equal)
     :accessor message-parent-header)
   (identities
     :initarg :identities
     :initform (list (make-uuid t))
     :accessor message-identities)
   (metadata
     :initarg :metadata
     :initform (make-hash-table :test #'equal)
     :accessor message-metadata)
   (content
     :initarg :content
     :initform (make-hash-table :test #'equal)
     :accessor message-content)
   (buffers
     :initarg :buffers
     :initform nil
     :accessor message-buffers))
  (:documentation "Representation of IPython messages"))


(defmethod initialize-instance :after ((instance message) &rest initargs &key &allow-other-keys)
  (let ((buffers (message-buffers instance)))
    (when buffers
      (trivial-garbage:finalize
        instance
        (lambda () (mapcar (lambda (buffer)
                             (static-vectors:free-static-vector buffer))
                           buffers))))))


(defun date-now ()
  (multiple-value-bind (s m h dt mth yr day)
        (get-decoded-time)
        (declare (ignore day))
    (format nil "~4,'0D-~2,'0D-~2,'0DT~2,'0D:~2,'0D:~2,'0DZ" yr mth dt h m s)))

(defun make-message (session-id msg-type content &key metadata buffers parent)
  (if parent
    (let ((hdr (message-header parent))
          (identities (message-identities parent)))
      (make-instance 'message
                     :header `(:object-alist
                                ("msg_id" . ,(make-uuid))
                                ("username" . ,(gethash "username" hdr))
                                ("session" . ,session-id)
                                ("msg_type" . ,msg-type)
                                ("date" . ,(date-now))
                                ("version" . ,+KERNEL-PROTOCOL-VERSION+))
                     :parent-header hdr
                     :identities identities
                     :content content
                     :metadata (or metadata :empty-object)
                     :buffers buffers))
    (make-instance 'message
                   :header `(:object-alist
                              ("msg_id" . ,(make-uuid))
                              ("username" . "")
                              ("session" . ,session-id)
                              ("msg_type" . ,msg-type)
                              ("date" . ,(date-now))
                              ("version" . ,+KERNEL-PROTOCOL-VERSION+))
                   :content content
                   :metadata (or metadata :empty-object)
                   :buffers buffers)))

;; XXX: should be a defconstant but  strings are not EQL-able...
(defvar +IDS-MSG-DELIMITER+ (babel:string-to-octets "<IDS|MSG>"))
(defvar +BODY-LENGTH+ 5)


#|

### Sending and receiving messages ###

|#

(defun send-string-part (ch part)
  (pzmq:send (channel-socket ch) part :sndmore t))

(defun send-binary-part (ch part)
  (let ((len (length part)))
    (cond
      ((typep part '(array single-float *))
        (cffi:with-foreign-array (m part (list :array :float len))
          (pzmq:send (channel-socket ch) m :len (* 4 len) :sndmore t)))
      (t
        (cffi:with-foreign-array (m part (list :array :uint8 len))
          (pzmq:send (channel-socket ch) m :len len :sndmore t))))))

(defun send-parts (ch identities body buffers)
  (with-slots (send-lock socket) ch
    (bordeaux-threads:with-lock-held (send-lock)
      (dolist (part identities)
        (send-binary-part ch part))
      (send-binary-part ch +IDS-MSG-DELIMITER+)
      (dolist (part body)
        (send-string-part ch part))
      (dolist (part buffers)
        (send-binary-part ch part))
      (pzmq:send socket nil))))

(defun message-send (ch msg)
  (with-slots (mac) ch
    (with-slots (identities header parent-header metadata content buffers) msg
      (let* ((*print-pretty* nil)
             (*read-default-float-format* 'double-float)
             (tail (mapcar (lambda (value)
                             (shasht:write-json value nil))
                           (list header parent-header metadata content))))
        (send-parts ch identities
                    (cons (compute-signature mac tail) tail)
                    buffers)))))

(defun more-parts (ch msg)
  (declare (ignore ch))
  (not (zerop (pzmq::%msg-more msg))))

(defun read-binary-part (ch msg)
  (pzmq:msg-recv msg (channel-socket ch))
  (cffi:foreign-array-to-lisp (pzmq:msg-data msg)
                              (list :array :uint8 (pzmq:msg-size msg))
                              ; explicitly defined element type is needed for CLISP
                              :element-type '(unsigned-byte 8)))


(defun read-buffer-part (ch msg)
  (pzmq:msg-recv msg (channel-socket ch))
  (let* ((size (pzmq:msg-size msg))
         (result (static-vectors:make-static-vector size :element-type '(unsigned-byte 8))))
    (static-vectors:replace-foreign-memory (static-vectors:static-vector-pointer result)
                                           (pzmq:msg-data msg)
                                           size)
    result))


(defun read-string-part (ch msg)
  (pzmq:msg-recv msg (channel-socket ch))
  (handler-case
      (cffi:foreign-string-to-lisp (pzmq:msg-data msg)
                                   :count (pzmq:msg-size msg)
                                   :encoding :utf-8)
    (babel-encodings:character-decoding-error ()
      (inform :warn ch "Unable to decode message part.")
      "")))

(defun recv-parts (ch)
  (with-slots (recv-lock) ch
    (bordeaux-threads:with-lock-held (recv-lock)
      (pzmq:with-message msg
        (values
          ; Read the identities first
          (iter
            (for part next (read-binary-part ch msg))
            (until (equalp part +IDS-MSG-DELIMITER+))
            (collect part)
            (unless (more-parts ch msg)
              (inform :warn ch "No identities/message delimiter found in message parts")
              (finish)))
          ; Read the message body
          (iter
            (for i from 1 to +BODY-LENGTH+)
            (unless (more-parts ch msg)
              (inform :warn ch "Incomplete message body.")
              (finish))
            (collect (read-string-part ch msg)))
          ; The remaining parts should be binary buffers
          (iter
            (while (more-parts ch msg))
            (collect (read-buffer-part ch msg))))))))

(defun message-recv (ch)
  (multiple-value-bind (identities body buffers) (recv-parts ch)
    (unless (equal (car body) (compute-signature (channel-mac ch) (cdr body)))
      (inform :warn ch "Signature mismatch on received message."))
    (destructuring-bind (header parent-header metadata content)
                        (let ((*read-default-float-format* 'double-float))
                          (mapcar #'shasht:read-json (cdr body)))
      (make-instance 'message :identities identities
                              :header header
                              :parent-header parent-header
                              :metadata metadata
                              :content content
                              :buffers buffers))))
