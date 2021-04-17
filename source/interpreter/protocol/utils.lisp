(cl:in-package #:hermetica.interpreter.protocol)


(defun constantly-t (&rest all)
  (declare (ignore all))
  (values t '()))
