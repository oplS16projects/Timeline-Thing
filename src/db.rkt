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
;; Database accessors
;; (timeline-author a-timeline)
;; (timeline-name a-timeline)
;; (timeline-timeline-id a-timeline)
;; (post-timeline-id a-post)
;; (post-date a-post)
;; (post-description a-post)
;; (post-time-created a-post)
;; (user-email a-user)
;; (user-password a-user)
;; (user-time-created a-user)
;; Takes a post id and returns the specified information
;;
;; (timeline-sort a-timeline)
;; Sorts all posts in a timeline by date in ascending order
;;
;; (timeline-insert-post! timeline-name timeline-id "Date" "Title")
;; Adds the post at the top of the timeline
;; Date should be in "Year/Month/Day" format for sorting purposes
;;
;; (timeline-delete-entry! timeline-name post-id)
;; (post-delete-entry! timeline-name post-id)
;; Deletes the object with the specified ID in the specified timeline

(require racket/list
         racket/date
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
                 "(id INTEGER PRIMARY KEY, author TEXT, name TEXT, time_created INTEGER)")))
  (define initial-timeline (timeline-insert-timeline! the-timeline "0" "Timeline1")) ;; Initial post so db is not void

  (unless (table-exists? db "posts")
    (query-exec db
                (string-append
                 "CREATE TABLE posts "
                 "(id INTEGER PRIMARY KEY, timeline_id INTEGER, date TEXT, description TEXT, time_created INTEGER)"))
      (timeline-insert-post! the-timeline initial-timeline "16/01/01" "Body of first post of first timeline"))

  (unless (table-exists? db "users")
    (query-exec db
                (string-append
                 "CREATE TABLE users "
                 "(id INTEGER PRIMARY KEY, email STRING, password STRING, time_created INTEGER)"))
      (users-insert-user! the-timeline "admin@opl.com" "admin"))
  the-timeline)

(define (users-insert-user! a-timeline email password)
  (define time_created (current-seconds))
  (query-exec
   (timeline-db a-timeline)
   "INSERT INTO users (email, password, time_created) VALUES (?, ?, ?)"
   email password time_created))


; timeline-posts : timeline -> (listof post?)
; Queries for a list of post ids
(define (timeline-posts a-timeline)
  (define (id->post an-id)
    (post a-timeline an-id))
  (map id->post
       (query-list
        (timeline-db a-timeline)
        "SELECT id FROM posts")))
 
; Database accessors
; Takes a database entry and returns the specified information from that
(define (timeline-author a-timeline)
  (query-value
   (timeline-db (post-timeline a-timeline))
   "SELECT author FROM timelines WHERE id = ?"
   (post-id a-timeline)))

(define (timeline-name a-timeline)
  (query-value
   (timeline-db (post-timeline a-timeline))
   "SELECT author FROM timelines WHERE id = ?"
   (post-id a-timeline)))

(define (timeline-time-created a-timeline)
  (query-value
   (timeline-db (post-timeline a-timeline))
   "SELECT time_created FROM timelines WHERE id = ?"
   (post-id a-timeline)))

(define (post-timeline-id a-post)
  (query-value
   (timeline-db (post-timeline a-post))
   "SELECT timeline_id FROM posts WHERE id = ?"
   (post-id a-post)))

(define (post-date a-post)
  (query-value
   (timeline-db (post-timeline a-post))
   "SELECT date FROM posts WHERE id = ?"
   (post-id a-post)))

(define (post-description a-post)
  (query-value
   (timeline-db (post-timeline a-post))
   "SELECT description FROM posts WHERE id = ?"
   (post-id a-post)))

(define (post-time-created a-post)
  (query-value
   (timeline-db (post-timeline a-post))
   "SELECT time_created FROM posts WHERE id = ?"
   (post-id a-post)))

(define (user-email a-user)
  (query-value
   (timeline-db (post-timeline a-user))
   "SELECT email FROM users WHERE id = ?"
   (post-id a-user)))

(define (user-password a-user)
  (query-value
   (timeline-db (post-timeline a-user))
   "SELECT email FROM posts WHERE id = ?"
   (post-id a-user)))

(define (user-time-created a-user)
  (query-value
   (timeline-db (post-timeline a-user))
   "SELECT time_created FROM users WHERE id = ?"
   (post-id a-user)))

; timeline-sort
; sorts a timeline by date
(define (timeline-sort a-timeline)
  (query-exec
   (timeline-db a-timeline)
   "SELECT * FROM posts ORDER BY date ASC"))
 
; timeline-insert-post!: timeline? string? string? -> void
; Consumes a timeline and a post, adds the post at the top of the timeline.
; Requires a timeline id (int), description (string) and time (int)
(define (timeline-insert-post! a-timeline timeline-id date body)
  (define time_created (current-seconds))
  (query-exec
   (timeline-db a-timeline)
   "INSERT INTO posts (timeline_id, date, description, time_created) VALUES (?, ?, ?, ?)"
   timeline-id date body time_created))

(define (timeline-insert-timeline! a-timeline author name)
  (define time_created (current-seconds))
  (query-exec
   (timeline-db a-timeline)
   "INSERT INTO timelines (author, name, time_created) VALUES (?, ?, ?)"
   author name time_created))

; deleting a database entry
; n is the id of the post to be deleted
(define (timeline-delete-entry! a-timeline n)
  (query-exec
   (timeline-db a-timeline)
   "DELETE FROM timelines (author, name, time_created) WHERE id = n"))

(define (posts-delete-entry! a-timeline n)
  (query-exec
   (timeline-db a-timeline)
   "DELETE FROM posts (timeline_id, description, time_created) WHERE id = n"))

(provide timeline? timeline-posts
         post? post-timeline-id post-description post-time-created
         initialize-timeline!
         timeline-insert-post!)
