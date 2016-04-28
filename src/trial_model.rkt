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
  (define db (sqlite3-connect #:database 'memory #:mode 'create))
  (define the-timeline (timeline db))
  (unless (table-exists? db "posts")
    (query-exec db
     (string-append
      "CREATE TABLE posts "
      "(id INTEGER PRIMARY KEY, title TEXT, body TEXT, content TEXT, date TEXT)"))
    (timeline-insert-post-initial!
     the-timeline  "AUTHOR  " "  DATE     " "       EVENT  " "  CONTENT"))
;;    (timeline-insert-post!
;;     the-timeline "Add Date" "This is another EVENT" "CONTENT" "DATE")
;;  (timeline-insert-post!
;;     the-timeline "Add Event" "This is another EVENT" "CONTENT" "DATE")
;;(timeline-insert-post!
;;     the-timeline "Add Content" "This is another EVENT"  "CONTENT" "DATE"))
;;  (unless (table-exists? db "comments")
;;    (query-exec db
;;     "CREATE TABLE comments (pid INTEGER, content TEXT)")
;;       (post-insert-comment!
;;     the-timeline (first (timeline-posts the-timeline))
;;     "First comment!"))
  the-timeline)
 
; timeline-posts : timeline -> (listof post?)
; Queries for the post ids
(define (timeline-posts a-timeline)
  (define (id->post an-id)
    (post a-timeline an-id))
  (map id->post
       (query-list
        (timeline-db a-timeline)
        "SELECT id FROM posts")))
 
; post-title : post -> string?
; Queries for the title
(define (post-title a-post)
  (query-value
   (timeline-db (post-timeline a-post))
   "SELECT title FROM posts WHERE id = ?"
   (post-id a-post)))
 
; post-body : post -> string?
; Queries for the body
(define (post-body p)
  (query-value
   (timeline-db (post-timeline p))
   "SELECT body FROM posts WHERE id = ?"
   (post-id p)))


; post-content : post -> string?
; Queries for the content
(define (post-content p)
  (query-value
   (timeline-db (post-timeline p))
   "SELECT content FROM posts WHERE id = ?"
   (post-id p)))

; post-date: post -> string?
; Queries for the date
(define (post-date p)
  (query-value
   (timeline-db (post-timeline p))
   "SELECT date FROM posts WHERE id = ?"
   (post-id p)))

; post-comments : post -> (listof string?)
; Queries for the comments
(define (post-comments p)
  (query-list
   (timeline-db (post-timeline p))
   "SELECT content FROM comments WHERE pid = ?"
   (post-id p)))


; timeline-insert-post!: timeline? string? string? string? string? -> void
; Consumes a timeline and a post, adds the post at the top of the timeline.
(define (timeline-insert-post! a-timeline title body content date)
  (query-exec
   (timeline-db a-timeline)
   "INSERT INTO posts (title, body, content, date) VALUES (?, ?, ?, ?)"
   title body content date))

; timeline-insert-post-initial!: timeline? string? string? string? string? -> void
; Consumes a timeline and a post, adds the post at the top of the timeline.
(define (timeline-insert-post-initial! a-timeline title body content date)
  (query-exec
   (timeline-db a-timeline)
   "INSERT INTO posts (title, body, content, date) VALUES (?, ?, ?, ?)"
   title body content date))
 
; post-insert-comment!: timeline? post string -> void
; Consumes a timeline, a post and a comment string.  As a side-efect, 
; adds the comment to the bottom of the post's list of comments.
;;(define (post-insert-comment! a-timeline p a-comment)
;;  (query-exec
;;   (timeline-db a-timeline)
;;   "INSERT INTO comments (pid, content) VALUES (?, ?)"
;;   (post-id p) a-comment))



(provide timeline? timeline-posts
         post? post-title post-body post-content
         post-comments post-date
         initialize-timeline! 
         timeline-insert-post!) ;;post-insert-comment!)