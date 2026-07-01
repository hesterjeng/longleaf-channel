;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 John

;;; Crush - Charm's terminal-based AI coding assistant, built from source.
;;;
;;; Crush is a Go module with ~260 dependencies.  Rather than package every
;;; dependency as a separate Guix package, we vendor them in a fixed-output
;;; derivation (CRUSH-VENDOR).  Fixed-output derivations are allowed network
;;; access, so `go mod vendor' can download the exact pinned versions from the
;;; Go module proxy; the result is content-addressed by CRUSH-VENDOR-HASH.
;;; The main build then runs fully offline with GO111MODULE=on and
;;; -mod=vendor.  This is the Guix analogue of Nix's `vendorHash'.
;;;
;;; Updating: bump VERSION + the source hash, set CRUSH-VENDOR-HASH to a string
;;; of 52 zeros, run `guix build -f ...' (or `guix build crush'), and paste the
;;; "expected ... obtained ..." hash Guix reports back into CRUSH-VENDOR-HASH.

(define-module (gnu packages crush)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix build-system go)
  #:use-module (guix utils)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages golang)
  #:use-module (gnu packages version-control)
  #:use-module ((guix licenses) #:prefix license:))

(define %crush-version "0.81.0")

(define %crush-source
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/charmbracelet/crush")
          (commit (string-append "v" %crush-version))))
    (file-name (git-file-name "crush" %crush-version))
    (sha256
     (base32 "0s0dh7wsw8bcsmakbzg6lszwiwdsyq682crjlxi5fns31h4y9sql"))))

;; base32 sha256 of the vendored module tree.  Fill in after the first build
;; (see the "Updating" note above).
(define %crush-vendor-hash
  "0qjjb3p15yghzi7mybrsr8q5zz93vssja9fxcwpi25m29b4fy0g2")

(define crush-vendor
  ;; Fixed-output derivation: the fully vendored Go dependency tree.
  (computed-file
   (string-append "crush-" %crush-version "-vendor")
   (with-imported-modules '((guix build utils))
     #~(begin
         (use-modules (guix build utils))
         (setenv "PATH"
                 (string-append #$(file-append go-1.26 "/bin") ":"
                                #$(file-append git-minimal "/bin")))
         (setenv "HOME" "/tmp")
         (setenv "GOPATH" "/tmp/gopath")
         (setenv "GOCACHE" "/tmp/gocache")
         (setenv "GOMODCACHE" "/tmp/gomod")
         (setenv "GOTOOLCHAIN" "local")
         (setenv "CGO_ENABLED" "0")
         (setenv "GOPROXY" "https://proxy.golang.org,direct")
         ;; HTTPS trust for the module proxy (Go reads SSL_CERT_DIR; git, if a
         ;; module needs VCS, reads GIT_SSL_CAPATH -- a dir of hashed certs).
         (setenv "SSL_CERT_DIR" #$(file-append nss-certs "/etc/ssl/certs"))
         (setenv "GIT_SSL_CAPATH" #$(file-append nss-certs "/etc/ssl/certs"))
         (copy-recursively #$%crush-source "/tmp/src")
         (chdir "/tmp/src")
         (invoke "go" "mod" "vendor")
         (copy-recursively "/tmp/src/vendor" #$output)))
   #:options `(#:hash-algo sha256
               #:hash ,(base32 %crush-vendor-hash)
               #:recursive? #t
               #:local-build? #t)))

(define-public crush
  (package
    (name "crush")
    (version %crush-version)
    (source %crush-source)
    (build-system go-build-system)
    (arguments
     (list
      #:go go-1.26
      #:import-path "github.com/charmbracelet/crush"
      #:install-source? #f
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (replace 'build
            (lambda* (#:key import-path #:allow-other-keys)
              (with-directory-excursion (string-append "src/" import-path)
                ;; Drop in the pre-fetched, hash-pinned dependencies and build
                ;; offline in module + vendor mode.
                (copy-recursively #$crush-vendor "vendor")
                (setenv "GO111MODULE" "on")
                (setenv "GOFLAGS" "-mod=vendor")
                (setenv "GOPROXY" "off")
                (setenv "GOTOOLCHAIN" "local")
                (setenv "CGO_ENABLED" "0")
                (setenv "GOCACHE" (string-append (getcwd) "/.gocache"))
                (invoke "go" "build"
                        "-trimpath"
                        "-ldflags"
                        (string-append
                         "-s -w -X github.com/charmbracelet/crush"
                         "/internal/version.Version=v" #$version)
                        "-o" "crush"
                        "."))))
          (replace 'install
            (lambda* (#:key import-path outputs #:allow-other-keys)
              (install-file
               (string-append "src/" import-path "/crush")
               (string-append (assoc-ref outputs "out") "/bin")))))))
    ;; nss-certs is referenced directly in the vendor FOD (build-time HTTPS
    ;; trust) and is not needed at runtime, so it is not an input here.
    (home-page "https://github.com/charmbracelet/crush")
    (synopsis "Terminal-based AI coding assistant")
    (description
     "Crush is a terminal-based AI coding assistant by Charm.  It provides an
interactive TUI for working with large language models, tools, LSP servers, and
MCP servers directly from the terminal.  This package builds the @command{crush}
binary from source.")
    (license license:expat)))

crush
