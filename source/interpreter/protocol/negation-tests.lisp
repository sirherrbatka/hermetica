(cl:in-package #:hermetica.interpreter.protocol)

(prove:plan 6)

(bind ((pattern1 (make 'repr:object-node
                       :object-class (make 'repr:constant-node :value (find-class 'tested-class1))
                       :children (list (make-instance 'repr:slot-node
                                                      :slot-reader 'test-slot2
                                                      :value (make 'repr:free-value-node
                                                                   :variable-name '?value)))))
       (pattern2 (make 'repr:negation-node
                       :inner (make 'repr:object-node
                                    :object-class (make 'repr:constant-node :value (find-class 'tested-class2))
                                    :children (list (make-instance 'repr:slot-node
                                                                   :slot-reader 'test-slot1
                                                                   :value (make 'repr:free-value-node :variable-name '?value))))))
       (pattern3 (make 'repr:object-node
                       :object-class (make 'repr:constant-node :value (find-class 'tested-class1))
                       :children (list (make-instance 'repr:slot-node
                                                      :slot-reader 'test-slot2
                                                      :value (make 'repr:free-value-node
                                                                   :variable-name '?value)))))
       (compiled1 (compile-node pattern1))
       (compiled2 (compile-node pattern2))
       (compiled3 (compile-node pattern3))
       (context (context *testing-sequence-interface*
                         (vector (make 'tested-class1
                                       :test-slot1 1
                                       :test-slot2 2)
                                 (make 'tested-class2
                                       :test-slot1 5
                                       :test-slot2 1)
                                 (make 'tested-class1
                                       :test-slot1 1
                                       :test-slot2 2))))
       ((:values found list) (funcall compiled1 context (rcurry compiled2 compiled3))))
  (prove:ok found)
  (prove:is (length list) 2)
  (prove:is (first list) 0)
  (prove:is (second list) 2))


(bind ((pattern1 (make 'repr:object-node
                       :object-class (make 'repr:constant-node :value (find-class 'tested-class1))
                       :children (list (make-instance 'repr:slot-node
                                                      :slot-reader 'test-slot2
                                                      :value (make 'repr:free-value-node
                                                                   :variable-name '?value)))))
       (pattern2 (make 'repr:negation-node
                       :inner (make 'repr:object-node
                                    :object-class (make 'repr:constant-node :value (find-class 'tested-class2))
                                    :children (list (make-instance 'repr:slot-node
                                                                   :slot-reader 'test-slot1
                                                                   :value (make 'repr:free-value-node :variable-name '?value))))))
       (pattern3 (make 'repr:object-node
                       :object-class (make 'repr:constant-node :value (find-class 'tested-class1))
                       :children (list (make-instance 'repr:slot-node
                                                      :slot-reader 'test-slot2
                                                      :value (make 'repr:free-value-node
                                                                   :variable-name '?value)))))
       (compiled1 (compile-node pattern1))
       (compiled2 (compile-node pattern2))
       (compiled3 (compile-node pattern3))
       (context (context *testing-sequence-interface*
                         (vector (make 'tested-class1
                                       :test-slot1 1
                                       :test-slot2 2)
                                 (make 'tested-class2
                                       :test-slot1 2
                                       :test-slot2 1)
                                 (make 'tested-class1
                                       :test-slot1 1
                                       :test-slot2 2))))
       ((:values found list) (funcall compiled1 context (rcurry compiled2 compiled3))))
  (prove:ok (not found))
  (prove:is (length list) 0))

(prove:finalize)
