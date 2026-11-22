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
