;;; Core of extended Scheme interpreter
;;;
;;; See also structure and predicate definitions in rtdata.scm and
;;; syntax.scm

(declare (usual-integrations eval apply))

(define (default-eval expression environment depth)
  (if (= depth 0)
      expression
      (cond ((application? expression)
         (apply (eval (operator expression) environment (- depth 1))
          (operands expression)
          environment
          (- depth 1)))
        (else
         (error "Unknown expression type" expression)))))

(define (default-apply procedure operands calling-environment depth)
  (error "Unknown procedure type" procedure))

(define eval
  (make-generic-operator 3 'eval default-eval))

(defhandler eval
  (lambda (expression environment depth) expression)
  self-evaluating?)

(defhandler eval 
  (lambda (expression environment depth)
    (lookup-variable-value expression environment))
  variable?)

(defhandler eval
  (lambda (expression environment depth)
    (text-of-quotation expression))
  quoted?)

(defhandler eval
  (lambda (expression environment depth)
    (make-compound-procedure
     (lambda-parameters expression)
     (lambda-body expression)
     environment))
  lambda?)

(defhandler eval
  (lambda (expression environment depth)
    (if (= depth 0)
      expression
      (if (eval (if-predicate expression) environment (- depth 1))
          (eval (if-consequent expression) environment (- depth 1))
          (eval (if-alternative expression) environment (- depth 1)))))
  if?)

(defhandler eval
  (lambda (expression environment depth)
    (if (= depth 0)
      expression
      (eval (cond->if expression) environment (- depth 1))))
  cond?)

(defhandler eval
  (lambda (expression environment depth)
    (eval (let->combination expression) environment (- depth 1)))
  let?)

(defhandler eval
  (lambda (expression environment)
    (if (= depth 0)
      expression
      (evaluate-sequence (begin-actions expression)
		         environment (- depth 1))))
  begin?)

(define (evaluate-sequence actions environment depth)
  (cond ((null? actions)
	 (error "Empty sequence"))
  ((= depth 0) actions)
	((null? (rest-exps actions))
	 (eval (first-exp actions) environment (- depth 1)))
	(else
	 (eval (first-exp actions) environment (- depth 1))
	 (evaluate-sequence (rest-exps actions) environment depth))))

(defhandler eval
  (lambda (expression environment depth)
   ; (if (= depth 0)
   ;   expression
   ;   (begin
        (define-variable! (definition-variable expression)
          (eval (definition-value expression) environment depth)
          environment)
        (definition-variable expression))
  definition?)

(defhandler eval
  (lambda (expression environment depth)
    (if (= depth 0)
      expression
      (set-variable-value! (assignment-variable expression)
        (eval (assignment-value expression) environment (- depth 1))
        environment)))
  assignment?)

(define apply
  (make-generic-operator 4 'apply default-apply))

(defhandler apply
  (lambda (procedure operands calling-environment depth)

    (call-with-current-continuation
     (lambda (cont)
       (bind-condition-handler
        '()
        (lambda (e)
          (cont 

             (cons procedure operands) ;; catch

          )) ;; self-evaluate
        (lambda () 
            ;; try
            (define (evaluate-list operands)
                  (cond ((null? operands) '())
                  ((null? (rest-operands operands))
                   (list (eval (first-operand operands)
                   calling-environment depth)))
                  (else
                   (cons (eval (first-operand operands)
                   calling-environment depth)
                   (evaluate-list (rest-operands operands))))))
                (apply-primitive-procedure procedure
                  (evaluate-list operands) depth)

          ))))
    )
  strict-primitive-procedure?)

(defhandler apply
  (lambda (procedure operands calling-environment depth)

    (call-with-current-continuation
     (lambda (cont)
       (bind-condition-handler
        '()
        (lambda (e)
          (cont 
            
            (cons procedure operands) #| catch |#

            )) ;; self-evaluate
        (lambda () 
          ;; try
          (if (not (= (length (procedure-parameters procedure))
                (length operands)))
              (error "Wrong number of operands supplied"))
          (let ((arguments
           (map (lambda (parameter operand)
            (evaluate-procedure-operand parameter
                      operand
                      calling-environment
                      depth))
          (procedure-parameters procedure)
          operands)))
            (eval (procedure-body procedure)
              (extend-environment
               (map procedure-parameter-name
              (procedure-parameters procedure))
               arguments
               (procedure-environment procedure))
              depth))

          ))))

    )
  compound-procedure?)
  


(define evaluate-procedure-operand
  (make-generic-operator 4
			 'evaluate-operand
			 (lambda (parameter operand environment depth)
         (if (= depth 0)
          operand
          (eval operand environment (- depth 1))))))

(define procedure-parameter-name
  (make-generic-operator 1 'parameter-name (lambda (x) x)))
