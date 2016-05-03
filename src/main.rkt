;; (c) Timeline-Things
;; https://github.com/oplS16projects/Timeline-Thing
#lang racket

(require "db.rkt"
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
(define CURR_VERSION 0.01)
(define FILE_VERSION_NAME "VERSION")
(define root (path->string (current-directory)))

(define (write-to-file path version_number)
  (call-with-output-file path
    #:exists 'replace
    (lambda (out-port)
      (write version_number out-port)))) ; how do you want to write string-list ?

;; Create/Update configuration file
(if (file-exists? FILE_VERSION_NAME)
    ;; file exists, so read it and increment the current version number by 0.01
    (begin
      (set! CURR_VERSION (+ (string->number (file->string FILE_VERSION_NAME)) 0.01))
      (write-to-file FILE_VERSION_NAME CURR_VERSION))

    ;; Else create file and set the value to whatever is current
    (write-to-file FILE_VERSION_NAME CURR_VERSION))

(define (fast-template
         title
         short_title
         curr_version)
 (include-template "home.htm"))

(define (timeline-thing req)
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
       (body (h1 ((class "title")) "1221")
             (div ((class "content-container"))
                  (h2 ((class "auth-title")) "Welcome back!")
                  (span ((class "auth-subtitle")) "Sign in to access your timelines")
                  (form ([action ,(embed/url upload-handler)]
                         [method "POST"]
                         [enctype "multipart/form-data"])
                         ,@(formlet-display file-upload-formlet)
                         (input ([type "text"] [placeholder "Email"]))
                         (input ([type "password"] [placeholder "Password"]))
                         (input ([type "submit"] [value "Sign In"])))
                  (span ((class "signup")) "Don't have an account?" (a ((class "signup-bold")) ((href ,(embed/url phase-2))) "Sign Up"))))
        (footer (span "&copy; 2016")
                (span "Build 0.11")))))
  (define (upload-handler request) (display "hello"))
  (define (show-signup-page request)
    (render-signup-page request))

  (send/suspend/dispatch response-generator))

(define (phase-2 request)
  (define (response-generator embed/url)
    (response/xepr
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
       (body (h1 ((class "title")) "1221")
             (div ((class "content-container"))
                  (h2 ((class "auth-title")) "Welcome back!")
                  (span ((class "auth-subtitle")) "Sign in to access your timelines")
                  (form ([action ,(embed/url upload-handler)]
                         [method "POST"]
                         [enctype "multipart/form-data"])
                         ,@(formlet-display file-upload-formlet)
                         (input ([type "text"] [placeholder "Email"]))
                         (input ([type "password"] [placeholder "Password"]))
                         (input ([type "submit"] [value "Sign In"])))
                  (span ((class "signup")) "Don't have an account?" (a ((class "signup-bold")) ((href "/signup.htm")) "Sign Up"))))
        (footer (span "&copy; 2016")
                (span "Build 0.11")))))
  (send/suspend/dispatch response-generator))

(define (render-signup-page request)
  (response/xepr
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
       (body (h1 ((class "title")) "1221")
             (div ((class "content-container"))
                  (h2 ((class "auth-title")) "Welcome back!")
                  (span ((class "auth-subtitle")) "Sign in to access your timelines")
                  (form ([action ,(embed/url upload-handler)]
                         [method "POST"]
                         [enctype "multipart/form-data"])
                         ,@(formlet-display file-upload-formlet)
                         (input ([type "text"] [placeholder "Email"]))
                         (input ([type "password"] [placeholder "Password"]))
                         (input ([type "submit"] [value "Sign In"])))
                  (span ((class "signup")) "Don't have an account?" (a ((class "signup-bold")) ((href "/signup.htm")) "Sign Up"))))
        (footer (span "&copy; 2016")
                (span "Build 0.11")))
     ))

;; Handle form submission
(define file-upload-formlet
  (formlet
   (#%# ,{input-string . => . email}
        ,{input-string . => . password})
   (values email password)))

;; Begin
(serve/servlet timeline-thing
               #:extra-files-paths
               (list
                (build-path CURR_DIR)))

(define TimelineThing (initialize-timeline! "timeline.db"))
; (timeline-insert-post! TimelineThing "Test_Title" "Wow cool")
; (timeline-posts TimelineThing)

(define (render-blog-page a-blog request)
  (response/xexpr
   `(html (head (title "My Blog"))
          (body (h1 "My Blog")
                ,(render-posts a-blog)))))