(cl:defpackage #:hermetica.representation
  (:use #:cl)
  (:import-from #:hermetica.representation.protocol
                #:chain-node
                #:and-node
                #:or-node
                #:fundamental-value-node
                #:constant-node
                #:free-value-node
                #:anonymus-value-node
                #:object-node
                #:set-node
                #:slot-node
                #:in-set-operator
                #:equality-operator
                #:recursive-node
                #:bind-node
                #:plus-operator
                #:minus-operator
                #:greater-operator
                #:less-operator
                #:negation-node
                #:children
                #:inner
                #:predicate-node
                #:expression-node
                #:object-class
                #:variable-name
                #:value
                #:slot-reader
                #:left
                #:right)
  (:export #:abstract-tree-node
           #:chain-node
           #:and-node
           #:or-node
           #:negation-node
           #:inner
           #:constant-node
           #:free-value-node
           #:anonymus-value-node
           #:object-node
           #:set-node
           #:slot-node
           #:in-set-operator
           #:expression-node
           #:recursive-node
           #:equality-operator
           #:plus-operator
           #:minus-operator
           #:greater-operator
           #:less-operator
           #:children
           #:bind-node
           #:predicate-node
           #:object-class
           #:variable-name
           #:value
           #:slot-reader
           #:left
           #:right))
