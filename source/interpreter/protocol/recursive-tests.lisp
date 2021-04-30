(cl:in-package #:hermetica.interpreter.protocol)

(prove:plan 13)

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

(defclass weapon-fire ()
  ((%tick :initarg :tick
          :reader tick)
   (%target :initarg :target
            :reader target)
   (%shooter :initarg :shooter
             :reader shooter)
   (%weapon :initarg :weapon
            :reader weapon)))


(defmethod print-object ((object weapon-fire) stream)
  (print-unreadable-object (object stream)
    (format stream "~a, ~a, ~a" (tick object) (shooter object) (weapon object))))


(defclass garbage ()
  ((%tick :initarg :tick
          :reader tick)))

(bind ((pattern
        (make 'repr:chain-node
              :children (list
                         (make-instance
                          'repr:object-node
                          :object-class (make 'repr:constant-node
                                              :value (find-class 'weapon-fire))
                          :children (list (make-instance
                                           'repr:slot-node
                                           :slot-reader 'tick
                                           :value (make 'repr:free-value-node
                                                        :variable-name '?anchor-tick))
                                          (make-instance
                                           'repr:slot-node
                                           :slot-reader 'weapon
                                           :value (make 'repr:free-value-node
                                                        :variable-name '?weapon))
                                          (make-instance
                                           'repr:slot-node
                                           :slot-reader 'shooter
                                           :value (make 'repr:free-value-node
                                                        :variable-name '?shooter))))
                         (make-instance
                          'repr:optional-node
                          :inner (make-instance
                                  'repr:recursive-node
                                  :children (list)
                                  :inner (make 'repr:chain-node
                                               :children (list (make-instance
                                                                'repr:object-node
                                                                :object-class (make 'repr:constant-node
                                                                                    :value (find-class 'weapon-fire))
                                                                :children (list (make-instance
                                                                                 'repr:slot-node
                                                                                 :slot-reader 'tick
                                                                                 :value (make 'repr:free-value-node
                                                                                              :variable-name '?tick))
                                                                                (make-instance
                                                                                 'repr:slot-node
                                                                                 :slot-reader 'weapon
                                                                                 :value (make 'repr:free-value-node
                                                                                              :variable-name '?weapon))
                                                                                (make-instance
                                                                                 'repr:slot-node
                                                                                 :slot-reader 'shooter
                                                                                 :value (make 'repr:free-value-node
                                                                                              :variable-name '?shooter))))
                                                               (make-instance
                                                                'repr:predicate-node
                                                                :value (make 'repr:expression-node :inner '(< (- ?tick ?anchor-tick) 32)))
                                                               (make-instance
                                                                'repr:bind-node
                                                                :variable-name '?anchor-tick
                                                                :value (make 'repr:expression-node :inner '?tick))
                                                               (make-instance
                                                                'repr:unbind-node
                                                                :variable-name '?tick))))))))
       (compiled (compile-node pattern))
       (vector (vector (make 'garbage :tick 0) ; 0
                       (make 'weapon-fire :tick 15 :shooter "steve" :weapon "AWP") ; 1
                       (make 'garbage :tick 18) ; 2
                       (make 'weapon-fire :tick 20 :shooter "JOSH" :weapon "UMP") ; 3
                       (make 'garbage :tick 20) ; 4
                       (make 'weapon-fire :tick 25 :shooter "JOSH" :weapon "UMP") ; 5
                       (make 'garbage :tick 30) ; 6
                       (make 'weapon-fire :tick 50 :shooter "JOSH" :weapon "UMP") ; 7
                       (make 'weapon-fire :tick 100 :shooter "JOSH" :weapon "UMP"))) ; 8
       (context (context *testing-sequence-interface* vector))
       (context2 (context *testing-sequence-interface* vector :start 2))
       ((:values found list) (funcall compiled context))
       ((:values found2 list2) (funcall compiled context2)))
  (prove:ok found)
  (prove:is list '(1))
  (prove:ok found2)
  (prove:is list2 '(3 5 7)))


(bind ((any-shots
        (make 'repr:optional-node
              :inner (make-instance
                      'repr:recursive-node
                      :children (list)
                      :inner (make 'repr:chain-node
                                   :children (list (make-instance
                                                    'repr:unbind-node
                                                    :variable-name '?tick)
                                                   (make-instance
                                                    'repr:object-node
                                                    :object-class (make 'repr:constant-node
                                                                        :value (find-class 'weapon-fire))
                                                    :children (list (make-instance
                                                                     'repr:slot-node
                                                                     :slot-reader 'tick
                                                                     :value (make 'repr:free-value-node
                                                                                  :variable-name '?tick))
                                                                    (make-instance
                                                                     'repr:slot-node
                                                                     :slot-reader 'weapon
                                                                     :value (make 'repr:free-value-node
                                                                                  :variable-name '?weapon))
                                                                    (make-instance
                                                                     'repr:slot-node
                                                                     :slot-reader 'shooter
                                                                     :value (make 'repr:free-value-node
                                                                                  :variable-name '?shooter))))
                                                   (make-instance
                                                    'repr:bind-node
                                                    :variable-name '?anchor-tick
                                                    :value (make 'repr:free-value-node
                                                                 :variable-name '?anchor-tick
                                                                 :default '?tick))
                                                   (make-instance
                                                    'repr:predicate-node
                                                    :value (make 'repr:expression-node :inner '(< (- ?tick ?anchor-tick) 32)))
                                                   (make-instance 'repr:bind-node
                                                                  :variable-name '?anchor-tick
                                                                  :value (make 'repr:free-value-node
                                                                               :variable-name '?tick)))))))
       (hit (make 'repr:chain-node
                  :children (list (make-instance
                                   'repr:unbind-node
                                   :variable-name '?tick)
                                  (make-instance 'repr:object-node
                                                 :object-class (make 'repr:constant-node
                                                                     :value (find-class 'weapon-fire))
                                                 :children (list (make-instance
                                                                  'repr:slot-node
                                                                  :slot-reader 'tick
                                                                  :value (make 'repr:free-value-node
                                                                               :variable-name '?tick))
                                                                 (make-instance
                                                                  'repr:slot-node
                                                                  :slot-reader 'target
                                                                  :value (make 'repr:anonymus-value-node))
                                                                 (make-instance
                                                                  'repr:slot-node
                                                                  :slot-reader 'weapon
                                                                  :value (make 'repr:free-value-node
                                                                               :variable-name '?weapon))
                                                                 (make-instance
                                                                  'repr:slot-node
                                                                  :slot-reader 'shooter
                                                                  :value (make 'repr:free-value-node
                                                                               :variable-name '?shooter))))
                                  (make-instance
                                   'repr:bind-node
                                   :variable-name '?anchor-tick
                                   :value (make 'repr:free-value-node :variable-name '?anchor-tick
                                                                      :default '?tick))
                                  (make-instance
                                   'repr:predicate-node
                                   :value (make 'repr:expression-node :inner '(< (- ?tick ?anchor-tick) 32)))
                                  (make-instance 'repr:bind-node
                                                 :variable-name '?anchor-tick
                                                 :value (make 'repr:free-value-node :variable-name '?tick)))))
       (pattern (make 'repr:chain-node
                      :children (list any-shots hit any-shots)))
       (compiled (compile-node pattern))
       (vector (vector (make 'garbage :tick 0) ; 0
                       (make 'weapon-fire :tick 15 :shooter "steve" :weapon "AWP") ; 1
                       (make 'garbage :tick 18) ; 2
                       (make 'weapon-fire :tick 20 :shooter "JOSH" :weapon "UMP") ; 3
                       (make 'garbage :tick 20) ; 4
                       (make 'weapon-fire :tick 25 :shooter "JOSH" :weapon "UMP" :target "steve") ; 5
                       (make 'garbage :tick 30) ; 6
                       (make 'weapon-fire :tick 50 :shooter "JOSH" :weapon "UMP") ; 7
                       (make 'weapon-fire :tick 100 :shooter "JOSH" :weapon "UMP"))) ; 8
       (vector2 (vector (make 'garbage :tick 0) ; 0
                        (make 'weapon-fire :tick 15 :shooter "steve" :weapon "AWP") ; 1
                        (make 'garbage :tick 18) ; 2
                        (make 'weapon-fire :tick 20 :shooter "JOSH" :weapon "UMP") ; 3
                        (make 'garbage :tick 20) ; 4
                        (make 'weapon-fire :tick 25 :shooter "JOSH" :weapon "UMP") ; 5
                        (make 'garbage :tick 30) ; 6
                        (make 'weapon-fire :tick 50 :shooter "JOSH" :weapon "UMP") ; 7
                        (make 'weapon-fire :tick 100 :shooter "JOSH" :weapon "UMP"))) ; 8
       (context (context *testing-sequence-interface* vector))
       (context2 (context *testing-sequence-interface* vector2))
       ((:values found list) (funcall compiled context))
       ((:values found2 list2) (funcall compiled context2)))
  (prove:ok (not found2))
  (prove:ok found)
  (prove:is list '(3 5 7)))


(prove:finalize)
