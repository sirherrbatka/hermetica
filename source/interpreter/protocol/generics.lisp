(cl:in-package #:hermetica.interpreter.protocol)


(defgeneric compile-node (node))
(defgeneric generate-code (node))
(defgeneric generate-slot-checking-code (slot-value slot-reader
                                         object-symbol exit-symbol))
(defgeneric generate-slot-value-binding-code (slot-value slot-reader
                                              object-symbol exit-symbol))
(defgeneric generate-class-checking-code (class object-symbol exit-symbol))
(defgeneric generate-class-binding-code (class object-symbol exit-symbol))
(defgeneric generate-value-binding-code (value bind-node))
(defgeneric generate-predicate-code (inner predicate))
