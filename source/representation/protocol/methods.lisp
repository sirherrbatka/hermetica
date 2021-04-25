(cl:in-package #:hermetica.representation.protocol)


(defmethod default ((node free-value-node))
  (if (slot-boundp node '%default)
      (values (read-default node) t)
      (values nil nil)))


(defmethod default ((node fundamental-value-node))
  (values nil nil))
