(cl:in-package #:hermetica.interpreter.protocol)

(prove:plan 4)

(bind ((pattern
        (make 'repr:chain-node
              :children (list
                         (make 'repr:object-node
                               :object-class (make 'repr:constant-node :value (find-class 'tested-class1))
                               :children (list (make-instance 'repr:slot-node
                                                              :slot-reader 'test-slot2
                                                              :value (make 'repr:free-value-node
                                                                           :variable-name '?value))))
                         (make 'repr:object-node
                               :object-class (make 'repr:constant-node :value (find-class 'tested-class2))
                               :children (list (make-instance 'repr:slot-node
                                                              :slot-reader 'test-slot1
                                                              :value (make 'repr:free-value-node :variable-name '?value)))))))
       (compiled (compile-node pattern))
       (context (context *testing-sequence-interface*
                         (vector (make 'tested-class1
                                       :test-slot1 1
                                       :test-slot2 2)
                                 (make 'tested-class2
                                       :test-slot1 2
                                       :test-slot2 1))))
       ((:values found list) (funcall compiled context)))
  (prove:ok found)
  (prove:is (length list) 2)
  (prove:is (first list) 0)
  (prove:is (second list) 1))

(prove:finalize)
