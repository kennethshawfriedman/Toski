#|
Startup.scm
May 11, 2017
By Kenny Friedman, Blake Elias, and Jared Pochtar

This code is run at start up. It does the following things:
- creates and manages the environments for real vs. preview executions

|#

(display "Startup.scm has been found & is currently loading.")

;;;; Set Up

;define the new environment
;(define preview-env (extend-top-level-environment (the-environment)))

;enter the new environment
;(ge preview-env)

;return to the original 
;(ge (environment-parent (the-environment)))



#|

(define safe-eval
    (let
        ((reporting-error-handler (lambda (error)
            (pp (list "error" (condition/report-string error)))
            (newline)
            (restart 1))))

        (lambda (env code-to-eval-as-string)
            (bind-condition-handler '() reporting-error-handler
                (lambda ()
                    (eval
                        (read (string->input-port
                            (string-append
                            "((lambda ()"
                            code-to-eval-as-string
                            "))")))
                        env))))))



; (safe-eval (the-environment) "(define (foo n) (+ n 3))(foo 4)")
; (safe-eval (the-environment) "(define malformed")

|#





(display "Startup.scm has loaded.")

