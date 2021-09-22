;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2021, 2022 Attila Lendvai <attila@lendvai.name>
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
;; To build it, but do not install:
;;   guix build -f guix.scm
;;
;; To use as the basis for a development environment:
;;   guix environment -l guix.scm --ad-hoc chez-scheme racket python python-sphinx python-sphinx-rtd-theme
;;
;; To get an isolated build environment for the releases (i.e. no git available):
;;   guix environment --pure --ad-hoc coreutils bash-minimal make gmp which findutils sed diffutils clang-toolchain@12 node chez-scheme racket python python-sphinx python-sphinx-rtd-theme

(use-modules
 (gnu packages idris)
 (git)
 (guix gexp)
 (guix git)
 (guix git-download)
 (guix packages))

(define *source-dir* (dirname (current-filename)))

(define (latest-git-commit-hash dir)
  (with-repository dir repo
    (oid->string (object-id (revparse-single repo "HEAD")))))

(define* (%make-idris-package #:key (with-worktree-changes? #true))
  (package
    (inherit idris-1.3.4)
    (version (git-version "1.3.4"
                          (if with-worktree-changes?
                              "dirty"
                              "1")
                          (latest-git-commit-hash *source-dir*)))
    (source (if with-worktree-changes?
                (local-file *source-dir*
                            #:recursive? #t
                            #:select? (git-predicate *source-dir*))
                (git-checkout (url *source-dir*)
                              (branch "idris.1"))))))

(%make-idris-package #:with-worktree-changes? #false)
