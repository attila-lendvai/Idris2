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
 (gnu packages idris)
 (git)
 (guix git)
 (guix git-download))

(define (latest-git-commit-hash dir)
  (with-repository dir repo
    (oid->string (object-id (revparse-single repo "HEAD")))))

(make-idris-package
 (git-checkout (url (dirname (current-filename))))
 (git-version "0.5.1" "1" (latest-git-commit-hash (dirname (current-filename))))
 #f ; we're taking a bootstrap shortcut, no need to specify the bootstrap idris package
 #:ignore-test-failures? #true)
