(load "/Users/blake/Dropbox (MIT)/Classes/6.945/Final_Project/Schemer/modified-eval-apply/code/load")


(define orig-apply apply)
(define orig-eval eval)

(define (apply procedure arguments calling-environment depth)
  (list (orig-apply procedure (map car arguments) calling-environment depth)
  	    (list procedure arguments calling-environment)))

;(define (eval expression environment depth)
;	(orig-eval (car expression) environment depth))

#|
(define (apply procedure arguments calling-environment depth)
; (display "(\n")
   (pp (cons procedure (map (lambda (arg) (eval arg calling-environment (- depth 1))) arguments)))
; ;  (display ")\n")
;;  (display "   depth: ")
;;  (display depth)
;;  (newline)
   (orig-apply procedure arguments calling-environment depth))

(define (eval expression environment depth)
;; (display expression)
;   (display (orig-eval expression environment depth))
;;  (display "   depth: ")
;;  (display depth)
;;  (newline)
  (orig-eval expression environment depth))

|#











