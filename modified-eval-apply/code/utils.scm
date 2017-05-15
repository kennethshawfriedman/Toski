(declare (usual-integrations))


(define (identity x) x)

(define (any? x) #t)


(define ((compose f g) x) (f (g x)))


;;; This is to keep the Scheme printer from going into an infinite
;;; loop if you try to print a circular data structure, such as an
;;; environment.  This is complicated by the fact that there was
;;; a recent change to MIT/GNU system fluid variables, and this must
;;; work in multiple versions.  Sorry!

(if (or (not *unparser-list-depth-limit*)
        (number? *unparser-list-depth-limit*))
    (begin
      (set! *unparser-list-depth-limit* 10)
      (set! *unparser-list-breadth-limit* 10)
      )
    (begin
      (set-fluid! *unparser-list-depth-limit* 10)
      (set-fluid! *unparser-list-breadth-limit* 10)
      ))

