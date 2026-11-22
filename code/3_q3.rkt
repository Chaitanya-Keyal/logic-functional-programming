#lang racket/base

;; (inorder-list tree) -> list
;; List of the values of the binary tree tree in inorder: left subtree,
;; node, right subtree.
;; Recursive reading: the inorder list of () is (); the inorder list of
;; (value left right) is the inorder list of left, followed by value,
;; followed by the inorder list of right. An accumulator is used so that no
;; append is needed.
(define (inorder-list tree)
  (inorder-list-acc tree '()))

;; (inorder-list-acc tree acc) -> list
;; The inorder list of tree followed by acc.
;; Recursive reading: for () the result is acc; for (value left right) the
;; right subtree's inorder list is placed in front of acc, then value is
;; consed on, then the left subtree is processed, so the result is
;; left, value, right, acc. The left call is tail recursive.
(define (inorder-list-acc tree acc)
  (cond
    [(null? tree) acc]
    [else
     (inorder-list-acc (cadr tree)
                       (cons (car tree)
                             (inorder-list-acc (caddr tree) acc)))]))
