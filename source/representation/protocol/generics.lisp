(cl:in-package #:hermetica.representation.protocol)


(defgeneric children (tree-node))
(defgeneric object-class (object-node))
(defgeneric variable-name (free-value-node))
(defgeneric value (constant-node))
(defgeneric slot-name (slot-node))
