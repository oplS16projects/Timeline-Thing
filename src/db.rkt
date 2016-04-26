#lang racket/base

;; Basic database structure

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

;; Possibly replace sqlite3 with a mysql connection?
 (define (initialize-timeline! user home password)
;;(define (initialize-timeline! home)
;;(define db (sqlite3-connect #:database home #:mode 'create))
   (define db (mysql-connect #:user user #:database home #:password password))
   (define the-timeline (timeline db))
   (unless (table-exists? db "posts")
     (query-exec db
                 (string-append
                  "CREATE TABLE posts "
                  "(id INTEGER PRIMARY KEY, title TEXT, body TEXT)"))
     (timeline-insert-post!
      the-timeline "First Post" "This is a test of the database."))
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
 
; timeline-insert-post!: timeline? string? string? -> void
; Consumes a timeline and a post, adds the post at the top of the timeline.
(define (timeline-insert-post! a-timeline title body)
  (query-exec
   (timeline-db a-timeline)
   "INSERT INTO posts (title, body) VALUES (?, ?)"
   title body))

(provide timeline? timeline-posts
         post? post-title post-body
         initialize-timeline!
         timeline-insert-post!)
