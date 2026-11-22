#lang racket/base

;; (my-length lst) -> number
;; Number of top-level elements of lst (atoms or sublists, each counting as
;; one).  Only the spine of lst is walked; sublists are not entered.
;; Recursive reading: the length of () is 0; the length of (a . rest) is
;; 1 + the length of rest.  Tail recursive: acc counts the elements seen so
;; far and rest is the part not yet counted.
(define (my-length lst)
  (let loop ([rest lst] [acc 0])
    (if (null? rest)
        acc
        (loop (cdr rest) (+ acc 1)))))

;; (my-map f lst) -> list
;; List of the results of applying f to each top-level element of lst, in
;; the same order.  Sublists are passed to f as they are, not descended
;; into.
;; Recursive reading: mapping f over () is (); mapping f over (a . rest) is
;; (f a) followed by mapping f over rest.  The recursive call is not a tail
;; call because cons needs its result, which keeps the output in order
;; without building it backwards.
(define (my-map f lst)
  (if (null? lst)
      '()
      (cons (f (car lst))
            (my-map f (cdr lst)))))

;; (insert-if-short x lst n) -> list
;; Copy of lst in which x is put at the front of every list, at every level
;; of nesting, whose length is less than n.  Lengths are measured on the
;; original list, before any insertion, so the top-level list is judged by
;; its original length even though it may gain x.  An element is a list
;; exactly when it is () or a pair; anything else is an atom and is kept as
;; it is.  () has length 0, so it becomes (x) whenever 0 < n.
;; Recursive reading: first insert into the elements of lst with my-map
;; (atoms are unchanged, lists are handled recursively); then, if the
;; original lst was short, cons x onto that result.  The length test uses
;; my-length on the original lst, and my-map preserves the order.
(define (insert-if-short x lst n)
  (let ([processed
         (my-map (lambda (element)
                   (if (or (null? element) (pair? element))
                       (insert-if-short x element n)
                       element))
                 lst)])
    (if (< (my-length lst) n)
        (cons x processed)
        processed)))
