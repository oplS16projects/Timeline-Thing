#lang racket/base
(require racket/list
         db)
 
; A timeline is a (timeline db)
; where db is an sqlite connection
(struct timeline (db))


; A post is a (post timeline id)
; where timeline is a timeline and id is an integer?
(struct post (timeline id))
 
; initialize-timeline! : path? -> timeline?
; Sets up a timeline database (if it doesn't exist)
(define (initialize-timeline! home)
  (define db (sqlite3-connect #:database 'memory #:mode 'read/write))
  (define the-timeline (timeline db))
  (unless (table-exists? db "timeline")
    (query-exec db
     (string-append
      "CREATE TABLE timeline "
      "(id INTEGER PRIMARY KEY, date TEXT, author TEXT, event TEXT, content TEXT)"))
    (timeline-insert-post!
     the-timeline "19540403" "James" "Birthday" "Yeah!")
    (timeline-insert-post!
     the-timeline "19770125" "Tyrone" "Birthday" "YEAH!")
  (timeline-insert-post!
     the-timeline "19750509" "Heather" "Birthday" "YEAH!")
(timeline-insert-post!
     the-timeline "20160812" "Jeff" "Birthday" "YEAH!")
(timeline-insert-post!
     the-timeline "19880322" "Diane" "Birthday" "YEAH!")
(timeline-insert-post!
     the-timeline "20161012" "Clair" "Birthday" "YEAH!"))
  (unless (table-exists? db "comments")
    (query-exec db
     "CREATE TABLE comments (pid INTEGER, content TEXT)")
    (post-insert-comment!
     the-timeline (first (timeline-posts the-timeline))
     "First comment!"))
  the-timeline)


 

; timeline-posts : timeline -> (listof post?)
; Queries for the post ids
(define (timeline-posts a-timeline)
  (define (id->post an-id)
    (post a-timeline an-id))
  (map id->post
       (query-list
        (timeline-db a-timeline)
        "SELECT id FROM timeline")))

             
   
; post-author : post -> string?
; Queries for the author
(define (post-author a-post)
  (query-value
   (timeline-db (post-timeline a-post))
   "SELECT author FROM timeline WHERE id = ?"
   (post-id a-post)))
 
; post-date : post -> string?
; Queries for the date
(define (post-date p)
  (query-value
   (timeline-db (post-timeline p))
   "SELECT date FROM timeline WHERE id = ?"
   (post-id p)))


; post-event : post -> string?
; Queries for the event
(define (post-event p)
  (query-value
   (timeline-db (post-timeline p))
   "SELECT event FROM timeline WHERE id = ?"
   (post-id p)))
;; post-row
 (define (post-row p)
          (query-row
           (timeline-db (post-timeline p))
           "SELECT * FROM timeline WHERE id = ?"
           (post-id p)))

; post-content : post -> string?
; Queries for the content
(define (post-content p)
  (query-value
   (timeline-db (post-timeline p))
   "SELECT content FROM timeline WHERE id = ?"
   (post-id p)))



; post-comments : post -> (listof string?)
; Queries for the comments
(define (post-comments p)
  (query-list
   (timeline-db (post-timeline p))
   "SELECT content FROM comments WHERE pid = ?"
   (post-id p)))

; timeline-insert-post!: timeline? string? string? -> void
; Consumes a timeline and a post, adds the post at the top of the timeline.
(define (timeline-insert-post! a-timeline date author event content)
  (query-exec
   (timeline-db a-timeline)
   "INSERT INTO timeline (date, author, event, content) VALUES (?, ?, ?, ?)"
   date author event content))

; post-insert-comment!: timeline? post string -> void
; Consumes a timeline, a post and a comment string.  As a side-efect, 
; adds the comment to the bottom of the post's list of comments.
(define (post-insert-comment! a-timeline p a-comment)
  (query-exec
   (timeline-db a-timeline)
   "INSERT INTO comments (pid, content) VALUES (?, ?)"
   (post-id p) a-comment))


(provide timeline? timeline-posts timeline post-id post-row post?
         post? post-author post-date post-comments timeline-db
         initialize-timeline! post-event post-content post post-timeline
         timeline-insert-post! post-insert-comment!)