(cl:in-package #:hermetica.interpreter.protocol)


(defclass fundamental-sequence ()
  ())


(defclass interpreter ()
  ((%bound-values :initarg :bound-values
                  :reader bound-values)
   (%undo-trail :initarg :undo-trail
                :reader undo-trail)))
