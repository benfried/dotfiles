(in-package :indentify/cli)


(defparameter +command-line-spec+
  '((("outfile" #\o) :type string :optional t :documentation "Write output to file (default stdout)")
    (("replace" #\r) :type boolean :optional t :documentation "Write output in-place, replacing input")
    (("no-defaults") :type boolean :optional t :documentation "Do not load default templates.")
    (("no-user") :type boolean :optional t :documentation "Do not load user templates.")
    (("templates" #\t) :type string :optional t :documentation "Load template file")
    (("help" #\h #\?) :type boolean :optional t :documentation "Print this message and exit.")
    (("version" #\V) :type boolean :optional t :documentation "Print the version and exit.")))


(defun main-handler (files &key outfile help version replace no-defaults no-user templates)
  (unless no-defaults
    (indentify:load-default-templates))
  (when templates
    (indentify:load-template-file templates))
  (unless no-user
    (indentify:load-user-templates))
  (cond
    (help
      (write-line "cl-indentify [OPTION]... [FILE]...")
      (write-line "If no files are given then input is read from stdin.")
      (command-line-arguments:show-option-help +command-line-spec+ :sort-names t))
    (version
      (write-line "0.1"))
    ((and replace files)
      (dolist (file files)
        (let ((result
                (with-output-to-string (output-stream)
                  (with-open-file (input-stream file)
                    (indentify:indentify input-stream output-stream)))))
          (with-open-file (output-stream file :direction :output :if-exists :supersede)
            (write-string result output-stream)))))
    ((and outfile files)
      (with-open-file (output-stream outfile :direction :output :if-exists :supersede)
        (dolist (file files)
          (with-open-file (input-stream file)
            (indentify:indentify input-stream output-stream)))))
    (files
      (dolist (file files)
        (with-open-file (input-stream file)
          (indentify:indentify input-stream))))
    (outfile
      (with-open-file (output-stream outfile :direction :output :if-exists :supersede)
        (indentify:indentify *standard-input* output-stream)))
    (t
      (indentify:indentify))))


(defun main (&rest args)
  (command-line-arguments:handle-command-line
    +command-line-spec+
    #'main-handler
    :command-line args
    :name "cl-indentify"
    :rest-arity t))
