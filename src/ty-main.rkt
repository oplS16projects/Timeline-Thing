#lang web-server/insta
 
(require web-server/formlets
         "ty-model.rkt")
(require racket/list db )
 
; start: request -> doesn't return
; Consumes a request and produces a page that displays
; all of the web content.
(define (start request)
  (render-timeline-page
   (initialize-timeline!
    (build-path (current-directory)
                "timeline.sqlite"))
   request))
 
; new-post-formlet : formlet (values string? string?)
; A formlet for requesting a author and date of a post
(define new-post-formlet
  (formlet
   (#%# ,{input-string . => . date}
        ,{input-string . => . author}
         ,{input-string . => . event}
          ,{input-string . => . content})
   (values date author event content)))
 
; render-timeline-page: timeline request -> doesn't return
; Produces an HTML page of the content of the
; timeline.
(define (render-timeline-page a-timeline request)  
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Timeline"))
            (body
             (h1 "Timeline")
             (h2 "Please enter: Date      Author      Event      Content")
             ,(render-posts a-timeline embed/url)
             (form ([action
                     ,(embed/url insert-post-handler)])
                   ,@(formlet-display new-post-formlet)
                   (input ([type "submit"])))

             (form ([action
                     ,(embed/url insert-post-handler-date)])
                   (button "Date"))
             (form ([action
                     ,(embed/url insert-post-handler-author)])
                   (button "Author"))
             (form ([action
                     ,(embed/url insert-post-handler-event)])
                   (button "Event"))))))
  
          (define (insert-post-handler request)
           (define-values (date author event content)
             (formlet-process new-post-formlet request))
             (timeline-insert-post! a-timeline date author event content)
                (render-timeline-page a-timeline (redirect/get)))


  
          (define (insert-post-handler-author request)
            (render-timeline-page-author a-timeline (redirect/get)))
  
          (define (insert-post-handler-event request)
            (render-timeline-page-event a-timeline (redirect/get)))

  
          (define (insert-post-handler-date request)
            (render-timeline-page-date a-timeline (redirect/get)))



  
             (send/suspend/dispatch response-generator))
 
; new-comment-formlet : formlet string
; A formlet for requesting a comment
(define new-comment-formlet
  input-string)
 
; render-post: post (handler -> string) -> xexpr
; Consumes a post, produces an xexpr fragment of the post.
; The fragment contains a link to show a detailed view of the post.
(define (render-post a-timeline a-post embed/url)

  `(div ([class ""])
        (p ,(post-date a-post) ,(post-author a-post),
           (post-event a-post), (post-content a-post))))
       
 
; render-posts: timeline (handler -> string) -> xexpr
; Consumes a embed/url, produces an xexpr fragment
; of all its posts.
(define (render-posts a-timeline embed/url)
  (define (render-post/embed/url a-post)
    (render-post a-timeline a-post embed/url))
  `(div ([class "timeline"])
        ,@(map render-post/embed/url (timeline-posts a-timeline))))
 
; render-as-itemized-list: (listof xexpr) -> xexpr
; Consumes a list of items, and produces a rendering as
; an unorderered list.
(define (render-as-itemized-list fragments)
  `(ul ,@(map render-as-item fragments)))
 
; render-as-item: xexpr -> xexpr
; Consumes an xexpr, and produces a rendering
; as a list item.
(define (render-as-item a-fragment)
  `(li ,a-fragment))


 ; render-timeline-page: timeline request -> doesn't return
; Produces an HTML page of the content of the
; timeline.
(define (render-timeline-page-date a-timeline request)

 ;; Get Ordered list of id #s
  (define s (query-list (timeline-db a-timeline)
              "SELECT id FROM timeline ORDER BY date"))
 ;; Turn list of id #s into list of posts
  (define v (map (lambda (x )( post a-timeline x)) s))

  (define (response-generator embed/url)
  
    (response/xexpr
     `(html (head (title "Timeline"))
            (body
             (h1 "Timeline By Date")
             
             ,(render-dates a-timeline v embed/url)
             (form ([action
                     ,(embed/url insert-post-handler)])
                   ,@(formlet-display new-post-formlet)
                   (input ([type "submit"])))

             (form ([action
                     ,(embed/url insert-post-handler-reset)])
                 
                   (button "RESET"))
             (form ([action
                     ,(embed/url insert-post-handler-author)])
                 
                   (button "Author"))

             (form ([action
                     ,(embed/url insert-post-handler-event)])
                 
                   (button "Event")) ) )))
 
  (define (insert-post-handler request)
    (define-values (author date event content)
      (formlet-process new-post-formlet request))
    (timeline-insert-post! a-timeline author date event content)
    (render-timeline-page a-timeline (redirect/get)))
  
(define (insert-post-handler-reset request)
    (render-timeline-page a-timeline (redirect/get)))


  (define (insert-post-handler-author request)
    (render-timeline-page-author a-timeline (redirect/get)))


(define (insert-post-handler-event request)
    (render-timeline-page-event a-timeline (redirect/get)))


  
  (send/suspend/dispatch response-generator))

 ; render-timeline-page-author: timeline request -> doesn't return
; Produces an HTML page of the content of the
; timeline.
(define (render-timeline-page-author a-timeline request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Timeline"))
            (body
             (h1 "Timeline")
             (h2 "Author Page Under Construction")
             ,(render-posts-author a-timeline embed/url)
             (form ([action
                     ,(embed/url insert-post-handler)])
                   ,@(formlet-display new-post-formlet)
                   (input ([type "submit"])))

            (form ([action
                     ,(embed/url insert-post-handler-date)])
                 
                   (button "Date"))
            (form ([action
                     ,(embed/url insert-post-handler-reset)])
                 
                   (button "RESET"))

            (form ([action
                     ,(embed/url insert-post-handler-event)])
                 
                   (button "Event") )) )))
 
  (define (insert-post-handler request)
    (define-values (author date event content)
      (formlet-process new-post-formlet request))
    (timeline-insert-post! a-timeline author date event content)
    (render-timeline-page a-timeline (redirect/get)))


  
(define (insert-post-handler-date request)
    (render-timeline-page-date a-timeline (redirect/get)))


  (define (insert-post-handler-reset request)
    (render-timeline-page-reset a-timeline (redirect/get)))


(define (insert-post-handler-event request)
    (render-timeline-page-event a-timeline (redirect/get)))


  
  (send/suspend/dispatch response-generator))


 ; render-timeline-page-event: timeline request -> doesn't return
; Produces an HTML page of the content of the
; timeline.
(define (render-timeline-page-event a-timeline request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Timeline"))
            (body
             (h1 "Timeline")
            (h2 "Event Page Underconstruction")
             ,(render-posts-event a-timeline embed/url)
             (form ([action
                     ,(embed/url insert-post-handler)])
                   ,@(formlet-display new-post-formlet)
                   (input ([type "submit"])))

              (form ([action
                     ,(embed/url insert-post-handler-date)])
                 
                   (button "Date"))
              (form ([action
                     ,(embed/url insert-post-handler-author)])
                 
                   (button "Author"))

               (form ([action
                     ,(embed/url insert-post-handler-reset)])
                 
                   (button "Reset")) ) )))
 
  (define (insert-post-handler request)
    (define-values (author date event content)
      (formlet-process new-post-formlet request))
    (timeline-insert-post! a-timeline author date event content)
    (render-timeline-page a-timeline (redirect/get)))

(define (insert-post-handler-date request)
    (render-timeline-page-date a-timeline (redirect/get)))
  
(define (insert-post-handler-author request)
    (render-timeline-page-author a-timeline (redirect/get)))


  (define (insert-post-handler-reset request)
    (render-timeline-page-reset a-timeline (redirect/get)))



  
  (send/suspend/dispatch response-generator))


 ; render-timeline-page-reset: timeline request -> doesn't return
; Produces an HTML page of the content of the
; timeline.
(define (render-timeline-page-reset a-timeline request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Timeline"))
            (body
             (h1 "Timeline")
             (h2 "Please enter: Date      Author      Event      Content ")
             ,(render-posts a-timeline embed/url)
             (form ([action
                     ,(embed/url insert-post-handler)])
                   ,@(formlet-display new-post-formlet)
                   (input ([type "submit"])))

                (form ([action
                     ,(embed/url insert-post-handler-date)])
                 
                   (button "date"))
             (form ([action
                     ,(embed/url insert-post-handler-author)])
                 
                   (button "Author"))

              (form ([action
                     ,(embed/url insert-post-handler-event)])
                 
                   (button "Event")) ) )))
 
  (define (insert-post-handler request)
    (define-values (author date event content)
      (formlet-process new-post-formlet request))
    (timeline-insert-post! a-timeline author date event content)
    (render-timeline-page a-timeline (redirect/get)))

(define (insert-post-handler-date request)
    (render-timeline-page-date a-timeline (redirect/get)))
  
(define (insert-post-handler-reset request)
    (render-timeline-page a-timeline (redirect/get)))


  (define (insert-post-handler-author request)
    (render-timeline-page-author a-timeline (redirect/get)))


(define (insert-post-handler-event request)
    (render-timeline-page-event a-timeline (redirect/get)))


  
  (send/suspend/dispatch response-generator))


; render-posts-date: 
(define (render-posts-date a-timeline embed/url)
  
  (define (render-post/embed/url a-post)
    (render-post a-timeline a-post embed/url))
  `(div ([class "timeline"])
      ,@(map render-post/embed/url   a-timeline)))
 
; render-posts-author:
(define (render-posts-author a-timeline embed/url)
  (define (render-post/embed/url a-post)
   
    (render-post a-timeline a-post embed/url))
  `(div ([class "timeline"])))
     

; render-posts-event:
(define (render-posts-event a-timeline embed/url)
  (define (render-post/embed/url a-post)
    (render-post a-timeline a-post embed/url))
  `(div ([class "timeline"])))


; render-date: post (handler -> string) -> xexpr
; Consumes a post, produces an xexpr fragment of the post.
; The fragment contains a link to show a detailed view of the post.
(define (render-date a-timeline a-post embed/url)

  `(div ([class ""])
        (p 
           ,(date-date a-post), (date-author a-post)
         , (date-event a-post), (date-content a-post))))
         
 
; render-dates: timeline (handler -> string) -> xexpr
; Consumes a embed/url, produces an xexpr fragment
; of all its posts.
(define (render-dates a-timeline o embed/url)
  (define (render-post/embed/url a-post)
    (render-date a-timeline a-post embed/url))
  `(div ([class "timeline"])
        ,@(map render-post/embed/url o)))


;date-date: gets date for date page
(define (date-date a-post)
  (query-value
   (timeline-db (post-timeline a-post ))
   "SELECT date FROM timeline WHERE id = ?"
   (post-id  a-post)))

;date-author: gets author for date page
(define (date-author a-post)
  (query-value
   (timeline-db (post-timeline a-post ))
   "SELECT author FROM timeline WHERE id = ?"
   (post-id  a-post)))

;date-event: gets event for date page
(define (date-event a-post)
  (query-value
   (timeline-db (post-timeline a-post ))
   "SELECT event FROM timeline WHERE id = ?"
   (post-id  a-post)))

;date-content: gets content for date page
(define (date-content a-post)
  (query-value
   (timeline-db (post-timeline a-post ))
   "SELECT content FROM timeline WHERE id = ?"
   (post-id  a-post)))