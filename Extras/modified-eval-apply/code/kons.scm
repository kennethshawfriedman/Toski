;;; A valuable special form -- the nonstrict version of CONS:

(define (kons? exp)
  (and (pair? exp)
       (eq? (car exp) 'kons)))

(defhandler eval
  (lambda (expression environment)
    (cons (delay-memo (cadr expression) environment)
	  (delay-memo (caddr expression) environment)))
  kons?)

