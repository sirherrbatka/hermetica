(cl:defpackage #:hermetica.interpreter.protocol
  (:use #:cl #:hermetica.aux-package)
  (:local-nicknames (#:repr #:hermetica.representation)
                    (#:seq #:hermetica.sequence))
  (:export #:match
           #:start
           #:end
           #:context
           #:at))
