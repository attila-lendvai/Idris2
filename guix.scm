;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2015 Paul van der Walt <paul@denknerd.org>
;;; Copyright © 2016, 2017 David Craven <david@craven.ch>
;;; Copyright © 2018 Alex ter Weele <alex.ter.weele@gmail.com>
;;; Copyright © 2019, 2021 Eric Bavier <bavier@posteo.net>
;;; Copyright © 2021 Attila Lendvai <attila@lendvai.name>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

;; To build and install:
;;   guix package -f guix.scm
;;
;; To build it, but not install it:
;;   guix build -f guix.scm
;;
;; To use as the basis for a development environment:
;;   guix environment -l guix.scm

(use-modules
 (gnu packages base)
 (gnu packages bash)
 (gnu packages chez)
 (gnu packages idris)
 (gnu packages llvm)
 (gnu packages multiprecision)
 (gnu packages node)
 (gnu packages version-control)
 (guix build-system gnu)
 (guix gexp)
 (guix git-download)
 ((guix licenses) #:prefix license:)
 (guix packages)
 (guix utils)
 (ice-9 regex)
 (srfi srfi-26)
 (srfi srfi-34))

(define *source-dir* (dirname (current-filename)))

(package
  (name "idris2")
  (version "0.3.0")
  (source (local-file *source-dir*
                      #:recursive? #t
                      #:select? (git-predicate *source-dir*)))
  (build-system gnu-build-system)
  (native-inputs
   `(("bootstrap-idris" ,idris2-0.2.2)
     ("clang" ,clang)
     ("coreutils" ,coreutils)
     ("git" ,git)
     ("node" ,node)
     ("sed" ,sed)))
  (inputs
   `(("bash" ,bash-minimal)
     ("chez-scheme" ,chez-scheme)
     ("gmp" ,gmp)))
  (arguments
   `(#:make-flags
     (list (string-append "CC=" ,(cc-for-target))
           (string-append "BOOTSTRAP_IDRIS=" (assoc-ref %build-inputs "bootstrap-idris") "/bin/idris2")
           (string-append "PREFIX=" (assoc-ref %outputs "out"))
           "-j1")
     #:phases
     (modify-phases %standard-phases
       (delete 'bootstrap)
       (delete 'configure)
       (delete 'check) ; check must happen after install and wrap-program
       (add-after 'unpack 'patch-paths
         (lambda* (#:key inputs #:allow-other-keys)
           (substitute* '("src/Compiler/Scheme/Chez.idr"
                          "src/Compiler/Scheme/Racket.idr"
                          "src/Compiler/Scheme/Gambit.idr"
                          "src/Compiler/ES/Node.idr"
                          "bootstrap/idris2_app/idris2.rkt"
                          "bootstrap/idris2_app/idris2.ss")
             ((,(regexp-quote "#!/bin/sh"))
              (string-append "#!" (assoc-ref inputs "bash") "/bin/sh"))
             (("/usr/bin/env")
              (string-append (assoc-ref inputs "coreutils") "/bin/env")))
           #true))
       (add-after 'install 'unwrap
         (lambda* (#:key outputs #:allow-other-keys)
           ;; The bin/idris2 calls bin/idris2_app/idris2.so which is
           ;; the real executable, but it sets LD_LIBRARY_PATH
           ;; incorrectly.  Remove bin/idris2 and replace it with
           ;; bin/idris2_app/idris2.so instead.
           (let ((out (assoc-ref outputs "out")))
             (delete-file (string-append out "/bin/idris2"))
             (rename-file (string-append out "/bin/idris2_app/idris2.so")
                          (string-append out "/bin/idris2"))
             (delete-file-recursively (string-append out "/bin/idris2_app"))
             (delete-file-recursively (string-append out "/lib")))
           #true))
       (add-after 'unwrap 'wrap-program
         (lambda* (#:key outputs inputs #:allow-other-keys)
           (let* ((chez (string-append (assoc-ref inputs "chez-scheme")
                                       "/bin/scheme"))
                  (out (assoc-ref outputs "out"))
                  (idris2 (string-append out "/bin/idris2"))
                  (version ,version))
             (wrap-program idris2
               `("IDRIS2_PREFIX" = (,out))
               `("LD_LIBRARY_PATH" prefix (,(string-append out "/idris2-" version "/lib")))
               `("CC" = (,',(cc-for-target)))
               `("CHEZ" ":" = (,chez))))
           #true))
       (add-after 'wrap-program 'check
         (lambda* (#:key outputs make-flags #:allow-other-keys)
           (apply invoke "make"
                  "INTERACTIVE="
                  (string-append "IDRIS=" (assoc-ref outputs "out") "/bin/idris2")
                  "test" make-flags))))))
  (home-page "https://www.idris-lang.org")
  (synopsis "General purpose language with full dependent types")
  (description "Idris is a general purpose language with full dependent
types.  It is compiled, with eager evaluation.  Dependent types allow types to
be predicated on values, meaning that some aspects of a program's behaviour
can be specified precisely in the type.  The language is closely related to
Epigram and Agda.")
  (license license:bsd-3))
