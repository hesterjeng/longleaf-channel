;; Longleaf Channel - All Package Definitions
(define-module (longleaf-packages)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix build-system dune)
  #:use-module (guix build-system python)
  #:use-module (guix build-system pyproject)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages node)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages finance)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-science)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages time)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages protobuf)
  #:use-module (gnu packages statistics)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages ocaml))

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
;;; OCaml Packages

;; tacaml - OCaml bindings for TA-Lib
(define-public tacaml
(package
 (name "ocaml-tacaml")
 (version "1.0.1")
 (source (github-tag-origin "tacaml"
                            "https://github.com/hesterjeng/tacaml"
                            version
			    "0xvgy43yqrfd85c6dpyffff5dqj6idvcxcv5gn6argcai145cwr1"
                            "v"))
 (build-system dune-build-system)
 (arguments
  `(#:test-target "."))
 (native-inputs
  (list ocaml-odoc))
 (propagated-inputs
  (list ocaml
        dune
        ocaml-ctypes
        ocaml-ppx-deriving
        ocaml-ppx-hash
        ta-lib
        pkg-config))
 (home-page "https://github.com/hesterjeng/tacaml")
 (synopsis "OCaml bindings for TA-Lib technical analysis library")
 (description
  "tacaml provides OCaml bindings to the TA-Lib (Technical Analysis Library).
This project offers both raw C bindings and higher-level, type-safe wrappers
for over 160 technical analysis functions commonly used in financial markets.
Features include comprehensive bindings, type safety with GADTs, efficient
data handling with Bigarray integration, modular design, and robust error
handling with Result types.")
 (license license:gpl3+)))

;; Full Longleaf package with all dependencies
(define-public longleaf
(package
 (name "longleaf")
 (version "cohttp")
 (source
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/hesterjeng/longleaf.git")
          (commit "cohttp")))
    (file-name (git-file-name name version))
    (sha256
     (base32 "1ckg348c95la77xpnj3lp35g4pwbb7kfrl7k379wgs0ajw6cc1ap"
	     ))))
 (build-system dune-build-system)
 (native-inputs
  (list ocaml-alcotest ocaml-odoc))
 (propagated-inputs
  (list
        ocaml-ptime
        ocaml-ppx-yojson-conv-lib
        ocaml-ppx-deriving
        ocaml-ppx-variants-conv
        ocaml-ppx-fields-conv
        ocaml-cmdliner
        ocaml-graph
        ocaml-eio-main
        tacaml
        ocaml-fileutils
        ocaml-yojson
        ocaml-uuidm
        ocaml-tyxml
        ocaml-alcotest))
 (home-page "https://github.com/hesterjeng/longleaf")
 (synopsis "Algorithmic trading platform written in OCaml")
 (description
  "Longleaf is an algorithmic trading platform that supports live trading,
paper trading, and backtesting with multiple brokerages and market data sources.
The platform uses a functional, modular architecture with strategies implemented
as functors for maximum code reuse and type safety.

The platform includes tacaml for TA-Lib technical analysis bindings.")
 (license license:gpl3+)))

;;; Python Packages

;; multitasking - Non-blocking Python methods using decorators
(define-public python-multitasking
  (package
   (name "python-multitasking")
   (version "0.0.12")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://files.pythonhosted.org/packages/source/m/multitasking/multitasking-"
                         version ".tar.gz"))
     (sha256
      (base32 "1lc4kcs5fnhp2rrr4izjnviqsrbx3k27vpf54zi8ajwcxnl2zfig"))))
   (build-system python-build-system)
   (arguments
    '(#:tests? #f))  ; No tests included in source
   (home-page "https://github.com/ranaroussi/multitasking")
   (synopsis "Non-blocking Python methods using decorators")
   (description
    "MultiTasking is a lightweight Python library that lets you convert your
Python methods into asynchronous, non-blocking methods simply by using a
decorator.  Perfect for I/O-bound tasks, API calls, web scraping, and any
scenario where you want to run multiple operations concurrently without the
complexity of manual thread or process management.")
   (license license:asl2.0)))

;; yfinance - Market data downloader
;; NOTE: Pinned to v0.2.57 to avoid curl_cffi dependency introduced in v0.2.58+
(define-public python-yfinance
  (package
   (name "python-yfinance")
   (version "0.2.57")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://files.pythonhosted.org/packages/source/y/yfinance/yfinance-"
                         version ".tar.gz"))
     (sha256
      (base32 "1cgkch19a1rn175ixd8180a47dnc8nmwljyj2538s55ijyd385kv"))))
   (build-system python-build-system)
   (arguments
    '(#:tests? #f     ; Skip tests that require network access
      #:phases
      (modify-phases %standard-phases
                     (delete 'sanity-check))))  ; Skip sanity check that enforces curl_cffi dependency
   (propagated-inputs
    (list python-pandas
          python-numpy
          python-requests
          python-lxml
          python-appdirs
          python-pytz
          python-beautifulsoup4
          python-websockets
          python-protobuf
          python-frozendict
          python-peewee))
   (home-page "https://github.com/ranaroussi/yfinance")
   (synopsis "Download market data from Yahoo! Finance API")
   (description
    "yfinance is a Python library that offers a threaded and Pythonic way
to download market data from Yahoo! Finance.  It fixes the temporary
authentication and decryption issues by dynamically scraping the data.")
   (license license:asl2.0)))

;; quantstats - Portfolio analytics for quants
(define-public python-quantstats
  (package
   (name "python-quantstats")
   (version "0.0.75")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://github.com/ranaroussi/quantstats/archive/"
                         version ".tar.gz"))
     (file-name (string-append name "-" version ".tar.gz"))
     (sha256
      (base32 "04a8r3rr36asij0dw31crvzj15xzz972drk48f9a80py0ha7431s"))))
   (build-system python-build-system)
   (arguments
    '(#:tests? #f     ; Skip tests that require yfinance network access
      #:phases
      (modify-phases %standard-phases
                     (delete 'sanity-check))))  ; Skip sanity check that enforces yfinance curl_cffi dependency
   (propagated-inputs
    (list python-pandas
          python-numpy
          python-scipy
          python-matplotlib
          python-seaborn
          python-tabulate
          python-dateutil
          python-packaging
          python-yfinance
          python-multitasking
          python-ipython))
   (home-page "https://github.com/ranaroussi/quantstats")
   (synopsis "Portfolio analytics for quants")
   (description
    "QuantStats is a Python library that performs portfolio analytics for quants.
It provides in-depth analytics and risk metrics for quantitative analysts
and portfolio managers including Sharpe ratio, win rate, volatility, drawdowns,
rolling statistics, monthly returns, and various performance tear sheets.")
   (license license:asl2.0)))

;; Development environment - provides Python environment for server
(define-public longleaf-quantstats-dev
  (package
   (name "longleaf-quantstats-dev")
   (version "0.1.0")
   (source (local-file "." "longleaf-quantstats-source"
                       #:recursive? #t))
   (build-system pyproject-build-system)
   (arguments
    '(#:phases
      (modify-phases %standard-phases
                     (delete 'configure)
                     (delete 'build)
                     (delete 'check)
                     (replace 'install
                              (lambda* (#:key outputs #:allow-other-keys)
                                (let ((out (assoc-ref outputs "out")))
                                  (copy-recursively "." (string-append out "/share/longleaf-quantstats"))
                                  #t))))))
   (propagated-inputs
    (list python
          python-quantstats
          python-pandas
          python-numpy
          python-frozendict))
   (home-page "https://github.com/hesterjeng/longleaf")
   (synopsis "Longleaf QuantStats server development environment")
   (description
    "Development package for Longleaf QuantStats FastAPI server. Provides Python
environment with all dependencies for portfolio analytics and reporting.")
   (license license:gpl3+)))

;;; Frontend Packages

;; Development package - provides Node.js environment for npm workflow
(define-public longleaf-frontend-dev
  (package
    (name "longleaf-frontend-dev")
    (version "0.1.0")
    (source (local-file "." "longleaf-frontend-source"
                        #:recursive? #t
                        #:select? (lambda (file stat)
                                    (not (string-contains file "node_modules")))))
    (build-system gnu-build-system)
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (delete 'build)
         (delete 'check)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (copy-recursively "." (string-append out "/share/longleaf-frontend"))
               #t))))))
    (propagated-inputs
     (list node))
    (home-page "https://github.com/hesterjeng/longleaf")
    (synopsis "Longleaf React frontend development environment")
    (description
     "Development package for Longleaf React frontend. Provides Node.js and npm
for running 'npm install' and 'npm start' in the React directory.")
    (license license:gpl3+)))

;; Production package - built static files
(define-public longleaf-frontend
  (package
    (name "longleaf-frontend")
    (version "0.1.0")
    (source (local-file "build" "longleaf-frontend-build"
                        #:recursive? #t))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan
       '(("." "share/longleaf/static"))))
    (home-page "https://github.com/hesterjeng/longleaf")
    (synopsis "Longleaf React frontend (built)")
    (description
     "Pre-built React dashboard for Longleaf trading platform. Contains
static HTML, CSS, and JavaScript files ready for serving.")
    (license license:gpl3+)))
