;;; Modifications to provide for generalized procedures.

;;; Syntax extension: allow decorated parameter names.

(defhandler procedure-parameter-name car pair?)


;;; run-time-data extension

(define (delay expression environment)
  (vector 'delayed expression environment))

(define (delay-memo expression environment)
  (vector 'delayed-memo expression environment))

(define (delayed? x)
  (and (vector? x)
       (eq? (vector-ref x 0) 'delayed)))

(define (delayed-memo? x)
  (and (vector? x)
       (eq? (vector-ref x 0) 'delayed-memo)))

(define (deferred? x)
  (or (delayed? x) (delayed-memo? x)))

(define (undelayed-memo? x)
  (and (vector? x)
       (eq? (vector-ref x 0) 'undelayed-memo)))
  
(define (delayed-expression x)
  (vector-ref x 1))

(define (delayed-environment x)
  (vector-ref x 2))


(define (undelay-memo! x value)
  (vector-set! x 0 'undelayed-memo)
  (vector-set! x 1 value)
  (vector-set! x 2 the-empty-environment))

(define (undelayed-value x)
  (vector-ref x 1))

;;; Evaluator extension -- change to IF:
;;;  Must have actual predicate value to proceed from IF.

(defhandler eval
  (lambda (expression environment)
    (if (undelay!
	 (eval (if-predicate expression) environment))
	(eval (if-consequent expression) environment)
	(eval (if-alternative expression) environment)))
  if?)


;;; Apply extension:
;;;  Must have actual procedure to apply it.

(defhandler apply
  (lambda (procedure operands calling-environment)
    (apply (undelay! procedure)
	   operands
	   calling-environment))
  deferred?)

(defhandler apply
  (lambda (procedure operands calling-environment)
    (apply (undelayed-value procedure)
	   operands
	   calling-environment))
  undelayed-memo?)

;;; This handler was replaced so it can get values of arguments for
;;; strict primitives.

(defhandler apply
  (lambda (procedure operands calling-environment)
    (define (evaluate-list operands)
      (cond ((null? operands) '())
	    ((null? (rest-operands operands))
	     (list (undelay! (eval (first-operand operands)
				   calling-environment))))
	    (else
	     (cons (undelay! (eval (first-operand operands)
				   calling-environment))
		   (evaluate-list
		    (rest-operands operands))))))
    (apply-primitive-procedure procedure
      (evaluate-list operands)))
  strict-primitive-procedure?)


(defhandler evaluate-procedure-operand
  (lambda (parameter operand environment)
    (delay operand environment))
  lazy?)

(defhandler evaluate-procedure-operand
  (lambda (parameter operand environment)
    (delay-memo operand environment))
  lazy-memo?)

(define undelay!
  (make-generic-operator 1 'undelay! (lambda (x) x)))

(defhandler undelay!
  (lambda (object)
    (undelay! (eval (delayed-expression object)
		    (delayed-environment object))))
  delayed?)

(defhandler undelay!
  (lambda (object)
    (let ((value
	   (undelay! (eval (delayed-expression object)
			   (delayed-environment object)))))
      (undelay-memo! object value)
      value))
  delayed-memo?)

(defhandler undelay!
  undelayed-value
  undelayed-memo?)


;;; For printing output

(defhandler write
  (compose write undelay!)
  deferred?)

(defhandler write-line
  (compose write-line undelay!)
  deferred?)

(defhandler pp
  (compose pp undelay!)
  deferred?)


(defhandler write
  (compose write undelayed-value)
  undelayed-memo?)

(defhandler write-line
  (compose write-line undelayed-value)
  undelayed-memo?)

(defhandler pp
  (compose pp undelayed-value)
  undelayed-memo?)
