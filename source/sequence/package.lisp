(cl:defpackage #:hermetica.sequence
  (:use #:cl #:hermetica.aux-package)
  (:import-from #:hermetica.sequence.protocol
                #:at
                #:out-of-sequence-bounds
                #:sequence-interface
                #:end
                #:start)
  (:export #:at
           #:out-of-sequence-bounds
           #:sequence-interface
           #:start
           #:end))
