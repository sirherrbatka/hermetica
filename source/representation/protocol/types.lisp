(cl:in-package #:hermetica.representation.protocol)


(defclass fundamental-node ()
  ())


(defclass abstract-tree-node (fundamental-node)
  ((%children :initarg :children
              :reader children
              :type list))
  (:default-initargs :children '()))


(defclass fundamental-operator-node (fundamental-node)
  ())


(defclass chain-node (abstract-tree-node)
  ())


(defclass fundamental-boolean-node (fundamental-operator-node
                                    abstract-tree-node)
  ())


(defclass and-node (fundamental-boolean-node)
  ())


(defclass or-node (fundamental-boolean-node)
  ())


(defclass negation-node (fundamental-node)
  ((%inner :initarg :inner
           :reader inner)))


(defclass fundamental-value-node (fundamental-node)
  ())


(defclass constant-node (fundamental-value-node)
  ((%value :initarg :value
           :reader value)))


(defclass free-value-node (fundamental-value-node)
  ((%variable-name :initarg :variable-name
                   :reader variable-name)))


(defclass anonymus-value-node (fundamental-value-node)
  ())


(defclass object-node (abstract-tree-node)
  ((%object-class :initarg :object-class
                  :reader object-class))
  (:default-initargs :object-class (make-instance 'anonymus-variable-node)))


(defclass set-node (abstract-tree-node)
  ())


(defclass fundamental-binary-operator (fundamental-operator-node)
  ((%left :initarg :left
          :reader left)
   (%right :initarg :right
           :reader right)))


(defclass slot-node (fundamental-node)
  ((%slot-reader :initarg :slot-reader
                 :reader slot-reader)
   (%value :initarg :value
           :reader value))
  (:default-initargs :value (make-instance 'anonymus-value-node)))


(defclass in-set-operator (fundamental-binary-operator)
  ())


(defclass equality-operator (fundamental-operator-node abstract-tree-node)
  ())


(defclass fundamental-algebra-operator (fundamental-operator-node
                                        abstract-tree-node)
  ())


(defclass plus-operator (fundamental-algebra-operator)
  ())


(defclass minus-operator (fundamental-algebra-operator)
  ())


(defclass greater-operator (fundamental-operator
                            abstract-tree-node)
  ())


(defclass less-operator (fundamental-operator
                         abstract-tree-node)
  ())


(defclass expression-node (fundamental-node)
  ((%inner :initarg :inner
           :reader inner)))


(defclass recursive-node (abstract-tree-node)
  ((%inner :initarg :inner
           :reader inner))
  (:default-initargs :children nil))


(defclass bind-node (fundamental-node)
  ((%variable-name :initarg :variable-name
                   :reader variable-name)
   (%value :initarg :value
           :reader value)))


(defclass predicate-node (fundamental-node)
  ((%value :initarg :value
           :reader value)))
