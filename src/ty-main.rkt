#lang web-server/insta
 
(require web-server/formlets
         "f-model.rkt")
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
   (#%# ,{input-string . => . author}
        ,{input-string . => . date}
         ,{input-string . => . event}
          ,{input-string . => . content})
   (values author date event content)))
 
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
    (define-values (author date event content)
      (formlet-process new-post-formlet request))
    (timeline-insert-post! a-timeline author date event content)
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
 
; render-post-detail-page: post request -> doesn't return
; Consumes a post and produces a detail page of the post.
; The user will be able to either insert new comments
; or go back to render-timeline-page.
(define (render-post-detail-page a-timeline a-post request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (author "Post Details"))
            (date
             (h1 "Post Details")
             (h2 ,(post-author a-post))
             (p ,(post-date a-post))
             ,(render-as-itemized-list
               (post-comments a-post))
             (form ([action
                     ,(embed/url insert-comment-handler)])
                   ,@(formlet-display new-comment-formlet)
                   (input ([type "submit"])))
             (a ([href ,(embed/url back-handler)])
                "Back to the timeline")))))
 
  (define (insert-comment-handler request)
    (render-confirm-add-comment-page
     a-timeline
     (formlet-process new-comment-formlet request)
     a-post
     request))
 
  (define (back-handler request)
    (render-timeline-page a-timeline request))
  (send/suspend/dispatch response-generator))
 
; render-confirm-add-comment-page :
; timeline comment post request -> doesn't return
; Consumes a comment that we intend to add to a post, as well
; as the request. If the user follows through, adds a comment 
; and goes back to the display page. Otherwise, goes back to 
; the detail page of the post.
(define (render-confirm-add-comment-page a-timeline a-comment
                                         a-post request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (author "Add a Comment"))
            (date
             (h1 "Add a Comment")
             "The comment: " (div (p ,a-comment))
             "will be added to "
             (div ,(post-author a-post))
 
             (p (a ([href ,(embed/url yes-handler)])
                   "Yes, add the comment."))
             (p (a ([href ,(embed/url cancel-handler)])
                   "No, I changed my mind!"))))))
 
  (define (yes-handler request)
    (post-insert-comment! a-timeline a-post a-comment)
    (render-post-detail-page a-timeline a-post (redirect/get)))
 
  (define (cancel-handler request)
    (render-post-detail-page a-timeline a-post request))
  (send/suspend/dispatch response-generator))
 
; render-post: post (handler -> string) -> xexpr
; Consumes a post, produces an xexpr fragment of the post.
; The fragment contains a link to show a detailed view of the post.
(define (render-post a-timeline a-post embed/url)
  (define (view-post-handler request)
    (render-post-detail-page a-timeline a-post request))
  `(div ([class ""])
        (p 
           ,(post-author a-post)
         ,(post-date a-post), (post-event a-post), (post-content a-post))))
       
 
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
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Timeline"))
            (body
             (h1 "Timeline")
             ,(render-posts-date a-timeline embed/url)
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
                 
                   (button "Event"))




 )


             )))
 
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

 ; render-timeline-page: timeline request -> doesn't return
; Produces an HTML page of the content of the
; timeline.
(define (render-timeline-page-author a-timeline request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Timeline"))
            (body
             (h1 "Timeline")
             (h2 "Please enter: Date      Author      Event      Content")
             (h3 "              19770125  Tyrone       Birthday    Yeah!")
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
                 
                   (button "Event"))




 )


             )))
 
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


 ; render-timeline-page: timeline request -> doesn't return
; Produces an HTML page of the content of the
; timeline.
(define (render-timeline-page-event a-timeline request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Timeline"))
            (body
             (h1 "Timeline")
             (h2 "Please enter: Date      Author      Event      Content")
             (h3 "              19770125  Tyrone       Birthday    Yeah!")
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
                 
                   (button "Reset"))




 )


             )))
 
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


 ; render-timeline-page: timeline request -> doesn't return
; Produces an HTML page of the content of the
; timeline.
(define (render-timeline-page-reset a-timeline request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Timeline"))
            (body
             (h1 "Timeline")
             (h2 "Please enter: Date      Author      Event      Content")
             (h3 "              19770125  Tyrone       Birthday    Yeah!")
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
                 
                   (button "Event"))




 )


             )))
 
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


; render-posts-date: timeline (handler -> string) -> xexpr
; Consumes a embed/url, produces an xexpr fragment
; of all its posts.
(define (render-posts-date a-timeline embed/url)
  
  (define (render-post/embed/url a-post)
    (render-post a-timeline a-post embed/url))
  `(div ([class "timeline"])
      ,@(map render-post/embed/url (timeline-posts a-timeline))))
 
; render-posts-author: timeline (handler -> string) -> xexpr
; Consumes a embed/url, produces an xexpr fragment
; of all its posts.
(define (render-posts-author a-timeline embed/url)
  (define (render-post/embed/url a-post)
   
    (render-post a-timeline a-post embed/url))
  `(div ([class "timeline"])))
     

; render-posts-event: timeline (handler -> string) -> xexpr
; Consumes a embed/url, produces an xexpr fragment
; of all its posts.
(define (render-posts-event a-timeline embed/url)
  (define (render-post/embed/url a-post)
    (render-post a-timeline a-post embed/url))
  `(div ([class "timeline"])
      (p , "Have a nice day")))
