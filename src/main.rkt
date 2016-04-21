#lang racket

(require racket/runtime-path
         web-server/templates
         web-server/servlet
         web-server/servlet-env
         xml)

;; Runtime declarations
(define-runtime-path curr_dir ".")

;; Timeline
;; Jacob Suarez (@Onamar), Tyrone Turrel(@tturrell), Saurabh Verma (@sv-uml)

;;; Stuff goes here

(define (fast-template thing)
 (include-template "home.htm"))
 
(define (timeline-thing req)
  (response/xexpr
   (string->xexpr (fast-template "Timeline Thing"))))

(serve/servlet timeline-thing
               #:extra-files-paths
               (list
                (build-path curr_dir)))

(serve/servlet timeline-thing)