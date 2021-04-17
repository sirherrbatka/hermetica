(cl:in-package #:hermetica.interpreter.protocol)


(defmethod compile-node ((node hermetica.representation.protocol:fundamental-node))
  (compile nil (generate-code node)))


;; This code only deals with the class and slot variable binding
(defmethod generate-code ((node repr:object-node))
  (alexandria:with-gensyms (!context
                            !next !object !block
                            !index !start !end
                            !check)
    (let ((slots (repr:children node))
          (class (repr:object-class node)))
      `(lambda (,!context &optional (,!next #'constantly-t))
         (block ,!block
           (flet ((,!check (,!index &aux (,!object (at ,!context ,!index)))
                    ,(generate-class-binding-code class !object !block)
                    ,@(iterate
                        (for slot in slots)
                        (for slot-reader = (repr:slot-reader slot))
                        (for slot-value = (repr:value slot))
                        (for validation-code = (generate-slot-checking-code slot-value slot-reader
                                                                            !object !block))
                        (when (null validation-code) (next-iteration))
                        (collect validation-code))
                    (nest ,@(if-let ((code (generate-class-binding-code class !object !block)))
                              (list code)
                              nil)
                          ,@(iterate
                              (for slot in slots)
                              (for slot-reader = (repr:slot-reader slot))
                              (for slot-value = (repr:value slot))
                              (for binding-code = (generate-slot-value-binding-code slot-value slot-reader
                                                                                    !object !block))
                              (when (null binding-code) (next-iteration))
                              (collect binding-code))
                          (bind (((:values result positions)
                                  (progn (setf (context-start ,!context) (1+ ,!index))
                                         (funcall ,!next ,!context))))
                            (return-from ,!block
                              (if result
                                  (values t (cons ,!index positions))
                                  (values nil '())))))))
             (iterate
               (with ,!start = (start ,!context))
               (with ,!end = (end ,!context))
               (for ,!index from ,!start below ,!end)
               (,!check ,!index))))))))


(defmethod generate-slot-checking-code ((slot-value repr:anonymus-value-node)
                                        slot-reader
                                        object-symbol
                                        exit-symbol)
  `(handler-case (,slot-reader ,object-symbol)
     (unbound-slot (e)
       (return-from ,exit-symbol (values nil '())))))


(defmethod generate-slot-checking-code ((slot-value repr:constant-node)
                                        slot-reader
                                        object-symbol
                                        exit-symbol)
  `(handler-case (unless (equal ,(repr:value slot-value) (,slot-reader ,object-symbol))
                   (return-from ,exit-symbol (values nil '())))
     (unbound-slot (e)
       (return-from ,exit-symbol (values nil '())))))


(defmethod generate-slot-checking-code ((slot-value repr:free-value-node)
                                        slot-reader
                                        object-symbol
                                        exit-symbol)
  `(handler-case (if (boundp ',(repr:variable-name slot-value))
                     (locally (declare special ,(repr:variable-name slot-value))
                       (unless (equal ,(repr:value slot-value) (,slot-reader ,object-symbol))
                         (return-from ,exit-symbol (values nil '()))))
                     nil)
     (unbound-slot (e)
       (return-from ,exit-symbol (values nil '())))))


(defmethod generate-slot-value-binding-code ((slot-value repr:free-value-node)
                                             slot-reader
                                             object-symbol
                                             exit-symbol)
  `(let ((,(repr:variable-name slot-value) (,slot-reader ,object-symbol)))
     (declare (special ,(repr:variable-name slot-value)))))


(defmethod generate-slot-value-binding-code ((slot-value repr:constant-node)
                                             slot-reader
                                             object-symbol
                                             exit-symbol)
  nil)


(defmethod generate-slot-value-binding-code ((slot-value repr:anonymus-value-node)
                                             slot-reader
                                             object-symbol
                                             exit-symbol)
  nil)


(defmethod generate-class-checking-code ((slot-value repr:anonymus-value-node)
                                         object-symbol
                                         exit-symbol)
  nil)


(defmethod generate-class-checking-code ((value repr:free-value-node)
                                         object-symbol
                                         exit-symbol)
  `(if (boundp ',(repr:variable-name value))
       (locally (declare special ,(repr:variable-name value))
         (unless (eq ,(repr:variable-name value) (class-of ,object-symbol))
           (return-from ,exit-symbol (values nil '()))))
       nil))


(defmethod generate-class-checking-code ((value repr:constant-node)
                                         object-symbol
                                         exit-symbol)
  `(unless (eq ,(repr:value value) (class-of ,object-symbol))
     (return-from ,exit-symbol (values nil '()))))


(defmethod generate-class-binding-code ((value repr:anonymus-value-node)
                                        object-symbol
                                        exit-symbol)
  nil)
