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
;; (timeline-author a-timeline) etc
;; Takes a post id and returns the specified information
;;
;; (timeline-sort a-timeline order)
;; Sorts a given timeline
;; To sort by ascending or decending, the second argument should be "up" or "down"
;;
;; (timeline-insert-post! timeline-name "Title" "Body of post")
;; Adds the post at the top of the timeline
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
(struct timelines (timeline id))

; initialize-timeline! : path? -> timeline?
; Sets up a timeline database (if it doesn't exist)
(define (initialize-timeline! home)
  (define db (sqlite3-connect #:database home #:mode 'create))
  (define the-timeline (timeline db))
  (define initial-timeline -2)
  (unless (table-exists? db "timelines")
    (query-exec db
                (string-append
                 "CREATE TABLE timelines "
                 "(id INTEGER PRIMARY KEY, author INTEGER, name TEXT, time_created INTEGER)"))
    (set! initial-timeline (- (timeline-insert-timeline! the-timeline 0 "Timeline1" (current-seconds)) 1))) ;; Initial post so db is not void)

  (unless (table-exists? db "posts")
    (query-exec db
                (string-append
                 "CREATE TABLE posts "
                 "(id INTEGER PRIMARY KEY, timeline_id INTEGER, description TEXT, time_created INTEGER)"))
    (timeline-insert-post! the-timeline initial-timeline "Body of first post of first timeline" (current-seconds)))

  (unless (table-exists? db "users")
    (query-exec db
                (string-append
                 "CREATE TABLE users "
                 "(id INTEGER PRIMARY KEY, email STRING, password STRING, time_created INTEGER)"))
    (users-insert-user! the-timeline "admin@opl.com" "admin"))

  (unless (table-exists? db "app_settings")
    (query-exec db
                (string-append
                 "CREATE TABLE app_settings "
                 "(id INTEGER PRIMARY KEY, key STRING, value STRING)"))
    (app-insert-setting! the-timeline "version" 0.01))
  the-timeline)

;; USERS
(define (users-insert-user! a-timeline email password)
  (define time_created (current-seconds))
  (query-exec
   (timeline-db a-timeline)
   "INSERT INTO users (email, password, time_created) VALUES (?, ?, ?)"
   email password time_created))

(define (users-authenticate-user! a-timeline email password)
  (if (> (query-value (timeline-db a-timeline)
                                   "SELECT COUNT(id) FROM users WHERE email = ? AND password = ?" email password)
         0)
      1 -1))

; timeline-posts : timeline -> (listof post?)
; Queries for a list of post ids
(define (timeline-posts a-timeline)
  (define (id->post an-id)
    (post a-timeline an-id))
  (map id->post
       (query-list
        (timeline-db a-timeline)
        "SELECT id FROM posts")))

; timeline-list : timeline -> '(list of timelines)
; Queries for a list of timeline ids
(define (timeline-list a-timeline)
  (define (id->timelines an-id)
    (timelines a-timeline an-id))
  (map id->timelines
       (query-list
        (timeline-db a-timeline)
        "SELECT id FROM timelines")))

; timelines-by-author : timeline -> '(list of ids)
; Queries for a list of ids of timelines from a specific author
(define (timelines-by-author a-timeline author)
  (query-list
   (timeline-db a-timeline)
   "SELECT id FROM timelines WHERE author = ?"
   author))
           
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
; Sorts a given timeline
; To sort by ascending or decending, the second argument should be "up" or "down"
(define (timeline-sort a-timeline order)
  (cond ((eqv? order "up") (query-exec
                            (timeline-db a-timeline)
                            "SELECT * FROM posts ORDER BY time_created ASC"))
        ((eqv? order "down") (query-exec
                            (timeline-db a-timeline)
                            "SELECT * FROM posts ORDER BY time_created DESC"))))
 
; timeline-insert-post!: timeline? string? string? -> void
; Consumes a timeline and a post, adds the post at the top of the timeline.
; Requires a timeline id (int), post body (string) and time (int)
(define (timeline-insert-post! a-timeline timeline-id body time)
  (query-exec
   (timeline-db a-timeline)
   "INSERT INTO posts (timeline_id, description, time_created) VALUES (?, ?, ?)"
   timeline-id body time))

(define (timeline-insert-timeline! a-timeline author name time)
  (if (query-exec
   (timeline-db a-timeline)
   "INSERT INTO timelines (author, name, time_created) VALUES (?, ?, ?)"
   author name time)
      (query-value (timeline-db a-timeline)
                   "SELECT COUNT(id) FROM timelines") -1))

; deleting a database entry
; n is the id of the post to be deleted
(define (timeline-delete-entry! a-timeline n)
  (query-exec
   (timeline-db a-timeline)
   "DELETE FROM timelines (author, name, time_created) WHERE id = ?" n))

(define (posts-delete-entry! a-timeline n)
  (query-exec
   (timeline-db a-timeline)
   "DELETE FROM posts (timeline_id, description, time_created) WHERE id = ?" n))

;; Application-related functions
(define (app-insert-setting! a-timeline key value)
  (if (query-exec (timeline-db a-timeline)
   "INSERT INTO app_settings (key, value) VALUES (?, ?)" key value) 1 -1))

(define (app-retrieve-setting! a-timeline key)
  (query-value (timeline-db a-timeline)
                   "SELECT value FROM app_settings WHERE key = ?" key))
  
(define (app-update-setting! a-timeline key value)
  (if (query-exec
   (timeline-db a-timeline)
   "UPDATE app_settings SET value = ? WHERE key = ?" value key) 1 -1))

(provide timeline? timeline-posts
         post? post-timeline-id post-description post-time-created
         initialize-timeline!
         timeline-insert-post!
         app-insert-setting! app-retrieve-setting! app-update-setting!
         users-insert-user! users-authenticate-user!)