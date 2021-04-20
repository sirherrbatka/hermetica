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


(defun generate-code/and-chain (node)
  (with-gensyms (!context !next)
    (bind ((content (repr:children node))
           ((:labels impl (nodes))
            (if (endp nodes)
                `(lambda (c &optional (n #'constantly-t))
                   (funcall ,!next c n))
                `(lambda (,!context &optional (,!next #'constantly-t))
                   (funcall ,(generate-code (first nodes))
                            ,!context
                            ,(~> nodes rest impl))))))
      (impl content))))


(defun ignore-warning (condition)
  (declare (ignore condition))
  (muffle-warning))
