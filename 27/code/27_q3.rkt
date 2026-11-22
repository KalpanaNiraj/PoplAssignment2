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
