;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 John

;;; Claude Code - Anthropic's agentic coding CLI tool
;;; This package wraps the prebuilt binary from Anthropic's distribution.
;;;
;;; We patch only the ELF interpreter to point to Guix's ld-linux,
;;; which allows the bundled Bun binary to run correctly.

(define-module (gnu packages claude-code)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module (gnu packages base)
  #:use-module (gnu packages elf)
  #:use-module ((guix licenses) #:prefix license:))

(define-public claude-code
  (package
    (name "claude-code")
    (version "2.1.158")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://storage.googleapis.com/claude-code-dist-"
                    "86c565f3-f756-42ad-8dfa-d59b1c096819/"
                    "claude-code-releases/" version "/linux-x64/claude"))
              (file-name (string-append "claude-" version "-linux-x64"))
              (sha256
               (base32
                "1gkz05k6hynmapg4svbqw2dby17n7z42wrb2ayn0nw22rn5009yx"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan #~'()
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:phases
      #~(modify-phases %standard-phases
          (replace 'install
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (bin (string-append out "/bin"))
                     (patchelf (string-append (assoc-ref inputs "patchelf") "/bin/patchelf"))
                     (ld-linux (string-append (assoc-ref inputs "glibc") "/lib/ld-linux-x86-64.so.2"))
                     (source (string-append "claude-" #$version "-linux-x64"))
                     (target (string-append bin "/claude")))
                (mkdir-p bin)
                (copy-file source target)
                (chmod target #o755)
                ;; Patch only the interpreter, not RPATH
                (invoke patchelf "--set-interpreter" ld-linux target)))))))
    (native-inputs
     (list patchelf))
    (inputs
     (list glibc))
    (supported-systems '("x86_64-linux"))
    (home-page "https://github.com/anthropics/claude-code")
    (synopsis "Anthropic's agentic coding CLI tool")
    (description
     "Claude Code is an agentic coding tool that lives in your terminal,
understands your codebase, and helps you code faster by executing routine
tasks, explaining complex code, and handling git workflows - all through
natural language commands.  This package provides the prebuilt native binary
which does not require Node.js.")
    (license license:expat)))
