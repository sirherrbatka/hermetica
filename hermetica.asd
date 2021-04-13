(asdf:defsystem #:hermetica
  :name "hermetica"
  :version "0.0.0"
  :license "BSD simplified"
  :author "Marek Kochanowicz"
  :depends-on ( :iterate
                :serapeum
                :alexandria)
  :serial T
  :pathname "source"
  :components ((:module "representation"
                :components ((:module "protocol"
                              :components ((:file "package")
                                           (:file "generics")
                                           (:file "types")
                                           (:file "methods")))
                             (:file "package")
                             ))
               (:module "interpreter"
                :components ((:module "protocol"
                              :components ((:file "package")
                                           (:file "variables")
                                           (:file "generics")
                                           (:file "types")
                                           (:file "methods")))
                             (:file "package")))
               ))
