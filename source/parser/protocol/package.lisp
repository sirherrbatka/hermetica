(cl:defpackage #:hermetica.parser.protocol
  (:use #:cl #:hermetica.aux-package)
  (:local-nicknames (#:repr #:hermetica.representation)
                    (#:seq #:hermetica.sequence))
  (:export
   #:parse
   #:fundamental-parser))
