(cl:in-package #:hermetica.interpreter.protocol)


(defclass fundamental-sequence ()
  ())


(defstruct context
  sequence-interface
  sequence
  (start 0 :type fixnum)
  (end 0 :type fixnum)
  (index 0 :type fixnum))
