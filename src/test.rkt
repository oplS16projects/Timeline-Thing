#lang web-server/insta
 
(require web-server/formlets
         "trial_model.rkt")
 
; start: request -> doesn't return
; Consumes a request and produces a page that displays
; all of the web content.
(define (start request)
  (render-timeline-page
   (initialize-timeline!
    (build-path (current-directory)
                "timeline.sqlite"))
   request))
 
; new-post-formlet : formlet (values string? string? string? string?)
; A formlet for requesting a title and body of a post
(define new-post-formlet
  (formlet
   (#%# ,{input-string . => . title}
        ,{input-string . => . body}
        ,{input-string . => . content}
        ,{input-string . => . date})
   (values title body content date)))

;; date-formlet
(define date-formlet
  (display 'HELP))
; render-timeline-page: timeline request -> doesn't return
; Produces an HTML page of the content of the
; timeline.
(define (render-timeline-page a-timeline request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Timeline"))
               
            (body 
             (h1 "Timeline")
             ,(render-posts a-timeline embed/url)
             (form ([action
                     ,(embed/url insert-post-handler)])
                   ,@(formlet-display new-post-formlet)
                   (input ([type "submit"]))
                   )
          

             ))))


    
  (define (insert-post-handler request)
    (define-values (title body content date)
      (formlet-process new-post-formlet request))
    (timeline-insert-post! a-timeline title body content date)
    (render-timeline-page a-timeline (redirect/get)))
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
     `(html (head (title "Post Details"))
            (body
             (h1 "Post Details")
             (h2 ,(post-title a-post))
             (p ,(post-body a-post))
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
     `(html (head (title "Add a Comment"))
            (body
             (h1 "Add a Comment")
             "The comment: " (div (p ,a-comment))
             "will be added to "
             (div ,(post-title a-post))
 
             (p (a ([href ,(embed/url yes-handler)])
                   "Yes, add the comment."))
             (p (a ([href ,(embed/url cancel-handler)])
                   "No, I changed my mind!"))))))
 
  (define (yes-handler request)
;;    (post-insert-comment! a-timeline a-post a-comment)
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

  
  `(div ([class "post"])
       ;; (a ([href ,(embed/url view-post-handler)])
       ;;    ,(post-title a-post))
    
        (render-as-itemized-list (p , (post-title a-post) , (post-body a-post) , (post-content a-post), (post-date a-post)))))
        ;;(div ,(number->string (length (post-comments a-post)))
        ;;     " comment(s)")))

; render-posts: timeline (handler -> string) -> xexpr
; Consumes a embed/url, produces an xexpr fragment
; of all its posts.
(define (render-posts a-timeline embed/url)
  (define (render-post/embed/url a-post)
    (render-post a-timeline a-post embed/url))
  `(div ([class "posts"])
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

