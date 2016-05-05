;; (c) Timeline-Things
;; https://github.com/oplS16projects/Timeline-Thing
#lang racket

(require "db.rkt"
         racket/format
         racket/include
         racket/runtime-path
         racket/date
         web-server/formlets
         web-server/templates
         web-server/servlet
         web-server/servlet-env
         web-server/http
         parser-tools/lex
         xml)

;; github test
;; Runtime declarations
(define-runtime-path CURR_DIR ".")
(define root (path->string (current-directory)))

(define TimelineThing (initialize-timeline! "timeline.db"))
(define CURR_VERSION 0)
(define retrieved_setting_version (app-retrieve-setting! TimelineThing "version"))
(cond ((string? retrieved_setting_version)
       (set! CURR_VERSION (+ (string->number retrieved_setting_version) 0.01)))
      ((number? retrieved_setting_version)
       (set! CURR_VERSION (+ retrieved_setting_version 0.01)))
      (else (set! CURR_VERSION 0.00)))
(app-update-setting! TimelineThing "version" CURR_VERSION)
(display CURR_VERSION)

;; Home-page scene
(define (home-page request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Timeline Thing")
             (link ((rel "stylesheet")
                    (href "https://fonts.googleapis.com/css?family=Open+Sans")
                    (type "text/css")))
             (link ((rel "stylesheet")
                    (href "https://fonts.googleapis.com/css?family=Pacifico")
                    (type "text/css")))
             (link ((rel "stylesheet")
                    (href "/style.css")
                    (type "text/css"))))
       (body (h1 ((class "title")) "Timeline Thing")
             (div ((class "content-container"))
                  (h2 ((class "auth-title")) "Welcome back!")
                  (span ((class "auth-subtitle")) "Sign in to access your timelines")
                  (form ([action ,(embed/url upload-handler)]
                         [method "POST"]
                         [enctype "multipart/form-data"])
                         (input ([type "text"] [name "email"] [placeholder "Email"]))
                         (input ([type "password"] [name "pass"] [placeholder "Password"]))
                         (input ([type "submit"] [value "Sign In"])))
                  (span ((class "signup")) "Don't have an account? " (a ((href ,(embed/url signup-page))) "Sign Up"))))
        (footer (span "© 2016 Build ")
                (span ,(number->string CURR_VERSION))))))
  (define (upload-handler request)
    (define bindings (request-bindings request))
    (display (extract-binding/single 'email bindings))
    (display (extract-binding/single 'pass bindings)))
  (send/suspend/dispatch response-generator))

(define (signup-page request)
  (define (response-generator embed/url)
    (response/xexpr
          `(html (head (title "SIGNUP Thing")
             (link ((rel "stylesheet")
                    (href "https://fonts.googleapis.com/css?family=Open+Sans")
                    (type "text/css")))
             (link ((rel "stylesheet")
                    (href "https://fonts.googleapis.com/css?family=Pacifico")
                    (type "text/css")))
             (link ((rel "stylesheet")
                    (href "/style.css")
                    (type "text/css"))))
       (body (h1 ((class "title")) "SIGNUP"))
        (footer (span "© 2016 Build ")
                (span ,(number->string CURR_VERSION))))))
  (send/suspend/dispatch response-generator))

;; Start the engine
(serve/servlet home-page
               #:extra-files-paths
               (list
                (build-path CURR_DIR)))