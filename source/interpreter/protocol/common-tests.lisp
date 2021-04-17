(cl:in-package #:hermetica.interpreter.protocol)

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
