(load "/Users/blake/Dropbox (MIT)/Classes/6.945/Final_Project/Schemer/modified-eval-apply/code/load")


(define orig-apply apply)

(define (apply procedure arguments calling-environment depth)
; (display "(\n")
   (pp (cons procedure (map (lambda (arg) (eval arg calling-environment (- depth 1))) arguments)))
; ;  (display ")\n")
  (display "   depth: ")
  (display depth)
  (newline)
   (orig-apply procedure arguments calling-environment depth))

(define orig-eval eval)

(define (eval expression environment depth)
 (display expression)
;   (display (orig-eval expression environment depth))
  (display "   depth: ")
  (display depth)
  (newline)
  (orig-eval expression environment depth))

