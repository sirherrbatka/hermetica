(cl:in-package #:hermetica.interpreter.protocol)


(defmethod compile-node ((node hermetica.representation.protocol:fundamental-node))
  (handler-bind ((condition #'muffle-warning))
    (compile nil (generate-code node))))


(defmethod generate-code ((node repr:optional-node))
  (with-gensyms (!context !next !found !positions)
    `(lambda (,!context &optional ,!next)
       (if ,!next
           (bind (((:values ,!found ,!positions)
                   (funcall ,(~> node repr:inner generate-code)
                            (context-quasi-clone ,!context)
                            ,!next)))
             (if ,!found
                 (values t ,!positions)
                 (funcall ,!next ,!context)))
           (values t
                   (nth-value 1 (funcall ,(~> node repr:inner generate-code)
                                         ,!context)))))))


(defmethod generate-code ((node repr:and-node))
  (generate-code/and-chain node))


(defmethod generate-code ((node repr:bind-node))
  (with-gensyms (!context !next)
    `(lambda (,!context &optional ,!next)
       (when (null ,!next)
         (setf ,!next #'constantly-t))
       (nest ,(generate-value-binding-code (repr:value node) node)
             (funcall ,!next ,!context)))))


(defmethod generate-code ((node repr:unbind-node))
  (with-gensyms (!context !next)
    `(lambda (,!context &optional ,!next)
       (declare (special ,(repr:variable-name node)))
       (when (null ,!next)
         (setf ,!next #'constantly-t))
       (progv '(,(repr:variable-name node)) '()
         (funcall ,!next ,!context)))))


(defmethod generate-code ((node repr:predicate-node))
  (generate-predicate-code (repr:value node) node))


(defmethod generate-predicate-code ((inner repr:expression-node)
                                    (node repr:predicate-node))
  (with-gensyms (!context !next)
    `(lambda (,!context &optional ,!next)
       (when (null ,!next)
         (setf ,!next #'constantly-t))
       (if ,(repr:inner inner)
           (funcall ,!next ,!context)
           (values nil '())))))


(defmethod generate-code ((node repr:recursive-node))
  (bind ((inner (repr:inner node))
         (bind-nodes (repr:children node))
         (inner-code (generate-code inner))
         ((:flet generate-value-binding-code (bind-node))
          (generate-value-binding-code (repr:value bind-node) bind-node)))
    (with-gensyms (!context !inner !found !next !other-next !positions)
      `(lambda (,!context &optional ,!next)
         (labels ((,!other-next (,!context)
                    (if ,!next
                        (bind (((:values ,!found ,!positions)
                                (funcall ,!next (context-quasi-clone ,!context))))
                          (if ,!found
                              (values t ,!positions)
                              (nest
                               ,@(mapcar #'generate-value-binding-code bind-nodes)
                               (,!inner ,!context))))
                        (nest
                         ,@(mapcar #'generate-value-binding-code bind-nodes)
                         (bind (((:values ,!found ,!positions)
                                 (,!inner ,!context #',!other-next)))
                           (if ,!found
                               (values ,!found ,!positions)
                               (values t '()))))))
                  (,!inner (,!context &optional ,!other-next)
                    (declare (ignore ,!other-next))
                    (funcall ,inner-code ,!context #',!other-next)))
           (bind (((:values ,!found ,!positions) (,!inner ,!context)))
             (values ,!found
                     ,!positions)))))))


(defmethod generate-value-binding-code ((value hermetica.representation.protocol:fundamental-value-node)
                                        (node repr:bind-node))
  (let ((variable-name (repr:variable-name node))
        (content (repr:variable-name value)))
    `(let ((,variable-name (if (boundp ',content)
                               ,content
                               ,(bind (((:values default has-default) (repr:default value)))
                                  (if has-default
                                      default
                                      `(error 'unbound-variable :name ,content))))))
       (declare (special ,variable-name)))))


(defmethod generate-value-binding-code ((value repr:expression-node) (node repr:bind-node))
  (let ((variable-name (repr:variable-name node))
        (value (repr:inner value)))
    `(let ((,variable-name (locally (declare (special ,variable-name))
                             ,value)))
       (declare (special ,variable-name)))))


(defmethod generate-code ((node repr:negation-node))
  (with-gensyms (!context !next !start !success !places !block)
    (bind ((content (repr:inner node)))
      `(lambda (,!context &optional ,!next)
         (when (null ,!next)
           (setf ,!next #'constantly-t))
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
  (generate-code/and-chain node))


;; This code only deals with the class and slot variable binding
(defmethod generate-code ((node repr:object-node))
  (with-gensyms (!context
                 !next !object !block
                 !index !start !end
                 !check)
    (let ((slots (repr:children node))
          (class (repr:object-class node)))
      `(lambda (,!context &optional ,!next)
         (when (null ,!next)
           (setf ,!next #'constantly-t))
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
                                  (funcall ,!next (context-quasi-clone
                                                   ,!context
                                                   :start (1+ ,!index)))))
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
  (bind (((:values default has-default) (repr:default slot-value)))
    (if has-default
        `(handler-case (if (boundp ',(repr:variable-name slot-value))
                           (locally (declare (special ,(repr:variable-name slot-value)))
                             (unless (equal ,(repr:variable-name slot-value) (,slot-reader ,object-symbol))
                               (return-from ,exit-symbol (values nil '()))))
                           (unless (equal ,(repr:variable-name slot-value) ,default)
                             (return-from ,exit-symbol (values nil '()))))
           (unbound-slot (e) (declare (ignore e))
             (return-from ,exit-symbol (values nil '()))))
        `(handler-case (if (boundp ',(repr:variable-name slot-value))
                           (locally (declare (special ,(repr:variable-name slot-value)))
                             (unless (equal ,(repr:variable-name slot-value) (,slot-reader ,object-symbol))
                               (return-from ,exit-symbol (values nil '()))))
                           nil)
           (unbound-slot (e) (declare (ignore e))
             (return-from ,exit-symbol (values nil '())))))))


(defmethod generate-slot-checking-code ((slot-value repr:expression-node)
                                        slot-reader
                                        object-symbol
                                        exit-symbol)
  `(handler-case (unless (equal ,(repr:inner slot-value) (,slot-reader ,object-symbol))
                   (return-from ,exit-symbol (values nil '())))
     (unbound-slot (e) (declare (ignore e))
       (return-from ,exit-symbol (values nil '())))))


(defmethod generate-slot-value-binding-code ((slot-value repr:expression-node)
                                             slot-reader
                                             object-symbol
                                             exit-symbol)
  nil)


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
