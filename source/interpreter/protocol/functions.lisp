(cl:in-package #:hermetica.interpreter.protocol)


(defun match (context compiled-tree)
  (funcall compiled-tree context #'constantly-t))


(defun start (context)
  (let ((interface (context-sequence-interface context))
        (sequence (context-sequence context))
        (start (context-start context)))
    (max start (seq:start interface sequence))))


(defun end (context)
  (let ((interface (context-sequence-interface context))
        (sequence (context-sequence context))
        (end (context-end context)))
    (min end (seq:end interface sequence))))


(defun at (context index)
  (let ((interface (context-sequence-interface context))
        (sequence (context-sequence context)))
    (seq:at interface sequence index)))


(defun context (interface sequence
                &key
                  (start (seq:start interface sequence))
                  (end (seq:end interface sequence)))
  (make-context
   :sequence-interface interface
   :sequence sequence
   :start start
   :end end))
