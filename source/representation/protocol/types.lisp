(cl:in-package #:hermetica.representation.protocol)


(defclass fundamental-node ()
  ())


(defclass fundamental-leaf-node (fundamental-node)
  ())


(defclass fundamental-tree-node (fundamental-node)
  ((%children :initarg :children
              :reader children
              :type list))
  (:initarg :children '()))


(defclass fundamental-operator-node (fundamental-tree-node)
  ())


(defclass chain-node (fundamental-operator-node)
  ())


(defclass fundamental-boolean-node (fundamental-operator-node)
  ())


(defclass and-node (fundamental-boolean-node)
  ())


(defclass or-node (fundamental-boolean-node)
  ())


(defclass fundamental-value-node (fundamental-leaf-node)
  ())


(defclass constant-node (fundamental-value-node)
  ((%value :initarg :value
           :reader value)))


(defclass free-value-node (fundamental-value-node)
  ((%variable-name :initarg :variable-name
                   :reader variable-name)))


(defclass anonymus-value-node (fundamental-value-node)
  ())


(defclass object-node (fundamental-tree-node)
  ((%object-class :initarg :object-class
                  :reader object-class))
  (:default-initargs :object-class (make-instance 'anonymus-variable-node)))


(defclass set-node (fundamental-tree-node)
  ())


(defclass fundamental-binary-operator (fundamental-operator-node)
  ())


(defclass slot-node (fundamental-leaf-node)
  ((%slot-name :initarg :slot-name
               :reader slot-name)
   (%value :initarg :value
           :reader value)))


(defclass in-set-operator (fundamental-binary-operator)
  ())


(defclass equality-operator (fundamental-operator-node)
  ())


(defclass fundamental-algebra-operator (fundamental-operator-node)
  ())


(defclass plus-operator (fundamental-algebra-operator)
  ())


(defclass minus-operator (fundamental-algebra-operator)
  ())


(defclass greater-operator (fundamental-operator)
  ())


(defclass less-operator (fundamental-operator)
  ())
