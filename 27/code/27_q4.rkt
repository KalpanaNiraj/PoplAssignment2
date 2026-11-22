#lang racket/base
;; CS F301 Assignment 2 - S2: Conditionally Insert into a Nested List

;; (my-length lst) -> number
;; Recursive reading: the length of () is 0; the length of (x . rest) is
;; 1 + the length of rest. Tail-recursive via acc: the named let carries the
;; number of elements seen so far, so the recursive call is the last action
;; and a 10,000-element list uses constant stack.
(define (my-length lst)
  (let loop ((rest lst) (acc 0))
    (if (null? rest)
        acc
        (loop (cdr rest) (+ acc 1)))))

;; (my-reverse lst) -> list
;; Recursive reading: the reverse of () is (); the reverse of (x . rest) is
;; the reverse of rest followed by x. Tail-recursive via acc: each element is
;; consed onto acc as it is passed, so acc holds the elements seen so far in
;; reverse order, and the last acc is the answer.
(define (my-reverse lst)
  (let loop ((rest lst) (acc '()))
    (if (null? rest)
        acc
        (loop (cdr rest) (cons (car rest) acc)))))

;; (my-map f lst) -> list
;; Recursive reading: the map of f over () is (); the map of f over (x . rest)
;; is (f x) followed by the map of f over rest. Tail-recursive via acc: the
;; named let conses (f x) onto acc, which builds the results in reverse, and
;; the base case returns (my-reverse acc) to restore the original order.
(define (my-map f lst)
  (let loop ((rest lst) (acc '()))
    (if (null? rest)
        (my-reverse acc)
        (loop (cdr rest) (cons (f (car rest)) acc)))))

;; (print-insert-result) -> unspecified
;; Recursive reading: not recursive. Reads x, then lst, then n from standard
;; input (let* evaluates the three reads in this order), then displays
;; (insert-if-short x lst n) followed by exactly one newline. Prints nothing else.
(define (print-insert-result)
  (let* ((x (read))
         (lst (read))
         (n (read)))
    (display (insert-if-short x lst n))
    (newline)))

;; (make-inserter x len-ok?) -> (list -> list)
;; Recursive reading: returns a function go of one list argument. go first
;; processes every element of its list with my-map: an element that is a list
;; (() or a pair) is replaced by (go e), and an atom is left unchanged. Then,
;; if (len-ok? (my-length lst)) holds for the ORIGINAL list, x is consed onto
;; the front of the processed list. go is bound with letrec so it can call
;; itself on sublists; x and len-ok? are captured from the enclosing call.
(define (make-inserter x len-ok?)
  (letrec ((go
            (lambda (lst)
              (let ((processed
                     (my-map (lambda (e)
                               (if (or (null? e) (pair? e))
                                   (go e)
                                   e))
                             lst)))
                (if (len-ok? (my-length lst))
                    (cons x processed)
                    processed)))))
    go))

;; (insert-if-short x lst n) -> list
;; Recursive reading: builds the inserter (make-inserter x len-ok?) with
;; len-ok? true exactly when a length k is less than n, and applies it to lst.
;; The recursion over sublists, and the measurement of each list's ORIGINAL
;; length before any insertion, are done by make-inserter, so this definition
;; is not itself recursive.
(define (insert-if-short x lst n)
  ((make-inserter x (lambda (k) (< k n))) lst))
