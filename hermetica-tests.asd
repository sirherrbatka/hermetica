(asdf:defsystem #:hermetica-tests
  :name "hermetica-tests"
  :version "0.0.0"
  :license "BSD simplified"
  :author "Marek Kochanowicz"
  :depends-on (:prove :hermetica)
  :defsystem-depends-on (:prove-asdf)
  :serial T
  :pathname "source"
  :components ((:module "representation"
                :components ((:module "protocol")))
               (:module "sequence"
                :components ((:module "protocol")))
               (:module "interpreter"
                :components ((:module "protocol"
                              :components ((:file "common-tests")
                                           (:test-file "object-tests")
                                           (:test-file "predicate-tests")
                                           (:test-file "negation-tests")
                                           (:test-file "recursive-tests")
                                           (:test-file "chain-tests")))))))
