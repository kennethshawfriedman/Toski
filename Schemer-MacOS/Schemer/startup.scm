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









(display "Startup.scm has loaded.")

