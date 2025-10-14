;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2013 Cyril Roelandt <tipecaml@gmail.com>
;;; Copyright © 2014, 2015 Mark H Weaver <mhw@netris.org>
;;; Copyright © 2015 Andreas Enge <andreas@enge.fr>
;;; Copyright © 2015 David Hashe <david.hashe@dhashe.com>
;;; Copyright © 2016 Eric Bavier <bavier@member.fsf.org>
;;; Copyright © 2016 Jan Nieuwenhuizen <janneke@gnu.org>
;;; Copyright © 2016, 2018-2020, 2023, 2024 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2016-2024 Julien Lepiller <julien@lepiller.eu>
;;; Copyright © 2017 Ben Woodcroft <donttrustben@gmail.com>
;;; Copyright © 2017, 2018, 2019, 2020 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2018 Peter Kreye <kreyepr@gmail.com>
;;; Copyright © 2018, 2019 Gabriel Hondet <gabrielhondet@gmail.com>
;;; Copyright © 2018 Kei Kebreau <kkebreau@posteo.net>
;;; Copyright © 2019 Ricardo Wurmus <rekado@elephly.net>
;;; Copyright © 2020 Brett Gilio <brettg@gnu.org>
;;; Copyright © 2020 Marius Bakke <marius@gnu.org>
;;; Copyright © 2020, 2021, 2025 Simon Tournier <zimon.toutoune@gmail.com>
;;; Copyright © 2020 divoplade <d@divoplade.fr>
;;; Copyright © 2020, 2021, 2022 pukkamustard <pukkamustard@posteo.net>
;;; Copyright © 2021 aecepoglu <aecepoglu@fastmail.fm>
;;; Copyright © 2021 Sharlatan Hellseher <sharlatanus@gmail.com>
;;; Copyright © 2021 Xinglu Chen <public@yoctocell.xyz>
;;; Copyright © 2021 Ivan Gankevich <i.gankevich@spbu.ru>
;;; Copyright © 2021 Maxime Devos <maximedevos@telenet.be>
;;; Copyright © 2021 Sarah Morgensen <iskarian@mgsn.dev>
;;; Copyright © 2022 Maxim Cournoyer <maxim@guixotic.coop>
;;; Copyright © 2022 John Kehayias <john.kehayias@protonmail.com>
;;; Copyright © 2022 Garek Dyszel <garekdyszel@disroot.org>
;;; Copyright © 2023 Csepp <raingloom@riseup.net>
;;; Copyright © 2023, 2024 Foundation Devices, Inc. <hello@foundation.xyz>
;;; Copyright © 2023 Arnaud DABY-SEESARAM <ds-ac@nanein.fr>
;;; Copyright © 2024 Sören Tempel <soeren@soeren-tempel.net>
;;; Copyright © 2025 Jussi Timperi <jussi.timperi@iki.fi>
;;; Copyright © 2025 John Hester <hesterj@etableau.com>
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

(define-module (gnu packages ocaml)
  #:use-module (gnu packages)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages finance)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages m4)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages node)
  #:use-module (gnu packages parallel)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages protobuf)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages tex)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages time)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages unicode)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages web)
  #:use-module (gnu packages web-browsers)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (guix build-system dune)
  #:use-module (guix build-system emacs)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system ocaml)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix svn-download)
  #:use-module (guix utils)
  #:use-module ((srfi srfi-1) #:hide (zip)))

;; A shortcut for files from ocaml forge. Downloaded files are computed from
;; their number, not their name.
(define (ocaml-forge-uri name version file-number)
  (string-append "https://forge.ocamlcore.org/frs/download.php/"
                 (number->string file-number) "/" name "-" version
                 ".tar.gz"))

(define (janestreet-origin name version hash)
  (origin (method url-fetch)
          (uri (string-append "https://ocaml.janestreet.com/ocaml-core/v"
                              (version-major+minor version) "/files/"
                              name "-v" (version-major+minor+point version)
                              ".tar.gz"))
          (sha256 (base32 hash))))

(define* (github-tag-origin name home-page version hash tag-prefix)
  "Create an origin for a GitHub repository using a version tag.
TAG-PREFIX is appended before the version to easily allow the same function
to be used for other repos."
  (origin
    (method git-fetch)
    (uri (git-reference
          (url (string-append home-page ".git"))
          (commit (string-append tag-prefix version))))
    (file-name (git-file-name name version))
    (sha256
     (base32
      hash))))

;; (define-public ocaml-pack-template
;;   (package
;;     (name "ocaml-pack-template")
;;     (version "0.2.0")
;;     (home-page
;;      "https://github.com/anmonteiro/httpun")
;;     (source
;;      (github-tag-origin
;;       name home-page version
;;       "056q1qm49xfhkkjyyxbrp5njqzgwlh2ngzql4cwqcg9f6h04gvpx"
;;       ""
;;       ))
;;     (build-system dune-build-system)
;;     ))

(define-public camlboot
  (let ((commit "45045d0afa82f7e9b7ea07314aab08be2d3cd64b")
        (revision "1"))
    (package
      (name "camlboot")
      (version (git-version "0.0.0" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/Ekdohibs/camlboot")
                      (commit commit)
                      (recursive? #t)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "1f5gl3hzvixbgk0v3kmxiyn432znyy3jh5fa65cfzcaxzgfv1i1c"))
                (patches (search-patches
                           "camlboot-dynamically-allocate-stack-signal.patch"))
                (modules '((guix build utils)))
                (snippet
                 `(begin
                    ;; Remove bootstrap binaries and pre-generated source files,
                    ;; to ensure we actually bootstrap properly.
                    (for-each delete-file (find-files "ocaml-src" "^.depend$"))
                    (delete-file "ocaml-src/boot/ocamlc")
                    (delete-file "ocaml-src/boot/ocamllex")
                    ;; Ensure writable
                    (for-each
                     (lambda (file)
                       (chmod file (logior (stat:mode (stat file)) #o200)))
                     (find-files "." "."))))))
      (build-system gnu-build-system)
      (arguments
       `(#:make-flags (list "_boot/ocamlc") ; build target
         #:tests? #f                        ; no tests
         #:phases
         (modify-phases %standard-phases
           (delete 'configure)
           (add-before 'build 'no-autocompile
             (lambda _
               ;; prevent a guile warning
               (setenv "GUILE_AUTO_COMPILE" "0")))
           (replace 'install
             (lambda* (#:key outputs #:allow-other-keys)
               (let* ((out (assoc-ref outputs "out"))
                      (bin (string-append out "/bin")))
                 (mkdir-p bin)
                 (install-file "_boot/ocamlc" bin)
                 (rename-file "miniml/interp/lex.byte" "ocamllex")
                 (install-file "ocamllex" bin)))))))
      (native-inputs
       (list guile-3.0))
      (properties
       ;; 10 hours, mostly for arm, more than 1 expected even on x86_64
       `((max-silent-time . 36000)))
      (home-page "https://github.com/Ekdohibs/camlboot")
      (synopsis "OCaml source bootstrap")
      (description "OCaml is written in OCaml.  Its sources contain a pre-compiled
bytecode version of @command{ocamlc} and @command{ocamllex} that are used to
build the next version of the compiler.  Camlboot implements a bootstrap for
the OCaml compiler and provides a bootstrapped equivalent to these files.

It contains a compiler for a small subset of OCaml written in Guile Scheme,
an interpreter for OCaml written in that subset and a manually-written lexer
for OCaml.  These elements eliminate the need for the binary bootstrap in
OCaml and can effectively bootstrap OCaml 4.07.

This package produces a native @command{ocamlc} and a bytecode @command{ocamllex}.")
      (license license:expat))))

(define-public ocaml-5.0
  (package
    (name "ocaml")
    (version "5.0.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/ocaml/ocaml")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1p0p8wldrnbr61wfy3x4122017g4k5gjvfwlg3mvlqn8r2fxn2m5"))))
    (build-system gnu-build-system)
    (native-search-paths
     (list (search-path-specification
            (variable "OCAMLPATH")
            (files (list "lib/ocaml" "lib/ocaml/site-lib")))
           (search-path-specification
            (variable "CAML_LD_LIBRARY_PATH")
            (files (list "lib/ocaml/site-lib/stubslibs"
                         "lib/ocaml/site-lib/stublibs")))))
    (native-inputs
     (list parallel perl pkg-config))
    (inputs
     (list libx11 libiberty ;needed for objdump support
           zlib))                       ;also needed for objdump support
    (arguments
     `(#:configure-flags '("--enable-ocamltest")
       #:test-target "tests"
       ;; This doesn't have the desired effect and makes test runs less
       ;; stable. See https://codeberg.org/guix/guix/pulls/2933.
       #:parallel-tests? #f
       #:make-flags '("defaultentry")
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'enable-parallel-tests
           (lambda _
             ;; Patch the `tests` build target to enable a special parallel
             ;; execution mode based on GNU Parallel.
             (substitute* "Makefile"
               (("-C testsuite all") "-C testsuite parallel"))))
         (add-after 'unpack 'patch-/bin/sh-references
           (lambda* (#:key inputs #:allow-other-keys)
             (let* ((sh (search-input-file inputs "/bin/sh"))
                    (quoted-sh (string-append "\"" sh "\"")))
               (with-fluids ((%default-port-encoding #f))
                 (for-each
                  (lambda (file)
                    (substitute* file
                      (("\"/bin/sh\"")
                       (begin
                         (format (current-error-port) "\
patch-/bin/sh-references: ~a: changing `\"/bin/sh\"' to `~a'~%"
                                 file quoted-sh)
                         quoted-sh))))
                  (find-files "." "\\.ml$")))))))))
    (home-page "https://ocaml.org/")
    (synopsis "The OCaml programming language")
    (description
     "OCaml is a general purpose industrial-strength programming language with
an emphasis on expressiveness and safety.  Developed for more than 20 years at
Inria it benefits from one of the most advanced type systems and supports
functional, imperative and object-oriented styles of programming.")
    ;; The compiler is distributed under qpl1.0 with a change to choice of
    ;; law: the license is governed by the laws of France.  The library is
    ;; distributed under lgpl2.0.
    (license (list license:qpl license:lgpl2.0))))

(define-public ocaml-5.3
  (package
    (inherit ocaml-5.0)
    (version "5.3.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/ocaml/ocaml")
                    (commit version)))
              (file-name (git-file-name "ocaml" version))
              (sha256
               (base32
                "05jhy9zn53v12rn3sg3vllqf5blv1gp7f06803npimc58crxy6rv"))))))

;; (define-public ocaml-5.4
;;   (package
;;     (inherit ocaml-5.0)
;;     (version "5.4.0")
;;     (source (origin
;;               (method git-fetch)
;;               (uri (git-reference
;;                     (url "https://github.com/ocaml/ocaml")
;;                     (commit version)))
;;               (file-name (git-file-name "ocaml" version))
;;               (sha256
;;                (base32
;;                 "1xfay0q47kckxy6c7y7qx8lqs7x8hw6sjqyq0sx8x7q1lwggcgry"))))))

(define-public ocaml-4.14
  (package
    (name "ocaml")
    (version "4.14.1")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "http://caml.inria.fr/pub/distrib/ocaml-"
                    (version-major+minor version)
                    "/ocaml-" version ".tar.xz"))
              (sha256
               (base32
                "0vxvwxxycpc3r5p7ys59d86vw5vdr2lhmck1f3s6qms2096rf9y1"))))
    (build-system gnu-build-system)
    (native-search-paths
     (list (search-path-specification
            (variable "OCAMLPATH")
            (files (list "lib/ocaml" "lib/ocaml/site-lib")))
           (search-path-specification
            (variable "CAML_LD_LIBRARY_PATH")
            (files (list "lib/ocaml/site-lib/stubslibs"
                         "lib/ocaml/site-lib/stublibs")))))
    (native-inputs
     (list perl pkg-config))
    (inputs
     (list libx11 libiberty ;needed for objdump support
           zlib))                       ;also needed for objdump support
    (arguments
     `(#:configure-flags '("--enable-ocamltest")
       #:test-target "tests"
       #:make-flags '("world.opt")
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-/bin/sh-references
           (lambda* (#:key inputs #:allow-other-keys)
             (let* ((sh (search-input-file inputs "/bin/sh"))
                    (quoted-sh (string-append "\"" sh "\"")))
               (with-fluids ((%default-port-encoding #f))
                 (for-each
                  (lambda (file)
                    (substitute* file
                      (("\"/bin/sh\"")
                       (begin
                         (format (current-error-port) "\
patch-/bin/sh-references: ~a: changing `\"/bin/sh\"' to `~a'~%"
                                 file quoted-sh)
                         quoted-sh))))
                  (find-files "." "\\.ml$")))))))))
    (home-page "https://ocaml.org/")
    (synopsis "The OCaml programming language")
    (description
     "OCaml is a general purpose industrial-strength programming language with
an emphasis on expressiveness and safety.  Developed for more than 20 years at
Inria it benefits from one of the most advanced type systems and supports
functional, imperative and object-oriented styles of programming.")
    ;; The compiler is distributed under qpl1.0 with a change to choice of
    ;; law: the license is governed by the laws of France.  The library is
    ;; distributed under lgpl2.0.
    (license (list license:qpl license:lgpl2.0))))

(define-public ocaml-4.09
  (package
    (inherit ocaml-4.14)
    (version "4.09.0")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "http://caml.inria.fr/pub/distrib/ocaml-"
                    (version-major+minor version)
                    "/ocaml-" version ".tar.xz"))
              (patches (search-patches
                         "ocaml-4.09-multiple-definitions.patch"
                         "ocaml-4.09-dynamically-allocate-signal-stack.patch"))
              (sha256
               (base32
                "1v3z5ar326f3hzvpfljg4xj8b9lmbrl53fn57yih1bkbx3gr3yzj"))))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-/bin/sh-references
           (lambda* (#:key inputs #:allow-other-keys)
             (let* ((sh (search-input-file inputs "/bin/sh"))
                    (quoted-sh (string-append "\"" sh "\"")))
               (with-fluids ((%default-port-encoding #f))
                 (for-each
                  (lambda (file)
                    (substitute* file
                      (("\"/bin/sh\"")
                       (begin
                         (format (current-error-port) "\
patch-/bin/sh-references: ~a: changing `\"/bin/sh\"' to `~a'~%"
                                 file quoted-sh)
                         quoted-sh))))
                  (find-files "." "\\.ml$"))))))
         (replace 'build
           (lambda _
             (invoke "make" "-j" (number->string (parallel-job-count))
                     "world.opt")))
         (replace 'check
           (lambda _
             (with-directory-excursion "testsuite"
               (invoke "make" "all")))))))))

;; This package is a bootstrap package for ocaml-4.07. It builds from camlboot,
;; using the upstream sources for ocaml 4.07. It installs a bytecode ocamllex
;; and ocamlc, the bytecode interpreter ocamlrun, and generated .depend files
;; that we otherwise remove for bootstrap purposes.
(define ocaml-4.07-boot
  (package
    (inherit ocaml-4.09)
    (name "ocaml-boot")
    (version "4.07.1")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "http://caml.inria.fr/pub/distrib/ocaml-"
                    (version-major+minor version)
                    "/ocaml-" version ".tar.xz"))
              (sha256
               (base32
                "1f07hgj5k45cylj1q3k5mk8yi02cwzx849b1fwnwia8xlcfqpr6z"))
              (patches (search-patches
                         "ocaml-multiple-definitions.patch"
                         "ocaml-4.07-dynamically-allocate-signal-stack.patch"))
              (modules '((guix build utils)))
              (snippet
               `(begin
                  ;; Remove bootstrap binaries and pre-generated source files,
                  ;; to ensure we actually bootstrap properly.
                  (for-each delete-file (find-files "." "^.depend$"))
                  (delete-file "boot/ocamlc")
                  (delete-file "boot/ocamllex")))))
    (arguments
     `(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (add-before 'configure 'copy-bootstrap
           (lambda* (#:key inputs #:allow-other-keys)
             (let ((camlboot (assoc-ref inputs "camlboot")))
               (copy-file (string-append camlboot "/bin/ocamllex") "boot/ocamllex")
               (copy-file (string-append camlboot "/bin/ocamlc") "boot/ocamlc")
               (chmod "boot/ocamllex" #o755)
               (chmod "boot/ocamlc" #o755))))
         (replace 'configure
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (mandir (string-append out "/share/man")))
               (invoke "./configure"
                       "--prefix" out
                       "--mandir" mandir))))
         (replace 'build
           (lambda* (#:key parallel-build? #:allow-other-keys)
             (define* (make . args)
               (apply invoke "make"
                      (append (if parallel-build?
                                  `("-j" ,(number->string (parallel-job-count)))
                                  '())
                              args)))
             ;; create empty .depend files because they are included by various
             ;; Makefiles, and they have no rule to generate them.
             (invoke "touch" ".depend" "stdlib/.depend" "byterun/.depend"
                     "tools/.depend"  "lex/.depend" "asmrun/.depend"
                     "debugger/.depend" "ocamltest/.depend" "ocamldoc/.depend"
                     "ocamldoc/stdlib_non_prefixed/.depend"
                     "otherlibs/bigarray/.depend" "otherlibs/graph/.depend"
                     "otherlibs/raw_spacetime_lib/.depend" "otherlibs/str/.depend"
                     "otherlibs/systhreads/.depend" "otherlibs/threads/.depend"
                     "otherlibs/unix/.depend" "otherlibs/win32unix/.depend")
             ;; We cannot build ocamldep until we have created all the .depend
             ;; files, so replace it with ocamlc -depend.
             (substitute* "tools/Makefile"
               (("\\$\\(CAMLRUN\\) ./ocamldep") "../boot/ocamlc -depend"))
             (substitute* '("otherlibs/graph/Makefile"
                            "otherlibs/systhreads/Makefile"
                            "otherlibs/threads/Makefile"
                            "otherlibs/unix/Makefile")
               (("\\$\\(CAMLRUN\\) ../../tools/ocamldep")
                "../../boot/ocamlc -depend"))
             (substitute* '("otherlibs/bigarray/Makefile"
                            "otherlibs/raw_spacetime_lib/Makefile"
                            "otherlibs/str/Makefile"
                            "otherlibs/win32unix/Makefile")
               (("\\$\\(CAMLRUN\\) \\$\\(ROOTDIR\\)/tools/ocamldep")
                "../../boot/ocamlc -depend"))
             ;; Ensure we copy needed file, so we can generate a proper .depend
             (substitute* "ocamldoc/Makefile"
               (("include Makefile.unprefix")
                "include Makefile.unprefix
depend: $(STDLIB_MLIS) $(STDLIB_DEPS)"))
             ;; Generate required tools for `alldepend'
             (make "-C" "byterun" "depend")
             (make "-C" "byterun" "all")
             (copy-file "byterun/ocamlrun" "boot/ocamlrun")
             (make "ocamlyacc")
             (copy-file "yacc/ocamlyacc" "boot/ocamlyacc")
             (make "-C" "stdlib" "sys.ml")
             (make "-C" "stdlib" "CAMLDEP=../boot/ocamlc -depend" "depend")
             ;; Build and copy files later used by `tools'
             (make "-C" "stdlib" "COMPILER="
                   "CAMLC=../boot/ocamlc -use-prims ../byterun/primitives"
                   "all")
             (for-each
              (lambda (file)
                (copy-file file (string-append "boot/" (basename file))))
              (cons* "stdlib/stdlib.cma" "stdlib/std_exit.cmo" "stdlib/camlheader"
                     (find-files "stdlib" ".*.cmi$")))
             (symlink "../byterun/libcamlrun.a" "boot/libcamlrun.a")
             ;; required for ocamldoc/stdlib_non_prefixed
             (make "parsing/parser.mli")
             ;; required for dependencies
             (make "-C" "tools"
                   "CAMLC=../boot/ocamlc -nostdlib -I ../boot -use-prims ../byterun/primitives -I .."
                   "make_opcodes" "cvt_emit")
             ;; generate all remaining .depend files
             (make "alldepend"
                   (string-append "ocamllex=" (getcwd) "/boot/ocamlrun "
                                  (getcwd) "/boot/ocamllex")
                   (string-append "CAMLDEP=" (getcwd) "/boot/ocamlc -depend")
                   (string-append "OCAMLDEP=" (getcwd) "/boot/ocamlc -depend")
                   (string-append "ocamldep=" (getcwd) "/boot/ocamlc -depend"))
             ;; Build ocamllex
             (make "CAMLC=boot/ocamlc -nostdlib -I boot -use-prims byterun/primitives"
                   "ocamlc")
             ;; Build ocamlc
             (make "-C" "lex"
                   "CAMLC=../boot/ocamlc -strict-sequence -nostdlib -I ../boot -use-prims ../byterun/primitives"
                   "all")))
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (depends (string-append out "/share/depends")))
               (mkdir-p bin)
               (mkdir-p depends)
               (install-file "ocamlc" bin)
               (install-file "lex/ocamllex" bin)
               (for-each
                (lambda (file)
                  (let ((dir (string-append depends "/" (dirname file))))
                    (mkdir-p dir)
                    (install-file file dir)))
                (find-files "." "^\\.depend$"))))))))
    (native-inputs
     `(("camlboot" ,camlboot)
       ("perl" ,perl)
       ("pkg-config" ,pkg-config)))))

(define-public ocaml-4.07
  (package
    (inherit ocaml-4.07-boot)
    (name "ocaml")
    (arguments
      (substitute-keyword-arguments (package-arguments ocaml-4.09)
        ((#:phases phases)
         `(modify-phases ,phases
            (add-before 'configure 'copy-bootstrap
              (lambda* (#:key inputs #:allow-other-keys)
                (let ((ocaml (assoc-ref inputs "ocaml")))
                  (copy-file (string-append ocaml "/bin/ocamllex") "boot/ocamllex")
                  (copy-file (string-append ocaml "/bin/ocamlc") "boot/ocamlc")
                  (chmod "boot/ocamllex" #o755)
                  (chmod "boot/ocamlc" #o755)
                  (let ((rootdir (getcwd)))
                    (with-directory-excursion (string-append ocaml "/share/depends")
                      (for-each
                        (lambda (file)
                          (copy-file file (string-append rootdir "/" file)))
                        (find-files "." ".")))))))
            (replace 'configure
              (lambda* (#:key outputs #:allow-other-keys)
                (let* ((out (assoc-ref outputs "out"))
                       (mandir (string-append out "/share/man")))
                  ;; Custom configure script doesn't recognize
                  ;; --prefix=<PREFIX> syntax (with equals sign).
                  (invoke "./configure"
                          "--prefix" out
                          "--mandir" mandir))))))))
    (native-inputs
     `(("ocaml" ,ocaml-4.07-boot)
       ("perl" ,perl)
       ("pkg-config" ,pkg-config)))))

(define-public ocaml ocaml-5.3)

(define-public ocamlbuild
  (package
    (name "ocamlbuild")
    (version "0.16.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/ocaml/ocamlbuild")
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "148r0imzsalr7c3zqncrl4ji29wpb5ls5zkqxy6xnh9q99gxb4a6"
         ))))
    (build-system ocaml-build-system)
    (arguments
     `(#:make-flags
       ,#~(list (string-append "OCAMLBUILD_PREFIX=" #$output)
                (string-append "OCAMLBUILD_BINDIR=" #$output "/bin")
                (string-append "OCAMLBUILD_LIBDIR=" #$output
                               "/lib/ocaml/site-lib")
                (string-append "OCAMLBUILD_MANDIR=" #$output "/share/man"))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))
                                        ; some failures because of changes in OCaml's error message formatting
       #:tests? #f))
    (home-page "https://github.com/ocaml/ocamlbuild")
    (synopsis "OCaml build tool")
    (description "OCamlbuild is a generic build tool, that has built-in rules
for building OCaml library and programs.")
    (license license:lgpl2.1+)))

(define-public camlidl
  (package
    (name "camlidl")
    (version "1.09")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/xavierleroy/camlidl")
             (commit "camlidl109")))
       (sha256
        (base32 "0zrkaq7fk23b2b9vg6jwdjx7l0hdqp4synbbrw1zcg8gjf6n3c80"))
       (file-name (git-file-name name version))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f ;; No test suite
       #:make-flags
       (list
        (string-append
         "BINDIR=" (assoc-ref %outputs "out") "/bin")
        (string-append
         "OCAMLLIB=" (assoc-ref %outputs "out") "/lib/ocaml/site-lib/camlidl"))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'build
           (lambda _
             (copy-file "config/Makefile.unix" "config/Makefile")
             ;; Note: do not pass '-jN' as this appears to not be
             ;; parallel-safe (race condition related to libcamlidl.a).
             (invoke "make" "all")
             #t))
         (add-before 'install 'create-target-directories
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (string-append (assoc-ref outputs "out"))))
               (mkdir-p
                (string-append out "/bin"))
               (mkdir-p
                (string-append out "/lib/ocaml/site-lib/camlidl/stublibs"))
               (mkdir-p
                (string-append out "/lib/ocaml/site-lib/camlidl/caml")))
             #t))
         (add-after 'install 'install-meta
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (with-output-to-file
                   (string-append out "/lib/ocaml/site-lib/camlidl/META")
                 (lambda _
                   (display
                    (string-append
                     "description = \"Stub code generator for OCaml/C interface\"
version = \"" ,version "\"
directory = \"^\"
archive(byte) = \"com.cma\"
archive(native) = \"com.cmxa\"")))))
             #t)))))
    (native-inputs
     (list ocaml))
    (home-page "https://github.com/xavierleroy/camlidl")
    (synopsis "Stub code generator for OCaml/C interface")
    (description
     "Camlidl is a stub code generator for Objective Caml.  It generates stub
code for interfacing Caml with C from an IDL description of the C functions.")
    (license license:lgpl2.1)))

(define-public ocaml-extlib
  (package
    (name "ocaml-extlib")
    (version "1.8.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://ygrek.org/p/release/ocaml-extlib/"
                                  "extlib-" version ".tar.gz"))
              (sha256
               (base32
                "0w2xskv8hl0fwjri68q5bpf6n36ab4fp1q08zkfqw2i807q7fhln"))))
    (build-system dune-build-system)
    (arguments
     (list #:package "extlib"))
    (native-inputs
      (list ocaml-cppo))
    (home-page "https://github.com/ygrek/ocaml-extlib")
    (synopsis "Complete and small extension for OCaml standard library")
    (description "This library adds new functions to OCaml standard library
modules, modifies some functions in order to get better performances or
safety (tail-recursive) and also provides new modules which should be useful
for day to day programming.")
    ;; With static-linking exception
    (license license:lgpl2.1+)))

(define-public ocaml-camlpdf
  (package
    (name "ocaml-camlpdf")
    (version "2.8.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/johnwhitington/camlpdf")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1cbqgwh62cqnsbax4k4iv9gb63k1v545izmbffxj8gj1q6sm0k34"))))
    (build-system ocaml-build-system)
    (arguments
     (list
      #:tests? #f ;no tests
      #:make-flags
        #~(list (string-append "CC=" #$(cc-for-target)))
      #:phases
        #~(modify-phases %standard-phases
            (delete 'configure)
            (add-after 'unpack 'patch-makefile-shell
              (lambda _
                (patch-makefile-SHELL "OCamlMakefile")))
            (add-after 'install 'install-doc
              (lambda _
                (let ((doc (string-append #$output "/share/doc/"
                                          #$name "-" #$version)))
                  (copy-recursively "doc/camlpdf/html"
                                    (string-append doc "/html"))))))))
    (home-page "https://github.com/johnwhitington/camlpdf")
    (synopsis "OCaml library for PDF file manipulation")
    (description
     "CamlPDF is an OCaml library that provides functionality for reading,
writing, and modifying PDF files.  It serves as the foundation for the
@command{cpdf} command-line tool and various API bindings.")
    (license license:lgpl2.1+)))

(define-public ocaml-cudf
  (package
    (name "ocaml-cudf")
    (version "0.10")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://gitlab.com/irill/cudf")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1lvrmpscbk1kjv5ag5bzlzv520xk5zw2haf6q7chvz98gcm9g0hk"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-extlib))
    (native-inputs (list ocaml-ounit2))
    (home-page "https://www.mancoosi.org/cudf/")
    (synopsis "CUDF library (part of the Mancoosi tools)")
    (description
     "@acronym{CUDF, Common Upgradeability Description Format} is a format for
describing upgrade scenarios in package-based software distributions.")
    ;; With static-linking exception
    (license license:lgpl2.1+)))

(define-public ocaml-mccs
  (package
    (name "ocaml-mccs")
    (version "1.1+19")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/AltGr/ocaml-mccs")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1x1y5rhj4f0xakbgfn9f90a9xy09v99p8mc42pbnam5kghyjmxy6"
                ))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-cudf))
    (home-page "https://www.i3s.unice.fr/~cpjm/misc/")
    (synopsis "Upgrade path problem solver")
    (description "Mccs (Multi Criteria CUDF Solver) is a CUDF problem solver.
Mccs take as input a CUDF problem and computes the best solution according to
a set of criteria.  It relies on a Integer Programming solver or a
Pseudo Boolean solver to achieve its task.  Mccs can use a wide set of
underlying solvers like Cplex, Gurobi, Lpsolver, Glpk, CbC, SCIP or WBO.")
    (license (list
               license:bsd-3
               license:gpl3+
               ;; With static-linking exception
               license:lgpl2.1+))))

(define-public ocaml-dose3
  (package
    (name "ocaml-dose3")
    (version "7.0.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://gitlab.com/irill/dose3")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0hcjh68svicap7j9bghgkp49xa12qhxa1pygmrgc9qwm0m4dhirb"))))
    (build-system dune-build-system)
    (arguments `(#:package "dose3"))
    (propagated-inputs (list ocaml-extlib
                             ocaml-base64-boot
                             ocaml-cudf
                             ocaml-graph
                             ocaml-re
                             ocaml-stdlib-shims))
    (native-inputs (list ocaml-ounit))
    (home-page "https://www.mancoosi.org/software/")
    (synopsis "Package distribution management framework")
    (description "Dose3 is a framework made of several OCaml libraries for
managing distribution packages and their dependencies.  Though not tied to
any particular distribution, dose3 constitutes a pool of libraries which
enable analyzing packages coming from various distributions.  Besides basic
functionalities for querying and setting package properties, dose3 also
implements algorithms for solving more complex problems such as monitoring
package evolutions, correct and complete dependency resolution and
repository-wide uninstallability checks.")
    ;; with static-linking exception
    (license license:lgpl2.1+)))

(define-public ocaml-down
  (package
    (name "ocaml-down")
    (version "0.1.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://erratique.ch/software/down/releases/down-"
                            version ".tbz"))
        (sha256
         (base32
          "1q467y6qz96ndiybpmggdcnrcip49kxw2i93pb54j1xjzkv1vnl1"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:tests? #f ;no tests
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))
       #:build-flags
       ,#~(list "build" "--lib-dir"
                (string-append #$output "/lib/ocaml/site-lib"))))
    (native-inputs
     (list ocaml-findlib ocamlbuild ocaml-topkg opam-installer))
    (home-page "https://erratique.ch/software/down")
    (synopsis "OCaml toplevel (REPL) upgrade")
    (description "Down is an unintrusive user experience upgrade for the
@command{ocaml} toplevel (REPL).

Simply load the zero dependency @code{down} library in the @command{ocaml}
toplevel and you get line edition, history, session support and identifier
completion and documentation with @command{ocp-index}.

Add this to your @file{~/.ocamlinit}:

@example
#use \"down.top\"
@end example

You may also need to add this to your @file{~/.ocamlinit} and declare
the environment variable @code{OCAML_TOPLEVEL_PATH}:

@example
let () =
  try Topdirs.dir_directory (Sys.getenv \"OCAML_TOPLEVEL_PATH\")
  with Not_found -> ()
@end example

OR

@example
let () = String.split_on_char ':' (Sys.getenv \"OCAMLPATH\")
         |> List.filter (fun x -> Filename.check_suffix x \"/site-lib\")
         |> List.map (fun x -> x ^ \"/toplevel\")
         (* remove the line below if you don't want to see the text
            every time you start the toplevel *)
         |> List.map (fun x -> Printf.printf \"adding directory %s\\n\" x; x)
         |> List.iter Topdirs.dir_directory;;
@end example")
    (license license:isc)))

(define-public ocaml-opam-file-format
  (package
    (name "ocaml-opam-file-format")
    (version "2.1.4")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ocaml/opam-file-format")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0dmnb1mqdy4913f9ma446hi5m99q7hfibj6j0m8x2wsfnfy2fw62"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:tests? #f; No tests
       #:make-flags ,#~(list (string-append "LIBDIR=" #$output
                                            "/lib/ocaml/site-lib"))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))))
    (home-page "https://opam.ocaml.org")
    (synopsis "Parser and printer for the opam file syntax")
    (description "This package contains a parser and a pretty-printer for
the opam file format.")
    ;; With static-linking exception
    (license license:lgpl2.1+)))

(define-public ocaml-swhid-core
  (package
    (name "ocaml-swhid-core")
    (version "0.1")
    (build-system dune-build-system)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ocamlpro/swhid_core")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0h3zndyk94lf2lakc3cb8b7a00jqh0y1m8xk6mg61gj2kdpdbfdq"))))
    (arguments
     `(#:tests? #f))
    ;; (native-inputs (list ocaml-alcotest))
    (home-page "https://github.com/ocamlpro/swhid_core")
    (synopsis "Software Heritage IDS")
    (description "
swhid_core is an OCaml library to work with persistent identifiers used by Software Heritage, also known as swhid. This is the core library, for most use cases you should use the swhid library instead.
")
    (license license:isc)))

(define-public ocaml-patch
  (package
    (name "ocaml-patch")
    (version "v3.0.0")
    (build-system dune-build-system)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/hannesm/patch"
                          )
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0fpxkc84g98ar321dl1fzr4cqbz990acj03n80pwg9y62x9mx2aq"))))
    (arguments
     `(#:tests? #f))
    ;; (native-inputs (list ocaml-alcotest))
    (home-page "https://github.com/hannesm/patch")
    (synopsis "Patch - apply your unified diffs in pure OCaml")
    (description "Patch - apply your unified diffs in pure OCaml

The loosely specified diff file format is widely used for transmitting differences of line-based information. The motivating example is opam, which is able to validate updates being cryptographically signed (e.g. conex) by providing a unified diff.

The test-based infered specification implemented in this library is the following grammar.")
    (license license:isc)))

(define-public ocaml-spdx-licenses
  (package
    (name "ocaml-spdx-licenses")
    (version "v1.4.0")
    (build-system dune-build-system)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url
                      "https://github.com/kit-ty-kate/spdx_licenses"
                          )
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "16nqhh2w2l5sky3i77v854yyyx8d9hgmmg14mkr8m7ym1syvp7mz"
                ))))
    (arguments
     `(#:tests? #f))
    ;; (native-inputs (list ocaml-alcotest))
    (home-page "https://github.com/hannesm/patch")
    (synopsis "spdx_licenses is an OCaml library aiming to provide an up-to-date and strict SPDX License Expression parser.")
    (description "It implements the format described in: https://spdx.github.io/spdx-spec/v3.0.1/annexes/spdx-license-expressions")
    (license license:isc)))

(define-public ocaml-ipaddr-cstruct
  (package
    (name "ocaml-ipaddr-cstruct")
    (version "5.6.1")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/ocaml-ipaddr/releases/download/v5.6.1/ipaddr-5.6.1.tbz")
       (sha256
        (base32 "06d32jp2a2ym49bg4736g2snqhi7glk7bgp94g446n6lmgw7sq8y"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ipaddr ocaml-cstruct ocaml-ppx-sexp-conv))
    (native-inputs (list ocaml-ounit2))
    (home-page "https://github.com/mirage/ocaml-ipaddr")
    (synopsis
     "A library for manipulation of IP address representations using Cstructs")
    (description "Cstruct convertions for macaddr.")
    (license license:isc)))

(define-public ocaml-xenstore
  (package
    (name "ocaml-xenstore")
    (version "2.4.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/ocaml-xenstore/releases/download/2.4.0/xenstore-2.4.0.tbz")
       (sha256
        (base32 "197s11f50rysffy1qh5b2fm3a89abccwnvpk6rylig58lnr3pdhi"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ounit2 ocaml-lwt))
    (home-page "https://github.com/mirage/ocaml-xenstore")
    (synopsis "Xenstore protocol in pure OCam")
    (description
     "This repo contains: 1.  a xenstore client library, a merge of the Mirage and XCP
ones 2.  a xenstore server library 3.  a xenstore server instance which runs
under Unix with libxc 4.  a xenstore server instance which runs on mirage.  The
client and the server libraries have sets of unit-tests.")
    (license #f)))


(define-public ocaml-ipaddr-sexp
  (package
    (name "ocaml-ipaddr-sexp")
    (version "5.6.1")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/ocaml-ipaddr/releases/download/v5.6.1/ipaddr-5.6.1.tbz")
       (sha256
        (base32 "06d32jp2a2ym49bg4736g2snqhi7glk7bgp94g446n6lmgw7sq8y"))))
    (build-system dune-build-system)
    (arguments '(#:package "ipaddr-sexp"
                 #:tests? #f)) ; tests build macaddr-sexp too, causing conflicts
    (propagated-inputs (list ocaml-ipaddr ocaml-ppx-sexp-conv ocaml-sexplib0 ocaml-ipaddr-cstruct))
    (native-inputs (list ocaml-ounit2))
    (home-page "https://github.com/mirage/ocaml-ipaddr")
    (synopsis
     "A library for manipulation of IP address representations using sexp")
    (description "Sexp convertions for ipaddr.")
    (license license:isc)))


(define-public ocaml-ca-certs-nss
  (package
    (name "ocaml-ca-certs-nss")
    (version "3.115")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/ca-certs-nss/releases/download/v3.115/ca-certs-nss-3.115.tbz")
       (sha256
        (base32 "03rqcwpbjisrxis1ixzwazp641w6i7zpn39x2bd2xsibx6nyyf3j"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-mirage-ptime ocaml-x509 ocaml-digestif ocaml-ipaddr-sexp
                             ))
    (native-inputs (list ocaml-logs ocaml-fmt ocaml-bos ocaml-cmdliner
                         ocaml-alcotest gmp))
    (home-page "https://github.com/mirage/ca-certs-nss")
    (synopsis "X.509 trust anchors extracted from Mozilla's NSS")
    (description
     "Trust anchors extracted from Mozilla's NSS certdata.txt package, to be used in
@code{MirageOS} unikernels.")
    (license license:isc)))

(define-public ocaml-xen-gnt
  (package
    (name "ocaml-xen-gnt")
    (version "4.0.2")
    (home-page "https://github.com/mirage/ocaml-gnt")
    (source
     (github-tag-origin
      name home-page version
      "0jq9xdjvzx7rxhi8mq68lql6xfkkwknzpbc1417myhs8jmrvhsbh"
      "v"
      ))
    (arguments
     `(#:package "xen-gnt"))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-cstruct ocaml-io-page ocaml-lwt
                             ocaml-lwt-dllist ocaml-cmdliner))
    (synopsis #f)
    (description #f)
    (license license:isc)))

(define-public ocaml-xen-gnt-unix
  (package
    (inherit ocaml-xen-gnt)
    (arguments
     `(#:package "xen-gnt-unix"))
    (inputs (list xen))
    (propagated-inputs (list ocaml-cstruct ocaml-io-page ocaml-lwt
                             ocaml-lwt-dllist ocaml-cmdliner))
  ))

(define-public ocaml-tls-mirage
  (package
    (name "ocaml-tls-mirage")
    (version "2.0.3")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirleft/ocaml-tls/releases/download/v2.0.3/tls-2.0.3.tbz")
       (sha256
        (base32 "1my3a71l3fb1idgmcirbi29p6xmwzlhg0ls3hirjxnpk8nkrn5fp"))))
    (build-system dune-build-system)
    (arguments
     ;; tests take a long time?
     `(#:tests? #f))
    (propagated-inputs (list ocaml-tls
                             ocaml-fmt
                             ocaml-lwt
                             ocaml-mirage-flow
                             ocaml-mirage-kv
                             ocaml-mirage-ptime
                             ocaml-ptime
                             ocaml-mirage-crypto
                             ;; ocaml-mirage-crypto-pk
                             ))
    (native-inputs (list gmp))
    (home-page "https://github.com/mirleft/ocaml-tls")
    (synopsis "Transport Layer Security purely in OCaml, MirageOS layer")
    (description
     "Tls-mirage provides an effectful FLOW module to be used in the @code{MirageOS}
ecosystem.")
    (license license:bsd-2)))
(define-public ocaml-xenstore-transport
  (package
    (name "ocaml-xenstore-transport")
    (version "1.5.0")
    (arguments
     ;; tests could not find xenstore?
     `(#:tests? #f))
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/xapi-project/ocaml-xenstore-clients/releases/download/v1.5.0/xenstore-tool-1.5.0.tbz")
       (sha256
        (base32 "0pz4q08fpgnk4ix98ajw1sjyyykdxsyq7shh54wwb0pr1y1is6ry"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-lwt ocaml-xenstore ocaml-camlp-streams))
    (native-inputs (list ocaml-findlib ocaml-ounit2))
    (properties `((upstream-name . "xenstore_transport")))
    (home-page "http://github.com/xapi-project/ocaml-xenstore-clients")
    (synopsis
     "Low-level libraries for connecting to a xenstore service on a xen host")
    (description
     "These libraries contain the IO functions for communicating with a xenstore
service on a xen host.  One subpackage deals with regular Unix threads and
another deals with Lwt co-operative threads.")
    (license license:lgpl2.1)))

(define-public ocaml-vchan
  (package
    (name "ocaml-vchan")
    (version "6.0.2")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/ocaml-vchan/releases/download/v6.0.2/vchan-6.0.2.tbz")
       (sha256
        (base32 "1razkj2jbplj1midhaiqlflzvibcl0ylivvz34g8rf6nbbdbaj3y"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-lwt
                             ocaml-cstruct
                             ocaml-io-page
                             ocaml-mirage-flow
                             ocaml-xenstore
                             ocaml-mirage-xen
                             ocaml-xenstore-transport
                             ocaml-xen-gnt
                             ocaml-xen-gnt-unix
                             ))
    (native-inputs (list ocaml-ounit2))
    (home-page "https://github.com/mirage/ocaml-vchan")
    (synopsis "Xen Vchan implementation")
    (description
     "This is an implementation of the Xen \"libvchan\" or \"vchan\" communication
protocol in OCaml.  It allows fast inter-domain communication using shared
memory.")
    (license license:isc)))

(define-public ocaml-conduit
  (package
    (name "ocaml-conduit")
    (version "8.0.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/ocaml-conduit/releases/download/v8.0.0/conduit-8.0.0.tbz")
       (sha256
        (base32 "0qbgyqn4xv79gznv5i7lxj4g920kyr8xl30p7a4p6m2vhq8djqqa"))))
    (build-system dune-build-system)
    (arguments
     '(#:package "conduit"))
    (propagated-inputs (list ocaml-sexplib0
                             ocaml-ipaddr
                             ocaml-ipaddr-sexp
                             ocaml-uri
                             ocaml-astring))
    (home-page "https://github.com/mirage/ocaml-conduit")
    (synopsis "A network connection establishment library")
    (description
     "The `conduit` library takes care of establishing and listening for TCP and
SSL/TLS connections for the Lwt and Async libraries.  The reason this library
exists is to provide a degree of abstraction from the precise SSL library used,
since there are a variety of ways to bind to a library (e.g. the C FFI, or the
Ctypes library), as well as well as which library is used (just @code{OpenSSL}
for now).  By default, @code{OpenSSL} is used as the preferred connection
library, but you can force the use of the pure OCaml TLS stack by setting the
environment variable `CONDUIT_TLS=native` when starting your program.  The
useful opam packages available that extend this library are: - `conduit`: the
main `Conduit` module - `conduit-lwt`: the portable Lwt implementation -
`conduit-lwt-unix`: the Lwt/Unix implementation - `conduit-async` the Jane
Street Async implementation - `conduit-mirage`: the @code{MirageOS} compatible
implementation.")
    (license license:isc)))

(define-public ocaml-conduit-lwt
  (package
    (name "ocaml-conduit-lwt")
    (version "8.0.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/ocaml-conduit/releases/download/v8.0.0/conduit-8.0.0.tbz")
       (sha256
        (base32 "0qbgyqn4xv79gznv5i7lxj4g920kyr8xl30p7a4p6m2vhq8djqqa"))))
    (build-system dune-build-system)
    (arguments
     '(#:package "conduit-lwt"))
    (propagated-inputs (list ocaml-conduit
                             ocaml-lwt))
    (home-page "https://github.com/mirage/ocaml-conduit")
    (synopsis "A portable network connection establishment library using Lwt")
    (description #f)
    (license license:isc)))

(define-public ocaml-conduit-lwt-unix
  (package
    (name "ocaml-conduit-lwt-unix")
    (version "8.0.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/ocaml-conduit/releases/download/v8.0.0/conduit-8.0.0.tbz")
       (sha256
        (base32 "0qbgyqn4xv79gznv5i7lxj4g920kyr8xl30p7a4p6m2vhq8djqqa"))))
    (build-system dune-build-system)
    (arguments
     ;; tests failed, unknown scheme?
     `(
       #:tests? #f
       #:package "conduit-lwt-unix"))
    (propagated-inputs (list ocaml-conduit-lwt
                             ocaml-lwt
                             ocaml-uri
                             ocaml-lwt-log
                             ocaml-ipaddr
                             ocaml-ipaddr-sexp
                             ocaml-logs
                             ocaml-ca-certs
                             ocaml-lwt-ssl))
    (home-page "https://github.com/mirage/ocaml-conduit")
    (synopsis "A network connection establishment library for Lwt_unix")
    (description #f)
    (license license:isc)))

(define-public ocaml-cohttp-lwt-unix
  (package
    (name "ocaml-cohttp-lwt-unix")
    (arguments
     `(
     ;; tests failed, unknown scheme?
       #:tests? #f
       #:package "cohttp-lwt-unix"))
    (version "6.1.1")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/ocaml-cohttp/releases/download/v6.1.1/cohttp-6.1.1.tbz")
       (sha256
        (base32 "1728dhv143pmgz6r2mvbhxia7f8gxay3dw34b58hnfiv41b0qhkb"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-http
                             ocaml-cohttp
                             ocaml-cohttp-lwt
                             ocaml-conduit-lwt-unix
                             ;; js-of-ocaml
                             ocaml-astring
                             ;; ocaml-cohttp-lwt
                             ;; ocaml-cmdliner
                             ;; ocaml-lwt
                             ;; ocaml-conduit-lwt
                             ;; ocaml-conduit-lwt-unix
                             ;; ocaml-fmt
                             ;; ocaml-ppx-sexp-conv
                             ocaml-magic-mime
                             ;; ocaml-logs
                             ;; ocaml-odoc
                             ))
    (native-inputs (list ocaml-ounit2 curl))
    (home-page "https://github.com/mirage/ocaml-cohttp")
    (synopsis "CoHTTP implementation for Unix and Windows using Lwt")
    (description
     "An implementation of an HTTP client and server using the Lwt concurrency
library.  See the `Cohttp_lwt_unix` module for information on how to use this.
The package also installs `cohttp-curl-lwt` and a `cohttp-server-lwt` binaries
for quick uses of a HTTP(S) client and server respectively.  Although the name
implies that this only works under Unix, it should also be fine under Windows
too.")
    (license license:isc)))

(define-public ocaml-0install-solver
  (package
    (name "ocaml-0install-solver")
    (version "v2.18")
    (build-system dune-build-system)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url
                      "https://github.com/0install/0install"
                          )
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1hm72k355qwgh16hngmnd77bgawf20ipnqxfncdzl10rqrc0640b"
                ))))
    (arguments
     `(#:tests? #f
       #:package "0install-solver"))
    (home-page "https://github.com/0install/0install")
    (synopsis "Package dependency solver")
    (description "Zero Install is a decentralised cross-distribution software installation system available under the LGPL. It allows software developers to publish programs directly from their own web-sites, while supporting features familiar from centralised distribution repositories such as shared libraries, automatic updates and digital signatures. It is intended to complement, rather than replace, the operating system's package management. 0install packages never interfere with those provided by the distribution.")
    (license license:lgpl2.1)))

(define-public ocaml-0install
  (package
    (inherit ocaml-0install-solver)
    (name "ocaml-0install")
    (version "v2.18")
    (build-system dune-build-system)
    ;; (source (origin
    ;;           (method git-fetch)
    ;;           (uri (git-reference
    ;;                  (url
    ;;                   "https://github.com/0install/0install"
    ;;                       )
    ;;                  (commit version)))
    ;;           (file-name (git-file-name name version))
    ;;           (sha256
    ;;            (base32
    ;;             "1hm72k355qwgh16hngmnd77bgawf20ipnqxfncdzl10rqrc0640b"
    ;;             ))))
    (arguments
     `(#:tests? #f
       #:package "0install"))
    ;; (native-inputs (list ocaml-alcotest))
    ;; (home-page "https://github.com/0install/0install")
    (native-inputs (list curl))
    (propagated-inputs (list ocaml-lwt
                             ocaml-xmlm
                             ocaml-yojson
                             ocaml-react
                             ocaml-lwt-react
                             ocaml-sha
                             ocaml-0install-solver
                             ;; For dune select form - using curl instead of cohttp
                             ocaml-curl
                             ocaml-curl-lwt
                             ocaml-stdlib-shims
                             ocaml-sha
                             ))
    (synopsis "the core 0install package" )
    (description "Zero Install is a decentralised cross-distribution software installation system available under the LGPL. It allows software developers to publish programs directly from their own web-sites, while supporting features familiar from centralised distribution repositories such as shared libraries, automatic updates and digital signatures. It is intended to complement, rather than replace, the operating system's package management. 0install packages never interfere with those provided by the distribution.")
    (license license:lgpl2.1)))

(define-public ocaml-lwt-glib
  (package
    (name "ocaml-lwt-glib")
    (version "1.1.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://github.com/ocsigen/lwt_glib/archive/1.1.1.tar.gz")
       (sha256
        (base32 "0qkk8yjqbp3py59sg7hq495v9b1p0jp881zsmr2jgib6p5x4hnlw"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-lwt))
    (native-inputs (list glib pkg-config))
    (properties `((upstream-name . "lwt_glib")))
    (home-page "https://github.com/ocsigen/lwt_glib")
    (synopsis "GLib integration for Lwt")
    (description #f)
    (license license:lgpl2.0+))) 

(define-public ocaml-opam-0install-cudf
  (package
    (name "ocaml-opam-0install-cudf")
    (version "v0.5.0")
    (build-system dune-build-system)
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url
                      "https://github.com/ocaml-opam/opam-0install-cudf"
                          )
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "12v1bgnxcxdylgxbsjlcr90rzwcp39rjlv191cy8g2s33nyxyi2c"
                ))))
    (propagated-inputs (list ocaml-0install ocaml-cudf))
    (arguments
     `(#:tests? #f))
    ;; (native-inputs (list ocaml-alcotest))
    (home-page "https://github.com/hannesm/patch")
    (synopsis "A generic CUDF solver library meant to be used in opam")
    (description "Opam's default solver is designed to maintain a set of packages over time, minimising disruption when installing new programs and finding a compromise solution across all packages.

In many situations (e.g. CI, local roots or duniverse builds) this is not necessary, and we can get a solution much faster by usin a different algorithm.

This package provides a generic solver library which uses 0install's solver library. The library uses the CUDF library in order to interface with opam as it is the format common used to talk to all the supported solvers.")
    (license license:isc)))

(define ocaml-opam-core
  (package
    (name "ocaml-opam-core")
    (version "2.4.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ocaml/opam")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0php0b31cwyabhds477abk8qyz4whl3kncpbka4dynzpaf9xnqsm"))))
    (build-system dune-build-system)
    (arguments `(#:package "opam-core"
                 ;; tests are run with the opam package
                 #:tests? #f
                 #:phases
                 (modify-phases %standard-phases
                   (add-before 'build 'pre-build
                     (lambda* (#:key inputs make-flags #:allow-other-keys)
                       (let ((bash (assoc-ref inputs "bash"))
                             (bwrap (search-input-file inputs "/bin/bwrap")))
                         (substitute* "src/core/opamSystem.ml"
                           (("\"/bin/sh\"")
                            (string-append "\"" bash "/bin/sh\""))
                           (("getconf")
                            (which "getconf")))))))))
    (propagated-inputs
     (list ocaml-graph
           ocaml-re
           ocaml-patch
           ocaml-uutf
           ocaml-cppo
           ocaml-swhid-core
           ocaml-jsonm
           ocaml-cmdliner-1.3
           ocaml-sha
           ))
    (inputs (list bubblewrap ocaml-patch ocaml-uutf))
    (home-page "https://opam.ocamlpro.com/")
    (synopsis "Package manager for OCaml")
    (description
     "OPAM is a tool to manage OCaml packages.  It supports multiple
simultaneous compiler installations, flexible package constraints, and a
Git-friendly development workflow.")
    ;; The 'LICENSE' file waives some requirements compared to LGPLv3.
    (license license:lgpl3)))

(define ocaml-opam-format
  (package
    (inherit ocaml-opam-core)
    (name "ocaml-opam-format")
    (inputs '())
    (propagated-inputs (list ocaml-opam-core
                             ocaml-opam-file-format
                             ocaml-re))
    (arguments `(#:package "opam-format"
                 ;; tests are run with the opam package
                 #:tests? #f
                 #:phases %standard-phases))))

(define-public opam-installer
  (package
    (inherit ocaml-opam-core)
    (name "opam-installer")
    (native-inputs (list ocaml-opam-format
                         ;; ocaml-patch
                         ;; ocaml-uutf
                         ocaml-cmdliner-1.3))
    (inputs '())
    (propagated-inputs '())
    (arguments `(#:package "opam-installer"
                 ;; requires all of opam
                 #:tests? #f))
    (synopsis "Tool for installing OCaml packages")
    (description "@var{opam-installer} is a tool for installing OCaml packages
based on @code{.install} files defined by the OPAM package manager.  It is
useful for installing OCaml packages without requiring the entirety of
OPAM.")
    (properties
     ;; opam-installer is used as a tool and not as a library, we can use the
     ;; OCaml 4.14 compiled opam until opam is compatible with OCaml 5.0.
     `((ocaml5.3-variant . ,(delay opam-installer))))))

(define ocaml-opam-repository
  (package
    (inherit ocaml-opam-core)
    (name "ocaml-opam-repository")
    (inputs '())
    (propagated-inputs (list ocaml-opam-format))
    (arguments `(#:package "opam-repository"
                 ;; tests are run with the opam package
                 #:tests? #f
                 #:phases %standard-phases))))

(define ocaml-opam-state
  (package
    (inherit ocaml-opam-core)
    (name "ocaml-opam-state")
    (arguments `(#:package "opam-state"
                 ;; tests are run with the opam package
                 #:tests? #f
                 #:phases
                 (modify-phases %standard-phases
                   (add-before 'build 'pre-build
                     (lambda* (#:key inputs make-flags #:allow-other-keys)
                       (let ((bwrap (search-input-file inputs "/bin/bwrap")))
                         ;; Use bwrap from the store directly.
                         (substitute* "src/state/shellscripts/bwrap.sh"
                           (("-v bwrap") (string-append "-v " bwrap))
                           (("exec bwrap") (string-append "exec " bwrap))
                           ;; Mount /gnu and /run/current-system in the
                           ;; isolated environment when building with opam.
                           ;; This is necessary for packages to find external
                           ;; dependencies, such as a C compiler, make, etc...
                           (("^add_sys_mounts /usr")
                            (string-append "add_sys_mounts "
                                           (%store-directory)
                                           " /run/current-system /usr")))))))))
    (inputs (list bubblewrap ocaml-spdx-licenses))
    (propagated-inputs (list ocaml-opam-repository))))

(define ocaml-opam-solver
  (package
    (inherit ocaml-opam-core)
    (name "ocaml-opam-solver")
    (inputs '())
    (propagated-inputs (list ocaml-opam-format
                             ocaml-mccs
                             ocaml-opam-0install-cudf
                             ocaml-dose3))
    (arguments `(#:package "opam-solver"
                 ;; tests are run with the opam package
                 #:tests? #f
                 #:phases %standard-phases))))

(define ocaml-opam-client
  (package
    (inherit ocaml-opam-core)
    (name "ocaml-opam-client")
    (arguments `(#:package "opam-client"
                 ;; tests are run with the opam package
                 #:tests? #f
                 #:phases
                 (modify-phases %standard-phases
                   (add-before 'build 'pre-build
                     (lambda* (#:key inputs make-flags #:allow-other-keys)
                       (let ((bwrap (search-input-file inputs "/bin/bwrap")))
                         (substitute* "src/client/opamInitDefaults.ml"
                           (("\"bwrap\"") (string-append "\"" bwrap "\"")))))))))
    (inputs (list bubblewrap))
    (propagated-inputs
     (list ocaml-opam-state
           ocaml-opam-solver
           ocaml-spdx-licenses
           ocaml-opam-repository
           ocaml-base64
           ocaml-re
           ocaml-cmdliner-1.3))))

(define-public opam
  (package
    (inherit ocaml-opam-core)
    (name "opam")
    (build-system dune-build-system)
    (arguments
     `(#:package "opam"
       #:tests? #f )) ; Tests require specific opam repository snapshots
;;       #:phases
;;        (modify-phases %standard-phases
;;          (add-before 'check 'prepare-checks
;;            (lambda* (#:key inputs #:allow-other-keys)
;;              ;; Opam tests need to run an isolated environment from a writable
;;              ;; home directory.
;;              (mkdir-p "test-home")
;;              (setenv "HOME" (string-append (getcwd) "/test-home"))
;;              (with-output-to-file (string-append (getcwd) "/test-home/.gitconfig")
;;                (lambda _
;;                  (display "[user]
;; email = guix@localhost.none
;; name = Guix Builder")
;;                  (newline)))

;;              ;; Opam tests require data from opam-repository. Instead of
;;              ;; downloading them with wget from the guix environment, copy the
;;              ;; content to the expected directory.
;;              (substitute* "tests/reftests/dune.inc"
;;                (("tar -C.*opam-archive-([0-9a-f]*)[^)]*" _ commit)
;;                 (string-append "rmdir %{targets}) (run cp -r "
;;                                (assoc-ref inputs (string-append "opam-repo-" commit))
;;                                "/ %{targets}) (run chmod +w -R %{targets}"))
;;                (("wget[^)]*") "touch %{targets}")
;;                ;; Disable a failing test because it tries to clone a git
;;                ;; repository from inside bwrap
;;                (("diff upgrade-format.test upgrade-format.out") "run true")
;;                ;; Disable a failing test because it tries to figure out which
;;                ;; distro this is, and it doesn't know Guix
;;                (("diff pin.unix.test pin.unix.out") "run true")
;;                ;; Disable a failing test because of a failed expansion
;;                (("diff opamroot-versions.test opamroot-versions.out") "run true")
;;                ;; Disable a failing test, probably because the repository we
;;                ;; replaced is not as expected
;;                (("diff opamrt-big-upgrade.test opamrt-big-upgrade.out") "run true")
;;                ;; Disable a failing test because of missing sandboxing
;;                ;; functionality
;;                (("diff init.test init.out") "run true"))
;;              (substitute* "tests/reftests/dune"
;;                ;; Because of our changes to the previous file, we cannot check
;;                ;; it can be regenerated
;;                (("diff dune.inc dune.inc.gen") "run true"))
;;              ;; Ensure we can run the generated build.sh (no /bin/sh)
;;              (substitute* '("tests/reftests/legacy-local.test"
;;                             "tests/reftests/legacy-git.test")
;;                (("#! ?/bin/sh")
;;                 (string-append "#!"
;;                                (search-input-file inputs "/bin/sh"))))
;;              (substitute* "tests/reftests/testing-env"
;;                (("OPAMSTRICT=1")
;;                 (string-append "OPAMSTRICT=1\nLIBRARY_PATH="
;;                                (assoc-ref inputs "libc") "/lib")))
;;              )))))
    (native-inputs
      (let ((opam-repo (lambda (commit hash)
                         (origin
                           (method git-fetch)
                           (uri (git-reference
                                  (url "https://github.com/ocaml/opam-repository")
                                  (commit commit)))
                           (file-name (git-file-name "opam-repo" commit))
                           (sha256 (base32 hash))))))
       `(("dune" ,dune)
         ("ocaml-cppo" ,ocaml-cppo)

         ;; For tests.
         ("git" ,git-minimal/pinned)
         ("openssl" ,openssl)
         ("python" ,python-wrapper)
         ("rsync" ,rsync)
         ("unzip" ,unzip)
         ("which" ,which)

         ;; Data for tests
         ("opam-repo-0070613707"
          ,(opam-repo "00706137074d536d2019d2d222fbe1bea929deda"
                      "1gv1vvmfscj7wirfv6qncp8pf81wygnpzjwd0lyqcxm7g8r8lb4w"))
         ("opam-repo-009e00fa"
          ,(opam-repo "009e00fa86300d11c311309a2544e5c6c3eb8de2"
                      "1wwy0rwrsjf4q10j1rh1dazk32fbzhzy6f7zl6qmndidx9b1bq7w"))
         ("opam-repo-7090735c"
          ,(opam-repo "7090735c9d1dd2dc481c4128c5ef4d3667238f15"
                      "1bccsgjhlp64lmvfjfn6viywf3x73ji75myg9ssf1ij1fkmabn0z"))
         ("opam-repo-a5d7cdc0"
          ,(opam-repo "a5d7cdc0c91452b0aef4fa71c331ee5237f6dddd"
                      "0z7kawqisy07088p5xjxwpvmvzlbj1d9cgdipsj90yx7nc5qh369"))
         ("opam-repo-ad4dd344"
          ,(opam-repo "ad4dd344fe5cd1cab49ced49d6758a9844549fb4"
                      "1a1qj47kj8xjdnc4zc50ijrix1kym1n7k20n3viki80a7518baw8"))
         ("opam-repo-c1842d168d"
          ,(opam-repo "c1842d168de956caf06d7ac8588e65020d7594d8"
                      "142y1ac7sprygyh91shcp0zcyfxjjkshi9g44qgg4rx60rbsbhai"))
         ("opam-repo-c1d23f0e"
          ,(opam-repo "c1d23f0e17ec83a036ebfbad1c78311b898a2ca0"
                      "0j9abisx3ifzm66ci3p45mngmz4f0fx7yd9jjxrz3f8w5jffc9ii"))
         ("opam-repo-f372039d"
          ,(opam-repo "f372039db86a970ef3e662adbfe0d4f5cd980701"
                      "0ld7fcry6ss6fmrpswvr6bikgx299w97h0gwrjjh7kd7rydsjdws"))
         ("opam-repo-11ea1cb"
          ,(opam-repo "11ea1cb6f2418b1f8a6679e4422771a04c9c3655"
                      "1s4p0wfn3bx97yvm8xvj3yhzv2pz0jwml68g2ybv37hj9mpbrsq0"))
         ("opam-repo-297366c"
          ,(opam-repo "297366cd01c3aaf29b967bf0b34ccc7989d4d5b3"
                      "1ysg69gys37nc2cxivs2ikh6xp0gj85if4rcrr874mqb9z12dm0j"))
         ("opam-repo-3235916"
          ,(opam-repo "3235916a162a59d7c82dac3fe24214975d48f1aa"
                      "1yf73rv2n740a4s9g7a9k4j91b4k7al88nwnw9cdw0k2ncbmr486"))
         ("opam-repo-de897adf36c4230dfea812f40c98223b31c4521a"
          ,(opam-repo "de897adf36c4230dfea812f40c98223b31c4521a"
                      "1m18x9gcwnbar8yv9sbfz8a3qpw412fp9cf4d6fb7syn0p0h96jw")))))
    (inputs (list ocaml-opam-client ocaml-spdx-licenses ocaml-opam-0install-cudf))
    (properties
     ;; OPAM is used as a tool and not as a library, we can use the OCaml 4.14
     ;; compiled opam until opam is compatible with OCaml 5.0.
     `((ocaml5.0-variant . ,(delay opam))))))

(define-public ocaml-opam-monorepo
  (package
    (name "ocaml-opam-monorepo")
    (version "0.3.5")
    (source (origin
              (method git-fetch)
              (uri
               (git-reference
                (url "https://github.com/tarides/opam-monorepo/")
                (commit version)))
              (file-name name)
              (sha256
               (base32
                "09lq788b1sai4v1nxd16b00pw0m55plcwrx3f9v5a90gpxg0a6sc"))))
    (build-system dune-build-system)
    (arguments
     ;; TODO
     ;; Too many tests require a fully initialized opam, disabling them would
     ;; be a huge pain.  "Mocking" opam init is difficult because it requires
     ;; networking access.
     '(#:tests? #f))
    ;; TODO: not entirely clear if these should be native, test cross-building
    (native-inputs (list
                         pkg-config))
    ;; (propagated-inputs lablgtk3) optional and is currently failing to build
    (home-page "https://github.com/tarides/opam-monorepo")
    (synopsis "Assemble and manage fully vendored Dune repositories")
    (description
     "The opam monorepo plugin provides a convenient interface to bridge the
opam package manager with having a local copy of all the source code required
to build a project using the dune build tool.")
    (license license:isc)))

(define-public ocaml-camlp-streams
  (package
    (name "ocaml-camlp-streams")
    (version "5.0.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ocaml/camlp-streams")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0r3wvffkzyyk4als78akirxanzbib5hvc3kvwxpk36mlmc38aywh"))))
    (build-system dune-build-system)
    (arguments
     ;; No tests
     `(#:tests? #f))
    (home-page "https://github.com/ocaml/camlp-streams")
    (synopsis "Stream and Genlex libraries for use with Camlp4 and Camlp5")
    (description
      "This package provides two library modules:

@itemize
@item Stream: imperative streams, with in-place update and memoization of
the latest element produced.
@item Genlex: a small parameterized lexical analyzer producing streams of
tokens from streams of characters.
@end itemize

The two modules are designed for use with Camlp4 and Camlp5: The stream
patterns and stream expressions of Camlp4/Camlp5 consume and produce data of
type 'a Stream.t.  The Genlex tokenizer can be used as a simple lexical
analyzer for Camlp4/Camlp5-generated parsers.

The Stream module can also be used by hand-written recursive-descent parsers,
but is not very convenient for this purpose.

The Stream and Genlex modules have been part of the OCaml standard library for a
long time, and have been distributed as part of the core OCaml system.  They
will be removed from the OCaml standard library at some future point, but will
be maintained and distributed separately in the camlpstreams package.")
    (license license:lgpl2.1)))

(define-public camlp5
  ;; Doesn't work for OCaml 5.4
  (package
    (name "camlp5")
    (version "8.04.00")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/camlp5/camlp5")
             (commit (string-append "" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0ykrlifzhky0z8q0hbfhv4vqlzx9qrk614lrk7blra7ddwd1b174"
                ))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f  ; XXX TODO figure out how to run the tests
       #:phases
       (modify-phases %standard-phases
         (replace 'configure
                  (lambda* (#:key outputs #:allow-other-keys)
                    (let* ((out (assoc-ref outputs "out"))
                           (mandir (string-append out "/share/man")))
                      ;; Custom configure script doesn't recognize
                      ;; --prefix=<PREFIX> syntax (with equals sign).
                      (invoke "./configure"
                              "--prefix" out
                              "--mandir" mandir))))
         (add-before 'build 'fix-/bin-references
           (lambda _
             (substitute* "config/Makefile"
               (("/bin/rm") "rm"))
             #t))
         (replace 'build
                  (lambda _
                    (invoke "make" "-j" (number->string
                                         (parallel-job-count))
                            "world.opt")))
         ;; Required for findlib to find camlp5's libraries
         (add-after 'install 'install-meta
           (lambda* (#:key outputs #:allow-other-keys)
             (install-file "etc/META" (string-append (assoc-ref outputs "out")
                                                     "/lib/ocaml/camlp5/"))
             #t)))))
    (inputs
     (list ocaml ocaml-camlp-streams ocaml-rresult ocaml-bos ocaml-re ocaml-pcre2 pcre2))
    (native-inputs
     (list perl ocaml-findlib))
    (home-page "https://camlp5.github.io/")
    (synopsis "Pre-processor Pretty Printer for OCaml")
    (description
     "Camlp5 is a Pre-Processor-Pretty-Printer for Objective Caml.  It offers
tools for syntax (Stream Parsers and Grammars) and the ability to modify the
concrete syntax of the language (Quotations, Syntax Extensions).")
    ;; Most files are distributed under bsd-3, but ocaml_stuff/* is under qpl.
    (license (list license:bsd-3 license:qpl))))

(define-public hevea
  (package
    (name "hevea")
    (version "2.36")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://hevea.inria.fr/old/"
                                  "hevea-" version ".tar.gz"))
              (sha256
               (base32
                "0j06f8gb8f5is34kzmzy3znb0jkm2qd2l6rcl5v5qa9af3bmjrsx"))))
    (build-system gnu-build-system)
    (inputs
     (list ocaml))
    (native-inputs
     (list ocamlbuild))
    (arguments
     `(#:tests? #f                      ; no test suite
       #:make-flags (list (string-append "PREFIX=" %output))
       #:phases (modify-phases %standard-phases
                  (delete 'configure)
                  (add-before 'build 'patch-/bin/sh
                    (lambda _
                      (substitute* "_tags"
                        (("/bin/sh") (which "sh")))
                      #t)))))
    (home-page "https://hevea.inria.fr/")
    (synopsis "LaTeX to HTML translator")
    (description
     "HeVeA is a LaTeX to HTML translator that generates modern HTML 5.  It is
written in Objective Caml.")
    (license license:qpl)))

(define-public ocaml-num
  (package
    (name "ocaml-num")
    (version "1.6")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ocaml/num")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1m0jvsjxar16bvmq0h3ad3cwnmjxn1wnjhqljya9hahv3dcg8s95"))))
    (build-system dune-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'fix-race
           (lambda _
             ;; There's a race between bng.o and bng_generic.c.  Both depend on
             ;; the architecture specific bng.c, but only the latter declares
             ;; the dependency.
             (mkdir-p "_build/default/src")
             (for-each
               (lambda (f)
                 (copy-file f (string-append "_build/default/" f)))
               (find-files "src" "bng_.*\\.c")))))))
    (home-page "https://github.com/ocaml/num")
    (synopsis "Arbitrary-precision integer and rational arithmetic")
    (description "OCaml-Num contains the legacy Num library for
arbitrary-precision integer and rational arithmetic that used to be part of
the OCaml core distribution.")
    (license license:lgpl2.1+))); with linking exception

(define-public emacs-tuareg
  (package
    (name "emacs-tuareg")
    (version "3.0.1-1.f0cb55f")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ocaml/tuareg")
             (commit "f0cb55f2177f6fc978d98d018910fe5b1890fe0c")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0f131fq2zgdzjvdy61wfi27laga3dl9fqdi0xv1v7qr8cqjnbfln")))
     )
    (build-system gnu-build-system)
    (arguments
     (list
      #:imported-modules `(,@%default-gnu-imported-modules
                           (guix build emacs-build-system)
                           (guix build emacs-utils))
      #:modules '((guix build gnu-build-system)
                  ((guix build emacs-build-system) #:prefix emacs:)
                  (guix build emacs-utils)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'make-git-checkout-writable
            (lambda _
              (for-each make-file-writable (find-files "."))))
          (delete 'configure)
          (add-before 'install 'fix-install-path
            (lambda _
              (substitute* "Makefile"
                (("/emacs/site-lisp")
                 (emacs:elpa-directory #$output)))))
          (add-after 'install 'post-install
            (lambda _
              (symlink "tuareg.el"
                       (string-append (emacs:elpa-directory #$output)
                                      "/tuareg-autoloads.el")))))))
    (native-inputs
     (list emacs-minimal opam))
    (home-page "https://github.com/ocaml/tuareg")
    (synopsis "OCaml programming mode, REPL, debugger for Emacs")
    (description "Tuareg helps editing OCaml code, to highlight important
parts of the code, to run an OCaml REPL, and to run the OCaml debugger within
Emacs.")
    (license license:gpl2+)))

(define-public ocaml-menhir
  (package
    (name "ocaml-menhir")
    (version "20250912")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://gitlab.inria.fr/fpottier/menhir.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1zjdhc3iqyz0kp08jahgby6jn1mng6ilz6kdwhkckck5n0q6g4a8"))))
    (build-system dune-build-system)
    (inputs
     (list ocaml))
    (arguments
     `(#:tests? #f)) ; No check target
    (properties `((ocaml4.07-variant . ,(delay (strip-ocaml4.07-variant ocaml-menhir)))))
    (home-page "https://gallium.inria.fr/~fpottier/menhir/")
    (synopsis "Parser generator")
    (description "Menhir is a parser generator.  It turns high-level grammar
specifications, decorated with semantic actions expressed in the OCaml
programming language into parsers, again expressed in OCaml.  It is based on
Knuth’s LR(1) parser construction technique.")
    ;; The file src/standard.mly and all files listed in src/mnehirLib.mlpack
    ;; that have an *.ml or *.mli extension are GPL licensed. All other files
    ;; are QPL licensed.
    (license (list license:gpl2+ license:qpl))))

(define-public ocaml-bigarray-compat
  (package
    (name "ocaml-bigarray-compat")
    (version "1.1.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/mirage/bigarray-compat")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0hif5baiwswdblymyfbxh9066pfqynlz5vj3b2brpn0a12k6i5fq"))))
    (build-system dune-build-system)
    (arguments
     `(#:tests? #f)); no tests
    (home-page "https://github.com/mirage/bigarray-compat")
    (synopsis "OCaml compatibility library")
    (description "This package contains a compatibility library for
@code{Stdlib.Bigarray} in OCaml.")
    (license license:isc)))

(define-public binsec
  (package
    (name "binsec")
    (version "0.10.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/binsec/binsec")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0mb7n20b1p2np9dchwwcv046ivsan0n2zssp4b8gi7bg5m2nq11m"))))
    (build-system dune-build-system)
    (arguments
      (list #:phases
            #~(modify-phases %standard-phases
                (add-after 'install 'wrap-programs
                  (lambda _
                    (let ((ocamlpath
                            `(,(string-append #$output "/lib/ocaml/site-lib")
                               ,@(search-path-as-string->list (getenv "OCAMLPATH")))))
                      (wrap-program (string-append #$output "/bin/" "binsec")
                                    `("OCAMLPATH" ":" prefix ,ocamlpath))))))))
    (inputs (list bash-minimal))
    (native-inputs (list gmp ocaml-qcheck ocaml-ounit2 z3))
    (propagated-inputs (list ocaml-dune-site
                             ocaml-base
                             ocaml-menhir
                             ocaml-graph
                             ocaml-zarith
                             ocaml-grain-dypgen
                             ocaml-toml
                             ocaml-z3))
    (synopsis "Binary-level analysis platform")
    (description
     "BINSEC is a binary analysis platform which implements analysis
techniques such as symbolic execution.  The goal of BINSEC is to improve
software security at the binary level through binary analysis.  BINSEC
is a research tool which relies on prior work in binary code analysis
at the intersection of formal methods, program analysis security and
software engineering.")
    (home-page "https://binsec.github.io/")
    (license license:lgpl2.1)))

(define-public unison
  (package
    (name "unison")
    (version "2.53.5")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/bcpierce00/unison")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1fy4c1wb6xn9gxdabs25yajbzik3amifyr7nzd4d9vn6r3gll9sw"))))
    (build-system dune-build-system)
    (propagated-inputs (list lablgtk3 zlib))
    (native-inputs (list ghostscript (texlive-local-tree '()) hevea lynx which))
    (arguments
     `(#:phases
         (modify-phases %standard-phases
           (add-before 'build 'writable-texmfvar
             ;; Generating font shapes requires a writable TEXMFVAR.
             (lambda _ (setenv "TEXMFVAR" "/tmp")))
           (add-after 'install 'install-doc
             (lambda* (#:key outputs #:allow-other-keys)
               (let ((doc (string-append (assoc-ref outputs "out")
                                         "/share/doc/unison")))
                 (mkdir-p doc)
                 ;; This file needs write-permissions, because it's
                 ;; overwritten by 'docs' during documentation generation.
                 (chmod "src/strings.ml" #o600)
                 (invoke "make" "docs"
                         "TEXDIRECTIVES=\\\\draftfalse")
                 (for-each (lambda (f)
                             (install-file f doc))
                           (map (lambda (ext)
                                  (string-append "doc/unison-manual." ext))
                                ;; Install only html documentation,
                                ;; since the build is currently
                                ;; non-reproducible with the ps, pdf,
                                ;; and dvi docs.
                                '(;; "ps" "pdf" "dvi"
                                  "html")))
                 #t))))))
    (home-page "https://www.cis.upenn.edu/~bcpierce/unison/")
    (synopsis "File synchronizer")
    (description
     "Unison is a file-synchronization tool.  It allows two replicas of
a collection of files and directories to be stored on different hosts
(or different disks on the same host), modified separately, and then
brought up to date by propagating the changes in each replica
to the other.")
    (license license:gpl3+)))

(define-public ocaml-findlib
  (package
    (name "ocaml-findlib")
    (version "1.9.5")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://download.camlcity.org/download/"
                                  "findlib" "-" version ".tar.gz"))
              (sha256
               (base32
                "0w9578j1561f5gi51sn2jgxm3kh3sn88cpannhdkqcdg1kk08iqd"))))
    (build-system gnu-build-system)
    (native-inputs
     (list m4 ocaml))
    (arguments
     `(#:tests? #f  ; no test suite
       #:parallel-build? #f
       #:make-flags (list "all" "opt")
       #:phases (modify-phases %standard-phases
                  (replace
                   'configure
                   (lambda* (#:key inputs outputs #:allow-other-keys)
                     (let ((out (assoc-ref outputs "out")))
                       (invoke
                        "./configure"
                        "-bindir" (string-append out "/bin")
                        "-config" (string-append out "/etc/ocamfind.conf")
                        "-mandir" (string-append out "/share/man")
                        "-sitelib" (string-append out "/lib/ocaml/site-lib")
                        "-with-toolbox"))))
                  (replace 'install
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let ((out (assoc-ref outputs "out")))
                        (invoke "make" "install"
                                (string-append "OCAML_CORE_STDLIB="
                                               out "/lib/ocaml/site-lib"))))))))
    (home-page "http://projects.camlcity.org/projects/findlib.html")
    (synopsis "Management tool for OCaml libraries")
    (description
     "The \"findlib\" library provides a scheme to manage reusable software
components (packages), and includes tools that support this scheme.  Packages
are collections of OCaml modules for which metainformation can be stored.  The
packages are kept in the file system hierarchy, but with strict directory
structure.  The library contains functions to look the directory up that
stores a package, to query metainformation about a package, and to retrieve
dependency information about multiple packages.  There is also a tool that
allows the user to enter queries on the command-line.  In order to simplify
compilation and linkage, there are new frontends of the various OCaml
compilers that can directly deal with packages.")
    (license license:x11)))

(define-public ocaml4.07-findlib
  (package
    (inherit ocaml-findlib)
    (name "ocaml4.07-findlib")
    (native-inputs
     (list m4 ocaml-4.07))))

(define-public ocaml4.09-findlib
  (package
    (inherit ocaml-findlib)
    (name "ocaml4.09-findlib")
    (native-inputs
     (list m4 ocaml-4.09))))

(define-public ocaml5.0-findlib
  (package
    (inherit ocaml-findlib)
    (name "ocaml5.0-findlib")
    (native-inputs
     (list m4 ocaml-5.0))))

(define-public ocaml-ounit2
  (package
    (name "ocaml-ounit2")
    (version "2.2.6")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/gildor478/ounit.git")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "04c841hpk2yij370w30w3pis8nibnr28v74mpq2qz7z5gb8l07p1"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-lwt ocaml-stdlib-shims))
    (home-page "https://github.com/gildor478/ounit")
    (synopsis "Unit testing framework for OCaml")
    (description "OUnit2 is a unit testing framework for OCaml.  It is similar
to JUnit and other XUnit testing frameworks.")
    (license license:expat)))

;; note that some tests may hang for no obvious reason.
(define-public ocaml-ounit
  (package
    (inherit ocaml-ounit2)
    (name "ocaml-ounit")
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (replace 'install
           (lambda _
             (invoke "make" "install-ounit" ,(string-append "version="
                                                            (package-version ocaml-ounit2))))))))
    (propagated-inputs
     (list ocaml-ounit2))
    (home-page "http://ounit.forge.ocamlcore.org")
    (synopsis "Unit testing framework for OCaml")
    (description "Unit testing framework for OCaml.  It is similar to JUnit and
other XUnit testing frameworks.")
    (license license:expat)))

(define-public ocaml-junit
  (package
    (name "ocaml-junit")
    (version "2.0.2")
    (home-page "https://github.com/Khady/ocaml-junit")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url home-page)
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1cam7zzarrh9p1l5m3ba3h5rkh9mhark8j37rjgw35a66qd0gds1"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "junit"
       #:phases (modify-phases %standard-phases
                  (add-before 'build 'dune-subst
                    (lambda _
                      (invoke "dune" "subst") #t)))))
    (properties `((upstream-name . "junit")))
    (propagated-inputs (list ocaml-ounit ocaml-ptime ocaml-tyxml))
    (synopsis "JUnit XML reports generation library")
    (description "Ocaml-junit is a package for the creation of JUnit XML
reports.  It provides a typed API to produce valid reports.  They are supposed
to be accepted by Jenkins.")
    ;; with OCaml linking exception
    (license license:gpl3+)))

(define-public ocaml-junit-alcotest
  (package
    (inherit ocaml-junit)
    (name "ocaml-junit-alcotest")
    (propagated-inputs (list ocaml-alcotest ocaml-junit))
    (build-system dune-build-system)
    (arguments
     `(#:package "junit_alcotest"
       #:tests? #f)); tests fail
    (properties `((upstream-name . "junit_alcotest")))
    (synopsis "JUnit XML reports generation for alcotest tests")
    (description "This package generates JUnit XML reports from ocaml-alcotest
test suites.")
    ;; with OCaml linking exception
    (license license:gpl3+)))

(define-public camlzip
  (package
    (name "camlzip")
    (version "1.11")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/xavierleroy/camlzip")
                     (commit (string-append
                               "rel"
                               (string-join (string-split version #\.) "")))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "16jnn3czxnvyjngnz167x5kw097k7izdqvkix8qvgvhdmgvqm89b"))))
    (build-system ocaml-build-system)
    (inputs
     (list zlib))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (delete 'configure))
       #:install-target "install-findlib"
       #:make-flags
       ,#~(list "all" "allopt"
                (string-append "INSTALLDIR=" #$output "/lib/ocaml"))))
    (home-page "https://github.com/xavierleroy/camlzip")
    (synopsis "Provides easy access to compressed files")
    (description "Provides easy access to compressed files in ZIP, GZIP and
JAR format.  It provides functions for reading from and writing to compressed
files in these formats.")
    (license license:lgpl2.1+)))

(define-public ocamlmod
  (package
    (name "ocamlmod")
    (version "0.0.9")
    (source (origin
              (method url-fetch)
              (uri (ocaml-forge-uri name version 1702))
              (sha256
               (base32
                "0cgp9qqrq7ayyhddrmqmq1affvfqcn722qiakjq4dkywvp67h4aa"))))
    (build-system ocaml-build-system)
    (native-inputs
     `(("ounit" ,ocaml-ounit)
       ("ocamlbuild" ,ocamlbuild)))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         ;; Tests are done during build.
         (delete 'check))))
    (home-page "https://forge.ocamlcore.org/projects/ocamlmod")
    (synopsis "Generate modules from OCaml source files")
    (description "Generate modules from OCaml source files.")
    (license license:lgpl2.1+))) ; with an exception

(define-public ocaml-zarith
  (package
    (name "ocaml-zarith")
    (version "1.14")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ocaml/Zarith")
                     (commit (string-append "release-" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32 "10fjr5ahxl7clikj17wfqj1c7yrvksc0vfzc52vfbwlcpw7c2jn5"
                       ))))
    (build-system ocaml-build-system)
    (native-inputs
     (list perl))
    (inputs
     (list gmp))
    (arguments
     `(#:tests? #f ; no test target
       #:phases
       (modify-phases %standard-phases
         (replace 'configure
           (lambda _ (invoke "./configure")))
         (add-after 'install 'move-sublibs
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (lib (string-append out "/lib/ocaml/site-lib")))
               (mkdir-p (string-append lib "/stublibs"))
               (rename-file (string-append lib "/zarith/dllzarith.so")
                            (string-append lib "/stublibs/dllzarith.so"))))))))
    (home-page "https://forge.ocamlcore.org/projects/zarith/")
    (synopsis "Implements arbitrary-precision integers")
    (description "Implements arithmetic and logical operations over
arbitrary-precision integers.  It uses GMP to efficiently implement arithmetic
over big integers. Small integers are represented as Caml unboxed integers,
for speed and space economy.")
    (license license:lgpl2.1+))) ; with an exception

(define-public ocaml-frontc
  (package
    (name "ocaml-frontc")
    (version "4.1.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/BinaryAnalysisPlatform/FrontC")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1mi1vh4qgscnb470qwidccaqd068j1bqlz6pf6wddk21paliwnqb"))))
    (build-system dune-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'make-writable
           (lambda _
             (for-each make-file-writable (find-files "." ".")))))))
    (native-inputs
     (list ocaml-menhir))
    (properties `((upstream-name . "FrontC")))
    (home-page "https://www.irit.fr/FrontC")
    (synopsis "C parser and lexer library")
    (description "FrontC is an OCAML library providing a C parser and lexer.
The result is a syntactic tree easy to process with usual OCAML tree management.
It provides support for ANSI C syntax, old-C K&R style syntax and the standard
GNU CC attributes.  It provides also a C pretty printer as an example of use.")
    (license license:lgpl2.1)))

(define-public ocaml-qcheck
  (package
    (name "ocaml-qcheck")
    (version "0.26")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/c-cube/qcheck")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "05jb99ijpf06d0ws5xjkkk78xmbj93bsza1szahx8vcbxmlzv5h1"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-alcotest ocaml-ounit ocaml-ppxlib))
    (native-inputs
     (list ocamlbuild))
    (home-page "https://github.com/c-cube/qcheck")
    (synopsis "QuickCheck inspired property-based testing for OCaml")
    (description "QuickCheck inspired property-based testing for OCaml. This
module checks invariants (properties of some types) over randomly
generated instances of the type. It provides combinators for generating
instances and printing them.")
    (license license:lgpl3+)))

(define-public ocaml-qtest
  (package
    (name "ocaml-qtest")
    (version "2.11.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/vincent-hugot/qtest/")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "04ghjshh6104xyglm0db9kv90m62qla5f4bfrlndv6dsvgw3rdjl"))))
    (build-system dune-build-system)
    (propagated-inputs
     `(("ounit" ,ocaml-ounit)
       ("qcheck" ,ocaml-qcheck)))
    (home-page "https://github.com/vincent-hugot/qtest")
    (synopsis "Inline (Unit) Tests for OCaml")
    (description "Qtest extracts inline unit tests written using a special
syntax in comments.  Those tests are then run using the oUnit framework and the
qcheck library.  The possibilities range from trivial tests -- extremely simple
to use -- to sophisticated random generation of test cases.")
    (license license:lgpl3+)))

(define-public ocaml-stringext
  (package
    (name "ocaml-stringext")
    (version "1.6.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/rgrinberg/stringext")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1m09cmn3vrk3gdm60fb730qsygcfyxsyv7gl9xfzck08q1x2x9qx"))))
    (build-system dune-build-system)
    (native-inputs
     `(("ocamlbuild" ,ocamlbuild)
       ("qtest" ,ocaml-qtest)))
    (home-page "https://github.com/rgrinberg/stringext")
    (synopsis "Extra string functions for OCaml")
    (description "Provides a single module named Stringext that provides a grab
bag of often used but missing string functions from the stdlib.  E.g, split,
full_split, cut, rcut, etc..")
    ;; the only mention of a license in this project is in its `opam' file
    ;; where it says `mit'.
    (license license:expat)))

(define-public dune-bootstrap
  (package
    (name "dune")
    (version "3.20.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ocaml/dune")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1z4ji0jwwwxsx0ffw0klnkvaql8m2mqyi9h308y23waaf8dr3g94"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:tests? #f; require odoc
       #:make-flags ,#~(list "release"
                             (string-append "PREFIX=" #$output)
                             (string-append "LIBDIR=" #$output
                                            "/lib/ocaml/site-lib"))
       #:phases
       (modify-phases %standard-phases
         (replace 'configure
           (lambda* (#:key outputs #:allow-other-keys)
             (mkdir-p "src/dune")
             (invoke "./configure")
             #t)))))
    (home-page "https://github.com/ocaml/dune")
    (synopsis "OCaml build system")
    (description "Dune is a build system for OCaml.  It provides a consistent
experience and takes care of the low-level details of OCaml compilation.
Descriptions of projects, libraries and executables are provided in
@file{dune} files following an s-expression syntax.")
    (properties '((hidden? . #t)))
    (license license:expat)))

(define-public ocaml4.09-dune-bootstrap
  (package-with-ocaml4.09 dune-bootstrap))

(define-public ocaml5.0-dune-bootstrap
  (package-with-ocaml5.0 dune-bootstrap))

(define-public dune-configurator
  (package
    (inherit dune-bootstrap)
    (name "dune-configurator")
    (build-system dune-build-system)
    (arguments
     `(#:package "dune-configurator"
       #:dune ,dune-bootstrap
       ; require ppx_expect
       #:tests? #f
       #:phases
       (modify-phases %standard-phases
         ;; When building dune, these directories are normally removed after
         ;; the bootstrap.
         (add-before 'build 'remove-vendor
           (lambda _
             (delete-file-recursively "vendor/csexp")
             (delete-file-recursively "vendor/pp"))))))
    (propagated-inputs
     (list ocaml-csexp))
    (properties `((ocaml4.09-variant . ,(delay ocaml4.09-dune-configurator))
                  (ocaml5.0-variant . ,(delay ocaml5.0-dune-configurator))))
    (synopsis "Dune helper library for gathering system configuration")
    (description "Dune-configurator is a small library that helps writing
OCaml scripts that test features available on the system, in order to generate
config.h files for instance.  Among other things, dune-configurator allows one to:

@itemize
@item test if a C program compiles
@item query pkg-config
@item import #define from OCaml header files
@item generate config.h file
@end itemize")))

(define-public ocaml4.09-dune-configurator
  (package
    (inherit dune-configurator)
    (name "ocaml4.09-dune-configurator")
    (arguments
     `(,@(package-arguments dune-configurator)
       #:dune ,ocaml4.09-dune-bootstrap
       #:ocaml ,ocaml-4.09
       #:findlib ,ocaml4.09-findlib))
    (propagated-inputs
     `(("ocaml-csexp" ,ocaml4.09-csexp)))))

(define-public ocaml5.0-dune-configurator
  (package
    (inherit dune-configurator)
    (name "ocaml5.0-dune-configurator")
    (arguments
     `(,@(package-arguments dune-configurator)
       #:dune ,ocaml5.0-dune-bootstrap
       #:ocaml ,ocaml-5.0
       #:findlib ,ocaml5.0-findlib))
    (propagated-inputs (list ocaml5.0-csexp))))

(define-public dune
  (package
    (inherit dune-bootstrap)
    (propagated-inputs
     (list dune-configurator))
    (properties `((ocaml4.07-variant . ,(delay ocaml4.07-dune))
                  (ocaml4.09-variant . ,(delay ocaml4.09-dune))
                  (ocaml5.0-variant . ,(delay ocaml5.0-dune))))))

(define-public ocaml4.09-dune
  (package
    (inherit ocaml4.09-dune-bootstrap)
    (propagated-inputs
     (list dune-configurator))))

(define-public ocaml4.07-dune
  (package
    (inherit (package-with-ocaml4.07 dune-bootstrap))
    (version "1.11.3")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ocaml/dune")
                     (commit version)))
              (file-name (git-file-name "dune" version))
              (sha256
               (base32
                "0l4x0x2fz135pljv88zj8y6w1ninsqw0gn1mdxzprd6wbxbyn8wr"))))))

(define-public ocaml5.0-dune
  (package
    (inherit ocaml5.0-dune-bootstrap)
    (propagated-inputs
     (list ocaml5.0-dune-configurator))))

(define-public ocaml-pp
  (package
    (name "ocaml-pp")
    (version "2.0.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ocaml-dune/pp")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1gfd6hrb031qzb54v2zhlfxs54x0vnbaj6a8as07pvpwx7qznyss"))))
    (build-system dune-build-system)
    (native-inputs (list ocaml-ppx-expect))
    (home-page "https://github.com/ocaml-dune/pp")
    (synopsis "Pretty-printing library")
    (description
     "This library provides an alternative to the @code{Format} module of the OCaml
standard library.  Pp uses the same concepts of boxes and break hints, and the
final rendering is done to formatter from the @code{Format} module.  However it
defines its own algebra which some might find easier to work with and reason
about.")
    (license license:expat)))

(define-public dune-ordering
  (package
    (inherit dune)
    (name "dune-ordering")
    (source (origin
              (inherit (package-source dune))
              (modules '((guix build utils)))
              (snippet
                `(begin
                   (delete-file-recursively "vendor/pp")
                   (delete-file-recursively "vendor/csexp")))))
    (build-system dune-build-system)
    (arguments
     `(#:package "ordering"
       ;; Tests have a cyclic dependency on stdune
       #:tests? #f))
    (properties '())
    (synopsis "Dune element ordering")
    (description "This library represents element ordering in OCaml.")))

(define-public dune-dyn
  (package
    (inherit dune-ordering)
    (name "dune-dyn")
    (build-system dune-build-system)
    (arguments
     `(#:package "dyn"
       ;; Tests have a cyclic dependency on stdune
       #:tests? #f))
    (propagated-inputs (list ocaml-pp dune-ordering))
    (synopsis "Dune dynamic types")
    (description "This library represents dynamic types in OCaml.")))

(define-public dune-stdune
  (package
    (inherit dune-ordering)
    (name "dune-stdune")
    (build-system dune-build-system)
    (arguments
     `(#:package "stdune"
       ;; Tests have a cyclic dependency on itself
       #:tests? #f))
    (propagated-inputs (list dune-dyn ocaml-pp))
    (synopsis "Unstable standard library from Dune")
    (description "This library implements the standard functions used by Dune.")))

(define-public dune-private-libs
  (package
    (inherit dune-ordering)
    (name "dune-private-libs")
    (build-system dune-build-system)
    (arguments
     `(#:package "dune-private-libs"
       #:tests? #f))
    (native-inputs (list dune-stdune ocaml-ppx-expect ocaml-ppx-inline-test))
    (synopsis "Private libraries of Dune")
    (description "This package contains code that is shared between various
dune packages.  However, it is not meant for public consumption and provides
no stability guarantee.")))

(define-public ocaml-dune-site
  (package
    (inherit dune-ordering)
    (name "ocaml-dune-site")
    (build-system dune-build-system)
    (arguments
     `(#:package "dune-site"
       #:tests? #f))
    (propagated-inputs (list dune-private-libs ocaml-lwt))
    (synopsis "Location information embedder")
    (description "This library helps embed location information inside
executables and libraries")))

(define-public ocaml-csexp
  (package
    (name "ocaml-csexp")
    (version "1.5.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ocaml-dune/csexp")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1v5y4x1a21193h8q536c0s0d8hv3hyyky4pgzm2dw9807v36s2x4"))))
    (build-system dune-build-system)
    (arguments
     `(#:tests? #f; FIXME: needs ppx_expect, but which version?
       #:dune ,dune-bootstrap
       #:phases
       (modify-phases %standard-phases
         (add-before 'build 'chmod
           (lambda _
             (for-each (lambda (file) (chmod file #o644)) (find-files "." ".*"))
             #t)))))
    ;; (propagated-inputs
    ;;  (list ocaml-result))
    (properties `((ocaml4.09-variant . ,(delay ocaml4.09-csexp))
                  (ocaml5.0-variant . ,(delay ocaml5.0-csexp))))
    (home-page "https://github.com/ocaml-dune/csexp")
    (synopsis "Parsing and printing of S-expressions in Canonical form")
    (description "This library provides minimal support for Canonical
S-expressions.  Canonical S-expressions are a binary encoding of
S-expressions that is super simple and well suited for communication
between programs.

This library only provides a few helpers for simple applications.  If
you need more advanced support, such as parsing from more fancy input
sources, you should consider copying the code of this library given
how simple parsing S-expressions in canonical form is.

To avoid a dependency on a particular S-expression library, the only
module of this library is parameterised by the type of S-expressions.")
    (license license:expat)))

(define-public ocaml4.09-csexp
  (package
    (inherit ocaml-csexp)
    (name "ocaml4.09-csexp")
    (arguments
     `(#:ocaml ,ocaml-4.09
       #:findlib ,ocaml4.09-findlib
       ,@(substitute-keyword-arguments (package-arguments ocaml-csexp)
           ((#:dune _) ocaml4.09-dune-bootstrap))))
    ;; (propagated-inputs
    ;;  `(("ocaml-result" ,ocaml4.09-result)))
    ))

(define-public ocaml5.0-csexp
  (package
    (inherit ocaml-csexp)
    (name "ocaml5.0-csexp")
    (arguments
     `(#:ocaml ,ocaml-5.0
       #:findlib ,ocaml5.0-findlib
       ,@(substitute-keyword-arguments (package-arguments ocaml-csexp)
           ((#:dune _) ocaml5.0-dune-bootstrap))))
    ;; (propagated-inputs
    ;;  `(("ocaml-result" ,ocaml5.0-result)))
    ))

(define-public ocaml4.14-migrate-parsetree
  (package
    (name "ocaml-migrate-parsetree")
    (version "2.4.0")
    (home-page "https://github.com/ocaml-ppx/ocaml-migrate-parsetree")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0a1qy0ik36j8hpqxvh3fxf4aibjqax989mihj73jncchv8qv4ynq"))))
    (build-system dune-build-system)
    (arguments `(#:tests? #f))
    (propagated-inputs
     (list ocaml-ppx-derivers ocamlbuild))
    (properties `((upstream-name . "ocaml-migrate-parsetree")))
    (synopsis "OCaml parsetree converter")
    (description "This library converts between parsetrees of different OCaml
versions.  For each version, there is a snapshot of the parsetree and conversion
functions to the next and/or previous version.")
    (license license:lgpl2.1+)))

(define-public ocaml-linenoise
  (package
    (name "ocaml-linenoise")
    (version "1.4.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ocaml-community/ocaml-linenoise")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1gk11pflal08kg2dz1b5zrlpnhbxpg2rwf8cknw3vzmq6gsmk2kc"))))
    (build-system dune-build-system)
    (arguments
     ;; No tests
     `(#:tests? #f))
    (home-page "https://github.com/ocaml-community/ocaml-linenoise")
    (synopsis "Lightweight readline alternative")
    (description "This package is a line-reading library for OCaml that aims
to replace readline.")
    (license license:bsd-2)))

(define-public ocaml-bitstring
  (package
    (name "ocaml-bitstring")
    (version "4.1.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/xguerin/bitstring")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0mghsl8b2zd2676mh1r9142hymhvzy9cw8kgkjmirxkn56wbf56b"))))
    (build-system dune-build-system)
    (native-inputs
     (list time autoconf automake))
    (propagated-inputs
     (list ocaml-stdlib-shims))
    (arguments
     `(#:package "bitstring"
       #:tests? #f; Tests fail to build
       #:phases
       (modify-phases %standard-phases
         (add-before 'build 'upgrade
           (lambda _
             (invoke "dune" "upgrade")
             #t)))))
    (home-page "https://github.com/xguerin/bitstring")
    (synopsis "Bitstrings and bitstring matching for OCaml")
    (description "Adds Erlang-style bitstrings and matching over bitstrings as
a syntax extension and library for OCaml.  You can use this module to both parse
and generate binary formats, files and protocols.  Bitstring handling is added
as primitives to the language, making it exceptionally simple to use and very
powerful.")
    (license license:isc)))

(define-public ocaml-ppx-bitstring
  (package
    (inherit ocaml-bitstring)
    (name "ocaml-ppx-bitstring")
    (arguments
     `(#:package "ppx_bitstring"
       ;; No tests
       #:tests? #f))
    (propagated-inputs (list ocaml-bitstring ocaml-ppxlib))
    (native-inputs (list ocaml-ounit))
    (properties `((upstream-name . "ppx_bitstring")))
    (synopsis "PPX extension for bitstrings and bitstring matching")
    (description
     "This package provides a way to write bitstrings and matching over
bitsrings in Erlang style as primitives to the language.")))

(define-public ocaml-result
  (package
    (name "ocaml-result")
    (version "1.5")
    (home-page
     "https://github.com/janestreet/result")
    (source
     (github-tag-origin
      name home-page version
      "166laj8qk7466sdl037c6cjs4ac571hglw4l5qpyll6df07h6a7q" ""
      ))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (propagated-inputs
     (list ocaml-jane-street-headers
           ocaml-ppx-base ocaml-ppx-optcomp ocaml-jst-config))
    (properties `((upstream-name . "result")))
    (synopsis "Compatibility result module")
    (description "Projects that want to use the new result type defined in OCaml >= 4.03 while staying compatible with older version of OCaml should use the Result module defined in this library.")
    (license license:bsd-3)))
;; (define-public ocaml-result
;;   (package
;;     (name "ocaml-result")
;;     (version "1.5")
;;     (source (origin
;;               (method git-fetch)
;;               (uri (git-reference
;;                      (url "https://github.com/janestreet/result")
;;                      (commit version)))
;;               (file-name (git-file-name name version))
;;               (sha256
;;                (base32
;;                 "166laj8qk7466sdl037c6cjs4ac571hglw4l5qpyll6df07h6a7q"))))
;;     (build-system dune-build-system)
;;     (arguments
;;      `(#:dune ,dune-bootstrap))
;;     (properties `((ocaml4.09-variant . ,(delay ocaml4.09-result))
;;                   (ocaml5.0-variant . ,(delay ocaml5.0-result))))
;;     (home-page "https://github.com/janestreet/result")
;;     (synopsis "Compatibility Result module")
;;     (description "Uses the new result type defined in OCaml >= 4.03 while
;; staying compatible with older version of OCaml should use the Result module
;; defined in this library.")
;;     (license license:bsd-3)))

;; (define-public ocaml4.09-result
;;   (package
;;     (inherit ocaml-result)
;;     (name "ocaml4.09-result")
;;     (arguments
;;      `(#:dune ,ocaml4.09-dune-bootstrap
;;        #:ocaml ,ocaml-4.09
;;        #:findlib ,ocaml4.09-findlib))))

;; (define-public ocaml5.0-result
;;   (package
;;     (inherit ocaml-result)
;;     (name "ocaml5.0-result")
;;     (arguments
;;      `(#:dune ,ocaml5.0-dune-bootstrap
;;        #:ocaml ,ocaml-5.0
;;        #:findlib ,ocaml5.0-findlib))))

(define-public ocaml-iso8601
  (package
    (name "ocaml-iso8601")
    (version "0.2.6")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ocaml-community/ISO8601.ml")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0nzadswspizi7s6sf67icn2xgc3w150x8vdg5nk1mjrm2s98n6d3"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-stdlib-shims ocaml-core-unix ocaml-ounit))
    (synopsis "Parser and printer for date-times in ISO8601")
    (description "This package allows parsing of dates that follow the ISO 8601
and RFC 3339 formats in OCaml.")
    (home-page "https://github.com/ocaml-community/ISO8601.ml")
    (license license:expat)))

(define-public ocaml-toml
  (package
    (name "ocaml-toml")
    (version "7.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ocaml-toml/To.ml")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0z2873mj3i6h9cg8zlkipcjab8jympa4c4avhk4l04755qzphkds"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-base ocaml-mdx ocaml-menhir ocaml-iso8601))
    (synopsis "TOML library for OCaml")
    (description
     "This package provides an OCaml library for interacting with files
in the @acronym{TOML, Tom's Obvious Minimal Language} format.  Specifically,
it provides a parser, a serializer, and a pretty printer.")
    (home-page "https://github.com/ocaml-toml/To.ml")
    (license license:expat)))

(define-public ocaml-grain-dypgen
  (package
    (name "ocaml-grain-dypgen")
    (version "0.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/grain-lang/dypgen")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1jyxkvi75nchk5kmhqixmjy70z55gmlqa83pxn0hsv2qxvyqxavw"))))
    (build-system ocaml-build-system)
    (arguments
     (list
      ;; Upstream does not have a test suite.
      #:tests? #f
      #:make-flags #~(let ((out #$output))
                       (list (string-append "OCAMLLIBDIR=" out
                                            "/lib/ocaml/site-lib")
                             (string-append "BINDIR=" out "/bin")
                             (string-append "MANDIR=" out "/share/man")))
      #:phases #~(modify-phases %standard-phases
                   (delete 'configure))))
    (properties `((upstream-name . "grain_dypgen")))
    (home-page "https://github.com/grain-lang/dypgen")
    (synopsis "Self-extensible parsers and lexers for OCaml")
    (description
     "This package provides a @acronym{GLR, generalized LR} parser generator
for OCaml.  It is able to generate self-extensible parsers (also called
adaptive parsers) as well as extensible lexers for the parsers it produces.")
    (license license:cecill-b)))

(define-public ocaml-topkg
  (package
    (name "ocaml-topkg")
    (version "1.0.6")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://erratique.ch/software/topkg/releases/"
                                  "topkg-" version ".tbz"))
              (sha256
               (base32
                "11ycfk0prqvifm9jca2308gw8a6cjb1hqlgfslbji2cqpan09kpq"))))
    (build-system ocaml-build-system)
    (native-inputs
     (list ocamlbuild))
    ;; (propagated-inputs
    ;;  `(("result" ,ocaml-result)))
    (arguments
     `(#:tests? #f
       #:build-flags '("build")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             ;; Use ocamlfind install to avoid circular dependency on opam-installer
             (let ((lib (string-append (assoc-ref outputs "out")
                                       "/lib/ocaml/site-lib")))
               (mkdir-p lib)
               (with-directory-excursion "_build"
                 (invoke "ocamlfind" "install" "topkg"
                         "../pkg/META"
                         "src/topkg.a"
                         "src/topkg.cma"
                         "src/topkg.cmxa"
                         "src/topkg.cmxs"
                         "src/topkg.cmx"
                         "src/topkg.cmi"
                         "src/topkg.mli"))))))))
    (home-page "https://erratique.ch/software/topkg")
    (synopsis "Transitory OCaml software packager")
    (description "Topkg is a packager for distributing OCaml software. It
provides an API to describe the files a package installs in a given build
configuration and to specify information about the package's distribution,
creation and publication procedures.")
    (license license:isc)))

(define-public ocaml-rresult
  (package
    (name "ocaml-rresult")
    (version "0.7.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://erratique.ch/software/rresult/releases/"
                                  "rresult-" version ".tbz"))
              (sha256
               (base32
                "0h2mjyzhay1p4k7n0mzaa7hlc7875kiy6m1i3r1n03j6hddpzahi"))))
    (build-system ocaml-build-system)
    (native-inputs
     (list ocamlbuild))
    (propagated-inputs
     `(("topkg" ,ocaml-topkg)))
    (arguments
     `(#:tests? #f
       #:build-flags '("build")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             ;; Use ocamlfind install to avoid circular dependency on opam-installer
             (let ((lib (string-append (assoc-ref outputs "out")
                                       "/lib/ocaml/site-lib")))
               (mkdir-p lib)
               (with-directory-excursion "_build"
                 (invoke "ocamlfind" "install" "rresult"
                         "../pkg/META"
                         "src/rresult.a"
                         "src/rresult.cma"
                         "src/rresult.cmxa"
                         "src/rresult.cmxs"
                         "src/rresult.cmx"
                         "src/rresult.cmi"
                         "src/rresult.mli"))))))))
    (home-page "https://erratique.ch/software/rresult")
    (synopsis "Result value combinators for OCaml")
    (description "Handle computation results and errors in an explicit and
declarative manner, without resorting to exceptions.  It defines combinators
to operate on the result type available from OCaml 4.03 in the standard
library.")
    (license license:isc)))

(define-public ocaml-sqlite3
  (package
    (name "ocaml-sqlite3")
    (version "5.3.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/mmottl/sqlite3-ocaml")
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0ypmds18izb6v6qyv9ly1imb8y2lvw0bv4ckb4zgzfjyhkd11wnk"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list dune-configurator))
    (native-inputs
     (list ocaml-ppx-inline-test pkg-config sqlite))
    (home-page "https://mmottl.github.io/sqlite3-ocaml")
    (synopsis "SQLite3 Bindings for OCaml")
    (description
     "SQLite3-OCaml is an OCaml library with bindings to the SQLite3 client
API.  Sqlite3 is a self-contained, serverless, zero-configuration,
transactional SQL database engine with outstanding performance for many use
cases.  These bindings are written in a way that enables a friendly
coexistence with the old (version 2) SQLite and its OCaml wrapper
@code{ocaml-sqlite}.")
    (license license:expat)))

(define-public ocaml-csv
  (package
    (name "ocaml-csv")
    (version "2.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/Chris00/ocaml-csv")
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0y2hlqlmqs7r4y5mfzc5qdv7gdp3wxbwpz458vf7fj4593vg94cf"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "csv"))
    (home-page "https://github.com/Chris00/ocaml-csv")
    (synopsis "Pure OCaml functions to read and write CSV")
    (description
     "@dfn{Comma separated values} (CSV) is a simple tabular format supported
by all major spreadsheets.  This library implements pure OCaml functions to
read and write files in this format as well as some convenience functions to
manipulate such data.")
    ;; This is LGPLv2.1 with an exception that allows packages statically-linked
    ;; against the library to be released under any terms.
    (license license:lgpl2.1)))

(define-public ocaml-mtime
  (package
    (name "ocaml-mtime")
    (version "2.1.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://erratique.ch/software/mtime/releases/"
                                  "mtime-" version ".tbz"))
              (sha256
               (base32
                "122dhf4qmba4kfpzljcllgqf5ii8b8ylh6rfazcyl09p5s0b4z09"))))
    (build-system ocaml-build-system)
    (native-inputs
     (list ocamlbuild))
    (propagated-inputs
     `(("topkg" ,ocaml-topkg)))
    (home-page "https://erratique.ch/software/mtime")
    (synopsis "Monotonic wall-clock time for OCaml")
    (description "Access monotonic wall-clock time.  It measures time
spans without being subject to operating system calendar time adjustments.")
    (license license:isc)
    (arguments
     `(#:tests? #f
       #:build-flags (list "build")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (lib (string-append out "/lib/ocaml/site-lib"))
                    (mtime-lib (string-append lib "/mtime"))
                    (clock-lib (string-append mtime-lib "/clock")))
               (mkdir-p lib)
               (with-directory-excursion "_build"
                 ;; Install main library
                 (invoke "ocamlfind" "install" "mtime"
                         "../pkg/META"
                         "src/mtime.a"
                         "src/mtime.cma"
                         "src/mtime.cmxa"
                         "src/mtime.cmxs"
                         "src/mtime.cmx"
                         "src/mtime.cmi"
                         "../src/mtime.mli"))
               ;; Install clock sublibrary manually
               (mkdir-p clock-lib)
               (for-each
                (lambda (file)
                  (install-file file clock-lib))
                (find-files "_build/src/clock"
                            "\\.(cma|cmxa|a|cmxs|cmi|cmx|so)$"))
               ;; Install .mli from source
               (install-file "src/clock/mtime_clock.mli" clock-lib)))))))))

(define-public ocaml-calendar
  (package
    (name "ocaml-calendar")
    (version "3.0.0")
    (home-page
     "https://github.com/ocaml-community/calendar")
    (source
     (github-tag-origin
      name home-page version
      "0jw8sdz1kl53fzdyxixd8ljfr25vvn4f2z4lspasqcj4ma5k6m7r" "v"))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (propagated-inputs (list ocaml-re))
    (properties `((upstream-name . "time_now")))
      (synopsis "OCaml library for handling dates and times")
      (description "This package provides types and operations over
dates and times.")
      ;; With linking exception.
      (license license:lgpl2.1+)
    ))

(define-public ocaml-int-repr
  (package
    (name "ocaml-int-repr")
    (version "0.17.0")
    (home-page
     "https://github.com/janestreet/int_repr")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/janestreet/int_repr")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "008gmlc5bw7gi15kgijmcrx9wkq9gh6rch0gldq1vk3r1z7q1rn9"))
       (modules '((guix build utils)))
       (snippet
        #~(begin
            ;; Remove [@@deriving globalize] annotations
            (substitute* (find-files "." "\\.(ml|mli)$")
              (("\\[@@deriving globalize\\]") "")
              ((", globalize") ""))))))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (propagated-inputs (list ocaml-base ocaml-ppx-jane))
    (properties `((upstream-name . "int_repr")))
    (synopsis "Integers of various widths")
    (description "Integers of various widths.")
    (license license:expat)))

(define-public ocaml-ppx-helpers
  (package
    (name "ocaml-ppx-helpers")
    (version "0.0.0-1.21ca9e2")
    (home-page "https://github.com/janestreet/ppx_helpers")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/janestreet/ppx_helpers")
             (commit "21ca9e2")))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0fw602infxk9jwzi9sl5n3fx2z7b7nrcpk1z9cysg7f3d8flz0kk"
         ))))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (propagated-inputs (list ocaml-ppxlib ocaml-ppxlib-jane))
    (synopsis "Helper functions for ppx rewriters")
    (description "This library provides helper functions for writing ppx rewriters.")
    (license license:expat)))

(define-public ocaml-ppx-globalize
  (package
    (name "ocaml-ppx-globalize")
    (version "0.17.2")
    (home-page
     "https://github.com/janestreet/ppx_globalize")
    (source
     (github-tag-origin
      name home-page version
      "0ajxbfwvckwn6d11bbrfjs3hb74wvh210lxg3d97l3bqzz5fm4g6"
      "v"))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (propagated-inputs (list ocaml-ppxlib ocaml-ppxlib-jane ocaml-base))
    (synopsis
     " A ppx rewriter that generates functions to copy local values to the global heap "
     )
    (description
     " A ppx rewriter that generates functions to copy local values to the global heap ")
      (license license:expat)
    ))

(define-public ocaml-cmdliner
  (package
    (name "ocaml-cmdliner")
    (version "2.0.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://erratique.ch/software/cmdliner/releases/"
                                  "cmdliner-" version ".tbz"))
              (sha256
               (base32
                "10l56xl7ibhbjljvfbz9fji3py5k9rrdffqdyvgsmyrn3iiplm2f"))))
    (build-system dune-build-system)
    ;; (propagated-inputs
    ;;  (list ocaml-result))
    (arguments `(#:tests? #f))
    (home-page "https://erratique.ch/software/cmdliner")
    (synopsis "Declarative definition of command line interfaces for OCaml")
    (description "Cmdliner is a module for the declarative definition of command
line interfaces.  It provides a simple and compositional mechanism to convert
command line arguments to OCaml values and pass them to your functions.  The
module automatically handles syntax errors, help messages and UNIX man page
generation. It supports programs with single or multiple commands and respects
most of the POSIX and GNU conventions.")
    (license license:bsd-3)))

(define-public ocaml-cmdliner-1.3
  (package
    (name "ocaml-cmdliner-1.3")
    (version "1.3.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://erratique.ch/software/cmdliner/releases/"
                                  "cmdliner-" version ".tbz"))
              (sha256
               (base32
                "1fwc2rj6xfyihhkx4cn7zs227a74rardl262m2kzch5lfgsq10cf"))))
    (build-system dune-build-system)
    ;; (propagated-inputs
    ;;  (list ocaml-result))
    (arguments `(#:tests? #f))
    (home-page "https://erratique.ch/software/cmdliner")
    (synopsis "Declarative definition of command line interfaces for OCaml")
    (description "Cmdliner is a module for the declarative definition of command
line interfaces.  It provides a simple and compositional mechanism to convert
command line arguments to OCaml values and pass them to your functions.  The
module automatically handles syntax errors, help messages and UNIX man page
generation. It supports programs with single or multiple commands and respects
most of the POSIX and GNU conventions.")
    (license license:bsd-3)))

(define-public ocaml-fmt
  (package
    (name "ocaml-fmt")
    (version "0.11.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "http://erratique.ch/software/fmt/releases/fmt-"
                            version ".tbz"))
        (sha256 (base32
                  "06va6zalm61g2zkyqns37fyx2g0p8ig6dqmkv6f44ljblm3zsz45"))))
    (build-system ocaml-build-system)
    (native-inputs
     (list ocamlbuild ocaml-topkg))
    (propagated-inputs
     (list ocaml-cmdliner
           ocaml-stdlib-shims
           ocaml-uchar))
    (arguments `(#:tests? #f
                 #:build-flags (list "build" "--with-base-unix" "true"
                                     "--with-cmdliner" "true")
                 #:phases
                 (modify-phases %standard-phases
                   (delete 'configure)
                   (replace 'install
                     (lambda* (#:key outputs #:allow-other-keys)
                       ;; Use ocamlfind install with subdirs for sub-packages
                       (let* ((out (assoc-ref outputs "out"))
                              (lib (string-append out "/lib/ocaml/site-lib/fmt")))
                         (with-directory-excursion "_build"
                           ;; Install main library
                           (invoke "ocamlfind" "install" "fmt" "../pkg/META"
                                   "src/fmt.a" "src/fmt.cma" "src/fmt.cmxa"
                                   "src/fmt.cmxs" "src/fmt.cmx"
                                   "src/fmt.cmi" "src/fmt.mli")
                           ;; Manually create subdirectories and install sub-libraries
                           (mkdir-p (string-append lib "/tty"))
                           (mkdir-p (string-append lib "/cli"))
                           (mkdir-p (string-append lib "/top"))
                           ;; Copy tty files
                           (for-each (lambda (f)
                                       (copy-file f (string-append lib "/tty/" (basename f))))
                                     (find-files "src/tty" "\\.(cma|cmxa|a|cmxs|cmx|cmi|mli)$"))
                           ;; Copy cli files
                           (for-each (lambda (f)
                                       (copy-file f (string-append lib "/cli/" (basename f))))
                                     (find-files "src/cli" "\\.(cma|cmxa|a|cmxs|cmx|cmi|mli)$"))
                           ;; Copy top files
                           (for-each (lambda (f)
                                       (copy-file f (string-append lib "/top/" (basename f))))
                                     (find-files "src/top" "\\.(cma|cmxa|cmx|ml)$")))))))))
    (home-page "https://erratique.ch/software/fmt")
    (synopsis "OCaml Format pretty-printer combinators")
    (description "Fmt exposes combinators to devise Format pretty-printing
functions.")
    (license license:isc)))

(define-public ocaml-astring
  (package
    (name "ocaml-astring")
    (version "0.8.5")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "http://erratique.ch/software/astring/releases/astring-"
                            version ".tbz"))
        (sha256 (base32
                  "1ykhg9gd3iy7zsgyiy2p9b1wkpqg9irw5pvcqs3sphq71iir4ml6"))))
    (build-system ocaml-build-system)
    (native-inputs
     (list ocamlbuild ocaml-topkg))
    (arguments
     `(#:tests? #f
       #:build-flags (list "build")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             ;; Use ocamlfind install to avoid circular dependency on opam-installer
             (let ((lib (string-append (assoc-ref outputs "out")
                                       "/lib/ocaml/site-lib")))
               (mkdir-p lib)
               (with-directory-excursion "_build"
                 (invoke "ocamlfind" "install" "astring"
                         "../pkg/META"
                         "src/astring.a"
                         "src/astring.cma"
                         "src/astring.cmxa"
                         "src/astring.cmxs"
                         "src/astring.cmx"
                         "src/astring.cmi"
                         "src/astring.mli"))))))))
    (home-page "https://erratique.ch/software/astring")
    (synopsis "Alternative String module for OCaml")
    (description "Astring exposes an alternative String module for OCaml.  This
module balances minimality and expressiveness for basic, index-free, string
processing and provides types and functions for substrings, string sets and
string maps.  The String module exposed by Astring has exception safe functions,
removes deprecated and rarely used functions, alters some signatures and names,
adds a few missing functions and fully exploits OCaml's newfound string
immutability.")
    (license license:isc)))

(define-public ocaml-alcotest
  (package
    (name "ocaml-alcotest")
    (version "1.9.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mirage/alcotest")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "04jv75jkcxynz61bp0hwsk2147ydlgrgg3dc4xj99klm3xqad4bk"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "alcotest"))
    (native-inputs
     (list ocamlbuild))
    (propagated-inputs
     (list ocaml-astring
           ocaml-cmdliner
           ocaml-logs
           ocaml-fmt
           ocaml-re
           ocaml-stdlib-shims
           ocaml-uuidm
           ocaml-uutf))
    (home-page "https://github.com/mirage/alcotest")
    (synopsis "Lightweight OCaml test framework")
    (description "Alcotest exposes simple interface to perform unit tests.  It
exposes a simple TESTABLE module type, a check function to assert test
predicates and a run function to perform a list of unit -> unit test callbacks.
Alcotest provides a quiet and colorful output where only faulty runs are fully
displayed at the end of the run (with the full logs ready to inspect), with a
simple (yet expressive) query language to select the tests to run.")
    (license license:isc)))

(define-public ocaml-alcotest-lwt
  (package
    (inherit ocaml-alcotest)
    (name "ocaml-alcotest-lwt")
    (arguments
     `(#:package "alcotest-lwt"))
    (propagated-inputs (list ocaml-alcotest ocaml-lwt))
    )
 )

(define-public ocaml-expect-test-helpers-core
  (package
    (name "ocaml-expect-test-helpers-core")
    (version "0.17.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url
                     "https://github.com/janestreet/expect_test_helpers_core")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0rmvr0spshh1la6gglzhk501sh9qpnhqk1m56yfm091pr5kl6ydy"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-base
                             ocaml-base-quickcheck
                             ocaml-core
                             ocaml-ppx-jane
                             ocaml-sexp-pretty
                             ocaml-stdio
                             ocaml-re))
    (properties `((upstream-name . "expect_test_helpers_core")))
    (home-page "https://github.com/janestreet/expect_test_helpers_core")
    (synopsis "Helpers for writing expectation tests")
    (description "Helper functions for writing expect tests.")
    (license license:expat)))

(define-public ocaml-ppx-tools
  (package
    (name "ocaml-ppx-tools")
    (version "6.6")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/alainfrisch/ppx_tools")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1ms2i063cwsm8wcw7jixz3qx2f2prrmf0k44gbksvsgqvm1rl6s2"))))
    (build-system dune-build-system)
    (arguments
     ;; No tests
     `(#:tests? #f))
    (native-inputs
     (list ocaml-cppo))
    (properties `((upstream-name . "ppx_tools")))
    (home-page "https://github.com/alainfrisch/ppx_tools")
    (synopsis "Tools for authors of ppx rewriters and other syntactic tools")
    (description
     "Ppx_tools provides tools for authors of ppx rewriters and other
syntactic tools.")
    (license license:expat)))

(define-public ocaml-yaml
  (package
    (name "ocaml-yaml")
    (version "3.2.0")
    (home-page "https://github.com/avsm/ocaml-yaml")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url home-page)
              (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1m0i9qdazmziswfw1bz4m1x9mlzqyv336vbrss0c21am4im9n6k6"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ppx-sexp-conv ocaml-ctypes ocaml-bos))
    (native-inputs (list ocaml-fmt
                         ocaml-sexplib
                         ocaml-logs
                         ocaml-mdx
                         ocaml-alcotest
                         ocaml-crowbar
                         ocaml-junit-alcotest
                         ocaml-ezjsonm))
    (synopsis "Parse and generate YAML 1.1/1.2 files")
    (description
     "This package is an OCaml library to parse and generate the YAML file
format.  It is intended to be interoperable with the @code{Ezjsonm}
JSON handling library, if the simple common subset of Yaml is used.  Anchors and
other advanced Yaml features are not implemented in the JSON compatibility
layer.")
    (license license:isc)))

(define-public ocaml-ppx-deriving-yaml
  (package
    (name "ocaml-ppx-deriving-yaml")
    (version "0.2.1")
    (home-page "https://github.com/patricoferris/ppx_deriving_yaml")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url home-page)
              (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1cxcqgvyl4ykyl86mf2d4ka6frnq51m1yqy0z5v6vdxkixllf9jd"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ppxlib ocaml-ppx-deriving ocaml-yaml
                            ))
    (native-inputs (list ocaml-alcotest ocaml-bos ocaml-mdx ocaml-ezjsonm))
    (properties `((upstream-name . "ppx_deriving_yaml")))
    (synopsis "Yaml PPX Deriver")
    (description
     "This package contains @code{deriving} conversion functions to and from
yaml for OCaml types.")
    (license license:isc)))

(define-public ocaml-ppx-import
  (package
    (name "ocaml-ppx-import")
    (version "1.10.0")
    (home-page "https://github.com/ocaml-ppx/ppx_import")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url home-page)
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "06srfd6whfwkmjvl6m61kvc65fb7j9b25bhfr1mp338zm87smv5p"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ppx-deriving ocaml-ppxlib
                             ocaml-ppx-sexp-conv))
    (native-inputs (list ocaml-ounit ocaml-sexplib0))
    (properties `((upstream-name . "ppx_import")))
    (synopsis "Extension for importing declarations from interface files")
    (description
     "Ppx-import is a syntax extension for importing declarations from
interface files.")
    (license license:expat)))

(define-public ocaml-parmap
  (package
    (name "ocaml-parmap")
    (version "1.2.5")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/rdicosmo/parmap")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0x5gnfap9f7kmgh8j725vxlbkvlplwzbpn8jdx2ywfa3dd6bn6xl"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list))
    (home-page "https://github.com/rdicosmo/parmap")
    (synopsis "Parallel map and fold primitives for OCaml")
    (description
     "Library to perform parallel fold or map taking advantage of multiple
core architectures for OCaml programs.  Drop-in replacement for these
@code{List} operations are provided:

@itemize
@item @code{List.map} -> @code{parmap}
@item @code{List.map} -> @code{parfold}
@item @code{List.mapfold} -> @code{parmapfold}
@end itemize

Also it allows specifying the number of cores to use with the optional
parameter @code{ncores}.")
    (license (list license:lgpl2.0
                   (license:fsdg-compatible "file://LICENSE"
                                            "See LICENSE file for details")))))

(define-public ocaml-pyml
  ;; NOTE: Using commit from master branch as 20220905 does not support
  ;; Python 3.10.
  (let ((revision "0")
        (commit "e33f4c49cc97e7bc6f8e5faaa64cce994470642e"))
    (package
      (name "ocaml-pyml")
      (version (git-version "20220905" revision commit))
      (source
        (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/thierry-martinez/pyml")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "1v421i5cvj8mbgrg5cs78bz1yzdprm9r5r41niiy20d3j7j8jx9k"))))
      (build-system dune-build-system)
      (propagated-inputs
       (list ocaml-stdcompat
             python
             python-numpy))
      (home-page "https://github.com/thierry-martinez/pyml")
      (synopsis "Python bindings for OCaml")
      (description "Library that allows OCaml programs to interact with Python
modules and objects.  The library also provides low-level bindings to the
Python C API.

This library is an alternative to @code{pycaml} which is no longer
maintained.  The @code{Pycaml} module provides a signature close to
@code{pycaml}, to ease migration of code to this library.")
      (license license:bsd-2))))

(define-public ocaml-react
  (package
    (name "ocaml-react")
    (version "1.2.2")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "http://erratique.ch/software/react/releases/react-"
                            version ".tbz"))
        (sha256 (base32
                  "16cg4byj8lfbbw96dhh8sks5y9n1c3fshz7f2p8m7wgisqax7bf4"))))
    (build-system ocaml-build-system)
    (native-inputs
     (list ocamlbuild opam-installer ocaml-topkg))
    (arguments
     `(#:tests? #f
       #:build-flags (list "build")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))))
    (home-page "https://erratique.ch/software/react")
    (synopsis "Declarative events and signals for OCaml")
    (description "React is an OCaml module for functional reactive programming
(FRP).  It provides support to program with time varying values: declarative
events and signals.  React doesn't define any primitive event or signal, it
lets the client choose the concrete timeline.")
    (license license:bsd-3)))

(define-public ocaml-mmap
  (package
    (name "ocaml-mmap")
    (version "1.2.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/mirage/mmap")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1a7w7l682cbksn2zlmz24gb519x7wb65ivr5vndm9x5pi9fw5pfb"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-bigarray-compat))
    (home-page "https://github.com/mirage/mmap")
    (synopsis "File mapping for OCaml")
    (description "This project provides a @command{Mmap.map_file} function
for mapping files in memory.  This function is the same as the
@command{Unix.map_file} function added in OCaml >= 4.06.")
    (license (list license:qpl license:lgpl2.0))))

(define-public ocaml-psq
  (package
    (name "ocaml-psq")
    (version "0.2.1")
    (home-page "https://github.com/pqwy/psq")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url home-page)
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256 (base32
                 "0ahxbzkbq5sw8sqv31c2lil2zny4076q8b0dc7h5slq7i2r23d79"))))
    (build-system dune-build-system)
    (native-inputs (list ocaml-qcheck ocaml-alcotest))
    (synopsis "Functional Priority Search Queues for OCaml")
    (description
     "This library provides Functional Priority Search Queues for OCaml.
Typical applications are searches, schedulers and caches.")
    (license license:isc)))

(define-public ocaml-optint
  (package
    (name "ocaml-optint")
    (version "0.3.0")
    (home-page "https://github.com/mirage/optint")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url home-page)
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256 (base32
                 "1qj32bcw1in7s6raxdvbmjr3lvj99iwv98x1ar9cwxp4zf8ybfss"))))
    (build-system dune-build-system)
    (native-inputs (list ocaml-crowbar ocaml-monolith ocaml-fmt))
    (synopsis "Efficient integer types on 64-bit architectures for OCaml")
    (description
     "This OCaml library provides two new integer types, @code{Optint.t} and
@code{Int63.t}, which guarantee efficient representation on 64-bit
architectures and provide a best-effort boxed representation on 32-bit
architectures.")
    (license license:isc)))

(define-public ocaml-hmap
  (package
    (name "ocaml-hmap")
    (version "0.8.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://erratique.ch/software/hmap/releases/hmap-0.8.1.tbz")
       (sha256
    (base32 "10xyjy4ab87z7jnghy0wnla9wrmazgyhdwhr4hdmxxdn28dxn03a"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:build-flags
       (list "build" "--tests" "true")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))))
    (native-inputs (list ocaml-topkg ocamlbuild opam-installer))
    (home-page "https://erratique.ch/software/hmap")
    (synopsis "Heterogeneous value maps for OCaml")
    (description
     "Hmap provides heterogeneous value maps for OCaml.  These maps bind keys to
values with arbitrary types.  Keys witness the type of the value they are bound
to which allows adding and looking up bindings in a type safe manner.")
    (license license:isc)))

(define-public ocaml-thread-table
  (package
    (name "ocaml-thread-table")
    (version "1.0.0")
    (home-page
     "https://github.com/ocaml-multicore/thread-table")
    (source
     (github-tag-origin
      name home-page version
      "05sla96m4lbfrnrjczj4xl1zbcwypir6krp4y16x50hz24ai12pc" ""
      ))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    ;; (propagated-inputs (list ocaml-re))
    (properties `((upstream-name . "thread-table")))
      (synopsis "OCaml library for thread tables")
      (description
       "Lock free thread safe integer keyed hash table")
      ;; With linking exception.
      (license license:isc)
    ))

(define-public ocaml-ppx-tydi
  (package
    (name "ocaml-ppx-tydi")
    (version "0.17.1")
    (home-page
     "https://github.com/janestreet/ppx_tydi"
     )
    (source
     (github-tag-origin
      name home-page version
      "00q8yq74dgkw0wyljjnqday5vzkrzykyza4ady5b33r3hnxp0ikn"
      "v"
      ))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    ;; (propagated-inputs (list ocaml-re))
    (propagated-inputs (list ocaml-ppxlib ocaml-base))
    (properties `((upstream-name . "thread-table")))
      (synopsis "Let expressions, inferring pattern type from expression")
      (description
       "Allow concise type-directed disambiguation of record patterns on the left-hand side of let-bindings")
      (license license:expat)
    ))

(define-public ocaml-capitalization
  (package
    (name "ocaml-capitalization")
    (version "0.17.0")
    (home-page
     "https://github.com/janestreet/capitalization"
     )
    (source
     (github-tag-origin
      name home-page version
      "0af3smzisx4prk96vq5rqikspmxzb1ai5gibhl8fa5wpwhxi5by2"
      "v"
      ))
    (build-system dune-build-system)
    ;; (arguments '(#:tests? #f))           ; no tests
    ;; (propagated-inputs (list ocaml-re))
    ;; (propagated-inputs (list ocaml-ppxlib ocaml-base ocaml-ppx-string ocaml-ppx-let ocaml-capitalization))
    ;; (properties `((upstream-name . "thread-table")))
    (propagated-inputs (list ocaml-ppx-base))
    (synopsis
     "Defines case conventions and functions to rename identifiers according to them "
     )
      (description
       "This library provides helper functions for formatting words using common naming conventions, such as snake_case, camelCase, and PascalCase."
       )
      (license license:expat)
    ))

(define-public ocaml-ppx-string-conv
  (package
    (name "ocaml-ppx-string-conv")
    (version "0.17.0")
    (home-page
     "https://github.com/janestreet/ppx_string_conv"
     )
    (source
     (github-tag-origin
      name home-page version
      "1x5w45c20zx84ddjdrcafycyb7vqlhzg9gdnna15rig34mnyxrdg"
      "v"
      ))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    ;; (propagated-inputs (list ocaml-re))
    (propagated-inputs (list ocaml-ppxlib ocaml-base ocaml-ppx-string ocaml-ppx-let ocaml-capitalization))
    ;; (properties `((upstream-name . "thread-table")))
    (synopsis
     "Ppx extension for generating of_string & to_string"
     )
      (description
       "ppx_string_conv is a ppx to help derive of_string and to_string, primarily for variant types."
       )
      (license license:expat)
    ))

(define-public ocaml-landmarks
  ;; currently broken until they update ppxlib dependency, unlikely
  (package
    (name "ocaml-landmarks")
    (version "1.5")
    (home-page
     "https://github.com/LexiFi/landmarks")
    (source
     (github-tag-origin
      name home-page version
      "1i1bzvn671qxx2bkvgixmd7kw2df3i8i7iy0mk730fvx7pcb92kq" "v"
      ))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (propagated-inputs (list ocaml-ppxlib))
      (synopsis "Simple profiling library")
      (description
       "Landmarks is a simple profiling library for OCaml. It provides primitives to delimit portions of code and measure the performance of instrumented code at runtime.")
      ;; With linking exception.
      (license license:expat)
    ))

(define-public ocaml-iter
  (package
    (name "ocaml-iter")
    (version "1.9")
    (home-page
     "https://github.com/c-cube/iter")
    (source
     (github-tag-origin
      name home-page version
      "05jvz6vphjp229ap24xakxqgw3xymqff80q08pfnh5vr2lyb0hxm" "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-mdx ocaml-ounit2 ocaml-qcheck))
      (synopsis "Clean and efficient loop fusion for all your iterating needs!")
      (description
       "Iter is a simple abstraction over iter functions intended to iterate efficiently on collections while performing some transformations. Common operations supported by Iter include filter, map, take, drop, append, flat_map, etc. Iter is not designed to be as general-purpose or flexible as Seq. Rather, it aims at providing a very simple and efficient way of iterating on a finite number of values, only allocating (most of the time) one intermediate closure to do so. For instance, iterating on keys, or values, of a Hashtbl.t, without creating a list. Similarly, the code above is turned into a single optimized for loop with flambda."
       )
      ;; With linking exception.
      (license license:bsd-2)
    ))

(define-public ocaml-containers
  (package
    (name "ocaml-containers")
    (version "3.16")
    (home-page
     "https://github.com/c-cube/ocaml-containers")
    (source
     (github-tag-origin
      name home-page version
      "0n8vng4g7rmwalp5ag1pl19f5zx1v2yxmj5gdma44s7329jw18ar" "v"
      ))
    (build-system dune-build-system)
    (arguments
     '(#:tests? #f))  ; CBOR tests fail on NaN comparison (NaN != NaN in IEEE 754)
    (propagated-inputs (list ocaml-either ocaml-uutf ocaml-gen ocaml-iter))
      (synopsis "A lightweight, modular standard library extension, string library, and interfaces to various libraries (unix, threads, etc.) BSD license.")
      (description
       "Containers is an extension of OCaml's standard library (under BSD license) focused on data structures, combinators and iterators, without dependencies on unix, str or num. Every module is independent and is prefixed with 'CC' in the global namespace. Some modules extend the stdlib (e.g. CCList provides safe map/fold_right/append, and additional functions on lists). Alternatively, open Containers will bring enhanced versions of the standard modules into scope."
       )
      ;; With linking exception.
      (license license:bsd-2)
    ))

(define-public ocaml-ke
  (package
    (name "ocaml-ke")
    (version "0.6")
    (home-page
     "https://github.com/mirage/ke")
    (source
     (github-tag-origin
      name home-page version
      "1fv23ys53p66xk1gjx9kdkv967jylwnjrscw2mfvi51b7gmzrsry"
      "v"
      ))
    (build-system dune-build-system)
    ;; (arguments
    ;;  '(#:tests? #f))
    ;; (propagated-inputs (list ))
    (propagated-inputs (list ocaml-fmt ocaml-alcotest ocaml-bigstringaf))
    (synopsis "Fast implementation of a queue")
      (description
       "Queue or FIFO is one of the most famous data-structure used in several algorithms. Ke provides some implementations of it in a functional or imperative way."
       )
      (license license:expat)
    ))

(define-public ocaml-ssl
  (package
    (name "ocaml-ssl")
    (version "0.7.0")
    (home-page
     "https://github.com/savonet/ocaml-ssl")
    (source
     (github-tag-origin
      name home-page version
      "1kh1870jhd5h9vfk3x5marc92ynkqqihnrq5fh9qws2a165k8bw2"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list autoconf automake ocaml-alcotest which openssl))
    ;; (propagated-inputs (list ocaml-eio ocaml-ipaddr ocaml-ke ocaml-uri ocaml-ssl))
    (synopsis "OCaml SSL Bindings")
    (description "OCaml-SSL - OCaml bindings for the libssl.")
    (license license:lgpl2.1)
    ))

(define-public ocaml-nlopt
  (package
    (name "ocaml-nlopt")
    (version "0.7")
    (home-page "https://github.com/mkur/nlopt-ocaml"
               )
    (source
     (github-tag-origin
      name home-page version "04j0a251wxvak7g5v5p2w2xz9csjcac88p1g4ryj56kvf7adnd7r"
      "release-"
      ))
    (build-system dune-build-system)
    (native-inputs (list nlopt))
    (synopsis "OCaml bindings to the NLOpt optimization library ")
    (description "nlopt-ocaml implements OCaml bindings to the NLOpt optimization library.")
    (license license:lgpl2.1)
    ))
(define-public ocaml-nlopt
  (package
    (name "ocaml-nlopt")
    (version "0.7")
    (home-page "https://github.com/mkur/nlopt-ocaml"
               )
    (source
     (github-tag-origin
      name home-page version "04j0a251wxvak7g5v5p2w2xz9csjcac88p1g4ryj56kvf7adnd7r"
      "release-"
      ))
    (build-system dune-build-system)
    (native-inputs (list nlopt))
    (synopsis "OCaml bindings to the NLOpt optimization library ")
    (description "nlopt-ocaml implements OCaml bindings to the NLOpt optimization library.")
    (license license:lgpl2.1)
    ))

(define-public ocaml-dream-mirage
(package
 (name "ocaml-dream-mirage")
 (version "1.0.0-git")
 (source
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/aantron/dream")
          (commit "af3c9bff7b4f11777190946e2f3453697bf5a07b")))
    (file-name (git-file-name name version))
    (sha256
     (base32 "0djl3a0xhj0ppgiimfhb44y60za92v3mgsgkspd6b37f6s5b2abm"))))
 (build-system dune-build-system)
 (arguments `(#:package "dream-mirage"
              #:tests? #f))
 (home-page "https://github.com/aantron/dream")
 (native-inputs
  (list ocaml-alcotest))
 (propagated-inputs (list ocaml-lwt-ppx))
 ;; (propagated-inputs
 ;;  (list ocaml-ppx-deriving
 ;;        ocaml-graphql-lwt
 ;;        ocaml-magic-mime
 ;;        ocaml-multipart-form-lwt
 ;;        ocaml-yojson
 ;;        ocaml-digestif
 ;;        ocaml-ssl
 ;;        ocaml-lwt-ssl
 ;;        ocaml-mirage-crypto
 ;;        ocaml-ptime
 ;;        ocaml-httpun-ws
 ;;        ocaml-mirage-crypto
 ;;        ocaml-unstrctrd
 ;;        ;; ocaml-lwt-ssl
 ;;        ocaml-lwt-ppx))
 (synopsis "Tidy, feature-complete Web framework ")
 (description "")
 (license license:gpl3+)))

(define-public ocaml-cstruct-lwt
  (package
    (name "ocaml-cstruct-lwt")
    (version "6.2.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/ocaml-cstruct/releases/download/v6.2.0/cstruct-6.2.0.tbz")
       (sha256
        (base32 "0qiyy1h7qsy90hdl01qdsg4rv61f3d5sp8wg2i4q63jqj8rhfy4s"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "cstruct-lwt"))
    (propagated-inputs (list ocaml-lwt ocaml-cstruct ocaml-ppxlib ocaml-sexplib ocaml-async-unix ocaml-async))
    (home-page "https://github.com/mirage/ocaml-cstruct")
    (synopsis "Access C-like structures directly from OCaml")
    (description
     "Cstruct is a library and syntax extension to make it easier to access C-like
structures directly from OCaml.  It supports both reading and writing to these
structures, and they are accessed via the `Bigarray` module.")
    (license license:isc)))

(define-public ocaml-metrics
  (package
    (name "ocaml-metrics")
    (version "0.5.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/metrics/releases/download/v0.5.0/metrics-0.5.0.tbz")
       (sha256
        (base32 "0pbi0lybar1nq2bsfxplcl9wbwx97h3gczh9rldlc1lxj2066dfz"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-fmt ocaml-duration))
    (native-inputs (list ocaml-alcotest gnuplot))
    (home-page "https://github.com/mirage/metrics")
    (synopsis "Metrics infrastructure for OCaml")
    (description
     "Metrics provides a basic infrastructure to monitor and gather runtime metrics
for OCaml program.  Monitoring is performed on sources, indexed by tags,
allowing users to enable or disable at runtime the gathering of data-points.  As
disabled metric sources have a low runtime cost (only a closure allocation), the
library is designed to instrument production systems.  Metric reporting is
decoupled from monitoring and is handled by a custom reporter.  A few reporters
are (will be) provided by default.  Metrics is heavily inspired by
[Logs](http://erratique.ch/software/logs).")
    (license license:isc)))
(define-public ocaml-mirage-vnetif
  (package
    (name "ocaml-mirage-vnetif")
    (version "0.6.2")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/mirage-vnetif/releases/download/v0.6.2/mirage-vnetif-0.6.2.tbz")
       (sha256
        (base32 "08j58plmrzzyx50ibpvzdzdyiljfxxhl02xb3lhjd131yjndr2ja"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-lwt
                             ocaml-mirage-net
                             ocaml-cstruct
                             ocaml-ipaddr
                             ocaml-macaddr
                             ocaml-duration
                             ocaml-logs))
    (home-page "https://github.com/mirage/mirage-vnetif")
    (synopsis "Virtual network interface and software switch for Mirage")
    (description
     "This package provides the module `Vnetif` which can be used as a replacement for
the regular `Netif` implementation in Xen and Unix.  Stacks built using `Vnetif`
are connected to a software switch that allows the stacks to communicate as if
they were connected to the same LAN.")
    (license license:isc)))
(define-public ocaml-arp
  (package
    (name "ocaml-arp")
    (version "4.0.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/arp/releases/download/v4.0.0/arp-4.0.0.tbz")
       (sha256
        (base32 "198dchi24zaqfkqdnhhv1gf1djj4f149whi72a4s0rkhcgzn2q0b"))))
    (build-system dune-build-system)
    (arguments
     '(#:tests? #f))  ; Tests would create a dependency cycle with ocaml-mirage-vnetif
    (propagated-inputs (list ocaml-cstruct
                             ocaml-ipaddr
                             ocaml-macaddr
                             ocaml-logs
                             ocaml-mirage-sleep
                             ocaml-lwt
                             ocaml-duration
                             ocaml-ethernet
                             ocaml-fmt))
    (native-inputs (list ocaml-alcotest ocaml-bos))
    (home-page "https://github.com/mirage/arp")
    (synopsis "Address Resolution Protocol purely in OCaml")
    (description
     "ARP is an implementation of the address resolution protocol (RFC826) purely in
OCaml.  It handles IPv4 protocol addresses and Ethernet hardware addresses only.")
    (license license:isc)))
(define-public ocaml-ethernet
  (package
    (name "ocaml-ethernet")
    (version "3.2.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/ethernet/releases/download/v3.2.0/ethernet-3.2.0.tbz")
       (sha256
        (base32 "02dcf88f4z8rvwjxbj3ngwscmldk7lpdxzx9jd1rs7922h1af7ac"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-cstruct ocaml-mirage-net ocaml-macaddr
                             ocaml-lwt ocaml-logs))
    (home-page "https://github.com/mirage/ethernet")
    (synopsis "OCaml Ethernet (IEEE 802.3) layer, used in MirageOS")
    (description
     "`ethernet` provides an [Ethernet](https://en.wikipedia.org/wiki/Ethernet)
(specified by IEEE 802.3) layer implementation for the [Mirage operating
system](https://mirage.io).")
    (license license:isc)))
(define-public ocaml-mirage-net
  (package
    (name "ocaml-mirage-net")
    (version "4.0.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/mirage-net/releases/download/v4.0.0/mirage-net-v4.0.0.tbz")
       (sha256
        (base32 "1kllw58f41qqjnl3iwvz748zk7xqvcahr1sh4jrhl6mqhz8zz3k6"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-fmt ocaml-macaddr ocaml-cstruct ocaml-lwt))
    (home-page "https://github.com/mirage/mirage-net")
    (synopsis "Network signatures for MirageOS")
    (description
     "mirage-net defines `Mirage_net.S`, the signature for network operations for
@code{MirageOS}.")
    (license license:isc)))

(define-public ocaml-qcheck-alcotest
  (package
    (name "ocaml-qcheck-alcotest")
    (version "0.26")
    (source
     (origin
       (method url-fetch)
       (uri "https://github.com/c-cube/qcheck/archive/v0.26.tar.gz")
       (sha256
        (base32 "0shxc3jgxw8w3gkzv7i4hrhw2nfkahxp343zclwghqkd667m892p"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-alcotest ocaml-ppxlib))
    (native-inputs (list ocaml-ounit2))
    (home-page "https://github.com/c-cube/qcheck/")
    (synopsis "Alcotest backend for QCheck")
    (description
     "QCheck is a @code{QuickCheck} inspired property-based testing library for OCaml.
 The `qcheck-alcotest` library provides an integration layer for `QCheck` onto
https://github.com/mirage/alcotest[`alcotest`], allowing to run property-based
tests in `alcotest`.")
    (license license:bsd-2)))


(define-public ocaml-lru
  (package
    (name "ocaml-lru")
    (version "0.3.1")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/pqwy/lru/releases/download/v0.3.1/lru-0.3.1.tbz")
       (sha256
        (base32 "1z9nnba2b4q0q0syyqk4790hzxs71la8h2wwhr7j8nvxgb927gkc"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-psq))
    (native-inputs (list
                         ocaml-alcotest ocaml-qcheck-alcotest))
    (home-page "https://github.com/pqwy/lru")
    (synopsis "Scalable LRU caches")
    (description
     "Lru provides weight-bounded finite maps that can remove the least-recently-used
(LRU) bindings in order to maintain a weight constraint.")
    (license license:isc)))

(define-public ocaml-pcap-format
  (package
    (name "ocaml-pcap-format")
    (version "0.6.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/ocaml-pcap/releases/download/v0.6.0/pcap-format-0.6.0.tbz")
       (sha256
        (base32 "19li8z9rmw42na9w7vgg8jpaifw3i4wjnisimg6cjmmsg7qz4j1d"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-cstruct ocaml-ppx-cstruct))
    (native-inputs (list ocaml-ounit))
    (home-page "https://github.com/mirage/ocaml-pcap")
    (synopsis "Decode and encode PCAP (packet capture) files")
    (description
     "pcap-format provides an interface to encode and decode pcap files, dealing with
both endianess, including endianess detection.")
    (license license:isc)))
;; (define-public ocaml-tcpip
;;   (package
;;     (name "ocaml-tcpip")
;;     (version "9.0.1")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri
;;         "https://github.com/mirage/mirage-tcpip/releases/download/v9.0.1/tcpip-9.0.1.tbz")
;;        (sha256
;;         (base32 "00qbz7f14wlin0hxmmj8ynz0zhqwccmxjwqksziza741hvlprh7s"))))
;;     (build-system dune-build-system)
;;     (propagated-inputs (list
;;                         ocaml-metrics
;;                         ocaml-ethernet
;;                              ocaml-cstruct
;;                              ;; ocaml-cstruct-lwt
;;                              ;; ocaml-mirage-net
;;                              ocaml-mirage-mtime
;;                              ocaml-arp
;;                              ocaml-mirage-crypto-rng
;;                              ocaml-mirage-sleep
;;                              ocaml-ipaddr
;;                              ocaml-macaddr
;;                              ;; ocaml-macaddr-cstruct
;;                              ocaml-cstruct-lwt
;;                              ocaml-fmt
;;                              ocaml-lwt
;;                              ocaml-lwt-dllist
;;                              ocaml-logs
;;                              ocaml-duration
;;                              ocaml-randomconv
;;                              ;; ocaml-ethernet
;;                              ;; ocaml-arp
;;                              ocaml-mirage-flow
;;                              ocaml-ipaddr-cstruct
;;                              ;; ocaml-macaddr-cstruct
;;                              ;; ocaml-lru
;;                              ;; ocaml-metrics
;;                              ocaml-cmdliner))
;;     (native-inputs (list ocaml-alcotest))
;;     (home-page "https://github.com/mirage/mirage-tcpip")
;;     (synopsis "OCaml TCP/IP networking stack, used in MirageOS")
;;     (description
;;      "`mirage-tcpip` provides a networking stack for the [Mirage operating
;; system](https://mirage.io).  It provides implementations for the following
;; module types (which correspond with the similarly-named protocols): * IP (via
;; the IPv4 and IPv6 modules) * ICMP * UDP * TCP.")
;;     (license license:isc)))
(define-public ocaml-tcpip
  (package
    (name "ocaml-tcpip")
    (version "9.0.1")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/mirage-tcpip/releases/download/v9.0.1/tcpip-9.0.1.tbz")
       (sha256
        (base32 "00qbz7f14wlin0hxmmj8ynz0zhqwccmxjwqksziza741hvlprh7s"))))
    (build-system dune-build-system)
    (arguments
     '(#:tests? #f))  ; Tests would create a dependency cycle with ocaml-mirage-vnetif
    (propagated-inputs (list
                             ocaml-cstruct
                             ocaml-cstruct-lwt
                             ocaml-mirage-net
                             ocaml-mirage-mtime
                             ocaml-mirage-crypto-rng
                             ocaml-mirage-sleep
                             ocaml-ipaddr
                             ocaml-macaddr
                             ocaml-macaddr-cstruct
                             ocaml-fmt
                             ocaml-lwt
                             ocaml-lwt-dllist
                             ocaml-logs
                             ocaml-duration
                             ocaml-randomconv
                             ocaml-ethernet
                             ocaml-arp
                             ocaml-mirage-flow
                             ocaml-ipaddr-cstruct
                             ocaml-macaddr-cstruct
                             ocaml-lru
                             ocaml-metrics
                             ocaml-cmdliner))
    (native-inputs (list ocaml-alcotest ocaml-pcap-format))
    (home-page "https://github.com/mirage/mirage-tcpip")
    (synopsis "OCaml TCP/IP networking stack, used in MirageOS")
    (description
     "`mirage-tcpip` provides a networking stack for the [Mirage operating
system](https://mirage.io).  It provides implementations for the following
module types (which correspond with the similarly-named protocols): * IP (via
the IPv4 and IPv6 modules) * ICMP * UDP * TCP.")
    (license license:isc)))
(define-public ocaml-conduit-async
  (package
    (name "ocaml-conduit-async")
    (version "8.0.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/ocaml-conduit/releases/download/v8.0.0/conduit-8.0.0.tbz")
       (sha256
        (base32 "0qbgyqn4xv79gznv5i7lxj4g920kyr8xl30p7a4p6m2vhq8djqqa"))))
    (build-system dune-build-system)
    (arguments
     '(#:package "conduit-async"))
    (propagated-inputs (list ocaml-conduit
                             ocaml-async
                             ocaml-ipaddr
                             ocaml-ipaddr-sexp
                             ocaml-uri))
    (home-page "https://github.com/mirage/ocaml-conduit")
    (synopsis "A network connection establishment library for Async")
    (description #f)
    (license license:isc)))



(define-public ocaml-pgx
  (package
    (name "ocaml-pgx")
    (version "2.2")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/arenadotio/pgx/releases/download/2.2/pgx-2.2.tbz")
       (sha256
        (base32 "0sn5d4y7rwnmzxqw2jcv8sxlgyb3gwsq1x421pd78k8jkm7gn3g5"))))
    (build-system dune-build-system)
    (arguments
     ;; No tests
     `(#:tests? #f
       #:package "pgx"))
    (propagated-inputs (list
                             ocaml-hex
                             ocaml-ipaddr
                             ocaml-re
                             ocaml-uuidm))
    (native-inputs (list ocaml-alcotest))
    (home-page "https://github.com/arenadotio/pgx")
    (synopsis "Pure-OCaml PostgreSQL client library")
    (description
     "PGX is a pure-OCaml @code{PostgreSQL} client library, supporting Async, LWT, or
synchronous operations.")
    (license #f)))


(define-public ocaml-caqti
  (package
    (name "ocaml-caqti")
    (version "2.2.4")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/paurkedal/ocaml-caqti/releases/download/v2.2.4/caqti-v2.2.4.tbz")
       (sha256
        (base32 "1fzq1brw9na4p22m20xjw19qbk869cj7nkrc2faw0khm40l47smq"))))
    (build-system dune-build-system)
    (arguments
     '(
       #:tests? #f
       #:package "caqti"))
    (propagated-inputs (list ocaml-angstrom
                             ocaml-bigstringaf
                             ocaml-dune-site
                             ocaml-domain-name
                             ocaml-ipaddr
                             ocaml-logs
                             ocaml-lru
                             ocaml-lwt-dllist
                             ocaml-mtime
                             ocaml-ptime
                             ocaml-tls
                             ocaml-uri
                             ocaml-x509))
    (native-inputs (list ocaml-alcotest ocaml-cmdliner ocaml-mdx ocaml-re postgresql))
    (home-page "https://github.com/paurkedal/ocaml-caqti/")
    (synopsis "Unified interface to relational database libraries")
    (description
     "Caqti provides a monadic cooperative-threaded OCaml connector API for relational
databases.  The purpose of Caqti is further to help make applications
independent of a particular database system.  This is achieved by defining a
common signature, which is implemented by the database drivers.  Connection
parameters are specified as an URI, which is typically provided at run-time.
Caqti then loads a driver which can handle the URI, and provides a first-class
module which implements the driver API and additional convenience functionality.
 Caqti does not make assumptions about the structure of the query language, and
only provides the type information needed at the edges of communication between
the OCaml code and the database; i.e.  for encoding parameters and decoding
returned tuples.  It is hoped that this agnostic choice makes it a suitable
target for higher level interfaces and code generators.")
    (license #f)))

(define-public ocaml-caqti-lwt
  (package
    (inherit ocaml-caqti)
    (name "caqti-lwt")
    (propagated-inputs (list ocaml-caqti))
    (native-inputs (list ocaml-caqti-driver-sqlite3 ocaml-alcotest-lwt))
    (arguments `(
                 #:tests? #f
                 #:package "caqti-lwt"))
  )
)

(define-public ocaml-reason
  (package
    (name "ocaml-reason")
    (version "3.17.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/reasonml/reason/releases/download/3.17.0/reason-3.17.0.tbz")
       (sha256
        (base32 "1sx5z269sry2xbca3d9sw7mh9ag773k02r9cgrz5n8gxx6f83j42"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-cmdliner
                             ocaml-dune-build-info
                             ocaml-menhir
                             ocaml-fix
                             ocaml-cppo
                             ocaml-ppxlib
                             ))
    (native-inputs (list ocaml-findlib))
    (home-page "https://reasonml.github.io/")
    (synopsis "Reason: Syntax & Toolchain for OCaml")
    (description
     "Reason gives OCaml a new syntax that is remniscient of languages like
@code{JavaScript}.  It's also the umbrella project for a set of tools for the
OCaml & @code{JavaScript} ecosystem.")
    (license license:expat)))
(define-public ocaml-dream-pure
  (package
    (name "ocaml-dream-pure")
    (version "1.0.0-git")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/aantron/dream")
             (commit "af3c9bff7b4f11777190946e2f3453697bf5a07b")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0djl3a0xhj0ppgiimfhb44y60za92v3mgsgkspd6b37f6s5b2abm"))))
    (build-system dune-build-system)
    (arguments
     '(#:package "dream-pure"
       #:tests? #f))
    (propagated-inputs (list ocaml-base64
                             ocaml-bigstringaf
                             ocaml-hmap
                             ocaml-lwt
                             ocaml-lwt-ppx
                             ocaml-ptime
                             ocaml-faraday
                             ocaml-digestif
                             ocaml-psq
                             ocaml-magic-mime
                             ocaml-caqti-lwt
                             ocaml-result
                             ocaml-uri))
    (native-inputs (list ocaml-alcotest ocaml-ppx-expect
                         ocaml-ppx-yojson-conv))
    (home-page "https://github.com/aantron/dream")
    (synopsis
     "Internal: shared HTTP types for Dream (server) and Hyper (client)")
    (description "This package does not have a stable API.")
    (license license:expat)))
(define-public ocaml-gluten-lwt-unix
  (package
    (name "ocaml-gluten-lwt-unix")
    (version "0.5.2")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/anmonteiro/gluten/releases/download/0.5.2/gluten-0.5.2.tbz")
       (sha256
        (base32 "0pq1ww3p41m6dzk2cmrr7pq03kvb5hjqvk49s95vp030kygxivmi"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-gluten-lwt ocaml-faraday-lwt-unix
                             ))
    (home-page "https://github.com/anmonteiro/gluten")
    (synopsis "Lwt + Unix support for gluten")
    (description #f)
    (license license:bsd-3)))

(define-public ocaml-dream-httpaf
  (package
    (name "ocaml-dream-httpaf")
    (version "1.0.0-git")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/aantron/dream")
             (commit "af3c9bff7b4f11777190946e2f3453697bf5a07b")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0djl3a0xhj0ppgiimfhb44y60za92v3mgsgkspd6b37f6s5b2abm"))))
    (build-system dune-build-system)
    (arguments
     '(#:package "dream-httpaf"
       #:tests? #f))
    (propagated-inputs (list ocaml-dream-pure
                             ocaml-gluten
                             ocaml-gluten-lwt-unix
                             ocaml-httpun-0.1.0
                             ocaml-httpun-lwt-unix-0.1.0
                             ocaml-httpun-ws-0.1.0
                             ocaml-lwt
                             ocaml-lwt-ppx
                             ocaml-lwt-ssl
                             ocaml-ssl))
    (home-page "https://github.com/aantron/dream")
    (synopsis
     "Internal: shared http/af stack for Dream (server) and Hyper (client)")
    (description "This package does not have a stable API.")
    (license license:expat)))
(define-public ocaml-gluten-lwt
  (package
    (name "ocaml-gluten-lwt")
    (version "0.5.2")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/anmonteiro/gluten/releases/download/0.5.2/gluten-0.5.2.tbz")
       (sha256
        (base32 "0pq1ww3p41m6dzk2cmrr7pq03kvb5hjqvk49s95vp030kygxivmi"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-gluten ocaml-lwt
                             ))
    (home-page "https://github.com/anmonteiro/gluten")
    (synopsis "Lwt-specific runtime for gluten")
    (description #f)
    (license license:bsd-3)))

(define-public ocaml-faraday-lwt-unix
  (package
    (name "ocaml-faraday-lwt-unix")
    (version "0.8.2")
    (source
     (origin
       (method url-fetch)
       (uri "https://github.com/inhabitedtype/faraday/archive/0.8.2.tar.gz")
       (sha256
        (base32 "1iiml37sgn28mm0szm4ldqq6fkji4l5368l7dvgafgpx745sj3kj"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-faraday-lwt ocaml-lwt))
    (home-page "https://github.com/inhabitedtype/faraday")
    (synopsis "Lwt_unix support for Faraday")
    (description #f)
    (license license:bsd-3)))
(define-public ocaml-h2-lwt-unix
  (package
    (name "ocaml-h2-lwt-unix")
    (arguments
     ;; No tests
     `(#:tests? #f))
    (version "0.13.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/anmonteiro/ocaml-h2/releases/download/0.13.0/h2-0.13.0.tbz")
       (sha256
        (base32 "03q7m2ra6ch49z1vwjbmp4qzr0sv3pl3n8h7lbkr8lhpg3qvd28d"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-h2-lwt ocaml-faraday-lwt-unix
                             ocaml-gluten-lwt-unix
                             ))
    (home-page "https://github.com/anmonteiro/ocaml-h2")
    (synopsis "Lwt + UNIX support for h2")
    (description
     "h2 is an implementation of the HTTP/2 specification entirely in OCaml.
h2-lwt-unix provides an Lwt runtime implementation for h2 that targets UNIX
binaries.")
    (license license:bsd-3)))

(define-public ocaml-httpun-lwt-unix
  (package
    (name "ocaml-httpun-lwt-unix")
    (version "0.2.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/anmonteiro/httpun/releases/download/0.2.0/httpun-0.2.0.tbz")
       (sha256
        (base32 "0b5xhyv7sbwls8fnln1lp48v5mlkx3ay7l8820f8xbl59kpjgkm2"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-httpun ocaml-httpun-lwt
                             ocaml-gluten-lwt-unix))
    (home-page "https://github.com/anmonteiro/httpun")
    (synopsis "Lwt + Unix support for httpun")
    (description #f)
    (license license:bsd-3)))

(define-public ocaml-httpun-lwt-unix-0.1.0
  (package
    (inherit ocaml-httpun-lwt-unix)
    (name "ocaml-httpun-lwt-unix-0.1.0")
    (version "0.1.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/anmonteiro/httpun/releases/download/0.1.0/httpun-0.1.0.tbz")
       (sha256
        (base32 "1lclla34qc03yss3vfbw83nmxg3r9ccik6013vn8vkz189glc1sh"))))
    (arguments
     '(#:package "httpun-lwt-unix"))
    (propagated-inputs (list ocaml-httpun-0.1.0 ocaml-httpun-lwt-0.1.0
                             ocaml-gluten-lwt-unix))))

(define-public ocaml-faraday-lwt
  (package
    (name "ocaml-faraday-lwt")
    (version "0.8.2")
    (source
     (origin
       (method url-fetch)
       (uri "https://github.com/inhabitedtype/faraday/archive/0.8.2.tar.gz")
       (sha256
        (base32 "1iiml37sgn28mm0szm4ldqq6fkji4l5368l7dvgafgpx745sj3kj"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-faraday ocaml-lwt))
    (home-page "https://github.com/inhabitedtype/faraday")
    (synopsis "Lwt support for Faraday")
    (description #f)
    (license license:bsd-3)))

(define-public ocaml-h2-lwt
  (package
    (name "ocaml-h2-lwt")
    (version "0.13.0")
    (arguments
     ;; No tests
     `(#:tests? #f))
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/anmonteiro/ocaml-h2/releases/download/0.13.0/h2-0.13.0.tbz")
       (sha256
        (base32 "03q7m2ra6ch49z1vwjbmp4qzr0sv3pl3n8h7lbkr8lhpg3qvd28d"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-h2 ocaml-lwt ocaml-gluten-lwt
                             ))
    (home-page "https://github.com/anmonteiro/ocaml-h2")
    (synopsis "Lwt support for h2")
    (description
     "h2 is an implementation of the HTTP/2 specification entirely in OCaml.  h2-lwt
provides an Lwt runtime implementation for h2.")
    (license license:bsd-3)))

(define-public ocaml-httpun-lwt
  (package
    (name "ocaml-httpun-lwt")
    (version "0.2.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/anmonteiro/httpun/releases/download/0.2.0/httpun-0.2.0.tbz")
       (sha256
        (base32 "0b5xhyv7sbwls8fnln1lp48v5mlkx3ay7l8820f8xbl59kpjgkm2"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-httpun ocaml-lwt ocaml-gluten-lwt))
    (home-page "https://github.com/anmonteiro/httpun")
    (synopsis "Lwt support for httpun")
    (description #f)
    (license license:bsd-3)))

(define-public ocaml-httpun-lwt-0.1.0
  (package
    (inherit ocaml-httpun-lwt)
    (name "ocaml-httpun-lwt-0.1.0")
    (version "0.1.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/anmonteiro/httpun/releases/download/0.1.0/httpun-0.1.0.tbz")
       (sha256
        (base32 "1lclla34qc03yss3vfbw83nmxg3r9ccik6013vn8vkz189glc1sh"))))
    (arguments
     '(#:package "httpun-lwt"))
    (propagated-inputs (list ocaml-httpun-0.1.0 ocaml-lwt ocaml-gluten-lwt))))

(define-public ocaml-lambdasoup
  (package
    (name "ocaml-lambdasoup")
    (version "1.1.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://github.com/aantron/lambdasoup/archive/1.1.1.tar.gz")
       (sha256
        (base32 "1zhhizim7zwxlv2r748hf1vwzgdpvzkdplyqdqbk391lwlw7zn85"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-camlp-streams ocaml-markup ))
    (native-inputs (list ocaml-ounit2))
    (home-page "https://github.com/aantron/lambdasoup")
    (synopsis
     "Easy functional HTML scraping and manipulation with CSS selectors")
    (description
     "Lambda Soup is an HTML scraping library inspired by Python's Beautiful Soup.  It
provides lazy traversals from HTML nodes to their parents, children, siblings,
etc., and to nodes matching CSS selectors.  The traversals can be manipulated
using standard functional combinators such as fold, filter, and map.  The DOM
tree is mutable.  You can use Lambda Soup for automatic HTML rewriting in
scripts.  Lambda Soup rewrites its own ocamldoc page this way.  A major goal of
Lambda Soup is to be easy to use, including in interactive sessions, and to have
a minimal learning curve.  It is a very simple library.")
    (license license:expat)))
(define-public ocaml-mirage-crypto-rng
  (package
    (name "ocaml-mirage-crypto-rng")
    (version "2.0.2")
    (arguments
     ;; No tests
     `(#:tests? #f))
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/mirage-crypto/releases/download/v2.0.2/mirage-crypto-2.0.2.tbz")
       (sha256
        (base32 "0x2q47b07a7s2br75zxdvlmsb421mif7ry2p6p4zn9s0ycwrv6kk"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-dune-configurator ocaml-duration ocaml-logs
                             ocaml-mirage-crypto ocaml-digestif))
    (native-inputs (list ocaml-ounit2 ocaml-randomconv ocaml-ohex))
    (home-page "https://github.com/mirage/mirage-crypto")
    (synopsis "A cryptographically secure PRNG")
    (description
     "Mirage-crypto-rng provides a random number generator interface, and
implementations: Fortuna, HMAC-DRBG, getrandom/getentropy based (in the unix
sublibrary).")
    (license license:isc)))

(define-public ocaml-dune-configurator
  (package
    (name "ocaml-dune-configurator")
    (version "3.20.2")
    (arguments
     ;; No tests
     `(#:tests? #f))
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/ocaml/dune/releases/download/3.20.2/dune-3.20.2.tbz")
       (sha256
        (base32 "0jd5kkpvkkpcmy0wwcyqnmy6x2pjz7rbsqb8pfwsid5xc0nnpa5i"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-csexp ocaml-lwt
                             ))
    (home-page "https://github.com/ocaml/dune")
    (synopsis "Helper library for gathering system configuration")
    (description
     "dune-configurator is a small library that helps writing OCaml scripts that test
features available on the system, in order to generate config.h files for
instance.  Among other things, dune-configurator allows one to: - test if a C
program compiles - query pkg-config - import #define from OCaml header files -
generate config.h file.")
    (license license:expat)))

(define-public ocaml-randomconv
  (package
    (name "ocaml-randomconv")
    (version "0.2.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/hannesm/randomconv/releases/download/v0.2.0/randomconv-0.2.0.tbz")
       (sha256
        (base32 "1sk3bdfz1nlqrivp8vy3slpbhqw858gc5zwjix3a8hg30zgiw5xk"))))
    (build-system dune-build-system)
    (home-page "https://github.com/hannesm/randomconv")
    (synopsis
     "Convert from random byte vectors (int -> string) to random native numbers")
    (description
     "Given a function which produces random byte vectors, convert it to a number of
your choice (int8/int16/int32/int64/int/float).")
    (license license:isc)))
(define-public ocaml-mirage-crypto-rng-lwt
  (package
    (name "ocaml-mirage-crypto-rng-lwt")
    (version "1.2.0")
    (arguments
     ;; No tests
     `(#:tests? #f))
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mirage/mirage-crypto/releases/download/v1.2.0/mirage-crypto-1.2.0.tbz")
       (sha256
        (base32 "0zp60zp101mcygwhsh62jj61sy61yh2k31d8kgznily1jv6jnm09"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-duration ocaml-logs ocaml-mirage-crypto-rng
                             ocaml-mtime ocaml-lwt ocaml-mirage-clock ocaml-eio ocaml-async
                             ocaml-mirage-time))
    (home-page "https://github.com/mirage/mirage-crypto")
    (synopsis "A cryptographically secure PRNG")
    (description
     "Mirage-crypto-rng-lwt provides entropy collection code for the RNG using Lwt.")
    (license license:isc)))
(define-public ocaml-caqti-driver-postgresql
  (package
    (name "ocaml-caqti-driver-postgresql")
    (version "2.2.4")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/paurkedal/ocaml-caqti/releases/download/v2.2.4/caqti-v2.2.4.tbz")
       (sha256
        (base32 "1fzq1brw9na4p22m20xjw19qbk869cj7nkrc2faw0khm40l47smq"))))
    (build-system dune-build-system)
    (arguments
     '(#:package "caqti-driver-postgresql"))
    (propagated-inputs (list ocaml-caqti
                             ocaml-postgresql
                             ocaml-uri))
    (native-inputs (list ocaml-alcotest ocaml-cmdliner))
    (home-page "https://github.com/paurkedal/ocaml-caqti/")
    (synopsis "PostgreSQL driver for Caqti based on C bindings")
    (description "PostgreSQL driver for Caqti using the C-based postgresql-ocaml library.")
    (license license:lgpl3+)))

(define-public ocaml-caqti-driver-pgx
  (package
    (name "ocaml-caqti-driver-pgx")
    (version "2.2.4")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/paurkedal/ocaml-caqti/releases/download/v2.2.4/caqti-v2.2.4.tbz")
       (sha256
        (base32 "1fzq1brw9na4p22m20xjw19qbk869cj7nkrc2faw0khm40l47smq"))))
    (build-system dune-build-system)
    (arguments
     '(#:package "caqti-driver-pgx"))
    (propagated-inputs (list ocaml-caqti
                             ocaml-domain-name
                             ocaml-ipaddr
                             ocaml-pgx))
    (home-page "https://github.com/paurkedal/ocaml-caqti/")
    (synopsis "PostgreSQL driver for Caqti based on the pure-OCaml PGX library")
    (description "PostgreSQL driver for Caqti using the pure-OCaml pgx library.")
    (license license:lgpl3+)))

(define-public ocaml-postgresql
  (package
    (name "ocaml-postgresql")
    (version "5.3.2")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/mmottl/postgresql-ocaml/releases/download/5.3.2/postgresql-5.3.2.tbz")
       (sha256
        (base32 "1bspn767p05vyxi8367ks7q3qapzi1fmfl3k7pr8z4zqf8kx4iqw"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-dune-compiledb ocaml-dune-configurator
                             ))
    (native-inputs (list postgresql))
    (home-page "https://mmottl.github.io/postgresql-ocaml")
    (synopsis "Bindings to the PostgreSQL library")
    (description
     "Postgresql offers library functions for accessing @code{PostgreSQL} databases.")
    (license #f)))
(define-public ocaml-dune-compiledb
  (package
    (name "ocaml-dune-compiledb")
    (version "0.6.0")
    (arguments
     ;; No tests
     `(#:tests? #f))
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/edwintorok/dune-compiledb/releases/download/0.6.0/dune-compiledb-0.6.0.tbz")
       (sha256
        (base32 "1zzriwgflwcgpa16s3gmv7z48bari21jv0sk3xrxz2dgqba4zrzm"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ezjsonm ocaml-sexplib ocaml-sexplib0
                             ocaml-fpath
                             ))
    (home-page "https://github.com/edwintorok/dune-compiledb")
    (synopsis "Generate compile_commands.json from dune rules")
    (description
     "Generates a compile_commands.json from dune rules that can be used by language
server like clangd', or static analyzers like goblint'.  Works with generated
headers.")
    (license license:lgpl2.1+)))
(define-public ocaml-tyxml-jsx
  (package
    (name "ocaml-tyxml-jsx")
    (version "4.6.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/ocsigen/tyxml/releases/download/4.6.0/tyxml-4.6.0.tbz")
       (sha256
        (base32 "1p82r68lxk6wzxihzd620a6kzp27vn548j2cr970l4jfdcy6gsxz"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-tyxml ocaml-tyxml-syntax ocaml-ppxlib
                             ))
    (native-inputs (list ocaml-alcotest
                         ;; ocaml-reason
                         ))
    (home-page "https://github.com/ocsigen/tyxml")
    (synopsis "JSX syntax to write TyXML documents")
    (description
     "```reason open Tyxml; let to_reason = <a href=\"reasonml.github.io/\"> \"Reason!\"
</a> ``` The @code{TyXML} JSX allow to write @code{TyXML} documents with
reason's JSX syntax.  It works with textual trees, virtual DOM trees, or any
@code{TyXML} module.")
    (license #f)))
(define-public ocaml-caqti-driver-sqlite3
  (package
    (name "ocaml-caqti-driver-sqlite3")
    (version "2.2.4")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/paurkedal/ocaml-caqti/releases/download/v2.2.4/caqti-v2.2.4.tbz")
       (sha256
        (base32 "1fzq1brw9na4p22m20xjw19qbk869cj7nkrc2faw0khm40l47smq"))))
    (build-system dune-build-system)
    (arguments
     '(#:package "caqti-driver-sqlite3"))
    (propagated-inputs (list ocaml-caqti
                             ocaml-sqlite3))
    (native-inputs (list ocaml-alcotest ocaml-cmdliner))
    (home-page "https://github.com/paurkedal/ocaml-caqti/")
    (synopsis "Sqlite3 driver for Caqti using C bindings")
    (description "SQLite3 driver for Caqti using the C-based sqlite3-ocaml library.")
    (license license:lgpl3+)))
(define-public ocaml-tyxml-syntax
  (package
    (name "ocaml-tyxml-syntax")
    (version "4.6.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/ocsigen/tyxml/releases/download/4.6.0/tyxml-4.6.0.tbz")
       (sha256
        (base32 "1p82r68lxk6wzxihzd620a6kzp27vn548j2cr970l4jfdcy6gsxz"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ppxlib ocaml-re ocaml-uutf
                             ))
    (native-inputs (list ocaml-alcotest))
    (home-page "https://github.com/ocsigen/tyxml")
    (synopsis "Common layer for the JSX and PPX syntaxes for Tyxml")
    (description #f)
    (license #f)))

(define-public ocaml-dream
  (package
    (name "ocaml-dream")
    (version "1.0.0-git")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/aantron/dream")
             (commit "af3c9bff7b4f11777190946e2f3453697bf5a07b")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0djl3a0xhj0ppgiimfhb44y60za92v3mgsgkspd6b37f6s5b2abm"))))
    (build-system dune-build-system)
    (arguments
     '(#:package "dream"
       #:tests? #f))  ; Tests require database servers (PostgreSQL, SQLite)
    (propagated-inputs (list ocaml-bigarray-compat
                             ocaml-camlp-streams
                             ocaml-caqti
                             ocaml-h2-lwt-unix
                             ocaml-caqti-lwt
                             libev
                             ocaml-cstruct
                             ocaml-digestif
                             ocaml-dream-httpaf
                             ocaml-dream-pure
                             ocaml-fmt
                             ocaml-graphql-parser
                             ocaml-graphql-lwt
                             ocaml-lambdasoup
                             ocaml-lwt
                             ocaml-lwt-ppx
                             ocaml-lwt-ssl
                             ocaml-logs
                             ocaml-magic-mime
                             ocaml-markup
                             ocaml-mirage-clock
                             ocaml-mirage-crypto
                             ocaml-mirage-crypto-rng
                             ocaml-mirage-crypto-rng-lwt
                             ocaml-multipart-form
                             ocaml-multipart-form-lwt
                             ocaml-ptime
                             ocaml-ssl
                             ocaml-uri
                             ocaml-yojson))
    (home-page "https://github.com/aantron/dream")
    (synopsis "Tidy, feature-complete Web framework")
    (description
     "Dream is a feature-complete Web framework with a simple programming model and no
boilerplate.  It provides only two data types, request and response.  Almost
everything else is either a built-in OCaml type, or an abbreviation for a bare
function.  For example, a Web app, known in Dream as a handler, is just an
ordinary function from requests to responses.  And a middleware is then just a
function from handlers to handlers.  Within this model, Dream adds: - Session
management with pluggable back ends. - A fully composable router. - Support for
HTTP/1.1, HTTP/2, and HTTPS. - @code{WebSockets}. - @code{GraphQL}, including
subscriptions and a built-in @code{GraphiQL} editor. - SQL connection pool
helpers. - Server-side HTML templates. - Automatic secure handling of cookies
and forms. - Unified, internationalization-friendly error handling. - A neat
log, and OCaml runtime configuration. - Helpers for Web formats, such as
Base64url, and a modern cipher.  Because of the simple programming model,
everything is optional and composable.  It is trivially possible to strip Dream
down to just a bare driver of the various HTTP protocols.  Dream is presented as
a single module, whose API is documented on one page.  In addition, Dream comes
with a large number of examples.  Security topics are introduced throughout,
wherever they are applicable.")
    (license license:expat)))

;; (define-public ocaml-dream
;; (package
;;  (name "ocaml-dream")
;;  (version "1.0.0-alpha8")
;;  (build-system dune-build-system)
;;  (arguments `(#:package "dream"))
;;  (home-page "https://github.com/camlworks/dream")
;;  (source
;;      (github-tag-origin
;;       name home-page version
;;       "0hhw4z6y09pi410lq2hzd9p2b1ck394kbwma1sbh0mwlng66r400"
;;       ""))
;;  (native-inputs
;;   (list ocaml-alcotest))
;;  (propagated-inputs
;;   (list ocaml-ppx-deriving
;;         ocaml-graphql-lwt
;;         ocaml-magic-mime
;;         ocaml-dream-mirage
;;         ocaml-multipart-form-lwt
;;         ocaml-yojson
;;         ocaml-digestif
;;         ocaml-ssl
;;         ocaml-lwt-ssl
;;         ocaml-mirage-crypto
;;         ocaml-ptime
;;         ocaml-httpun-ws
;;         ocaml-mirage-crypto
;;         ocaml-unstrctrd
;;         ;; ocaml-lwt-ssl
;;         ocaml-lwt-ppx))
;;  (synopsis "Tidy, feature-complete Web framework ")
;;  (description "")
;;  (license license:gpl3+)))

(define-public ocaml-eio-ssl
  (package
    (name "ocaml-eio-ssl")
    (version "0.3.0")
    (home-page "https://github.com/anmonteiro/eio-ssl")
    (source
     (github-tag-origin
      name home-page version
      "0yq5p7wx5fhs50c3zlswma4hbj5is5w0ll4x6833cs62jzfyxnqp"
      ""
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-eio ocaml-ipaddr ocaml-ke ocaml-uri ocaml-ssl))
    (synopsis "")
    (description "")
    (license license:lgpl2.0)
    ))

(define-public ocaml-magic-mime
  (package
    (name "ocaml-magic-mime")
    (version "1.3.1")
    (home-page
     "https://github.com/mirage/ocaml-magic-mime")
    (source
     (github-tag-origin
      name home-page version
      "1yi681s1bbbnjz11bfah5g93jcl18varhs5m346bq4c2m4njw8x9"
      "v"
      ))
    (build-system dune-build-system)
    ;; (propagated-inputs (list ocaml-eio ocaml-ipaddr ocaml-ke ocaml-uri ocaml-ssl))
    (synopsis "Convert file extensions to MIME types")
      (description "This library contains a database of MIME types that maps filename extensions into MIME types suitable for use in many Internet protocols such as HTTP or e-mail. It is generated from the mime.types file found in Unix systems, but has no dependency on a filesystem since it includes the contents of the database as an ML datastructure."
       )
      (license license:isc)
    ))

(define-public ocaml-faraday
  (package
    (name "ocaml-faraday")
    (version "0.8.2")
    (home-page
     "https://github.com/inhabitedtype/faraday")
    (source
     (github-tag-origin
      name home-page version "00kca7f1qhcfps3fxn3rxrsiiir1ziqpbbhv5p7dvmhihw7287n1"
      ""
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-bigstringaf ocaml-lwt ocaml-async ocaml-alcotest
                             ))
    (synopsis
     "Serialization library built for speed and memory efficiency"
     )
    (description "Faraday is a library for writing fast and memory-efficient serializers. Its core type and related operation gives the user fine-grained control over copying and allocation behavior while serializing user-defined types, and presents the output in a form that makes it possible to use vectorized write operations, such as the writev system call, or any other platform or application-specific output APIs."
       )
      (license license:bsd-3)
    ))

(define-public ocaml-mirage-crypto
  (package
    (name "ocaml-mirage-crypto")
    (version "2.0.2")
    (home-page
     "https://github.com/mirage/mirage-crypto"
     )
    (arguments
     ;; No tests
     `(#:tests? #f))
    (source
     (github-tag-origin
      name home-page version
      "0zsqd5fhvq3cq00drymbbbzy7wxz72h5ppzxlh0yr1ssj4jn0lp4"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list
                        ocaml-ohex
                        ocaml-zarith
                        ocaml-mirage-sleep
                        ocaml-mirage-runtime
                        ocaml-logs ocaml-digestif ocaml-duration ocaml-eqaf ocaml-mirage-mtime ocaml-miou))
    (synopsis "Cryptographic primitives for OCaml, in OCaml (also used in MirageOS) ")
    (description "mirage-crypto is a small cryptographic library that puts emphasis on the applicative style and ease of use. It includes basic ciphers (AES, 3DES, RC4, ChaCha20/Poly1305), AEAD primitives (AES-GCM, AES-CCM, ChaCha20/Poly1305), public-key primitives (RSA, DSA, DH), elliptic curves (NIST P-256, P-384, P-521, and curve 25519), and a strong RNG (Fortuna).")
    (license license:isc)
    ))

(define-public ocaml-ohex
  (package
    (name "ocaml-ohex")
    (version "0.2.0")
    (home-page
     "https://git.robur.coop/robur/ohex"
     )
    (source
     (github-tag-origin
      name home-page version "1ky2vg25h18wjzjb40bm8qyv153wcgh9526xjdrp3f0m14h3yn7n"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-alcotest))
    (synopsis "")
    (description "")
    (license license:isc)
    ))

(define-public ocaml-mirage-mtime
  (package
    (name "ocaml-mirage-mtime")
    (version "5.2.0")
    (home-page
     "https://github.com/mirage/mirage-mtime"
     )
    (source
     (github-tag-origin
      name home-page version
      "0x1smji6hc5wjwky01d581vkil0c5b2kjqhw8s10rp262xsyhn24"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-logs))
    (synopsis "")
    (description "")
    (license license:isc)
    ))

(define-public ocaml-gmap
  (package
    (name "ocaml-gmap")
    (version "0.3.0")
    (home-page
     "https://github.com/hannesm/gmap"
     )
    (source
     (github-tag-origin
      name home-page version "0880mhcybr662k6wnahx5mwbialh878kkzxacn47qniadd21x411"
      ""
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ohex ocaml-digestif ocaml-ptime ocaml-fpath ocaml-bos ocaml-ipaddr
                             ocaml-mirage-crypto ocaml-kdf
                             ))
    (synopsis "")
    (description "")
    (license license:isc)
    ))

(define-public ocaml-asn1-combinators
  (package
    (name "ocaml-asn1-combinators")
    (version "0.3.2")
    (home-page
     "https://github.com/mirleft/ocaml-asn1-combinators"
     )
    (source
     (github-tag-origin
      name home-page version "0qbkn1wjbfqkj7pggrmiraffw6yds1324d8jb78l160kdqpzvpq8"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ptime
                             ))
    (native-inputs (list ocaml-ohex))
    (synopsis "")
    (description "")
    (license license:isc)
    ))

(define-public ocaml-mirage-ptime
  (package
    (name "ocaml-mirage-ptime")
    (version "5.1.0")
    (home-page "https://github.com/mirage/mirage-ptime"
               )
    (source
     (github-tag-origin
      name home-page version "13y9b4sl7mjax3djby94f4kcbvqf3ck2b52xhwqx3vbh78hg6pl4"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ptime))
    (synopsis "")
    (description "")
    (license license:isc)
    ))
(define-public ocaml-mirage-kv
  (package
    (name "ocaml-mirage-kv")
    (version "6.1.1")
    (home-page "https://github.com/mirage/mirage-kv"
               )
    (source
     (github-tag-origin
      name home-page version "1i0q9023my6b2xy2jx65g52xywgi3fl0giixs744n9ryn83yrw7q"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-lwt ocaml-ptime ocaml-optint ocaml-fmt ocaml-alcotest))
    (synopsis "")
    (description "")
    (license license:isc)
    ))

(define-public ocaml-tls
  (package
    (name "ocaml-tls")
    (version "2.0.3")
    (home-page "https://github.com/mirleft/ocaml-tls")
    (source
     (github-tag-origin
      name home-page version "1w188b4c3cpfzgxyhil6g319r7y3hk9lw6wyf1881hwxsf6kprqq"
      "v"
      ))
    (arguments
    ;; Tests take FOREVER
     '(#:tests? #f))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ppx-jane ocaml-mirage-crypto ocaml-ptime ocaml-x509 ocaml-eio ocaml-core-unix ocaml-async ocaml-cstruct-async ocaml-mirage-ptime ocaml-mirage-kv ocaml-mirage-flow ocaml-crowbar ocaml-hxd ocaml-eio-main))
    ;; (propagated-inputs (list ocaml-ohex ocaml-digestif ocaml-ptime ocaml-fpath ocaml-bos ocaml-ipaddr
    ;;                          ocaml-mirage-crypto ocaml-kdf ocaml-gmap ocaml-asn1-combinators
    ;;                          ))
    (native-inputs (list gmp))
    (synopsis "TLS in pure OCaml")
    (description "Transport Layer Security (TLS) is probably the most widely deployed security protocol on the Internet. It provides communication privacy to prevent eavesdropping, tampering, and message forgery. Furthermore, it optionally provides authentication of the involved endpoints. TLS is commonly deployed for securing web services (HTTPS), emails, virtual private networks, and wireless networks.")
    (license license:isc)
    ))

(define-public ocaml-ca-certs
  (package
    (name "ocaml-ca-certs")
    (version "1.0.1")
    (home-page
     "https://github.com/mirage/ca-certs"
     )
    (source
     (github-tag-origin
      name home-page version
      "1pd7903cizj6qq5d0bl34i7q2y50vs6gzxbc87dwqswsfji3mffr"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ohex ocaml-digestif ocaml-ptime ocaml-fpath ocaml-bos ocaml-x509))
    (native-inputs (list gmp))
    (arguments
     ;; no trust anchor
     '(#:tests? #f))
    (synopsis "")
    (description "")
    (license license:isc)
    ))

(define-public ocaml-x509
  (package
    (name "ocaml-x509")
    (version "1.0.6")
    (home-page
     "https://github.com/mirleft/ocaml-x509"
     )
    (source
     (github-tag-origin
      name home-page version "0mdyyp5lddc870jl2vrll77yfkq0ckhf77wgazpkr8q3995ckl4h"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ohex ocaml-digestif ocaml-ptime ocaml-fpath ocaml-bos ocaml-ipaddr
                             ocaml-mirage-crypto ocaml-kdf ocaml-gmap ocaml-asn1-combinators
                             ))
    (native-inputs (list gmp))
    (synopsis "")
    (description "")
    (license license:isc)
    ))

(define-public ocaml-ca-certs
  (package
    (name "ocaml-ca-certs")
    (version "1.0.1")
    (home-page
     "https://github.com/mirage/ca-certs"
     )
    (source
     (github-tag-origin
      name home-page version
      "1pd7903cizj6qq5d0bl34i7q2y50vs6gzxbc87dwqswsfji3mffr"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ohex ocaml-digestif ocaml-ptime ocaml-fpath ocaml-bos ocaml-x509))
    (native-inputs (list gmp))
    (arguments
     ;; no trust anchor
     '(#:tests? #f))
    (synopsis "")
    (description "")
    (license license:isc)
    ))

(define-public ocaml-mirage-sleep
  (package
    (name "ocaml-mirage-sleep")
    (version "4.1.0")
    (home-page
     "https://github.com/mirage/mirage-sleep"
     )
    (source
     (github-tag-origin
      name home-page version "139jh41j5yxg8l98lfk6rh9qpxh57gc0wazlimzd81s6wqmi5v3p"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-duration ocaml-lwt))
    (synopsis "")
    (description "")
    (license license:isc)
    ))

(define-public ocaml-gluten
  (package
    (name "ocaml-gluten")
    (version "0.5.2")
    (home-page
     "https://github.com/anmonteiro/gluten"
     )
    (source
     (github-tag-origin
      name home-page version
      "0z7b68c2l90lnlds03b459vm16pcril12hl3fr4m3wwh8kfin3wc"
      ""
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-lwt ocaml-mirage-flow ocaml-faraday ocaml-eio))
    ;; (propagated-inputs (list ocaml-logs ocaml-cstruct ocaml-mirage-mtime ocaml-alcotest ocaml-angstrom))
    (synopsis "")
    (description "")
    (license license:isc)
    ))

(define-public ocaml-h2
  (package
    (name "ocaml-h2")
    (version "0.13.0")
    (home-page
     "https://github.com/anmonteiro/ocaml-h2"
     )
    (source
     (github-tag-origin
      name home-page version "13j67g9kv50zhn5c3vz9s536y3ja0qd8kazm7nafkniabxa1hli9" ""))
    (propagated-inputs (list ocaml-faraday ocaml-angstrom ocaml-mirage-flow ocaml-gluten ocaml-httpun ocaml-base64 ocaml-hex ocaml-yojson))
    (arguments
     ;; http2-frame-test-case broken
     '(#:tests? #f))
    (build-system dune-build-system)
    (synopsis "")
    (description "")
    (license license:isc)
    ))

(define-public ocaml-sedlex
  (package
    (name "ocaml-sedlex")
    (version "3.7")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/ocaml-community/sedlex/archive/refs/tags/v3.7.tar.gz")
       (sha256
        (base32 "0l88w2rr5wkrgj3hr6ara39ra5d9zijv26y1qxlpx4sz1xqqkd7d"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ppxlib ocaml-gen
                             ))
    (native-inputs (list ocaml-ppx-expect))
    (home-page "https://github.com/ocaml-community/sedlex")
    (synopsis "An OCaml lexer generator for Unicode")
    (description
     "sedlex is a lexer generator for OCaml.  It is similar to ocamllex, but supports
Unicode.  Unlike ocamllex, sedlex allows lexer specifications within regular
OCaml source files.  Lexing specific constructs are provided via a ppx syntax
extension.")
    (license license:expat)))

(define-public ocaml-pecu
  (package
    (name "ocaml-pecu")
    (version "0.7")
    (build-system dune-build-system)
    (native-inputs (list ocaml-fmt ocaml-alcotest ocaml-crowbar ocaml-astring))
    (home-page "https://github.com/mirage/pecu")
    (synopsis "Encoder/Decoder of Quoted-Printable (RFC2045 & RFC2047)")
    (description
     "This package provides a non-blocking encoder/decoder of Quoted-Printable
according to RFC2045 and RFC2047 (about encoded-word).  Useful to translate
contents of emails.")
    (source
     (github-tag-origin
      name home-page version
      "0k2l94q7yms2b1cs2727df9xwmydbi4jg0myiyx47ph372i5xdi8"
      "v"
      ))
    (license license:expat)))

(define-public ocaml-mirage-flow
  (package
    (name "ocaml-mirage-flow")
    (version "5.0.0")
    (home-page
     "https://github.com/mirage/mirage-flow"
     )
    (source
     (github-tag-origin
      name home-page version
      "15183vj8sxz9d58m1baaqspjx709f84afvpyp2p9g1a9411yvliz"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-logs ocaml-cstruct ocaml-mirage-mtime ocaml-alcotest ocaml-angstrom))
    (synopsis "")
    (description "")
    (license license:isc)
    ))

(define-public ocaml-bigarray-overlap
  (package
    (name "ocaml-bigarray-overlap")
    (version "0.2.1")
    (home-page
     "https://github.com/dinosaure/overlap"
     )
    (source
     (github-tag-origin
      name home-page version "1j1d4iisn9nkvipgwii9g116iv60ci863ip4wwcl7ijvpi6n0jv2"
      "v"
      ))
    (native-inputs (list pkg-config))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-alcotest))
    (synopsis "")
    (description "")
    (license license:expat)
    ))

(define-public ocaml-hxd
  (package
    (name "ocaml-hxd")
    (version "0.3.5")
    (home-page
     "https://github.com/dinosaure/hxd"
     )
    (source
     (github-tag-origin
      name home-page version "0nfiw2kqqzs27ah9k7y3jd4syvjwqfvw64sl7n5gl0677g5izn50"
      "v"
      ))
    (propagated-inputs (list ocaml-cmdliner))
    (build-system dune-build-system)
    ;; (propagated-inputs (list ocaml-angstrom ocaml-uutf ocaml-ke ocaml-crowbar ocaml-rresult ocaml-hxd))
    (synopsis "")
    (description "")
    (license license:expat)
    (arguments
     ;; tests failing, unsure
     '(#:tests? #f))
    ))

(define-public ocaml-unstrctrd
  (package
    (name "ocaml-unstrctrd")
    (version "0.4")
    (home-page
     "https://github.com/dinosaure/unstrctrd"
     )
    (source
     (github-tag-origin
      name home-page version
      "1x1jglg5c9hzsgdcldcv5vw6kr3p4v0kx3x62k6dsiiv8bryf600"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-angstrom ocaml-uutf ocaml-ke ocaml-crowbar ocaml-rresult ocaml-hxd))
    (synopsis "")
    (description "")
    (license license:expat)
    ))

(define-public ocaml-oseq
  (package
    (name "ocaml-oseq")
    (version "0.5.1")
    (home-page "https://github.com/c-cube/oseq"
     )
    (source
     (github-tag-origin
      name home-page version "1yfbh5xm6wh8bsbb4c0v0hxpidz2jssbjpgvl9gp1g3gm4wgyakz"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-containers))
    (synopsis "Purely functional iterators compatible with standard `seq`. ")
    (description "Simple list of suspensions, as a composable lazy iterator that behaves like a value.  The type of sequences, 'a OSeq.t, is compatible with the new standard type of iterators 'a Seq.t.")
    (license license:bsd-2)
    ))

(define-public ocaml-dscheck
  (package
    (name "ocaml-dscheck")
    (version "0.5.0")
    (home-page "https://github.com/ocaml-multicore/dscheck"
     )
    (source
     (github-tag-origin
      name home-page version "06jcd0r0iw9h226r8fik8qzblspgk2dbvzf72x8k0ij3z6vz6m82"
      ""
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-oseq))
    (synopsis "")
    (description "")
    (license license:expat)
    ))

(define-public ocaml-kdf
  (package
    (name "ocaml-kdf")
    (version "1.0.0")
    (home-page "https://github.com/robur-coop/kdf"
     )
    (source
     (github-tag-origin
      name home-page version "1ggw55mppvxliwahv54ryq8znilnd17asas1m301bq08bznff9fy"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-digestif ocaml-mirage-crypto))
    (synopsis "")
    (description "")
    (license license:expat)
    ))

(define-public ocaml-miou
  (package
    (name "ocaml-miou")
    (version "0.4.0")
    (home-page "https://github.com/robur-coop/miou"
     )
    (source
     (github-tag-origin
      name home-page version "14wlxfmh0yrwdgvk83w84i1hyfs4f592i6gic5qfxyw1l2xgbdc9"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-dscheck))
    (synopsis "")
    (description "")
    (license license:expat)
    ))

(define-public ocaml-multipart-form
  (package
    (name "ocaml-multipart-form")
    (version "0.7.0")
    (home-page "https://github.com/dinosaure/multipart_form"
     )
    (source
     (github-tag-origin
      name home-page version
      "1bq03iarfrad7l2xv3hqnzf2acacjq4l9akwz208i65vazp47fq2"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-miou ocaml-ke ocaml-angstrom ocaml-eio ocaml-pecu ocaml-cohttp ocaml-cohttp-lwt ocaml-unstrctrd ocaml-prettym ocaml-alcotest-lwt ocaml-rosetta))
    (synopsis "normal version")
    (description "")
    (license license:expat)
    ))

(define-public ocaml-multipart-form-lwt
  (package
    (name "ocaml-multipart-form-lwt")
    (version "0.7.0")
    (home-page "https://github.com/dinosaure/multipart_form"
     )
    (source
     (github-tag-origin
      name home-page version
      "1bq03iarfrad7l2xv3hqnzf2acacjq4l9akwz208i65vazp47fq2"
      "v"
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-multipart-form))
    (synopsis "normal version")
    (description "")
    (arguments
     `(#:package "multipart_form-lwt"))
    (license license:expat)
    ))

(define-public ocaml-multipart-form-piaf
  (package
    (name "ocaml-multipart-form-piaf")
    (version "0.0.0-06a86ad")
    (home-page "https://github.com/anmonteiro/multipart_form")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/anmonteiro/multipart_form")
             (commit "06a86ad395a4f09cdf1ac4fd1f15993521e7ac47")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0ybig1cqfphwc79m7bmp2x2hd9jdy6jvz4il17vq4v8b1iphkfgr"
                )))
     )
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-miou ocaml-ke ocaml-angstrom ocaml-eio ocaml-pecu ocaml-cohttp ocaml-cohttp-lwt ocaml-unstrctrd ocaml-prettym ocaml-alcotest-lwt ocaml-rosetta ocaml-faraday))
    (synopsis "forked version for piaf")
    (description "")
    (license license:expat)
    ))

(define-public ocaml-prettym
  (package
    (name "ocaml-prettym")
    (version "0.0.3")
    (home-page "https://github.com/dinosaure/prettym")
    (source
     (github-tag-origin
      name home-page version "1sh0j23if7scaqbq8gzl181dy28l2zyc5gvr6l891p0znf53m1lf"
      ""
      ))
    (propagated-inputs (list ocaml-bigstringaf ocaml-ke ocaml-bigarray-overlap ocaml-jsonm ocaml-base64))
    (build-system dune-build-system)
    ;; (propagated-inputs (list ocaml-logs ocaml-cstruct ocaml-mirage-mtime ocaml-alcotest ocaml-angstrom))
    (synopsis "A simple bounded encoder constraints by columns in OCaml ")
    (description "prettym is a simple bounded encoder to serialize human readable values and respect the 80-column constraint. It permits to serialize values in the respect of RFC 822 and put fws token when necessary.

For example, a list of email addresses should fits under the 80 column for an email. The encoder should find the opportunity to add a line breaker plus a space to respect RFC 822.")
    (license license:expat)
    ))

(define-public ocaml-httpun
  (package
    (name "ocaml-httpun")
    (version "0.2.0")
    (home-page
     "https://github.com/anmonteiro/httpun")
    (source
     (github-tag-origin
      name home-page version
      "056q1qm49xfhkkjyyxbrp5njqzgwlh2ngzql4cwqcg9f6h04gvpx"
      ""
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-bigstringaf ocaml-faraday ocaml-cstruct
                             ocaml-mirage-flow ocaml-gluten
                             ))
    (synopsis
     "A high performance, memory efficient, and scalable web server written in OCaml "
     )
    (description
     "http/un is a high-performance, memory-efficient, scalable and web library for OCaml. It uses the Angstrom and Faraday libraries for parsing and serialization."
       )
      (license license:bsd-3)
    ))

(define-public ocaml-httpun-0.1.0
  (package
    (inherit ocaml-httpun)
    (name "ocaml-httpun-0.1.0")
    (version "0.1.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/anmonteiro/httpun/archive/"
                          version ".tar.gz"))
       (sha256
        (base32 "02l4s18hryzkgqjjixd66k2hvkcfhdcjvmi63h5vc3s2kzgx95rp"))))))

(define-public ocaml-httpun-ws
  (package
    (name "ocaml-httpun-ws")
    (version "0.2.0")
    (home-page
     "https://github.com/anmonteiro/httpun-ws")
    (source
     (github-tag-origin
      name home-page version
      "12cc219q5bgpfwj2d8k6rykcadpgzcw0sgj52rbw207i227z1r35"
      ""
      ))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-bigstringaf ocaml-faraday ocaml-cstruct
                             ocaml-mirage-flow ocaml-gluten ocaml-digestif
                             ocaml-base64 ocaml-httpun
                             ))
    (synopsis
     "A high performance, memory efficient, and scalable web server written in OCaml (websockets) "
     )
    (description "httpun-ws is a Websocket implementation that uses http-un for the initial connection and upgrade.

It started as a fork of websocketaf, but has since diverged quite a bit, given the meager implementation in the original work."
       )
      (license license:bsd-3)
    ))

(define-public ocaml-httpun-ws-0.1.0
  (package
    (inherit ocaml-httpun-ws)
    (name "ocaml-httpun-ws-0.1.0")
    (version "0.1.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/anmonteiro/httpun-ws/archive/"
                          version ".tar.gz"))
       (sha256
        (base32 "1wmfdj94ckqj4438v4xabxzg198z195lzc2qp5mk6q9xp2lmfr76"))))
    (propagated-inputs (list ocaml-httpun-0.1.0
                             ocaml-faraday
                             ocaml-base64
                             ocaml-angstrom
                             ocaml-bigstringaf
                             ocaml-gluten
                             ocaml-gluten-lwt
                             ocaml-lwt
                             ocaml-digestif))))

(define-public ocaml-piaf
  (package
    (name "ocaml-piaf")
    (version "0.2.0")
    (home-page "https://github.com/anmonteiro/piaf")
    (source
     (github-tag-origin
      name home-page version
      "0l7rbh6lgxjsxrbsyp5jrh2kxida0si0vv06jp32iimvicyjh2m5"
      ""))
    (build-system dune-build-system)
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'use-system-multipart-form-piaf
           (lambda _
             ;; Use system ocaml-multipart-form-piaf instead of vendored version
             ;; Replace vendor/dune to use system package
             (with-output-to-file "vendor/dune"
               (lambda ()
                 (display ";; Use system multipart_form-piaf package\n")))
             ;; Patch multipart/dune to use system piaf_multipart_form
             (substitute* "multipart/dune"
               (("piaf\\.multipart_form")
                "piaf_multipart_form"))
             #t)))))
    (propagated-inputs (list ocaml-eio ocaml-ipaddr ocaml-ke ocaml-uri ocaml-ssl ocaml-magic-mime ocaml-eio-ssl ocaml-async ocaml-faraday ocaml-async ocaml-httpun ocaml-pecu ocaml-prettym ocaml-httpun-ws ocaml-h2 ocaml-unstrctrd ocaml-multipart-form-piaf))
    (synopsis "Web library for OCaml with support for HTTP/1.X / HTTP/2")
      (description "")
      (license license:bsd-3)
    ))

(define-public ocaml-domain-local-await
  (package
    (name "ocaml-domain-local-await")
    (version "1.0.1")
    (home-page
     "https://github.com/ocaml-multicore/domain-local-await")
    (source
     (github-tag-origin
      name home-page version
      "0h60sxzd9p14ilpg004d47y3zd89pswffr0wvqa9cykpn8qgdfcm" ""
      ))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (propagated-inputs (list ocaml-thread-table))
    (properties `((upstream-name . "domain-local-await")))
      (synopsis "OCaml library for local domain await")
      (description "A low level mechanism intended for writing higher level libraries that need to block in a scheduler friendly manner.

A library that needs to suspend and later resume the current thread of execution may simply call prepare_for_await to obtain a pair of await and release operations for the purpose.")
      ;; With linking exception.
      (license license:isc)
    ))

(define-public ocaml-eio
  (package
    (name "ocaml-eio")
    (version "1.3")
    (home-page "https://github.com/ocaml-multicore/eio")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256 (base32
                "05s3zs416y4284bcj20c7w2vdz4in1iaplgjnxmm9n3f1wyk2jqv"))))
    (build-system dune-build-system)
    (arguments `(#:package "eio"))
    (propagated-inputs (list ocaml-bigstringaf
                             ocaml-cstruct
                             ocaml-lwt
                             ocaml-lwt-dllist
                             ocaml-logs
                             ocaml-optint
                             ocaml-psq
                             ocaml-fmt
                             ocaml-hmap
                             ocaml-mtime
                             ocaml-domain-local-await
                             ;;
                             ))
    (native-inputs (list ocaml-astring
                         ocaml-crowbar
                         ocaml-alcotest
                         ocaml-mdx))
    (synopsis "Effect-based direct-style IO API for OCaml")
    (description "This package provides an effect-based IO API for multicore
OCaml with fibers.")
    (license license:isc)))

;; (define-public ocaml-eio-luv
;;   (package
;;     (inherit ocaml-eio)
;;     (name "ocaml-eio-luv")
;;     (arguments `(#:package "eio-luv"))
;;     (propagated-inputs (list ocaml-eio ocaml-luv))
;;     (native-inputs (list ocaml-mdx))
;;     (synopsis "Libuv-based backend for Ocaml Eio")
;;     (description "@code{Eio_luv} provides a cross-platform backend for
;; @code{Ocaml Eio}'s APIs using luv (libuv)")))

;; (define-public ocaml5.4-eio-luv
;;   (package-with-ocaml5.0 ocaml-eio-luv))

(define-public ocaml-unionfind
  (package
    (name "ocaml-unionfind")
    (version "20220122")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://gitlab.inria.fr/fpottier/unionfind")
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0hdh56rbg8vfjd61q09cbmh8l5wmry5ykivg7gsm0v5ckkb3531r"))))
    (build-system dune-build-system)
    (arguments
     (list ;; The test allocates an Array that is too large for OCaml when on a
           ;; 32-bit architecture.
           #:tests? (target-64bit?)))
    (home-page "https://gitlab.inria.fr/fpottier/unionFind")
    (synopsis "Union-find data structure")
    (description "This package provides two union-find data structure
implementations for OCaml.  Both implementations are based on disjoint sets
forests, with path compression and linking-by-rank, so as to guarantee good
asymptotic complexity: every operation requires a quasi-constant number of
accesses to the store.")
    ;; Version 2 only, with linking exception.
    (license license:lgpl2.0)))

(define-public ocaml-uring
  (package
    (name "ocaml-uring")
    (version "2.7.0")
    (home-page "https://github.com/ocaml-multicore/ocaml-uring")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url home-page)
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256 (base32
                 "0ja1z1if07wyk61vz3d5i1bcm1a1vbpazjakg0g2ppjfaphbhcv8"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-cstruct
           ocaml-fmt
           ocaml-optint))
    (native-inputs
     (list ocaml-lwt
           ocaml-bechamel
           ocaml-logs
           ocaml-cmdliner
           ocaml-mdx))
    (synopsis "OCaml bindings for Linux io_uring")
    (description "This package provides OCaml bindings to the Linux
@code{io_uring} kernel IO interfaces.")
    (license
     (list license:isc license:expat))))

(define ocaml-eio-linux
  (package
    (inherit ocaml-eio)
    (name "ocaml-eio-linux")
    (arguments `(#:package "eio_linux"
                 #:tests? #f
                 ))
    (propagated-inputs
     (list ocaml-eio
           ocaml-uring
           ocaml-logs
           ocaml-fmt))
    (native-inputs
     (list ocaml-mdx
           ocaml-alcotest
           ocaml-mdx))
    (synopsis "Linux backend for ocaml-eio")
    (description "@code{Eio_linux} provides a Linux io-uring backend for
@code{Ocaml Eio} APIs, plus a low-level API that can be used directly
(in non-portable code).")))

(define-public ocaml5.0-eio-linux
  (package-with-ocaml5.0 ocaml-eio-linux))

(define ocaml-eio-main
  (package
    (inherit ocaml-eio)
    (name "ocaml-eio-main")
    (arguments `(#:package "eio_main"
                 ;; tests require network
                 #:tests? #f))
    (propagated-inputs
     (list ocaml-eio
           ;; ocaml-eio-luv
           ocaml-eio-linux))
    (native-inputs
     (list ocaml-mdx))
    (synopsis "Eio backend selector")
    (description "@code{Eio_main} selects an appropriate backend (e.g.
@samp{eio_linux} or @samp{eio_luv}), depending on your platform.")))

(define-public ocaml5.0-eio-main
  (package-with-ocaml5.0 ocaml-eio-main))

(define-public ocaml-lwt
  (package
    (name "ocaml-lwt")
    (version "5.9.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ocsigen/lwt")
               (commit version)))
        (file-name (git-file-name name version))
        (sha256 (base32
                 "1vvyjnw9xcsc1zqjsp2s75g3dl0as573rk67i1va3hbhvm230fm7"
                 ))))
    (build-system dune-build-system)
    (arguments
     `(#:package "lwt"))
    (native-inputs
     (list ocaml-cppo pkg-config))
    (inputs
     (list glib))
    (propagated-inputs
     (list ocaml-mmap ocaml-ocplib-endian ocaml-seq libev))
    (home-page "https://github.com/ocsigen/lwt")
    (synopsis "Cooperative threads and I/O in monadic style")
    (description "Lwt provides typed, composable cooperative threads.  These
make it easy to run normally-blocking I/O operations concurrently in a single
process.  Also, in many cases, Lwt threads can interact without the need for
locks or other synchronization primitives.")
    (license license:lgpl2.1)))

(define-public ocaml-lwt-ppx
  (package
    (name "ocaml-lwt-ppx")
    (version "5.9.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ocsigen/lwt")
               (commit version)))
        (file-name (git-file-name name version))
        (sha256 (base32
                 "1vvyjnw9xcsc1zqjsp2s75g3dl0as573rk67i1va3hbhvm230fm7"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "lwt_ppx"))
    (native-inputs
     (list ocaml-cppo pkg-config))
    (inputs
     (list glib))
    (propagated-inputs
     (list ocaml-mmap ocaml-ocplib-endian ocaml-seq libev ocaml-ppxlib ocaml-lwt))
    (home-page "https://github.com/ocsigen/lwt")
    (synopsis "Cooperative threads and I/O in monadic style")
    (description "Lwt provides typed, composable cooperative threads.  These
make it easy to run normally-blocking I/O operations concurrently in a single
process.  Also, in many cases, Lwt threads can interact without the need for
locks or other synchronization primitives.")
    (license license:lgpl2.1)))

(define-public ocaml-lwt-ssl
  (package
    (name "ocaml-lwt-ssl")
    (version "1.2.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/ocsigen/lwt_ssl"
                    )
               (commit version)))
        (file-name (git-file-name name version))
        (sha256 (base32 "0dml6rmb5975k4cmizd9lwzqf56d0n3kgmd9ysd76px7z7x94j9f"
                        ))))
    (build-system dune-build-system)
    (native-inputs
     (list ocaml-cppo pkg-config))
    (inputs
     (list glib))
    (propagated-inputs (list ocaml-ssl ocaml-lwt))
    ;; (propagated-inputs
    ;;  (list ocaml-mmap ocaml-ocplib-endian ocaml-seq libev ocaml-ppxlib ocaml-lwt))
    (home-page "https://github.com/ocsigen/lwt")
    (synopsis ""
     )
    (description ""
     )
    (license license:lgpl2.1)))

(define-public ocaml-lwt-dllist
  (package
    (name "ocaml-lwt-dllist")
    (version "1.0.1")
    (home-page "https://github.com/mirage/lwt-dllist")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "18bi8fb4yly1pyf43pjvvdhlyzb3wkgxifffx9d1g9y2mwsng6jw"))))
    (build-system dune-build-system)
    (native-inputs (list ocaml-lwt))
    (synopsis "OCaml library providing mutable doubly-linked list with Lwt iterators")
    (description "This OCaml library provides an implementation of a mutable
doubly-linked list with Lwt iterators.")
    (license license:expat)))


(define-public ocaml-shared-memory-ring
  (package
    (name "ocaml-shared-memory-ring")
    (version "3.1.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mirage/shared-memory-ring")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "12cpbia39aifnd8rxpsra0lhssqj5qw0zygb5fd8kg58zy2clmrr"))))
    (build-system dune-build-system)
    (arguments
     '(#:package "shared-memory-ring"))
    (propagated-inputs (list ocaml-cstruct ocaml-ppx-cstruct ocaml-lwt-dllist
                             ocaml-mirage-profile))
    (native-inputs (list ocaml-ounit))
    (home-page "https://github.com/mirage/shared-memory-ring")
    (synopsis "Xen-style shared memory rings")
    (description
     "Libraries for creating shared memory producer/consumer rings.  The rings
follow the Xen ABI and may be used to create or implement Xen virtual
devices.")
    (license license:isc)))

(define-public ocaml-shared-memory-ring-lwt
  (package
    (inherit ocaml-shared-memory-ring)
    (name "ocaml-shared-memory-ring-lwt")
    (arguments
     '(#:package "shared-memory-ring-lwt"))
    (propagated-inputs (modify-inputs (package-propagated-inputs
                                       ocaml-shared-memory-ring)
                         (append ocaml-shared-memory-ring)))))

(define-public ocaml-xenstore
  (package
    (name "ocaml-xenstore")
    (version "2.2.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mirage/ocaml-xenstore")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1acld5gxmvnhl5iyyy5ancpm7fv9d6ns1x32krcmb62p2czd00ky"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-cstruct ocaml-ppx-cstruct ocaml-lwt))
    (native-inputs (list ocaml-ounit2))
    (home-page "https://github.com/mirage/ocaml-xenstore")
    (synopsis "Xenstore protocol in pure OCaml")
    (description "Repository contents:
@itemize
@item client library, a merge of the Mirage and XCP ones
@item server library
@item server instance which runs under Unix with libxc
@item server instance which runs on mirage.
@end itemize
The client and the server libraries have sets of unit-tests.")
    ;; Has a linking exception, see LICENSE.md.
    (license license:lgpl2.1)))

(define-public ocaml-mirage-xen
  (package
    (name "ocaml-mirage-xen")
    (version "8.0.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mirage/mirage-xen")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1qydg92dbw8hj4b809apj0f51cjgmamq3zdf34a4wyn5jv85yzyx"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-cstruct
                             ocaml-lwt
                             ocaml-shared-memory-ring-lwt
                             ocaml-xenstore
                             ocaml-lwt-dllist
                             ;; ocaml-mirage-profile  dependency cycle
                             ocaml-io-page
                             ocaml-mirage-runtime
                             ocaml-logs
                             ocaml-fmt
                             ocaml-bheap
                             ocaml-duration))
    (home-page "https://github.com/mirage/mirage-xen")
    (synopsis "Xen core platform libraries for MirageOS")
    (description
     "MirageOS OS library for Xen targets, which handles the main
loop and timers.  It also provides the low level C startup code and C stubs
required by the OCaml code.")
    (license license:isc)))

(define-public ocaml-io-page
  (package
    (name "ocaml-io-page")
    (version "3.0.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mirage/io-page")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0lmvm1whdw5s7rvi7jnjzicrp2j919dkjl856jwyjlq38f7qn0zm"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-cstruct))
    (native-inputs (list pkg-config ocaml-ounit))
    (home-page "https://github.com/mirage/io-page")
    (synopsis "Support for efficient handling of I/O memory pages")
    (description
     "IO pages are page-aligned, and wrapped in the @code{Cstruct} library to
avoid copying the data contained within the page.")
    (license license:isc)))

(define-public ocaml-bheap
  (package
    (name "ocaml-bheap")
    (version "2.0.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/backtracking/bheap")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0b8md5zl4yz7j62jz0bf7lwyl0pyqkxqx36ghkgkbkxb4zzggfj1"))))
    (build-system dune-build-system)
    (native-inputs (list ocaml-stdlib-shims))
    (home-page "https://github.com/backtracking/bheap")
    (synopsis "Priority queues")
    (description
     "Traditional implementation of priority queues using a binary heap
encoded in a resizable array.")
    (license license:lgpl2.1)))

(define-public ocaml-luv
  (package
    (name "ocaml-luv")
    (version "0.5.14")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/aantron/luv/releases/download/"
                                  version "/luv-" version ".tar.gz"))
              (sha256
               (base32
                "16dfv8gzpqdcqpcil5pd7a44vp64hw35q94fipcwsxl81jjv80cf"))
              (modules '((guix build utils)))
              (snippet
               '(begin
                  ;; Remove bundled configure and libuv.
                  (delete-file-recursively "src/c/vendor")
                  #t))))
    (build-system dune-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (add-before 'build 'use-system-libuv
                 (lambda _
                   (setenv "LUV_USE_SYSTEM_LIBUV" "yes")))
               (replace 'check
                 (lambda* (#:key tests? #:allow-other-keys)
                   (when tests?
                     (invoke "dune" "runtest" "--no-buffer" "--force")))))))
    (inputs (list libuv))
    (propagated-inputs (list ocaml-ctypes))
    (native-inputs (list ocaml-base ocaml-alcotest))
    (home-page "https://github.com/aantron/luv")
    (synopsis "Binding to libuv: cross-platform asynchronous I/O")
    (description
     "Luv is a binding to libuv, the cross-platform C library that does
asynchronous I/O in Node.js and runs its main loop.  Besides asynchronous I/O,
libuv also supports multiprocessing and multithreading.  Multiple event loops
can be run in different threads.  libuv also exposes a lot of other
functionality, amounting to a full OS API, and an alternative to the standard
module Unix.")
    (license license:expat)))

(define-public ocaml-lwt-react
  (package
    (inherit ocaml-lwt)
    (name "ocaml-lwt-react")
    (version "5.8.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ocsigen/lwt")
                     ;; Version from opam
                     (commit "5.8.0")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0l7pd4kl9n8ja4v0rx415l385qqxbbg1pq244zcknslkkd444zhr"))))
    (arguments
     `(#:package "lwt_react"))
    (properties `((upstream-name . "lwt_react")))
    (propagated-inputs
     (list ocaml-lwt ocaml-react))))

(define-public ocaml-lwt-log
  (package
    (name "ocaml-lwt-log")
    (version "1.1.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/aantron/lwt_log")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0mbv5l9gj09jd1c4lr2axcl4v043ipmhjd9xrk27l4hylzfc6d1q"))))
    (build-system dune-build-system)
    (arguments
     `(#:tests? #f)); require lwt_ppx
    (propagated-inputs
     `(("lwt" ,ocaml-lwt)))
    (properties `((upstream-name . "lwt_log")))
    (home-page "https://github.com/aantron/lwt_log")
    (synopsis "Logging library")
    (description "This package provides a deprecated logging component for
ocaml lwt.")
    (license license:lgpl2.1)))

(define-public ocaml-logs
  (package
    (name "ocaml-logs")
    (version "0.9.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://erratique.ch/software/logs/releases/"
                                  "logs-" version ".tbz"))
              (sha256
                (base32
                  "1m861xfcd80y2g298wxdcmhz43jfximkqid9vqcqzqhwlidhd5zf"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:tests? #f
       #:build-flags (list "build")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (add-after 'unpack 'disable-browser-support
           (lambda _
             ;; Disable js_of_ocaml browser support to avoid dependency
             (substitute* "pkg/pkg.ml"
               (("let jsoo = Conf.value c jsoo in")
                "let jsoo = false in"))))
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             ;; Use ocamlfind install with subdirs for sub-packages
             (let* ((out (assoc-ref outputs "out"))
                    (lib (string-append out "/lib/ocaml/site-lib/logs")))
               (with-directory-excursion "_build"
                 ;; Install main library
                 (invoke "ocamlfind" "install" "logs" "../pkg/META"
                         "src/logs.a" "src/logs.cma" "src/logs.cmxa"
                         "src/logs.cmxs" "src/logs.cmx"
                         "src/logs.cmi" "src/logs.mli")
                 ;; Manually create subdirectories and install sub-libraries
                 (for-each (lambda (sublib)
                             (let ((dir (string-append lib "/" sublib)))
                               (mkdir-p dir)
                               (for-each (lambda (f)
                                           (copy-file f (string-append dir "/" (basename f))))
                                         (find-files (string-append "src/" sublib)
                                                     "\\.(cma|cmxa|a|cmxs|cmx|cmi|mli)$"))))
                           '("fmt" "cli" "lwt" "threaded" "top")))))))))
    (native-inputs
     (list ocamlbuild))
    (propagated-inputs
     `(("fmt" ,ocaml-fmt)
       ("lwt" ,ocaml-lwt)
       ("mtime" ,ocaml-mtime)
       ;; ("result" ,ocaml-result)
       ("cmdliner" ,ocaml-cmdliner)
       ("topkg" ,ocaml-topkg)))
    (home-page "https://erratique.ch/software/logs")
    (synopsis "Logging infrastructure for OCaml")
    (description "Logs provides a logging infrastructure for OCaml.  Logging is
performed on sources whose reporting level can be set independently.  Log
message report is decoupled from logging and is handled by a reporter.")
    (license license:isc)))

(define-public ocaml-fpath
  (package
    (name "ocaml-fpath")
    (version "0.7.3")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://erratique.ch/software/fpath/releases/"
                                  "fpath-" version ".tbz"))
              (sha256
                (base32
                  "03z7mj0sqdz465rc4drj1gr88l9q3nfs374yssvdjdyhjbqqzc0j"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:tests? #f
       #:build-flags (list "build")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             ;; Use ocamlfind install to avoid circular dependency on opam-installer
             (let ((lib (string-append (assoc-ref outputs "out")
                                       "/lib/ocaml/site-lib")))
               (mkdir-p lib)
               (with-directory-excursion "_build"
                 (invoke "ocamlfind" "install" "fpath"
                         "../pkg/META"
                         "src/fpath.a"
                         "src/fpath.cma"
                         "src/fpath.cmxa"
                         "src/fpath.cmxs"
                         "src/fpath.cmx"
                         "src/fpath.cmi"
                         "src/fpath.mli"))))))))
    (native-inputs
     (list ocamlbuild))
    (propagated-inputs
     `(("topkg" ,ocaml-topkg)
       ("astring" ,ocaml-astring)))
    (home-page "https://erratique.ch/software/fpath")
    (synopsis "File system paths for OCaml")
    (description "Fpath is an OCaml module for handling file system paths with
POSIX or Windows conventions.  Fpath processes paths without accessing the
file system and is independent from any system library.")
    (license license:isc)))

(define-public ocaml-bos
  (package
    (name "ocaml-bos")
    (version "0.2.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://erratique.ch/software/bos/releases/"
                                  "bos-" version ".tbz"))
              (sha256
                (base32
                  "0dwg7lpaq30rvwc5z1gij36fn9xavvpah1bj8ph9gmhhddw2xmnq"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:tests? #f
       #:build-flags (list "build")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             ;; Use ocamlfind install to avoid circular dependency on opam-installer
             (let ((lib (string-append (assoc-ref outputs "out")
                                       "/lib/ocaml/site-lib")))
               (mkdir-p lib)
               (with-directory-excursion "_build"
                 (invoke "ocamlfind" "install" "bos"
                         "../pkg/META"
                         "src/bos.a"
                         "src/bos.cma"
                         "src/bos.cmxa"
                         "src/bos.cmxs"
                         "src/bos.cmx"
                         "src/bos.cmi"
                         "src/bos.mli"))))))))
    (native-inputs
     (list ocamlbuild))
    (propagated-inputs
     `(("topkg" ,ocaml-topkg)
       ("astring" ,ocaml-astring)
       ("fmt" ,ocaml-fmt)
       ("fpath" ,ocaml-fpath)
       ("logs" ,ocaml-logs)
       ("rresult" ,ocaml-rresult)))
    (home-page "https://erratique.ch/software/bos")
    (synopsis "Basic OS interaction for OCaml")
    (description "Bos provides support for basic and robust interaction with
the operating system in OCaml.  It has functions to access the process
environment, parse command line arguments, interact with the file system and
run command line programs.")
    (license license:isc)))

(define-public ocaml-xml-light
  (package
    (name "ocaml-xml-light")
    (version "2.4")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/ncannasse/xml-light")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "089ywjz84y4p5iln94y54vh03b5fm2zrl2dld1398dyrby96dp6s"))))
    (build-system ocaml-build-system)
    (arguments
     (list #:tests? #f ; There are no tests.
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'prefix
                 (lambda _
                   (substitute* "Makefile"
                     (("`\\$\\(OCAMLC\\) -where`")
                      (string-append #$output "/lib/ocaml/site-lib/xml-light")))))
               (delete 'configure) ; no configure
               (add-before 'install 'mkdir
                 (lambda _
                   (mkdir-p (string-append #$output "/lib/ocaml/site-lib/xml-light"))))
               (replace 'install
                 (lambda _
                   (invoke "make" "install_ocamlfind"))))))
    (home-page "https://github.com/ncannasse/xml-light")
    (synopsis "Minimal XML parser & printer for OCaml")
    (description
     "Xml-Light provides functions to parse an XML document into an OCaml data
structure, work with it, and print it back to an XML document.  It also
supports DTD parsing and checking, and is entirely written in OCaml, hence it
does not require additional C libraries.")
    (license license:lgpl2.1+))) ; with linking exception

(define-public ocaml-xmlm
  (package
    (name "ocaml-xmlm")
    (version "1.4.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://erratique.ch/software/xmlm/releases/"
                                  "xmlm-" version ".tbz"))
              (sha256
                (base32
                  "1ynrjba3wm3axscvggrfijfgsznmphhxnkffqch67l9xiqjm44h9"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:tests? #f
       #:build-flags (list "build")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))))
    (native-inputs
     (list ocamlbuild ocaml-topkg opam-installer))
    (home-page "https://erratique.ch/software/xmlm")
    (synopsis "Streaming XML codec for OCaml")
    (description "Xmlm is a streaming codec to decode and encode the XML data
format.  It can process XML documents without a complete in-memory
representation of the data.")
    (license license:isc)))

(define-public ocaml-gen
  (package
    (name "ocaml-gen")
    (version "1.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/c-cube/gen")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1z5nw5wljvcqp8q07h336bbvf9paynia0jsdh4486hlkbmr1ask1"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "gen"))
    (propagated-inputs
     (list ocaml-seq))
    (native-inputs
     (list ocaml-qtest ocaml-qcheck))
    (home-page "https://github.com/c-cube/gen/")
    (synopsis "Iterators for OCaml, both restartable and consumable")
    (description "Gen implements iterators of OCaml, that are both restartable
and consumable.")
    (license license:bsd-2)))

(define-public ocaml-sedlex
  (package
    (name "ocaml-sedlex")
    (version "3.7")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/ocaml-community/sedlex")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "02qjpblb0w1wiy9ilc6y56pm46m07ksxc7v5h1lcbsfj9hkapjmr"))))
    (build-system dune-build-system)
    (arguments
     (list #:package "sedlex"
           #:phases
           #~(modify-phases %standard-phases
               (add-before 'build 'copy-resources
                 ;; These three files are needed by src/generator/data/dune,
                 ;; but would be downloaded using curl at build time.
                 (lambda* (#:key inputs #:allow-other-keys)
                   (with-directory-excursion "src/generator/data"
                     ;; Newer versions of dune emit an error if files it wants to
                     ;; build already exist. Delete the dune file so dune doesn't
                     ;; complain.
                     (delete-file "dune")
                     (for-each
                      (lambda (file)
                        (copy-file (search-input-file inputs file)
                                   (basename file)))
                      '("share/ucd/extracted/DerivedGeneralCategory.txt"
                        "share/ucd/DerivedCoreProperties.txt"
                        "share/ucd/PropList.txt")))))
               (add-before 'build 'chmod
                 (lambda _
                   (for-each (lambda (file) (chmod file #o644)) (find-files "." ".*")))))))
    (native-inputs (list ocaml-ppx-expect))
    (propagated-inputs
     (list ocaml-gen ocaml-ppxlib ocaml-uchar))
    (inputs
     (list ucd))
    (home-page "https://www.cduce.org/download.html#side")
    (synopsis "Lexer generator for Unicode and OCaml")
    (description "Lexer generator for Unicode and OCaml.")
    (license license:expat)))

(define-public ocaml-sedlex-2
  (package
    (inherit ocaml-sedlex)
    (name "ocaml-sedlex")
    (version "2.6")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/ocaml-community/sedlex")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1z8mmk1idh9hjhh2b9rp5b1h8kmzcxhagqkw0pvxn6ykx1brskq1"))))
    (arguments
     (substitute-keyword-arguments (package-arguments ocaml-sedlex)
       ((#:tests? _ #t) #f)))               ; no tests
    (native-inputs '())))

(define-public ocaml-uchar
  (package
    (name "ocaml-uchar")
    (version "0.0.2")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/ocaml/uchar/releases/download/v"
                            version "/uchar-" version ".tbz"))
        (sha256 (base32
                  "1w2saw7zanf9m9ffvz2lvcxvlm118pws2x1wym526xmydhqpyfa7"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:tests? #f
       #:build-flags (list "native=true" "native-dynlink=true")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             ;; For OCaml >= 4.03, uchar is built-in, just install stub META
             (let ((lib (string-append (assoc-ref outputs "out")
                                       "/lib/ocaml/site-lib/uchar")))
               (mkdir-p lib)
               (copy-file "pkg/META.empty" (string-append lib "/META"))))))))
    (native-inputs
     (list ocamlbuild))
    (home-page "https://github.com/ocaml/uchar")
    (synopsis "Compatibility library for OCaml's Uchar module")
    (description "The uchar package provides a compatibility library for the
`Uchar` module introduced in OCaml 4.03.")
    (license license:lgpl2.1)))

(define-public ocaml-uutf
  (package
    (name "ocaml-uutf")
    (version "1.0.4")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://erratique.ch/software/uutf/releases/"
                                  "uutf-" version ".tbz"))
              (sha256
                (base32
                  "1a4wc6209gqblgksrjf6d5x96rc5kisv9qqq9s4shjcimzk7i9d7"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:tests? #f
       #:build-flags (list "build")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             ;; Use ocamlfind install to avoid circular dependency on opam-installer
             (let ((lib (string-append (assoc-ref outputs "out")
                                       "/lib/ocaml/site-lib")))
               (mkdir-p lib)
               (with-directory-excursion "_build"
                 (invoke "ocamlfind" "install" "uutf"
                         "../pkg/META"
                         "src/uutf.a"
                         "src/uutf.cma"
                         "src/uutf.cmxa"
                         "src/uutf.cmxs"
                         "src/uutf.cmx"
                         "src/uutf.cmi"
                         "src/uutf.mli"))))))))
    (native-inputs
     (list ocamlbuild ocaml-topkg))
    (propagated-inputs
     (list ocaml-uchar ocaml-cmdliner))  ; uchar needed for old topkg packages' build scripts
    (home-page "https://erratique.ch/software/uutf")
    (synopsis "Non-blocking streaming Unicode codec for OCaml")
    (description "Uutf is a non-blocking streaming codec to decode and encode
the UTF-8, UTF-16, UTF-16LE and UTF-16BE encoding schemes.  It can efficiently
work character by character without blocking on IO.  Decoders perform character
position tracking and support newline normalization.

Functions are also provided to fold over the characters of UTF encoded OCaml
string values and to directly encode characters in OCaml Buffer.t values.")
    (license license:isc)))

(define-public ocaml-uunf
  (package
    (name "ocaml-uunf")
    (version "15.0.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://erratique.ch/software/uunf/releases/uunf-"
                           version".tbz"))
       (sha256
        (base32
         "1s5svvdqfbzw16rf1h0zm9n92xfdr0qciprd7lcjza8z1hy6pyh7"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:build-flags (list "build" "--tests" "true")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         ;; reported and fixed upstream, will be available in next version.
         (add-before 'build 'fix-test
           (lambda _
             (substitute* "test/test.ml"
               (("test/NormalizationTest.txt") "-"))))
         (add-before 'check 'check-data
           (lambda* (#:key inputs #:allow-other-keys)
             (copy-file (assoc-ref inputs "NormalizationTest.txt")
                        "test/NormalizationTest.txt")
             #t)))))
    (native-inputs
     `(("ocamlbuild" ,ocamlbuild)
       ("opam-installer" ,opam-installer)
       ("topkg" ,ocaml-topkg)
       ;; Test data is otherwise downloaded with curl
       ("NormalizationTest.txt"
        ,(origin
           (method url-fetch)
           (uri (string-append "https://www.unicode.org/Public/"
                               version
                               "/ucd/NormalizationTest.txt"))
           (file-name (string-append "NormalizationTest-" version ".txt"))
           (sha256
              (base32 "09pkawfqpgy2xnv2nkkgmxv53rx4anprg65crbbcm02a2p6ci6pv"))))))
    (propagated-inputs (list ocaml-uutf))
    (home-page "https://erratique.ch/software/uunf")
    (synopsis "Unicode text normalization for OCaml")
    (description
     "Uunf is an OCaml library for normalizing Unicode text.  It supports all
Unicode normalization forms.  The library is independent from any
IO mechanism or Unicode text data structure and it can process text
without a complete in-memory representation.")
    (license license:isc)))

(define-public ocaml-jsonm
  (package
    (name "ocaml-jsonm")
    (version "1.0.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://erratique.ch/software/jsonm/releases/"
                                  "jsonm-" version ".tbz"))
              (sha256
                (base32
                  "1176dcmxb11fnw49b7yysvkjh0kpzx4s48lmdn5psq9vshp5c29w"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:tests? #f
       #:build-flags (list "build")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             ;; Use ocamlfind install to avoid circular dependency on opam-installer
             (let ((lib (string-append (assoc-ref outputs "out")
                                       "/lib/ocaml/site-lib")))
               (mkdir-p lib)
               (with-directory-excursion "_build"
                 (invoke "ocamlfind" "install" "jsonm"
                         "../pkg/META"
                         "src/jsonm.a"
                         "src/jsonm.cma"
                         "src/jsonm.cmxa"
                         "src/jsonm.cmxs"
                         "src/jsonm.cmx"
                         "src/jsonm.cmi"
                         "src/jsonm.mli"))))))))
    (native-inputs
     (list ocamlbuild ocaml-topkg))
    (propagated-inputs
     `(("uutf" ,ocaml-uutf)
       ("cmdliner" ,ocaml-cmdliner)))
    (home-page "https://erratique.ch/software/jsonm")
    (synopsis "Non-blocking streaming JSON codec for OCaml")
    (description "Jsonm is a non-blocking streaming codec to decode and encode
the JSON data format.  It can process JSON text without blocking on IO and
without a complete in-memory representation of the data.")
    (license license:isc)))

(define-public ocaml-ocp-indent
  (package
    (name "ocaml-ocp-indent")
    (version "1.9.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/OCamlPro/ocp-indent")
               (commit version)))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "1zrf8sbh7m828bkj299kb0k3qknhafj7gnpiclc67qrwqxkmnmzg"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-cmdliner))
    (home-page "https://www.typerex.org/ocp-indent.html")
    (synopsis "Tool to indent OCaml programs")
    (description
      "Ocp-indent is based on an approximate, tolerant OCaml parser
and a simple stack machine.  Presets and configuration options are available,
with the possibility to set them project-wide.  It supports the most common
syntax extensions, and it is extensible for others.

This package includes:

@itemize
@item An indentor program, callable from the command-line or from within editors,
@item Bindings for popular editors,
@item A library that can be directly used by editor writers, or just for
      fault-tolerant and approximate parsing.
@end itemize")
    (license license:lgpl2.1)))

(define-public ocaml-ocp-index
  (package
    (name "ocaml-ocp-index")
    (version "1.3.4")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/OCamlPro/ocp-index")
               (commit version)))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "031b3s8ppqkpw1n6h87h6jzjkmny6yig9wfimmgwnljafcc83d3b"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "ocp-index"))
    (propagated-inputs
     (list ocaml-ocp-indent ocaml-re ocaml-cmdliner))
    (native-inputs
     (list ocaml-cppo))
    (home-page "https://www.typerex.org/ocp-index.html")
    (synopsis "Lightweight completion and documentation browsing for OCaml libraries")
    (description "This package includes only the @code{ocp-index} library
and command-line tool.")
    ;; All files in libs/ are GNU lgpl2.1
    ;; For static linking, clause 6 of LGPL is lifted
    ;; All other files under GNU gpl3
    (license (list license:gpl3+
                   license:lgpl2.1+))))

(define-public ocaml-domain-name
  (package
    (name "ocaml-domain-name")
    (version "0.4.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/hannesm/domain-name/")
                    (commit (string-append "v" version))))
              (file-name name)
              (sha256
               (base32
                "1a669zz1pc7sqbi1c13jsnp8algcph2b8gr5fjrjhyh3p232770k"))))
    (build-system dune-build-system)
    (native-inputs (list ocaml-alcotest))
    (home-page "https://github.com/hannesm/domain-name")
    (synopsis "RFC 1035 Internet domain name data structure and parser")
    (description
     "Parses and constructs RFC compliant domain names.  The invariants on the
length of domain names are preserved throughout the module.")
    (license license:isc)))

(define-public ocaml-macaddr
  (package
    (name "ocaml-macaddr")
    (version "5.6.1")
    (source (origin
              (method url-fetch)
              (uri
               "https://github.com/mirage/ocaml-ipaddr/releases/download/v5.6.1/ipaddr-5.6.1.tbz")
              (sha256
               (base32
                "06d32jp2a2ym49bg4736g2snqhi7glk7bgp94g446n6lmgw7sq8y"))))
    (build-system dune-build-system)
    (arguments '(#:package "macaddr"))
    (propagated-inputs (list ocaml-cstruct ocaml-domain-name))
    (native-inputs (list ocaml-ounit2 ocaml-ppx-sexp-conv))
    (home-page "https://github.com/mirage/ocaml-ipaddr")
    (synopsis "OCaml library for manipulation of MAC address representations")
    (description
     "Features:
@itemize
@item MAC-48 (Ethernet) address support
@item @code{Macaddr} is a @code{Map.OrderedType}
@item All types have sexplib serializers/deserializers optionally via the
@code{Macaddr_sexp} library
@end itemize")
    (license license:isc)))

(define-public ocaml-macaddr-cstruct
  (package
    (inherit ocaml-macaddr)
    (name "ocaml-macaddr-cstruct")
    (arguments '(#:package "macaddr-cstruct"))
    (propagated-inputs (list ocaml-macaddr ocaml-cstruct))
    (synopsis "OCaml library for MAC addresses with Cstruct support")
    (description
     "This package provides Cstruct serialization for MAC addresses.")))

(define-public ocaml-ipaddr
  ;; same repo and versions as ocaml-macaddr
  (package
    (inherit ocaml-macaddr)
    (name "ocaml-ipaddr")
    (arguments '(#:package "ipaddr"))
    (propagated-inputs (list ocaml-macaddr ocaml-domain-name))
    (synopsis
     "Library for manipulation of IP (and MAC) address representations")
    (description
     "IP address types with serialization, supporting a wide range of RFCs.")
    (license license:isc)))

(define-public ocaml-emile
  (package
    (name "ocaml-emile")
    (version "1.1")
    (source (origin
              (method url-fetch)
              (uri
               "https://github.com/mirage/emile/releases/download/v1.1/emile-v1.1.tbz")
              (sha256
               (base32
                "0r1141makr0b900aby1gn0fccjv1qcqgyxib3bzq8fxmjqwjan8p"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-angstrom
                             ocaml-ipaddr
                             ocaml-base64
                             ocaml-pecu
                             ocaml-bigstringaf
                             ocaml-uutf))
    (native-inputs (list ocaml-alcotest))
    (home-page "https://github.com/mirage/emile")
    (synopsis "Parser of email address according RFC822")
    (description
     "This package provides a parser of email address according RFC822, RFC2822,
RFC5321 and RFC6532.  It handles UTF-8 email addresses and encoded-word
according RFC2047.")
    (license license:expat)))

(define-public ocaml-parse-argv
  (package
    (name "ocaml-parse-argv")
    (version "0.2.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mirage/parse-argv")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "16n18zik6vkfnhv8jaigr90fwp1ykg23p61aqchym0jil4i4yq01"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-astring))
    (native-inputs (list ocaml-ounit))
    (home-page "https://github.com/mirage/parse-argv")
    (synopsis "Process strings into sets of command-line arguments")
    (description "Small implementation of a simple argv parser.")
    (license license:isc)))

(define-public ocaml-functoria-runtime
  (package
    (name "ocaml-functoria-runtime")
    (version "4.3.3")
    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/mirage/mirage/")
         (commit (string-append "v" version))))
       (file-name (git-file-name "mirage" version))
       (sha256
        (base32
         "09mqbffrhnklbc50gaflkwb3h1xysqqiwb84a9q1phjl038pic6r"))))
    (build-system dune-build-system)
    (arguments
     '(#:package "functoria-runtime"
       ;; TODO
       ;; again, requires opam for tests, which needs network access.
       ;; most other tests seem to pass.
       #:tests? #f))
    (propagated-inputs
     (list ocaml-cmdliner ocaml-fmt ocaml-logs ocaml-bos ocaml-ipaddr
           ocaml-emile ocaml-uri))
    (native-inputs
     (list ocaml-alcotest))
    (home-page "https://github.com/mirage/mirage")
    (synopsis "Runtime support library for functoria-generated code")
    (description
     "This is the runtime support library for code generated by functoria.")
    (license license:isc)))

(define-public ocaml-mirage-runtime
  (package
    (inherit ocaml-functoria-runtime)
    (name "ocaml-mirage-runtime")
    (build-system dune-build-system)
    (arguments
     '(#:package "mirage-runtime"
       ;; TODO again, wants opam, other tests seem to pass
       ;; look for a way to disable tests that want network access
       #:tests? #f))
    (propagated-inputs (list ocaml-ipaddr ocaml-functoria-runtime ocaml-fmt
                             ocaml-logs ocaml-lwt))
    (native-inputs (list ocaml-alcotest))
    (home-page "https://github.com/mirage/mirage")
    (synopsis
     "The base MirageOS runtime library, part of every MirageOS unikernel")
    (description
     "This package provides a bundle of useful runtime functions for
applications built with MirageOS")
    (license license:isc)))

(define-public ocaml-functoria
  (package
    (inherit ocaml-functoria-runtime)
    (name "ocaml-functoria")
    (build-system dune-build-system)
    (arguments
     '(#:package "functoria"
       ;; TODO again, wants opam, other tests seem to pass
       ;; look for a way to disable tests that want network access
       #:tests? #f))
    (propagated-inputs (list ocaml-cmdliner ocaml-rresult
                             ocaml-astring ocaml-fmt ocaml-logs ocaml-bos
                             ocaml-fpath ocaml-emile ocaml-uri))
    (native-inputs (list ocaml-alcotest ocaml-functoria-runtime))
    (home-page "https://github.com/mirage/mirage")
    (synopsis
     "DSL to organize functor applications")
    (description
     "DSL to describe a set of modules and functors, their types and
how to apply them in order to produce a complete application.  The main use
case is mirage.")
    (license license:isc)))

(define-public ocaml-mirage
  (package
    (inherit ocaml-functoria-runtime)
    (name "ocaml-mirage")
    (build-system dune-build-system)
    (arguments
     '(#:package "mirage"
       ;; TODO again, wants opam, other tests seem to pass
       ;; look for a way to disable tests that want network access
       #:tests? #f))
    (propagated-inputs
     (list ocaml-astring ocaml-bos ocaml-functoria ocaml-ipaddr ocaml-logs
           ocaml-mirage-runtime ocaml-opam-monorepo))
    (native-inputs (list ocaml-alcotest ocaml-fmt))
    (home-page "https://github.com/mirage/mirage")
    (synopsis
     "The MirageOS library operating system")
    (description
     "Library operating system that constructs unikernels for secure,
high-performance network applications across a variety of cloud computing and
mobile platforms.  Code can be developed on a normal OS and then compiled into
a fully-standalone, specialised unikernel.")
    (license license:isc)))

(define-public ocaml-mirage-bootvar-unix
  (package
    (name "ocaml-mirage-bootvar-unix")
    (version "0.1.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mirage/mirage-bootvar-unix")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1vi13q0z5ffv5hf4q5lfvkia6j2s5520px0s2x4dbjgd52icizrz"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-lwt ocaml-parse-argv))
    (home-page "https://github.com/mirage/mirage-bootvar-unix")
    (synopsis "Unix implementation of MirageOS Bootvar interface")
    (description "Library for passing boot parameters from Solo5 to MirageOS.")
    (license license:isc)))

(define-public ocaml-duration
  (package
    (name "ocaml-duration")
    (version "0.2.1")
    (source (origin
              (method git-fetch)
              (uri
               (git-reference
                (url "https://github.com/hannesm/duration/")
                (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0vvxi0ipxmdz1k4h501brvccniwf3wpc32djbccyyrzraiz7qkff"))))
    (build-system dune-build-system)
    (native-inputs (list ocaml-alcotest))
    (home-page "https://github.com/hannesm/duration")
    (synopsis "Conversions to various time units")
    (description
     "This package provides a duration is represented in nanoseconds as an
unsigned 64 bit integer.  This has a range of up to 584 years.  Functions
provided check the input and raise on negative or out of bound input.")
    (license license:isc)))

(define-public ocaml-mirage-time
  (package
    (name "ocaml-mirage-time")
    (version "3.0.0")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/mirage/mirage-time/releases/download/v"
                    version "/mirage-time-v3.0.0.tbz"))
              (sha256
               (base32
                "0z5xkhlgyhm22wyhwpf9r0rn4125cc3cxj6ccavyiiz2b2dr8h0d"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-lwt ocaml-duration))
    (home-page "https://github.com/mirage/mirage-time")
    (synopsis "Time operations for MirageOS")
    (description
     "Defines the signature for time-related operations for MirageOS.")
    (license license:isc)))

(define-public ocaml-mirage-clock
  (package
    (name "ocaml-mirage-clock")
    (version "4.2.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mirage/mirage-clock")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0rkara9i3dvnzrb8jl2vkx8hgamvxnksin67wmhbv9d4i758amjy"))))
    (build-system dune-build-system)
    (home-page "https://github.com/mirage/mirage-clock")
    (synopsis "Libraries and module types for portable clocks")
    (description
     "This library implements portable support for an operating system
timesource that is compatible with the MirageOS library interfaces.  It
implements an @code{MCLOCK} module that represents a monotonic timesource
since an arbitrary point, and @code{PCLOCK} which counts time since the Unix
epoch.")
    (license license:isc)))

(define-public ocaml-ptime
  (package
    (name "ocaml-ptime")
    (version "1.2.0")
    (source (origin
              (method url-fetch)
              (uri
               "https://erratique.ch/software/ptime/releases/ptime-1.2.0.tbz")
              (sha256
               (base32
                "1c1swx6h794gcck358nqfzshlfhyw1zb5ji4h1pc63j9vxzp85ln"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:build-flags (list "build")
       #:tests? #f  ; tests not built
       #:phases (modify-phases %standard-phases
                  (delete 'configure))))
    ;; (propagated-inputs (list js-of-ocaml))
    (native-inputs (list ocaml-findlib ocamlbuild ocaml-topkg opam-installer))
    (home-page "https://erratique.ch/software/ptime")
    (synopsis "POSIX time for OCaml")
    (description
     "Ptime offers platform independent POSIX time support in pure OCaml.  It
provides a type to represent a well-defined range of POSIX timestamps with
picosecond precision, conversion with date-time values, conversion with RFC
3339 timestamps and pretty printing to a human-readable, locale-independent
representation.")
    (license license:isc)))

(define-public ocaml-mirage-unix
  (package
    (name "ocaml-mirage-unix")
    (version "5.0.1")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/mirage/mirage-unix/releases/download/v"
                    version "/mirage-unix-5.0.1.tbz"))
              (sha256
               (base32
                "1y44hvsd5lxqbazwkv9n6cn936lpn8l7v82wf55w4183fp70nnjk"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-lwt ocaml-duration ocaml-mirage-runtime))
    (home-page "https://github.com/mirage/mirage-unix")
    (synopsis "Unix core platform libraries for MirageOS")
    (description
     "This package provides the MirageOS `OS` library for Unix targets, which
handles the main loop and timers.")
    (license license:isc)))

(define-public ocaml-mirage-profile-unix
  (package
    (name "ocaml-mirage-profile-unix")
    (version "0.9.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mirage/mirage-profile/")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "11p3ai8g993algds9mbg4xf3is0agqah127r69fb7rm35dryzq95"))))
    (build-system dune-build-system)
    (arguments
     '(#:package "mirage-profile-unix"
       #:tests? #f ;depends on ocaml-mirage-profile which would form a loop
       #:phases (modify-phases %standard-phases
                  ;; TODO is there a way to do this with dune build flags?
                  (add-after 'unpack 'disable-xen
                    (lambda _
                      ;; this way it is not detected as a build target
                      (rename-file "xen" "_xen"))))))
    (propagated-inputs (list ocaml-cstruct ocaml-ocplib-endian ocaml-lwt
                             ocaml-mtime ocaml-ppx-cstruct))
    (native-inputs (list ocaml-ppx-cstruct))
    (home-page "https://github.com/mirage/mirage-profile")
    (synopsis "Collects Ocaml/Lwt profiling information in CTF format")
    (description
     "Used to trace execution of OCaml/Lwt programs (such as Mirage
unikernels) at the level of Lwt threads.  The traces can be viewed using
JavaScript or GTK viewers provided by mirage-trace-viewer or processed by
tools supporting the Common Trace Format.
When compiled against a normal version of Lwt, OCaml's cross-module inlining
will optimise these calls away, meaning there should be no overhead in the
non-profiling case.")
    (license license:bsd-2)))

(define-public ocaml-mirage-profile
  (package
    (inherit ocaml-mirage-profile-unix)
    (name "ocaml-mirage-profile")
    (arguments
     '(#:package "mirage-profile"
       ;; TODO cyclic dependency with mirage-profile
       ;; It could be broken using package variants, if not for
       ;; propagated inputs leading to version conflicts.
       #:tests? #f))
    (propagated-inputs (modify-inputs (package-propagated-inputs
                                       ocaml-mirage-profile-unix)
                         (append ocaml-mirage-profile-unix)))))

(define-public ocaml-mirage-logs
  (package
    (name "ocaml-mirage-logs")
    (version "1.2.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mirage/mirage-logs/")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1wv2hz1dj38jzc8nabin9p8im43ghy8f3crv7rf9szyyzyrdanp2"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-logs ocaml-ptime ocaml-mirage-clock
                             ocaml-mirage-profile ocaml-lwt))
    (native-inputs (list ocaml-alcotest))
    (home-page "https://github.com/mirage/mirage-logs")
    (synopsis
     "Reporter for the Logs library that writes to stderr with timestamps")
    (description
     "Uses a Mirage @code{CLOCK} to write timestamped log messages.  It can
also log only important messages to the console, while writing all received
messages to a ring buffer which is displayed if an exception occurs.  If
tracing is enabled (via mirage-profile), it also writes each log message to
the trace buffer.")
    (license license:isc)))

(define-public ocaml-curl
  (package
    (name "ocaml-curl")
    (version "0.10.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/ygrek/ocurl/releases/download/0.10.0/curl-0.10.0.tbz")
       (sha256
        (base32 "0519l7vxrk0z05j0068rr5j1bhnbgc7yk6ldflm2k53zv9gj2kn1"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "curl"))
    (native-inputs (list pkg-config))
    (inputs (list curl))
    (properties `((upstream-name . "curl")))
    (home-page "https://github.com/ygrek/ocurl")
    (synopsis "OCaml bindings for libcurl")
    (description "Client-side URL transfer library, supporting HTTP and a
multitude of other network protocols (FTP/SMTP/RTSP/etc).")
    (license license:expat)))

(define-public ocaml-curl-lwt
  (package
    (inherit ocaml-curl)
    (name "ocaml-curl-lwt")
    (arguments
     `(#:package "curl_lwt"))
    (propagated-inputs (list ocaml-curl ocaml-lwt))
    (synopsis "OCaml bindings for libcurl with Lwt support")
    (description "Lwt-enabled bindings for libcurl, providing asynchronous
URL transfers.")))

(define-public ocaml-ocurl
  (package
    (name "ocaml-ocurl")
    (version "transition")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/ygrek/ocurl/releases/download/0.10.0/curl-0.10.0.tbz")
       (sha256
        (base32 "0519l7vxrk0z05j0068rr5j1bhnbgc7yk6ldflm2k53zv9gj2kn1"))))
    (build-system ocaml-build-system)
    (propagated-inputs (list ocaml-curl ocaml-curl-lwt))
    (home-page "https://ygrek.org/p/ocurl")
    (synopsis
     "This is a transition package, ocurl is now named curl. Use the curl package instead")
    (description
     "This is a transition package, ocurl is now named curl.  Use the curl package
instead.")
    (license license:expat)))

(define-public ocaml-base64
  (package
    (name "ocaml-base64")
    (version "3.5.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/mirage/ocaml-base64")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1jq349jp663hq51a941afr2y4yyh34r19zsxla73ks9bywj4mm2q"))))
    (build-system dune-build-system)
    (native-inputs (list ocaml-alcotest ocaml-bos ocaml-rresult))
    (home-page "https://github.com/mirage/ocaml-base64")
    (synopsis "Base64 encoding for OCaml")
    (description "Base64 is a group of similar binary-to-text encoding schemes
that represent binary data in an ASCII string format by translating it into a
radix-64 representation.  It is specified in RFC 4648.")
    (license license:isc)))

;; A variant without tests that is used to prevent a cyclic dependency when
;; compiling ocaml-dose3.
(define ocaml-base64-boot
  (package
    (inherit ocaml-base64)
    (arguments `(#:tests? #f))
    (native-inputs '())))

(define-public ocamlify
  (package
    (name "ocamlify")
    (version "0.0.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://download.ocamlcore.org/ocamlify/ocamlify/"
                           version "/ocamlify-" version ".tar.gz"))
       (sha256
        (base32 "1f0fghvlbfryf5h3j4as7vcqrgfjb4c8abl5y0y5h069vs4kp5ii"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:tests? #f; no tests
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'build
           ;; This package uses pre-generated setup.ml by oasis, but is
           ;; a dependency of oasis.  the pre-generated setup.ml is broken
           ;; with recent versions of OCaml, so we perform a bootstrap instead.
           (lambda _
             (substitute* "src/OCamlifyConfig.ml.ab"
               (("$pkg_version") ,version))
             (rename-file "src/OCamlifyConfig.ml.ab" "src/OCamlifyConfig.ml")
             (with-directory-excursion "src"
               (invoke "ocamlc" "OCamlifyConfig.ml" "ocamlify.ml" "-o"
                       "ocamlify"))
             #t))
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((bin (string-append (assoc-ref outputs "out") "/bin")))
               (mkdir-p bin)
               (install-file "src/ocamlify" bin)
               #t))))))
    (home-page "https://forge.ocamlcore.org/projects/ocamlify")
    (synopsis "Include files in OCaml code")
    (description "OCamlify creates OCaml source code by including
whole files into OCaml string or string list.  The code generated can be
compiled as a standard OCaml file.  It allows embedding external resources as
OCaml code.")
    (license license:lgpl2.1+))); with the OCaml static compilation exception

(define-public omake
  (package
    (name "omake")
    (version "0.10.5")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://download.camlcity.org/download/"
                                  "omake-" version ".tar.gz"))
              (sha256
               (base32
                "1i7pcv53kqplrbdx9mllrhbv4j57zf87xwq18r16cvn1lbc6mqal"))
              (patches (search-patches "omake-fix-non-determinism.patch"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:make-flags
       ,#~(list (string-append "PREFIX=" #$output))
       #:tests? #f ; no test target
       #:phases
       (modify-phases %standard-phases
         (add-before 'configure 'fix-makefile
                     (lambda* (#:key outputs #:allow-other-keys)
                       (substitute* "mk/osconfig_unix.mk"
                                    (("CC = cc") "CC = gcc")))))))
    (native-inputs (list hevea))
    (home-page "http://projects.camlcity.org/projects/omake.html")
    (synopsis "Build system designed for scalability and portability")
    (description "Similar to make utilities you may have used, but it features
many additional enhancements, including:

@enumerate
@item Support for projects spanning several directories or directory hierarchies.
@item Fast, reliable, automated, scriptable dependency analysis using MD5 digests,
      with full support for incremental builds.
@item Dependency analysis takes the command lines into account — whenever the
      command line used to build a target changes, the target is considered
      out-of-date.
@item Fully scriptable, includes a library that providing support for standard
      tasks in C, C++, OCaml, and LaTeX projects, or a mixture thereof.
@end enumerate")
    (license (list license:lgpl2.1 ; libmojave
                   license:expat ; OMake scripts
                   license:gpl2)))) ; OMake itself, with ocaml linking exception
                                    ; see LICENSE.OMake

(define-public ocaml-benchmark
  (package
    (name "ocaml-benchmark")
    (version "1.6")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/Chris00/ocaml-benchmark")
               (commit version)))
        (file-name (git-file-name name version))
        (sha256
         (base32 "0d0vdfjgjzf1y6wkd714d8b0piv1z9qav5ahsapynqzk4b4ahhnp"))))
    (build-system dune-build-system)
    (home-page "https://github.com/Chris00/ocaml-benchmark")
    (synopsis "Benchmark running times of code")
    (description
      "This module provides a set of tools to measure the running times of
your functions and to easily compare the results.  A statistical test
is used to determine whether the results truly differ.")
    (license license:lgpl3+)))

(define-public ocaml-bechamel
  (package
    (name "ocaml-bechamel")
    (version "0.3.0")
    (home-page "https://github.com/mirage/bechamel")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url home-page)
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "1x7sf45iy5dzx7kknbkkvpna42rcwpj5p55y0nqsg2fb4srj0b1q"))))
    (build-system dune-build-system)
    (arguments `(#:package "bechamel"))
    (propagated-inputs (list ocaml-fmt ocaml-stdlib-shims))
    (synopsis "Yet Another Benchmark in OCaml")
    (description
     "BEnchmark for a CHAMEL/camel/caml which is agnostic to the system.  It's a
micro-benchmark tool for OCaml which lets the user to re-analyzes and prints
samples.")
    (license license:expat)))

(define-public ocaml-batteries
  (package
    (name "ocaml-batteries")
    (version "3.5.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ocaml-batteries-team/batteries-included")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "07387jp93civ9p1q2ixmq8qkzzyssp94ssxd4w2ndvkg1nr6kfcl"))))
    (build-system ocaml-build-system)
    (propagated-inputs (list ocaml-num))
    (native-inputs
     (list ocamlbuild ocaml-benchmark ocaml-qcheck ocaml-qtest))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'make-writable
           (lambda _
             (for-each make-file-writable (find-files "." "."))))
         (add-before 'build 'fix-nondeterminism
           (lambda _
             (substitute* "setup.ml"
               (("Sys.readdir dirname")
                "let a = Sys.readdir dirname in Array.sort String.compare a; a"))
             #t)))))
    (home-page "http://batteries.forge.ocamlcore.org/")
    (synopsis "Development platform for the OCaml programming language")
    (description "Define a standard set of libraries which may be expected on
every compliant installation of OCaml and organize these libraries into a
hierarchy of modules.")
    (license license:lgpl2.1+)))

(define-public ocaml-pcre
  (package
    (name "ocaml-pcre")
    (version "7.5.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/mmottl/pcre-ocaml")
              (commit version)))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "048k1rl17fcml000yh8fnghk1a06h14lbyrnk9nbigxsymrz6cq2"))))
    (build-system dune-build-system)
    (arguments
     ;; No tests.
     '(#:tests? #f))
    (propagated-inputs
     (list dune-configurator pcre))
    (native-inputs
     `(("pcre:bin" ,pcre "bin")))
    (home-page "https://mmottl.github.io/pcre-ocaml")
    (synopsis
      "Bindings to the Perl Compatibility Regular Expressions library")
    (description "Pcre-ocaml offers library functions for string
pattern matching and substitution, similar to the functionality
offered by the Perl language.")
    ;; With static linking exception
    (license license:lgpl2.1+)))

(define-public ocaml-pcre2
  (package
    (name "ocaml-pcre2")
    (version "8.0.3")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/camlp5/pcre2-ocaml/archive/refs/tags/8.0.3.tar.gz")
       (sha256
        (base32 "0hkvv2wznq3a6npbxxcg02ng14hj2kabscm8qfdy1s883bwc4jdb"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-dune-configurator))
    (native-inputs (list pcre2 ocaml-ounit2))
    (home-page "https://github.com/camlp5/pcre2-ocaml")
    (synopsis
     "Bindings to the Perl Compatibility Regular Expressions library (version 2)")
    (description
     "pcre2-ocaml offers library functions for string pattern matching and
substitution, similar to the functionality offered by the Perl language.")
    (license #f)))

(define-public ocaml-expect
  (package
    (name "ocaml-expect")
    (version "0.0.6")
    (source (origin
              (method url-fetch)
              (uri (ocaml-forge-uri name version 1736))
              (sha256
               (base32
                "098qvg9d4yrqzr5ax291y3whrpax0m3sx4gi6is0mblc96r9yqk0"))))
    (arguments
     `(#:tests? #f))
    (build-system ocaml-build-system)
    (native-inputs
     `(("ocamlbuild" ,ocamlbuild)
       ("ocaml-num" ,ocaml-num)
       ("ocaml-pcre" ,ocaml-pcre)
       ("ounit" ,ocaml-ounit)))
    (propagated-inputs
     `(("batteries" ,ocaml-batteries)))
    (home-page "https://forge.ocamlcore.org/projects/ocaml-expect/")
    (synopsis "Simple implementation of expect")
    (description "This package provides utilities for building unitary testing
of interactive program.  You can match the question using a regular expression
or a timeout.")
    (license license:lgpl2.1+))) ; with the OCaml static compilation exception

(define-public ocaml-stdcompat
  (package
    (name "ocaml-stdcompat")
    (version "19")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/thierry-martinez/stdcompat")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (modules '((guix build utils)))
       (snippet
        #~(for-each delete-file '("Makefile.in" "configure")))
       (sha256
        (base32
         "0r9qcfjkn8634lzxp5bkagzwsi3vmg0hb6vq4g1p1515rys00h1b"))))
    (build-system dune-build-system)
    (arguments
     (list #:imported-modules `((guix build gnu-build-system)
                                ,@%dune-build-system-modules)
           #:modules '((guix build dune-build-system)
                       ((guix build gnu-build-system) #:prefix gnu:)
                       (guix build utils))
           #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'bootstrap
                 (assoc-ref gnu:%standard-phases 'bootstrap))
               (add-before 'build 'prepare-build
                 (lambda _
                   (let ((bash (which "bash")))
                     (setenv "CONFIG_SHELL" bash)
                     (setenv "SHELL" bash)))))))
    (native-inputs
      (list autoconf
            automake
            ocaml
            ocaml-findlib))
    (home-page "https://github.com/thierry-martinez/stdcompat")
    (synopsis "Compatibility module for OCaml standard library")
    (description
     "Compatibility module for OCaml standard library allowing programs to use
some recent additions to the standard library while preserving the ability to
be compiled on former versions of OCaml.")
    (license license:bsd-2)))

(define-public ocaml-stdlib-shims
  (package
    (name "ocaml-stdlib-shims")
    (version "0.3.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ocaml/stdlib-shims")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0gmg8w67j3ww17llk7hl4dx0vq7p50rn5s4ib9sy984k543rz59h"))))
    (build-system dune-build-system)
    (home-page "https://github.com/ocaml/stdlib-shims")
    (synopsis "OCaml stdlib features backport to older OCaml compilers")
    (description "This package backports some of the new stdlib features to
older compilers, such as the Stdlib module.  This allows projects that require
compatibility with older compiler to use these new features in their code.")
    ;; with ocaml-linking exception
    (license license:lgpl2.1+)))

(define-public ocaml-fileutils
  (package
    (name "ocaml-fileutils")
    (version "0.6.6")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/gildor478/ocaml-fileutils")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "12x658yn6f14vy13sh4d9g0wwdz0xwkhrrg97225q8pv2dlbp4yd"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-stdlib-shims))
    (native-inputs
     (list ocaml-ounit))
    (home-page "http://ocaml-fileutils.forge.ocamlcore.org")
    (synopsis "Pure OCaml functions to manipulate real file and filename")
    (description "Library to provide pure OCaml functions to manipulate real
file (POSIX like) and filename.")
    (license license:lgpl2.1+))) ; with the OCaml static compilation exception

(define-public ocaml-oasis
  (package
    (name "ocaml-oasis")
    (version "0.4.11")
    (source (origin
              (method url-fetch)
              (uri (ocaml-forge-uri name version 1757))
              (sha256
               (base32
                "0bn13mzfa98dq3y0jwzzndl55mnywaxv693z6f1rlvpdykp3vdqq"))
            (modules '((guix build utils)))
            (snippet
             '(begin
                (substitute* "test/test-main/Test.ml"
                  ;; most of these tests fail because ld cannot find crti.o, but according
                  ;; to the log file, the environment variables {LD_,}LIBRARY_PATH
                  ;; are set correctly when LD_LIBRARY_PATH is defined beforehand.
                  (("TestBaseCompat.tests;") "")
                  (("TestExamples.tests;") "")
                  (("TestFull.tests;") "")
                  (("TestPluginDevFiles.tests;") "")
                  (("TestPluginInternal.tests;") "")
                  (("TestPluginOCamlbuild.tests;") "")
                  (("TestPluginOMake.tests;") ""))
                #t))))
    (build-system ocaml-build-system)
    (arguments
     `(#:tests? #f))
    (native-inputs
     (list ocamlbuild ocamlify ocamlmod))
    (home-page "https://oasis.forge.ocamlcore.org")
    (synopsis "Integrates a configure, build, install system in OCaml projects")
    (description "OASIS is a tool to integrate a configure, build and install
system in your OCaml projects.  It helps to create standard entry points in your
build system and allows external tools to analyse your project easily.")
    (license license:lgpl2.1+))) ; with ocaml static compilation exception

(define-public ocaml-cppo
  (package
    (name "ocaml-cppo")
    (version "1.6.9")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/mjambon/cppo")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256 (base32
                 "1c8jlr2s0allw1h6czz5q24vn5jsnrrh44j7hjyilzaifm17dlrm"))))
    (build-system dune-build-system)
    (arguments
     `(#:tests? #f))
    (native-inputs
     (list ocamlbuild))
    (home-page "https://github.com/mjambon/cppo")
    (synopsis "Equivalent of the C preprocessor for OCaml programs")
    (description "Cppo is an equivalent of the C preprocessor for OCaml
programs.  It allows the definition of simple macros and file inclusion.  Cppo is:
@enumerate
@item more OCaml-friendly than @command{cpp}
@item easy to learn without consulting a manual
@item reasonably fast
@item simple to install and to maintain.
@end enumerate")
    (license license:bsd-3)))

(define-public ocaml-seq
  (package
    (name "ocaml-seq")
    (version "0.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/c-cube/seq")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1cjpsc7q76yfgq9iyvswxgic4kfq2vcqdlmxjdjgd4lx87zvcwrv"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (delete 'build)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((install-dir (string-append (assoc-ref outputs "out")
                                               "/lib/ocaml/site-lib/seq")))
               (mkdir-p install-dir)
               (with-output-to-file (string-append install-dir "/META")
                 (lambda _
                   (display "name=\"seq\"
version=\"[distributed with ocaml]\"
description=\"dummy package for compatibility\"
requires=\"\"")))
               #t))))))
    (home-page "https://github.com/c-cube/seq")
    (synopsis "OCaml's standard iterator type")
    (description "This package is a compatibility package for OCaml's
standard iterator type starting from 4.07.")
    (license license:lgpl2.1+)))

(define-public ocaml-re
  (package
    (name "ocaml-re")
    (version "1.10.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ocaml/ocaml-re")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1g0vmpx6ylv8m0w77zarn215pgb4czc6gcpb2fi5da1s307zwr0w"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-seq))
    (native-inputs
     `(("ounit" ,ocaml-ounit)))
    (home-page "https://github.com/ocaml/ocaml-re/")
    (synopsis "Regular expression library for OCaml")
    (description "Pure OCaml regular expressions with:
@enumerate
@item Perl-style regular expressions (module Re_perl)
@item Posix extended regular expressions (module Re_posix)
@item Emacs-style regular expressions (module Re_emacs)
@item Shell-style file globbing (module Re_glob)
@item Compatibility layer for OCaml's built-in Str module (module Re_str)
@end enumerate")
    (license license:expat)))

(define-public ocaml-ocplib-endian
  (package
    (name "ocaml-ocplib-endian")
    (version "1.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/OCamlPro/ocplib-endian/")
                     (commit version)))
              (sha256
               (base32
                "1klj4g451s7m5r8bxmwc1rpvngpqdm40csnx9smgc06pwy2fax2c"))
              (file-name (git-file-name name version))))
    (build-system dune-build-system)
    (native-inputs
     `(("cppo" ,ocaml-cppo)))
    (home-page "https://github.com/OCamlPro/ocplib-endian")
    (synopsis "Optimised functions to read and write int16/32/64 from strings
and bigarrays")
    (description "Optimised functions to read and write int16/32/64 from strings
and bigarrays, based on new primitives added in version 4.01.  It works on
strings, bytes and bigstring (Bigarrys of chars), and provides submodules for
big- and little-endian, with their unsafe counter-parts.")
    (license license:lgpl2.1)))

(define-public ocaml-cstruct
  (package
    (name "ocaml-cstruct")
    (version "6.2.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/mirage/ocaml-cstruct")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1x3ljgf2kn373cbhczxy8mqfrrkd6lhxax5sy0qv49k6zsax7m32"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "cstruct"))
    (propagated-inputs
     (list ocaml-bigarray-compat))
    (native-inputs
     (list ocaml-alcotest))
    (home-page "https://github.com/mirage/ocaml-cstruct")
    (synopsis "Access C structures via a camlp4 extension")
    (description "Cstruct is a library and syntax extension to make it easier
to access C-like structures directly from OCaml.  It supports both reading and
writing to these structures, and they are accessed via the Bigarray module.")
    (license license:isc)))

(define-public ocaml-cstruct-async
  (package
    (name "ocaml-cstruct-async")
    (version "6.2.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/mirage/ocaml-cstruct")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1x3ljgf2kn373cbhczxy8mqfrrkd6lhxax5sy0qv49k6zsax7m32"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "cstruct-async"))
    (propagated-inputs
     (list ocaml-bigarray-compat ocaml-async-unix ocaml-async))
    (native-inputs
     (list ocaml-alcotest))
    (home-page "https://github.com/mirage/ocaml-cstruct")
    (synopsis "Access C structures via a camlp4 extension")
    (description "Cstruct is a library and syntax extension to make it easier
to access C-like structures directly from OCaml.  It supports both reading and
writing to these structures, and they are accessed via the Bigarray module.")
    (license license:isc)))

;; TODO again, the "parent" package already has an explicit package argument,
;; so a variant package doesn't make sense, at least these aliases help the
;; importer out so it doesn't re-import things.  At least hopefully.
(define ocaml-cstruct-unix ocaml-cstruct)
(define ocaml-cstruct-sexp ocaml-cstruct)

(define-public ocaml-ppx-cstruct
  (package
    (inherit ocaml-cstruct)
    (name "ocaml-ppx-cstruct")
    (properties `((upstream-name . "ppx_cstruct")))
    (arguments
     '(#:package "ppx_cstruct"
       ;; TODO doesn't find test deps for some reason?
       ;; I have no clue why.
       #:tests? #f))
    (propagated-inputs (modify-inputs (package-propagated-inputs ocaml-cstruct)
                         (append ocaml-cstruct ocaml-ppxlib ocaml-sexplib)))
    (native-inputs (modify-inputs (package-propagated-inputs ocaml-cstruct)
                     (append ocaml-cstruct-sexp ocaml-findlib
                             ocaml-ppx-sexp-conv)))))

(define-public ocaml-hex
  (package
    (name "ocaml-hex")
    (version "1.5.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/mirage/ocaml-hex")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0xnl5wxd2qrba7phm3mdrjwd2kk26kb17dv94ciwp49ljcj28qc1"))))
    (build-system dune-build-system)
    (propagated-inputs
     `(("ocaml-bigarray-compat" ,ocaml-bigarray-compat)
       ("cstruct" ,ocaml-cstruct)))
    (home-page "https://github.com/mirage/ocaml-hex/")
    (synopsis "Minimal library providing hexadecimal converters")
    (description "Hex is a minimal library providing hexadecimal converters.")
    (license license:isc)))

(define-public ocaml-ezjsonm
  (package
    (name "ocaml-ezjsonm")
    (version "1.3.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mirage/ezjsonm")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "004knljxqxn9zq0rnq7q7wxl4nwlzydm8p9f5cqkl8il5yl5zkjm"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "ezjsonm"))
    (native-inputs (list ocaml-alcotest node-lts))
    (propagated-inputs (list ocaml-jsonm ocaml-uutf ocaml-sexplib0 ocaml-hex))
    (home-page "https://github.com/mirage/ezjsonm/")
    (synopsis "Read and write JSON data")
    (description "Ezjsonm provides more convenient (but far less flexible) input
and output functions that go to and from [string] values than jsonm.  This avoids
the need to write signal code, which is useful for quick scripts that manipulate
JSON.")
    (license license:isc)))

(define-public ocaml-uri
  (package
    (name "ocaml-uri")
    (version "4.2.0")
    (home-page "https://github.com/mirage/ocaml-uri")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1bgkc66cq00mgnkz3i535srwzwc4cpdsv0mly5dzvvq33451xwf0"))))
    (build-system dune-build-system)
    (arguments '(#:package "uri"))
    (propagated-inputs
     (list ocaml-stringext ocaml-angstrom))
    (native-inputs
     (list ocaml-ounit ocaml-ppx-sexp-conv))
    (properties `((upstream-name . "uri")))
    (synopsis "RFC3986 URI/URL parsing library")
    (description "OCaml-uri is a library for parsing URI/URL in the RFC3986 format.")
    (license license:isc)))

(define-public ocaml-easy-format
  (package
    (name "ocaml-easy-format")
    (version "1.3.4")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/mjambon/easy-format")
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0xap6az4yyb60vb1jfs640wl3cf4njv78p538x9ihhf9f6ij3nh8"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "easy-format"
       #:phases
       (modify-phases %standard-phases
         (add-before 'build 'make-writable
           (lambda _
             (for-each
               (lambda (file)
                 (chmod file #o644))
               (find-files "." "."))
             #t)))))
    (home-page "https://github.com/mjambon/easy-format")
    (synopsis "Interface to the Format module")
    (description "Easy-format is a high-level and functional interface to the
Format module of the OCaml standard library.")
    (license license:bsd-3)))

(define-public ocaml-piqilib
  (package
    (name "ocaml-piqilib")
    (version "0.6.16")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/alavrik/piqi")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0mbhfrfrik3jlzx9zz680g0qdvv0b7cbjz28cgdlryp7nk4v4kx8"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-before 'configure 'fix-ocamlpath
           (lambda _
             (substitute* '("Makefile" "make/Makefile.ocaml")
               (("OCAMLPATH := ") "OCAMLPATH := $(OCAMLPATH):"))))
         (replace 'configure
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (substitute* "make/OCamlMakefile"
                 (("/bin/sh") (which "bash")))
               (invoke "./configure" "--prefix" out "--ocaml-libdir"
                       (string-append out "/lib/ocaml/site-lib")))))
       (add-after 'build 'build-ocaml
         (lambda* (#:key outputs #:allow-other-keys)
           (invoke "make" "ocaml")))
       (add-after 'install 'install-ocaml
         (lambda* (#:key outputs #:allow-other-keys)
           (invoke "make" "ocaml-install")))
       (add-after 'install-ocaml 'link-stubs
         (lambda* (#:key outputs #:allow-other-keys)
           (let* ((out (assoc-ref outputs "out"))
                  (stubs (string-append out "/lib/ocaml/site-lib/stubslibs"))
                  (lib (string-append out "/lib/ocaml/site-lib/piqilib")))
             (mkdir-p stubs)
             (symlink (string-append lib "/dllpiqilib_stubs.so")
                      (string-append stubs "/dllpiqilib_stubs.so"))))))))
    (native-inputs
     (list which))
    (propagated-inputs
     `(("ocaml-xmlm" ,ocaml-xmlm)
       ("ocaml-sedlex" ,ocaml-sedlex-2)
       ("ocaml-easy-format" ,ocaml-easy-format)
       ("ocaml-base64" ,ocaml-base64)))
    (home-page "https://piqi.org")
    (synopsis "Data serialization and conversion library")
    (description "Piqilib is the common library used by the piqi command-line
tool and piqi-ocaml.")
    (license license:asl2.0)))

(define-public ocaml-uuidm
  (package
    (name "ocaml-uuidm")
    (version "0.9.10")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://erratique.ch/software/uuidm/"
                                  "releases/uuidm-" version ".tbz"))
              (sha256
               (base32
                "0mz9fyrdpqbh5yhldabnlqq71n64fn4ccbkhwqr2jcynhx55jrci"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:build-flags
       (list "build" "--tests" "true" "--with-cmdliner" "true")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             ;; Use ocamlfind install to avoid circular dependency on opam-installer
             (let ((lib (string-append (assoc-ref outputs "out")
                                       "/lib/ocaml/site-lib")))
               (mkdir-p lib)
               (with-directory-excursion "_build"
                 (invoke "ocamlfind" "install" "uuidm"
                         "../pkg/META"
                         "src/uuidm.a"
                         "src/uuidm.cma"
                         "src/uuidm.cmxa"
                         "src/uuidm.cmxs"
                         "src/uuidm.cmx"
                         "src/uuidm.cmi"
                         "src/uuidm.mli"))))))))
    (native-inputs
     (list ocamlbuild))
    (propagated-inputs
     `(("cmdliner" ,ocaml-cmdliner)
       ("topkg" ,ocaml-topkg)))
    (home-page "https://erratique.ch/software/uuidm")
    (synopsis "Universally unique identifiers for OCaml")
    (description "Uuidm is an OCaml module implementing 128 bits universally
unique identifiers (UUIDs) version 3, 5 (named based with MD5, SHA-1 hashing)
and 4 (random based) according to RFC 4122.")
    (license license:isc)))

(define-public ocaml-graph
  (package
    (name "ocaml-graph")
    (version "2.2.0")
    (home-page "https://github.com/backtracking/ocamlgraph/")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url home-page)
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "02f4iyrnnhi7kam7qrnny76vbdh1q68748bcrq02cy8wa79chp3r"))))
    (build-system dune-build-system)
    (arguments `(#:package "ocamlgraph"))
    (propagated-inputs (list ocaml-stdlib-shims))
    (native-inputs (list ocaml-graphics))
    (properties `((upstream-name . "ocamlgraph")))
    (synopsis "Graph library for OCaml")
    (description "OCamlgraph is a generic graph library for OCaml.")
    (license license:lgpl2.1)))

(define-public ocaml-graphql
  (package
    (name "ocaml-graphql")
    (version "0.14.0")
    (home-page "https://github.com/andreas/ocaml-graphql-server"
               )
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url home-page)
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0pxn2pqw881cs8lwwhxi0k5lfy992fwr7xmjxcy9ndqp35kay2bk"
                ))))
    (build-system dune-build-system)
    (arguments `(#:package "graphql"))
    ;; (propagated-inputs (list ocaml-stdlib-shims))
    (native-inputs (list ocaml-graphics ocaml-seq ocaml-rresult ocaml-yojson ocaml-graphql-parser))
    ;; (properties `((upstream-name . "ocamlgraph")))
    (synopsis "")
    (description "")
    (license license:expat)))

(define-public ocaml-graphql-lwt
  (package
    (name "ocaml-graphql")
    (version "0.14.0")
    (home-page "https://github.com/andreas/ocaml-graphql-server"
               )
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url home-page)
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0pxn2pqw881cs8lwwhxi0k5lfy992fwr7xmjxcy9ndqp35kay2bk"
                       ))))
    (build-system dune-build-system)
    (arguments `(#:package "graphql-lwt"))
    (propagated-inputs (list ocaml-graphql-parser ocaml-graphql ocaml-lwt ocaml-rresult ocaml-yojson))
    (native-inputs (list ocaml-graphics))
    ;; (properties `((upstream-name . "ocamlgraph")))
    (synopsis "")
    (description "")
    (license license:expat)))

(define-public ocaml-graphql-parser
  (package
    (name "ocaml-graphql")
    (version "0.14.0")
    (home-page "https://github.com/andreas/ocaml-graphql-server"
               )
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url home-page)
                     (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0pxn2pqw881cs8lwwhxi0k5lfy992fwr7xmjxcy9ndqp35kay2bk"
                       ))))
    (build-system dune-build-system)
    (arguments `(#:package "graphql_parser"))
    (propagated-inputs (list ocaml-menhir ocaml-re ocaml-fmt ocaml-alcotest))
    (native-inputs (list ocaml-graphics))
    (properties `((upstream-name . "graphql_parser")))
    (synopsis "")
    (description "")
    (license license:expat)))

(define-public ocaml-piqi
  (package
    (name "ocaml-piqi")
    (version "0.7.8")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/alavrik/piqi-ocaml")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "12m9vxir0cs2155nxs0a3m3npf3w79kyxf9a5lmf18qvvgismfz8"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:make-flags
       ,#~(list (string-append "DESTDIR=" #$output)
                (string-append "SHELL="
                               #+(file-append (canonical-package bash-minimal)
                                              "/bin/sh")))
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'make-files-writable
           (lambda _
             (for-each make-file-writable (find-files "."))
             #t))
         (delete 'configure))))
    (native-inputs
     (list which protobuf)) ; for tests
    (propagated-inputs
     `(("ocaml-num" ,ocaml-num)
       ("ocaml-piqilib" ,ocaml-piqilib)
       ("ocaml-stdlib-shims" ,ocaml-stdlib-shims)))
    (home-page "https://github.com/alavrik/piqi-ocaml")
    (synopsis "Protocol serialization system for OCaml")
    (description "Piqi is a multi-format data serialization system for OCaml.
It provides a uniform interface for serializing OCaml data structures to JSON,
XML and Protocol Buffers formats.")
    (license license:asl2.0)))

(define-public ocaml-ppx-bap
  (package
    (name "ocaml-ppx-bap")
    (version "0.14.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/BinaryAnalysisPlatform/ppx_bap")
                     (commit (string-append "v" (version-major+minor version)))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1c6rcdp8bicdiwqc2mb59cl9l2vxlp3y8hmnr9x924fq7acly248"))))
    (build-system dune-build-system)
    (arguments
     ;; No tests
     `(#:tests? #f))
    (propagated-inputs (list ocaml-base-quickcheck
                             ocaml-ppx-assert
                             ocaml-ppx-bench
                             ocaml-ppx-bin-prot
                             ocaml-ppx-cold
                             ocaml-ppx-compare
                             ocaml-ppx-enumerate
                             ocaml-ppx-fields-conv
                             ocaml-ppx-hash
                             ocaml-ppx-here
                             ocaml-ppx-optcomp
                             ocaml-ppx-sexp-conv
                             ocaml-ppx-sexp-value
                             ocaml-ppx-variants-conv
                             ocaml-ppxlib))
    (properties `((upstream-name . "ppx_bap")))
    (home-page "https://github.com/BinaryAnalysisPlatform/ppx_bap")
    (synopsis "The set of ppx rewriters for BAP")
    (description
     "@code{ppx_bap} is the set of blessed ppx rewriters used in BAP projects.
It fills the same role as @code{ppx_base} or @code{ppx_jane} (from which it is
derived), but doesn't impose any style requirements and has only the minimal
necessary set of rewriters.")
    (license license:expat)))

(define-public bap
  (let (;; Let pin one commit because -alpha is subject to change.
        ;; The last stable release v2.5.0 is from July 2022.
        (revision "0")
        (commit "f995d28a4a34abb4cef8e0b3bd3c41cd710ccf1a"))
    (package
      (name "bap")
      (version (git-version "2.6.0-alpha" revision commit))
      (home-page "https://github.com/BinaryAnalysisPlatform/bap")
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url home-page)
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "1zfkc8nagf8kvxbypalbhf6gs0c7i48zx53hlpak2ipjwhvm5im5"))))
      (build-system ocaml-build-system)
      (arguments
       (list
        #:use-make? #t
        #:phases
        #~(modify-phases %standard-phases
            (add-before 'configure 'fix-ncurses
              (lambda _
                (substitute* "oasis/llvm"
                  (("-lcurses") "-lncurses"))
                #t))
            (replace 'configure
              (lambda* (#:key outputs inputs #:allow-other-keys)
                (for-each make-file-writable (find-files "." "."))
                ;; Package name changed
                (substitute* "oasis/elf-loader"
                  (("bitstring.ppx") "ppx_bitstring"))
                ;; We don't have a monolithic llvm
                (substitute* "oasis/llvm.setup.ml.in"
                  (("llvm_static = \"true\"") "true"))
                ;; Package update removed Make_binable, which was an alias
                ;; for Make_binable_without_uuid
                (substitute* (find-files "." ".")
                  (("Utils.Make_binable1\\(") "Utils.Make_binable1_without_uuid(")
                  (("Utils.Make_binable\\(") "Utils.Make_binable_without_uuid("))
                (invoke "./configure" "--prefix"
                        (assoc-ref outputs "out")
                        "--libdir"
                        (string-append
                         (assoc-ref outputs "out")
                         "/lib/ocaml/site-lib")
                        (string-append "--with-llvm-version=" #$(package-version llvm))
                        "--with-llvm-config=llvm-config"
                        "--disable-ghidra"
                        "--disable-llvm-static"
                        "--enable-llvm"
                        "--enable-everything"))))))
      (native-inputs (list clang ocaml-oasis ocaml-ounit))
      (propagated-inputs
       (list
        camlzip
        ocaml-bitstring
        ocaml-cmdliner
        ocaml-core-kernel
        ocaml-ezjsonm
        ocaml-fileutils
        ocaml-frontc
        ocaml-graph
        ocaml-linenoise
        ocaml-ocurl
        ocaml-piqi
        ocaml-ppx-bap
        ocaml-ppx-bitstring
        ocaml-re
        ocaml-uri
        ocaml-utop
        ocaml-uuidm
        ocaml-yojson
        ocaml-z3
        ocaml-zarith))
      (inputs
       (list gmp llvm ncurses))
      (synopsis "Binary Analysis Platform")
      (description "Binary Analysis Platform is a framework for writing program
analysis tools, that target binary files.  The framework consists of a plethora
of libraries, plugins, and frontends.  The libraries provide code reusability,
the plugins facilitate extensibility, and the frontends serve as entry points.")
      (license license:expat))))

(define-public ocaml-camomile
  (package
    (name "ocaml-camomile")
    (version "1.0.2")
    (home-page "https://github.com/yoriyuki/Camomile")
    (source (origin
              (method url-fetch)
              (uri (string-append home-page "/releases/download/" version
                                  "/camomile-" version ".tbz"))
              (sha256
               (base32
                "0chn7ldqb3wyf95yhmsxxq65cif56smgz1mhhc7m0dpwmyq1k97h"))))
    (build-system dune-build-system)
    (arguments
     `(#:tests? #f ; Tests fail, see https://github.com/yoriyuki/Camomile/issues/82
       #:phases
       (modify-phases %standard-phases
         (add-before 'build 'fix-usr-share
           (lambda* (#:key outputs #:allow-other-keys)
             (substitute* '("Camomile/dune" "configure.ml")
               (("/usr/share") (string-append (assoc-ref outputs "out") "/share")))
             #t)))))
    (synopsis "Comprehensive Unicode library")
    (description "Camomile is a Unicode library for OCaml.  Camomile provides
Unicode character type, UTF-8, UTF-16, UTF-32 strings, conversion to/from about
200 encodings, collation and locale-sensitive case mappings, and more.  The
library is currently designed for Unicode Standard 3.2.")
    ;; with an exception for linked libraries to use a different license
    (license license:lgpl2.0+)))

(define-public ocaml-charinfo-width
  ;; Add LICENSE file and Dune tests
  (let ((commit "20aaaa6dca8f1e0b1ace55b6f2a8ba5e5910b620"))
    (package
      (name "ocaml-charinfo-width")
      (version (git-version "1.1.0" "1" commit))
      (home-page "https://github.com/kandu/charinfo_width/")
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url home-page)
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "04gil5hxm2jax9paw3i24d8zyzhyl5cphzfyryvy2lcrm3c485q0"))))
      (build-system dune-build-system)
      (propagated-inputs
       (list ocaml-camomile))
      (native-inputs
       (list ocaml-ppx-expect))
      (properties
       `((upstream-name . "charInfo_width")))
      (synopsis "Determine column width for a character")
      (description "This module implements purely in OCaml a character width
function that follows the prototype of POSIX's wcwidth.")
      (license license:expat))))

(define-public ocaml-zed
  (package
    (name "ocaml-zed")
    (version "3.2.1")
    (home-page "https://github.com/ocaml-community/zed")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "17zdbm422y0qznc659civ9bmahhrbffxa50f8dnykiaq8v2ci91l"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-react
           ;; ocaml-result
           ocaml-uchar
           ocaml-uutf
           ocaml-uucp
           ocaml-uuseg
          ))
    (synopsis "Abstract engine for text edition in OCaml")
    (description
     "This module provides an abstract engine for text edition.  It can be
used to write text editors, edition widgets, readlines, and more.  The module
Zed uses Camomile to fully support the Unicode specification, and implements
an UTF-8 encoded string type with validation, and a rope datastructure to
achieve efficient operations on large Unicode buffers.  Zed also features a
regular expression search on ropes.  To support efficient text edition
capabilities, Zed provides macro recording and cursor management facilities.")
    (license license:bsd-3)))

(define-public ocaml-lambda-term
  (package
    (name "ocaml-lambda-term")
    (version "3.3.1")
    (home-page "https://github.com/ocaml-community/lambda-term")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1pkamblc6h0rsbk901cqn3xr9gqa3g8wrwyx5zryaqvb2xpbhp8b"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-logs
           ocaml-lwt
           ocaml-lwt-react
           ocaml-mew-vi
          
           ocaml-react
           ocaml-zed))
    (synopsis "Terminal manipulation library for OCaml")
    (description "Lambda-Term is a cross-platform library for manipulating the
terminal.  It provides an abstraction for keys, mouse events, colors, as well as
a set of widgets to write curses-like applications.  The main objective of
Lambda-Term is to provide a higher level functional interface to terminal
manipulation than, for example, ncurses, by providing a native OCaml interface
instead of bindings to a C library.")
    (license license:bsd-3)))

(define-public ocaml-utop
  (package
    (name "ocaml-utop")
    (version "2.10.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ocaml-community/utop")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1pcix3h9f7is06581iax4i08zkd6sv8y5hy1vvxhqhcsd9z0qfl3"))))
    (build-system dune-build-system)
    (native-inputs
     (list ocaml-cppo))
    (propagated-inputs
     (list ocaml-lambda-term
           ocaml-logs
           ocaml-lwt
           ocaml-lwt-react
           ocaml-react
           ocaml-zed))
    (home-page "https://github.com/ocaml-community/utop")
    (synopsis "Improved interface to the OCaml toplevel")
    (description "UTop is an improved toplevel for OCaml.  It can run in a
terminal or in Emacs.  It supports line editing, history, real-time and context
sensitive completion, colors, and more.")
    (license license:bsd-3)))

(define-public ocaml-ansiterminal
  (package
    (name "ocaml-ansiterminal")
    (version "0.8.5")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/Chris00/ANSITerminal")
                    (commit version)
                    (recursive? #t)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "052qnc23vmxp90yympjz9q6lhqw98gs1yvb3r15kcbi1j678l51h"))))
    (build-system dune-build-system)
    (properties `((upstream-name . "ANSITerminal")))
    (home-page "https://github.com/Chris00/ANSITerminal")
    (synopsis
     "Basic control of ANSI compliant terminals and the windows shell")
    (description
     "ANSITerminal is a module allowing to use the colors and cursor
movements on ANSI terminals.")
    ;; Variant of the LGPL3+ which permits
    ;; static and dynamic linking when producing binary files.
    ;; In other words, it allows one to link to the library
    ;; when compiling nonfree software.
    (license (license:non-copyleft "LICENSE.md"))))

(define-public ocaml-ptmap
  (package
    (name "ocaml-ptmap")
    (version "2.0.5")
    (source (origin
              (method url-fetch)
              (uri
               (string-append "https://github.com/backtracking/ptmap/releases/download/"
                              version "/ptmap-" version ".tbz"))
              (sha256
               (base32
                "1apk61fc1y1g7x3m3c91fnskvxp6i0vk5nxwvipj56k7x2pzilgb"))))
    (build-system dune-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (replace 'check
                 (lambda* (#:key tests? #:allow-other-keys)
                   (when tests?
                     (invoke "dune" "runtest")))))))
    (propagated-inputs (list ocaml-stdlib-shims ocaml-seq))
    (home-page "https://github.com/backtracking/ptmap")
    (synopsis "Maps of integers implemented as Patricia trees")
    (description
     "An implementation inspired by Okasaki & Gill's paper 'Fast Mergeable
Integer Maps.'")
    (license license:lgpl2.1))) ; with linking exception

(define-public ocaml-integers
  (package
    (name "ocaml-integers")
    (version "0.7.0")
    (home-page "https://github.com/ocamllabs/ocaml-integers")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0c0bmy53ag6504kih0cvnp4yf7mbcimb18m1mgs592ffb0zj1rff"))))
    (build-system dune-build-system)
    (arguments
     `(#:tests? #f)) ; no tests
    (propagated-inputs
     (list ocaml-stdlib-shims))
    (synopsis "Various signed and unsigned integer types for OCaml")
    (description "The ocaml-integers library provides a number of 8-, 16-, 32-
and 64-bit signed and unsigned integer types, together with aliases such as
long and size_t whose sizes depend on the host platform.")
    (license license:expat)))

(define-public ocaml-ctypes
  (package
   (name "ocaml-ctypes")
   (version "0.23.0")
   (home-page "https://github.com/ocamllabs/ocaml-ctypes")
   (source (origin
             (method git-fetch)
             (uri (git-reference
                    (url home-page)
                    (commit version)))
             (file-name (git-file-name name version))
             (sha256
              (base32
               "16dxz2r070vlrkbqhza0c5y6izxpjn080vqmxj47i919wfqd75vx"))
             (patches (search-patches "ocaml-ctypes-test-oo.patch"))))
   (build-system dune-build-system)
   (arguments
    `(#:phases
      (modify-phases %standard-phases
        (add-after 'unpack 'make-writable
          (lambda _
            (for-each make-file-writable
                      (find-files "."))))
        (delete 'configure))))
   (native-inputs
    `(("pkg-config" ,pkg-config)
      ("ounit" ,ocaml-ounit)
      ("lwt" ,ocaml-lwt)))
   (propagated-inputs
    `(("bigarray-compat" ,ocaml-bigarray-compat)
      ("integers" ,ocaml-integers)))
   (inputs
    (list libffi))
   (synopsis "Library for binding to C libraries using pure OCaml")
   (description "Ctypes is a library for binding to C libraries using pure
OCaml.  The primary aim is to make writing C extensions as straightforward as
possible.  The core of ctypes is a set of combinators for describing the
structure of C types -- numeric types, arrays, pointers, structs, unions and
functions.  You can use these combinators to describe the types of the
functions that you want to call, then bind directly to those functions -- all
without writing or generating any C!")
   (license license:expat)))

(define-public ocaml-ocb-stubblr
  (package
   (name "ocaml-ocb-stubblr")
   (version "0.1.1")
   (home-page "https://github.com/pqwy/ocb-stubblr")
   (source (origin
             (method url-fetch)
             (uri (string-append
                   home-page "/releases/download/v0.1.1/ocb-stubblr-"
                   version ".tbz"))
             (file-name (string-append name "-" version ".tbz"))
             (sha256
              (base32
               "167b7x1j21mkviq8dbaa0nmk4rps2ilvzwx02igsc2706784z72f"))))
   (build-system ocaml-build-system)
   (arguments
    `(#:build-flags (list "build" "--tests" "true")
      #:phases
      (modify-phases %standard-phases
        (delete 'configure)
        (add-before 'build 'fix-for-guix
          (lambda _
            (substitute* "src/ocb_stubblr.ml"
              ;; Do not fail when opam is not present or initialized
              (("error_msgf \"error running opam\"") "\"\"")
              ;; Guix doesn't have cc, but it has gcc
              (("\"cc\"") "\"gcc\""))
            #t)))))
   (inputs (list ocaml-topkg opam-installer))
   (native-inputs (list ocaml-astring ocamlbuild))
   (synopsis "OCamlbuild plugin for C stubs")
   (description "Ocb-stubblr is about ten lines of code that you need to
repeat over, over, over and over again if you are using ocamlbuild to build
OCaml projects that contain C stubs.")
   (license license:isc)))

(define-public ocaml-tsdl
  (package
    (name "ocaml-tsdl")
    (version "1.1.0")
    (home-page "https://erratique.ch/software/tsdl")
    (source (origin
              (method url-fetch)
              (uri (string-append home-page "/releases/tsdl-"
                                  version ".tbz"))
              (file-name (string-append name "-" version ".tar.gz"))
              (sha256
               (base32
                "0fw78qby010ai8apgwc66ary6zm3a5nw57228i44vccypav3xpk4"))))
    (build-system ocaml-build-system)
    (arguments
     `(#:build-flags '("build")
       #:tests? #f; tests require a display device
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))))
    (native-inputs
     (list ocamlbuild ocaml-astring opam-installer pkg-config))
    (inputs
     `(("topkg" ,ocaml-topkg)
       ("sdl2" ,sdl2)
       ("integers" ,ocaml-integers)
       ("ctypes" ,ocaml-ctypes)))
    (synopsis "Thin bindings to SDL for OCaml")
    (description "Tsdl is an OCaml library providing thin bindings to the
cross-platform SDL C library.")
    (license license:isc)))

(define-public dedukti
  (package
    (name "dedukti")
    (version "2.7")
    (home-page "https://deducteam.github.io/")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/deducteam/dedukti")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1dsr3s88kgmcg3najhc29cwfvsxa2plvjws1127fz75kmn15np28"))))
    (build-system dune-build-system)
    (inputs (list gmp ocaml-cmdliner ocaml-z3 z3))
    (native-inputs (list ocaml-menhir))
    (synopsis "Proof-checker for the λΠ-calculus modulo theory, an extension of
the λ-calculus")
    (description "Dedukti is a proof-checker for the λΠ-calculus modulo
theory.  The λΠ-calculus is an extension of the simply typed λ-calculus with
dependent types.  The λΠ-calculus modulo theory is itself an extension of the
λΠ-calculus where the context contains variable declaration as well as rewrite
rules.  This system is not designed to develop proofs, but to check proofs
developed in other systems.  In particular, it enjoys a minimalistic syntax.")
    (license license:cecill-c)))

(define-public ocaml-jst-config
  (package
    (name "ocaml-jst-config")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/jst-config")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "1dy345p6825wyhpv6drlrl9gqwcgx341a5k3pnvfnxpcc6mkw167"
                 ))))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (propagated-inputs
      (list ocaml-base ocaml-ppx-assert ocaml-stdio dune-configurator))
    (home-page "https://github.com/janestreet/jst-config")
    (synopsis "Compile-time configuration for Jane Street libraries")
    (description "Defines compile-time constants used in Jane Street libraries
such as Base, Core, and Async.  This package has an unstable interface; it is
intended only to share configuration between different packages from Jane
Street.  Future updates may not be backward-compatible, and we do not
recommend using this package directly.")
    (license license:expat)))

(define-public ocaml-jane-street-headers
  (package
    (name "ocaml-jane-street-headers")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/jane-street-headers")
    (source
     (github-tag-origin
      name home-page version
      "0hq29ip8k7vyjrjm5hq9bq6b5cmssqlzcsaqi350sp39xg9bhilw"
      "v"))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (synopsis "Jane Street C header files")
    (description "C header files shared between the various Jane Street
packages.")
    (license license:expat)))

(define-public ocaml-uuuu
  (package
    (name "ocaml-uuuu")
    (version "0.3.0")
    (home-page "https://github.com/mirage/uuuu")
    (source
     (github-tag-origin
      name home-page version
      "0jbv126gzmqbjyif0qj6ajazdxdzl7h5rz00045n69ag80s4x8ig"
      "v"))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (synopsis "")
    (description "")
    (license license:expat)))


(define-public ocaml-yuscii
  (package
    (name "ocaml-yuscii")
    (version "0.3.0")
    (home-page "https://github.com/mirage/yuscii")
    (source
     (github-tag-origin
      name home-page version
      "11qf4ds5gmap4afg40lim2m9l1v7lv80k3fk41py25z4p2f0rzbc"
      "v"))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (synopsis "")
    (description "")
    (license license:expat)))

(define-public ocaml-coin
  (package
    (name "ocaml-coin")
    (version "0.1.4")
    (home-page "https://github.com/mirage/coin")
    (source
     (github-tag-origin
      name home-page version
      "06q4y0ky3q5860a14ly2jixzk16c0c6yv7skv4p6kld4vaabbxgx"
      "v"))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    ;; (propagated-inputs (list ocaml-coin))
    (synopsis "Coin")
    (description "coin is a little library to normalize an KOI8-{U,R} input to Unicode. This library uses tables provided by the Unicode Consortium:

https://ftp.unicode.org/Public/MAPPINGS/VENDORS/MISC

This project takes tables and converts them to OCaml code. Then, it provides a non-blocking decoder to translate KOI8-{U,R} codepoint to Unicode codepoint.")
    (license license:expat)))

(define-public ocaml-rosetta
  (package
    (name "ocaml-rosetta")
    (version "0.3.0")
    (home-page "https://github.com/mirage/rosetta")
    (source
     (github-tag-origin
      name home-page version "16r0gid0ypv500pi7jxsmbwn2w7pps2h0xb8wd3imjzkq6pq7qsy"
      "v"))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (propagated-inputs (list ocaml-coin ocaml-yuscii ocaml-uuuu))
    (synopsis "Universal decoder of encoded flow to Unicode ")
    (description "Rosetta is a merge-point between uuuu, coin and yuscii. It able to decode UTF-7, ISO-8859 and KOI8 and return Unicode code-point - then, end-user can normalize it to UTF-8 with uutf for example.

The final goal is to provide an universal decoder of any encoding. This project is a part of mrmime, a parser of emails to be able to decode encoded-word (according rfc2047).")
    (license license:expat)))

(define-public ocaml-time-now
  (package
    (name "ocaml-time-now")
    (version "0.17.0")
    (home-page
     "https://github.com/janestreet/time_now")
    (source
     (github-tag-origin
      name home-page version
      "1abn5fqqixlj1jbqb6vwysn48m0fv9cp7jyw5nfkkyxivw9xccvd" "v"))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (propagated-inputs
     (list ocaml-base ocaml-jane-street-headers ocaml-jst-config
           ocaml-ppx-base ocaml-ppx-optcomp))
    (properties `((upstream-name . "time_now")))
    (synopsis "Reports the current time")
    (description
     "Provides a single function to report the current time in nanoseconds
since the start of the Unix epoch.")
    (license license:expat)))

(define-public ocaml-ppx-inline-test
  (package
    (name "ocaml-ppx-inline-test")
    (version "0.17.1")
    (home-page "https://github.com/janestreet/ppx_inline_test")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url (string-append home-page ".git"))
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1y7lkj20r0kv8pziwny314yq4xirmqa6sjklxjy3an8ysmsc7l60"))))
    (build-system dune-build-system)
    (arguments
     `(#:tests? #f)) ;see home page README for further information
    (propagated-inputs
     (list ocaml-base
           ocaml-compiler-libs
           ocaml-sexplib0
           ocaml-stdio
           ocaml-ppxlib
           ocaml-time-now))
    (properties `((upstream-name . "ppx_inline_test")))
    (synopsis "Syntax extension for writing in-line tests in ocaml code")
    (description "This package contains a syntax extension for writing
in-line tests in ocaml code.  It is part of Jane Street's PPX rewriters
collection.")
    (license license:expat)))

(define-public ocaml-bindlib
  (package
    (name "ocaml-bindlib")
    (version "6.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/rlepigre/ocaml-bindlib")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1viyws3igy49hfaj4jaiwm4iggck9zdn7r3g6kh1n4zxphqk57yk"))))
    (build-system dune-build-system)
    (native-inputs
     (list ocamlbuild ocaml-findlib))
    (home-page "https://rlepigre.github.io/ocaml-bindlib/")
    (synopsis "OCaml Bindlib library for bound variables")
    (description "Bindlib is a library allowing the manipulation of data
structures with bound variables.  It is particularly useful when writing ASTs
for programming languages, but also for manipulating terms of the λ-calculus
or quantified formulas.")
    (license license:gpl3+)))

(define-public ocaml-earley
  (package
    (name "ocaml-earley")
    (version "3.0.0")
    (home-page "https://github.com/rlepigre/ocaml-earley")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url (string-append home-page ".git"))
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1vi58zdxchpw6ai0bz9h2ggcmg8kv57yk6qbx82lh47s5wb3mz5y"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-stdlib-shims))
    (synopsis "Parsing library based on Earley Algorithm")
    (description "Earley is a parser combinator library base on Earley's
algorithm.  It is intended to be used in conjunction with an OCaml syntax
extension which allows the definition of parsers inside the language.  There
is also support for writing OCaml syntax extensions in a camlp4 style.")
    (license license:cecill-b)))

(define-public ocaml-timed
  (package
    (name "ocaml-timed")
    (version "1.1")
    (home-page "https://github.com/rlepigre/ocaml-timed")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url (string-append home-page ".git"))
                    (commit version)))
              (sha256
               (base32
                "1aqmkpjv5jk95lc2m3qyyrhw8ra7n9wj8pv3bfc83l737zv0hjn1"))
              (file-name (git-file-name name version))))
    (build-system dune-build-system)
    (synopsis "Timed references for imperative state")
    (description "Timed references for imperative state.  This module provides
an alternative type for references (or mutable cells) supporting undo/redo
operations.  In particular, an abstract notion of time is used to capture the
state of the references at any given point, so that it can be restored.  Note
that usual reference operations only have a constant time / memory overhead
(compared to those of the standard library).

Moreover, we provide an alternative implementation based on the references
of the standard library (Pervasives module).  However, it is less efficient
than the first one.")
    (license license:expat)))

(define-public ocaml-biniou
 (package
   (name "ocaml-biniou")
   (version "1.2.2")
   (home-page "https://github.com/mjambon/biniou")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url (string-append home-page ".git"))
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1gd4nqffm9h7dzxyvpfpww24l61fqgazyh3p5f7k9jvgyv9y4vcn"))))
   (build-system dune-build-system)
   (arguments
    `(#:phases
      (modify-phases %standard-phases
        (add-before 'build 'make-writable
          (lambda _ (for-each make-file-writable (find-files "." ".")))))))
   (inputs
    (list ocaml-easy-format ocaml-camlp-streams))
   (native-inputs
    (list which))
   (synopsis "Data format designed for speed, safety, ease of use and backward
compatibility")
   (description "Biniou (pronounced \"be new\" is a binary data format
designed for speed, safety, ease of use and backward compatibility as
protocols evolve.  Biniou is vastly equivalent to JSON in terms of
functionality but allows implementations several times faster (4 times faster
than yojson), with 25-35% space savings.")
   (license license:bsd-3)))

(define-public ocaml-yojson
  (package
    (name "ocaml-yojson")
    (version "3.0.0")
    (home-page "https://github.com/ocaml-community/yojson")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url (string-append home-page ".git"))
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1q655y2j8b7j28ri2ffdqmv8lfgzb9dx62rz3a1p3sw7305bdan5"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "yojson"))
    (propagated-inputs (list ocaml-seq))
    (native-inputs (list ocaml-alcotest ocaml-cppo))
    (synopsis "Low-level JSON library for OCaml")
    (description "Yojson is an optimized parsing and printing library for the
JSON format.  It addresses a few shortcomings of json-wheel including 2x
speedup, polymorphic variants and optional syntax for tuples and variants.
@code{ydump} is a pretty printing command-line program provided with the
yojson package.  The program @code{atdgen} can be used to derive OCaml-JSON
serializers and deserializers from type definitions.")
    (license license:bsd-3)))

(define-public ocaml-ppx-yojson-conv
  (package
    (name "ocaml-ppx-yojson-conv")
    (version "0.17.1")
    (home-page
     "https://github.com/janestreet/ppx_yojson_conv")
    (source
     (github-tag-origin
      name home-page version
      "1cpl74k2ic3y0mv0r4jakspy4l7jg3xw9a2ffvqj0yyabwvsx3a0" "v"))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (propagated-inputs (list ocaml-ppxlib ocaml-ppx-js-style ocaml-ppx-yojson-conv-lib))
    (properties `((upstream-name . "ppx-yojson-conv")))
    (synopsis "ppx for yojson")
    (description "ppx_yojson_conv is a PPX syntax extension that generates code for converting OCaml types to and from Yojson.Safe, as defined in the =yojson= library.")
    ;; With linking exception.
    (license license:expat)))

(define-public ocaml-ppx-yojson-conv-lib
  (package
    (name "ocaml-ppx-yojson-conv-lib")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/ppx_yojson_conv_lib")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
          (url home-page)
          (commit (string-append "v" version))))
        (sha256
         (base32 "0nd9vghqbgpam17n4lrcwp88n67q98x0dr86d921760y05q2js2w"
                 ))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-yojson))
    (properties `((upstream-name . "ppx_yojson_conv_lib")))
    (synopsis "Runtime library used by ocaml PPX yojson convertor")
    (description "Ppx_yojson_conv_lib is the runtime library used by
ppx_yojson_conv, a ppx rewriter that can be used to convert ocaml types
to a Yojson.Safe value.")
    (license license:expat)))

(define-public ocaml-merlin-lib
  (package
    (name "ocaml-merlin-lib")
    (version "5.6-503")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ocaml/merlin")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "164mcl6rlaj8y6ia9l2zfc9pwq6x8kv3q62vkidjxm313lyq858k"
                ))))
    (build-system dune-build-system)
    (arguments '(#:package "merlin-lib"
                 #:tests? #f))          ; no tests
    (propagated-inputs (list ocaml-csexp ocaml-menhir))
    (properties `((ocaml5.0-variant . ,(delay ocaml5.0-merlin-lib))))
    (home-page "https://ocaml.github.io/merlin/")
    (synopsis "Merlin libraries")
    (description "These libraries provides access to low-level compiler
interfaces and the standard higher-level merlin protocol.")
    (license license:expat)))

;; the 500 indicates that this version is for OCaml 5.0
(define ocaml-merlin-lib-500
  (package
    (inherit ocaml-merlin-lib)
    (name "ocaml-merlin-lib")
    (version "4.14-500")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ocaml/merlin")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0rx0h8a7m435jmfvpxjf4682dxgb2f74ar1k1m3c3hls6yxgw0a9"))))
    (properties '())))

(define-public ocaml5.0-merlin-lib
  (package-with-ocaml5.0 ocaml-merlin-lib-500))

(define-public ocaml-dot-merlin-reader
  (package
    (inherit ocaml-merlin-lib)
    (name "ocaml-dot-merlin-reader")
    (arguments '(#:package "dot-merlin-reader"
                 #:tests? #f))          ; no tests
    (propagated-inputs (list ocaml-merlin-lib))
    (properties `((ocaml5.0-variant . ,(delay ocaml5.0-dot-merlin-reader))))
    (synopsis "Reads config files for @code{ocaml-merlin}")
    (description "@code{ocaml-dot-merlin-reader} is an external reader for
@code{ocaml-merlin} configurations.")))

(define-public ocaml5.0-dot-merlin-reader
  (package-with-ocaml5.0
   (package
     (inherit ocaml-merlin-lib-500)
     (name "ocaml-dot-merlin-reader")
     (arguments '(#:package "dot-merlin-reader"
                  #:tests? #f))         ; no tests
     (propagated-inputs (list ocaml5.0-merlin-lib))
     (synopsis "Reads config files for @code{ocaml-merlin}")
     (description "@code{ocaml-dot-merlin-reader} is an external reader for
@code{ocaml-merlin} configurations."))))

(define-public ocaml-merlin
  (package
    (inherit ocaml-dot-merlin-reader)
    (name "ocaml-merlin")
    (arguments
     '(#:package "merlin"
       #:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda* (#:key tests? #:allow-other-keys)
              ;; Tests require a writable cache directory
              (setenv "HOME" "/tmp")
             (when tests?
               (invoke "dune" "runtest" "-p" "merlin,dot-merlin-reader")))))))
    (propagated-inputs (list ocaml-merlin-lib ocaml-yojson))
    (properties `((ocaml5.0-variant . ,(delay ocaml5.0-merlin))))
    (native-inputs
     (list ocaml-dot-merlin-reader ; required for tests
           ocaml-ppxlib
           ocaml-mdx
           jq))
    (synopsis "Context sensitive completion for OCaml in Vim and Emacs")
    (description "Merlin is an editor service that provides modern IDE
features for OCaml.  Emacs and Vim support is provided out-of-the-box.
External contributors added support for Visual Studio Code, Sublime Text and
Atom.")
    (license license:expat)))

(define-public ocaml5.0-merlin
  (package-with-ocaml5.0
   (package
     (inherit ocaml-merlin-lib-500)
     (name "ocaml-merlin")
     (arguments
      '(#:package "merlin"
        #:phases
        (modify-phases %standard-phases
          (replace 'check
            (lambda* (#:key tests? #:allow-other-keys)
              ;; Tests require a writable cache directory
              (setenv "HOME" "/tmp")
              (when tests?
                (invoke "dune" "runtest" "-p" "merlin,dot-merlin-reader")))))))
     (propagated-inputs (list ocaml-merlin-lib ocaml-yojson))
     (native-inputs
      (list ocaml-dot-merlin-reader     ; required for tests
            ocaml-ppxlib
            ocaml-mdx
            jq))
     (synopsis "Context sensitive completion for OCaml in Vim and Emacs")
     (description "Merlin is an editor service that provides modern IDE
features for OCaml.  Emacs and Vim support is provided out-of-the-box.
External contributors added support for Visual Studio Code, Sublime Text and
Atom.")
     (license license:expat))))

(define-public ocaml-lsp-server
  (package
    (name "ocaml-lsp-server")
    (version "1.23.1")
    (home-page "https://github.com/ocaml/ocaml-lsp")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                (url home-page)
                (commit version)))
              (sha256
               (base32
                "1h02bgf3glf6d6mghk32ds8xm6a7h575f1zf9qkgr6y946rh0760"
                ))))
    (build-system dune-build-system)
    (arguments '(#:tests? #f)) ; tests are failing for v1.17
    (propagated-inputs (list
                             ocaml-re
                             ocaml-ppx-yojson-conv-lib
                             dune-rpc
                             ocaml-chrome-trace
                             dune-dyn
                             dune-stdune
                             ocaml-fiber
                             ocaml-xdg
                             dune-ordering
                             ocaml-dune-build-info
                             ocaml-spawn
                             ocamlc-loc
                             ocaml-uutf
                             ocaml-pp
                             ocaml-csexp
                             ocamlformat-rpc-lib
                            
                             ocaml-merlin-lib))
    (native-inputs (list ocaml-ppx-expect ocamlformat))
    (properties `((upstream-name . "ocaml-lsp-server")))
    (synopsis "LSP Server for OCaml")
    (description "This package implements an Ocaml language server implementation.")
    (license license:isc)))

(define-public ocaml5.0-lsp-server (package-with-ocaml5.0 ocaml-lsp-server))

(define-public ocaml-gsl
  (package
    (name "ocaml-gsl")
    (version "1.24.0")
    (source
     (origin
       (method url-fetch)
       (uri
        (string-append
         "https://github.com/mmottl/gsl-ocaml/releases/download/"
         version "/gsl-" version ".tbz"))
       (sha256
        (base32
         "1l5zkkkg8sglsihrbf10ivq9s8xzl1y6ag89i4jqpnmi4m43fy34"))))
    (build-system dune-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'fix-gsl-directory
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "src/config/discover.ml"
               (("/usr") (assoc-ref inputs "gsl"))))))))
    (inputs
     (list gsl))
    (propagated-inputs
     (list ocaml-base ocaml-stdio))
    (home-page "https://mmottl.github.io/gsl-ocaml")
    (synopsis "Bindings to the GNU Scientific Library")
    (description
     "GSL-OCaml is an interface to the @dfn{GNU scientific library} (GSL) for
the OCaml language.")
    (license license:gpl3+)))

(define-public cubicle
  (package
    (name "cubicle")
    (version "1.1.2")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://cubicle.lri.fr/cubicle-"
                                  version ".tar.gz"))
              (sha256
               (base32
                "10kk80jdmpdvql88sdjsh7vqzlpaphd8vip2lp47aarxjkwjlz1q"))))
    (build-system gnu-build-system)
    (native-inputs
     (list automake ocaml
           (@@ (gnu packages base) which)))
    (propagated-inputs
     (list ocaml-num z3))
    (arguments
     `(#:configure-flags (list "--with-z3")
       #:make-flags (list "QUIET=")
       #:tests? #f
       #:phases
       (modify-phases %standard-phases
         (add-before 'configure 'make-deterministic
           (lambda _
             (substitute* "Makefile.in"
               (("`date`") "no date for reproducibility"))))
         (add-before 'configure 'configure-for-release
           (lambda _
             (substitute* "Makefile.in"
               (("SVNREV=") "#SVNREV="))
             #t))
         (add-before 'configure 'fix-/bin/sh
           (lambda _
             (substitute* "configure"
               (("-/bin/sh") (string-append "-" (which "sh"))))
             #t))
         (add-before 'configure 'fix-smt-z3wrapper.ml
           (lambda _
             (substitute* "Makefile.in"
               (("\\\\n") ""))
             #t))
         (add-before 'configure 'fix-ocaml-num
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "Makefile.in"
               (("nums.cma") "num.cma num_core.cma")
               (("= \\$\\(FUNCTORYLIB\\)")
                (string-append "= -I "
                               (assoc-ref inputs "ocaml-num")
                               "/lib/ocaml/site-lib/num/core -I "
                               (assoc-ref inputs "ocaml-num")
                               "/lib/ocaml/site-lib/num"
                               " $(FUNCTORYLIB)")))
             #t)))))
    (home-page "https://cubicle.lri.fr/")
    (synopsis "Model checker for array-based systems")
    (description "Cubicle is a model checker for verifying safety properties
of array-based systems.  This is a syntactically restricted class of
parametrized transition systems with states represented as arrays indexed by
an arbitrary number of processes.  Cache coherence protocols and mutual
exclusion algorithms are typical examples of such systems.")
    (license license:asl2.0)))

(define-public ocaml-sexplib0
  (package
    (name "ocaml-sexplib0")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/sexplib0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url home-page)
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1s6bc7hj7zwrrz7m5c994h0zjx69af9lvx5ayjpg7dsy2h9g17a3"))))
    (build-system dune-build-system)
    (arguments `(#:tests? #f)) ;no tests
    (synopsis "Library containing the definition of S-expressions and some
base converters")
    (description "Part of Jane Street's Core library The Core suite of
libraries is an industrial strength alternative to OCaml's standard library
that was developed by Jane Street, the largest industrial user of OCaml.")
    (license license:expat)))

(define-public ocaml-parsexp
  (package
    (name "ocaml-parsexp")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/parsexp")
    ;; (source
    ;;  (github-tag-origin name home-page version "000"))
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url home-page)
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1mfw44f41kiy3jxbrina3vqrgbi8hdw6l6xsjy8sfcybf3lxkal8"))))
    (build-system dune-build-system)
    (inputs
     (list ocaml-sexplib0 ocaml-base))
    (synopsis "S-expression parsing library")
    (description
     "This library provides generic parsers for parsing S-expressions from
strings or other medium.

The library is focused on performances but still provide full generic
parsers that can be used with strings, bigstrings, lexing buffers,
character streams or any other sources effortlessly.

It provides three different class of parsers:
@itemize
@item
the normal parsers, producing [Sexp.t] or [Sexp.t list] values
@item
the parsers with positions, building compact position sequences so
that one can recover original positions in order to report properly
located errors at little cost
@item
the Concrete Syntax Tree parsers, produce values of type
@code{Parsexp.Cst.t} which record the concrete layout of the s-expression
syntax, including comments
@end itemize

This library is portable and doesn't provide IO functions.  To read
s-expressions from files or other external sources, you should use
parsexp_io.")
    (license license:expat)))

(define-public ocaml-sexplib
  (package
    (name "ocaml-sexplib")
    (version "0.16.0")
    (home-page "https://github.com/janestreet/sexplib")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url home-page)
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0hl0zf2cgjivvlsrf85f5lg4xprcgbz7qg2z51k838y7k2121k78"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-base ocaml-num ocaml-parsexp ocaml-sexplib0))
    (synopsis
     "Library for serializing OCaml values to and from S-expressions")
    (description
     "This package is part of Jane Street's Core library.  Sexplib contains
functionality for parsing and pretty-printing s-expressions.")
    (license license:expat)))

(define-public ocaml-sexp-pretty
  (package
    (name "ocaml-sexp-pretty")
    (version "0.17.0")
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-base ocaml-ppx-base ocaml-sexplib ocaml-re))
    (properties `((upstream-name . "sexp_pretty")))
    (home-page "https://github.com/janestreet/sexp_pretty")
    (synopsis "S-expression pretty-printer")
    (source
     (github-tag-origin
      name home-page version
      "0dq1gk64rhzjznlnwv7135b3ww38pcw3yn1i8fsw003p1abhpj0d"
      "v"
      ))
    (description
     "Library for pretty-printing s-expressions, using better indentation
rules than the default pretty printer in Sexplib.")
    (license license:expat)))

(define-public ocaml-base
  (package
    (name "ocaml-base")
    (version "0.17.3")
    (home-page "https://github.com/janestreet/base")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/base")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "0yyd9cs6qf8bzk4cpga6hh0iiarhyl2kn15ar3jgqgfmg3p6bcyb"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-sexplib0 ocaml-intrinsics-kernel))
    (synopsis
     "Full standard library replacement for OCaml")
    (description
     "Base is a complete and portable alternative to the OCaml standard
library.  It provides all standard functionalities one would expect
from a language standard library.  It uses consistent conventions
across all of its module.

Base aims to be usable in any context.  As a result system dependent
features such as I/O are not offered by Base.  They are instead
provided by companion libraries such as
@url{https://github.com/janestreet/stdio, ocaml-stdio}.")
    (license license:expat)))

(define-public ocaml-intrinsics-kernel
  (package
    (name "ocaml-intrinsics-kernel")
    (version "0.17.1")
    (home-page "https://github.com/janestreet/ocaml_intrinsics_kernel")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/janestreet/ocaml_intrinsics_kernel")
              (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1a85l2cns5g8vnxri1pxrx1zhs2r04bjl2sj2vfpcv9vs8k6pw6r"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-sexplib0))
    (synopsis
     "Full standard library replacement for OCaml")
    (description
     "
ocaml_intrinsics_kernel - a library of intrinsics for OCaml

The ocaml_intrinsics_kernel library provides an OCaml interface to operations that have dedicated hardware instructions on some micro-architectures. Currently, it provides the following operations:

    conditional select

See ocaml_intrinsics for details. Unlike ocaml_intrinsics, ocaml_intrinsics_kernel can be used by programs compiled to javascript."
     )
    (license license:expat)))

(define-public ocaml5.0-base
  ;; This version contains fixes for OCaml 5.0
  ;; (see https://github.com/ocaml/opam-repository/pull/21851)
  (let ((commit "423dbad212f55506767d758b1ceb2d6e0ee8e7f5")
        (revision "0"))
   (package-with-ocaml5.0
    (package
      (inherit ocaml-base)
      (name "ocaml-base")
      (version (git-version "0.17.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/kit-ty-kate/base")
               (commit commit)))
         (file-name (git-file-name "ocaml5.0-base" version))
         (sha256
          (base32
           "15vsiv3q53l1bzrvqgspf3lp2104s9dzw62z3nl75f53jvjvsyf6"))))
      (properties '())))))

(define-public ocaml-compiler-libs
  (package
    (name "ocaml-compiler-libs")
    (version "0.17")
    (home-page "https://github.com/janestreet/ocaml-compiler-libs")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0cs3waqdnf5xv5cv5g2bkjypgqibwlxgkxd5ddmvj5g9d82vm821"))))
    (build-system dune-build-system)
    (arguments `(#:tests? #f)) ;no tests
    (properties `((upstream-name . "ocaml-compiler-libs")))
    (synopsis "Compiler libraries repackaged")
    (description "This package simply repackages the OCaml compiler libraries
so they don't expose everything at toplevel.  For instance, @code{Ast_helper}
is now @code{Ocaml_common.Ast_helper}.")
    (license license:expat)))

(define-public ocaml-stdio
  (package
    (name "ocaml-stdio")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/stdio")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1l3da9qri8d04440ps51j9ffh6bpk8j11mda4lidcndkmr94r19p"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-base ocaml-sexplib0))
    (arguments `(#:tests? #f)) ;no tests
    (synopsis "Standard IO library for OCaml")
    (description
     "Stdio implements simple input/output functionalities for OCaml.  It
re-exports the input/output functions of the OCaml standard libraries using
a more consistent API.")
    (license license:expat)))

(define-public ocaml-ppx-deriving
  (package
    (name "ocaml-ppx-deriving")
    (version "6.1.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ocaml-ppx/ppx_deriving")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1hzzy3zxpwhs0diyx7lyp71szl987l2v62h2hndl5c7hv320k1il"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-ppx-derivers ocaml-ppxlib))
    (native-inputs
     (list ocaml-cppo ocaml-ounit2))
    (properties `((upstream-name . "ppx_deriving")))
    (home-page "https://github.com/ocaml-ppx/ppx_deriving")
    (synopsis "Type-driven code generation for OCaml")
    (description
     "Ppx_deriving provides common infrastructure for generating code based
on type definitions, and a set of useful plugins for common tasks.")
    (license license:expat)))

(define-public ocaml-ppx-derivers
  (package
    (name "ocaml-ppx-derivers")
    (version "1.2.1")
    (home-page
     "https://github.com/ocaml-ppx/ppx_derivers")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url (string-append home-page ".git"))
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0yqvqw58hbx1a61wcpbnl9j30n495k23qmyy2xwczqs63mn2nkpn"))))
    (build-system dune-build-system)
    (arguments
     '(#:tests? #f)) ;no tests
    (properties `((upstream-name . "ppx_derivers")))
    (synopsis "Shared @code{@@deriving} plugin registry")
    (description
     "Ppx_derivers is a tiny package whose sole purpose is to allow
ppx_deriving and ppx_type_conv to inter-operate gracefully when linked
as part of the same ocaml-migrate-parsetree driver.")
    (license license:bsd-3)))

(define-public ocaml-ppx-deriving-yojson
  (package
    (name "ocaml-ppx-deriving-yojson")
    (version "3.7.0")
    (home-page "https://github.com/ocaml-ppx/ppx_deriving_yojson")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url home-page)
              (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1nazam6zlzm9ngyyr1q7s1vmw162fnrvsn8r6bsn5lnpaygv28ly"))))
    (build-system dune-build-system)
    (propagated-inputs
      (list ocaml-yojson
            ;; ocaml-result
            ocaml-ppx-deriving
            ocaml-ppxlib))
    (native-inputs (list ocaml-ounit))
    (properties `((upstream-name . "ppx_deriving_yojson")))
    (synopsis "JSON codec generator for OCaml")
    (description
     "Ppx_deriving_yojson is a ppx_deriving plugin that provides a JSON codec
generator.")
    (license license:expat)))

(define-public ocaml-cinaps
  ;; The commit removes the unused dependency of ocaml-ppx-jane. We need to
  ;; use this as we would otherwise have a dependency loop between
  ;; ocaml-ppxlib and ocaml-ppx-jane.
  (let ((commit "d974bb2db3ab1ab14e81f989b5bdb609462bff47")
        (revision "0"))
    (package
      (name "ocaml-cinaps")
      (version (git-version "0.15.1" revision commit))
      (home-page "https://github.com/ocaml-ppx/cinaps")
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url home-page)
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "00kb04vqlnk1pynqjhna5qhn8790ab17baxf4na5py1l1h1js8qx"))))
      (build-system dune-build-system)
      (propagated-inputs (list ocaml-re))
      (synopsis "Trivial metaprogramming tool for OCaml")
      (description
       "Cinaps is a trivial Metaprogramming tool using the OCaml toplevel.  It is based
on the same idea as expectation tests.  The user writes some OCaml code inside
special comments and cinaps makes sure that what follows is what is printed by
the OCaml code.")
      (license license:expat))))

(define-public ocaml-ppxlib
  (package
    (name "ocaml-ppxlib")
    (version "0.37")
    (home-page "https://github.com/ocaml-ppx/ppxlib")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1ca4ivcl9j65c610s8gzx6xjhc13c0875wrbij577lqzsgjsbc98"))))
    (build-system dune-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'fix-test-format
           (lambda _
             ;; Since sexplib >= 0.15, error formatting has changed
             (substitute* "test/driver/exception_handling/run.t"
               (("\\(Failure ") "Failure("))
             (substitute* "test/base/test.ml"
               (("Invalid_argument \\((.*)\\)." _ m)
                (string-append "Invalid_argument " m "."))
               (("\\(Invalid_argument (.*)\\)" _ m)
                (string-append "Invalid_argument " m ".")))
             (substitute* "test/ppx_import_support/test.ml"
               (("\\(Failure") "Failure")
               (("  \"(Some ppx-es.*)\")" _ m)
                (string-append " \"" m "\".")))))
         (add-after 'fix-test-format 'fix-egrep
           (lambda _
             ;; egrep is obsolescent; using grep -E
             (substitute* "test/expansion_context/run.t"
               (("egrep") "grep -E")))))))
    (propagated-inputs
     (list ocaml-compiler-libs
           ocaml-ppx-derivers
           ocaml-sexplib0
           ocaml-cmdliner
           ocaml-stdlib-shims))
    (native-inputs
     (list ocaml-stdio
           ocaml-cinaps
           ocaml-base))
    (synopsis
     "Base library and tools for ppx rewriters")
    (description
     "A comprehensive toolbox for ppx development.  It features:
@itemize
@item an OCaml AST / parser / pretty-printer snapshot, to create a full frontend
independent of the version of OCaml;
@item a library for library for ppx rewriters in general, and type-driven code
generators in particular;
@item
a feature-full driver for OCaml AST transformers;
@item a quotation mechanism allowing to write values representing the
OCaml AST in the OCaml syntax;
@item a generator of open recursion classes from type definitions.
@end itemize")
    (license license:expat)))

(define-public ocaml-ppx-compare
  (package
    (name "ocaml-ppx-compare")
    (version "0.17.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/janestreet/ppx_compare")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "13g1g0f8z40yjiipwp07rsi6wp2mhq5hhdn0z5jq1l6sqvsw21dq"))))
    (build-system dune-build-system)
    (arguments
     `(#:tests? #f))  ; Tests require additional dependencies
    (propagated-inputs
     (list ocaml-base ocaml-ppxlib ocaml-ppxlib-jane))
    (properties `((upstream-name . "ppx_compare")))
    (home-page "https://github.com/janestreet/ppx_compare")
    (synopsis "Generation of comparison functions from types")
    (description "Generation of fast comparison functions from type expressions
and definitions.  Ppx_compare is a ppx rewriter that derives comparison functions
from type representations.  The scaffolded functions are usually much faster
than ocaml's Pervasives.compare.  Scaffolding functions also gives you more
flexibility by allowing you to override them for a specific type and more safety
by making sure that you only compare comparable values.")
    (license license:asl2.0)))

(define-public ocaml-fieldslib
  (package
    (name "ocaml-fieldslib")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/fieldslib")
    (source
     (github-tag-origin
      name home-page version
      "09ba8z37ipyhb3mmhgf1pq4icviyi677dljr9rc3d1m0ckgxryb5"
      "v"))
    (build-system dune-build-system)
    (arguments `(#:tests? #f)) ; No tests
    (propagated-inputs
     (list ocaml-base ocaml-ppxlib))
    (properties `((upstream-name . "fieldslib")))
    (synopsis "Syntax extension to record fields")
    (description "Syntax extension to define first class values representing
record fields, to get and set record fields, iterate and fold over all fields
of a record and create new record values.")
    (license license:asl2.0)))

(define-public ocaml-variantslib
  (package
    (name "ocaml-variantslib")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/variantslib")
    (source
     (github-tag-origin
      name home-page version
      "1prfwpmj544lvsx5sgxc3l690y8f09imlyxk0xn52hnfqgbppymz"
      "v"))
    (build-system dune-build-system)
    (arguments
     ;; No tests
     `(#:tests? #f))
    (propagated-inputs
     (list ocaml-base ocaml-ppxlib))
    (properties `((upstream-name . "variantslib")))
    (synopsis "OCaml variants as first class values")
    (description "The Core suite of libraries is an alternative to OCaml's
standard library.")
    (license license:asl2.0)))

(define-public ocaml-ppx-fields-conv
  (package
    (name "ocaml-ppx-fields-conv")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/ppx_fields_conv")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0d1lxqwxyqf3fgg48jpl6fzczllwhq3cyw65dsl9sc49187f23hl"
                ))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-base ocaml-fieldslib ocaml-ppxlib))
    (properties `((upstream-name . "ppx_fields_conv")))
    (synopsis "Generation of accessor and iteration functions for ocaml records")
    (description "Ppx_fields_conv is a ppx rewriter that can be used to define
first class values representing record fields, and additional routines, to get
and set record fields, iterate and fold over all fields of a record and create
new record values.")
    (license license:asl2.0)))

(define-public ocaml-ppx-sexp-conv
  (package
    (name "ocaml-ppx-sexp-conv")
    (version "0.17.1")
    (home-page "https://github.com/janestreet/ppx_sexp_conv")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0b6nkxz7mwfvgfmpcvd3gha6rkdr24c79wiz42030jyd1yw6a0n9"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-base ocaml-ppxlib ocaml-ppxlib-jane))
    (properties `((upstream-name . "ppx_sexp_conv")))
    (synopsis "generation of s-expression conversion functions from type definitions")
    (description "this package generates s-expression conversion functions from type
definitions.")
    (license license:asl2.0)))

(define-public ocaml-ppx-variants-conv
  (package
    (name "ocaml-ppx-variants-conv")
    (version "0.17.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/janestreet/ppx_variants_conv")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1xbml7df11n0fswlp1n12v6irqyd49d3wqbsbcz37b5vvdg6rzz2"
         ))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-base ocaml-variantslib ocaml-ppxlib))
    (properties
     `((upstream-name . "ppx_variants_conv")))
    (home-page
     "https://github.com/janestreet/ppx_variants_conv")
    (synopsis "Generation of accessor and iteration functions for OCaml variant types")
    (description
     "This package generates accessors and iteration functions for OCaml
variant types.")
    (license license:asl2.0)))

(define-public ocaml-ppx-custom-printf
  (package
    (name "ocaml-ppx-custom-printf")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/ppx_custom_printf")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "17kaghmdfsmwh0br0m7v9b31lcfk1psq034ajnh2l508sdph6n0c"
         ))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-base ocaml-ppx-sexp-conv ocaml-ppxlib))
    (properties `((upstream-name . "ppx_custom_printf")))
    (synopsis "Printf-style format-strings for user-defined string conversion")
    (description "Extensions to printf-style format-strings for user-defined
string conversion.")
    (license license:asl2.0)))

(define-public ocaml-ppx-stable-witness
  (package
    (name "ocaml-ppx-stable-witness")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_stable_witness")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "07af14w3xh9vy57gh31nrxaq9pg753jhlx4fwwi1ngccyd3nx3lk"
          ))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-base ocaml-ppxlib))
    (properties `((upstream-name . "ppx_stable_witness")))
    (home-page "https://github.com/janestreet/ppx_stable_witness")
    (synopsis "Mark a type as stable across versions")
    (description "This ppx extension is used for deriving a witness that a
type is intended to be stable.  In this context, stable means that the
serialization format will never change.  This allows programs running at
different versions of the code to safely communicate.")
    (license license:expat)))

(define-public ocaml-bin-prot
  (package
    (name "ocaml-bin-prot")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/bin_prot")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "1f3a2a3fwiy2c8cydza9nkjry979dh58j2zk2g6qiybf4zq8l1z5"
          ))))
    (build-system dune-build-system)
    (propagated-inputs
      (list ocaml-base
            ocaml-ppx-compare
            ocaml-ppx-custom-printf
            ocaml-ppx-fields-conv
            ocaml-ppx-optcomp
            ocaml-ppx-sexp-conv
            ocaml-ppx-stable-witness
            ocaml-ppx-variants-conv))
    (properties `((upstream-name . "bin_prot")))
    (home-page "https://github.com/janestreet/bin_prot")
    (synopsis "Binary protocol generator")
    (description "This library contains functionality for reading and writing
OCaml-values in a type-safe binary protocol.  It is extremely efficient,
typically supporting type-safe marshalling and unmarshalling of even highly
structured values at speeds sufficient to saturate a gigabit connection.  The
protocol is also heavily optimized for size, making it ideal for long-term
storage of large amounts of data.")
    (license license:expat)))

(define-public ocaml-protocol-version-header
  (package
    (name "ocaml-protocol-version-header")
    (version "0.17.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url
                     "https://github.com/janestreet/protocol_version_header")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1pkj6b2hhvbqs4dbjchdb214bwk1qlxnzibgyfl3x6k6m2yvib2q"
                ))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-core ocaml-ppx-jane))
    (properties `((upstream-name . "protocol_version_header")))
    (home-page "https://github.com/janestreet/protocol_version_header")
    (synopsis "Protocol versioning")
    (description
     "This library offers a lightweight way for applications protocols to
version themselves.  The more protocols that add themselves to
@code{Known_protocol}, the nicer error messages we will get when connecting to
a service while using the wrong protocol.")
    (license license:expat)))

(define-public ocaml-octavius
  (package
    (name "ocaml-octavius")
    (version "1.2.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/ocaml-doc/octavius")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1c5m51xcn2jv42kjjpklr6g63sgx1k885wfdp1yr4wrmiaj9cbpx"))))
    (build-system dune-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-before 'build 'make-writable
           (lambda _
             (for-each (lambda (file)
                         (chmod file #o644))
                       (find-files "." "."))
             #t)))))
    (properties `((upstream-name . "octavius")))
    (home-page "https://github.com/ocaml-doc/octavius")
    (synopsis "Ocamldoc comment syntax parser")
    (description "Octavius is a library to parse the `ocamldoc` comment syntax.")
    (license license:isc)))

(define-public ocaml-sha
  (package
    (name "ocaml-sha")
    (version "1.15.4")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/djs55/ocaml-sha/releases/download/"
                                  version "/sha-" version ".tbz"))
              (sha256
               (base32
                "1cgiy6y572rzhpr8ni4xgia2lv4865d8miscvzlrr6di74hv3rbd"))))
    (build-system dune-build-system)
    (native-inputs (list ocaml-ounit2))
    (home-page "https://github.com/djs55/ocaml-sha")
    (synopsis "OCaml binding to the SHA cryptographic functions")
    (description
     "This is the binding for SHA interface code in OCaml, offering the same
interface as the MD5 digest included in the OCaml standard library.  It
currently provides SHA1, SHA256 and SHA512 hash functions.")
    (license license:isc)))

(define-public ocaml-ppx-hash
  (package
    (name "ocaml-ppx-hash")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/ppx_hash")
    (source
     (github-tag-origin
      name home-page version
      "0zxb1n9zx4k44hilibdgasrq45y965ywx7h8pij3c6knh4pc400q"
      "v"))
    (build-system dune-build-system)
    (propagated-inputs
     (list
      ocaml-base ocaml-ppx-compare
      ocaml-ppx-sexp-conv
           ocaml-ppxlib))
    (properties `((upstream-name . "ppx_hash")))
    (synopsis "Generation of hash functions from type expressions and definitions")
    (description "This package is a collection of ppx rewriters that generate
hash functions from type exrpessions and definitions.")
    (license license:asl2.0)))

(define-public ocaml-ppx-enumerate
  (package
    (name "ocaml-ppx-enumerate")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/ppx_enumerate")
    (source
     (github-tag-origin
      name home-page version
      "1vkn3ii16974p68n97187wz062ksp9al3nmxy1jdsywzkp36p832"
      "v"))
    (build-system dune-build-system)
    (arguments
     `(#:tests? #f)) ; no test suite
    (propagated-inputs
     (list ocaml-base ocaml-ppxlib ocaml-ppxlib-jane))
    (properties `((upstream-name . "ppx_enumerate")))
    (synopsis "Generate a list containing all values of a finite type")
    (description "Ppx_enumerate is a ppx rewriter which generates a definition
for the list of all values of a type (for a type which only has finitely
many values).")
    (license license:asl2.0)))

(define-public ocaml-ppx-bench
  (package
    (name "ocaml-ppx-bench")
    (version "0.17.1")
    (build-system dune-build-system)
    (arguments
     ;; No tests
     `(#:tests? #f))
    (propagated-inputs (list ocaml-ppx-inline-test ocaml-ppxlib))
    (properties `((upstream-name . "ppx_bench")))
    (home-page "https://github.com/janestreet/ppx_bench")
    (synopsis "Syntax extension for writing in-line benchmarks in ocaml code")
    (description "Syntax extension for writing in-line benchmarks in ocaml code.")
    (source
     (github-tag-origin
      name home-page version
      "0npwvfg2rgwry645rck4vsfi7xim2pd5mgbb90x9z6br495rjylw"
      "v"
      ))
    (license license:expat)))

(define-public ocaml-ppx-here
  (package
    (name "ocaml-ppx-here")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/ppx_here")
    (source
     (github-tag-origin
      name home-page version
      "1hr6ymfkz5xhsciia8bi23mnlx94h4345njp9r7k9f1nzxr0xg69"
      "v"))
    (build-system dune-build-system)
    (arguments
     ;; broken tests
     `(#:tests? #f))
    (propagated-inputs
     (list ocaml-base ocaml-ppxlib))
    (properties `((upstream-name . "ppx_here")))
    (synopsis "Expands [%here] into its location")
    (description
      "Part of the Jane Street's PPX rewriters collection.")
    (license license:asl2.0)))

(define-public ocaml-typerep
  (package
    (name "ocaml-typerep")
    (version "0.17.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/typerep")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "0a9d55b13kg14k2nmmr26bkc11y6b4l6yqj0dq0d5iqbpix3f3c7"
          ))))
    (build-system dune-build-system)
    (arguments `(#:tests? #f)); no tests
    (propagated-inputs (list ocaml-base))
    (home-page "https://github.com/janestreet/typerep")
    (synopsis "Typerep is a library for runtime types")
    (description "Typerep is a library for runtime types.")
    (license license:expat)))

(define-public ocaml-ppx-sexp-value
  (package
    (name "ocaml-ppx-sexp-value")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_sexp_value")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1cpp6wmkdadpdlbh0imapzs0qjn5p9cd78y35b9wvyj8s4n87pkz"))))
    (build-system dune-build-system)
    (propagated-inputs
      (list ocaml-base ocaml-ppx-here ocaml-ppx-sexp-conv ocaml-ppxlib))
    (properties `((upstream-name . "ppx_sexp_value")))
    (home-page "https://github.com/janestreet/ppx_sexp_value")
    (synopsis "Simplify building s-expressions from ocaml values")
    (description "@samp{ppx-sexp-value} is a ppx rewriter that simplifies
building s-expressions from ocaml values.")
    (license license:expat)))

(define-public ocaml-ppx-sexp-message
  (package
    (name "ocaml-ppx-sexp-message")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_sexp_message")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1q2di8vb0145xnxxf0qvjdrkiq32724j2wksm3imr06lqjz17n28"))))
    (build-system dune-build-system)
    (propagated-inputs
      (list ocaml-base ocaml-ppx-here ocaml-ppx-sexp-conv ocaml-ppxlib))
    (properties `((upstream-name . "ppx_sexp_message")))
    (home-page "https://github.com/janestreet/ppx_sexp_message")
    (synopsis "Ppx rewriter for easy construction of s-expressions")
    (description "Ppx_sexp_message aims to ease the creation of s-expressions
in OCaml.  This is mainly motivated by writing error and debugging messages,
where one needs to construct a s-expression based on various element of the
context such as function arguments.")
    (license license:expat)))

(define-public ocaml-ppx-pipebang
  (package
    (name "ocaml-ppx-pipebang")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_pipebang")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "14yz95fzw8l4lkzmiphksnw73h8hhd3wk1slgn8971a26g7va5hq"))))
    (build-system dune-build-system)
    (arguments `(#:tests? #f)); no tests
    (propagated-inputs (list ocaml-ppxlib))
    (properties `((upstream-name . "ppx_pipebang")))
    (home-page "https://github.com/janestreet/ppx_pipebang")
    (synopsis "Inline reverse application operators `|>` and `|!`")
    (description "A ppx rewriter that inlines reverse application operators
@code{|>} and @code{|!}.")
    (license license:expat)))

(define-public ocaml-ppx-module-timer
  (package
    (name "ocaml-ppx-module-timer")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_module_timer")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1wic880klh1bpy43jp5gh3hvw3a3znn9alvryhj1n0s97wi3asir"))))
    (build-system dune-build-system)
    (arguments
     `(#:tests? #f)); no tests
    (propagated-inputs
      (list ocaml-base ocaml-ppx-base ocaml-stdio ocaml-time-now ocaml-ppxlib))
    (properties `((upstream-name . "ppx_module_timer")))
    (home-page "https://github.com/janestreet/ppx_module_timer")
    (synopsis "Ppx rewriter that records top-level module startup times")
    (description "Modules using @samp{ppx_module_timer} have instrumentation
to record their startup time.")
    (license license:expat)))

(define-public ocaml-ppx-fixed-literal
  (package
    (name "ocaml-ppx-fixed-literal")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_fixed_literal")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1iffidvi815nkyfyf5999h5gj45f5cvz81vsf2dyxzshysv9pbsy"))))
    (build-system dune-build-system)
    (arguments
     `(#:tests? #f)); no tests
    (propagated-inputs (list ocaml-base ocaml-ppxlib))
    (properties `((upstream-name . "ppx_fixed_literal")))
    (home-page "https://github.com/janestreet/ppx_fixed_literal")
    (synopsis "Simpler notation for fixed point literals")
    (description
      "@samp{ppx-fixed-literal} is a ppx rewriter that rewrites fixed point
literal of the  form 1.0v to conversion functions currently in scope.")
    (license license:expat)))

(define-public ocaml-ppx-optional
  (package
    (name "ocaml-ppx-optional")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/ppx_optional")
    (source
     (github-tag-origin
      name home-page version
      "00gprmppf1w875r4r3bq9hfx333rarsnyxk1rmym66x53v73cz28"
      "v"))
    (build-system dune-build-system)
    (arguments `(#:tests? #f)) ; No tests
    (propagated-inputs
     (list ocaml-base ocaml-ppxlib ocaml-ppxlib-jane))
    (properties `((upstream-name . "ppx_optional")))
    (synopsis "Pattern matching on flat options")
    (description
      "A ppx rewriter that rewrites simple match statements with an if then
else expression.")
    (license license:asl2.0)))

(define-public ocaml-ppx-optcomp
  (package
    (name "ocaml-ppx-optcomp")
    (version "0.17.1")
    (home-page "https://github.com/janestreet/ppx_optcomp")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0z7nmjyd7qjyvap97cxqbxs8y28pjf0xk1ai4cncx4c68lrmhbws"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-base ocaml-stdio ocaml-ppxlib))
    (properties `((upstream-name . "ppx_optcomp")))
    (synopsis "Optional compilation for OCaml")
    (description "Ppx_optcomp stands for Optional Compilation.  It is a tool
used to handle optional compilations of pieces of code depending of the word
size, the version of the compiler, ...")
    (license license:asl2.0)))

(define-public ocaml-ppx-let
  (package
    (name "ocaml-ppx-let")
    (version "0.17.1")
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-base ocaml-ppxlib ocaml-ppx-here))
    (properties `((upstream-name . "ppx_let")))
    (home-page "https://github.com/janestreet/ppx_let")
    (synopsis "Monadic let-bindings")
    (description "A ppx rewriter for monadic and applicative let bindings,
match expressions, and if expressions.")
    (source
     (github-tag-origin
      name home-page version
      "0q84b60y8v6yf7xpkpz3d2g8yyzbw2d3x037ndcl990c8z8vll73"
      "v"
      ))
    (license license:asl2.0)))

(define-public ocaml-ppx-fail
  (package
    (name "ocaml-ppx-fail")
    (version "0.14.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_fail")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "012p9gv7w4sk3b4x0sdmqrmr2856w8xc424waxb6vrybid7qjs95"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-base ocaml-ppx-here ocaml-ppxlib))
    (properties `((upstream-name . "ppx_fail")))
    (home-page "https://github.com/janestreet/ppx_fail")
    (synopsis "Add location to calls to failwiths")
    (description "Syntax extension that makes [failwiths] always include a
position.")
    (license license:expat)))

(define-public ocaml-ppx-cold
  (package
    (name "ocaml-ppx-cold")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/ppx_cold")
    (source
     (github-tag-origin
      name home-page version
      "1l0gg8dyjawb71nz6w4r3svi0jbjk0qlmw9r3bzb0jylqsanlmkw"
      "v"))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-base ocaml-ppxlib))
    (properties `((upstream-name . "ppx_cold")))
    (synopsis "Syntax extension for indicating cold path")
    (description
     "This package contains an syntax extension to indicate that the code is
on the cold path and should be kept out of the way to avoid polluting the
instruction cache on the hot path.  See also
https://github.com/ocaml/ocaml/issues/8563.")
    (license license:expat)))

(define-public ocaml-ppx-assert
  (package
    (name "ocaml-ppx-assert")
    (version "0.17.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/janestreet/ppx_assert")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1h0gynscd3d9vdx1rf6cf281cn8sw3gxp6z5vl4smypsa5sb1p53"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-base
           ocaml-ppx-cold
           ocaml-ppx-compare
           ocaml-ppx-here
           ocaml-ppx-sexp-conv
           ocaml-ppxlib))
    (properties `((upstream-name . "ppx_assert")))
    (home-page "https://github.com/janestreet/ppx_assert")
    (synopsis "Assert-like extension nodes that raise useful errors on failure")
    (description "This package contains assert-like extension nodes that raise
useful errors on failure.")
    (license license:asl2.0)))

(define-public ocaml-ppx-expect
  (package
    (name "ocaml-ppx-expect")
    (version "0.17.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/janestreet/ppx_expect")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1knjg29hawci3hicv3wn2hlws88xn8rgbywqwrspg32qf6kpg1kr"))))
    (build-system dune-build-system)
    (arguments
     ;; Cyclic dependency with ocaml-ppx-jane
     `(#:tests? #f))
    (propagated-inputs
     (list ocaml-base
           ocaml-ppx-here
           ocaml-ppx-inline-test
           ocaml-stdio
           ocaml-ppxlib
           ocaml-re))
    (properties `((upstream-name . "ppx_expect")))
    (home-page "https://github.com/janestreet/ppx_expect")
    (synopsis "Cram like framework for OCaml")
    (description "Expect-test is a framework for writing tests in OCaml, similar
to Cram.  Expect-tests mimics the existing inline tests framework with the
@code{let%expect_test} construct.  The body of an expect-test can contain
output-generating code, interleaved with @code{%expect} extension expressions
to denote the expected output.")
    (license license:asl2.0)))

(define-public ocaml5.0-ppx-expect
  ;; Contains fixes for OCaml 5.0
  ;; (https://github.com/janestreet/ppx_expect/pull/39/).
  (let ((commit "83edfc1ee779e8dcdd975e26715c2e688326befa")
        (revision "0"))
    (package-with-ocaml5.0
     (package
       (inherit ocaml-ppx-expect)
       (name "ocaml-ppx-expect")
       (version (git-version "0.17.0" revision commit))
       (source
        (origin
          (method git-fetch)
          (uri (git-reference
                (url "https://github.com/janestreet/ppx_expect")
                (commit commit)))
          (file-name (git-file-name name version))
          (sha256
           (base32
            "05r7wlmrhb5biwyw6bjcpmr77srglijcbf7nm7h2hiil0d0i7bkz"))))
       (properties '())))))

(define-public ocaml-ppx-js-style
  (package
    (name "ocaml-ppx-js-style")
    (version "0.17.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/janestreet/ppx_js_style")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "13hkdvb92c9ll3mq7mvksj8pndbxhmyhghlpwk9rcm8nmziqcqb0"))))
    (build-system dune-build-system)
    (arguments `(#:tests? #f)) ; No tests
    (propagated-inputs
     (list ocaml-base ocaml-octavius ocaml-ppxlib))
    (properties `((upstream-name . "ppx_js_style")))
    (home-page "https://github.com/janestreet/ppx_js_style")
    (synopsis "Code style checker for Jane Street Packages")
    (description "This package is a no-op ppx rewriter.  It is used as a
@code{lint} tool to enforce some coding conventions across all Jane Street
packages.")
    (license license:asl2.0)))

(define-public ocaml-ppx-typerep-conv
  (package
    (name "ocaml-ppx-typerep-conv")
    (version "0.17.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/janestreet/ppx_typerep_conv/")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "05vqvpjzx34427qsnqmrcgs6d2688i14m50268xkgakgzvd8n6mg"
                 ))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-base ocaml-typerep ocaml-ppxlib))
    (properties `((upstream-name . "ppx_typerep_conv")))
    (home-page "https://github.com/janestreet/ppx_typerep_conv")
    (synopsis "Generation of runtime types from type declarations")
    (description "This package can automatically generate runtime types
from type definitions.")
    (license license:expat)))

(define-public ocaml-ppx-string
  (package
    (name "ocaml-ppx-string")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_string")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "001f92jh2jf3fp46j9hhkln6mlri11zpz1c811wz83ixmcjjz85m"))))
    (build-system dune-build-system)
    (arguments `(#:tests? #f)); no tests
    (propagated-inputs
      (list ocaml-base ocaml-ppx-base ocaml-stdio ocaml-ppxlib))
    (properties `((upstream-name . "ppx_string")))
    (home-page "https://github.com/janestreet/ppx_string")
    (synopsis "Ppx extension for string interpolation")
    (description "This extension provides a syntax for string interpolation.")
    (license license:expat)))

(define-public ocaml-ppx-stable
  (package
    (name "ocaml-ppx-stable")
    (version "0.17.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/janestreet/ppx_stable")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1q9j217dfpshyb9r1is851w8rj30zs6g24z5ivdbqx4fai2j0l49"
         ))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-base ocaml-ppxlib))
    (properties `((upstream-name . "ppx_stable")))
    (home-page "https://github.com/janestreet/ppx_stable")
    (synopsis "Stable types conversions generator")
    (description "This package is a ppx extension for easier implementation of
conversion functions between almost identical types.")
    (license license:expat)))

(define-public ocaml-ppx-base
  (package
    (name "ocaml-ppx-base")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/ppx_base")
    (source
     (github-tag-origin
      name home-page version
      "14lvhy842fjjm2qwqhxkqig4mc5s439rbkd87mlys86byzrdrkpy"
      "v"))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-ppx-compare
           ocaml-ppx-cold
           ocaml-ppx-enumerate
           ocaml-ppx-hash
           ocaml-ppx-globalize
           ocaml-ppx-js-style
           ocaml-ppx-sexp-conv
           ocaml-ppxlib))
    (properties `((upstream-name . "ppx_base")))
    (synopsis "Base set of ppx rewriters")
    (description "Ppx_base is the set of ppx rewriters used for Base.

Note that Base doesn't need ppx to build, it is only used as a
verification tool.")
    (license license:asl2.0)))

(define-public ocaml-ppx-bin-prot
  (package
    (name "ocaml-ppx-bin-prot")
    (version "0.17.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_bin_prot")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "03pf85zs4mabcs56gf3ib70ldz9rxlz4bfygcr6348cy113nsczm"
                 ))))
    (build-system dune-build-system)
    (arguments
     ;; Cyclic dependency with ocaml-ppx-jane
     `(#:tests? #f))
    (propagated-inputs
      (list ocaml-base ocaml-bin-prot ocaml-ppx-here ocaml-ppxlib))
    (properties `((upstream-name . "ppx_bin_prot")))
    (home-page "https://github.com/janestreet/ppx_bin_prot")
    (synopsis "Generation of bin_prot readers and writers from types")
    (description "Generation of binary serialization and deserialization
functions from type definitions.")
    (license license:expat)))

(define-public ocaml-ppx-ignore-instrumentation
  (package
    (name "ocaml-ppx-ignore-instrumentation")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_ignore_instrumentation")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1v2prvv8s20xfc91jc0gwn0z2n7cragsfdd0cysb7c4zfbqnjxzg"))))
    (build-system dune-build-system)
    (arguments
     `(#:tests? #f)) ;no tests
    (propagated-inputs (list ocaml-ppxlib))
    (properties `((upstream-name . "ppx_ignore_instrumentation")))
    (home-page "https://github.com/janestreet/ppx_ignore_instrumentation")
    (synopsis "Ignore Jane Street specific instrumentation extensions")
    (description
      "Ignore Jane Street specific instrumentation extensions from internal
PPXs or compiler features not yet upstreamed.")
    (license license:expat)))

(define-public ocaml-ppx-log
  (package
    (name "ocaml-ppx-log")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_log")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "13hcsjx13yma4215fk4nc52vf0vpf6s2186pb8wyiqa7w9cy6ncn"))))
    (build-system dune-build-system)
    (propagated-inputs
      (list ocaml-base
            ocaml-ppx-compare
            ocaml-stdio
            ocaml-ppx-sexp-value
            ocaml-ppx-here
            ocaml-ppx-sexp-conv
            ocaml-ppx-sexp-message
            ocaml-ppx-enumerate
            ocaml-ppx-variants-conv
            ocaml-ppx-string
            ocaml-ppx-expect
            ocaml-ppx-fields-conv
            ocaml-ppx-let
            ocaml-sexplib
            ocaml-ppxlib))
    (properties `((upstream-name . "ppx_log")))
    (arguments
     `(#:tests? #f)) ;no tests
    (home-page "https://github.com/janestreet/ppx_log")
    (synopsis "Extension nodes for lazily rendering log messages")
    (description "This package provides ppx_sexp_message-like extension
nodes for lazily rendering log messages.")
    (license license:expat)))

(define-public ocaml-ppx-disable-unused-warnings
  (package
    (name "ocaml-ppx-disable-unused-warnings")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_disable_unused_warnings")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0rcnknb6547n9z5akb05diklkzd71yfrgz5p12qlxynlynwqhx98"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-base ocaml-ppxlib))
    (properties `((upstream-name . "ppx_disable_unused_warnings")))
    (home-page "https://github.com/janestreet/ppx_disable_unused_warnings")
    (synopsis "Simple ppx extension for commonly unused warnings")
    (description "This package expands @code{@@disable_unused_warnings} into
@code{@@warning \"-20-26-32-33-34-35-36-37-38-39-60-66-67\"}")
    (license license:expat)))

(define-public ocaml-ppx-jane
  (package
    (name "ocaml-ppx-jane")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_jane")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "1jym28vadcyc32vw0kmn1cw4lrsis8w25fk8f03mv4c9p1pjh0hy"
          ))))
    (build-system dune-build-system)
    (propagated-inputs
      (list ocaml-base-quickcheck
            ocaml-ppx-assert
            ocaml-ppx-base
            ocaml-ppx-tydi
            ocaml-ppx-string-conv
            ocaml-ppx-bench
            ocaml-ppx-bin-prot
            ocaml-ppx-custom-printf
            ocaml-ppx-disable-unused-warnings
            ocaml-ppx-expect
            ocaml-ppx-fields-conv
            ocaml-ppx-fixed-literal
            ocaml-ppx-here
            ocaml-ppx-ignore-instrumentation
            ocaml-ppx-inline-test
            ocaml-ppx-let
            ocaml-ppx-log
            ocaml-ppx-module-timer
            ocaml-ppx-optcomp
            ocaml-ppx-optional
            ocaml-ppx-pipebang
            ocaml-ppx-sexp-message
            ocaml-ppx-sexp-value
            ocaml-ppx-stable
            ocaml-ppx-string
            ocaml-ppx-typerep-conv
            ocaml-ppx-variants-conv
            ocaml-ppxlib))
    (properties `((upstream-name . "ppx_jane")))
    (home-page "https://github.com/janestreet/ppx_jane")
    (synopsis "Standard Jane Street ppx rewriters")
    (description "This package installs a ppx-jane executable, which is a ppx
driver including all standard Jane Street ppx rewriters.")
    (license license:expat)))

(define-public ocaml-ppxlib-jane
  (package
    (name "ocaml-ppxlib-jane")
    (version "0.17.4")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppxlib_jane")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1vc0hi73b3hsfkrl83jgz777hz4whyb0z4y4qr8ynvif7mlpp8bj"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list
      ;; ocaml-base-quickcheck
            ;; ocaml-ppx-assert
            ;; ocaml-ppx-base
            ;; ocaml-ppx-bench
            ;; ocaml-ppx-bin-prot
            ;; ocaml-ppx-custom-printf
            ;; ocaml-ppx-disable-unused-warnings
            ;; ocaml-ppx-expect
            ;; ocaml-ppx-fields-conv
            ;; ocaml-ppx-fixed-literal
            ;; ocaml-ppx-here
            ;; ocaml-ppx-ignore-instrumentation
            ;; ocaml-ppx-inline-test
            ;; ocaml-ppx-let
            ;; ocaml-ppx-log
            ;; ocaml-ppx-module-timer
            ;; ocaml-ppx-optcomp
            ;; ocaml-ppx-optional
            ;; ocaml-ppx-pipebang
            ;; ocaml-ppx-sexp-message
            ;; ocaml-ppx-sexp-value
            ;; ocaml-ppx-stable
            ;; ocaml-ppx-string
            ;; ocaml-ppx-typerep-conv
            ;; ocaml-ppx-variants-conv
            ocaml-ppxlib))
    (properties `((upstream-name . "ppxlib_jane")))
    (home-page "https://github.com/janestreet/ppxlib_jane")
    (synopsis "Standard Jane Street ppx rewriters")
    (description "This package installs a ppx-jane executable, which is a ppx
driver including all standard Jane Street ppx rewriters.")
    (license license:expat)))

(define-public ocaml-base-bigstring
  (package
    (name "ocaml-base-bigstring")
    (version "0.17.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/janestreet/base_bigstring")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1qb02dzc7zhdmhzcw735is6hq8mbbfdw2y626srl3mwlaf8ysq5l"
         ))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-base ocaml-int-repr ocaml-ppx-jane))
    (properties `((upstream-name . "base_bigstring")))
    (home-page "https://github.com/janestreet/base_bigstring")
    (synopsis "String type based on [Bigarray], for use in I/O and C-bindings")
    (description "This package provides string type based on [Bigarray], for
use in I/O and C-bindings.")
    (license license:expat)))

(define-public ocaml-splittable-random
  (package
    (name "ocaml-splittable-random")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/splittable_random")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "0q25b8cq94n09dby97rv1qqmlymsczr9yabvvxf1c63vpp284mif"
          ))))
    (build-system dune-build-system)
    (propagated-inputs
      (list ocaml-base
            ocaml-ppx-assert
            ocaml-ppx-bench
            ocaml-ppx-inline-test
            ocaml-ppx-sexp-message))
    (properties `((upstream-name . "splittable_random")))
    (home-page "https://github.com/janestreet/splittable_random")
    (synopsis "PRNG that can be split into independent streams")
    (description "This package provides a splittable
@acronym{PRNG,pseudo-random number generator} functions like a PRNG that can
be used as a stream of random values; it can also be split to produce a
second, independent stream of random values.

This library implements a splittable pseudo-random number generator that sacrifices
cryptographic-quality randomness in favor of performance.")
    (license license:expat)))

(define-public ocaml-base-quickcheck
  (package
    (name "ocaml-base-quickcheck")
    (version "0.17.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/base_quickcheck")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1sa3adxp9milapmm6vbm0p4mn64mqwmjbfghisagc5mndfq39knj"))))
    (build-system dune-build-system)
    (propagated-inputs
      (list ocaml-base
            ocaml-ppx-base
            ocaml-ppx-fields-conv
            ocaml-ppx-let
            ocaml-ppx-sexp-message
            ocaml-ppx-sexp-value
            ocaml-splittable-random
            ocaml-ppxlib))
    (properties `((upstream-name . "base_quickcheck")))
    (home-page "https://github.com/janestreet/base_quickcheck")
    (synopsis
      "Randomized testing framework, designed for compatibility with Base")
    (description
      "@samp{base-quickcheck} provides randomized testing in the style of
Haskell's Quickcheck library, with support for built-in types as well as
types provided by Base.")
    (license license:expat)))

(define-public ocaml-gel
  (package
    (name "ocaml-gel")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/gel")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "0j614lb2blb2zn8pqx51jx19pwhd8vv8ki3fm3sp0da8nb2yaq6c"
          ))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-base ocaml-ppx-jane))
    (home-page "https://github.com/janestreet/ppx_diff")
    (synopsis
      "A library to mark non-record fields global")
    (description "")
    (license license:expat)
    ))

(define-public ocaml-ppx-diff
  (package
    (name "ocaml-ppx-diff")
    (version "0.17.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/ppx_diff")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "07lypj65xhnxyx4ymf6skh68kndzvwpgnfb4rxhwqdg3hc8fav3r"
          ))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-ppx-enumerate ocaml-ppx-compare ocaml-ppx-jane ocaml-gel
            ))
    (home-page "https://github.com/janestreet/ppx_diff")
    (synopsis
      "ppx for ldiffable")
    (description "Generation of diffs and update functions for ocaml types.

ppx_diff is a ppx rewriter that generates the implementation of [Diffable.S]. The [Diff.t] type represents differences between two values. The [Diff.get] and [Diff.apply_exn] functions compute and apply the differences."
      )
    (license license:expat)))

(define-public ocaml-spawn
  (package
    (name "ocaml-spawn")
    (version "0.17.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/janestreet/spawn")
                     (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0wxp4yl8hjw1g68j6gii84agd3n31gcc99nrfxbnrfxrn4nic510"
                ))))
    (build-system dune-build-system)
    (native-inputs (list ocaml-ppx-expect))
    (home-page "https://github.com/janestreet/spawn")
    (synopsis "Spawning sub-processes")
    (description
      "Spawn is a small library exposing only one functionality: spawning sub-process.

It has three main goals:

@itemize
@item provide missing features of Unix.create_process such as providing a
working directory,
@item provide better errors when a system call fails in the
sub-process.  For instance if a command is not found, you get a proper
@code{Unix.Unix_error} exception,
@item improve performances by using vfork when available.  It is often
claimed that nowadays fork is as fast as vfork, however in practice
fork takes time proportional to the process memory while vfork is
constant time.  In application using a lot of memory, vfork can be
thousands of times faster than fork.
@end itemize")
    (license license:asl2.0)))

(define-public ocaml-core
  (package
    (name "ocaml-core")
    (version "0.17.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/core")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32
          "1m1nkpd412skknd3lj2gr74v0p3rz7xbsrk2kpar4m15z1r02h2y"
          ))))
    (build-system dune-build-system)
    (arguments
     `(#:package "core"
       #:tests? #f)); Require a cyclic dependency: core_extended
    (propagated-inputs
      (list ocaml-base
            ocaml-base-bigstring
            ocaml-base-quickcheck
            ocaml-bin-prot
            ocaml-fieldslib
            ocaml-jane-street-headers
            ocaml-jst-config
            ocaml-ppx-assert
            ocaml-ppx-base
            ocaml-ppx-diff
            ocaml-ppx-hash
            ocaml-ppx-inline-test
            ocaml-ppx-jane
            ocaml-ppx-sexp-conv
            ocaml-ppx-sexp-message
            ocaml-sexplib
            ocaml-splittable-random
            ocaml-stdio
            ocaml-time-now
            ocaml-typerep
            ocaml-variantslib))
    (home-page "https://github.com/janestreet/core")
    (synopsis "Alternative to OCaml's standard library")
    (description "The Core suite of libraries is an alternative to OCaml's
standard library that was developed by Jane Street.")
    ;; Also contains parts of OCaml, relicensed to expat, as permitted
    ;; by OCaml's license for consortium members (see THIRD-PARTY.txt).
    (license license:expat)))

(define-public ocaml-uopt
  (package
    (name "ocaml-uopt")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/uopt")
    (source
     (github-tag-origin
      name home-page version
      "1hxdm39g9922ngvr29vs2y2jdsq8k29hbqhc2y2wqjbla4jqai5p"
      "v"))
    (build-system dune-build-system)
    (properties `((upstream-name . "uopt")))
    (propagated-inputs (list ocaml-ppx-jane))
    (synopsis "An [option]-like type that incurs no allocation, without requiring a reserved value in the underlying type ")
    (description "An [option]-like type that incurs no allocation, without requiring a reserved value in the underlying type")
    (license license:expat)))

(define-public ocaml-async-log
  (package
    (name "ocaml-async-log")
    (version "0.17.0")
    (home-page "https://github.com/janestreet/async_log")
    (source
     (github-tag-origin
      name home-page version
      "0l76v6mffny7s2hwd4gs275a3iawsv9arjs0vhmqm7xlh3g85rax"
      "v"))
    (build-system dune-build-system)
    (properties `((upstream-name . "uopt")))
    (propagated-inputs (list ocaml-async-unix ocaml-core ocaml-core-kernel
                             ocaml-ppx-jane ocaml-timezone))
    (synopsis "Logging library built on top of Async_unix ")
    (description "Logging library built on top of Async_unix")
    (license license:expat)))

(define-public ocaml-core-kernel
  (package
    (name "ocaml-core-kernel")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/core_kernel")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1nrj8amx76cdgak6j4i9pabnq7hg1hhiw0c3l7mp8d02smwk9dcp"))))
    (build-system dune-build-system)
    (arguments
     ;; Cyclic dependency with ocaml-core
     `(#:tests? #f))
    (propagated-inputs
      (list ocaml-base ocaml-core ocaml-int-repr ocaml-ppx-jane ocaml-uopt))
    (properties `((upstream-name . "core_kernel")))
    (home-page "https://github.com/janestreet/core_kernel")
    (synopsis "Portable standard library for OCaml")
    (description "Core is an alternative to the OCaml standard library.

Core_kernel is the system-independent part of Core.  It is aimed for cases when
the full Core is not available, such as in Javascript.")
    (license license:expat)))

(define-public ocaml-core-unix
  (package
    (name "ocaml-core-unix")
    (version "0.17.1")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/janestreet/core_unix")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "198jzjln8i1p74xw3c284kc0wmh4qy917z3xwv8pq1n1lidh36n4"
                ))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-core
                             ocaml-core-kernel
                             ocaml-expect-test-helpers-core
                             ocaml-jane-street-headers
                             ocaml-jst-config
                             ocaml-intrinsics
                             ocaml-ppx-jane
                             ocaml-sexplib
                             ocaml-timezone
                             ocaml-spawn))
    (properties `((upstream-name . "core_unix")))
    (home-page "https://github.com/janestreet/core_unix")
    (synopsis "Unix-specific portions of Core")
    (description
     "Unix-specific extensions to some of the modules defined in core and
core_kernel.")
    (arguments
     `(#:tests? #f))
    (license license:expat)))

(define-public ocaml-async-kernel
  (package
    (name "ocaml-async-kernel")
    (version "0.17.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/janestreet/async_kernel")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1zlpppywmzwvszgdc077fgsplv3b6vx0nbrnm70pj94f8znfhikw"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-core ocaml-core-kernel ocaml-ppx-jane))
    (properties `((upstream-name . "async_kernel")))
    (home-page "https://github.com/janestreet/async_kernel")
    (synopsis "Monadic concurrency library")
    (description
     "Contains @code{Async}'s core data structures, like
@code{Deferred}.  @code{Async_kernel} is portable, and so can be used in
JavaScript using @code{Async_js}.")
    (license license:expat)))

(define-public ocaml-async-unix
  (package
    (name "ocaml-async-unix")
    (version "0.17.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/janestreet/async_unix")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1905v8bpwr6dqyawky71ia5x31sj8qxx4yn69i6gnyyd17j5w3bw"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-async-kernel ocaml-core ocaml-core-kernel
                             ocaml-core-unix ocaml-ppx-jane ocaml-cstruct))
    (properties `((upstream-name . "async_unix")))
    (home-page "https://github.com/janestreet/async_unix")
    (synopsis "Monadic concurrency library")
    (description
     "Unix-related dependencies for things like system calls and
threads.  Using these, it hooks the Async_kernel scheduler up to either epoll
or select, depending on availability, and manages a thread pool that blocking
system calls run in.")
    (license license:expat)))

(define-public ocaml-async-rpc-kernel
  (package
    (name "ocaml-async-rpc-kernel")
    (version "0.17.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/janestreet/async_rpc_kernel")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0w7qmf7sp0cnylx76s9x2zri8d2j66l253bqym96igcv1i3acand"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-async-kernel ocaml-core ocaml-ppx-jane
                             ocaml-protocol-version-header))
    (properties `((upstream-name . "async_rpc_kernel")))
    (home-page "https://github.com/janestreet/async_rpc_kernel")
    (synopsis "Platform-independent core of Async RPC library")
    (description
     "Library for building RPC-style protocols.  This library is the portable
part of the Unix-oriented Async_rpc library, and is actively used in
JavaScript.")
    (license license:expat)))

(define-public ocaml-async
  (package
    (name "ocaml-async")
    (version "0.17.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/janestreet/async")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32 "058lxypv3c9nsqaminrbahkx5axwb43kfrnplrm74r25kcgly10b"
                       ))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-async-kernel
                             ocaml-async-rpc-kernel
                             ocaml-async-unix
                             ocaml-async-log
                             ocaml-core
                             ocaml-core-kernel
                             ocaml-core-unix
                             ocaml-ppx-jane
                             ocaml-ppx-log
                             ocaml-textutils))
    ;; TODO one test dependency is deprecated, the other is nowhere to be found
    (arguments
     '(#:tests? #f))
    ;; (native-inputs (list ocaml-netkit-sockets ocaml-qtest-deprecated))
    (home-page "https://github.com/janestreet/async")
    (synopsis "Asynchronous execution library")
    (description
     "Library for asynchronous programming, i.e., programming where some part
of the program must wait for things that happen at times determined by some
external entity (like a human or another program).")
    (license license:expat)))

(define-public ocaml-textutils-kernel
  (package
    (name "ocaml-textutils-kernel")
    (version "0.17.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/janestreet/textutils_kernel")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0al68g4spx6rn4is09v7f6hargd18raz0x4zah8hwjqildn33487"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-core ocaml-ppx-jane ocaml-uutf))
    (properties `((upstream-name . "textutils_kernel")))
    (home-page "https://github.com/janestreet/textutils_kernel")
    (synopsis "Text output utilities")
    (description
     "The subset of textutils using only core_kernel and working in
javascript.")
    (license license:expat)))

(define-public ocaml-textutils
  (package
    (name "ocaml-textutils")
    (version "0.17.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/janestreet/textutils")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "000jxpfpczjr5pm3gf77kg8h488b9f1fmirrrb4iv4szkym2r7r7"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-core
                             ocaml-core-kernel
                             ocaml-core-unix
                             ocaml-ppx-jane
                             ocaml-textutils-kernel
                             ocaml-uutf))
    (home-page "https://github.com/janestreet/textutils")
    (synopsis "Text output utilities")
    (description
     "Utilities for working with terminal output, such as color printing.")
    (license license:expat)))

(define-public ocaml-timezone
  (package
    (name "ocaml-timezone")
    (version "0.17.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/janestreet/timezone")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0wf5apsln4clxxndzavxpcwh7zpaf8sf6xnj9jah9jg4r9c8p8zz"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-core ocaml-ppx-jane))
    (home-page "https://github.com/janestreet/timezone")
    (synopsis "Time-zone handling")
    (description
      "Timezone handles parsing timezone data and create @code{Timezone.t}
that can later be used to manipulate time in core_kernel or core.")
    (license license:expat)))

(define-public ocaml-markup
  (package
    (name "ocaml-markup")
    (version "1.0.3")
    (home-page "https://github.com/aantron/markup.ml")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url (string-append home-page ".git"))
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1acgcbhx4rxx92rf65lsns588d6zzfrin2pnpkx24jw5vbgz7idn"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "markup"))
    (propagated-inputs
     (list ocaml-uchar ocaml-uutf ocaml-lwt))
    (native-inputs
     (list ocaml-ounit2 pkg-config))
    (synopsis "Error-recovering functional HTML5 and XML parsers and writers")
    (description "Markup.ml provides an HTML parser and an XML parser.  The
parsers are wrapped in a simple interface: they are functions that transform
byte streams to parsing signal streams.  Streams can be manipulated in various
ways, such as processing by fold, filter, and map, assembly into DOM tree
structures, or serialization back to HTML or XML.

Both parsers are based on their respective standards.  The HTML parser, in
particular, is based on the state machines defined in HTML5.

The parsers are error-recovering by default, and accept fragments.  This makes
it very easy to get a best-effort parse of some input.  The parsers can,
however, be easily configured to be strict, and to accept only full documents.

Apart from this, the parsers are streaming (do not build up a document in
memory), non-blocking (can be used with threading libraries), lazy (do not
consume input unless the signal stream is being read), and process the input in
a single pass.  They automatically detect the character encoding of the input
stream, and convert everything to UTF-8.")
    (license license:bsd-3)))

(define-public ocaml-tyxml
  (package
    (name "ocaml-tyxml")
    (version "4.6.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ocsigen/tyxml")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0mabl4q2vcv5b3b6myb49k99q69smyg0bhlm4ilz16n7yhlw0y2l"))))
    (build-system dune-build-system)
    (inputs
     (list ocaml-re ocaml-seq ocaml-uutf))
    (native-inputs
     (list ocaml-alcotest))
    (arguments `(#:package "tyxml"))
    (home-page "https://github.com/ocsigen/tyxml/")
    (synopsis "TyXML is a library for building correct HTML and SVG documents")
    (description "TyXML provides a set of convenient combinators that uses the
OCaml type system to ensure the validity of the generated documents.  TyXML can
be used with any representation of HTML and SVG: the textual one, provided
directly by this package, or DOM trees (@code{js_of_ocaml-tyxml}) virtual DOM
(@code{virtual-dom}) and reactive or replicated trees (@code{eliom}).  You can
also create your own representation and use it to instantiate a new set of
combinators.")
    (license license:lgpl2.1)))

(define-public ocaml-bisect-ppx
  (package
    (name "ocaml-bisect-ppx")
    (version "2.8.3")
    (source
     (origin
       (method url-fetch)
       (uri "https://github.com/aantron/bisect_ppx/archive/2.8.3.tar.gz")
       (sha256
        (base32 "1nzq3wsdaw8k9pfmyvd7hj86h4phslyfcqsfa3f51bpvc0pypp97"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-cmdliner ocaml-ppxlib))
    (native-inputs (list ocamlformat))
    (properties `((upstream-name . "bisect_ppx")))
    (home-page "https://github.com/aantron/bisect_ppx")
    (synopsis "Code coverage for OCaml")
    (description
     "Bisect_ppx helps you test thoroughly.  It is a small preprocessor that inserts
instrumentation at places in your code, such as if-then-else and match
expressions.  After you run tests, Bisect_ppx gives a nice HTML report showing
which places were visited and which were missed.  Usage is simple - add package
bisect_ppx when building tests, run your tests, then run the Bisect_ppx report
tool on the generated visitation files.")
    (license license:expat)))

(define-public ocaml-crunch
  (package
    (name "ocaml-crunch")
    (version "4.0.0")
    (home-page "https://github.com/mirage/ocaml-crunch")
    (source
     (github-tag-origin
      name home-page version
      "0qmsdry5l20fnfh8wrvpqq0dh8kaswsvbkgpri333q4gkp1b3d9j" "v"))
    (build-system dune-build-system)
    (arguments '(#:tests? #f))           ; no tests
    (propagated-inputs (list ocaml-cmdliner ocaml-ptime))
    ;; (propagated-inputs
    ;;  (list ocaml-base ocaml-jane-street-headers ocaml-jst-config
    ;;        ocaml-ppx-base ocaml-ppx-optcomp))
    (properties `((upstream-name . "ocaml-crunch")))
    (synopsis "ocaml-crunch — convert a filesystem into a static OCaml module")
    (description "ocaml-crunch takes a directory of files and compiles them into a standalone OCaml module which serves the contents directly from memory. This can be convenient for libraries that need a few embedded files (such as a web server) and do not want to deal with all the trouble of file configuration.")
    (license license:isc)))

(define-public ocaml-odoc
  (package
    (name "ocaml-odoc")
    (version "3.1.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/ocaml/odoc/releases/download/3.1.0/odoc-3.1.0.tbz")
       (sha256
        (base32 "0559zx12v7qa42a048rdjc4qcgikbviirdfqmv5h6jckykzkqnrm"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-odoc-parser
                             ocaml-astring
                             ocaml-uutf
                             ocaml-sexplib
                             ocaml-cmdliner
                             ocaml-fpath
                             ocaml-tyxml
                             ocaml-fmt
                             ocaml-crunch))
    (native-inputs (list ocaml-cppo
                         ocaml-findlib
                         ocaml-yojson
                         ocaml-sexplib0
                         jq
                         ocaml-ppx-expect
                         ocaml-bos
                         ;; ocaml-bisect-ppx
                         ))
    (home-page "https://github.com/ocaml/odoc")
    (synopsis "OCaml Documentation Generator")
    (description
     "**odoc** is a powerful and flexible documentation generator for OCaml.  It reads
*doc comments*, demarcated by `(** ... *)`, and transforms them into a variety
of output formats, including HTML, @code{LaTeX}, and man pages. - **Output
Formats:** Odoc generates HTML for web browsing, @code{LaTeX} for PDF
generation, and man pages for use on Unix-like systems. - **Cross-References:**
odoc uses the `ocamldoc` markup, which allows to create links for functions,
types, modules, and documentation pages. - **Link to Source Code:**
Documentation generated includes links to the source code of functions,
providing an easy way to navigate from the docs to the actual implementation. -
**Code Highlighting:** odoc automatically highlights syntax in code snippets for
different languages.  odoc is part of the [OCaml
Platform](https://ocaml.org/docs/platform), the recommended set of tools for
OCaml.")
    (license license:isc)))

(define-public ocaml-odoc-parser
  (package
    (name "oocaml-odoc-parser")
    (version "2.0.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/ocaml-doc/odoc-parser")
              (commit version)))
        (file-name (git-file-name name version))
        (sha256
          (base32
           "1x48kf051xs98rd6cri591bk1ccp9hyp93n1rlf6qnxic55jw683"))))
    (build-system dune-build-system)
    (propagated-inputs
      (list ocaml-astring ocaml-camlp-streams ocaml-result))
    (native-inputs
      (list ocaml-ppx-expect))
    (home-page "https://github.com/ocaml-doc/odoc-parser")
    (synopsis "Parser for ocaml documentation comments")
    (description
     "This package provides a library for parsing the contents of OCaml
documentation comments, formatted using Odoc syntax, an extension of the
language understood by ocamldoc.")
    (license license:isc)))

(define-public ocaml-fftw3
  (package
    (name "ocaml-fftw3")
    (version "0.8.5")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Chris00/fftw-ocaml")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "07ljbin9dsclsqh24p7haqjccz1w828sf5xfwlzl298d4a6zsbhs"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list fftw fftwf))
    (native-inputs
     (list ocaml-cppo ocaml-lacaml))
    (home-page
     "https://github.com/Chris00/fftw-ocaml")
    (synopsis
     "Bindings to FFTW3")
    (description
     "Bindings providing OCaml support for the seminal Fast Fourier Transform
library FFTW.")
    (license license:lgpl2.1))) ; with static linking exception.

(define-public ocaml-lacaml
  (package
    (name "ocaml-lacaml")
    (version "11.0.8")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mmottl/lacaml")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "115535kphchh2a434b48b408x9794j8zzrsdmacsgqdsrgy3rck4"))
       (modules '((guix build utils)))
       (snippet '(substitute* '("src/dune" "src/config/dune")
                   (("-march=native") "")))))
    (properties '((tunable? . #t)))
    (build-system dune-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'find-openblas
                 (lambda* _
                   (setenv "LACAML_LIBS" "-lopenblas"))))
           #:tests? #f))                ; No test target.
    (native-inputs
     (list openblas ocaml-base ocaml-stdio))
    (home-page "https://mmottl.github.io/lacaml/")
    (synopsis
     "OCaml-bindings to BLAS and LAPACK")
    (description
     "Lacaml interfaces the BLAS-library (Basic Linear Algebra Subroutines) and
LAPACK-library (Linear Algebra routines).  It also contains many additional
convenience functions for vectors and matrices.")
    (license license:lgpl2.1)))

(define-public ocaml-cairo2
  (package
    (name "ocaml-cairo2")
    (version "0.6.4")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/Chris00/ocaml-cairo")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "06ag9b88ihhr7yd3s9l0ac7ysig02fmlmsswybbsvz71ni0mb105"))))
    (build-system dune-build-system)
    (arguments
     (list #:package "cairo2"))
    (inputs
     `(("cairo" ,cairo)))
    (native-inputs
     (list pkg-config))
    (home-page "https://github.com/Chris00/ocaml-cairo")
    (synopsis "Binding to Cairo, a 2D Vector Graphics Library")
    (description "Ocaml-cairo2 is a binding to Cairo, a 2D graphics library
with support for multiple output devices.  Currently supported output targets
include the X Window System, Quartz, Win32, image buffers, PostScript, PDF,
and SVG file output.")
    (license license:lgpl3+)))

(define-public ocaml-version
  (package
    (name "ocaml-version")
    (version "4.0.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ocurrent/ocaml-version")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1js5w68srirnsng7h2qfjqg9mfldc9z50166r1kz8d23n157605k"))))
    (build-system dune-build-system)
    (arguments `(#:tests? #f))          ; no tests
    (properties '((upstream-name . "ocaml-version")))
    (home-page
     "https://github.com/ocurrent/ocaml-version")
    (synopsis
     "Manipulate, parse and generate OCaml compiler version strings")
    (description
     "This library provides facilities to parse version numbers of the OCaml
compiler, and enumerates the various official OCaml releases and configuration
variants.")
    (license license:isc)))

(define-public ocaml-mdx
  (package
    (name "ocaml-mdx")
    (version "2.5.1")
    (home-page
     "https://github.com/realworldocaml/mdx")
    ;; (source (origin
    ;;           (method git-fetch)
    ;;           (uri (git-reference
    ;;                 (url "https://github.com/realworldocaml/mdx")
    ;;                 (commit version)))
    ;;           (file-name (git-file-name name version))
    ;;           (sha256
    ;;            (base32
    ;;             "1w1givvhwv9jzj9zbg4mmlpb35sqi75w83r99p2z50bdr69fdf57"
    ;; ))))
    (source (github-tag-origin name home-page version
      "1rhj00gsj1zz8yd99wkcpsgf0ym1fg940zk2jq29fysk4zd1g7m3" ""))
    (build-system dune-build-system)
    ;; (arguments
    ;;  `(#:phases
    ;;    (modify-phases %standard-phases
    ;;      (add-after 'unpack 'fix-test-format
    ;;        (lambda _
    ;;          ;; cmdliner changed the format and the tests fail
    ;;          (substitute* '("test/bin/mdx-test/misc/no-such-file/test.expected"
    ;;                         "test/bin/mdx-test/misc/no-such-prelude/test.expected")
    ;;            (("`") "'")
    ;;            (("COMMAND") "[COMMAND]")
    ;;            (("\\.\\.\\.") "…"))))
    ;;      (add-after 'fix-test-format 'fix-egrep
    ;;        (lambda _
    ;;          ;; egrep is obsolescent; using grep -E
    ;;          (substitute* "test/bin/mdx-test/expect/padding/test-case.md"
    ;;            (("egrep") "grep -E")))))))
    (propagated-inputs
     (list ocaml-fmt
           ocaml-astring
           ocaml-logs
           ocaml-cmdliner
           ocaml-re
           ;; ocaml-result
           ;; ocaml-odoc-parser
           ocaml-version))
    (native-inputs
     (list ocaml-cppo ocaml-lwt ocaml-alcotest))
    (synopsis
     "Executable code blocks inside markdown files")
    (description
     "@code{ocaml-mdx} executes code blocks inside markdown files.
There are (currently) two sub-commands, corresponding
to two modes of operations: pre-processing (@code{ocaml-mdx pp})
and tests (@code{ocaml-mdx test}]).

The pre-processor mode allows mixing documentation and code,
and to practice @dfn{literate programming} using markdown and OCaml.

The test mode ensures that shell scripts and OCaml fragments
in the documentation always stays up-to-date.

@code{ocaml-mdx} is released as two binaries called @code{ocaml-mdx} and
@code{mdx} which are the same, mdx being the deprecated name, kept for now for
compatibility.")
    (license license:isc)))

(define-public ocaml-mparser
  (package
    (name "ocaml-mparser")
    (version "1.3")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/murmour/mparser")
              (commit version)))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "16j19v16r42gcsii6a337zrs5cxnf12ig0vaysxyr7sq5lplqhkx"))))
    (build-system dune-build-system)
    (arguments
     ;; No tests.
     '(#:package "mparser"
       #:tests? #f))
    (home-page "https://github.com/murmour/mparser")
    (synopsis "Simple monadic parser combinator library")
    (description
      "This library implements a rather complete and efficient monadic parser
combinator library similar to the Parsec library for Haskell by Daan Leijen and
the FParsec library for FSharp by Stephan Tolksdorf.")
    ;; With static linking exception.
    (license license:lgpl2.1+)))

(define-public ocaml-mparser-re
  (package
    (inherit ocaml-mparser)
    (name "ocaml-mparser-re")
    (arguments
     ;; No tests.
     '(#:package "mparser-re"
       #:tests? #f))
    (propagated-inputs
     (list ocaml-mparser ocaml-re))
    (synopsis "MParser plugin for RE-based regular expressions")
    (description "This package provides RE-based regular expressions
support for Mparser.")))

(define-public ocaml-mparser-pcre
  (package
    (inherit ocaml-mparser)
    (name "ocaml-mparser-pcre")
    (arguments
     ;; No tests.
     '(#:package "mparser-pcre"
       #:tests? #f))
    (propagated-inputs
     (list ocaml-mparser ocaml-pcre))
    (synopsis "MParser plugin for PCRE-based regular expressions")
    (description "This package provides PCRE-based regular expressions
support for Mparser.")))

(define-public lablgtk3
  (package
    (name "lablgtk")
    (version "3.1.3")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/garrigue/lablgtk")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0rhdr89w7yj8pkga5xc7iqmqvrs28034wb7sm7vx7faaxczwjifn"))))
    (build-system dune-build-system)
    (arguments
     `(#:package "lablgtk3"))
    (propagated-inputs
     (list ocaml-cairo2 ocaml-camlp-streams))
    (inputs
     (list camlp5 gtk+))
    (native-inputs
     (list pkg-config))
    (home-page "https://github.com/garrigue/lablgtk")
    (synopsis "OCaml interface to GTK+3")
    (description "LablGtk is an OCaml interface to GTK+ 1.2, 2.x and 3.x.  It
provides a strongly-typed object-oriented interface that is compatible with the
dynamic typing of GTK+.  Most widgets and methods are available.  LablGtk
also provides bindings to gdk-pixbuf, the GLArea widget (in combination with
LablGL), gnomecanvas, gnomeui, gtksourceview, gtkspell, libglade (and it can
generate OCaml code from .glade files), libpanel, librsvg and quartz.")
    ;; Version 2 only, with linking exception.
    (license license:lgpl2.0)))

(define-public ocaml-lablgtk3-sourceview3
  (package
    (inherit lablgtk3)
    (name "ocaml-lablgtk3-sourceview3")
    (propagated-inputs (list gtksourceview-3 lablgtk3))
    (arguments
     `(#:package "lablgtk3-sourceview3"))
    (synopsis "OCaml interface to GTK+ gtksourceview library")
    (description "This package provides the lablgtk interface to the
GTK+ gtksourceview library.")))

(define-public ocaml-reactivedata
  (package
    (name "ocaml-reactivedata")
    (version "0.3")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/ocsigen/reactiveData")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0gmpfnw08c7hx4bsgrgvp6w7pq2ghqxq3qd1cbdyscbg9n22jrca"))))
    (arguments
     `(#:tests? #f)) ;no tests
    (build-system dune-build-system)
    (properties `((upstream-name . "reactiveData")))
    (propagated-inputs
     (list ocaml-react))
    (home-page "https://github.com/ocsigen/reactiveData")
    (synopsis "Declarative events and signals for OCaml")
    (description
     "React is an OCaml module for functional reactive programming (FRP).  It
provides support to program with time varying values: declarative events and
 signals.  React doesn't define any primitive event or signal, it lets the
client chooses the concrete timeline.")
    (license license:lgpl2.1+)))

(define-public ocaml-uucd
  (package
    (name "ocaml-uucd")
    (version "15.0.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://erratique.ch/software/uucd/releases/"
                           "uucd-" version ".tbz"))
       (sha256
        (base32
         "1g26237yqmxr7sd1n9fg65qm5mxz66ybk7hr336zfyyzl25h6jqf"))))
    (build-system ocaml-build-system)
    (arguments
     '(#:build-flags '("build" "--tests" "true")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))))
    (propagated-inputs
     (list ocaml-xmlm))
    (native-inputs
     (list opam-installer ocaml-findlib ocamlbuild ocaml-topkg))
    (home-page "https://erratique.ch/software/uucd")
    (synopsis "Unicode character database decoder for OCaml")
    (description "Uucd is an OCaml module to decode the data of the Unicode
character database from its XML representation.  It provides high-level (but
not necessarily efficient) access to the data so that efficient
representations can be extracted.")
    (license license:isc)))

(define-public ocaml-uucp
  (package
    (name "ocaml-uucp")
    (version "15.0.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://erratique.ch/software/uucp/releases/"
                           "uucp-" version ".tbz"))
       (sha256
        (base32
         "0c2k9gkg442l7hnc8rn1vqzn6qh68w9fx7h3nj03n2x90ps98ixc"))))
    (build-system ocaml-build-system)
    (arguments
     '(#:build-flags '("build" "--tests" "true")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))))
    (native-inputs
     (list opam-installer
           ocaml-findlib
           ocamlbuild
           ocaml-topkg
           ocaml-uucd
           ocaml-uunf
           ocaml-uutf))
    (home-page "https://erratique.ch/software/uucp")
    (synopsis "Unicode character properties for OCaml")
    (description "Uucp is an OCaml library providing efficient access to a
selection of character properties of the Unicode character database.")
    (license license:isc)))

(define-public ocaml-uuseg
  (package
    (name "ocaml-uuseg")
    (version "15.0.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://erratique.ch/software/uuseg/releases/"
                           "uuseg-" version ".tbz"))
       (sha256
        (base32
         "1qz130wlmnvb6j7kpvgjlqmdm2jqid4wb1dmrsls4hdm4rp7gk5b"))))
    (build-system ocaml-build-system)
    (arguments
     '(#:build-flags '("build" "--tests" "true")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))))
    (propagated-inputs
     (list ocaml-uucp ocaml-uutf ocaml-cmdliner))
    (native-inputs
     (list opam-installer ocaml-findlib ocamlbuild ocaml-topkg))
    (home-page "https://erratique.ch/software/uuseg")
    (synopsis "Unicode text segmentation for OCaml")
    (description "Uuseg is an OCaml library for segmenting Unicode text.  It
implements the locale independent Unicode text segmentation algorithms to
detect grapheme cluster, word and sentence boundaries and the Unicode line
breaking algorithm to detect line break opportunities.

The library is independent from any IO mechanism or Unicode text data
structure and it can process text without a complete in-memory
representation.")
    (license license:isc)))

(define-public ocaml-fix
  (package
    (name "ocaml-fix")
    (version "20220121")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://gitlab.inria.fr/fpottier/fix")
              (commit version)))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "15785v43jcbqsw1y653cnb89alrcnbdri1h0w6zl6p7769ja9rdj"))))
    (build-system dune-build-system)
    (arguments
     ;; No tests.
     '(#:tests? #f))
    (home-page "https://gitlab.inria.fr/fpottier/fix")
    (synopsis "Facilities for memoization and fixed points")
    (description "This package provides helpers with various constructions
that involve memoization and recursion.")
    (license license:lgpl2.0)))

(define-public ocaml-dune-build-info
  (package
    (inherit dune-ordering)
    (name "ocaml-dune-build-info")
    (build-system dune-build-system)
    (arguments
     '(#:package "dune-build-info"
       ;; No separate test suite from dune.
       #:tests? #f))
    (propagated-inputs
     (list))
    (synopsis "Embed build information inside an executable")
    (description "This package allows one to access information about how the
executable was built, such as the version of the project at which it was built
or the list of statically linked libraries with their versions.  It supports
reporting the version from the version control system during development to
get an precise reference of when the executable was built.")))

(define-public ocaml-xdg
  (package
    (inherit dune-ordering)
    (name "ocaml-xdg")
    (build-system dune-build-system)
    (arguments
     '(#:package "xdg"
       ;; Tests have a cyclic dependency on stdune
       #:tests? #f))
    (synopsis "XDG Base Directory Specification library for ocaml")
    (description
     "This ocaml library returns user XDG directories such as XDG_CONFIG_HOME,
     XDG_STATE_HOME.")))

(define-public dune-rpc
  (package
    (inherit dune-ordering)
    (name "dune-rpc")
    (build-system dune-build-system)
    (arguments
     '(#:package "dune-rpc"
       ;; Tests have a cyclic dependency on stdune
       #:tests? #f))
    (propagated-inputs (list ocaml-csexp
                             dune-ordering
                             dune-dyn
                             ocamlc-loc
                             ocaml-xdg
                             dune-stdune
                             ocaml-pp))
    (synopsis "Communicate with ocaml dune using rpc")
    (description "Library to connect and control a running dune instance.")))

(define-public ocamlc-loc
  (package
    (inherit dune-ordering)
    (name "ocamlc-loc")
    (build-system dune-build-system)
    (arguments
     '(#:package "ocamlc-loc"
       ;; Tests have a cyclic dependency on stdune
       #:tests? #f))
    (propagated-inputs (list dune-dyn))
    (synopsis "Parse ocaml compiler output into structured form")
    (description
     "This library parses ocaml compiler output and returns it as ocaml values.
This library offers no backwards compatibility guarantees.")))

(define-public ocaml-chrome-trace
  (package
    (inherit dune-ordering)
    (name "ocaml-chrome-trace")
    (build-system dune-build-system)
    (arguments
     '(#:package "chrome-trace"
       ;; Tests have a cyclic dependency on stdune
       #:tests? #f))
    (synopsis "Chrome trace event generation library for ocaml")
    (description
     "Output trace data to a file in Chrome's trace_event format. This format is
    compatible with chrome trace viewer chrome://tracing.
    This library offers no backwards compatibility guarantees.")
    (license license:expat)))

(define-public ocaml-fiber
  (package
    (name "ocaml-fiber")
    (home-page "https://github.com/ocaml-dune/fiber")
    (version "3.7.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url home-page)
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "085v1dfxrb4wnkgysghj5q4vr4nx3nxr84rqmy874dr3pk30740n"))))
    (build-system dune-build-system)
    (arguments
     '(#:package "fiber"
       ;; Tests require ppx_expect.common which was removed in ppx_expect v0.17.
       ;; Fiber 3.7.0 requires ppx_expect <v0.17, but Guix has v0.17.3.
       #:tests? #f))
    (propagated-inputs (list dune-stdune dune-dyn))
    (native-inputs (list ocaml-ppx-expect))
    (synopsis "Structured concurrency library")
    (description
     "This library implements structured concurrency for ocaml.
     It offers no backwards compatibility guarantees.")
    (license license:expat)))

(define-public ocaml-either
  (package
    (name "ocaml-either")
    (version "1.0.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/mirage/either")
               (commit version)))
        (file-name (git-file-name name version))
        (sha256
          (base32 "099p1m24vz5i0043zcfp88krzjsa2qbrphrm4bnx84gif5vgkxwm"))))
    (build-system dune-build-system)
    (arguments
     ;; no tests
     `(#:tests? #f))
    (home-page "https://github.com/mirage/either")
    (synopsis "Compatibility Either module")
    (description "This library is a compatibility module for the Either module
defined in OCaml 4.12.0.")
    (license license:expat)))

(define-public ocamlformat
  (package
    (name "ocamlformat")
    (version "0.27.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/ocaml-ppx/ocamlformat")
              (commit version)))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0wdzv54s31lckkkwf776j7npcd7i2sscdy9asiaxy50vgi4y7kbx"))
        (modules '((guix build utils)))
        ;; (snippet
        ;;  #~(begin
        ;;      ;; Add out_width field for OCaml 5.4 compatibility
        ;;      (substitute* "lib/bin_conf/Bin_conf.ml"
        ;;        (("      ; out_indent= \\(fun _ -> \\(\\)\\) \\} \\)")
        ;;         "      ; out_indent= (fun _ -> ())\n      ; out_width= (fun _ ~pos ~len -> 80) } )"))))
        ))
    (build-system dune-build-system)
    (arguments
     ;; Tests fail due to cmdliner version mismatch with ocaml-alcotest
     '(#:tests? #f))
    ;; (arguments
    ;;  '(#:package "ocamlformat"
    ;;    #:phases
    ;;    (modify-phases %standard-phases
    ;;      ;; Tests related to other packages
    ;;      (add-after 'unpack 'remove-unrelated-tests
    ;;        (lambda _
    ;;          (delete-file-recursively "test/rpc")))
    ;;      (add-after 'unpack 'fix-test-format
    ;;        (lambda _
    ;;          (substitute* "test/cli/repl_file_errors.t/run.t"
    ;;            ((" ;;") ";;")))))))
    (propagated-inputs
      (list ocaml-version
            ocaml-base
            ocaml-cmdliner-1.3
            ocaml-dune-build-info
            ocaml-either
            ocaml-fix
            ocaml-fpath
            ocaml-menhir
           
            ocaml-ppxlib
            ocaml-re
            ;; ocaml-odoc-parser
 ocaml-stdio
            ocaml-uuseg
            ocaml-uutf))
    (native-inputs
      (list git-minimal/pinned                     ;for tests
            ocaml-alcotest ocaml-ocp-indent))
    (home-page "https://github.com/ocaml-ppx/ocamlformat")
    (synopsis "Auto-formatter for OCaml code")
    (description "OCamlFormat is a tool to automatically format OCaml code in
a uniform style.")
    (license license:expat)))

(define-public ocamlformat-rpc-lib
  (package
    (inherit ocamlformat)
    (name "ocamlformat-rpc-lib")
    (arguments
     '(#:package "ocamlformat-rpc-lib"))
    (propagated-inputs (list ocaml-csexp))
    (synopsis "Auto-formatter for OCaml code in RPC mode")
    (description
     "OCamlFormat is a tool to automatically format OCaml code in a uniform style.
This package defines a RPC interface to OCamlFormat.")))

(define-public ocaml-bigstringaf
  (package
    (name "ocaml-bigstringaf")
    (version "0.9.0")
    (home-page "https://github.com/inhabitedtype/bigstringaf")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "188j9awxg99vrp2l3rqfmdxdazq5xrjmg1wf62vfqsks9sff6wqx"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-bigarray-compat))
    (native-inputs
     (list ocaml-alcotest pkg-config))
    (synopsis
     "Bigstring intrinsics and fast blits based on memcpy/memmove")
    (description
     "The OCaml compiler has a bunch of intrinsics for Bigstrings, but they're
not widely-known, sometimes misused, and so programs that use Bigstrings are
slower than they have to be.  And even if a library got that part right and
exposed the intrinsics properly, the compiler doesn't have any fast blits
between Bigstrings and other string-like types.  @code{bigstringaf} provides
these missing pieces.")
    (license license:bsd-3)))

(define-public ocaml-intrinsics
  (package
    (name "ocaml-intrinsics")
    (version "0.15.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/janestreet/ocaml_intrinsics")
                    (commit (string-append "v" version))))
              (file-name name)
              (sha256
               (base32
                "1mazr1ka2zlm2s8bw5i555cnhi1bmr9yxvpn29d3v4m8lsnfm73z"))))
    (build-system dune-build-system)
    ;; TODO figure out how to get around this error:
    ;; No rule found for alias test/runtime-deps-of-tests
    (arguments
     '(#:tests? #f))
    (propagated-inputs (list dune-configurator))
    (native-inputs (list ocaml-expect-test-helpers-core ocaml-core))
    (properties `((upstream-name . "ocaml_intrinsics")))
    (home-page "https://github.com/janestreet/ocaml_intrinsics")
    (synopsis "AMD64 intrinsics with emulated fallbacks")
    (description
     "Provides an OCaml interface to operations that have dedicated hardware
instructions on some micro-architectures, with default implementations using C
stubs for all targets.")
    (license license:expat)))

(define-public ocaml-trie
  (package
    (name "ocaml-trie")
    (version "1.0.0")
    (home-page "https://github.com/kandu/trie/")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0s7p9swjqjsqddylmgid6cv263ggq7pmb734z4k84yfcrgb6kg4g"))))
    (build-system dune-build-system)
    (arguments
     '(#:tests? #f))                    ;no tests
    (synopsis "Strict impure trie tree")
    (description
     "This module implements strict impure trie tree data structure for
OCaml.")
    (license license:expat)))

(define-public ocaml-mew
  (package
    (name "ocaml-mew")
    (version "0.1.0")
    (home-page "https://github.com/kandu/mew")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0417xsghj92v3xa5q4dk4nzf2r4mylrx2fd18i7cg3nzja65nia2"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-trie))
    (native-inputs
     (list ocaml-ppx-expect))
    (synopsis "General modal editing engine generator")
    (description
     "This package provides the core modules of Modal Editing Witch, a general
modal editing engine generator.")
    (license license:expat)))

(define-public ocaml-mew-vi
  (package
    (name "ocaml-mew-vi")
    (version "0.5.0")
    (home-page "https://github.com/kandu/mew_vi")
    (source
      (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit version)))
       (file-name (git-file-name name version))
        (sha256
          (base32 "0lihbf822k5zasl60w5mhwmdkljlq49c9saayrws7g4qc1j353r8"))))
    (build-system dune-build-system)
    (propagated-inputs
      (list ocaml-mew ocaml-react))
    (native-inputs
     (list ocaml-ppx-expect))
    (properties `((upstream-name . "mew_vi")))
    (synopsis "Modal editing VI-like editing engine generator")
    (description "This module provides a vi-like modal editing engine
generator.")
    (license license:expat)))

(define-public ocaml-syntax-shims
  (package
    (name "ocaml-syntax-shims")
    (version "1.0.0")
    (home-page "https://github.com/ocaml-ppx/ocaml-syntax-shims")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0l1i8z95qgb0lxlrv3yb5nkp391hqsiyi4r91p12k3xmggqixagf"))))
    (build-system dune-build-system)
    (properties
     `((upstream-name . "ocaml-syntax-shims")))
    (synopsis
     "Backport new syntax to older OCaml versions")
    (description
     "This package backports new language features such as @code{let+} to older
OCaml compilers.")
    (license license:expat)))

(define-public ocaml-angstrom
  (package
    (name "ocaml-angstrom")
    (version "0.16.1")
    (home-page "https://github.com/inhabitedtype/angstrom")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "17l1nzs38nq8sapd3snhsn8qapgivcss3vkv233nnlyixqmq7yhh"
         ))))
    (build-system dune-build-system)
    (arguments
     ;; Only build the base angstrom package.
     '(#:package "angstrom"))
    (propagated-inputs
     (list ocaml-bigstringaf))
    (native-inputs
     (list ocaml-alcotest ocaml-ppx-let ocaml-syntax-shims))
    (synopsis "Parser combinators built for speed and memory-efficiency")
    (description
     "Angstrom is a parser-combinator library that makes it easy to write
efficient, expressive, and reusable parsers suitable for high-performance
applications.  It exposes monadic and applicative interfaces for composition,
and supports incremental input through buffered and unbuffered interfaces.
Both interfaces give the user total control over the blocking behavior of
their application, with the unbuffered interface enabling zero-copy IO.
Parsers are backtracking by default and support unbounded lookahead.")
    (license license:bsd-3)))

(define-public ocaml-graphics
  (package
    (name "ocaml-graphics")
    (version "5.1.2")
    (home-page "https://github.com/ocaml/graphics")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1q20f8y6ijxbvzik2ns4yl3w54q5z8kd0pby8i8c64a04hvly08m"))))
    (build-system dune-build-system)
    (propagated-inputs
     (list libx11))
    (synopsis "The OCaml graphics library")
    (description
     "The graphics library provides a set of portable drawing primitives.
Drawing takes place in a separate window that is created when
Graphics.open_graph is called.  This library used to be distributed with OCaml
up to OCaml 4.08.")
    (license license:lgpl2.1+)))

(define-public ocaml-uri-sexp
  (package
    (inherit ocaml-uri)
    (name "ocaml-uri-sexp")
    (arguments
     '(#:package "uri-sexp"))
    (propagated-inputs
      (list ocaml-uri ocaml-ppx-sexp-conv ocaml-sexplib0))
    (native-inputs (list ocaml-ounit))
    (synopsis "RFC3986 URI/URL parsing library")
    (description "This package adds S-exp support to @code{ocaml-uri}.")))

(define-public ocaml-http
  (package
    (name "ocaml-http")
    (version "6.1.1")
    (build-system dune-build-system)
    (arguments '(#:package "http"))
    (home-page "https://github.com/mirage/ocaml-cohttp")
    (source
     (github-tag-origin
      name home-page version
      "1li96x3s287a092nb9d0panr55298a9dd3v1s9igdxllsb789l9a"
      "v"
      ))
    (propagated-inputs
      (list ocaml-re
            ocaml-uri
            ;; ocaml-http
            ocaml-uri-sexp
            ocaml-sexplib0
            ocaml-ppx-sexp-conv
            ocaml-stringext
            ocaml-ppx-expect
            ocaml-base-quickcheck
            ocaml-base64
            ))
    (native-inputs
     (list ocaml-fmt
           ocaml-jsonm
           ocaml-alcotest
           ocaml-crowbar))
    (synopsis "OCaml library for HTTP clients and servers")
    (description
      "Cohttp is an OCaml library for creating HTTP daemons.  It has a portable
HTTP parser, and implementations using various asynchronous programming
libraries.")
    (license license:isc)))

(define-public ocaml-cohttp
  (package
    (name "ocaml-cohttp")
    (version "6.1.1")
    (build-system dune-build-system)
    (arguments '(#:package "cohttp"))
    (home-page "https://github.com/mirage/ocaml-cohttp")
    (source
     (github-tag-origin
      name home-page version
      "1li96x3s287a092nb9d0panr55298a9dd3v1s9igdxllsb789l9a"
      "v"
      ))
    (propagated-inputs
      (list ocaml-re
            ocaml-uri
            ocaml-http
            ocaml-logs
            ocaml-uri-sexp
            ocaml-sexplib0
            ocaml-ppx-sexp-conv
            ocaml-stringext
            ocaml-base64
            ))
    (native-inputs
     (list ocaml-fmt
           ocaml-jsonm
           ocaml-alcotest
           ocaml-crowbar))
    (synopsis "OCaml library for HTTP clients and servers")
    (description
      "Cohttp is an OCaml library for creating HTTP daemons.  It has a portable
HTTP parser, and implementations using various asynchronous programming
libraries.")
    (license license:isc)))

(define-public ocaml-cohttp-lwt
  (package
    (name "ocaml-cohttp-lwt")
    (version "6.1.1")
    (build-system dune-build-system)
    (arguments '(#:package "cohttp-lwt"))
    (home-page "https://github.com/mirage/ocaml-cohttp")
    (source
     (github-tag-origin
      name home-page version
      "1li96x3s287a092nb9d0panr55298a9dd3v1s9igdxllsb789l9a"
      "v"
      ))
    (propagated-inputs
      (list ocaml-re
            ocaml-uri
            ocaml-ipaddr
            ocaml-logs
            ocaml-cohttp
            ;; ocaml-http
            ocaml-uri-sexp
            ocaml-sexplib0
            ocaml-ppx-sexp-conv
            ocaml-stringext
            ocaml-ppx-expect
            ocaml-base-quickcheck
            ocaml-base64
            ))
    (native-inputs
     (list ocaml-fmt
           ocaml-jsonm
           ocaml-alcotest
           ocaml-crowbar))
    (synopsis "OCaml library for HTTP clients and servers")
    (description
      "Cohttp is an OCaml library for creating HTTP daemons.  It has a portable
HTTP parser, and implementations using various asynchronous programming
libraries.")
    (license license:isc)))

(define-public ocaml-cohttp-eio
  (package
    (name "ocaml-cohttp-eio")
    (version "6.1.1")
    (build-system dune-build-system)
    (arguments '(#:package "cohttp-eio"))
    (home-page "https://github.com/mirage/ocaml-cohttp")
    (source
     (github-tag-origin
      name home-page version
      "1li96x3s287a092nb9d0panr55298a9dd3v1s9igdxllsb789l9a"
      "v"
      ))
    (propagated-inputs
      (list ocaml-re
            ocaml-tls
            ocaml-uri
            ocaml-ipaddr
            ocaml-logs
            ocaml-cohttp
            ocaml-eio
            ocaml-eio-main
            ocaml-mirage-crypto
            ocaml-ptime
            ;; ocaml-http
            ocaml-uri-sexp
            ocaml-sexplib0
            ocaml-ppx-sexp-conv
            ocaml-stringext
            ocaml-ppx-expect
            ocaml-base-quickcheck
            ocaml-base64
            ))
    (native-inputs
     (list
      gmp
      ocaml-ca-certs
      ocaml-fmt
           ocaml-jsonm
           ocaml-alcotest
           ocaml-crowbar))
    (synopsis "OCaml library for HTTP clients and servers")
    (description
      "Cohttp is an OCaml library for creating HTTP daemons.  It has a portable
HTTP parser, and implementations using various asynchronous programming
libraries.")
    (license license:isc)))

(define-public js-of-ocaml-compiler
  (package
    (name "js-of-ocaml-compiler")
    (version "6.2.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/ocsigen/js_of_ocaml/releases/download/6.2.0/js_of_ocaml-6.2.0.tbz")
       (sha256
        (base32 "1nm5sa6xpzcbwf3rpkfg19d3c8f6x3h3wcw858sjl5qvimvl3ikw"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-ppxlib
                             ocaml-cmdliner
                             ocaml-sedlex
                             ocaml-menhir
                             ocaml-yojson
                             ocaml-tyxml
                             ocaml-reactivedata
                             ))
    (native-inputs (list ocaml-num ocaml-ppx-expect ocaml-re ocaml-qcheck git))
    (properties `((upstream-name . "js_of_ocaml-compiler")))
    (home-page "https://ocsigen.org/js_of_ocaml/latest/manual/overview")
    (synopsis "Compiler from OCaml bytecode to JavaScript")
    (description
     "Js_of_ocaml is a compiler from OCaml bytecode to @code{JavaScript}.  It makes it
possible to run pure OCaml programs in @code{JavaScript} environment like
browsers and Node.js.")
    (license license:gpl2+)))

(define-public js-of-ocaml
  (package
    (name "js-of-ocaml")
    (version "6.2.0")
    (source
     (origin
       (method url-fetch)
       (uri
        "https://github.com/ocsigen/js_of_ocaml/releases/download/6.2.0/js_of_ocaml-6.2.0.tbz")
       (sha256
        (base32 "1nm5sa6xpzcbwf3rpkfg19d3c8f6x3h3wcw858sjl5qvimvl3ikw"))))
    (build-system dune-build-system)
    (propagated-inputs (list js-of-ocaml-compiler ocaml-ppxlib
                             ;; ocaml-odoc
                             ))
    (native-inputs (list ocaml-num ocaml-ppx-expect ocaml-re git))
    (properties `((upstream-name . "js_of_ocaml")))
    (home-page "https://ocsigen.org/js_of_ocaml/latest/manual/overview")
    (synopsis "Compiler from OCaml bytecode to JavaScript")
    (description
     "Js_of_ocaml is a compiler from OCaml bytecode to @code{JavaScript}.  It makes it
possible to run pure OCaml programs in @code{JavaScript} environment like
browsers and Node.js.")
    (license license:gpl2)))

(define-public ocaml-afl-persistent
  (package
    (name "ocaml-afl-persistent")
    (version "1.3")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/stedolan/ocaml-afl-persistent")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
          (base32
           "06yyds2vcwlfr2nd3gvyrazlijjcrd1abnvkfpkaadgwdw3qam1i"))))
    (build-system ocaml-build-system)
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (replace 'build
           (lambda _
             (invoke "./build.sh")))
         ;; XXX: The tests are already run in the build.sh script.
         (delete 'check))))
    (native-inputs (list opam-installer))
    (home-page "https://github.com/stedolan/ocaml-afl-persistent")
    (synopsis "Use afl-fuzz in persistent mode")
    (description
      "afl-fuzz normally works by repeatedly forking the program being tested.
Using this package, you can run afl-fuzz in ``persistent mode'', which avoids
repeated forking and is much faster.")
    (license license:expat)))

(define-public ocaml-monolith
  (package
    (name "ocaml-monolith")
    (version "20210525")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://gitlab.inria.fr/fpottier/monolith")
              (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1b6jj4ivl9ni8kba7wls4xsqdy8nm7q9mnx9347jvb99dmmlj5mc"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-afl-persistent ocaml-pprint ocaml-seq))
    (home-page "https://gitlab.inria.fr/fpottier/monolith")
    (synopsis "Framework for testing an OCaml library using afl-fuzz")
    (description "Monolith offers facilities for testing an OCaml library (for
instance, a data structure implementation) by comparing it against a reference
implementation.  It can be used to perform either random testing or fuzz
testing by using the @code{afl-fuzz} tool.")
    (license license:lgpl3+)))

(define-public ocaml-pprint
  (package
    (name "ocaml-pprint")
    (version "20230830")
    (home-page "https://github.com/fpottier/pprint")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1802ziwlwi1as97xcv7d41s08z1p9mql7fy3ad6bs210y3bgpxva"))))
    (build-system dune-build-system)
    (synopsis "OCaml pretty-printing combinator library and rendering
engine")
    (description "This OCaml library offers a set of combinators for building
so-called documents as well as an efficient engine for converting documents to
a textual, fixed-width format.  The engine takes care of indentation and line
breaks, while respecting the constraints imposed by the structure of the
document and by the text width.")
    (license license:lgpl2.0)))

(define-public ocaml-crowbar
  (package
    (name "ocaml-crowbar")
    (version "0.2.1")
    (home-page "https://github.com/stedolan/crowbar")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "11f3kiw58g8njx15akx16xcplzvzdw9y6c4jpyfxylkxws4g0f6j"
                ))))
    (build-system dune-build-system)
    (propagated-inputs
     (list ocaml-ocplib-endian
           ocaml-cmdliner
           ocaml-afl-persistent))
    (native-inputs
     (list ocaml-calendar
           ocaml-fpath
           ocaml-uucp
           ocaml-uunf
           ocaml-uutf
           ocaml-pprint))
    (properties `((ocaml5.0-variant . ,(delay ocaml5.0-crowbar))))
    (synopsis "Ocaml library for tests, let a fuzzer find failing cases")
    (description "Crowbar is a library for testing code, combining
QuickCheck-style property-based testing and the magical bug-finding powers of
@uref{http://lcamtuf.coredump.cx/afl/, afl-fuzz}.")
    (license license:expat)))

(define-public ocaml5.0-crowbar
  (package-with-ocaml5.0
   (package
     (inherit ocaml-crowbar)
     ;; Tests require ocaml-calendar which does not work with OCaml 5.0
     (arguments `(#:tests? #f))
     (properties '()))))

(define-public ocaml-eqaf
  (package
    (name "ocaml-eqaf")
    (version "0.10")
    (home-page "https://github.com/mirage/eqaf")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1pwj69j0nrmshngxa9xilj8k0v17r72jjsx8ch92npnhgfi1ij6w"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-cstruct))
    (native-inputs (list ocaml-alcotest ocaml-crowbar))
    (synopsis "OCaml library for constant-time equal function on string")
    (description "This OCaml library provides an equal function on string in
constant-time to avoid timing-attack with crypto stuff.")
    (license license:expat)))

(define-public ocaml-digestif
  (package
    (name "ocaml-digestif")
    (version "1.3.0")
    (home-page "https://github.com/mirage/digestif")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0qwyihi5bdqfy39m00db3v4simm6b0nbglav0zcdd00jpv6mgnc2"))))
    (build-system dune-build-system)
    (propagated-inputs (list ocaml-eqaf))
    (native-inputs
     (list pkg-config
           ocaml-fmt
           ocaml-crowbar
           ocaml-alcotest
           ocaml-bos
           ocaml-astring
           ocaml-fpath
           ocaml-rresult
           ocaml-findlib))
    (synopsis "Simple hash algorithms in OCaml")
    (description
     "Digestif is an OCaml library that provides implementations of hash
algorithms.  Implemented hash algorithms include MD5, SHA1, SHA224, SHA256,
SHA384, SHA512, Blake2b, Blake2s and RIPEMD160.")
    (license license:expat)))

(define-public ocaml-bibtex2html
  (package
    (name "ocaml-bibtex2html")
    (version "1.99-1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/backtracking/bibtex2html/releases/download/v-1-99/"
                           "bibtex2html-"  version ".tar.gz"))
       (sha256
        (base32
         "07gzrs4lfrkvbn48cgn2gn6c7cx3jsanakkrb2irj0gmjzfxl96j"))))
    (build-system ocaml-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'patch-/bin/sh
            (lambda _
              (substitute* "configure" (("/bin/sh") (which "bash")))
              ;; mktexfmt needs writable TEXMFVAR directory.
              (setenv "TEXMFVAR" "/tmp"))))))
    (native-inputs
     (list (texlive-local-tree
            (list texlive-infwarerr
                  texlive-kvoptions
                  texlive-pdftexcmds
                  texlive-preprint))
           which))
    (propagated-inputs
     (list hevea))
    (home-page "https://www.lri.fr/~filliatr/bibtex2html/")
    (synopsis "BibTeX to HTML translator")
    (description "This package allows you to produce, from a set of
bibliography files in BibTeX format, a bibliography in HTML format.")
    (license license:gpl2)))

(define-public ocaml-guile
  (package
    (name "ocaml-guile")
    (version "1.0")
    (home-page "https://github.com/gopiandcode/guile-ocaml")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url home-page)
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0yxdkrhrrbwvay5sn0p26rh3f11876k6kdharmpi4afxknml74ql"))))
    (build-system dune-build-system)
    (arguments
     `(#:tests? #f)) ; no tests
    (propagated-inputs
     (list ocaml-sexplib
           ocaml-ctypes
           ocaml-stdio
          ))
    (inputs (list guile-3.0 libffi))
    (native-inputs
     (list
           pkg-config))
    (synopsis "Bindings to GNU Guile Scheme for OCaml")
    (description
     "The OCaml guile library provides high-level OCaml bindings to GNU Guile
3.0, supporting easy interop between OCaml and GNU Guile Scheme.")
    (license license:gpl3+)))

;;;
;;; Avoid adding new packages to the end of this file. To reduce the chances
;;; of a merge conflict, place them above by existing packages with similar
;;; functionality or similar names.
;;;
