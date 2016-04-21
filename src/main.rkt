#lang racket

(require web-server/templates
         web-server/servlet
         web-server/servlet-env
         xml)

;; Timeline
;; Jacob Suarez (@Onamar), Tyrone Turrel(@tturrell), Saurabh Verma (@sv-uml)

;;; Stuff goes here

(define (fast-template thing)
 (include-template "home.htm"))
 
(define (timeline-thing req)
  (response/xexpr
   (string->xexpr (fast-template "Timeline Thing"))))

(serve/servlet timeline-thing)