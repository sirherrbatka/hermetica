(cl:in-package #:hermetica.sequence.protocol)


(define-condition out-of-sequence-bounds (cl-ds:argument-value-out-of-bounds)
  ())
