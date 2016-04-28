;; (c) Timeline-Things
;; https://github.com/oplS16projects/Timeline-Thing
#lang racket

(require "db.rkt"
         racket/include
         racket/runtime-path
         racket/date
         web-server/templates
         web-server/servlet
         web-server/servlet-env
         web-server/http
         parser-tools/lex
         xml)

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
  (response/xexpr
   (string->xexpr (fast-template
                   "Timeline Thing"
                   "Timeline"
                   (string->number(real->decimal-string CURR_VERSION 3))))))

(serve/servlet timeline-thing
               #:extra-files-paths
               (list
                (build-path CURR_DIR)))

;(define TimelineThing (initialize-timeline! "timeline.db"))
; (timeline-insert-post! TimelineThing "Test_Title" "Wow cool")
; (timeline-posts TimelineThing)

(serve/servlet timeline-thing)
