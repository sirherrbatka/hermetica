(cl:in-package #:hermetica.interpreter.protocol)


(defgeneric bound-values (interpreter))
(defgeneric undo-trail (interpreter))
(defgeneric scan (node sequence interpreter))
(defgeneric value-bound-p (value-node interpreter))
(defgeneric value (value-node interpreter))
