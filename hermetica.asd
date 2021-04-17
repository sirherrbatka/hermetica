(asdf:defsystem #:hermetica
  :name "hermetica"
  :version "0.0.0"
  :license "BSD simplified"
  :author "Marek Kochanowicz"
  :depends-on ( #:iterate
                #:serapeum
                #:alexandria
                #:cl-data-structures)
  :serial T
  :pathname "source"
  :components ((:file "aux-package")
               (:module "representation"
                :components ((:module "protocol"
                              :components ((:file "package")
                                           (:file "generics")
                                           (:file "types")
                                           (:file "utils")
                                           (:file "functions")
                                           (:file "methods")))
                             (:file "package")))
               (:module "sequence"
                :components ((:module "protocol"
                              :components ((:file "package")
                                           (:file "variables")
                                           (:file "conditions")
                                           (:file "generics")
                                           (:file "types")
                                           (:file "utils")
                                           (:file "functions")
                                           (:file "methods")))
                             (:file "package")))
               (:module "interpreter"
                :components ((:module "protocol"
                              :components ((:file "package")
                                           (:file "variables")
                                           (:file "generics")
                                           (:file "types")
                                           (:file "utils")
                                           (:file "functions")
                                           (:file "methods")))
                             (:file "package")))))
