(in-package :shasht)


(declaim #+(or)(optimize (speed 3) (safety 0))
         (inline make-newline-strine)
         (ftype (function (t t t stream) t) print-json-key-value)
         (ftype (function (string stream) string) write-json-string))


(defparameter *delimiter* nil)
(defparameter *next-delimiter* nil)
(defparameter *write-indent-level* 0)
(defparameter *terminator* nil)
(defparameter *next-terminator* nil)


(defun write-json-string (value output-stream)
  "Write value as a JSON string to stream specified by output-stream."
  (write-char #\" output-stream)
  (do ((index 0 (1+ index)))
      ((>= index (length value)))
    (let* ((ch (char value index))
           (code (char-code ch)))
      (cond
        ((char= ch #\newline)
          (write-string "\\n" output-stream))
        ((char= ch #\return)
          (write-string "\\r" output-stream))
        ((char= ch #\tab)
          (write-string "\\t" output-stream))
        ((char= ch #\page)
          (write-string "\\f" output-stream))
        ((char= ch #\backspace)
          (write-string "\\b" output-stream))
        ((char= ch #\")
          (write-string "\\\"" output-stream))
        ((char= ch #\\)
          (write-string "\\\\" output-stream))
        ((not (graphic-char-p ch))
          (format output-stream "\\u~4,'0x" code))
        ((or (not *write-ascii-encoding*)
             (ascii-printable-p code))
          (write-char ch output-stream))
        ((supplementary-plane-p code)
          (format output-stream "\\u~4,'0x\\u~4,'0x"
                  (+ (ash (- code #x10000) -10)
                     #xd800)
                  (+ (logand (- code #x10000)
                             (- (ash 1 10) 1))
                     #xdc00)))
        (t
          (format output-stream "\\u~4,'0x" code)))))
  (write-char #\" output-stream)
  value)


(defun make-newline-string ()
  (when *print-pretty*
    (apply 'concatenate 'string (list #\newline)
           (make-list *write-indent-level* :initial-element *write-indent-string*))))


(defmacro with-json-array (output-stream &body body)
  "Enable JSON array writing for body. Array open/close and commas will be automatically
handled when calls to print-json-value are made."
  `(let* ((*terminator* "]")
          (*next-terminator* (concatenate 'string (make-newline-string) "]"))
          (*write-indent-level* (1+ *write-indent-level*))
          (*delimiter* (make-newline-string))
          (*next-delimiter* (concatenate 'string "," *delimiter*)))
     (declare (type (or null string) *delimiter* *next-delimiter*))
     (write-char #\[ ,output-stream)
     (locally ,@body)
     (write-string *terminator* ,output-stream)))


(defmacro with-json-object (output-stream &body body)
  "Enable JSON object writing for body. Object open/close and commas will be automatically
handled when calls to print-json-key-value are made."
  `(let* ((*terminator* "}")
          (*next-terminator* (concatenate 'string (make-newline-string) "}"))
          (*write-indent-level* (1+ *write-indent-level*))
          (*delimiter* (make-newline-string))
          (*next-delimiter* (concatenate 'string "," *delimiter*)))
     (declare (type (or null string) *delimiter* *next-delimiter*))
     (write-char #\{ ,output-stream)
     (locally ,@body)
     (write-string *terminator* ,output-stream)))


(defgeneric print-json-value (value output-stream)
  (:documentation "Print a JSON value to output-stream. Used by write-json to dispatch based on type."))


(defmacro with-json-key ((key output-stream) &body body)
  `(progn
     (print-json-value ,key ,output-stream)
     (let ((*delimiter* (if *print-pretty*
                          ": "
                          ":")))
       ,@body)))


(defgeneric print-json-key-value (object key value output-stream)
  (:documentation "Print a JSON key value. Must be used inside of with-json-object.")
  (:method (object key value output-stream)
    (declare (ignore object))
    (print-json-value key output-stream)
    (let ((*delimiter* (if *print-pretty*
                         ": "
                         ":")))
      (print-json-value value output-stream))))


(defun print-json-delimiter (output-stream)
  (when *delimiter*
    (write-string *delimiter* output-stream))
  (setf *delimiter* *next-delimiter*)
  (setf *terminator* *next-terminator*))


(defmethod print-json-value :before (value output-stream)
  (declare (ignore value))
  (print-json-delimiter output-stream))


(defmethod print-json-value ((value number) output-stream)
  (let* ((result (format nil "~,,,,,,'eE" value))
         (decimal-position (position #\. result)))
    (write-string (cond
                    ((not decimal-position)
                      result)
                    ((= (1+ decimal-position) (length result))
                      (subseq result 0 (1- (length result))))
                    ((char= #\e (char result (1+ decimal-position)))
                      (concatenate 'string (subseq result 0 decimal-position)
                                   (subseq result (1+ decimal-position))))
                    (t
                      result))
                  output-stream))
  value)


(defmethod print-json-value ((value integer) output-stream)
  (prin1 value output-stream))


(defmethod print-json-value ((value string) output-stream)
  (write-json-string value output-stream))


(defmethod print-json-value ((value hash-table) output-stream)
  (with-json-object output-stream
    (maphash (lambda (key val)
               (print-json-key-value value key val output-stream))
             value))
  value)


(defmethod print-json-value ((value list) output-stream)
  (cond
    ((eql :object-alist (car value))
      (with-json-object output-stream
        (trivial-do:doalist (k v (cdr value))
          (print-json-key-value value k v output-stream))))
    ((eql :object-plist (car value))
      (with-json-object output-stream
        (trivial-do:doplist (k v (cdr value))
          (print-json-key-value value k v output-stream))))
    ((eql :array (car value))
      (with-json-array output-stream
        (dolist (element (cdr value))
          (print-json-value element output-stream))))
    ((and *write-alist-as-object*
          (alistp value))
      (with-json-object output-stream
        (trivial-do:doalist (k v value)
          (print-json-key-value value k v output-stream))))
    ((and *write-plist-as-object*
          (plistp value))
      (with-json-object output-stream
        (trivial-do:doplist (k v value)
          (print-json-key-value value k v output-stream))))
    (t
      (with-json-array output-stream
        (dolist (element value)
          (print-json-value element output-stream)))))
  value)


(defmethod print-json-value ((value vector) output-stream)
  (with-json-array output-stream
    (dotimes (position (length value))
      (print-json-value (elt value position) output-stream)))
  value)


(defmethod print-json-value ((value symbol) output-stream)
  (cond
    ((member value *write-true-values* :test #'eql)
      (write-string "true" output-stream))
    ((member value *write-false-values* :test #'eql)
      (write-string "false" output-stream))
    ((member value *write-null-values* :test #'eql)
      (write-string "null" output-stream))
    ((or (and (null value)
              (or *write-alist-as-object*
                  *write-plist-as-object*))
         (member value *write-empty-object-values* :test #'eql))
      (write-string "{}" output-stream))
    ((or (null value)
         (member value *write-empty-array-values* :test #'eql))
      (write-string "[]" output-stream))
    (t
      (write-json-string (funcall *symbol-name-function* value)
                         output-stream)))
  value)


(defmethod print-json-value ((value pathname) output-stream)
  (write-json-string (namestring value) output-stream)
  value)


(defun print-json-mop (value output-stream)
  (with-json-object output-stream
    (dolist (def (closer-mop:class-slots (class-of value)) value)
      (let ((slot-name (closer-mop:slot-definition-name def)))
        (when (slot-boundp value slot-name)
          (let* ((slot-value (slot-value value slot-name))
                 (slot-type (closer-mop:slot-definition-type def))
                 (list-type-p (subtypep 'list slot-type))
                 (null-type-p (subtypep 'null slot-type))
                 (boolean-type-p (subtypep 'boolean slot-type)))
            (print-json-key-value value
                                  slot-name
                                  (cond
                                    (slot-value
                                      slot-value)
                                    ((and null-type-p
                                          (not list-type-p)
                                          (not boolean-type-p))
                                      :null)
                                    ((and list-type-p
                                          (not boolean-type-p))
                                      :empty-array)
                                    (t
                                      :false))
                                  output-stream))))))
  value)


(defmethod print-json-value ((value standard-object) output-stream)
  (print-json-mop value output-stream))


(defmethod print-json-value ((value structure-object) output-stream)
  (print-json-mop value output-stream))


(defun write-json (value &optional (output-stream t))
"Write a JSON value. Writing is influenced by the dynamic variables
*write-ascii-encoding*, *write-true-values*,  *write-false-values*,
*write-null-values*, *write-alist-as-object*,  *write-plist-as-object*,
*write-indent-string* and common-lisp:*print-pretty*.

The following arguments also control the behavior of the write.

* value - The value to be written.
* output-stream - a stream or nil to return a string or t to use
  *standard-output*."
  (if (null output-stream)
    (with-output-to-string (output-stream)
      (print-json-value value output-stream))
    (print-json-value value (if (eql t output-stream)
                               *standard-output*
                               output-stream))))


(defun write-json* (value &key (stream t) ascii-encoding (true-values '(t :true))
                               (false-values '(nil :false)) (null-values '(:null))
                               (empty-array-values '(:empty-array))
                               (empty-object-values '(:empty-object)) alist-as-object
                               plist-as-object pretty (indent-string "  "))
"Write a JSON value. Writing is not influenced by the dynamic variables
of write-json.

The following arguments also control the behavior of the write.

* value - The value to be written.
* stream - a stream or nil to return a string or t to use
  *standard-output*.
* ascii-encoding - If true then any non ASCII values will be encoded
  using Unicode escape sequences.
* true-values - Values that will be written as a true token.
* false-values - Values that will be written as a false token.
* null-values - Values that will be written as a null token.
* empty-array-values - Values that will be written as an empty array.
* empty-object-values - Values that will be written as an empty object.
* alist-as-object - If true then assocation lists will be written as an object.
* plist-as-object - If true then property lists will be written as an object.
* pretty - Use indentation in printing.
* indent-string - The string to use when indenting objects and arrays."
  (let ((*write-ascii-encoding* ascii-encoding)
        (*write-true-values* true-values)
        (*write-false-values* false-values)
        (*write-null-values* null-values)
        (*write-empty-array-values* empty-array-values)
        (*write-empty-object-values* empty-object-values)
        (*write-alist-as-object* alist-as-object)
        (*write-plist-as-object* plist-as-object)
        (*write-indent-string* indent-string)
        (*print-pretty* pretty))
    (write-json value stream)))

