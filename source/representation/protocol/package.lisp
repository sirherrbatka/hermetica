(cl:defpackage #:hermetica.representation.protocol
  (:use #:cl)
  (:export
   #:fundamental-node
   #:abstract-tree-node
   #:fundamental-operator-node
   #:chain-node
   #:fundamental-boolean-node
   #:and-node
   #:or-node
   #:fundamental-value-node
   #:constant-node
   #:free-value-node
   #:anonymus-value-node
   #:inner
   #:negation-node
   #:expression-node
   #:recursive-node
   #:object-node
   #:bind-node
   #:predicate-node
   #:variable-name
   #:inner
   #:optional-node
   #:set-node
   #:fundamental-binary-operator
   #:slot-node
   #:in-set-operator
   #:equality-operator
   #:fundamental-algebra-operator
   #:plus-operator
   #:minus-operator
   #:greater-operator
   #:less-operator
   #:children
   #:object-class
   #:variable-name
   #:value
   #:slot-reader
   #:left
   #:right
   ))
