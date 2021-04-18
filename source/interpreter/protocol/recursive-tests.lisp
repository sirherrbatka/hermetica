(cl:in-package #:hermetica.interpreter.protocol)

(prove:plan 6)

(bind ((pattern (make-instance
                 'repr:recursive-node
                 :inner (make-instance 'repr:object-node
                                       :object-class (make 'repr:anonymus-value-node)
                                       :children (list (make-instance 'repr:slot-node
                                                                      :slot-reader 'test-slot1
                                                                      :value (make 'repr:constant-node :value 1))))))
       (compiled (compile-node pattern))
       (context (context *testing-sequence-interface*
                         (vector (make 'tested-class1
                                       :test-slot1 1
                                       :test-slot2 2)
                                 (make 'tested-class1
                                       :test-slot1 1
                                       :test-slot2 2)
                                 (make 'tested-class1
                                       :test-slot1 1
                                       :test-slot2 2)
                                 (make 'tested-class1))))
       ((:values found list) (funcall compiled context)))
  (prove:ok found)
  (prove:is (length list) 3)
  (prove:is list '(0 1 2)))


(bind ((pattern (make-instance
                 'repr:recursive-node
                 :children (list (make 'repr:bind-node
                                       :variable-name '?i
                                       :value (make 'repr:expression-node :inner '(1+ ?i))))
                 :inner (make-instance 'repr:object-node
                                       :object-class (make 'repr:anonymus-value-node)
                                       :children (list (make-instance 'repr:slot-node
                                                                      :slot-reader 'test-slot1
                                                                      :value (make 'repr:free-value-node
                                                                                   :variable-name '?i))))))
       (compiled (compile-node pattern))
       (context (context *testing-sequence-interface*
                         (vector (make 'tested-class1
                                       :test-slot1 0
                                       :test-slot2 2)
                                 (make 'tested-class1
                                       :test-slot1 1
                                       :test-slot2 2)
                                 (make 'tested-class1
                                       :test-slot1 2
                                       :test-slot2 2)
                                 (make 'tested-class1))))
       ((:values found list) (funcall compiled context)))
  (prove:ok found)
  (prove:is (length list) 3)
  (prove:is list '(0 1 2)))

(prove:finalize)
