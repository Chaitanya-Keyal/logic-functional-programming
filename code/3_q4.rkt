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
