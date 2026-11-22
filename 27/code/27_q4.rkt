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
