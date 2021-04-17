(cl:in-package #:hermetica.interpreter.protocol)

(prove:plan 12)

(defclass tested-class2 ()
  ((%test-slot1 :initarg :test-slot1
                :reader test-slot1)
   (%test-slot2 :initarg :test-slot2
                :reader test-slot2)))

(defclass tested-class1 ()
  ((%test-slot1 :initarg :test-slot1
                :reader test-slot1)
   (%test-slot2 :initarg :test-slot2
                :reader test-slot2)))

(defclass testing-sequence-interface ()
  ())

(defmethod seq:at ((interface testing-sequence-interface)
                   vector
                   index)
  (aref vector index))

(defmethod seq:start ((interface testing-sequence-interface)
                      vector)
  0)

(defmethod seq:end ((interface testing-sequence-interface)
                    vector)
  (length vector))

(defparameter *testing-sequence-interface*
  (make 'testing-sequence-interface))

(bind ((pattern (make-instance 'repr:object-node
                               :object-class (make 'repr:anonymus-value-node)
                               :children (list (make-instance 'repr:slot-node
                                                              :slot-reader 'test-slot1
                                                              :value (make 'repr:constant-node :value 1)))))
       (compiled (compile-node pattern))
       (context (context *testing-sequence-interface*
                         (vector (make 'tested-class1
                                       :test-slot1 1
                                       :test-slot2 2))))
       ((:values found list) (funcall compiled context)))
  (prove:ok found)
  (prove:is (length list) 1)
  (prove:is (first list) 0))

(bind ((pattern (make-instance 'repr:object-node
                               :object-class (make 'repr:constant-node :value (find-class 'tested-class2))
                               :children (list (make-instance 'repr:slot-node
                                                              :slot-reader 'test-slot2
                                                              :value (make 'repr:constant-node :value 2)))))
       (compiled (compile-node pattern))
       (context (context *testing-sequence-interface*
                         (vector (make 'tested-class1
                                       :test-slot1 1
                                       :test-slot2 2)
                                 (make 'tested-class2
                                       :test-slot1 1
                                       :test-slot2 2))))
       ((:values found list) (funcall compiled context)))
  (prove:ok found)
  (prove:is (length list) 1)
  (prove:is (first list) 1))

(bind ((pattern1 (make-instance 'repr:object-node
                                :object-class (make 'repr:constant-node :value (find-class 'tested-class1))
                                :children (list (make-instance 'repr:slot-node
                                                               :slot-reader 'test-slot2
                                                               :value (make 'repr:free-value-node
                                                                            :variable-name '?value)))))
       (pattern2 (make-instance 'repr:object-node
                                :object-class (make 'repr:constant-node :value (find-class 'tested-class2))
                                :children (list (make-instance 'repr:slot-node
                                                               :slot-reader 'test-slot2
                                                               :value (make 'repr:free-value-node
                                                                            :variable-name '?value)))))
       (compiled1 (compile-node pattern1))
       (compiled2 (compile-node pattern2))
       (context (context *testing-sequence-interface*
                         (vector (make 'tested-class1
                                       :test-slot1 1
                                       :test-slot2 2)
                                 (make 'tested-class2
                                       :test-slot1 1
                                       :test-slot2 2))))
       ((:values found list) (funcall compiled1 context compiled2)))
  (prove:ok found)
  (prove:is (length list) 2)
  (prove:is (first list) 0)
  (prove:is (second list) 1))


(bind ((pattern1 (make-instance 'repr:object-node
                                :object-class (make 'repr:constant-node :value (find-class 'tested-class1))
                                :children (list (make-instance 'repr:slot-node
                                                               :slot-reader 'test-slot2
                                                               :value (make 'repr:free-value-node
                                                                            :variable-name '?value)))))
       (pattern2 (make-instance 'repr:object-node
                                :object-class (make 'repr:constant-node :value (find-class 'tested-class2))
                                :children (list (make-instance 'repr:slot-node
                                                               :slot-reader 'test-slot2
                                                               :value (make 'repr:constant-node
                                                                            :value -1)))))
       (compiled1 (compile-node pattern1))
       (compiled2 (compile-node pattern2))
       (context (context *testing-sequence-interface*
                         (vector (make 'tested-class1
                                       :test-slot1 1
                                       :test-slot2 2)
                                 (make 'tested-class2
                                       :test-slot1 1
                                       :test-slot2 2))))
       ((:values found list) (funcall compiled1 context compiled2)))
  (prove:ok (not found))
  (prove:is (length list) 0))

(prove:finalize)
