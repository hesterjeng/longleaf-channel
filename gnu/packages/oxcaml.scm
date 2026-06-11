;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2026 John Hester <hesterj@etableau.com>
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

(define-module (gnu packages oxcaml)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system longleaf-ocaml)
  #:use-module (gnu packages longleaf-ocaml)
  #:use-module (gnu packages m4)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-13))

;; Commentary:
;;
;; This module rebuilds OCaml packages from (gnu packages longleaf-ocaml) with
;; the OxCaml compiler instead of the default upstream OCaml.
;;
;; The engine is PACKAGE-WITH-OXCAML, a transformation (built on the channel's
;; PACKAGE-WITH-EXPLICIT-OCAML, exactly as PACKAGE-WITH-OCAML5.0 is) that
;; recursively rebuilds a package AND its entire OCaml dependency graph with
;; oxcaml + oxcaml-findlib + oxcaml-dune.  Rebuilding the whole graph is
;; mandatory: oxcaml's .cmi/.cmx magic numbers differ from upstream OCaml, so a
;; package built with oxcaml cannot link against dependencies built with the
;; default compiler.  A plain (inherit ...) that only swaps the compiler would
;; leave the inputs mismatched.
;;
;; Curated oxcaml- variants are then one-liners:
;;
;;   (define-public oxcaml-foo (package-with-oxcaml ocaml-foo))
;;
;; and packages that need a per-package patch layer (inherit ...) on top:
;;
;;   (define-public oxcaml-foo
;;     (package (inherit (package-with-oxcaml ocaml-foo)) ...fix...))
;;
;; NOTE: oxcaml is based on OCaml 5.2, while the channel default is 5.4.  Any
;; package relying on 5.3/5.4 stdlib or syntax, or on compiler-libs internals,
;; will not build.  Add entries here only as they are verified to build.
;;
;; Code:

;; ocamlfind, rebuilt with oxcaml.  oxcaml's stdlib types `prerr_endline' as
;; `string @ local -> unit', which no longer unifies with `ignore' in
;; topfind.ml's `if real_toploop then prerr_endline else ignore'.  Eta-expand
;; `prerr_endline' so the branch is global (string -> unit), matching both
;; `ignore' and the invariant `(string -> unit) ref' in topfind.mli.
(define-public oxcaml-findlib
  (package
    (inherit ocaml-findlib)
    (name "oxcaml-findlib")
    (native-inputs (list m4 oxcaml))
    (arguments
     (substitute-keyword-arguments (package-arguments ocaml-findlib)
       ((#:phases phases)
        (append phases
                `((add-after 'unpack 'oxcaml-mode-compat
                    (lambda _
                      (substitute* "src/findlib/topfind.ml.in"
                        (("prerr_endline else ignore")
                         "(fun s -> prerr_endline s) else ignore"))))
                  ;; Stock OCaml ships `seq' ambiently (it is an empty compat
                  ;; META -- the Seq module lives in stdlib).  oxcaml's build
                  ;; doesn't, so libs that write `(libraries seq)' without
                  ;; depending on ocaml-seq (psq, base64, ...) fail to resolve
                  ;; the findlib name.  Install the shim into findlib's own
                  ;; site-lib so every oxcaml build sees it -- inline META, not
                  ;; a package dep, so no oxcaml-seq <- oxcaml-findlib cycle.
                  (add-after 'install 'oxcaml-seq-shim
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let ((dir (string-append
                                  (assoc-ref outputs "out")
                                  "/lib/ocaml/site-lib/seq")))
                        (mkdir-p dir)
                        (call-with-output-file (string-append dir "/META")
                          (lambda (port)
                            (display "name=\"seq\"
version=\"[distributed with ocaml]\"
description=\"dummy package for compatibility\"
requires=\"\"" port)))))))))))))

;; --- oxcaml policy for the generic #:extra-transform hook -------------------
;; Test runners pulled in as native-inputs are RUN, never linked into a
;; library; with tests disabled they are not needed at all.  Dropping them
;; avoids dragging their (often topkg/ppx) closures through the oxcaml rebuild.
;; Matched with the ocaml-/oxcaml- prefix stripped.
(define %oxcaml-test-frameworks
  '("alcotest" "alcotest-lwt" "qcheck" "qcheck-core" "qcheck-alcotest"
    "qcheck-ounit" "qtest" "ounit" "ounit2" "benchmark"
    "crowbar" "afl-persistent"))           ; fuzzing test frameworks

(define (oxcaml-base-name name)
  (cond ((string-prefix? "oxcaml-" name) (substring name 7))
        ((string-prefix? "ocaml-" name) (substring name 6))
        (else name)))

(define (oxcaml-test-framework-input? input)
  ;; Handle both new-style (bare package) and old-style (label package ...).
  (let ((pkg (match input
               ((? package? p) p)
               ((_ (? package? p) _ ...) p)
               (_ #f))))
    (and pkg
         (member (oxcaml-base-name (package-name pkg)) %oxcaml-test-frameworks)
         #t)))

;; Per-package source fixes for oxcaml-specific incompatibilities, keyed by the
;; base (prefix-stripped) package name.  Each value is a list of modify-phases
;; clauses injected after 'unpack.  Applied by the hook at EVERY node, so a
;; transitively-pulled occurrence is fixed too -- a hand-defined oxcaml- variant
;; only fixes direct builds, never deps pulled through the auto-transform.
(define %oxcaml-source-fixes
  (list
   ;; iter: 143 higher-order combinators infer `@ local' params clashing with
   ;; the global .mli; drop the .mli so the interface follows the implementation.
   (cons "iter"
         '((add-after 'unpack 'oxcaml-iter-drop-mli
             (lambda _
               (for-each (lambda (f) (when (file-exists? f) (delete-file f)))
                         '("src/Iter.mli" "src/IterLabels.mli"))))))
   ;; yojson: point-free Buffer.add_string aliases infer `@ local'; eta-expand.
   (cons "yojson"
         '((add-after 'unpack 'oxcaml-yojson-eta-expand
             (lambda _
               (substitute* "lib/write.ml"
                 (("let write_intlit = Buffer.add_string")
                  "let write_intlit ob s = Buffer.add_string ob s")
                 (("let write_floatlit = Buffer.add_string")
                  "let write_floatlit ob s = Buffer.add_string ob s")
                 (("let write_stringlit = Buffer.add_string")
                  "let write_stringlit ob s = Buffer.add_string ob s"))))))
   ;; containers: one jkind annotation on CCList's List-include (oxcaml's List.t
   ;; is `value_or_null') + eta-expand the point-free stdlib aliases its CC*
   ;; modules use.  All oxcaml-only (base channel keeps the plain source).
   (cons "containers"
         '((add-after 'unpack 'oxcaml-containers-mode-fixes
             (lambda _
               (substitute* "src/core/CCList.mli"
                 (("with type 'a t := 'a list")
                  "with type ('a : value_or_null) t := 'a list"))
               (substitute* "src/core/CCChar.ml"
                 (("let pp_buf = Buffer.add_char")
                  "let pp_buf b c = Buffer.add_char b c")
                 (("let of_int_exn = Char.chr")
                  "let of_int_exn i = Char.chr i")
                 (("let to_int = Char.code")
                  "let to_int c = Char.code c"))
               (substitute* "src/core/CCArray.ml"
                 (("let fold = Array.fold_left")
                  "let fold f acc a = Array.fold_left f acc a"))
               (substitute* "src/core/CCParse.ml"
                 (("let string_equal = String.equal")
                  "let string_equal a b = String.equal a b"))
               (substitute* "src/core/CCString.ml"
                 (("let compare = String.compare")
                  "let compare a b = String.compare a b")
                 (("let length = String.length")
                  "let length s = String.length s")
                 (("let blit = String.blit")
                  "let blit s1 o1 b o2 n = String.blit s1 o1 b o2 n")
                 (("let iter = String.iter")
                  "let iter f s = String.iter f s"))))))
   ;; ocaml-compiler-libs (a ppxlib dep): read_cma.ml matches Cmo_format.cu_name
   ;; as `Compunit of string', but oxcaml/Flambda2 made it Compilation_unit.t.
   ;; Use the proper name accessor instead of the old variant pattern.
   (cons "compiler-libs"
         '((add-after 'unpack 'oxcaml-fix-read-cma
             (lambda _
               (substitute* "src/read_cma/read_cma.ml"
                 (("\\{ cu_name = Compunit name ; _ \\} = name")
                  "{ cu_name ; _ } = Compilation_unit.name_as_string cu_name"))))))))

;; Applied to every node of the rebuilt graph: force tests off, strip test
;; runners from ALL input fields (run, never linked -- safe, and handles channel
;; bugs like iter propagating qcheck/ounit2), and inject any per-package source
;; fix.  Doing this inside the recursion is what reaches transitive deps.
(define (oxcaml-drop-test-inputs pkg)
  (define (drop inputs)
    (filter (lambda (input) (not (oxcaml-test-framework-input? input))) inputs))
  ;; `fix' is cheap (package-name only).  Keep `args' INSIDE the thunked
  ;; arguments field below: computing it eagerly here would force the package's
  ;; #:dune promise (oxcaml-dune-bootstrap) at module-load time, before it is
  ;; defined, breaking the forward reference.
  (define fix
    (assoc-ref %oxcaml-source-fixes (oxcaml-base-name (package-name pkg))))
  (package
    (inherit pkg)
    (arguments
     (let ((args (ensure-keyword-arguments (package-arguments pkg)
                                           '(#:tests? #f))))
       (if fix
           (substitute-keyword-arguments args
             ((#:phases phases '%standard-phases)
              `(modify-phases ,phases ,@fix)))
           args)))
    (native-inputs (drop (package-native-inputs pkg)))
    (inputs (drop (package-inputs pkg)))
    (propagated-inputs (drop (package-propagated-inputs pkg)))))

;; The transform engine.  Uses the bootstrap dune (a complete dune that is
;; built with the ocaml-build-system and so needs no pre-existing dune) as the
;; build tool, which also avoids the dune-configurator dependency cycle.
;; The (delay ...) references are only forced at build time (arguments/inputs
;; are thunked record fields), so forward references below are fine.
(define-public package-with-oxcaml
  (package-with-explicit-ocaml (delay oxcaml)
                               (delay oxcaml-findlib)
                               (delay oxcaml-dune-bootstrap)
                               "ocaml-" "oxcaml-"
                               #:extra-transform oxcaml-drop-test-inputs))

;; dune, bootstrapped with oxcaml.
(define-public oxcaml-dune-bootstrap
  (package-with-oxcaml dune-bootstrap))

;; --- Curated oxcaml- library variants (start small; add as they build) ---

;; Minimal leaf (dune-build-system, no OCaml deps): proves the toolchain.
(define-public oxcaml-csexp
  (package-with-oxcaml ocaml-csexp))

(define-public oxcaml-seq
  (package-with-oxcaml ocaml-seq))

(define-public oxcaml-stdlib-shims
  (package-with-oxcaml ocaml-stdlib-shims))

(define-public oxcaml-sexplib0
  (package-with-oxcaml ocaml-sexplib0))

(define-public oxcaml-re
  (package-with-oxcaml ocaml-re))

(define-public oxcaml-result
  (package-with-oxcaml ocaml-result))

(define-public oxcaml-base
  (package-with-oxcaml ocaml-base))

(define-public oxcaml-stdio
  (package-with-oxcaml ocaml-stdio))

;; ocamlbuild's bytecode build didn't namespace its packed modules with
;; -for-pack (the native build does), so under oxcaml its `Bool' module
;; collided with Stdlib.Bool and the pack dropped it.  Fixed at the source in
;; the base `ocamlbuild' (its byte-for-pack phase), so the transform just
;; works -- no oxcaml-specific source override needed.
(define-public oxcaml-ocamlbuild
  (package-with-oxcaml ocamlbuild))

;; topkg libraries (build via ocamlbuild, fixed above).  These are longleaf's
;; direct dbuenzli deps; the transitive ones (logs, bos, fpath, rresult, uutf,
;; uucp, uuseg, mtime, hmap, topkg) build the same way once these are proven.
(define-public oxcaml-topkg (package-with-oxcaml ocaml-topkg))
(define-public oxcaml-astring (package-with-oxcaml ocaml-astring))
(define-public oxcaml-fmt (package-with-oxcaml ocaml-fmt))
(define-public oxcaml-ptime (package-with-oxcaml ocaml-ptime))
(define-public oxcaml-uuidm (package-with-oxcaml ocaml-uuidm))
(define-public oxcaml-hmap (package-with-oxcaml ocaml-hmap))
(define-public oxcaml-rresult (package-with-oxcaml ocaml-rresult))
(define-public oxcaml-logs (package-with-oxcaml ocaml-logs))
(define-public oxcaml-fpath (package-with-oxcaml ocaml-fpath))
(define-public oxcaml-mtime (package-with-oxcaml ocaml-mtime))
(define-public oxcaml-uutf (package-with-oxcaml ocaml-uutf))

;; dune-configurator built with oxcaml (via the bootstrap dune, so no cycle).
;; C-stub dune libs (lwt, cstruct, mirage-crypto) need `dune.configurator' at
;; build time; the transform's bootstrap dune doesn't propagate it like the
;; full dune does, so those libs must depend on this explicitly.
(define-public oxcaml-dune-configurator
  (package-with-oxcaml dune-configurator))

;; --- dune ecosystem ---
;; yojson: eta-expand mode fix is in %oxcaml-source-fixes (applied transitively);
;; the hook drops its alcotest dep.  cppo (preprocessor) is rebuilt with oxcaml.
(define-public oxcaml-yojson (package-with-oxcaml ocaml-yojson))

;; either/gen build (the hook strips their test frameworks; gen also needs the
;; dune-configurator native-input added in the base).
(define-public oxcaml-either (package-with-oxcaml ocaml-either))
(define-public oxcaml-gen (package-with-oxcaml ocaml-gen))
;; iter builds via the drop-mli fix in %oxcaml-source-fixes (its 143 higher-order
;; combinators infer `@ local'; the .mli is dropped so the interface follows the
;; impl).  The fix is in the table so it applies transitively (containers' iter).
(define-public oxcaml-iter (package-with-oxcaml ocaml-iter))
;; containers is a HARD multi-axis mode port (deferred).  Fixes that DO work are
;; in %oxcaml-source-fixes (value_or_null jkind on CCList's List-include + ~9
;; eta-expanded aliases), but deeper blockers remain: (1) inline partial
;; applications on the local axis (e.g. CCArray `_shuffle (Random.State.int st)
;; a ...`), and (2) the PORTABILITY axis -- `include module type of List' imports
;; oxcaml's `portable' List sig, but CCList's reimplemented fold_right/etc. are
;; `nonportable'.  (2) is pervasive (every reimplemented List fn).  longleaf opens
;; Containers globally, so this is critical-path but needs a real port (likely
;; drop-.mli for CCList/CCArray, or portability annotations).
(define-public oxcaml-containers (package-with-oxcaml ocaml-containers))

;; cstruct: C-stub lib (dune-build-system); alcotest test dep is auto-dropped by
;; the hook.  Foundational for the tls/x509/mirage-crypto stack longleaf uses.
(define-public oxcaml-cstruct (package-with-oxcaml ocaml-cstruct))

;; --- ppx tier (gates ppx_yojson_conv/ppx_deriving/... longleaf uses) ---
;; ppxlib is compiler-libs/AST-coupled; the big question is whether the channel's
;; ppxlib supports oxcaml's 5.2 AST.
(define-public oxcaml-ppxlib (package-with-oxcaml ocaml-ppxlib))

;; --- eio / TLS stack (base-free, so independent of the ppx/intrinsics skew) ---
(define-public oxcaml-base64 (package-with-oxcaml ocaml-base64))
(define-public oxcaml-domain-name (package-with-oxcaml ocaml-domain-name))
(define-public oxcaml-eqaf (package-with-oxcaml ocaml-eqaf))
(define-public oxcaml-mirage-crypto (package-with-oxcaml ocaml-mirage-crypto))
(define-public oxcaml-psq (package-with-oxcaml ocaml-psq))
(define-public oxcaml-eio (package-with-oxcaml ocaml-eio))
