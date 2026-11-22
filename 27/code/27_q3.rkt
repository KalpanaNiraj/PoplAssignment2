#lang racket/base
;; CS F301 Assignment 2 - S1: Binary Tree Traversals
;; A tree is () or (value left right).

;; (node-value tree) -> number or symbol
;; Recursive reading: not recursive; the value of a non-empty tree (value left right)
;; is its first element.
(define (node-value tree)
  (car tree))

;; (node-left tree) -> tree
;; Recursive reading: not recursive; the left subtree is the second element.
(define (node-left tree)
  (cadr tree))

;; (node-right tree) -> tree
;; Recursive reading: not recursive; the right subtree is the third element.
(define (node-right tree)
  (caddr tree))

;; (inorder-acc tree acc) -> list
;; Recursive reading: for the empty tree (), the result is acc unchanged. For
;; (v l r), first compute the inorder of r onto acc, cons v in front of that, then
;; compute the inorder of l onto the result. Going right first means the final
;; list reads left, node, right without append. The left call is a tail call.
(define (inorder-acc tree acc)
  (if (null? tree)
      acc
      (inorder-acc (node-left tree)
                   (cons (node-value tree)
                         (inorder-acc (node-right tree) acc)))))

;; (tree-inorder tree) -> list
;; Recursive reading: the inorder list of a tree is its inorder-acc onto the empty
;; list; for () that is ().
(define (tree-inorder tree)
  (inorder-acc tree '()))

;; (preorder-acc tree acc) -> list
;; Recursive reading: for the empty tree (), the result is acc unchanged. For
;; (v l r), first compute the preorder of r onto acc, then the preorder of l onto
;; that result, then cons v in front. Going right first, then left, then the node
;; means the final list reads node, left, right without append.
(define (preorder-acc tree acc)
  (if (null? tree)
      acc
      (cons (node-value tree)
            (preorder-acc (node-left tree)
                          (preorder-acc (node-right tree) acc)))))

;; (tree-preorder tree) -> list
;; Recursive reading: the preorder list of a tree is its preorder-acc onto the
;; empty list; for () that is ().
(define (tree-preorder tree)
  (preorder-acc tree '()))

;; (postorder-acc tree acc) -> list
;; Recursive reading: for the empty tree (), the result is acc unchanged. For
;; (v l r), cons v onto acc first (the node comes last), then put the postorder of
;; r in front of that, then the postorder of l in front of that. The final list
;; reads left, right, node without append. The call on l is a tail call.
(define (postorder-acc tree acc)
  (if (null? tree)
      acc
      (postorder-acc (node-left tree)
                     (postorder-acc (node-right tree)
                                    (cons (node-value tree) acc)))))

;; (tree-postorder tree) -> list
;; Recursive reading: the postorder list of a tree is its postorder-acc onto the
;; empty list; for () that is ().
(define (tree-postorder tree)
  (postorder-acc tree '()))

;; (print-inorder tree) -> unspecified (prints)
;; Recursive reading: not recursive itself; it displays the inorder list of the tree
;; (computed by the recursive tree-inorder; () for the empty tree) and then prints
;; exactly one newline. Nothing else is printed.
(define (print-inorder tree)
  (display (tree-inorder tree))
  (newline))

;; (print-all-traversals tree) -> unspecified (prints)
;; Recursive reading: not recursive itself; it displays the inorder list, then the
;; preorder list, then the postorder list of the tree (each computed by the
;; recursive tree-inorder, tree-preorder and tree-postorder), each followed by
;; exactly one newline. Nothing else is printed. For the empty tree it prints
;; three lines of ().
(define (print-all-traversals tree)
  (display (tree-inorder tree))
  (newline)
  (display (tree-preorder tree))
  (newline)
  (display (tree-postorder tree))
  (newline))

;; (tree-height tree) -> number
;; Recursive reading: the height of the empty tree () is 0. The height of a node
;; (v l r) is 1 plus the larger of the height of l and the height of r. So a
;; single node (v () ()) has height 1 + max(0, 0) = 1.
(define (tree-height tree)
  (if (null? tree)
      0
      (+ 1 (max (tree-height (node-left tree))
                (tree-height (node-right tree))))))
