(cl:in-package #:hermetica.representation.protocol)


(defgeneric children (tree-node))
(defgeneric object-class (object-node))
(defgeneric variable-name (free-value-node))
(defgeneric value (constant-node))
(defgeneric slot-reader (slot-node))
(defgeneric left (binary-operator))
(defgeneric right (binary-operator))
(defgeneric inner (negation-node))
(defgeneric default (free-value-node))
