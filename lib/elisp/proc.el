(defun proc (procname proctype)
  "make a C procedure"
  (interactive "sFunction Name: \nsType: ")
  (goto-char (point-max))
  (insert-string "\n")
  (insert proctype "\n" procname "( )\n{")
  (newline-and-indent)
  (insert "pushfunc(\"" procname "\");")
  (newline-and-indent)
  (insert "popfunc(\"" procname "\");\n}"))
