(cl:in-package #:hermetica.interpreter.protocol)


(defun constantly-t (&rest all)
  (declare (ignore all))
  (values t '()))


(defmacro context-quasi-clone (context &rest initargs)
  (once-only (context)
    `(make-context ,@initargs
                   :sequence-interface (context-sequence-interface ,context)
                   :sequence (context-sequence ,context)
                   :start (context-start ,context)
                   :end (context-end ,context))))
