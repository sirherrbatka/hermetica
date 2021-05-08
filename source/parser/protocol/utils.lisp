(cl:in-package #:hermetica.parser.protocol)


(defpackage #:hermetica.parser.protocol.generated-symbols)


(defun make-variable-name (symbol-name)
  (~> symbol-name
      string-upcase
      (intern (find-package :hermetica.parser.protocol.generated-symbols))))
