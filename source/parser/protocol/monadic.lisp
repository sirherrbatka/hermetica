(cl:in-package #:hermetica.parser.protocol)


(defparameter *special-characters* '(#\, #\| #\! #\? #\: #\} #\{))


(defun special-character-p (character)
  (member character *special-characters*))


(defun ?special-character ()
  (maxpc:?satisfies #'special-character-p))


(defun ?word-character ()
  (maxpc:?satisfies (alexandria:conjoin
                     (complement #'serapeum:whitespacep)
                     (complement #'special-character-p))))


(defun =word ()
  (maxpc:=subseq (maxpc:%some (?word-character))))


(defun =constant-value ()
  (maxpc:=destructure (value) (maxpc:=list (=word))
    (make-instance 'repr:constant-node :value (parse-word value))))


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


(defun =anonymus-value ()
  (maxpc:=destructure (_) (maxpc:=list (maxpc:?eq #\?))
    (make-instance 'repr:anonymus-value-node)))


(defun =value ()
  (maxpc:%or '=free-value/parser
             (=constant-value)))


(defun =padding ()
  (maxpc:%any (maxpc:?satisfies #'serapeum:whitespacep)))


(defun =slot ()
  (maxpc:=destructure (_ reader _ _ value _)
                      (maxpc:=list (maxpc:%maybe (=padding))
                                   (=word)
                                   (maxpc:?eq #\:)
                                   (maxpc:%maybe (=padding))
                                   (maxpc:%or (=value)
                                              (=anonymus-value))
                                   (maxpc:%maybe (=padding)))
    (make-instance 'repr:slot-node
                   :slot-reader (make-variable-name reader)
                   :value value)))


(defun =slots ()
  (maxpc:%any (=slot)))


(defun =object ()
  (maxpc:=destructure (class _ slots _)
                      (maxpc:=list
                       (maxpc:%or (=value)
                                  (=anonymus-value))
                       (maxpc:?eq #\{)
                       (maxpc:%maybe (=slots))
                       (maxpc:?eq #\}))
    (make-instance 'repr:object-node
                   :object-class class
                   :children slots)))


(setf (fdefinition '=free-value/parser) (=free-value))
