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
  (with-gensyms (!context !next !n)
    (bind ((content (repr:children node))
           ((:labels impl (nodes))
            (if (endp nodes)
                !next
                `(lambda (,!context)
                   (let ((,!n ,(generate-code (first nodes))))
                     (if (null ,!n)
                         (values t '())
                         (funcall ,!n
                                  ,!context
                                  ,(~> nodes rest impl))))))))
      `(lambda (,!context &optional ,!next)
         (funcall ,(impl content) ,!context)))))


(defun ignore-warning (condition)
  (declare (ignore condition))
  (muffle-warning))


(defmacro with-default (node reader object)
  `(handler-case (,reader ,object)
     (unbound-slot (e)
       (bind (((:values default-value present) (repr:default ,node)))
         (if present
             default-value
             (error e))))))
