#lang racket/base
;; Tests for S1 (code/27_q3.rkt). Run from the 27 folder: racket tests/test_q3.rkt
(require racket/port racket/runtime-path)

(define-runtime-path solution-path "../code/27_q3.rkt")
(dynamic-require solution-path #f)
(define ns (module->namespace solution-path))

;; call a solution function on a tree (as quoted data) in the solution namespace
(define (call f tree) (eval (list f (list 'quote tree)) ns))
(define (output-of f tree) (with-output-to-string (lambda () (call f tree))))

(define total 0)
(define passed 0)
(define (check name actual expected)
  (set! total (+ total 1))
  (cond ((equal? actual expected)
         (set! passed (+ passed 1))
         (display "PASS ") (display name) (newline))
        (else
         (display "FAIL ") (display name) (newline)
         (display "  expected: ") (write expected) (newline)
         (display "  actual:   ") (write actual) (newline))))

;; ---- tree builders (test side only) ----
(define (right-chain n)              ; 1 -> 2 -> ... -> n going right
  (let loop ((i n) (t '()))
    (if (= i 0) t (loop (- i 1) (list i '() t)))))
(define (left-chain n)               ; n at top, going left down to 1
  (let loop ((i 1) (t '()))
    (if (> i n) t (loop (+ i 1) (list i t '())))))
(define (full-bst lo hi)             ; balanced BST on lo..hi
  (if (> lo hi)
      '()
      (let ((mid (quotient (+ lo hi) 2)))
        (list mid (full-bst lo (- mid 1)) (full-bst (+ mid 1) hi)))))
(define (range a b) (if (> a b) '() (cons a (range (+ a 1) b))))
(define (strictly-increasing? l)
  (or (null? l) (null? (cdr l))
      (and (< (car l) (cadr l)) (strictly-increasing? (cdr l)))))

(define t1 '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))
(define t2 '(1 () (2 () (3 () ()))))
(define t3 '(a (b () ()) (c () ())))
(define single '(5 () ()))
(define left-skew '(3 (2 (1 () ()) ()) ()))
(define right-skew '(1 () (2 () (3 () ()))))
(define mixed '(x (1 (y () ()) (2 () ())) (z () (3 () ()))))
(define deep (right-chain 100))
(define full (full-bst 1 1023))

;; ---- print-inorder ----
(check "print-inorder t1" (output-of 'print-inorder t1) "(1 2 3 4 5 6 7)\n")
(check "print-inorder t2" (output-of 'print-inorder t2) "(1 2 3)\n")
(check "print-inorder t3" (output-of 'print-inorder t3) "(b a c)\n")
(check "print-inorder ()" (output-of 'print-inorder '()) "()\n")
(check "print-inorder single" (output-of 'print-inorder single) "(5)\n")
(check "print-inorder left-skew" (output-of 'print-inorder left-skew) "(1 2 3)\n")
(check "print-inorder right-skew" (output-of 'print-inorder right-skew) "(1 2 3)\n")
(check "print-inorder mixed" (output-of 'print-inorder mixed) "(y 1 2 x z 3)\n")

;; ---- print-all-traversals ----
(check "print-all-traversals t1" (output-of 'print-all-traversals t1)
       "(1 2 3 4 5 6 7)\n(4 2 1 3 6 5 7)\n(1 3 2 5 7 6 4)\n")
(check "print-all-traversals t2" (output-of 'print-all-traversals t2)
       "(1 2 3)\n(1 2 3)\n(3 2 1)\n")
(check "print-all-traversals t3" (output-of 'print-all-traversals t3)
       "(b a c)\n(a b c)\n(b c a)\n")
(check "print-all-traversals ()" (output-of 'print-all-traversals '()) "()\n()\n()\n")
(check "print-all-traversals single" (output-of 'print-all-traversals single)
       "(5)\n(5)\n(5)\n")
(check "print-all-traversals left-skew" (output-of 'print-all-traversals left-skew)
       "(1 2 3)\n(3 2 1)\n(1 2 3)\n")
(check "print-all-traversals right-skew" (output-of 'print-all-traversals right-skew)
       "(1 2 3)\n(1 2 3)\n(3 2 1)\n")
(check "print-all-traversals mixed" (output-of 'print-all-traversals mixed)
       "(y 1 2 x z 3)\n(x 1 y 2 z 3)\n(y 2 1 3 z x)\n")

;; ---- print-height-and-leaves ----
(check "print-height-and-leaves t1" (output-of 'print-height-and-leaves t1) "(3 4)\n")
(check "print-height-and-leaves t2" (output-of 'print-height-and-leaves t2) "(3 1)\n")
(check "print-height-and-leaves t3" (output-of 'print-height-and-leaves t3) "(2 2)\n")
(check "print-height-and-leaves ()" (output-of 'print-height-and-leaves '()) "(0 0)\n")
(check "print-height-and-leaves single" (output-of 'print-height-and-leaves single) "(1 1)\n")
(check "print-height-and-leaves left-skew" (output-of 'print-height-and-leaves left-skew) "(3 1)\n")
(check "print-height-and-leaves right-skew" (output-of 'print-height-and-leaves right-skew) "(3 1)\n")
(check "print-height-and-leaves mixed" (output-of 'print-height-and-leaves mixed) "(3 3)\n")
(check "print-height-and-leaves depth 100" (output-of 'print-height-and-leaves deep) "(100 1)\n")
(check "print-height-and-leaves full height 10" (output-of 'print-height-and-leaves full) "(10 512)\n")

;; ---- underlying functions (values) ----
(check "tree-height ()" (call 'tree-height '()) 0)
(check "tree-height single" (call 'tree-height single) 1)
(check "tree-height depth 100" (call 'tree-height deep) 100)
(check "leaf-count ()" (call 'leaf-count '()) 0)
(check "leaf-count single" (call 'leaf-count single) 1)
(check "leaf-count depth 100" (call 'leaf-count deep) 1)
(check "leaf-count left chain 100" (call 'leaf-count (left-chain 100)) 1)
(check "tree-height full 1023" (call 'tree-height full) 10)
(check "leaf-count full 1023" (call 'leaf-count full) 512)
(check "inorder depth 100" (call 'tree-inorder deep) (range 1 100))
(check "preorder depth 100" (call 'tree-preorder deep) (range 1 100))
(check "postorder depth 100" (call 'tree-postorder deep) (reverse (range 1 100)))
(check "inorder full is 1..1023" (call 'tree-inorder full) (range 1 1023))
(check "inorder full strictly increasing" (strictly-increasing? (call 'tree-inorder full)) #t)
(check "preorder full length" (length (call 'tree-preorder full)) 1023)
(check "preorder full root first" (car (call 'tree-preorder full)) 512)
(check "postorder full root last" (car (reverse (call 'tree-postorder full))) 512)

(newline)
(display "passed ") (display passed) (display " of ") (display total) (newline)
