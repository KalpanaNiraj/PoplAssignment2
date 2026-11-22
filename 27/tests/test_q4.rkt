#lang racket/base
;; Tests for S2 (code/27_q4.rkt). Run from 27: racket tests/test_q4.rkt
(require racket/port racket/runtime-path)

(define-runtime-path solution-path "../code/27_q4.rkt")
(dynamic-require solution-path #f)
(define ns (module->namespace solution-path))

;; call a function of the solution with already-evaluated arguments
(define (call name . args)
  (eval (cons name (map (lambda (a) (list 'quote a)) args)) ns))

(define total 0)
(define passed 0)

(define (check name actual expected)
  (set! total (+ total 1))
  (cond ((equal? actual expected)
         (set! passed (+ passed 1))
         (display (string-append "PASS " name "\n")))
        (else
         (display (string-append "FAIL " name "\n"))
         (display (string-append "  expected: " (format "~s" expected) "\n"))
         (display (string-append "  actual:   " (format "~s" actual) "\n")))))

;; run print-insert-result with the given standard input, return the output
(define (run-print input)
  (with-output-to-string
    (lambda ()
      (parameterize ((current-input-port (open-input-string input)))
        (eval '(print-insert-result) ns)))))

(define (range-list k) ; (1 2 ... k)
  (let loop ((i k) (acc '()))
    (if (= i 0) acc (loop (- i 1) (cons i acc)))))

(define (nest k) ; k wrappers around ()
  (let loop ((i k) (acc '()))
    (if (= i 0) acc (loop (- i 1) (list acc)))))

;; every level of an expected deep structure: depth k gives (x (x (... (x))))
(define (deep-expected x k)
  (let loop ((i k) (acc (list x)))
    (if (= i 0) acc (loop (- i 1) (list x acc)))))

;; ---------------- print-insert-result: assignment examples ----------------
(check "print ex1"
       (run-print "42 ((1 2) (3 4 5) (6) ()) 3")
       "((42 1 2) (3 4 5) (42 6) (42))\n")
(check "print ex2"
       (run-print "0 (((1) 2) (3) ((4 5 6) ())) 3")
       "((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))\n")
(check "print ex3 empty list n=3" (run-print "7 () 3") "(7)\n")
(check "print ex4 empty list n=0" (run-print "7 () 0") "()\n")
(check "print input over several lines"
       (run-print "42\n((1 2)\n (3 4 5) (6) ())\n3\n")
       "((42 1 2) (3 4 5) (42 6) (42))\n")
(check "print symbol x"
       (run-print "a ((b) c ()) 2")
       "((a b) c (a))\n")

;; ---------------- insert-if-short ----------------
(check "n=0 nested list unchanged"
       (call 'insert-if-short 5 '(((1) 2) (3) ()) 0)
       '(((1) 2) (3) ()))
(check "n=0 empty list" (call 'insert-if-short 5 '() 0) '())
(check "n=1 only empty lists get x"
       (call 'insert-if-short 'x '(() (1) (() 2) ()) 1)
       '((x) (1) ((x) 2) (x)))
(check "n=1 empty top-level list" (call 'insert-if-short 'x '() 1) '(x))
(check "atom-only list, short"
       (call 'insert-if-short 9 '(1 2 3) 4) '(9 1 2 3))
(check "atom-only list, not short"
       (call 'insert-if-short 9 '(1 2 3) 3) '(1 2 3))
(check "symbol x and symbol elements"
       (call 'insert-if-short 'z '(a (b c) d) 3)
       '(a (z b c) d))
(check "deep nesting 100 levels, every level gets x"
       (call 'insert-if-short 9 (nest 100) 1000)
       (deep-expected 9 100))
(check "deep nesting 100 levels, n=0 unchanged"
       (call 'insert-if-short 9 (nest 100) 0)
       (nest 100))
(let ((flat (range-list 10000)))
  (check "flat 10000 elements, n=10000 unchanged"
         (call 'insert-if-short 0 flat 10000) flat)
  (check "flat 10000 elements, n=10001 gets x"
         (call 'insert-if-short 0 flat 10001) (cons 0 flat)))
;; original length rule: ((1)) has length 1; its child (1) becomes (0 1)
;; (length 2) but the parent is still judged by its original length 1.
(check "original length rule: length n-1 is short"
       (call 'insert-if-short 0 '((1)) 2) '(0 (0 1)))
(check "original length rule: length n is not short even if children grow"
       (call 'insert-if-short 0 '((1) (2)) 2) '((0 1) (0 2)))
(check "original length rule: child grows to length n, parent length n-1"
       (call 'insert-if-short 0 '((1 2)) 3) '(0 (0 1 2)))

;; ---------------- my-length ----------------
(check "my-length ()" (call 'my-length '()) 0)
(check "my-length (1 2 3)" (call 'my-length '(1 2 3)) 3)
(check "my-length ((1 2) () 3)" (call 'my-length '((1 2) () 3)) 3)
(check "my-length 10000" (call 'my-length (range-list 10000)) 10000)

;; ---------------- my-reverse ----------------
(check "my-reverse ()" (call 'my-reverse '()) '())
(check "my-reverse (1 2 3)" (call 'my-reverse '(1 2 3)) '(3 2 1))
(check "my-reverse nested stays shallow"
       (call 'my-reverse '((1 2) 3)) '(3 (1 2)))
(check "my-reverse 10000"
       (call 'my-reverse (range-list 10000))
       (let loop ((i 1) (acc '()))
         (if (> i 10000) acc (loop (+ i 1) (cons i acc)))))

;; ---------------- my-map ----------------
(define (call-map fn-expr lst)
  (eval (list 'my-map fn-expr (list 'quote lst)) ns))
(check "my-map () identity" (call-map '(lambda (e) e) '()) '())
(check "my-map +1 (1 2 3)" (call-map '(lambda (e) (+ e 1)) '(1 2 3)) '(2 3 4))
(check "my-map keeps order"
       (call-map '(lambda (e) (list e)) '(a b c)) '((a) (b) (c)))
(check "my-map +1 on 10000"
       (call-map '(lambda (e) (+ e 1)) (range-list 10000))
       (let loop ((i 10001) (acc '()))
         (if (< i 2) acc (loop (- i 1) (cons i acc)))))

;; ---------------- make-inserter ----------------
(define (call-inserter x len-ok-expr lst)
  (eval (list (list 'make-inserter (list 'quote x) len-ok-expr)
              (list 'quote lst))
        ns))
(check "make-inserter len = 2"
       (call-inserter 'z '(lambda (k) (= k 2)) '((1 2) (3) () (4 5)))
       '((z 1 2) (3) () (z 4 5)))
(check "make-inserter len < 3 (S2.b example)"
       (call-inserter 42 '(lambda (k) (< k 3)) '((1 2) (3 4 5) (6) ()))
       '((42 1 2) (3 4 5) (42 6) (42)))
(check "make-inserter on empty list, len-ok true"
       (call-inserter 7 '(lambda (k) (< k 3)) '()) '(7))
(check "make-inserter on empty list, len-ok false"
       (call-inserter 7 '(lambda (k) (< k 0)) '()) '())
(check "make-inserter top-level list also qualifies"
       (call-inserter 'z '(lambda (k) (= k 2)) '(1 2))
       '(z 1 2))

(display (string-append "passed " (number->string passed) " of "
                        (number->string total) "\n"))
