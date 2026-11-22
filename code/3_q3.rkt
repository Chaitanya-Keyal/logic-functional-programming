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

;; (print-inorder tree) -> (display result)
;; Prints the inorder list of tree on one line, followed by one newline.
;; Uses inorder-list so the traversal order is not duplicated here.
(define (print-inorder tree)
  (display (inorder-list tree))
  (newline))

;; (preorder-list tree) -> list
;; List of the values of the binary tree tree in preorder: node, left
;; subtree, right subtree.
;; Recursive reading: the preorder list of () is (); the preorder list of
;; (value left right) is value, followed by the preorder list of left,
;; followed by the preorder list of right. An accumulator is used so that no
;; append is needed.
(define (preorder-list tree)
  (preorder-list-acc tree '()))

;; (preorder-list-acc tree acc) -> list
;; The preorder list of tree followed by acc.
;; Recursive reading: for () the result is acc; for (value left right) the
;; right subtree's preorder list is placed in front of acc, then the left
;; subtree's preorder list is placed in front of that, then value is consed
;; on, so the result is value, left, right, acc.
(define (preorder-list-acc tree acc)
  (cond
    [(null? tree) acc]
    [else
     (cons (car tree)
           (preorder-list-acc (cadr tree)
                              (preorder-list-acc (caddr tree) acc)))]))

;; (postorder-list tree) -> list
;; List of the values of the binary tree tree in postorder: left subtree,
;; right subtree, node.
;; Recursive reading: the postorder list of () is (); the postorder list of
;; (value left right) is the postorder list of left, followed by the
;; postorder list of right, followed by value. An accumulator is used so that
;; no append or reverse is needed.
(define (postorder-list tree)
  (postorder-list-acc tree '()))

;; (postorder-list-acc tree acc) -> list
;; The postorder list of tree followed by acc.
;; Recursive reading: for () the result is acc; for (value left right), value
;; is consed on to acc, then the right subtree's postorder list is placed in
;; front of that, then the left subtree's postorder list is placed in front,
;; so the result is left, right, value, acc. The left call is tail recursive.
(define (postorder-list-acc tree acc)
  (cond
    [(null? tree) acc]
    [else
     (postorder-list-acc (cadr tree)
                         (postorder-list-acc (caddr tree)
                                             (cons (car tree) acc)))]))
