#lang web-server/insta

(require web-server/templates)
(require xml)

;; Timeline
;; Jacob Suarez (@Onamar), Tyrone Turrel(@tturrell), Saurabh Verma (@sv-uml)

;;; Stuff goes here

(define (fast-template thing)
 (include-template "home.htm"))

(define (start request)
  (response/xexpr
   (string->xexpr (fast-template "Timeline Thing"))))
 
