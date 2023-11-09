#lang racket/base

(require gregor
         net/http-client
         net/http-easy
         racket/cmdline
         racket/list
         racket/match
         threading)

(define email-address (make-parameter ""))

(define password (make-parameter ""))

(command-line
 #:program "racket extract.rkt"
 #:once-each
 [("-e" "--email-address") email
                           "Email address used for FinViz"
                           (email-address email)]
 [("-p" "--password") pass
                      "Password used for FinViz"
                      (password pass)])

(define-values (status headers body)
  (http-sendrecv "finviz.com"
                 "/login_submit.ashx"
                 #:ssl? #t
                 #:method "POST"
                 #:headers (list "Content-Type: application/x-www-form-urlencoded")
                 #:data (string-append "email=" (email-address)
                                       "&password=" (password)
                                       "&remember=true")))

(define aspx-auth
  (filter-map (λ (h) (match h [(regexp #rx"\\.ASPXAUTH=([0-9A-F]+);" (list str auth))
                               (bytes->string/utf-8 auth)]
                            [_ #f]))
              headers))

(call-with-output-file* (string-append "/var/tmp/finviz/screener/" (date->iso8601 (today)) ".csv")
  (λ (out) (~> (get "https://finviz.com/export.ashx?v=151"
                    #:headers (hash 'Cookie
                                    (string-append "screenerUrl=screener.ashx%3Fv%3D151; "
                                                   "screenerCustomTable=0%2C1%2C2%2C3%2C4; "
                                                   ".ASPXAUTH=" (first aspx-auth) ";")))
               (response-body _)
               (write-bytes _ out)))
  #:exists 'replace)
