;;; Load up extended Scheme interpreter

;;; The next three expressions build an environment structure for safely
;;;  experimenting with generic operations.
(set! user-initial-environment (make-top-level-environment))
(environment-define user-initial-environment 
                    'generic-evaluation-environment
                    (extend-top-level-environment user-initial-environment))
(define generic-evaluation-environment 
  (access generic-evaluation-environment user-initial-environment))

(load "/Users/blake/Dropbox (MIT)/Classes/6.945/Final_Project/Schemer/modified-eval-apply/code/utils" user-initial-environment)
(load "/Users/blake/Dropbox (MIT)/Classes/6.945/Final_Project/Schemer/modified-eval-apply/code/ghelper" user-initial-environment)
(load "/Users/blake/Dropbox (MIT)/Classes/6.945/Final_Project/Schemer/modified-eval-apply/code/syntax" user-initial-environment)
(load "/Users/blake/Dropbox (MIT)/Classes/6.945/Final_Project/Schemer/modified-eval-apply/code/rtdata" user-initial-environment)

(load "/Users/blake/Dropbox (MIT)/Classes/6.945/Final_Project/Schemer/modified-eval-apply/code/interp" generic-evaluation-environment)
(load "/Users/blake/Dropbox (MIT)/Classes/6.945/Final_Project/Schemer/modified-eval-apply/code/repl" generic-evaluation-environment)

;;; This allows nonstrict definitions.
;;; (load "general-procedures" generic-evaluation-environment)
;;; (load "kons" generic-evaluation-environment)

(ge generic-evaluation-environment)

