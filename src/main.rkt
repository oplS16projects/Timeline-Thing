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
(define logged-in 0)

(define TimelineThing (initialize-timeline! "timeline.db"))
(define CURR_VERSION 0)
(define retrieved_setting_version (app-retrieve-setting! TimelineThing "version"))
(cond ((string? retrieved_setting_version)
       (set! CURR_VERSION (+ (string->number retrieved_setting_version) 0.01)))
      ((number? retrieved_setting_version)
       (set! CURR_VERSION (+ retrieved_setting_version 0.01)))
      (else (set! CURR_VERSION 0.00)))
(app-update-setting! TimelineThing "version" CURR_VERSION)

;; Home-page scene
(define (home-page request)
  (define (response-generator embed/url)
    (if (= logged-in 0)
        (response/xexpr ;; NOT LOGGED IN
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
                (body (nav ((class "header single"))
                           (h1 ((class "title")) "Timeline Thing"))
                      (div ((class "content-container"))
                           (h2 ((class "auth-title")) "Welcome back!")
                           (span ((class "auth-subtitle")) "Sign in to access your timelines")
                           (form ([action ,(embed/url upload-handler)]
                                  [method "POST"])
                                 (input ([type "text"] [name "email"] [placeholder "Email"]))
                                 (input ([type "password"] [name "pass"] [placeholder "Password"]))
                                 (input ([type "submit"] [value "Sign In"])))
                           (span ((class "signup")) "Don't have an account? " (a ((href ,(embed/url signup-page))) "Sign Up"))))
                (footer (span "© 2016 Build ")
                        (span ,(number->string (string->number(real->decimal-string CURR_VERSION 3)))))))

        (response/xexpr ;; LOGGED IN
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
                (body ((class "loggedin"))
                      (nav ((class "header"))
                           (h1 ((class "title")) "Timeline Thing")
                           (a ([href ,(embed/url sign-out)]) "Sign Out"))
                      (div ((class "content-container"))
                           (h2 ((class "auth-title")) "You're logged in!")))
                (footer (span "© 2016 Build ")
                        (span ,(number->string (string->number(real->decimal-string CURR_VERSION 3)))))))))
    
  (define (upload-handler request)
    (define bindings (request-bindings request))
    (define email (extract-binding/single 'email bindings))
    (define password (extract-binding/single 'pass bindings))

    (if (= (users-authenticate-user! TimelineThing email password) 1)
        (set! logged-in 1) #f)
    (home-page (redirect/get)))
  (define (sign-out request)
    (begin
      (display (timelines-by-author TimelineThing 0))
      (set! logged-in 0))
    (signup-page (redirect/get)))
  (send/suspend/dispatch response-generator))

(define (signup-page request)
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
                (body (nav ((class "header single"))
                           (h1 ((class "title")) "Timeline Thing"))
                      (div ((class "content-container"))
                           (h2 ((class "auth-title")) "Welcome")
                           (span ((class "auth-subtitle")) "Sign up to create timelines")
                           (form ([action ,(embed/url upload-handler)]
                                  [method "POST"])
                                 (input ([type "text"] [name "email"] [placeholder "Email"]))
                                 (input ([type "password"] [name "pass"] [placeholder "Password"]))
                                 (input ([type "submit"] [value "Sign In"])))
                           (span ((class "signup")) "Already have an account? " (a ((href ,(embed/url home-page))) "Sign In"))))
                (footer (span "© 2016 Build ")
                        (span ,(number->string (string->number(real->decimal-string CURR_VERSION 3))))))))
  (define (upload-handler request)
    (define bindings (request-bindings request))
    (define email (extract-binding/single 'email bindings))
    (define password (extract-binding/single 'pass bindings))

    (if (users-insert-user! TimelineThing email password)
        (begin
          (set! logged-in 1)
          (home-page (redirect/get)))
        (signup-page (redirect/get))))
  (send/suspend/dispatch response-generator))

(define (logged-in-page request)
  (define (response-generator embed/url)
    (response/xexpr ;; LOGGED IN
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
                (body ((class "loggedin"))
                      (nav ((class "header"))
                           (h1 ((class "title")) "Timeline Thing")
                           (a ([href ,(embed/url sign-out)]) "Sign Out"))
                      (div ((class "content-container"))
                           (h2 ((class "auth-title")) "You're logged in!")))
                (footer (span "© 2016 Build ")
                        (span ,(number->string (string->number(real->decimal-string CURR_VERSION 3))))))))
  (define (sign-out request)
    (begin
      (display (timelines-by-author TimelineThing 0))
      (set! logged-in 0))
    (signup-page (redirect/get)))
  (send/suspend/dispatch response-generator))

;; Start the engine
(serve/servlet home-page
               #:extra-files-paths
               (list
                (build-path CURR_DIR)))