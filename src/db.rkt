#lang racket/base

;; Basic database structure

;; ----INSTRUCTIONS----
;;
;; Initializing an empty timeline object
;; (define example-timeline (initialize-timeline! "path/to/filename"))
;; The path to filename in for our purposes should just be "timeline.db" by default.
;; You'll need to create a timeline.db file in the same folder as this file for the
;; Database to initialize into
;;
;; After that everything should be self explanatory, fromt he comments above each function
;; but I'll do a more detailed explanation of their usage
;;
;; (timeline-posts timeline-name)
;; Returns a list of post IDs
;; To use a specific ID with post-title, post-body, and delete-entry!, use cdr and cdr.
;; Example:
;; (car (timeline-posts timeline)) would return the id of the first post in timeline
;; (post-title (car (timeline-posts timeline))) would return the title of that post as a string
;;
;; (post-title post-id)
;; Returns the title of the post with the specified ID
;;
;; (post-body post-id)
;; Returns the body of the post with the specified ID
;;
;; (timeline-insert-post! timeline-name "Title" "Body of post")
;; Adds the post at the top of the timeline
;;
;; (delete-entry! timeline-name post-id)
;; Deletes the post with the specified ID in the specified timeline

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
  (define db (sqlite3-connect #:database home #:mode 'create))
  (define the-timeline (timeline db))
  (unless (table-exists? db "timelines")
    (query-exec db
                (string-append
                 "CREATE TABLE timelines "
                 "(id INTEGER PRIMARY KEY, author INTEGER, name TEXT, time_created INTEGER)")))
  (define initial-timeline (timeline-insert-timeline! the-timeline 0 "Timeline1")) ;; Initial post so db is not void

  (unless (table-exists? db "posts")
    (query-exec db
                (string-append
                 "CREATE TABLE posts "
                 "(id INTEGER PRIMARY KEY, timeline_id INTEGER, description TEXT, time_created INTEGER)"))
      (timeline-insert-post! the-timeline initial-timeline "Body of first post of first timeline" (current-seconds)))
  the-timeline)

; timeline-posts : timeline -> (listof post?)
; Queries for a list of post ids
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
; Requires a timeline id (int), post body (string) and time (int)
(define (timeline-insert-post! a-timeline timeline-id body time)
  (query-exec
   (timeline-db a-timeline)
   "INSERT INTO posts (timeline_id, description, time_created) VALUES (?, ?, ?)"
   timeline-id body time))

(define (timeline-insert-timeline! a-timeline author name)
  (define time_created 1461796513)
  (if (query-exec
   (timeline-db a-timeline)
   "INSERT INTO timelines (author, name, time_created) VALUES (?, ?, ?)"
   author name time_created)
      (query-value (timeline-db a-timeline)
                   "SELECT last_insert_rowid() FROM timelines") -1))

; deleting a database entry
; n is the id of the post to be deleted
(define (delete-entry! a-timeline n)
  (query-exec
   (timeline-db a-timeline)
   "DELETE FROM posts (title, body) WHERE id = n"))

(provide timeline? timeline-posts
         post? post-title post-body
         initialize-timeline!
         timeline-insert-post!)
