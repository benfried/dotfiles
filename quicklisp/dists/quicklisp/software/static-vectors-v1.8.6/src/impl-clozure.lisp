;;;; -*- Mode: Lisp; indent-tabs-mode: nil -*-
;;;
;;; --- ClozureCL implementation
;;;

(in-package :static-vectors)

(declaim (inline fill-foreign-memory))
(defun fill-foreign-memory (pointer length value)
  "Fill LENGTH octets in foreign memory area POINTER with VALUE."
  (#_memset pointer value length)
  pointer)

(declaim (inline replace-foreign-memory))
(defun replace-foreign-memory (dst-ptr src-ptr length)
  "Copy LENGTH octets from foreign memory area SRC-PTR to DST-PTR."
  (#_memcpy dst-ptr src-ptr length)
  dst-ptr)

(declaim (inline %allocate-static-vector))
(defun %allocate-static-vector (length element-type)
  (ccl:make-heap-ivector length element-type))

(declaim (inline static-vector-pointer))
(defun static-vector-pointer (vector &key (offset 0))
  "Return a foreign pointer to the beginning of VECTOR + OFFSET octets.
VECTOR must be a vector created by MAKE-STATIC-VECTOR."
  (check-type offset unsigned-byte)
  (unless (typep vector 'ccl::ivector)
    (ccl::report-bad-arg vector 'ccl::ivector))
  (let ((ptr (null-pointer)))
    (inc-pointer (ccl::%vect-data-to-macptr vector ptr) offset)))

(declaim (inline free-static-vector))
(defun free-static-vector (vector)
  "Free VECTOR, which must be a vector created by MAKE-STATIC-VECTOR."
  (ccl:dispose-heap-ivector vector)
  (values))

(defmacro with-static-vector ((var length &rest args
                               &key (element-type ''(unsigned-byte 8))
                                 initial-contents initial-element)
                              &body body &environment env)
  "Bind PTR-VAR to a static vector of length LENGTH and execute BODY
within its dynamic extent. The vector is freed upon exit."
  (declare (ignorable element-type initial-contents initial-element))
  (multiple-value-bind (real-element-type length type-spec)
      (canonicalize-args env element-type length)
    (remf args :element-type)
    `(let ((,var (make-static-vector ,length ,@args
                                     :element-type ,real-element-type)))
       (declare (type ,type-spec ,var))
       (unwind-protect
            (locally ,@body)
         (when ,var (free-static-vector ,var))))))
