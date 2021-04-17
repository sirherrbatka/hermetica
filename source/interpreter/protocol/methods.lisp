(cl:in-package #:hermetica.interpreter.protocol)


(defmethod compile-node ((node hermetica.representation.protocol:fundamental-node))
  (compile nil (generate-code node)))


(defmethod generate-code ((node repr:negation-node))
  (with-gensyms (!context !next !start !success !places !block)
    (bind ((content (repr:inner node)))
      `(lambda (,!context &optional (,!next #'constantly-t))
         (block ,!block
           (bind ((,!start (start ,!context))
                  ((:values ,!success ,!places)
                   (funcall ,!next ,!context)))
             (unless ,!success
               (return-from ,!block (values nil nil)))
             (setf (context-start ,!context) ,!start)
             (unless (endp ,!places)
               (setf (context-end ,!context) (car (last ,!places))))
             (if (funcall ,(generate-code content)
                          ,!context)
                 (return-from ,!block (values nil nil))
                 (return-from ,!block (values t ,!places)))))))))


(defmethod generate-code ((node repr:chain-node))
  (with-gensyms (!context !next)
    (bind ((content (repr:children node))
           ((:labels impl (nodes))
            (if (endp nodes)
                `(lambda (c &optional (n #'constantly-t))
                   (funcall ,!next c n))
                `(lambda (,!context &optional (,!next #'constantly-t))
                   (funcall ,(generate-code (first nodes))
                            ,!context
                            ,(~> nodes rest impl))))))
      (impl content))))


;; This code only deals with the class and slot variable binding
(defmethod generate-code ((node repr:object-node))
  (with-gensyms (!context
                 !next !object !block
                 !index !start !end
                 !check)
    (let ((slots (repr:children node))
          (class (repr:object-class node)))
      `(lambda (,!context &optional (,!next #'constantly-t))
         (block ,!block
           (flet ((,!check (,!index &aux (,!object (at ,!context ,!index)))
                    ,(generate-class-checking-code class !object !check)
                    ,(generate-class-binding-code class !object !check)
                    ,@(iterate
                        (for slot in slots)
                        (for slot-reader = (repr:slot-reader slot))
                        (for slot-value = (repr:value slot))
                        (for validation-code = (generate-slot-checking-code slot-value slot-reader
                                                                            !object !check))
                        (when (null validation-code) (next-iteration))
                        (collect validation-code))
                    (nest ,@(if-let ((code (generate-class-binding-code class !object !check)))
                              (list code)
                              nil)
                          ,@(iterate
                              (for slot in slots)
                              (for slot-reader = (repr:slot-reader slot))
                              (for slot-value = (repr:value slot))
                              (for binding-code = (generate-slot-value-binding-code slot-value slot-reader
                                                                                    !object !check))
                              (when (null binding-code) (next-iteration))
                              (collect binding-code))
                          (bind (((:values result positions)
                                  (progn (setf (context-start ,!context) (1+ ,!index))
                                         (funcall ,!next ,!context))))
                            (when result
                              (return-from ,!block
                                (values t (cons ,!index positions))))))))
             (iterate
               (declare (type fixnum ,!start ,!end ,!index))
               (with ,!start = (start ,!context))
               (with ,!end = (end ,!context))
               (for ,!index from ,!start below ,!end)
               (,!check ,!index)
               (finally (return (values nil '()))))))))))


(defmethod generate-slot-checking-code ((slot-value repr:anonymus-value-node)
                                        slot-reader
                                        object-symbol
                                        exit-symbol)
  `(handler-case (,slot-reader ,object-symbol)
     (unbound-slot (e) (declare (ignore e))
       (return-from ,exit-symbol (values nil '())))))


(defmethod generate-slot-checking-code ((slot-value repr:constant-node)
                                        slot-reader
                                        object-symbol
                                        exit-symbol)
  `(handler-case (unless (equal ,(repr:value slot-value) (,slot-reader ,object-symbol))
                   (return-from ,exit-symbol (values nil '())))
     (unbound-slot (e) (declare (ignore e))
       (return-from ,exit-symbol (values nil '())))))


(defmethod generate-slot-checking-code ((slot-value repr:free-value-node)
                                        slot-reader
                                        object-symbol
                                        exit-symbol)
  `(handler-case (if (boundp ',(repr:variable-name slot-value))
                     (locally (declare (special ,(repr:variable-name slot-value)))
                       (unless (equal ,(repr:variable-name slot-value) (,slot-reader ,object-symbol))
                         (return-from ,exit-symbol (values nil '()))))
                     nil)
     (unbound-slot (e) (declare (ignore e))
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
       (locally (declare (special ,(repr:variable-name value)))
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


(defmethod generate-class-binding-code ((value repr:constant-node)
                                        object-symbol
                                        exit-symbol)
  nil)


(defmethod generate-class-binding-code ((value repr:free-value-node)
                                        object-symbol
                                        exit-symbol)
  `(let ((,(repr:variable-name value) (class-of ,object-symbol)))
     (declare (special ,(repr:variable-name value)))))
