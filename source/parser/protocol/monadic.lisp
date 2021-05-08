(cl:in-package #:hermetica.parser.protocol)


(defun ?special-character ()
  (maxpc:?satisfies (rcurry #'member '(#\, #\|))))


(defun ?word-character ()
  (maxpc:?satisfies (alexandria:conjoin
                     (compose #'not #'serapeum:whitespacep)
                     (compose #'not (rcurry #'member '(#\, #\|))))))


(defun =word ()
  (maxpc:=subseq (maxpc:%some (?word-character))))


(defun =constant-value ()
  (maxpc:=destructure (value) (maxpc:=list (=word))
    (make-instance 'repr:constant-node :value value)))


(defun =free-value ()
  (maxpc:%or
   (maxpc:=destructure (_ variable-name _ default)
                       (maxpc:=list (maxpc:?eq #\?)
                                    (=word)
                                    (maxpc:?eq #\|)
                                    (=value))
     (make-instance 'repr:free-value-node
                    :variable-name (make-variable-name variable-name)
                    :default default))
   (maxpc:=destructure (_ variable-name)
                       (maxpc:=list (maxpc:?eq #\?)
                                    (=word))
     (make-instance 'repr:free-value-node
                    :variable-name (make-variable-name variable-name)))))


(defun =value ()
  (maxpc:%or '=free-value/parser
             (=constant-value)))


(setf (fdefinition '=free-value/parser) (=free-value))
