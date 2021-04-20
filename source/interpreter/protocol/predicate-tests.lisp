(cl:in-package #:hermetica.interpreter.protocol)

(prove:plan 6)

(bind ((pattern1 (make-instance
                  'repr:object-node
                  :object-class (make 'repr:constant-node :value (find-class 'tested-class2))
                  :children (list
                             (make-instance 'repr:slot-node
                                            :slot-reader 'test-slot2
                                            :value (make-instance 'repr:free-value-node
                                                                  :variable-name 'test-slot2)))))
       (pattern2 (make-instance
                  'repr:and-node
                  :children (list (make-instance 'repr:predicate-node
                                                 :value (make 'repr:expression-node
                                                              :inner '(= test-slot2 2))))))
       (compiled1 (compile-node pattern1))
       (compiled2 (compile-node pattern2))
       (context (context *testing-sequence-interface*
                         (vector (make 'tested-class2
                                       :test-slot1 1
                                       :test-slot2 2)
                                 (make 'tested-class2
                                       :test-slot1 1
                                       :test-slot2 2))))
       ((:values found list) (funcall compiled1 context compiled2)))
  (prove:ok found)
  (prove:is (length list) 1)
  (prove:is (first list) 0))

(bind ((pattern1 (make-instance
                  'repr:object-node
                  :object-class (make 'repr:constant-node :value (find-class 'tested-class2))
                  :children (list
                             (make-instance 'repr:slot-node
                                            :slot-reader 'test-slot2
                                            :value (make-instance 'repr:free-value-node
                                                                  :variable-name 'test-slot2)))))
       (pattern2 (make-instance
                  'repr:and-node
                  :children (list (make-instance 'repr:predicate-node
                                                 :value (make 'repr:expression-node
                                                              :inner '(= test-slot2 2))))))
       (compiled1 (compile-node pattern1))
       (compiled2 (compile-node pattern2))
       (context (context *testing-sequence-interface*
                         (vector (make 'tested-class2
                                       :test-slot1 1
                                       :test-slot2 0)
                                 (make 'tested-class2
                                       :test-slot1 1
                                       :test-slot2 2))))
       ((:values found list) (funcall compiled1 context compiled2)))
  (prove:ok found)
  (prove:is (length list) 1)
  (prove:is (first list) 1))

(prove:finalize)
